module Api
  module V1
    # Proxy endpoints for MangaDex content (manga detail + chapter reading).
    # `manga`/`search` stay open (pure catalog browsing). `chapter` actually
    # delivers reading content, so it requires a logged-in user with an
    # active trial or VIP subscription.
    class MdexController < BaseController
      before_action :authenticate_user!, :require_active_access!, only: :chapter

      # GET /api/v1/mdex/manga/:id
      # Returns manga detail + full chapter list from MangaDex (in the given
      # language). The client is responsible for paginating the display.
      def manga
        manga = MangadexService.manga_detail(params[:id])
        return render json: { error: "Manga not found" }, status: :not_found unless manga

        lang     = params.fetch(:lang, "pt-br")
        chapters = MangadexService.manga_chapters(params[:id], lang: lang)

        render json: {
          id:           manga[:id],
          title:        manga[:title],
          description:  manga[:description],
          status:       manga[:status],
          year:         manga[:year],
          author:       manga[:author],
          cover_url:    manga[:cover_url],
          tags:         manga[:tags],
          last_chapter: manga[:last_chapter],
          chapters:     chapters.map { |ch|
            {
              id:        ch[:id],
              chapter:   ch[:chapter],
              title:     ch[:title],
              volume:    ch[:volume],
              pages:     ch[:pages],
              published: ch[:published],
              lang:      ch[:lang],
              group:     ch[:group]
            }
          }
        }
      end

      # GET /api/v1/mdex/search?query=...
      def search
        query   = params[:query].to_s.strip
        results = MangadexService.search(query)
        render json: { mangas: results }
      end

      # GET /api/v1/mdex/chapter/:id
      # Returns ordered page image URLs for a MangaDex chapter.
      # Accepts ?data_saver=true for compressed images and ?refresh=true to
      # bypass the cache and request a fresh MD@Home node assignment.
      def chapter
        data_saver = params[:data_saver] == "true"
        refresh    = params[:refresh] == "true"
        result     = MangadexService.chapter_pages(params[:id], data_saver: data_saver, refresh: refresh)

        return render json: { error: "Chapter not found" }, status: :not_found unless result

        render json: {
          chapter_id: result[:chapter_id],
          pages:      result[:pages]
        }
      end
    end
  end
end
