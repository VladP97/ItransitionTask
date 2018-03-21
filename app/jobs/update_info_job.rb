require 'sidekiq-scheduler'

class UpdateInfoJob
  include Sidekiq::Worker

  def perform(*args)
    Url.all.each { |url| update_info(url) }
  end

  private

  def update_info(url)
    page = Nokogiri::HTML(Curl.get(url.url).body)
    min_price, max_price = get_prices(page.css("a.offers-description__link")[0].inner_text.strip)
    title = page.css("h1.catalog-masthead__title")[0].inner_text.strip
    update_if_new(url.products.last, {"min_price" => min_price,
                                      "max_price" => max_price,
                                      "name" => title })
  end

  def get_prices(prices_text)
    if(/(.*) – (.*) р./).match?(prices_text)
      return BigDecimal.new(prices_text.match(/(.*) – (.*) р./)[1].gsub(/,/, ".").to_s),
             BigDecimal.new(prices_text.match(/(.*) – (.*) р./)[2].gsub(/,/, ".").to_s)
    else
      p prices_text
      return BigDecimal.new(prices_text.match(/(.*?) р./)[1].gsub(/,/, ".").to_s),
             BigDecimal.new(prices_text.match(/(.*?) р./)[1].gsub(/,/, ".").to_s)
    end
  end

  def update_if_new(last_product_state, current_product_state)
    puts current_product_state["min_price"]
    puts last_product_state["min_price"]
    if last_product_state["min_price"] != current_product_state["min_price"] ||
        last_product_state.max_price != current_product_state["max_price"] ||
          last_product_state.created_at.to_date < Date.today
      Product.create(min_price: current_product_state["min_price"],
                     max_price: current_product_state["max_price"],
                     name: current_product_state["name"],
                     url_id: last_product_state["url_id"])
    end
  end
end
