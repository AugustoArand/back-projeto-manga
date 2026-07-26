module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from StandardError, with: :internal_server_error

      private

      def not_found
        render json: { error: "Not found" }, status: :not_found
      end

      def internal_server_error(exception)
        Rails.logger.error("[API] Erro interno: #{exception.class} — #{exception.message}")
        Rails.logger.error(exception.backtrace&.first(5)&.join("\n"))
        render json: { error: "Erro interno no servidor" }, status: :internal_server_error
      end

      def cover_url_for(attachment)
        return nil unless attachment&.attached?
        url_for(attachment)
      end

      # ── Autenticação de usuário MangaVerse ────────────────────────────────────

      def authenticate_user!
        token = bearer_token
        return unauthorized! unless token.present?

        @current_session = UserSession.find_active(token)
        return unauthorized! unless @current_session

        @current_user = @current_session.user
      end

      def current_user
        @current_user
      end

      # MangaVerse usa X-User-Token; MangaDex usa Authorization: Bearer
      def bearer_token
        request.headers["X-User-Token"].presence ||
          request.headers["Authorization"]&.delete_prefix("Bearer ")
      end

      def unauthorized!
        render json: { error: "Autenticação necessária" }, status: :unauthorized
      end

      # ── Gate de teste grátis / assinatura ────────────────────────────────────
      # Só usado nas ações que efetivamente entregam conteúdo de leitura
      # (páginas de capítulo) — precisa rodar depois de authenticate_user!.
      def require_active_access!
        return if current_user&.access_active?
        render json: { error: "trial_expired" }, status: :payment_required
      end
    end
  end
end
