# flterm/libghostty Integration Plan: Wireable Features

**Date**: 2026-07-04

---

## Features Worth Integrating

### Phase 1: Link Configuration (2-3h)

**Current state**: `TerminalView` receives `linkSettings: widget.linkSettings ?? const LinkSettings()`. The `LinkSettings` default enables basic URL detection but nothing custom.

**Wireable features**:

| Feature | flterm API | Value | Effort |
|---------|-----------|-------|--------|
| Custom link rules | `LinkRule`, `LinkSettings.customRules` | **Medium** — users can add patterns like `JIRA-123`, internal URLs | 1h |
| Link activation modifier | `ActivationModifier` | **Medium** — Ctrl+Click vs Click-to-open, match native terminal behavior | 30min |
| Hyperlink theming | `HyperlinkTheme`, `HyperlinkStyle` | **Low-Medium** — style visited/unvisited hyperlinks differently | 30min |
| Link highlight mode | `LinkHighlightMode` | **Low** — choose between underline, background, or both | 15min |
| URL overlay (finish) | `url_overlay.dart` | **Medium** — tap plain-text URLs in terminal buffer | 2-3h |

**Integration steps**:

```
Step 1.1 — Link activation modifier (30 min)
  File: terminal_view.dart, local_terminal_view.dart
  Change: Pass TerminalView(linkSettings: LinkSettings(modifier: ActivationModifier.control))
  Effect: Ctrl+Click to open links (standard terminal convention)
  Config: Add to TerminalConfig in retained_terminal_provider, persist in SharedPreferences

Step 1.2 — Hyperlink theme (30 min)
  File: terminal_themes.dart
  Change: Add HyperlinkTheme to built-in themes
    HyperlinkTheme(
      urlStyle: HyperlinkStyle(color: linkColor, underline: true),
      visitedStyle: HyperlinkStyle(color: linkColor.withOpacity(0.7)),
    )
  Wire: Pass to TerminalTheme(hyperlinkTheme: ...)

Step 1.3 — Custom link rules (1h)
  File: host form or link settings screen
  Change: Add "Link Rules" section (list of regex patterns)
  Storage: LinkRules in SharedPreferences or DB
  Wire: Build LinkSettings(customRules: rules) from stored patterns

Step 1.4 — URL overlay completion (2-3h)
  File: url_overlay.dart
  Change: Instead of pass-through, scan buffer for URL patterns,
          render tap targets over detected positions using cell metrics,
          open URLs on tap via UrlLauncher
  Note: This is the most complex item — requires coordinate mapping
```

**Total Phase 1**: 3-5h

---

### Phase 2: Mouse & Cursor Behavior (2-3h)

**Current state**: `TerminalView` receives no `mouseAutoHide` or `gestureSettings`.

**Wireable features**:

| Feature | flterm API | Value | Effort |
|---------|-----------|-------|--------|
| Mouse auto-hide config | `TerminalView(mouseAutoHide:)` | **Medium** — terminal users expect mouse to hide on keystroke | 30min |
| Cursor blink config | `TerminalConfig(cursorBlink:, cursorBlinkInterval:)` | **Medium** — some users prefer no blinking cursor | 30min |
| Gesture settings | `TerminalGestureSettings` | **Low** — fine-tune triple-click selection, word characters | 1h |
| Cursor position in status bar | `controller.terminal.cursor` | **Medium** — show "Row 42, Col 15" in status line | 1h |

**Integration steps**:

```
Step 2.1 — Mouse auto-hide (30 min)
  File: terminal_view.dart, local_terminal_view.dart
  Change:
    TerminalView(
      mouseAutoHide: MouseAutoHide.onInput,  // explicit default
    )
  Config: Add toggle in terminal settings → persist in SharedPreferences
  Values: onInput (default), never, always

Step 2.2 — Cursor blink (30 min)
  File: retained_terminal_provider.dart → _createController()
  Change:
    TerminalConfig(
      scrollbackLimit: _defaultTerminalScrollbackBytes,
      scrollToBottom: ScrollToBottom.both,
      cursorBlink: true,  // from settings
      cursorBlinkInterval: Duration(milliseconds: 500),  // from settings
    )
  Config: Add "Blinking cursor" toggle in terminal settings
  Persistence: CursorProvider (already exists, currently only saves CursorShape)

Step 2.3 — Cursor position in status bar (1h)
  File: terminal_view.dart or status bar widget
  Change:
    StreamBuilder(
      stream: controller.onCursorPosition,  // check if available
      builder: (ctx, snap) => Text('Row ${snap.data?.row} Col ${snap.data?.col}'),
    )
  If no stream exists, poll controller.terminal.cursor on a timer
  Display: "42:15" in bottom-right corner of terminal pane
```

**Total Phase 2**: 2-3h

---

### Phase 3: TerminalConfig Expansion (1-2h)

**Current state**: `TerminalConfig` only passes `scrollbackLimit` and `scrollToBottom`.

**Wireable features**:

