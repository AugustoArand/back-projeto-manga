class Rack::Attack
  # Limite geral por IP em toda a API — proteção básica contra abuso.
  throttle("api/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # A MangaDex aplica rate limit próprio por IP, e todo o tráfego proxy
  # (busca, capítulos, imagens) sai pelo mesmo IP do servidor Rails —
  # um limite GLOBAL (não por cliente) evita que a soma das requisições
  # de todos os usuários do app estoure esse teto e derrube/baneie o IP
  # do backend na MangaDex.
  throttle("mdex/global", limit: 4, period: 1.second) do |req|
    "mdex" if req.path.start_with?("/api/v1/mdex")
  end

  # Limite por IP nas rotas MangaDex, para que um único cliente não consuma
  # sozinho todo o orçamento global acima.
  throttle("mdex/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/v1/mdex")
  end

  self.throttled_responder = lambda do |request|
    match_data   = request.env["rack.attack.match_data"] || {}
    retry_after  = match_data[:period] || 60

    [
      429,
      { "Content-Type" => "application/json", "Retry-After" => retry_after.to_s },
      [ { error: "Muitas requisições. Tente novamente em instantes." }.to_json ]
    ]
  end
end
