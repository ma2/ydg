require 'time_util'
include TimeUtil

class ApiController < ApplicationController
  force_ssl
  protect_from_forgery except: [:callback]
  before_action :set_client

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless @client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = @client.parse_events_from(body)
    event_handler(events)
    render text: 'OK'
  end

  private
  def set_client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def event_handler(events)
    events.each do |event|
      user = user_handler(event)
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          reply_to_message(event, user)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          reply_to_image(event, user)
        end
      when Line::Bot::Event::Postback
        reply_to_postbacks(event, user)
      end
    end
  end

  # テキストメッセージに反応
  # やりとり開始
  # 告知、じゃんけん、じゃんけん結果
  def reply_to_message(event, user)
    msg = event.message['text']
    if msg == 'ケンシリセット'
      user.update(q1: 0)
      message = {
        type: 'text',
        text: "#{user.name}のq1を#{user.q1}にリセットしたぜ"
      }
    elsif user.q1 == 0
      message = {
        type: 'template',
        altText: 'お知らせスタート前',
        template: {
          thumbnailImageUrl: helpers.image_url('kensi.png'),
          type: 'buttons',
          title: 'オイラはケンシだ',
          text: "へえ、あんた#{user.name}って言うのか、よろしくな。あんたもあれのために来たんだろ。言わなくても分かるんだよな",
          actions: [
            {
              type: 'postback',
              label: 'あれって？',
              data: 'event=start0'
            },
          ]
        }
      }
    # elsif user.q2 == 0 && janken_time?
    #   message = {
    #     type: 'template',
    #     altText: 'じゃんけんスタート前',
    #     template: {
    #       thumbnailImageUrl: helpers.image_url('kensi.png'),
    #       type: 'buttons',
    #       title: 'ちょきじゃんけんはじまるよ',
    #       text: 'あいこだったらちょきの勝ち、ってルールだよ。やるかい？',
    #       actions: [
    #         {
    #           type: 'postback',
    #           label: 'やる！',
    #           data: 'event=janken0'
    #         },
    #       ]
    #     }
    #   }
    # elsif user.q2 != 0 && janken_result_time?
    #   # じゃんけん結果発表
    else
      # 次のじゃんけんまで待ってもらう
    end
    @client.reply_message(event['replyToken'], message)
  end

  # ポストバックをじゃんけんと告知に分けて処理
  def reply_to_postbacks(event, user)
    _, choice = event['postback']['data'].split('=')
    reply_to_announce(event, user) unless choice.start_with?('janken')
    reply_to_janken(event, user) if choice.start_with?('janken')
  end

  # ポストバック（ユーザの選択）に返事
  # じゃんけん
  def reply_to_janken(event, user)
    _, choice = event['postback']['data'].split('=')
    case choice
    when 'janken0'
      message = {
        type: 'template',
        altText: 'じゃんけんスタート',
        template: {
          thumbnailImageUrl: helpers.image_url('kensi.png'),
          type: 'buttons',
          title: '手を選んでくれよ',
          text: 'あいこだったらちょきの勝ちだぞ。ちょきじゃんけん、じゃんけんぽん！',
          actions: [
            {
              type: 'postback',
              label: 'ぐー',
              data: 'event=janken_goo'
            },
            {
              type: 'postback',
              label: 'ちょき',
              data: 'event=janken_choki'
            },
            {
              type: 'postback',
              label: 'ぱー',
              data: 'event=janken_paa'
            },
          ]
        }
      }
    when /janken_(.*)/
      gcp = %w(goo choki paa).index($1)
      user.update(q2: gcp+1)
      message = {
        type: 'text',
        text: "結果は#{next_result_time}に発表するから、その頃にまた話しかけてくれよな"
      }
    else

    end
    @client.reply_message(event['replyToken'], message)
  end

  # ポストバック（ユーザの選択）に返事
  # 告知
  def reply_to_announce(event, user)
    p, choice = event['postback']['data'].split('=')
    img1 = helpers.image_url('kensi.png')
    img2 = helpers.image_url('kokuchi2.png')
    case choice
    when 'start0'
      message = {
        type: 'template',
        altText: 'お知らせスタート',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: 'ほんとに知らないのかよー',
          text: '爺ちゃんのそのまた爺ちゃんのときの王様がボンクラでさ、それに懲りて、新しい王様はバトルで決めてるんだよ',
          actions: [
            {
              type: 'postback',
              label: '詳しく教えて',
              data: 'event=start1'
            },
          ]
        }
      }
    when 'start1'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: '場所と時間さえ守れば誰でも参加できるんだ。すごいだろ',
          text: "#{user.name}もやるだろ？ オイラはもちろん参加だ。これでオイラも王様だ！",
          actions: [
            {
              type: 'postback',
              label: 'いつやるの',
              data: 'event=wwhen_owhere'
            },
            {
              type: 'postback',
              label: 'どこでやるの',
              data: 'event=owhen_wwhere'
            },
          ]
        }
      }
    when 'wwhen_owhere'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: 'かー、そんなことも知らねえのかよ',
          text: '9月16日だよ。羊皮紙にメモっておきな。15:30開始だから、少し早めに来るんだぞ。あ、オイラって親切だな。',
          actions: [
            {
              type: 'postback',
              label: '場所を聞いてなかったよ',
              data: 'event=xwhen_wwhere'
            },
          ]
        }
      }
    when 'owhen_wwhere'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: '王位継承バトルって言ったらさ',
          text: "池袋コミュニティカレッジ8Fに決まってるだろ。王宮じゃなくて豊島区だからな、間違えるなよ",
          actions: [
            {
              type: 'postback',
              label: 'いつやるんだっけ',
              data: 'event=wwhen_xwhere'
            },
          ]
        }
      }
    when 'xwhen_wwhere'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: "まさか#{user.name}って方向音痴か？",
          text: '王位継承バトルは池袋コミュニティカレッジ8Fでやるんだけど、ちゃんと来れるか？',
          actions: [
            {
              type: 'postback',
              label: '大丈夫、だいじょうぶ',
              data: 'event=announce'
            },
          ]
        }
      }
    when 'wwhen_xwhere'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: '9月16日だよ',
          text: 'そんなことも知らずにここに来たのか。いますぐ羊皮紙にメモだ。17:00開始だから、馬で来る方がいいな。',
          actions: [
            {
              type: 'postback',
              label: 'そういうことか',
              data: 'event=announce'
            },
          ]
        }
      }
    when 'announce'
      message = {
        type: 'template',
        altText: '告知',
        template: {
          thumbnailImageUrl: img2,
          type: 'buttons',
          title: "#{user.name}、9月16日に会おう",
          text: 'まあ、オイラは負けないけどな',
          actions: [
            {
              type: 'postback',
              label: '楽しみにしてるよ',
              data: 'event=end'
            },
          ]
        }
      }
    when 'end'
      message = {
        type: 'text',
        text: "9月16日17:00、池袋コミュニティカレッジ8Fだ。#{user.name}と会えるのが楽しみだぜ"
      }
    end
    # 告知済みフラグを設定
    user.update(q1: 1)
    @client.reply_message(event['replyToken'], message)
  end

  def reply_to_image(event, user)
    message = {
      type: 'text',
      text: "#{user.name}は、それが好きなのか？"
    }
    @client.reply_message(event['replyToken'], message)
  end

  # userIdからユーザを取得する
  # 新規ユーザならDBに登録する
  def user_handler(event)
    userid = event['source']['userId']
    # すでに登録済みユーザか？
    user = User.find_or_create_by(userid: userid) do |u|
      # 新規ユーザならプロファイルを取得
      response = @client.get_profile(userid)
      case response
      when Net::HTTPSuccess then
        contact = JSON.parse(response.body)
        u.name = contact['displayName']
      end
    end
    user
  end

end
