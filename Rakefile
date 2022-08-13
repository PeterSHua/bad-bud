require 'rake/testtask'

ROOT = File.expand_path(__dir__)

task default: :launch

desc 'Launch on localhost'
task :launch do
  sh "bundle exec ruby #{ROOT}/bad_buds.rb"
end

desc 'Deploy to Heroku'
task 'deploy' do
  sh "git push heroku main"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
