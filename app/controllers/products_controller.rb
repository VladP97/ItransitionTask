class ProductsController < ApplicationController
  def index

  end

  def create
    prices = get_price(params[:product][:query])
    url = Url.create(url: params[:product][:query])
    params = ActionController::Parameters.new(product: prices.merge!({ "url_id" => url.id}))
    Product.create(params.require(:product).permit(:min_price, :max_price, :name, :url_id))
    redirect_to products_path
  end

  def show
    @products = Url.find(params[:id]).products
    get_chart
  end

  private

  def get_price(url)
    page = Nokogiri::HTML(Curl.get(url).body)
    text = page.css("a.offers-description__link")[0].inner_text.strip
    title = page.css("h1.catalog-masthead__title")[0].inner_text.strip
    {"min_price" => BigDecimal.new(text.match(/(.*) – (.*) р./)[1].gsub(/,/, ".").to_s),
     "max_price" => BigDecimal.new(text.match(/(.*) – (.*) р./)[2].gsub(/,/, ".").to_s),
     "name" => title }
  end

  def get_chart
    @chart = Fusioncharts::Chart.new(
        :height => 400,
        :width => 600,
        :type => 'msarea',
        :renderAt => 'chart-container',
        :dataSource => {
          "chart" =>  {
            "caption": @products.first.name + " prices",
            "theme": 'hulk-light',
            "xaxisname": "Date",
            "yaxisname": "Price (In R)",
            "crossLineColor": "#262626",
            "crossLineAlpha": "50"
          },
          "categories": [
            {
              "category": get_objects_array(@products, "label", "created_at")
            }
          ],
          "dataset": [
            {
              "seriesname": "Min price",
              "renderas": "line",
              "showvalues": "0",
              "data": get_objects_array(@products, "value", "min_price")
            },
            {
              "seriesname": "Max price",
              "renderas": "line",
              "showvalues": "0",
              "data": get_objects_array(@products, "value", "max_price")
            }
          ]
        }
    )
  end

  def get_objects_array(products, key_name, value_name)
    products.map do |product|
      { key_name => product[value_name] }
    end
  end
end