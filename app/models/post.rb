class Post < ApplicationRecord
    has_one_attached :image

    attr_accessor :remote_image_url

    # Discogsの主要ジャンルを定義
    GENRES = ["Rock", "Electronic", "Hip Hop", "Jazz", "Funk / Soul", "Classical", "Reggae", "Latin", "Pop"].freeze

    validates :title, presence: true
    validates :artist, presence: true
    validates :genre, inclusion: { in: GENRES, allow_blank: true } # 定義外の入力を防ぐ
    validates :release_year, numericality: { only_integer: true, allow_nil: true }
end
