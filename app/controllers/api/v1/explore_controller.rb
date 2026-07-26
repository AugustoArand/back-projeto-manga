module Api
  module V1
    class ExploreController < BaseController
      before_action :authenticate_user!, only: :index

      def index
        @popular = MangadexService.popular(limit: 10)
        @latest  = MangadexService.latest_chapters(limit: 15)
        @categories = MangadexService.genre_tags
        @history = current_user.reading_histories.recent
        @favorites = current_user.favorites.recent
        @recommendations = MangadexService.recommendations(limit: 10)
      end

      def category
        @tag_name = params[:name] || "Categoria"
        @mangas   = MangadexService.by_tag(params[:tag_id], limit: 24)
      end
    end
  end
end
