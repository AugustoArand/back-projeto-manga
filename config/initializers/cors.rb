Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Permite requisições de qualquer origem para todas as rotas da API
  allow do
    origins "*"

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization", "X-User-Token" ]
  end

  # Garante que erros (404, 500) em qualquer rota também tenham headers CORS
  allow do
    origins "*"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
