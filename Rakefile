ROOT = File.expand_path(__dir__)

task default: :launch

desc 'Launch on localhost'
task :launch do
  sh "bundle exec ruby #{ROOT}/bad_buds.rb"
end

desc 'Run tests'
task :test do
  sh "bundle exec ruby #{ROOT}/test/bad_buds_test.rb"
end

desc 'Deploy to Heroku'
task 'deploy' do
  sh "git push heroku main"
end
