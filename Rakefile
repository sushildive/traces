require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ["lib", "app"]
  t.warning = true
  t.verbose = true
  t.test_files = FileList['test/unit/**/*_test.rb']
end
