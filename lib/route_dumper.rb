require "csv"
require "zlib"

class RouteDumper
  FIELDS = %w(incoming_path handler backend_id disabled redirect_to).freeze

  def initialize(filename)
    @filename = filename
  end

  def dump
    Zlib::GzipWriter.open(filename) do |file|
      csv = CSV.new(file)
      csv << FIELDS + %w[updated_at]
      routes.each do |route|
        csv << FIELDS.map { |field| route.send(field) } + [Time.now.utc]
      end
    end
  end

private

  attr_reader :filename

  def routes
    Route.all
  end
end
