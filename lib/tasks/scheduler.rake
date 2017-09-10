desc 'This task is called by the Heroku scheduler add-on'
task aggregate: :environment do
  puts 'Janken aggregation'
  Janken.aggregate
  puts 'done'
end
