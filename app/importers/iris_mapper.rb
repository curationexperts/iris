# frozen_string_literal: true
class IrisMapper < Darlingtonia::HashMapper
  def fields
    [:creator, :title, :keyword, :rights, :resource_type, :visibility]
  end

  def visibility
    metadata['visibility']
  end
end
