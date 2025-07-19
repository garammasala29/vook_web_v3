namespace :product do
  desc 'Post a random product to X'
  task post_product_to_x: :environment do
    random_id = Product.pluck(:id).sample
    product = Product.includes(knowledge: :brand).find_by(id: random_id)

    unless product
      puts '[X Bot] No product found.'
      next
    end

    brand = product.knowledge.brand
    knowledge = product.knowledge
    include ActionView::Helpers::NumberHelper
    price = "#{number_with_delimiter(product.price)}円"

    hashtags = [
      format_hashtag(brand.name),
      format_hashtag("#{brand.name}#{knowledge.name}"),
      'ヴィンテージ',
      '古着'
    ].map { |tag| "##{tag}" }.join(' ')

    post_text = <<~POST
      【商品紹介】
      #{product.name}

      価格：#{price}
      商品ページ：#{product.url}

      #{hashtags}
    POST

    begin
      x_credentials = {
        api_key: ENV['X_API_KEY'],
        api_key_secret: ENV['X_API_KEY_SECRET'],
        access_token: ENV['X_ACCESS_TOKEN'],
        access_token_secret: ENV['X_ACCESS_TOKEN_SECRET']
      }
      x_client = X::Client.new(**x_credentials)

      x_client.post('tweets', { text: post_text }.to_json)
      puts "[X Bot] 投稿完了: #{product.name}"
    rescue StandardError => e
      puts "[X Bot] 投稿失敗: #{e.message}"
    end
  end

  def format_hashtag(text)
    text.to_s.tr("’'", '').gsub(/\s+/, '')
  end
end
