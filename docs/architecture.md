# Architecture

## Tech stack

| Layer | Choice | Notes |
|---|---|---|
| UI framework | Flutter (SDK `>=3.3.0 <4.0.0`) | Material 3, seed color `0xFF2563EB` |
| Game engine | [`flame`](https://pub.dev/packages/flame) `^1.18.0` | `FlameGame` subclass drives the side-scrolling level itself; menus/HUD/popups stay in plain Flutter widgets layered on top |
| Audio | [`flame_audio`](https://pub.dev/packages/flame_audio) `^2.10.7` | Wrapped by `SoundService` |
| State management | [`provider`](https://pub.dev/packages/provider) `^6.1.2` | One app-wide `ChangeNotifierProvider<GameProgress>`; no bloc/riverpod |
| Persistence | [`shared_preferences`](https://pub.dev/packages/shared_preferences) `^2.2.3` | Local key-value only — **no backend, no network calls anywhere in the app** |
| Navigation | Raw `Navigator.push` / `pushReplacement` with `MaterialPageRoute` | No routing package (no go_router, no named routes) |
| Fonts | [`google_fonts`](https://pub.dev/packages/google_fonts) (`Baloo 2`) | Playful/rounded font used in quiz popup and result/splash/complete screens |
| Text sizing | [`auto_size_text`](https://pub.dev/packages/auto_size_text) | Responsive font sizing for variable-length quiz question text |
| App icon / splash | `flutter_launcher_icons`, `flutter_native_splash` | Android-only generation from `assets/icon/app_icon.png` |

Target platform is **Android only** — there is no `ios/` folder, and both `flutter_launcher_icons` and `flutter_native_splash` are configured with `ios: false, web: false` in `pubspec.yaml`.

## Project layout

```
lib/
  main.dart                    — app entry point / bootstrap
  app/
    game_progress.dart         — global persisted state (ChangeNotifier)
  audio/
    sound_service.dart         — static wrapper around flame_audio for SFX cues
  game/
    game_anak_soleh.dart       — the FlameGame subclass: core game loop, level loading, quiz-gate/heart/score/timer logic
    hud_overlay.dart           — Flutter overlay: hearts, timer, on-screen move/jump controls
    components/                — Flame PositionComponents (player, platforms, obstacles, gates, scenery...)
    levels/
      level_data.dart          — data model for a level (LevelData + all *Spec classes)
      level_registry.dart      — kLevelBuilders map, kLevelMeta, kEpisodeTitles, kFinalLevelId
      level_1.dart … level_20.dart — one file per level, each exporting buildLevelN()
  quiz/
    quiz_question.dart         — QuizQuestion model, QuizCategory, QuizDifficulty
    quiz_bank.dart             — static question bank (QuizBank.all) + helpers
    quiz_overlay.dart          — Flutter popup widget shown on quiz gate trigger
  ui/
    splash_screen.dart         — cold-start preload + progress bar
    main_menu_screen.dart
    character_select_screen.dart
    level_select_screen.dart
    gameplay_screen.dart       — hosts the GameWidget(Flame), wires overlays
    level_result_screen.dart
    level_failed_screen.dart
    all_levels_complete_screen.dart
assets/
  images/{bg,ground,platform,obstacle,characters,buildings,items,scenery}/
  sounds/{sfx,music}/
  icon/                        — source icon for flutter_launcher_icons / native_splash
android/                       — Android platform project (only platform target)
test/                          — unit + structural tests (see Testing below)
requirements/                  — historical per-feature spec docs (design archive, see docs/README.md)
```

## Bootstrap flow (`lib/main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()`, then `FlutterNativeSplash.preserve()` — keeps the native Android splash visible past Flutter's first frame (needed on Android 12+, which otherwise dismisses it too early against Flame's separate rendering surface).
2. Forces landscape orientation via `SystemChrome.setPreferredOrientations`.
3. `runApp(const GameAnakSholehApp())`.
4. `GameAnakSholehApp` wraps the tree in `ChangeNotifierProvider<GameProgress>` seeded with `GameProgress.empty()` — a synchronous, unhydrated placeholder so the widget tree can build immediately — then renders a `MaterialApp` whose `home` is `SplashScreen`.
5. `SplashScreen` does the real async bootstrap work, in order:
   - `FlutterNativeSplash.remove()` (dismiss the native splash immediately, Flutter's own splash screen takes over)
   - `GameProgress.hydrate()` — loads real values from `SharedPreferences` into the *same* provider instance
   - `Flame.images.loadAll(...)` — warms the sprite cache
   - `SoundService.preload()` — warms the audio cache
   - enforces a minimum 1.35s display time (so the splash doesn't flash by on fast devices)
   - `Navigator.pushReplacement` → `MainMenuScreen`

## Screen / navigation flow

```
SplashScreen
  → MainMenuScreen
      → CharacterSelectScreen   (only if GameProgress.gender is still null)
      → LevelSelectScreen
          → GameplayScreen(levelId)
              ├─ on goal reached, levelId != kFinalLevelId → LevelResultScreen
              │     → "Lanjut" (next level) / "Pilih Level" (back to LevelSelectScreen)
              ├─ on goal reached, levelId == kFinalLevelId (50) → AllLevelsCompleteScreen
              │     → "PILIH LEVEL" / "Beranda" / "Ulangi"
              └─ on hearts == 0 → LevelFailedScreen
                    → "Ulangi Level" / "Pilih Level"
```

There is no routing package; every transition is a plain `Navigator.push`/`pushReplacement` call with `MaterialPageRoute`, so adding a new screen means wiring the `Navigator` call by hand at the call site — check `gameplay_screen.dart` for the existing pattern before adding new terminal screens.

## Game engine architecture (`lib/game/`)

`GameAnakSoleh` (`lib/game/game_anak_soleh.dart`) extends Flame's `FlameGame` and owns the per-attempt runtime state:

- **Level loading**: on `levelId` change it looks up `kLevelBuilders[levelId]` (see `level_registry.dart`) to obtain a `LevelData`, then spawns one Flame `Component` per spec list (`PlatformComponent`, `ObstacleComponent`, `QuizGateComponent`, `LadderComponent`, `MovingPlatformComponent`, `CrumblingPlatformComponent`, `PatrolObstacleComponent`, `GoalComponent`, plus decorative `GroundComponent`/`HillsComponent`/`SceneryComponent`).
- **Player**: `PlayerComponent` implements accel/decel horizontal movement (speed 220, accel 1000, decel 1500 px/s) and gravity-based jump physics (gravity 1600, jump speed 760, max fall 900 px/s), with directional sprite animation (idle/walk1/walk2/jump × left/right) and squash-and-stretch juice.
- **Collision model**: platforms/ground/obstacles are solid (block movement); `QuizGateComponent` is a non-solid overlap trigger — touching it (not walking through it as a wall) calls back into `GameAnakSoleh._handleGateBlocked`, which pauses the Flame engine and exposes the active `QuizQuestion` via a `ValueNotifier` that `GameplayScreen` listens to in order to show `QuizOverlay`.
- **Quiz resolution**: `GameAnakSoleh.answerQuiz(chosenIndex)` checks `QuizQuestion.isCorrect`. Correct → speed-based score bonus, advances to the gate's next sub-question if it has `extraQuestions` ("double gate"), else marks the gate solved; once every gate in the level is solved, `GoalComponent` unlocks. Wrong → `hearts -= 1`; hitting 0 hearts fires `onLevelFailed` (only the current attempt is discarded — no unlocked-level or best-score progress is lost).
- **HUD**: `HudOverlay` (plain Flutter widget, not a Flame component) renders hearts, the countdown timer (only shown when `LevelData.timeLimitSeconds != null`), and on-screen move/jump touch controls, and is composed by `GameplayScreen` as a Flame `overlay` alongside `QuizOverlay`.

See [features.md](features.md) for the gameplay-facing behavior (scoring formula, heart rules, unlock rules) and [content-authoring.md](content-authoring.md) for the exact data schema used to author new levels/components.

## State management

A single `GameProgress` (`lib/app/game_progress.dart`, `ChangeNotifier`) provided at the app root holds everything that must survive an app restart:

- selected `CharacterGender` (boy/girl)
- `unlockedLevel` (highest level id reachable)
- `bestScore` (`Map<int, int>`, per level id, JSON-encoded into `shared_preferences`)
- `perfectLevels` (`Map<int, bool>`, per level id — completed with all hearts intact)

Everything else (current hearts, current score, remaining timer seconds, which quiz gates are solved this attempt) lives only inside the `GameAnakSoleh` instance for the current attempt and is discarded on level restart/exit — it is never persisted.

Widgets read `GameProgress` via `context.watch<GameProgress>()` / `context.read<GameProgress>()` (standard `provider` usage) rather than any bespoke state plumbing.

## Testing

`test/` contains:

- `widget_test.dart` — smoke test that `MainMenuScreen` renders under a mocked `GameProgress`/`SharedPreferences`.
- `game_progress_test.dart` — unit tests for unlock progression, gender persistence, best-score/perfect tracking, and the episode-unlock rule (`isEpisodeClean`/`isSpecialEpisodeUnlocked`).
- `quiz_bank_test.dart` — validates `QuizBank.all`: every question has exactly 4 options, a valid `correctIndex`, and all ids are unique.
- `level_geometry_test.dart` — a structural-invariant checker (no rendering involved) that verifies every platform/quiz gate/goal in each level is reachable via a plausible jump chain or ladder and rests on a surface, using constants derived from the player's actual jump physics. **Run this after authoring or editing any level** — it is the closest thing this project has to an automated playtest.

Run everything with:

```
flutter test
flutter analyze
```

## Known rough edges (as of this writing)

- `lib/quiz/quiz_bank.dart` is explicitly commented as a draft/placeholder pending religious-content review — treat its question text/answers as provisional, not final content.
- `SoundService` calls are wrapped in try/catch because SFX assets may be partially missing; a missing sound fails silently rather than crashing. Verify `assets/sounds/sfx/` and `assets/sounds/music/` are populated before relying on audio during a release build.
- `SETUP.md` at the repo root is stale (written when only 2 levels existed) — prefer this `docs/` folder for current architecture, and consider refreshing `SETUP.md` as part of onboarding cleanup.
- Windows-specific build note (still relevant): if the project drive differs from the Pub cache drive, the Kotlin incremental compiler can crash — `android/gradle.properties` sets `kotlin.incremental=false` to work around this.
