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
    events.each do |event|
      event_handler(event)
    end
    render text: 'OK'
  end

  private
  def set_client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def event_handler(event)
    case event.type
    when Line::Bot::Event::MessageType::Text
      reply_to_message(event)
    when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
      reply_to_image(event)
    end

  end

  # テキストメッセージに反応
  def reply_to_message(event)
    msg = event.message['text']
    Rails.logger.info(msg)
    if msg == 'クイズ'
      message = {
          type: 'template',
          altText: '漢字のクイズ',
          template: {
              type: 'buttons',
              title: 'Menu',
              text: 'Please select',
              actions: [
                  {
                      type: 'postback',
                      label: 'Buy',
                      data: 'action=buy&itemid=123'
                  },
                  {
                      type: 'postback',
                      label: 'Add to cart',
                      data: 'action=add&itemid=123'
                  },
                  {
                      type: 'uri',
                      label: 'View detail',
                      uri: 'http://example.com/page/123'
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

  def reply_to_image(event)
    Rails.logger.info('image')
    message = {
        type: 'text',
        text: '画像っすね'
    }
    @client.reply_message(event['replyToken'], message)
  end

end
