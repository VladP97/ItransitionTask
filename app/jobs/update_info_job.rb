require 'sidekiq-scheduler'

class UpdateInfoJob
  include Sidekiq::Worker

  def perform(*args)
    Url.all.each { |url| update_info(url) }
  end

  private

  def update_info(url)
    page = Nokogiri::HTML(Curl.get(url.url).body)
    text = page.css("a.offers-description__link")[0].inner_text.strip
    title = page.css("h1.catalog-masthead__title")[0].inner_text.strip
    update_if_new(url.products.last, {"min_price" => BigDecimal.new(text.match(/(.*) – (.*) р./)[1].gsub(/,/, ".").to_s),
                                      "max_price" => BigDecimal.new(text.match(/(.*) – (.*) р./)[2].gsub(/,/, ".").to_s),
                                      "name" => title })
  end

  def update_if_new(last_product_state, current_product_state)
    puts current_product_state["min_price"]
    puts last_product_state.min_price
    if last_product_state.min_price != current_product_state["min_price"] || last_product_state.max_price != current_product_state["max_price"]
      Product.create(ActionController::Parameters.new(product: current_product_state.merge!({ "url_id" => last_product_state.id})))
    end
  end
end
