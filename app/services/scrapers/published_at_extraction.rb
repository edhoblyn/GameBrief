module Scrapers
  module PublishedAtExtraction
    DATE_KEYS = %w[
      datePublished
      dateCreated
      dateModified
      publishDate
      publishedAt
      published_at
      releaseDate
      published
      createdAt
      created_at
      updatedAt
      updated_at
    ].freeze

    private

    def extract_published_at(doc)
      extract_published_at_from_meta(doc) ||
        extract_published_at_from_json_ld(doc)
    end

    def extract_published_at_from_meta(doc)
      selectors = [
        "meta[property='article:published_time']",
        "meta[property='og:published_time']",
        "meta[name='article:published_time']",
        "meta[name='publish_date']",
        "meta[name='publish-date']",
        "meta[name='pubdate']",
        "meta[itemprop='datePublished']",
        "time[datetime]",
        "[itemprop='datePublished']"
      ]

      selectors.each do |selector|
        doc.css(selector).each do |node|
          value = node&.[]("content") || node&.[]("datetime") || node&.text
          published_at = parse_published_at(value)
          return published_at if published_at
        end
      end

      nil
    end

    def extract_published_at_from_json_ld(doc)
      doc.css("script[type='application/ld+json']").each do |script|
        payload = JSON.parse(script.text)
        published_at = extract_published_at_from_object(payload)
        return published_at if published_at
      rescue JSON::ParserError
        next
      end

      nil
    end

    def extract_published_at_from_object(object)
      case object
      when Array
        object.each do |entry|
          published_at = extract_published_at_from_object(entry)
          return published_at if published_at
        end
      when Hash
        DATE_KEYS.each do |key|
          published_at = parse_published_at(object[key])
          return published_at if published_at
        end

        object.each_value do |value|
          published_at = extract_published_at_from_object(value)
          return published_at if published_at
        end
      end

      nil
    end

    def parse_published_at(value)
      return if value.blank?

      Time.zone.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
