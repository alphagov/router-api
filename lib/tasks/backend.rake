namespace :backend do
  desc "Adds a subdomain to all backends"
  task add_subdomains: :environment do
    subdomain_mappings = {
      "content-store" => "content-store",
      "calculators" => "calculators",
      "email-alert-frontend" => "email-alert-frontend",
      "manuals-frontend" => "manuals-frontend",
      "info-frontend" => "info-frontend",
      "government-frontend" => "government-frontend",
      "email-campaign-frontend" => "email-campaign-frontend",
      "finder-frontend" => "finder-frontend",
      "whitehall-frontend" => "whitehall-frontend",
      "smartanswers" => "smartanswers",
      "service-manual-frontend" => "service-manual-frontend",
      "frontend" => "frontend",
      "feedback" => "feedback",
      "licensify" => "licensify",
      "canary-frontend" => "canary-frontend",
      "licencefinder" => "licencefinder",
      "collections" => "collections",
      "static" => "static",
      "contacts-frontend" => "contacts-frontend",
      "search-api" => "search-api",
    }
    subdomain_mappings.each do |backend_id, subdomain|
      backend = Backend.find_by(backend_id: backend_id)
      unless backend
        puts "couldn't find backend '#{backend_id}'"
        next
      end
      puts "Changing #{backend_id} subdomain from '#{backend.subdomain_name}' to '#{subdomain}'"
      backend.subdomain_name = subdomain
      backend.save!
    end

    puts "Reloading router"
    RouterReloader.reload
  end

  desc "Updates backend_url for a given backend"
  task :modify_url, %i[backend_id backend_url] => [:environment] do |_t, args|
    unless args[:backend_id] && args[:backend_url]
      raise "Requires backend_id and backend_url to be passed as parameters"
    end

    backend_id = args[:backend_id]
    backend_url = args[:backend_url]

    backend = Backend.where(backend_id: backend_id).first
    old_url = backend.backend_url
    backend.backend_url = backend_url

    puts "Changing #{backend_id} from #{old_url} to #{backend_url}"

    backend.save!

    puts "Reloading router"

    RouterReloader.reload
  end

  desc "Updates backend_url for all backends using search and replace"
  task :bulk_update_url, %i[search_string replace_string] => [:environment] do |_t, args|
    unless args[:search_string] && args[:replace_string]
      raise "Requires search_string and replace_string to be passed as parameters"
    end

    search_string = args[:search_string]
    replace_string = args[:replace_string]

    Backend.all.each do |backend|
      old_url = backend.backend_url
      new_url = old_url.gsub(search_string, replace_string)

      next unless old_url != new_url

      puts "Changing #{backend.backend_id} from #{old_url} to #{new_url}"
      backend.backend_url = new_url
      backend.save!
    end

    puts "Reloading router"

    RouterReloader.reload
  end
end
