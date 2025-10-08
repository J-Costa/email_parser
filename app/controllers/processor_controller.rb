class ProcessorController < ApplicationController
  def new; end

  def create
    processor = EmailParser::Processor.new(raw_email: params[:raw_email])

    if processor.save
      render json: processor, status: :created
    else
      render json: processor.errors, status: :unprocessable_entity
    end
  end
end
