# frozen_string_literal: true
class IrisMapper < Darlingtonia::HashMapper
  def fields
    [:creator, :title, :keyword, :rights, :resource_type, :visibility, :representative_file]
  end

  def visibility
    metadata['visibility']
  end

  def representative_file
    metadata['file_name']
  end
end
