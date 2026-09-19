# Roadmap

This roadmap reflects the state of the project as of **2026-09-19** (20 of 50 planned levels implemented, Episode 1–2 complete, Episode 3–5 not yet built). It's organized into phases rather than dates, since pacing depends on available development time. Each phase lists concrete, verifiable exit criteria so "done" is unambiguous.

Source of truth for planned level content: `requirements/add-50-level-scenario/requirement.md` (level-by-level table, categories, mechanics per episode). This roadmap sequences the *engineering and content* work; that document defines *what* each remaining level should contain.

## Phase 1 — Finish the core campaign (Episode 3)

Goal: complete the "clean core game" milestone — 30/50 levels, all three non-special episodes done, so the special-episode unlock rule (`GameProgress.isSpecialEpisodeUnlocked`) has real content to gate against.

- [ ] Implement levels 21–30 (Episode 3: "Masjid & Sholat Berjamaah") per the level table in `requirements/add-50-level-scenario/requirement.md`, using the process in [content-authoring.md](content-authoring.md).
- [ ] Add quiz questions for the `rukunSholat`, `wudhu`, and `adzanIqamah` categories to `quiz_bank.dart` (these categories already exist in `QuizCategory` but have no questions yet).
- [ ] Register all 10 levels in `level_registry.dart` (`kLevelBuilders`, `kLevelMeta`).
- [ ] `test/level_geometry_test.dart` passes for all new levels (reachability/no-floating-platform checks).
- [ ] Manual playtest of all 10 levels on a real or emulated Android device, including deliberately failing quiz gates to confirm heart loss and retry flow.

**Exit criteria**: `flutter test` green with 30 levels registered; `LevelSelectScreen` shows Episode 1–3 fully playable and Episode 4–5 still locked/greyed.

## Phase 2 — Complete the 50-level campaign (Episode 4 & 5)

Goal: reach the full planned scope — all 50 levels, both "special" episodes, the finale.

- [ ] Implement levels 31–40 (Episode 4: "Ramadhan & Zakat") — first episode to use `LevelData.timeLimitSeconds` (bonus-only timer) and the `ramadhanPuasa`/`zakatSedekah` quiz categories.
- [ ] Implement levels 41–50 (Episode 5: "Haji, Kisah Nabi & Akhlak Mulia"), including the level-45 "double gate" scenario (`QuizGateSpec.extraQuestions`) called out in the original design.
- [ ] Add quiz content for `hajiUmroh`, `kisahNabiLanjutan`, `asmaulHusna`, `akhlakMulia`, plus remaining `ramadhanPuasa`/`zakatSedekah` questions.
- [ ] End-to-end test of the special-episode unlock rule with real content: verify Episode 4 stays locked until Episode 1–3 are each Perfect-cleared, and Episode 5 likewise against Episode 2–4.
- [ ] Verify `AllLevelsCompleteScreen` triggers correctly on completing level 50 (`kFinalLevelId`) and not before.
- [ ] Arabic/hijaiyah text rendering in `QuizOverlay` confirmed correct on-device (font fallback), since Episode 2+ content leans more heavily on hijaiyah/harakat questions.

**Exit criteria**: all 50 levels registered and completable; a full clean playthrough (Perfect on every level) is possible end-to-end without hitting a dead end or missing asset.

## Phase 3 — Content quality & asset completion

Goal: everything currently marked placeholder/draft becomes real, reviewed content. This can run partly in parallel with Phase 1–2.

