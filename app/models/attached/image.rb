module Attached
  class Image < Attached::File
    FORMATS = %i[thumb small medium].freeze
    EXTENSIONS = %w[jpeg jpg png].freeze

    def all_formats
      FORMATS.each_with_object({}) {|key, h| h[key] = "#{url.gsub(name, '')}resized-#{key}-#{name}" }
             .merge(original: url)
    end

    FORMATS.each {|format| define_method("#{format}_format") { all_formats[format] } }
  end
end
