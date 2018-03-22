class ProductsController < ApplicationController
  def index
    if params[:search].present?
      @urls = Url.includes(:products).where("url.name LIKE ?", "%#{params[:search][:search_query]}%").page(params[:page])
    else
      @urls = Url.page(params[:page]).includes(:products)
    end
  end

  def create
    if (/https:\/\/|http:\/\//).match?(params[:product][:query])
      prices = get_price(params[:product][:query])
      url = Url.create(url: params[:product][:query], image: prices["image"])
      insert_params = ActionController::Parameters.new(product: prices.merge!({ "url_id" => url.id}))
      Product.create(insert_params.require(:product).permit(:min_price, :max_price, :name, :url_id))
    else
      get_products_by_query(params[:product][:query])
    end
    redirect_to products_path
  end

  def show
    @products = Url.find(params[:id]).products.where("created_at > ?", Date.today - 1)
    @min = @products.minimum(:min_price)
    @min -= (@min * 0.03).to_i
  end

  def show_chart
    @products = Url.find(params[:product_id]).products.where("created_at > ?", Date.today - params[:period].to_i)
    @min = @products.minimum(:min_price)
    render partial: "chart", locals: { products: @products, min: @min - (@min * 0.03).to_i }
  end

  private

  def get_products_by_query(query)
    json = JSON.parse(Curl.get("https://catalog.api.onliner.by/search/products", query: query.gsub(/ /, '+'), page: 1).body_str)
    insert_from_json(json)
    json["page"]["last"].to_i - 1.times do |index|
      json = JSON.parse(Curl.get("https://catalog.api.onliner.by/search/products", query: query.gsub(/ /, '+'), page: index + 2).body_str)
      insert_from_json(json)
    end
  end

  def insert_from_json(json)
    json["products"].each do |product|
      if product["prices"]
        url = Url.create(name: product["name_prefix"] + " " + product["full_name"], url: product["html_url"], image: "https:" + product["images"]["header"])
        Product.create(min_price: product["prices"]["price_min"]["amount"],
                       max_price: product["prices"]["price_max"]["amount"],
                       url_id: url.id)
      end
    end
  end

  def get_price(url)
    page = Nokogiri::HTML(Curl.get(url).body)
    text = page.css("a.offers-description__link")[0].inner_text.strip
    title = page.css("h1.catalog-masthead__title")[0].inner_text.strip
    image = page.css("#device-header-image")[0].attribute("src").value
    {"min_price" => BigDecimal.new(text.match(/(.*) – (.*) р./)[1].gsub(/,/, ".").to_s),
     "max_price" => BigDecimal.new(text.match(/(.*) – (.*) р./)[2].gsub(/,/, ".").to_s),
     "name" => title,
     "image" => image }
  end

  def get_chart

  end

  # def get_chart(period = 1)
  #   date_array = [{"label" => Date.today - period.to_i}] + get_objects_array(@products, "label", "created_at", period.to_i)
  #   max_price_array = [{"value" => @products.first.max_price}] + get_objects_array(@products, "value", "max_price", period.to_i)
  #   min_price_array = [{"value" => @products.first.min_price}] + get_objects_array(@products, "value", "min_price", period.to_i)
  #   filled_date_array, filled_max_price_array, filled_min_price_array = fill_arrays_by_hashes(date_array, max_price_array, min_price_array)
  #   @chart = Fusioncharts::Chart.new(
  #     :height => 400,
  #     :width => 600,
  #     :type => 'msarea',
  #     :renderAt => 'chart-container',
  #     :dataSource => {
  #       "chart" =>  {
  #         "caption": @products.first.name + " prices",
  #         "theme": 'hulk-light',
  #         "xaxisname": "Date",
  #         "yaxisname": "Price (In R)",
  #         "crossLineColor": "#262626",
  #         "crossLineAlpha": "50",
  #         "showvalues": "0"
  #       },
  #       "categories": [
  #         {
  #           "category": filled_date_array
  #         }
  #       ],
  #       "dataset": [
  #         {
  #           "seriesname": "Max price",
  #           "renderas": "line",
  #           "showvalues": "6",
  #           "data": filled_max_price_array
  #         },
  #         {
  #           "seriesname": "Min price",
  #           "renderas": "line",
  #           "showvalues": "6",
  #           "data": filled_min_price_array
  #         }
  #       ]
  #     }
  #   )
  # end
  #
  # def get_objects_array(products, key_name, value_name, period)
  #   products.map do |product|
  #     if product.created_at.to_date - period < product.created_at
  #       { key_name => product[value_name] }
  #     else
  #       break
  #     end
  #   end
  # end

  # def fill_arrays_by_hashes(date_array, max_price_array, min_price_array)
  #   filled_date_array = [] << date_array[0]
  #   filled_max_price_array = [] << max_price_array[0]
  #   filled_min_price_array = [] << max_price_array[0]
  #   index = 1
  #   while filled_date_array.last["label"] < DateTime.now
  #     if filled_date_array.last["label"] + 1.minute < date_array[index]["label"]
  #       index += 1
  #       filled_date_array << date_array[index]
  #     else
  #       filled_date_array << {"label" => filled_date_array.last["label"] + 1.minute}
  #     end
  #     filled_max_price_array << max_price_array[index]
  #     filled_min_price_array << max_price_array[index]
  #   end
  #   return filled_date_array, filled_max_price_array, filled_min_price_array
  # end
end