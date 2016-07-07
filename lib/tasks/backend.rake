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
end
