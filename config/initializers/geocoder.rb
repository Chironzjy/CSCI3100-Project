if ENV['GOOGLE_MAPS_API_KEY'].present?
  Geocoder.configure(
    lookup: :google,
    api_key: ENV['GOOGLE_MAPS_API_KEY'],
    use_https: true
  )
else
  Geocoder.configure(
    lookup: :nominatim,
    use_https: true,
    timeout: 5,
    http_headers: { "User-Agent" => "cuhk-mart-dev" }
  )
end