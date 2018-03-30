# frozen_string_literal: true

class ProvenanceValidator < Darlingtonia::Validator
  private

    ##
    # @private
    #
    # @see Validator#validate
    def run_validation(parser:, **)
      parser.records.each_with_object([]) do |record, errors|
        provenances = record.respond_to?(:provenance) ? record.provenance : []

        errors << error_for(record: record) if Array(provenances).empty?
      end
    end

    protected

      ##
      # @private
      # @param record [InputRecord]
      #
      # @return [Error]
      def error_for(record:)
        Error.new(self,
                  :missing_provenance,
                  "Provenance is required; got #{record.mapper.metadata}")
      end
end
