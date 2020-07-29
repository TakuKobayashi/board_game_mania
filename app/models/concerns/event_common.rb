module EventCommon
  BITLY_SHORTEN_API_URL = 'https://api-ssl.bitly.com/v4/shorten'

  def build_informed_from_url
    aurl = Addressable::URI.parse(self.url)
    if aurl.host.include?('connpass.com')
      self.informed_from = :connpass
    elsif aurl.host.include?('peatix.com')
      self.informed_from = :peatix
    elsif aurl.host.include?('doorkeeper')
      self.informed_from = :doorkeeper
    elsif aurl.host.include?('atnd')
      self.informed_from = :atnd
    elsif aurl.host.include?('meetup.com')
      self.informed_from = :meetup
    end
  end

  def build_from_website
    dom =
      RequestParser.request_and_parse_html(
        url: self.url, options: { customize_force_redirect: true, timeout_second: 30 },
      )
    return nil if dom.text.blank?
    # Titleとdescriptionはなんかそれらしいものを抜き取って入れておく
    dom.css('meta').each do |meta_dom|
      dom_attrs = OpenStruct.new(meta_dom.to_h)
      if self.title.blank?
        if dom_attrs.property.to_s.include?('title') || dom_attrs.name.to_s.include?('title') ||
             dom_attrs.itemprop.to_s.include?('title')
          self.title = dom_attrs.content.to_s.strip.truncate(140)
        end
      end
      if self.description.to_s.length < dom_attrs.content.to_s.length
        if dom_attrs.property.to_s.include?('description')
          dom_attrs.name.to_s.include?('description')
          dom_attrs.itemprop.to_s.include?('description')
          self.description = dom_attrs.content.to_s.strip
        end
      end
    end
    self.title = dom.try(:title).to_s.strip.truncate(140) if self.title.blank?

    body_dom = dom.css('body').first
    return nil if body_dom.blank?
    sanitized_body_html = Sanitizer.basic_sanitize(body_dom.to_html)
    sanitized_body_text = Sanitizer.basic_sanitize(body_dom.text)

    delete_reg_exp = Regexp.new(['(', [
      Sanitizer::RegexpParts::HTML_COMMENT,
      Sanitizer::RegexpParts::HTML_SCRIPT_TAG,
      Sanitizer::RegexpParts::HTML_HEADER_TAG,
      Sanitizer::RegexpParts::HTML_FOOTER_TAG,
      Sanitizer::RegexpParts::HTML_STYLE_TAG,
    ].join(')|('), ')'].join(''))
    sanitized_main_content_html = sanitized_body_html.gsub(delete_reg_exp, '')
    match_address = Sanitizer.japan_address_regexp.match(sanitized_body_text)

    if match_address.present?
      self.address = match_address
      self.place = self.address
    else
      # オンラインの場合を検索する
      scaned_online = sanitized_main_content_html.downcase.scan(/(オンライン|online|おんらいん)/)
      self.place = 'online' if scaned_online.present?
    end

    current_time = Time.current
    candidate_dates = Sanitizer.scan_candidate_datetime(sanitized_main_content_html)
    # 前後一年以内の日時が候補
    # 時間が早い順にsortした
    filtered_dates =
      candidate_dates.select do |candidate_date|
        ((current_time.year - 1)..(current_time.year + 1)).cover?(candidate_date.year)
      end.uniq.sort

    candidate_times = Sanitizer.scan_candidate_time(sanitized_main_content_html)
    filtered_times =
      candidate_times.select do |candidate_time|
        0 <= candidate_time[0].to_i && candidate_time[0].to_i < 30 && 0 <= candidate_time[1].to_i &&
          candidate_time[1].to_i < 60 && 0 <= candidate_time[2].to_i && candidate_time[2] < 60
      end.uniq
    filtered_times.sort_by! { |time| time[0].to_i * 10000 + time[1].to_i * 100 + time[2].to_i }
    start_time_array = filtered_times.first || []
    end_time_array = filtered_times.last || []
    start_at_datetime = filtered_dates.first
    end_at_datetime = filtered_dates.last

    self.started_at =
      start_at_datetime.try(
        :advance,
        { hours: start_time_array[0].to_i, minutes: start_time_array[1].to_i, secounds: start_time_array[2].to_i },
      )
    if end_at_datetime.present?
      self.ended_at =
        end_at_datetime.try(
          :advance,
          { hours: end_time_array[0].to_i, minutes: end_time_array[1].to_i, secounds: end_time_array[2].to_i },
        )
    end
    # 解析した結果、始まりと終わりが同時刻になってしまったのなら、その日の終わりを終了時刻とする
    self.ended_at = self.started_at.try(:end_of_day) if self.started_at.present? && self.started_at == self.ended_at
  end

  def generate_google_map_static_image_url
    return(
      "https://maps.googleapis.com/maps/api/staticmap?zoom=15&center=#{self.lat},#{self.lon}&key=#{
        ENV.fetch('GOOGLE_API_KEY', '')
      }&size=185x185"
    )
  end

  def generate_google_map_embed_tag
    embed_url = Addressable::URI.parse('https://maps.google.co.jp/maps')
    query_hash = { ll: [self.lat, self.lon].join(','), output: 'embed', z: 16 }
    if self.place.present?
      query_hash[:q] = self.place
    elsif self.address.present?
      query_hash[:q] = self.address
    end
    embed_url.query_values = query_hash
    return(
      ActionController::Base.helpers.raw(
        "<iframe width=\"400\" height=\"300\" frameborder=\"0\" scrolling=\"yes\" marginheight=\"0\" marginwidth=\"0\" src=\"#{
          embed_url.to_s
        }\"></iframe>",
      )
    )
  end

  def get_og_image_url
    dom = RequestParser.request_and_parse_html(url: self.url, options: { follow_redirect: true })
    og_image_dom = dom.css("meta[@property = 'og:image']").first

    # 画像じゃないものも含まれていることもあるので分別する

    if og_image_dom.present?
      image_url = og_image_dom['content'].to_s

      fi = FastImage.new(image_url.to_s)
      return image_url.to_s if fi.type.present?
    end
    return nil
  end

  def short_url
    convert_to_short_url! if shortener_url.blank?
    return self.shortener_url
  end

  # {年}{開始月}{終了月}になるように番号を形成する
  def season_date_number
    number = self.started_at.year * 10000
    month = self.started_at.month
    if (1..2).cover?(month)
      return number + 102
    elsif (3..4).cover?(month)
      return number + 304
    elsif (5..6).cover?(month)
      return number + 506
    elsif (7..8).cover?(month)
      return number + 708
    elsif (9..10).cover?(month)
      return number + 910
    elsif (11..12).cover?(month)
      return number + 1112
    end
  end

  def url_active?
    http_client = HTTPClient.new
    begin
      response = http_client.get(self.url, { follow_redirect: true })
      return false if 400 <= response.status && response.status < 500
    rescue SocketError,
           HTTPClient::ConnectTimeoutError,
           HTTPClient::SendTimeoutError,
           HTTPClient::ReceiveTimeoutError,
           HTTPClient::BadResponseError,
           Addressable::URI::InvalidURIError => e
      return false
    end
    return true
  end

  def merge_event_attributes(attrs: {})
    ops = OpenStruct.new(attrs.reject { |key, value| value.nil? })

    if ops.started_at.present? && ops.started_at.is_a?(String)
      parsed_started_at = DateTime.parse(ops.started_at)
      ops.started_at = parsed_started_at if self.started_at.try(:utc) != parsed_started_at.try(:utc)
    end

    if ops.ended_at.present? && ops.ended_at.is_a?(String)
      parsed_ended_at = DateTime.parse(ops.ended_at)
      ops.ended_at = parsed_ended_at if self.ended_at.try(:utc) != parsed_ended_at.try(:utc)
    end
    if self.lat.present? && self.lon.present?
      ops.delete_field(:lat) unless ops.lat.nil?
      ops.delete_field(:lon) unless ops.lon.nil?
    end
    self.attributes = self.attributes.merge(ops.to_h)
    self.distribute_event_type
  end

  def build_location_data
    script_url =
      'https://script.google.com/macros/s/AKfycbxM1zm-Ep6jsV87pi5U9UQJQM4YvU2BHiCOghOV90wYCae3mtNfrz3JIQLWBxSMoJF0zA/exec'
    if self.address.present? && self.lat.blank? && self.lon.blank?
      geo_result =
        RequestParser.request_and_parse_json(
          url: script_url, params: { address: self.address }, options: { follow_redirect: true },
        )
      self.lat = geo_result['latitude']
      self.lon = geo_result['longitude']
    elsif self.address.blank? && self.lat.present? && self.lon.present?
      geo_result =
        RequestParser.request_and_parse_json(
          url: script_url, params: { latitude: self.lat, longitude: self.lon }, options: { follow_redirect: true },
        )
      self.lat = geo_result['latitude']
      self.lon = geo_result['longitude']
      self.address = geo_result['address']
    end
    if self.address.present?
      self.address = Charwidth.normalize(self.address).strip
    end
  end

  def search_hashtags
    return Sanitizer.scan_hash_tags(Nokogiri::HTML.parse(self.description.to_s).text).join(' ')
  end

  def og_image_html
    # すでにイベントが閉鎖しているのだからその後の処理をやらないようにしてみる
    return '' if self.closed?
    image_url = self.get_og_image_url
    if image_url.present?
      fi = FastImage.new(image_url.to_s)
      width, height = fi.size
      size_text = AdjustImage.calc_resize_text(width: width, height: height, max_length: 300)
      resize_width, resize_height = size_text.split('x')
      return(
        ActionController::Base.helpers.image_tag(
          image_url,
          { width: resize_width, height: resize_height, alt: self.title },
        )
      )
    end
    return ''
  end

  def generate_google_map_url
    return "https://www.google.co.jp/maps?q=#{self.lat},#{self.lon}"
  end

  def convert_to_short_url!
    update!(shortener_url: self.get_short_url)
  end

  def get_short_url
    result =
      RequestParser.request_and_parse_json(
        url: BITLY_SHORTEN_API_URL,
        method: :post,
        header: {
          'Authorization' => "Bearer #{ENV.fetch('BITLY_ACCESS_TOKEN', '')}", 'Content-Type' => 'application/json'
        },
        body: { long_url: self.url }.to_json,
        options: { follow_redirect: true },
      )
    if result['id'].present?
      return 'https://' + result['id']
    else
      return nil
    end
  end
end
