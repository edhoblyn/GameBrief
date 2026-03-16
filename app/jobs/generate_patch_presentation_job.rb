class GeneratePatchPresentationJob < ApplicationJob
  queue_as :default

  def perform(patch_id)
    patch = Patch.find_by(id: patch_id)
    return if patch.nil?
    return unless patch.ai_presentable?

    PatchPresentationService.new(patch).call
  end
end
