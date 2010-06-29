task :default => :package

desc "Build the simulator and device libs for the phone"
task :build do
  sh "scripts/build"
end

desc "Package the lib into a framework"
task :package => :build do
  sh "scripts/package"
end