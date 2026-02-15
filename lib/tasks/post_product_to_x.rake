namespace :product do
  desc 'Post a random product to X with AI-generated recommendation'
  task post_product_to_x: :environment do
    product = Product.includes(knowledge: %i[brand item line]).order('RAND()').first

    unless product
      puts '[X Bot] No product found.'
      next
    end

    knowledge = product.knowledge
    brand = knowledge.brand
    item = knowledge.item
    line = knowledge.line

    include ActionView::Helpers::NumberHelper
    price = "#{number_with_delimiter(product.price)}円"

    product_info = <<~INFO
      ブランド: #{brand.name}
      アイテム: #{item.name}
      ライン: #{line.name}
      モデル名: #{knowledge.name}
      年代: #{knowledge.age}年
      価格: #{price}
      トピック: #{knowledge.topic_sentence}
      概要: #{knowledge.summary}
    INFO

    post_text = generate_post_text(product_info, price, product.url)

    unless post_text
      puts '[X Bot] AI生成に失敗したため投稿をスキップします。'
      next
    end

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
      puts "[X Bot] 投稿内容:\n#{post_text}"
    rescue StandardError => e
      puts "[X Bot] 投稿失敗: #{e.message}"
    end
  end

  def generate_post_text(product_info, price, url)
    client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GEMINI_API_KEY']
      },
      options: { model: 'gemini-2.5-flash', server_sent_events: true }
    )

    prompt = <<~PROMPT
      あなたはヴィンテージ古着の専門バイヤーです。
      以下の商品情報をもとに、Xへの投稿文を作成してください。

      【ルール】
      - 商品の魅力やストーリーを伝え、購買意欲を刺激する文章にする
      - 年代やモデルの希少性、歴史的価値に触れる
      - 感情に訴えかける表現を使う（「今しか手に入らない」「一期一会」など）
      - 文章の最後に必ず以下の2行を改行して入れる:
        #{price}
        #{url}
      - ハッシュタグは文章の末尾に3〜5個つける
      - ハッシュタグはクリックされやすいものを選ぶ（例: #古着好きと繋がりたい #ヴィンテージ古着 #古着コーデ #古着男子 #古着女子 など、トレンド性のあるもの）
      - ブランド名やモデル名のハッシュタグも含める
      - 投稿全体（文章+価格+URL+ハッシュタグ）を280文字以内に収める
      - 絵文字は使わない
      - 装飾記号（【】や■など）は最小限にする
      - 出力は投稿文のみ。説明や前置きは不要

      【商品情報】
      #{product_info}
    PROMPT

    result = client.stream_generate_content(
      { contents: { role: 'user', parts: { text: prompt } } }
    )

    result.map { |r| r.dig('candidates', 0, 'content', 'parts', 0, 'text') }.join
  rescue StandardError => e
    puts "[X Bot] AI生成失敗: #{e.message}"
    nil
  end
end
