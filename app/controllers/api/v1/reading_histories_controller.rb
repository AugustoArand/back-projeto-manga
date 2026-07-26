module Api
  module V1
    class ReadingHistoriesController < BaseController
      before_action :authenticate_user!

      def index
        @histories = current_user.reading_histories.recent
        render json: @histories.map { |h|
          {
            id: h.id,
            title: h.title,
            cover_url: h.cover_url,
            genre: h.genre,
            manga_id: h.manga_id,
            mangadex_id: h.mangadex_id,
            chapter_label: h.chapter_label,
            mangadex_chapter_id: h.mangadex_chapter_id,
            updated_at: h.updated_at
          }
        }
      end

      def create
        @history = ReadingHistory.track(history_params, user: current_user)
        render json: { id: @history.id }, status: :created
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def history_params
        params.require(:reading_history).permit(
          :manga_id, :mangadex_id, :title, :cover_url, :genre,
          :chapter_label, :mangadex_chapter_id
        )
      end
    end
  end
end
