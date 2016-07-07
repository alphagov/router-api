namespace :backend do
  desc 'Updates backend_url for a given backend'
  task :modify_url, [:backend_id, :backend_url] => [:environment] do |_t, args|
    unless args[:backend_id] && args[:backend_url]
      raise 'Requires backend_id and backend_url to be passed as parameters'
    end

    backend_id = args[:backend_id]
    backend_url = args[:backend_url]

    backend = Backend.where(backend_id: backend_id).first
    old_url = backend.backend_url
    backend.backend_url = backend_url

    puts "Changing #{backend_id} from #{old_url} to #{backend_url}"

    backend.save!

    puts 'Reloading router'

    RouterReloader.reload
  end

  desc 'Updates backend_url for all backends using search and replace'
  task :bulk_update_url, [:search_string, :replace_string] => [:environment] do |_t, args|
    unless args[:search_string] && args[:replace_string]
      raise 'Requires search_string and replace_string to be passed as parameters'
    end

    search_string = args[:search_string]
    replace_string = args[:replace_string]

    Backend.all.each do |backend|
      old_url = backend.backend_url
      new_url = old_url.gsub(search_string, replace_string)

      if old_url != new_url
        puts "Changing #{backend.backend_id} from #{old_url} to #{new_url}"
        backend.backend_url = new_url
        backend.save!
      end
    end

    puts 'Reloading router'

    RouterReloader.reload
  end
end
