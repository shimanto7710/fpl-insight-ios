# FPL Insight

FPL Insight is an iOS-first Fantasy Premier League companion app that turns a custom machine learning prediction pipeline into a practical mobile experience. The goal of the project is to help FPL managers make faster squad decisions by showing predicted points, suggested lineups, top players, and a saved team builder inside a clean SwiftUI app.

This project showcases the full path from model development to product: I built the ML model from scratch, exposed the predictions through a FastAPI backend, containerized the service with Docker, deployed it on AWS, and then built the iOS client that consumes the API.

## Recent iOS Improvements

I recently improved the iOS architecture to make the app easier to maintain, test, and extend:

- Added protocol-based API integration with `FPLInsightAPIProtocol`.
- Updated view models to depend on the API protocol instead of the concrete API implementation.
- Added SwiftData offline storage for saved My Team players.
- Kept formation as a lightweight `UserDefaults` preference.
- Added focused Swift Testing unit tests for `BestXIViewModel`.
- Cleaned the tab model by renaming the My Team tab case from `settings` to `myTeam`.

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
- Offline player persistence with SwiftData for the saved My Team squad.
- Lightweight `UserDefaults` persistence for selected formation.
- Bottom tab navigation with separate navigation stacks for each main section.
- Splash screen that loads into the root `HomeView`.

## iOS Tech Stack

- Swift
- SwiftUI
- MVVM-style feature structure
- `NavigationStack` and `TabView`
- `async/await` networking
- Generic API client
- Protocol-based API abstraction for testable view models
- `ObservableObject` view models
- `AsyncImage` for remote player images
- SwiftData for offline My Team player storage
- `UserDefaults` for lightweight formation persistence
- Swift Testing for focused view model tests
- Xcode project structure organized by app, features, models, services, and persistence

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
+-- Persistence/
+-- Services/
```

`HomeView` owns the bottom tab navigation. Each tab uses its own `NavigationStack`, which keeps navigation isolated per screen. Networking is handled through a reusable `APIClient`, while `FPLInsightAPI` contains the app-specific endpoints.

View models depend on `FPLInsightAPIProtocol`, which means the real API can be replaced with a mock API in tests or previews without changing screen logic. My Team players are saved with SwiftData through a `SavedSquadPlayer` model, so the selected squad can be restored offline.

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

Lets the user build a personal team. The screen supports formation selection, player search, position validation, bench slots, predicted point totals, and offline player saving with SwiftData.

## API Integration

The app uses a generic API client for reusable request handling:

- Validates URLs.
- Adds JSON accept headers.
- Checks HTTP status codes.
- Decodes responses into Swift models.
- Surfaces meaningful API errors to the UI.

Feature-specific calls are kept inside `FPLInsightAPI`, which makes the view models simpler and keeps endpoint details out of the UI layer.

The app also defines `FPLInsightAPIProtocol`, so view models are not tightly coupled to the live API implementation. This makes the architecture easier to test and keeps networking replaceable.

## Offline Persistence

My Team player selections are saved locally with SwiftData. The app defines a `SavedSquadPlayer` model and registers it in the app-level model container. When the My Team screen appears, it loads saved players from SwiftData and places them back into the correct pitch or bench slots.

Formation is saved separately in `UserDefaults` because it is a single lightweight preference.

## Testing

The project includes focused unit tests for `BestXIViewModel` using Swift Testing. The tests use a mock API implementation to verify both success and failure states without calling the real backend.

## What This Project Demonstrates

- Building a production-style SwiftUI app from a real API.
- Structuring an iOS project around features, models, and services.
- Using protocol-based dependency injection for API access.
- Saving app data offline with SwiftData.
- Writing focused Swift Testing unit tests.
- Consuming ML predictions in a mobile product.
- Designing user flows around real football/FPL decision making.
- Training and deploying a custom ML model.
- Connecting ML, backend, cloud deployment, and iOS into one complete project.

## Future Improvements

- Add authentication and cloud sync for saved teams.
- Add player detail screens with historical stats and prediction explanation.
- Add transfer recommendations based on user budget.
- Add captain and vice-captain optimization.
- Add more unit tests for My Team formation and persistence logic.

## Author

Built by Shimanto A. as an end-to-end ML and iOS portfolio project.
