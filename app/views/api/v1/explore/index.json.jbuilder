json.popular @popular do |manga|
  json.id          manga[:id]
  json.title       manga[:title]
  json.cover_url   manga[:cover_url]
  json.status      manga[:status]
  json.tags        manga[:tags]
  json.author      manga[:author]
  json.description manga[:description]
end

json.latest @latest do |ch|
  json.id          ch[:id]
  json.chapter     ch[:chapter]
  json.title       ch[:title]
  json.published_at ch[:published_at]
  json.manga_id    ch[:manga_id]
  json.manga_title ch[:manga_title]
  json.cover_url   ch[:cover_url]
  json.pages       ch[:pages]
end

json.categories @categories do |tag|
  json.id   tag[:id]
  json.name tag[:name]
end

json.history @history do |h|
  json.id                  h.id
  json.title               h.title
  json.cover_url           h.cover_url
  json.genre               h.genre
  json.manga_id            h.manga_id
  json.mangadex_id         h.mangadex_id
  json.chapter_label       h.chapter_label
  json.mangadex_chapter_id h.mangadex_chapter_id
  json.updated_at          h.updated_at
end

json.favorites @favorites do |f|
  json.id          f.id
  json.title       f.title
  json.cover_url   f.cover_url
  json.genre       f.genre
  json.manga_id    f.manga_id
  json.mangadex_id f.mangadex_id
end

json.recommendations @recommendations do |manga|
  json.id        manga[:id]
  json.title     manga[:title]
  json.cover_url manga[:cover_url]
  json.status    manga[:status]
  json.tags      manga[:tags]
end
