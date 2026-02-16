POST_TONE_VARIATIONS = [
  'バイヤー目線で「自分ならこう着る」「こういう人に刺さる」という提案を交えて書いてください。',
  '鑑定士のように、このモデル特有のディテールや見分けポイントを語りつつ魅力を伝えてください。',
  '古着市場の相場観を踏まえて、この価格がいかにお得か、あるいは妥当かをプロの視点で伝えてください。',
  'このアイテムが生まれた時代背景やカルチャーとの関係を短く語り、歴史的な文脈で魅力を伝えてください。',
  '「なぜ今このモデルが再評価されているのか」というトレンドの文脈で、プロの知見を交えて書いてください。'
].freeze

# XではURLが自動的にt.co短縮（23文字）されるため、実際の文字数を計算する
X_URL_LENGTH = 23

namespace :product do
  desc 'Post a random product to X with AI-generated recommendation'
  task post_product_to_x: :environment do
    log = ->(msg) { puts "[X Bot] [#{Time.current.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}" }

    posted_ids = Rails.cache.fetch('x_bot:posted_product_ids') { [] }
    product = Product.includes(knowledge: %i[brand item line]).where.not(id: posted_ids).order('RAND()').first
    product ||= Product.includes(knowledge: %i[brand item line]).order('RAND()').first

    unless product
      log.call('No product found.')
      next
    end

    posted_ids = (posted_ids + [product.id]).last(50)
    Rails.cache.write('x_bot:posted_product_ids', posted_ids)

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

    x_char_count = post_text.gsub(%r{https?://\S+}, 'x' * X_URL_LENGTH).length
    if x_char_count > 280
      log.call("文字数オーバー(X換算#{x_char_count}文字)のため投稿をスキップします。")
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
    rescue X::Forbidden => e
      log.call("投稿拒否(Forbidden): #{e.message}")
      log.call("投稿しようとした内容(X換算#{x_char_count}文字):\n#{post_text}")
    rescue StandardError => e
      log.call("投稿失敗: #{e.class} #{e.message}")
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
      あなたはヴィンテージ古着歴20年の専門バイヤーです。
      何千着もの古着を見てきた経験と知識に基づき、以下の商品をXで紹介してください。

      【トーン指定】
      #{tone}

      【絶対に守るルール】
      - 商品情報に書かれた「アイテム」の種別を正確に使うこと。Denim Pantsならパンツ/デニム、Jacketならジャケットと書く。勝手にアイテム種別を変えない
      - 商品情報に書かれていない事実を創作しない。年代、ブランド、モデル名はそのまま使う
      - 以下の表現は使用禁止。必ず別の言い回しにする:
        「一期一会」「お見逃しなく」「見逃し厳禁」「希少な逸品」「奇跡の入荷」「歴史を纏う」

      【文章のルール】
      - プロのバイヤーとしての知見・経験が感じられる文章にする
      - 具体的なディテール（生地、シルエット、年代の特徴など）に触れる
      - 文章の最後に必ず以下の2行を改行して入れる:
        #{price}
        #{url}

      【ハッシュタグのルール】
      - ハッシュタグは文章の末尾に3〜5個つける
      - 数字だけのハッシュタグは禁止（例: #559 はNG。#Levis559 のようにブランド名と組み合わせる）
      - ハッシュタグはクリックされやすいものを選ぶ（例: #古着好きと繋がりたい #ヴィンテージ古着 #古着コーデ #古着男子 #古着女子 など）
      - ブランド名やモデル名のハッシュタグも含める

      【フォーマットのルール】
      - URLはXで23文字に短縮される。文章+価格+23文字+ハッシュタグの合計が280文字以内になるようにする
      - 文章部分は100文字以内を目安にする
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
