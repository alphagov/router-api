require "route_dumper"

namespace :routes do
  desc "Dump routes"
  task :dump, [:filename] => [:environment] do |_, args|
    raise "Missing filename." unless args[:filename]

    RouteDumper.new(args[:filename]).dump
  end
end
