module Api
  module V1
    class FavoritesController < BaseController
      before_action :authenticate_user!

      def index
        render json: current_user.favorites.recent.map { |f| favorite_json(f) }
      end

      def create
        favorite = current_user.favorites.find_or_initialize_by(
          favorite_params.slice(:manga_id, :mangadex_id).compact
        )
        favorite.assign_attributes(favorite_params)
        favorite.save!
        render json: favorite_json(favorite), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def destroy
        favorite = current_user.favorites.find(params[:id])
        favorite.destroy
        head :no_content
      end

      private

      def favorite_params
        params.require(:favorite).permit(:manga_id, :mangadex_id, :title, :cover_url, :genre)
      end

      def favorite_json(favorite)
        {
          id: favorite.id,
          title: favorite.title,
          cover_url: favorite.cover_url,
          genre: favorite.genre,
          manga_id: favorite.manga_id,
          mangadex_id: favorite.mangadex_id,
          created_at: favorite.created_at
        }
      end
    end
  end
end
