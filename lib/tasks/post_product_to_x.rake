POST_TONE_VARIATIONS = [
  '語りかけるような親しみやすいトーンで書いてください。友達に「これ見て！」と勧める感じで。',
  '淡々としたクールなトーンで書いてください。事実と数字で魅力を伝える硬派なスタイルで。',
  '情熱的な古着バイヤーのトーンで書いてください。商品への愛が伝わる熱い文章で。',
  'ストーリーテリング風に書いてください。この服が歩んできた歴史や時代背景を短く語る形で。',
  '問いかけ形式で書いてください。「〜を知っていますか？」「〜を探していませんか？」のように読者に語りかける形で。'
].freeze

namespace :product do
  desc 'Post a random product to X with AI-generated recommendation'
  task post_product_to_x: :environment do
    log = ->(msg) { puts "[X Bot] [#{Time.current.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}" }

    product = Product.includes(knowledge: %i[brand item line]).order('RAND()').first

    unless product
      log.call('No product found.')
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
      log.call('AI生成に失敗したため投稿をスキップします。')
      next
    end

    if post_text.length > 280
      log.call("文字数オーバー(#{post_text.length}文字)のため投稿をスキップします。")
      log.call("生成内容:\n#{post_text}")
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
      log.call("投稿完了: #{product.name}")
      log.call("投稿内容:\n#{post_text}")
    rescue StandardError => e
      log.call("投稿失敗: #{e.message}")
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

    tone = POST_TONE_VARIATIONS.sample

    prompt = <<~PROMPT
      あなたはヴィンテージ古着の専門バイヤーです。
      以下の商品情報をもとに、Xへの投稿文を作成してください。

      【トーン指定】
      #{tone}

      【絶対に守るルール】
      - 商品情報に書かれた「アイテム」の種別を正確に使うこと。Denim Pantsならパンツ/デニム、Jacketならジャケットと書く。勝手にアイテム種別を変えない
      - 商品情報に書かれていない事実を創作しない。年代、ブランド、モデル名はそのまま使う
      - 以下の表現は使用禁止。必ず別の言い回しにする:
        「一期一会」「お見逃しなく」「見逃し厳禁」「希少な逸品」「奇跡の入荷」

      【文章のルール】
      - 商品の魅力やストーリーを伝え、購買意欲を刺激する文章にする
      - 年代やモデルの特徴、歴史的価値に触れる
      - 文章の最後に必ず以下の2行を改行して入れる:
        #{price}
        #{url}

      【ハッシュタグのルール】
      - ハッシュタグは文章の末尾に3〜5個つける
      - 数字だけのハッシュタグは禁止（例: #559 はNG。#Levis559 のようにブランド名と組み合わせる）
      - ハッシュタグはクリックされやすいものを選ぶ（例: #古着好きと繋がりたい #ヴィンテージ古着 #古着コーデ #古着男子 #古着女子 など）
      - ブランド名やモデル名のハッシュタグも含める

      【フォーマットのルール】
      - 投稿全体（文章+価格+URL+ハッシュタグ）を280文字以内に厳守する。URLは長いので文章は短めにする
      - 絵文字は使わない
      - 装飾記号（【】や■など）は最小限にする
      - 出力は投稿文のみ。説明や前置きは不要

      【商品情報】
      #{product_info}
    PROMPT

    result = client.stream_generate_content(
      { contents: { role: 'user', parts: { text: prompt } } }
    )

    result.map { |r| r.dig('candidates', 0, 'content', 'parts', 0, 'text') }.join.strip
  rescue StandardError => e
    Rails.logger.error("[X Bot] AI生成失敗: #{e.message}")
    nil
  end
end
