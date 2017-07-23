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
        reply_to_postback(event, user)
      end
    end
  end

  # テキストメッセージに反応
  def reply_to_message(event, user)
    msg = event.message['text']
    if msg =~ /あれ/
      message = {
        type: 'template',
        altText: 'なぞなぞ開始',
        template: {
          thumbnailImageUrl: helpers.image_url('kensi.png'),
          type: 'buttons',
          title: 'ほんとに知らないのかよー',
          text: '爺ちゃんのそのまた爺ちゃんのときの王様がボンクラでさ、それに懲りたもんで、新しい王様はバトルで決めることになったんだよ',
          actions: [
            {
              type: 'postback',
              label: '詳しく教えて',
              data: 'event=start'
            },
          ]
        }
      }
    elsif msg =~ /だれ|誰/
      message = {
        type: 'text',
        text: "オイラはケンシだ。へえ、あんた#{user.name}って言うのか、よろしくな。あんたもあれのために来たんだろ。言わなくても分かるんだよな"
      }
    else
      # オウム返し
      message = {
        type: 'text',
        text: "#{user.name}、「#{event.message['text']}」って言った？"
      }
    end
    @client.reply_message(event['replyToken'], message)
  end

  # ポストバック（ユーザの選択）に返事
  def reply_to_postback(event, user)
    p, choice = event['postback']['data'].split('=')
    img1 = helpers.image_url('kensi.png')
    case choice
    when 'start'
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
          title: 'おいおい、冗談はよしてくれよ',
          text: "王位継承バトルって言ったら池袋コミュニティカレッジ8Fに決まってるだろ。王宮じゃなくて豊島区だからな。#{user.name}は間違えそうだから気をつけろよ",
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
          title: 'おいおい、冗談はよしてくれよ',
          text: "王位継承バトルって言ったら池袋コミュニティカレッジ8Fに決まってるだろ。王宮じゃなくて豊島区だからな。#{user.name}は間違えそうだから気をつけろよ",
          actions: [
            {
              type: 'postback',
              label: 'よし、分かった',
              data: 'event=end'
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
          title: 'かー、そんなことも知らねえのかよ',
          text: '9月16日だよ。羊皮紙にメモっておきな。15:30開始だから、少し早めに来るんだぞ。あ、オイラって親切だな。',
          actions: [
            {
              type: 'postback',
              label: 'そういうことか',
              data: 'event=end'
            },
          ]
        }
      }
    when 'end'
      message = {
        type: 'text',
        text: "9月16日 15:30から、池袋コミュニティカレッジ8Fで、リアル合戦ゲーム「王様のバトル」鐘の音が７度なると勝負の月が出る……ゴクリ、いよいよ始まるな、#{user.name}。じゃあ、当日会おうぜ！"
      }
    end
    @client.reply_message(event['replyToken'], message)
  end

  def reply_to_image(event, user)
    message = {
      type: 'text',
      text: "#{user.name}は、これが好きなのか？"
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