- [ ] Religious-content review pass over all of `quiz_bank.dart` (currently explicitly marked as draft/placeholder pending review) — verify correctness of every question/answer with a qualified reviewer before treating any of it as final.
- [ ] Populate `assets/sounds/sfx/` and `assets/sounds/music/` with real audio matching the six `SoundService` cues (`gameStart`, `jump`, `quizTrigger`, `answerWrong`, `answerCorrect`, `levelComplete`); the specs/prompts already exist in `requirements/sound-feature/requirement.md`. Remove or tighten the current silent-failure try/catch once assets are confirmed present, so a missing sound is caught in CI/tests instead of silently ignored.
- [ ] Add background music (currently only `assets/sounds/music/` folder is declared — confirm whether background music is actually wired into any screen, and implement it if not).
- [ ] Refresh root `SETUP.md`, which still describes a 2-level, audio-less build — bring it in line with current scope or fold its still-relevant parts (Windows Kotlin build workaround) into `docs/`.

**Exit criteria**: no `// TODO` / "placeholder" markers remain in `quiz_bank.dart`; a fresh `flutter run` produces audio for all 6 cues on a real device.

## Phase 4 — Polish, accessibility & settings

Goal: the app is comfortable for its actual target audience (children aged 3–7, per `requirement.md`) and their parents.

- [ ] Settings/options screen: music/SFX volume toggle at minimum (currently no in-app way to mute audio).
- [ ] Parental gate or simple age-appropriate confirmation before any exit-app / destructive action, if not already present.
- [ ] Touch target size audit for the on-screen move/jump controls in `HudOverlay` — confirm comfortable hit areas for young children on both the phone (Samsung A15) and tablet (Tab A9) form factors named in `requirement.md`.
- [ ] Visual/performance pass on lower-end Android devices — verify frame pacing with the full complement of parallax/decoration components (`HillsComponent`, `SceneryComponent`) active simultaneously, especially once Episode 3–5 levels add more moving components (`MovingPlatformComponent`, `PatrolObstacleComponent`, `CrumblingPlatformComponent`) per screen.
- [ ] Expand automated test coverage for scoring math (`GameAnakSoleh`'s score formula currently has no dedicated unit test — `game_progress_test.dart` covers persistence, not the live score calculation) and for the special-episode unlock rule against real Episode 3–5 data once it exists.

**Exit criteria**: no known frame-rate or input-responsiveness issues on the two reference devices; settings screen shipped; expanded test suite covers scoring logic.

## Phase 5 — Release readiness

Goal: ship a build to the Play Store.

- [ ] App signing config for release builds (`android/`), versioning strategy beyond the current `0.1.0+1`.
- [ ] Play Store listing assets (screenshots, feature graphic, description) and an age-appropriate content rating (this is a children's app — check Google Play's Families Policy requirements specifically, including any data-safety declarations even though the app currently makes no network calls and stores everything locally).
- [ ] Privacy policy covering local-only data storage (no account system, no analytics currently present) — required for Play Store submission regardless of how minimal the actual data footprint is.
- [ ] Crash reporting / diagnostics decision: currently there is none. Decide whether to add one (e.g. Firebase Crashlytics) and if so, make sure it's disclosed appropriately given the children's-app context, or explicitly decide to ship without any telemetry.
- [ ] Final QA pass across the full 50-level campaign on both reference devices.

**Exit criteria**: signed release build installable from the Play Store (or ready for submission), with required store metadata and policy documents in place.

## Phase 6 — Post-launch ideas (not yet scoped)

Speculative directions worth evaluating once the core 50-level campaign has shipped and has real player feedback. None of these are committed — flag with the user/product owner before starting any of them:

- Additional episodes/levels beyond 50 (the unlock-rule code already generalizes past 5 episodes, so this is a content-only extension).
- Replayability features: daily challenge mix of quiz categories, achievements/badges beyond the existing "Perfect" star.
- Optional cloud save / cross-device sync (would be the first feature requiring any backend — currently zero network dependencies in the app, so this is a meaningful architecture decision, not just a feature toggle).
- iOS release (currently Android-only end to end, including icon/splash tooling config) — would need its own asset generation pass, device testing, and App Store's own children's-app policy review.
- Localization beyond Indonesian, if there's demand outside the current target market.
- A simple parent-facing dashboard (progress overview, content review) — natural extension of the "clean episode" tracking already in `GameProgress`.
