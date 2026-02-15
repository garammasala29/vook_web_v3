env :PATH, ENV['PATH']
set :environment, 'production'
set :output, 'log/cron.log'

every 1.day, at: '1:00 am' do
  rake 'sitemap:refresh'
  rake 'analytics:fetch_page_views'
end

%w[7:00 8:00 12:00 12:30 18:00 19:00 21:00 22:00].each do |time|
  every 1.day, at: time do
    rake 'product:post_product_to_x'
  end
end
