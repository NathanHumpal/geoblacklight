# frozen_string_literal: true
require 'spec_helper'

describe Geoblacklight::DocumentPresenter do
  # Please see https://github.com/projectblacklight/blacklight/blob/v6.15.0/spec/presenters/index_presenter_spec.rb#L4
  subject { presenter }
  let(:request_context) { double(document_index_view_type: 'list') }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_index_field 'gbl_wxsIdentifier_s'
      config.add_index_field 'index_display'
      config.add_index_field 'period'
      config.add_index_field 'multi_display'
    end
  end
  let(:solr_fields) { Settings.FIELDS }
  let(:presenter) do
    described_class.new(document, request_context, blacklight_config)
  end

  let(:document) do
    SolrDocument.new(
      id: 1,
      gbl_wxsIdentifier_s: 'druid:abc123',
      non_index_field: 'do not render',
      period: 'Ends with period.',
      multi_display: %w[blue blah]
    )
  end

  describe '#index_fields_display' do
    let(:rendered_index_text) { subject.index_fields_display }
    let(:multi_valued_text) { document['multi_display'].join(' and ') }
    let(:combined_fields) { document['gbl_wxsIdentifier_s'] + '. ' + document['period'] }

    context 'with multi-valued field' do
      it 'each value is separated by comma' do
        expect(rendered_index_text).to include(multi_valued_text)
      end
    end
    context 'with document fields not configured as index field' do
      it 'does not render' do
        expect(rendered_index_text).not_to include(document['non_index_field'])
      end
    end
    context 'with multiple document index fields present' do
      it 'separates fields by period followed by a space' do
        expect(rendered_index_text).to include(combined_fields)
      end
      context 'with index field ending in period' do
        it 'renders only 1 period' do
          expect(rendered_index_text).to include(document['period'] + ' ')
        end
      end
    end
    context 'with document empty configured index field' do
      it 'does not render a period followed by a space' do
        expect(rendered_index_text).not_to include('. .')
      end
    end
  end
end
