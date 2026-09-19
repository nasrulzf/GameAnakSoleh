# Features

This document describes gameplay-facing behavior as currently implemented. For the underlying code structure, see [architecture.md](architecture.md); for how to add new content, see [content-authoring.md](content-authoring.md).

## Level & episode system

- The campaign is planned as **5 episodes × 10 levels = 50 levels** (`kFinalLevelId = 50` in `lib/game/levels/level_registry.dart`). **20 levels are implemented today** (Episode 1: levels 1–10, Episode 2: levels 11–20); Episode 3–5 exist only as titles in `kEpisodeTitles` and as planning content in `requirements/add-50-level-scenario/requirement.md`.
- Episode titles (`kEpisodeTitles`):
  1. Ngaji & Adab Harian
  2. TPA & Belajar Al-Qur'an
  3. Masjid & Sholat Berjamaah
  4. Ramadhan & Zakat
  5. Haji, Kisah Nabi & Akhlak Mulia
- Each level is defined by a `LevelData` value (world size, ground height, player start, platforms, obstacles, quiz gates, goal position, optional ladders/moving platforms/crumbling platforms/patrol obstacles, and an optional `timeLimitSeconds`).
- `LevelSelectScreen` lists levels grouped by episode, showing lock state, best score, and a "perfect" star per level.

### Unlock rules

- Levels unlock sequentially: completing level *N* unlocks level *N+1* (`GameProgress.completeLevel`). Level 1 is always unlocked.
- **Special episodes** (episode number ≥ 4) have an *additional* gate: `GameProgress.isSpecialEpisodeUnlocked(episode)` requires the **three preceding episodes** to each be "clean" (`isEpisodeClean` — every one of that episode's 10 levels has been completed **Perfect**, i.e. with all hearts intact, at least once). Episodes 1–3 have no such extra requirement.
- This is a general N-3/N-2/N-1 rule (not hardcoded to episodes 4/5 specifically), so it will apply automatically if the campaign is extended beyond 50 levels/5 episodes.

## Character system

- Two playable characters: `CharacterGender.boy` / `CharacterGender.girl`, chosen once on `CharacterSelectScreen` and persisted via `GameProgress.setGender`.
- Sprite naming convention: `assets/images/characters/{boy|girl}_{left|right}_{idle|walk1|walk2|jump}.png`.
- `PlayerComponent` drives movement physics (accelerate to 220 px/s, decelerate on release) and jump physics (gravity 1600, jump speed 760, terminal fall speed 900 px/s), and swaps animation state (idle/walk1/walk2/jump) per direction, plus a squash-and-stretch visual effect on landing/jumping.

## Quiz gate feature

- A **quiz gate** (visually a treasure chest) blocks progress until answered correctly. Touching a gate (an overlap trigger, not a solid collision) pauses the Flame engine and opens `QuizOverlay`, a themed Flutter popup (wooden frame, mascot character, 2×2 grid of pastel answer buttons, `Baloo 2` font via `google_fonts`, responsive text via `auto_size_text`).
- **Correct answer**: awards a speed-based score bonus (faster answer = more points, floor 20), plays the `answerCorrect` SFX, and either advances to the next sub-question (if the gate is a "double gate" with `extraQuestions`, e.g. level 45 per the original design) or marks the gate solved.
- **Wrong answer**: the popup shows an error state (mascot turns "worried", buttons turn red, an X icon appears) with a "Coba Lagi" (try again) retry button; `hearts -= 1` and the `answerWrong` SFX plays. The player keeps re-attempting the same question — there's no skip.
- Once **every** quiz gate in a level is solved, `GoalComponent` (the "Madrasah" building) unlocks and the player can reach it to finish the level.
- Question data comes from `lib/quiz/quiz_bank.dart` (`QuizBank`), modeled by `QuizQuestion` in `lib/quiz/quiz_question.dart` — see [content-authoring.md](content-authoring.md) for the schema and how levels select which questions appear at which gate.
- Questions can embed Arabic/hijaiyah script directly as Unicode text in `question`/`options` — the UI needs an appropriate font fallback for this to render correctly (noted in the original spec, `requirements/add-50-level-scenario/requirement.md`).

## Hearts / fail state

- Each level attempt starts with **5 hearts**. Every wrong quiz answer costs 1 heart.
- Reaching **0 hearts** ends the attempt immediately: `onLevelFailed` fires and `LevelFailedScreen` is shown, offering "Ulangi Level" (retry) or "Pilih Level" (back to level select).
- Failing a level **never** rolls back campaign progress (`unlockedLevel`, `bestScore`, `perfectLevels` are untouched) — only the current in-progress attempt is discarded.
- Completing a level with **all 5 hearts intact** marks it "Perfect" for that level id (`GameProgress.recordLevelResult(..., perfect: true)`), which feeds into the special-episode unlock rule above and shows a star badge on `LevelSelectScreen`.

## Scoring

Score for a single attempt is computed live inside `GameAnakSoleh` (not persisted until the level ends) as:

```
base           = 100 + (episode - 1) * 20
+ per correct answer: max(20, 100 - elapsedSecondsSinceGateShown * 5)   (speed bonus)
+ heartsRemainingAtGoal * 30                                            (heart bonus)
+ 300 flat                                                              (only if finished before timeLimitSeconds, Episode 4/5 levels only)
```

On finishing a level, `GameProgress.recordLevelResult(levelId, score, perfect: ...)` updates `bestScore[levelId]` only if the new score is higher (scores never regress), and `totalHighScore` (shown on `LevelSelectScreen`) is the sum of all per-level best scores.

## Timer (bonus-only)

- `LevelData.timeLimitSeconds` is `null` for Episode 1–3 levels (no timer shown) and set for Episode 4/5 levels.
- The timer **never fails a level** — running out of time simply forfeits the 300-point timer bonus. `HudOverlay` only renders the countdown when a level has a time limit.

## Audio

- `SoundService` (`lib/audio/sound_service.dart`) wraps `flame_audio` with 6 named cues: `gameStart`, `jump`, `quizTrigger`, `answerWrong`, `answerCorrect`, `levelComplete`.
- All playback calls are wrapped in try/catch — a missing sound file fails silently instead of crashing, since actual SFX assets may not be fully populated (see `requirements/sound-feature/requirement.md`, which is a set of AI-audio-generation prompts, not shipped audio files).
- Expected asset locations: `assets/sounds/sfx/` and `assets/sounds/music/` (both declared in `pubspec.yaml` assets).

## Progress persistence

Everything below survives app restarts via `shared_preferences`, managed entirely by `GameProgress` (`lib/app/game_progress.dart`):

| Data | Key | Notes |
|---|---|---|
| Selected character | `character_gender` | int index into `CharacterGender.values` |
| Highest unlocked level | `unlocked_level` | defaults to `1` |
| Best score per level | `best_score` | JSON-encoded `Map<levelId, score>` |
| Perfect-completion per level | `perfect_levels` | JSON-encoded `Map<levelId, bool>` |

There is no cloud sync, no account system, and no analytics/telemetry anywhere in the app — everything is local to the device.

## App icon & splash screen

- Source art: `assets/icon/app_icon.png`, generated into Android mipmaps via `flutter_launcher_icons`.
- Native splash (shown before Flutter's first frame) is configured via `flutter_native_splash` (background `#8FD3F4`, same icon image), Android-only.
- A **second**, custom Flutter `SplashScreen` (`lib/ui/splash_screen.dart`) takes over immediately after the native one is dismissed, showing a real preload-driven progress bar (hydrating `GameProgress`, warming sprite/audio caches) rather than a fixed-duration fake loader.
