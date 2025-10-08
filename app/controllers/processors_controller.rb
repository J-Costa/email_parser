class ProcessorsController < ApplicationController
  def new; end

  def create
    files = files_params.compact_blank!
    if files.blank?
      flash[:alert] = "Por favor, envie pelo menos um arquivo .eml."
      return redirect_to new_processor_path
    end

    log_ids = files.map do |file|
        log = Log.create!(status: :pending)
        log.eml_file.attach(file)
        log.id
      end

    EmailProcessor::BulkProcessJob.perform_later(log_ids)
    flash[:notice] = "Os arquivos estão sendo processados em segundo plano."
    redirect_to new_processor_path
  end

  private

  def files_params
    params.expect(files: [])
  end
end
