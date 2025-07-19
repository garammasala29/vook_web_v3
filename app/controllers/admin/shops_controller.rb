module Admin
  class ShopsController < ApplicationController
    before_action :require_admin_login, only: %i[index new create edit update destroy]
    before_action :set_shop, only: %i[edit update destroy]

    def index
      @shops = Shop.includes(image_credits: { blob: { attachments: :record } }).order(:id)
    end

    def new
      @shop = Shop.new
    end

    def create
      @shop = Shop.new(shop_params)

      if @shop.save
        redirect_to admin_shops_path, notice: 'ショップを作成しました'
      else
        flash.now[:alert] = 'ショップの作成に失敗しました'
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @shop.update(shop_params)
        redirect_to admin_shops_path, notice: 'ショップを更新しました'
      else
        flash.now[:alert] = 'ショップの更新に失敗しました'
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @shop.destroy
      redirect_to admin_shops_path, notice: 'ショップを削除しました'
    end

    private

    def shop_params
      params.require(:shop).permit(:name, :url, :image)
    end

    def set_shop
      @shop = Shop.find(params[:id])
    end
  end
end
