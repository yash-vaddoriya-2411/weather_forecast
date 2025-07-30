
# Project Title

A brief description of what this project does and who it's for

# Weather Forecast System (Rails)

This is a simple weather forecast feature built with Ruby on Rails. Users can enter an address, and the system fetches the current weather using Geoapify for geocoding and OpenWeatherMap for weather data.

---

## Tech Stack & Versions

| Component         | Version     |
|------------------|-------------|
| Ruby             | 3.2.7       |
| Rails            | 8.0.2       |
| Bootstrap        | 5.3         |

---

## Features

- Enter an address to check the current weather.
- Get coordinates from Geoapify API.
- Get weather from OpenWeatherMap API.
- Service-Oriented Architecture (SOA).
- Handles invalid input and API errors.
- Well-structured request specs.

---

## Folder Structure
```bash
app/
├── controllers/
│   └── forecasts_controller.rb
├── services/
│   ├── geocoding_service.rb
│   ├── weather_forecast_service.rb
│   └── weather_service.rb
├── views/
│   └── forecasts/
│       └── check_weather.html.erb
```


## Setup Project Locally

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/weather-forecast.git
cd weather-forecast 
```

### 2. Install Required Ruby Version
```bash
rbenv install 3.2.7
rbenv local 3.2.7
```

### 3. Install Gems
```bash
bundle install
```

### 4. Set credentials (api keys, db)
```bash
EDITOR="nano" bin/rails credentials:edit --environment name
```


### 5. Start the Rails Server
```bash
rails server
```


## Running Test Cases

Run all tests using:
```bash
bundle exec rspec
```