| Feature | flterm API | Value | Effort |
|---------|-----------|-------|--------|
| Terminal size | `TerminalConfig(cols:, rows:)` | **Medium** — set initial terminal dimensions | 15min |
| Kitty image storage | `TerminalConfig(kittyImageStorageLimit:)` | **Low** — cap image memory if Kitty protocol is used | 15min |
| Terminal modes | `TerminalConfig(modes:)` | **Low** — disable features like alt-screen scroll, numlock | 30min |
| Scroll physics | `TerminalView(scrollPhysics:)` | **Low** — overscroll behavior | 15min |

**Integration steps**:

```
Step 3.1 — Initial terminal size (15 min)
  File: retained_terminal_provider.dart → _createController()
  Change:
    TerminalConfig(
      scrollbackLimit: _defaultTerminalScrollbackBytes,
      scrollToBottom: ScrollToBottom.both,
      cols: defaultTerminalCols,  // from host config or global default (80)
      rows: defaultTerminalRows,  // from host config or global default (24)
    )
  Effect: Terminal starts at configured size instead of relying on resize events

Step 3.2 — Kitty image storage (15 min)
  File: same as above
  Change: Add kittyImageStorageLimit: 64 * 1024 * 1024 (explicit default)
  Value: Caps Kitty image memory to prevent OOM from malicious images
```

**Total Phase 3**: 1-2h

---

### Phase 4: Scrollback & Formatting (1-2h)

**Current state**: `FormatterFormat.plain` used for scrollback export. No HTML or other formats.

**Wireable features**:

| Feature | flterm API | Value | Effort |
|---------|-----------|-------|--------|
| HTML export | `FormatterFormat.html` | **Medium** — export terminal content as styled HTML | 1h |
| FormatterExtra options | `FormatterExtra` | **Low** — include/exclude certain content in exports | 30min |
| Search hit navigation | `terminal.scrollToHighlight()` | **Medium** — keyboard nav between search results | 1h |

**Integration steps**:

```
Step 4.1 — HTML export (1h)
  File: auto_reconnect_service.dart, crash_recovery.dart
    (or new "Export as HTML" menu item)
  Change:
    final formatter = controller.createFormatter(format: FormatterFormat.html);
    final html = formatter.format();
    // Save to file or clipboard
  UI: Add "Copy as HTML" in terminal context menu

Step 4.2 — Search navigation (1h)
  File: find_on_page_panel.dart
  Change: Add keyboard shortcuts for Next/Previous search hit
  Use: controller.scrollToHighlight() for smooth scrolling between matches
```

**Total Phase 4**: 1-2h

---

### Phase 5: Advanced Rendering (2-3h)

**Current state**: Custom font via theme but no `fontData`, no custom shortcuts.

**Wireable features**:

| Feature | flterm API | Value | Effort |
|---------|-----------|-------|--------|
| Custom font data | `TerminalView(fontData:)` | **Low** — exact font metrics from TTF/OTF bytes | 1h |
| Custom shortcuts | `TerminalView(shortcuts:)`, `TerminalShortcutScope` | **Low** — app-specific keybinds | 1-2h |
| Image paste callback | `TerminalView.onImagePaste` | **Low** — already handled by ImagePasteHandler widget | — |

---

## Priority Matrix

| Phase | Effort | Impact | Risk | Recommended |
|-------|--------|--------|------|-------------|
| 1: Link config | 3-5h | Medium | Low | **Week 1** |
| 2: Mouse & cursor | 2-3h | Medium | Low | **Week 1** |
| 3: Config expansion | 1-2h | Low-Medium | Low | **Week 2** |
| 4: Scrollback/formatting | 1-2h | Medium | Low | **Week 2** |
| 5: Advanced rendering | 2-3h | Low | Medium | Defer |

## Recommended Sprint Order

```
Sprint 1 (Week 1): Phase 1(link modifier + hyperlink theme) + Phase 2(mouse+blink+cursor)
Sprint 2 (Week 2): Phase 1(custom rules + url overlay) + Phase 3(config expansion)
Sprint 3 (Week 3): Phase 4(HTML export + search nav)
Future: Phase 5(advanced rendering, custom shortcuts)
```

## Key Files to Modify

| File | Phase | Change |
|------|-------|--------|
| `terminal_view.dart` | 1, 2 | Pass linkSettings, mouseAutoHide, gestureSettings to TerminalView |
| `local_terminal_view.dart` | 1, 2 | Same changes |
| `retained_terminal_provider.dart` | 2, 3 | Expand TerminalConfig with cursorBlink, cols/rows, etc. |
| `terminal_themes.dart` | 1 | Add HyperlinkTheme to built-in themes |
| `custom_theme_provider.dart` | 1 | Add HyperlinkTheme serialization |
| `url_overlay.dart` | 1 | Full URL tap-overlay implementation |
| `find_on_page_panel.dart` | 4 | Search hit keyboard navigation |
| `cursor_provider.dart` | 2 | Extend to store blink settings |
| `terminal_theme.dart` / `theme_picker.dart` | 1 | Hyperlink preview in theme picker |
