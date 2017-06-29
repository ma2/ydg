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
    if msg == 'クイズ'
      message = {
        type: 'template',
        altText: '漢字のクイズ',
        template: {
          type: 'buttons',
          title: '匕首',
          text: 'なんて読むかな？',
          actions: [
            {
              type: 'postback',
              label: 'いくび',
              data: 'q=1&choice=1'
            },
            {
              type: 'postback',
              label: 'あいくち',
              data: 'q=1&choice=2'
            },
            {
              type: 'postback',
              label: 'おしゅ',
              data: 'q=1&choice=3'
            }
          ]
        }
      }
    else
      # オウム返し
      message = {
        type: 'text',
        text: event.message['text']
      }
    end
    @client.reply_message(event['replyToken'], message)
  end

  # ポストバック（ユーザの選択）に返事
  def reply_to_postback(event, user)
    message = {
      type: 'text',
      text: "そうかもねー、#{user.name}さん"
    }
    @client.reply_message(event['replyToken'], message)
  end

  def reply_to_image(event, user)
    message = {
      type: 'text',
      text: '画像だよねー'
    }
    @client.reply_message(event['replyToken'], message)
  end

  # ユーザの管理
  def user_handler(event)
    userid = event['source']['userId']
    # すでに登録済みユーザか？
    user = User.find_or_create_by(userid: userid) do |u|
      # 新規ユーザならプロファイルを取得
      response = @client.get_profile(userid)
      case response
      when Net::HTTPSuccess then
        contact = JSON.parse(response.body)
        p contact['displayName']
        p contact['pictureUrl']
        p contact['statusMessage']
        u.name = contact['displayName']
      end
    end
    user
  end

end
