# FPL Insight

FPL Insight is an iOS Fantasy Premier League companion app powered by a custom machine learning prediction backend. The app helps users explore predicted player points, view a recommended Best XI, compare top players, and build their own saved squad.

The project is built to showcase iOS product development first, while also demonstrating end-to-end ML, backend, Docker, and AWS deployment experience.

## Highlights

- SwiftUI app with bottom tab navigation and separate navigation stacks.
- Best XI pitch view showing 15 predicted players with points, opponent, position, team, and image support.
- My Team builder with dynamic formations, position-based player selection, searchable player picker, predicted point totals, and saved squad persistence.
- Top Players screen with paginated API loading.
- Generic `APIClient` using `async/await`, HTTP validation, JSON decoding, and reusable error handling.
- Protocol-based API layer for dependency injection and testability.
- Network-aware fallback API: live API is used when available, offline mock data is shown when there is no internet or the server fails.
- SwiftData storage for saved My Team players and `UserDefaults` for lightweight formation persistence.
- Clean Architecture applied to the Best XI flow with use case and repository layers.
- Focused Swift Testing coverage for `BestXIViewModel`.

## iOS Architecture

The app is organized by feature, with shared services and persistence kept separate.

```text
FPL Insight/
+-- App/
+-- Features/
|   +-- BestXI/
|   +-- MyTeam/
|   +-- TopPlayers/
+-- Domain/
|   +-- Repositories/
|   +-- UseCases/
+-- Data/
|   +-- Repositories/
+-- Models/
+-- Persistence/
+-- Services/
```

Best XI follows a clean architecture path:

```text
BestXIView
-> BestXIViewModel
-> FetchBestXIUseCase
-> BestXIRepository
-> BestXIRepositoryImpl
-> FPLInsightAPIProtocol
-> APIClient
```

This keeps UI, business logic, data access, and networking responsibilities separated. Other features use a simpler MVVM structure where that is enough for the current scope.

## Main Features

**Best XI**  
Displays the model-recommended squad on a football pitch layout, grouped by position with predicted points and opponent information.

**Top Players**  
Shows high-performing players from the API with paginated loading, 20 players at a time.

**My Team**  
Lets users build a personal squad, choose formation, search players by API query, validate slot positions, view predicted team points, and save selected players offline.

## API and Offline Flow

The app uses a reusable API layer:

- `APIClient` handles HTTP requests and decoding.
- `FPLInsightAPIProtocol` keeps screens and repositories testable.
- `FPLInsightAPI` contains live backend endpoints.
- `FallbackFPLInsightAPI` checks network state and falls back to mock data when needed.
- `MockFPLInsightAPI` and `MockFPLInsightData` keep offline demo data separate from production networking.

Fallback behavior:

```text
No internet -> show offline mock data
Internet available -> try live API
Live API fails -> show offline mock data
```

## Machine Learning and Backend

I trained the prediction model from scratch using `XGBRegressor`. The ML work included data cleaning, feature extraction, feature engineering, model comparison, hyperparameter tuning, and evaluation before exposing predictions through an API.

The backend is built with FastAPI, containerized with Docker, and deployed on AWS. It serves prediction and player endpoints used by the iOS app, including Best XI predictions, top players, searchable players, and position-based filtering.

Example endpoint:

```http
GET /api/v1/predictions/best-xi
```

## Tech Stack

- Swift, SwiftUI
- MVVM and Clean Architecture for Best XI
- `NavigationStack`, `TabView`
- `async/await`
- Protocol-oriented API integration
- SwiftData, `UserDefaults`
- Network framework with `NWPathMonitor`
- Swift Testing
- FastAPI, Docker, AWS
- XGBoost / `XGBRegressor`

## Testing

The project includes focused unit tests for `BestXIViewModel`. Tests inject a mock use case to verify loading, success, and failure states without calling the real backend.

Run tests:

```bash
xcodebuild test -project 'FPL Insight.xcodeproj' -scheme 'FPL Insight' -destination 'platform=iOS Simulator,name=iPhone 16' '-only-testing:FPL InsightTests'
```

## What This Demonstrates

- Building a real SwiftUI app from API-driven data.
- Applying clean architecture where it adds value.
- Using dependency injection and protocols for testable iOS code.
- Designing offline-friendly app behavior.
- Persisting user data locally with SwiftData.
- Turning an ML model into a usable mobile product.
- Owning the full path from ML training to backend deployment to iOS implementation.

## Author

Developed by Md Afser Uddin.
