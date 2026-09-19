# Content authoring guide

Practical reference for the most common extension work on this project: adding a new level and adding new quiz questions. Read [architecture.md](architecture.md) first if you haven't already.

## Data model reference (`lib/game/levels/level_data.dart`)

```dart
class LevelData {
  final int id;
  final String title;
  final int episode;                 // 1-5, groups levels for LevelSelectScreen + special-episode unlock rule
  final double worldWidth;
  final double worldHeight;
  final double groundHeight;
  final Vector2 playerStart;
  final List<PlatformSpec> platforms;
  final List<ObstacleSpec> obstacles;
  final List<QuizGateSpec> quizGates;
  final Vector2 goalPosition;
  final int? timeLimitSeconds;       // null = no timer (Episode 1-3); set only for Episode 4/5
  final List<LadderSpec> ladders;                     // default []
  final List<MovingPlatformSpec> movingPlatforms;      // default []
  final List<CrumblingPlatformSpec> crumblingPlatforms;// default []
  final List<PatrolObstacleSpec> patrolObstacles;      // default []
}

class PlatformSpec        { Vector2 position; Vector2 size; }
class ObstacleSpec        { Vector2 position; Vector2 size; }
class LadderSpec          { Vector2 position; Vector2 size; }

class QuizGateSpec {
  Vector2 position;
  Vector2 size;
  QuizQuestion question;
  List<QuizQuestion>? extraQuestions;  // set for a "double gate" — answer `question` then each of these in order
}

enum PatrolAxis { horizontal, vertical }

class MovingPlatformSpec {
  Vector2 position; Vector2 size;
  PatrolAxis axis;          // default horizontal
  double travelDistance;
  double speed;              // default 80 px/s
}

class CrumblingPlatformSpec {
  Vector2 position; Vector2 size;
  double crumbleDelaySeconds;  // default 0.6 — time standing on it before it collapses
  double respawnDelaySeconds;  // default 3   — time before it reappears
}

class PatrolObstacleSpec {
  Vector2 position; Vector2 size;
  PatrolAxis axis;           // default horizontal
  double patrolDistance;
  double speed;               // default 60 px/s
}
```

`QuizQuestion` (`lib/quiz/quiz_question.dart`):

```dart
class QuizQuestion {
  final String id;                 // must be globally unique — checked by test/quiz_bank_test.dart
  final QuizCategory category;
  final String question;
  final List<String> options;      // must contain exactly 4 entries — checked by test/quiz_bank_test.dart
  final int correctIndex;          // 0-3, asserted at construction
  final QuizDifficulty difficulty; // default QuizDifficulty.mudah
}

enum QuizDifficulty { mudah, sedang, sulit }
```

`QuizCategory` already lists categories for all 5 episodes (see the enum in `quiz_question.dart`) even though only Episode 1/2 categories currently have questions in `QuizBank.all` — you don't need to add new enum values for Episode 3-5 content, just start using the existing ones.

## Player jump physics (for level geometry)

`PlayerComponent`: gravity `1600`, jump speed `760`, horizontal speed `220`. This gives a maximum jump height of ~180px (`_maxJumpUp` in `test/level_geometry_test.dart` derives this from the same constants) — keep platform gaps within what this physics can actually clear. `MovingPlatformComponent`/`LadderComponent` exist specifically to bridge gaps that a plain jump can't.

## How to add a new level

1. Create `lib/game/levels/level_N.dart` modeled on an existing one (e.g. `level_20.dart` is the most recently added). Export a single `LevelData buildLevelN()` function — the builder pattern exists because quiz gates often need a *random* question pick per playthrough (`QuizBank.randomPick(...)`), so the level can't be a plain `const`.
2. Register it in `lib/game/levels/level_registry.dart`:
   - add the import
   - add `N: buildLevelN` to `kLevelBuilders`
   - add a `LevelMeta(id: N, episode: ..., title: ..., subtitle: ...)` entry to `kLevelMeta`, in id order
3. **Do not** change `kFinalLevelId` (hardcoded to `50`) until level 50 itself is actually implemented — it deliberately does not track `kLevelBuilders.length`, so that `GameplayScreen` doesn't route to `AllLevelsCompleteScreen` prematurely while the campaign is still being built out.
4. If the level belongs to a new episode's first level, double check `kEpisodeTitles` already has an entry for that episode (Episode 3-5 titles are already present).
5. Run `flutter test` — `test/level_geometry_test.dart` will fail if any platform/gate/goal in the new level is unreachable or floats without a surface under it. Fix geometry rather than skip this check.
6. Playtest manually: `flutter run` (see `SETUP.md` for environment setup) and complete the level via the actual touch/keyboard controls, including deliberately answering a quiz gate wrong to confirm the heart-loss path.

Refer to `requirements/add-50-level-scenario/requirement.md` Section covering the level-by-level table for the intended title/category/quiz-gate-count/new-mechanic per level if you're implementing Episode 3-5 — that document is the design source of truth for what each remaining level should contain, even though the code for it doesn't exist yet.

## How to add new quiz questions

1. Open `lib/quiz/quiz_bank.dart` and add a `QuizQuestion` entry to `QuizBank.all` (or wherever the relevant category's questions are grouped in that file).
2. Pick a unique `id` — check `test/quiz_bank_test.dart` expectations for the existing naming convention before inventing a new one, and keep ids stable once shipped (they may end up referenced by specific level builders that pick a question by id rather than by random category pick).
3. Use an existing `QuizCategory` value if the content fits one of the categories already defined for that episode; only add a new enum value if the content genuinely doesn't fit any existing category.
4. `options` must have **exactly 4 entries**; `correctIndex` must be `0-3`.
5. Arabic/hijaiyah text can go directly into `question`/`options` as plain Unicode — no special escaping needed, but verify it renders correctly in `QuizOverlay` (font fallback for Arabic script may need attention if it doesn't).
6. **Quiz content is currently placeholder/draft pending religious-content review** (see the note in `quiz_bank.dart` and `architecture.md`'s "Known rough edges"). If you're adding real content intended to ship, flag it for review rather than assuming existing entries are a vetted reference.
7. Run `flutter test` — `test/quiz_bank_test.dart` validates option count, correct-index bounds, and id uniqueness across the whole bank.

## Adding a new component type (platforms, obstacles, etc.)

If a level needs a mechanic that doesn't exist yet (a new kind of moving hazard, a switch, a collectible):

1. Add a `*Spec` class to `level_data.dart` (position/size plus whatever behavior parameters it needs) and a corresponding field on `LevelData`.
2. Implement the Flame `Component` in `lib/game/components/` (look at `crumbling_platform_component.dart` or `patrol_obstacle_component.dart` as templates for a stateful, timer-driven component).
3. Wire spawning for the new spec list into `GameAnakSoleh`'s level-loading code (`lib/game/game_anak_soleh.dart`), alongside how the existing spec lists are spawned.
4. Update `test/level_geometry_test.dart`'s reachability model if the new component changes what counts as a valid platform/surface for jump-chain analysis.
