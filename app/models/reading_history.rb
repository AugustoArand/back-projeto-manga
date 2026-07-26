class ReadingHistory < ApplicationRecord
  belongs_to :manga,   optional: true
  belongs_to :user,    optional: true
  belongs_to :chapter, optional: true

  validates :title, presence: true

  scope :recent, -> { order(updated_at: :desc).limit(20) }
  scope :unique_titles, -> { select("DISTINCT ON (COALESCE(mangadex_id, CAST(manga_id AS TEXT))) *").order("COALESCE(mangadex_id, CAST(manga_id AS TEXT)), updated_at DESC") }

  # Registrar o último capítulo lido de um mangá (local ou da API) por um
  # usuário. Uma linha por (usuário, mangá) — ler um capítulo novo do mesmo
  # mangá atualiza a mesma linha em vez de criar histórico duplicado.
  def self.track(attrs, user:)
    scope = user.reading_histories
    record = if attrs[:mangadex_id].present?
               scope.find_or_initialize_by(mangadex_id: attrs[:mangadex_id])
             elsif attrs[:manga_id].present?
               scope.find_or_initialize_by(manga_id: attrs[:manga_id])
             else
               scope.new
             end

    record.assign_attributes(attrs)
    record.save!
    record
  end

  # Gêneros mais consumidos pelo usuário
  def self.top_genres(limit = 5)
    where.not(genre: [nil, ""])
         .group(:genre)
         .order("count_all DESC")
         .limit(limit)
         .count
         .keys
  end
end
