module Api
  module V1
    # Ativação de VIP. Por enquanto simula a confirmação de pagamento (não há
    # gateway real integrado ainda) — troque `subscribe` por um webhook do
    # gateway quando isso existir; o contrato com o app não muda.
    class PlansController < BaseController
      before_action :authenticate_user!

      def subscribe
        current_user.update!(vip: true)
        render json: current_user.as_api_json
      end
    end
  end
end
