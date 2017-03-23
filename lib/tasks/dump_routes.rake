require "route_dumper"

desc "Dump routes"
task :dump_routes, [:filename] => [:environment] do |_, args|
  raise "Missing filename." unless args[:filename]
  RouteDumper.new(args[:filename]).dump
end
