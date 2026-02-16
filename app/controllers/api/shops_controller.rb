module API
  class ShopsController < ApplicationController
    def index
      shops = Shop.all
      render json: ShopResource.new(shops)
    end
  end
end
