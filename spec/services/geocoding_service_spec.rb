require 'rails_helper'

RSpec.describe GeocodingService do
  describe "#coordinates" do
    context "when address is valid" do
      let(:result) {
        double("result", latitude: 12.34, longitude: 56.78, postal_code: "12345")
      }

      it "returns coordinates and zip code" do
        allow(Geocoder).to receive(:search).and_return([ result ])
        service = described_class.new("Some Place")
        expect(service.coordinates).to eq({ lat: 12.34, lng: 56.78, zip_code: "12345" })
      end
    end

    context "when address is blank" do
      it "returns empty hash" do
        service = described_class.new("")
        expect(service.coordinates).to eq({})
      end
    end

    context "when geocoder returns no result" do
      it "returns empty hash" do
        allow(Geocoder).to receive(:search).and_return([])
        service = described_class.new("Unknown")
        expect(service.coordinates).to eq({})
      end
    end
  end
end
