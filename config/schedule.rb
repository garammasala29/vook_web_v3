env :PATH, ENV['PATH']
set :environment, 'production'
set :output, 'log/cron.log'

every 1.day, at: '1:00 am' do
  rake 'sitemap:refresh'
  rake 'analytics:fetch_page_views'
end

every 1.hour, at: 10 do
  rake 'product:post_product_to_x'
end
