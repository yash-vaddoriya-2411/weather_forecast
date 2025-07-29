class GeocodingService
  def initialize(address)
    @address = address
  end

  def coordinates
    # search coordinates for given address
    results = Geocoder.search(@address)
    if results.any?
      result = results.first
      # return latitude, longitude and zip code for controller
      {
        lat: result.latitude,
        lng: result.longitude,
        zip_code: result.postal_code
      }
    end
  end
end
