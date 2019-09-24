class MakeBackendsHttps < Mongoid::Migration
  def self.up
    Backend.all.each do |backend|
      uri = URI.parse(backend.backend_url)

      if uri.scheme == "http"
        uri.scheme = "https"
        backend.backend_url = uri.to_s
        backend.save!
      end
    end
  end

  def self.down
  end
end
