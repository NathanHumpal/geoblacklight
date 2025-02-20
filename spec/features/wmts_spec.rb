# frozen_string_literal: true
require 'spec_helper'

feature 'wmts layer' do
  before do
    WebMock.disable_net_connect!(allow_localhost: true, allow: 'chromedriver.storage.googleapis.com')
  end

  after do
    WebMock.allow_net_connect!
  end

  context 'when referencing a WMTSCapabilities document with a single layer' do
    scenario 'displays the layer', js: true do
      # Mock wmts manifest url
      stub_request(:get, 'https://map-tiles-staging.princeton.edu/mosaicjson/WMTSCapabilities.xml?id=2a91d82c541c426cb787cc62afe8f248')
        .to_return(status: 200, body: read_fixture('manifests/wmts-single.xml'))

      visit solr_document_path('princeton-fk4544658v-wmts')
      expect(page).to have_css '.leaflet-control-zoom', visible: :visible
      expect(page).to have_css "img[src*='map-tiles-staging.princeton.edu/mosaicjson/tiles/WebMercatorQuad']"
    end
  end
  context 'when referencing a WMTSCapabilities document with a multiple layers' do
    scenario 'displays the layer referenced in the layer_id field', js: true do
      # Mock wmts manifest url
      stub_request(:get, 'https://maps.wien.gv.at/wmts/1.0.0/WMTSCapabilities.xml')
        .to_return(status: 200, body: read_fixture('manifests/wmts-multiple.xml'))
      visit solr_document_path('princeton-fk4db9hn29')
      expect(page).to have_css '.leaflet-control-zoom', visible: :visible
      expect(page).to have_css "img[src*='http://maps1.wien.gv.at/wmts/lb2016/farbe/google3857']"
    end
  end
end
