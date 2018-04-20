# frozen_string_literal: true
class IsoZipMapper < Darlingtonia::MetadataMapper
  def fields
    [:title, :iso, :resource_type, :zip]
  end

  def input_fields
    [:iso, :resource_type, :zip]
  end

  def iso
    @iso_xml ||=
      begin
        iso_entry.extract(File.join(tmp_dir, iso_entry_name))
        Nokogiri::XML(iso_entry.get_input_stream.read)
      end
  end

  def resource_type
    ['VectorWork']
  end

  def title
    iso.xpath('//xmlns:citation/xmlns:CI_Citation/xmlns:title/gco:CharacterString')
       .map(&:text)
  end

  def zip
    metadata || raise('Trying to access zip before set; use `#metadata=`.')
  end

  private

    def iso_entry_name
      zip.name.split('/').last.sub('.zip', '').to_s +
        '-iso19139.xml'
    end

    def iso_entry
      zip.get_entry(iso_entry_name)
    end

    def tmp_dir
      directory = Dir::Tmpname.create(['iris-'], Hydra::Derivatives.temp_file_base) {}

      FileUtils.mkdir_p(directory)
      directory
    end
end
