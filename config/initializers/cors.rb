Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://127.0.0.1:5500" # Frontend URL

    resource "/api/v1/*", # Matches your API routes
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options],
      credentials: true # Set to true if using authentication (e.g., JWT in cookies)

  end
end
