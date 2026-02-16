module API
  class ImageCreditsController < ApplicationController
    protect_from_forgery with: :null_session

    def create
      blob = ActiveStorage::Blob.find_signed(image_credit_params[:blob_id])
      render json: { error: 'Blob not found' }, status: :not_found and return unless blob

      credit = ImageCredit.find_or_initialize_by(blob_id: blob.id)
      credit.assign_attributes(image_credit_params.except(:blob_id))

      if credit.save
        render json: { status: 'ok' }, status: :ok
      else
        render json: { errors: credit.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def image_credit_params
      params.require(:image_credit).permit(:blob_id, :shop_id, :source_url)
    end
  end
end
