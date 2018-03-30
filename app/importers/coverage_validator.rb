# frozen_string_literal: true

class CoverageValidator < Darlingtonia::Validator
  private

    ##
    # @private
    #
    # @see Validator#validate
    def run_validation(parser:, **)
      parser.records.each_with_object([]) do |record, errors|
        coverage = coverage?(record) ? record.coverage : []
        errors << error_for(record: record) if Array(coverage).empty?
      end
    end
    # TODO: South must be less than North, West must be less than East - should we validate this or let bad data get created?

    def coverage?(record)
      record_responds_to_all_coverage_fields?(record) && record_contains_all_coverage_field_data?(record)
    end

    def record_responds_to_all_coverage_fields?(record)
      record.respond_to?(:northlimit) && record.respond_to?(:eastlimit) && record.respond_to?(:southlimit) && record.respond_to?(:westlimit)
    end

    def record_contains_all_coverage_field_data?(record)
      record.northlimit.present? && record.eastlimit.present? && record.southlimit.present? && record.westlimit.present?
    end

    protected

      ##
      # @private
      # @param record [InputRecord]
      #
      # @return [Error]
      def error_for(record:)
        Error.new(self,
                  :missing_coverage_field,
                  "NorthLimit, EastLimit, SouthLimit and WestLimit are all required fields; got #{record.mapper.metadata}")
      end
end
