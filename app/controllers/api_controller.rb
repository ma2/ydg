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
    if msg =~ /謎|なぞ/
      message = {
        type: 'template',
        altText: 'なぞなぞ開始',
        template: {
          thumbnailImageUrl: helpers.image_url('majomina.png'),
          type: 'buttons',
          title: '部屋の中になんかあるよ',
          text: '見てみる？',
          actions: [
            {
              type: 'postback',
              label: '見てみる',
              data: 'event=start'
            },
          ]
        }
      }
    elsif msg =~ /だれ|誰/
      message = {
        type: 'text',
        text: 'わたしマジョミナ！ 魔女の見習い、人呼んで「見習い魔女」！ よろしくね！'
      }
    else
      # オウム返し
      message = {
        type: 'text',
        text: "#{user.name}さん、「#{event.message['text']}」っていいました？"
      }
    end
    @client.reply_message(event['replyToken'], message)
  end

  # ポストバック（ユーザの選択）に返事
  def reply_to_postback(event, user)
    p, choice = event['postback']['data'].split('=')
    img1 = helpers.image_url('majomina.png')
    img2 = helpers.image_url('ydg.png')
    case choice
    when 'start'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: 'カレンダーと机だね',
          text: '興味ある？ 私はないな',
          actions: [
            {
              type: 'postback',
              label: 'カレンダーをチェック！',
              data: 'event=look_calendar'
            },
            {
              type: 'postback',
              label: '机ってどんな？',
              data: 'event=look_desk'
            },
          ]
        }
      }
    when 'look_calendar'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: 'あ、カレンダーに印があるよ',
          text: '9月16日、池袋コミュニティカレッジで何かが起きる！ だって、だって！',
          actions: [
            {
              type: 'postback',
              label: 'なんだってー',
              data: 'event=look_desk'
            },
            {
              type: 'postback',
              label: '待って待って。机は？',
              data: 'event=look_desk'
            },
          ]
        }
      }
    when 'look_desk'
      message = {
        type: 'template',
        altText: 'なぞなぞ',
        template: {
          thumbnailImageUrl: img1,
          type: 'buttons',
          title: 'あ、机に落書きがあるよ',
          text: '米光講座脱出ゲーム始まる！ だって、だって！',
          actions: [
            {
              type: 'postback',
              label: 'なんだってー',
              data: 'event=end'
            },
            {
              type: 'postback',
              label: 'なんですとー',
              data: 'event=end'
            },
          ]
        }
      }
    when 'end'
      message = {
        type: 'text',
        text: '9月16日 15:30から、池袋コミュニティカレッジ8Fで、米光講座脱出ゲーム開催。みんな来てね！ マジョミナのお知らせでした。'
      }
    end
    @client.reply_message(event['replyToken'], message)
  end

  def reply_to_image(event, user)
    message = {
      type: 'text',
      text: "#{user.name}さんらしい画像だよねー"
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
