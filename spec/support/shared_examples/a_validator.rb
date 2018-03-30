# frozen_string_literal: true

RSpec.shared_examples 'a Darlingtonia::Validator' do
  subject(:validator) { described_class.new }

  define :be_a_validator_error do # |expected|
    match { false } # { |actual| some_condition }
  end

  describe '#validate' do
    context 'without a parser' do
      it 'raises ArgumentError' do
        expect { validator.validate }.to raise_error ArgumentError
      end
    end

    it 'gives an empty error collection for a valid parser' do
      expect(validator.validate(parser: valid_parser)).to be_empty
    end

    context 'for an invalid parser' do
      it 'gives an non-empty error collection' do
        expect(validator.validate(parser: invalid_parser)).not_to be_empty
      end
    end
  end
end
