class Tweet < ApplicationRecord
  def self.sync(query)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.consumer_key
      config.consumer_secret     = Rails.application.secrets.consumer_secret
      config.access_token        = Rails.application.secrets.access_token
      config.access_token_secret = Rails.application.secrets.access_token_secret
    end
    client.search(query).each do |tweet|
      create(body: tweet.text)
    end
  end

  before_save :set_sentiment, if: :body_changed?

  scope :positive, ->{ where(sentiment: :positive) }
  scope :neutral, ->{ where(sentiment: :neutral) }
  scope :negative, ->{ where(sentiment: :negative) }

  def set_sentiment
    self.sentiment = $analyzer.sentiment(body)
    self.score = $analyzer.score(body)
  end
end
