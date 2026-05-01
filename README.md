# FPL Insight

FPL Insight is an iOS-first Fantasy Premier League companion app that turns a custom machine learning prediction pipeline into a practical mobile experience. The goal of the project is to help FPL managers make faster squad decisions by showing predicted points, suggested lineups, top players, and a saved team builder inside a clean SwiftUI app.

This project showcases the full path from model development to product: I built the ML model from scratch, exposed the predictions through a FastAPI backend, containerized the service with Docker, deployed it on AWS, and then built the iOS client that consumes the API.

## Why I Built It

Fantasy Premier League decisions involve a lot of moving parts: form, fixtures, player position, team strength, opponent strength, price, minutes, and recent performance. I wanted to build a project that proves I can work across the stack, but with the iOS app as the main product surface.

The app focuses on making ML predictions useful for a real user instead of only showing a model score in a notebook.

## iOS App Features

- Best XI screen with a football-pitch layout for the recommended 15-player squad.
- Player cards showing image, predicted points, position, team, and opponent.
- Top Players screen with paginated loading, 20 players at a time.
- My Team screen where users can build their own squad on a pitch.
- Dynamic formation selection saved locally for future app launches.
- Position-aware player selection, so GK, DEF, MID, and FWD slots only allow valid players.
- Bench section with a fixed goalkeeper slot and flexible outfield slots.
- Player search backed by the API using query parameters.
- Predicted points summary for the selected user team.
- Local persistence with `UserDefaults` so the selected team and formation remain saved.
- Bottom tab navigation with separate navigation stacks for each main section.
- Splash screen that loads into the root `HomeView`.

## iOS Tech Stack

- Swift
- SwiftUI
- MVVM-style feature structure
- `NavigationStack` and `TabView`
- `async/await` networking
- Generic API client
- `ObservableObject` view models
- `AsyncImage` for remote player images
- `UserDefaults` for lightweight local persistence
- Xcode project structure organized by app, features, models, and services

## App Architecture

The app is organized around feature ownership so each screen is easier to understand and extend.

```text
FPL Insight/
+-- App/
|   +-- AppTab.swift
|   +-- HomeView.swift
|   +-- SplashView.swift
+-- Features/
|   +-- BestXI/
|   +-- MyTeam/
|   +-- TopPlayers/
+-- Models/
+-- Services/
```

`HomeView` owns the bottom tab navigation. Each tab uses its own `NavigationStack`, which keeps navigation isolated per screen. Networking is handled through a reusable `APIClient`, while `FPLInsightAPI` contains the app-specific endpoints.

## Machine Learning Pipeline

I trained the prediction model from scratch using `XGBRegressor`. The ML work included:

- Collecting and preparing FPL player and fixture data.
- Cleaning inconsistent, missing, and noisy values before training.
- Extracting useful features from historical player performance.
- Engineering features around form, position, team, opponent, fixture context, and expected contribution.
- Training an XGBoost regression model to predict player points.
- Comparing XGBRegressor against other regression models to choose the best-performing approach.
- Running hyperparameter tuning to improve model accuracy and reduce overfitting.
- Evaluating predictions before exposing them to the backend API.

XGBRegressor was selected because it performs well on structured tabular data, handles nonlinear relationships, and works effectively with engineered football/FPL features.

## Backend and Deployment

The trained model is served through a FastAPI backend. The API provides endpoints for best XI predictions, top players, and searchable player data used by the iOS app.

Backend and deployment work included:

- FastAPI service for model inference and player data endpoints.
- Docker containerization for repeatable deployment.
- AWS deployment for hosting the backend service.
- JSON API responses designed for direct Swift decoding.
- Query-based filtering for player search and position-specific selection.

Example endpoint used by the iOS app:

```http
GET /api/v1/predictions/best-xi
```

## Main Screens

### Best XI

Shows the model-recommended squad on a football pitch. Players are grouped by position and displayed with predicted points, opponent, and image.

### Top Players

Shows the highest-performing players with pagination. The app loads 20 players at a time to keep the screen responsive and API usage efficient.

### My Team

Lets the user build a personal team. The screen supports formation selection, player search, position validation, bench slots, predicted point totals, and local saving.

## API Integration

The app uses a generic API client for reusable request handling:

- Validates URLs.
- Adds JSON accept headers.
- Checks HTTP status codes.
- Decodes responses into Swift models.
- Surfaces meaningful API errors to the UI.

Feature-specific calls are kept inside `FPLInsightAPI`, which makes the view models simpler and keeps endpoint details out of the UI layer.

## What This Project Demonstrates

- Building a production-style SwiftUI app from a real API.
- Structuring an iOS project around features, models, and services.
- Consuming ML predictions in a mobile product.
- Designing user flows around real football/FPL decision making.
- Training and deploying a custom ML model.
- Connecting ML, backend, cloud deployment, and iOS into one complete project.

## Future Improvements

- Add authentication and cloud sync for saved teams.
- Add player detail screens with historical stats and prediction explanation.
- Add transfer recommendations based on user budget.
- Add captain and vice-captain optimization.
- Add unit tests for API decoding and view model state handling.

## Author

Built by Shimanto A. as an end-to-end ML and iOS portfolio project.
