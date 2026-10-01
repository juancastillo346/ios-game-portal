# GamePortal · iOS starter

A native SwiftUI portal with a bundled HTML/JavaScript Tic-Tac-Toe game. Two people can play on one phone without a server or account.

## Run

1. Open `GamePortal.xcodeproj` in Xcode.
2. Select the **GamePortal** scheme and an iPhone simulator.
3. Press **⌘R**. If no simulator is available, install an iOS runtime in Xcode → Settings → Components.

Requires Xcode with an iOS SDK; deployment target is iOS 17. No packages, API keys, or paid developer account are needed for the simulator. A physical phone requires your own signing team in Xcode.

## Demo flow

1. Enter your name and choose **Play as guest**.
2. In **Discover**, choose Tic-Tac-Toe → **Choose mode**.
3. Enter two player names and **Start match**.
4. Make a move, pass the phone, then tap the next player's confirmation.
5. Open **My Matches** to resume the same match. Closing and reopening the app preserves the board and pending handoff.
6. Complete a row, column, or diagonal. The game finishes and appears under **Finished**. Draws are also detected.
7. Open a finished match to inspect its board or hide it from this device.

## What each file does

- `GamePortalApp.swift`: entry point and native screens: Welcome, Discover, setup, My Matches, match and handoff.
- `Match.swift`: match data, legal move checks, turn changes, win/draw detection.
- `PortalStore.swift`: guest profile and matches; atomically saves JSON to the app's Documents directory after changes.
- `GameWebView.swift`: restricted WebView and JSON message bridge. Only the bundled page can navigate; no native account credentials are exposed.
- `Game/`: board presentation and move proposals, using HTML/CSS/JavaScript.
- `GamePortalTests/main.swift`: executable tests of moves, handoffs, results, and disk round-trip persistence.

## Interface with the game

The native container sends `state_change` with `state.board`, `turn_of_user`, `my_user`, and `players`. Seats are indexed 0 and 1; `turn_of_user` is null after the match ends.

The game responds with `make_move`, `turn_of_player_index`, and `next_state.board`. **Local assumption:** `turn_of_player_index` identifies the player proposing the move. The slide's illustrative payload does not fully define this field; confirm its meaning with the other workstreams before integration.

The native app compares the proposed board with its saved state, accepts exactly one legal empty-square placement by the current player, computes the result, and saves. Turn handoffs block additional moves until confirmed.

Tic-Tac-Toe validation currently lives in `Match.swift`. Supporting arbitrary game packages will require a shared rules/validation interface; merely replacing the HTML is not sufficient. The WebView is restricted for this bundled sample, but externally generated game packages need a further security review.

## Scope and next handoff

Implemented: local guest identity, one discoverable game, two-player setup, playable embedded board, turn privacy overlay, saved active/finished matches, resume and hide-finished behavior.

Not implemented yet: backend accounts, remote matches, shared lobbies, invitations, spectator mode, computer opponents, push notifications, remote offline queues, localization, or downloaded game packages. The guest identity is local, not server authentication. The handoff overlay demonstrates the portal interaction; Tic-Tac-Toe itself has no secret hands.

For the next iOS presenter:

1. Agree on game-package metadata and JSON message semantics with GameBuilder.
2. Agree on match creation/join/move endpoints and version handling with the backend workstream.
3. Add a network service alongside local storage and complete a move visible on a second client.

## Verification commands

```sh
xcodebuild -project GamePortal.xcodeproj -scheme GamePortal -sdk iphonesimulator -configuration Debug -derivedDataPath /tmp/gameportal-build CODE_SIGNING_ALLOWED=NO build
swiftc -module-cache-path /tmp/gameportal-swift-cache GamePortal/Match.swift GamePortalTests/main.swift -o /tmp/gameportal-tests
/tmp/gameportal-tests
```

For a presentation, distinguish implemented local behavior from planned shared-backend behavior. Explain the files and credit AI assistance accurately.

### Verified October 1, 2026

- Simulator build and UI-test bundle compile successfully with Xcode 26.4.1.
- Rules tests pass for valid/invalid moves, mandatory handoff, all winning lines, draws, completed games, and JSON disk persistence.
- The end-to-end UI test passed on iPhone 17 Pro / iOS 26.4.1: start a match, make a move, restart the app, resume the pending handoff, verify an occupied square is disabled, complete an X win, and find it under Finished.
- The first UI run failed waiting for the initial handoff; a diagnostic rerun and a final run with diagnostics removed both passed without a game-logic change. Treat that initial failure as an intermittent test/runtime issue, not a confirmed fix. Rehearse the flow before presenting.

Run the UI test in Xcode with **⌘U**. The test creates local sample matches. It expects the guest name Juan, so use a fresh simulator installation if you have already entered a different guest name.
