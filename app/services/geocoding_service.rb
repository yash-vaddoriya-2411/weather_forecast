# This class has responsibility to get longitude, latitude etc from address using external api call
class GeocodingService
  def initialize(address)
    @address = address
  end

  def coordinates
    # Check for if address not blank
    return {} if @address.blank?

    # search coordinates for given address
    results = Geocoder.search(@address)
    return {} unless results.any?

    result = results.first
    # return latitude, longitude and zip code for controller
    {
      lat: result.latitude,
      lng: result.longitude,
      zip_code: result.postal_code
    }
  end
end
