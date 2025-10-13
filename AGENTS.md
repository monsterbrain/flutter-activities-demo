## Agentic Instructions

This document provides instructions for AI agents working with this codebase.

### Tech Stack

*   **Flutter Version**: This project is built with Flutter. The exact version isn't specified, but it's compatible with the Dart version below.
*   **Dart Version**: The project uses Dart SDK version `^3.8.0`.
*   **State Management**: The project uses the `provider` package for state management.
    *   `Provider` is used for simple dependency injection (e.g., `SettingsController`, `Palette`).
    *   `ChangeNotifierProvider` is used for more complex state that changes over time (e.g., `PlayerProgress`).
    *   `ProxyProvider2` is used for providers that depend on other providers (e.g., `AudioController`).
    *   State is accessed in widgets using `context.watch<T>()` for listening to changes and `context.read<T>()` for one-off reads.

### How to Run

To run the application, use the standard Flutter command:

```bash
flutter run
```

### How to Test

To run the tests, use the following command:

```bash
flutter test
```

### Project Structure

The `lib` directory is organized by feature:

*   `app_lifecycle/`: Handles app lifecycle events.
*   `audio/`: Manages audio playback.
*   `game_internals/`: Core game logic.
*   `level_selection/`: UI for selecting game levels.
*   `main_menu/`: The main menu screen.
*   `play_session/`: The main gameplay screen.
*   `player_progress/`: Manages the player's progress.
*   `settings/`: Manages user settings.
*   `style/`: Contains visual styling information like colors and themes.
*   `win_game/`: The screen shown when a player wins the game.
*   `main.dart`: The entry point of the application.
*   `router.dart`: Defines the navigation routes for the app using `go_router`.