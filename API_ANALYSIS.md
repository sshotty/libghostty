# libghostty & flterm API Surface Analysis

**Date**: 2026-07-04
**Packages**: `libghostty` v0.0.10, `flterm` v0.0.4 (submodule at `packages/libghostty`)
**Dependency**: `flterm` via path, `libghostty` via path (dependency override)

---

## Architecture

```
sshotty (ui/) 
  ├── imports flterm (11 files)
  │     └── flterm re-exports ~28 types from libghostty
  └── imports libghostty directly (1 file — sshotty_logger.dart)
```

`flterm` is a Flutter widget layer on top of `libghostty`. The app imports `flterm` for terminal rendering and `libghostty` only for the process-global logger.

---

## 1. APIs USED by sshotty

### 1.1 From flterm (via `package:flterm/flterm.dart`)

| API | Kind | Used In | How |
|-----|------|---------|-----|
| `TerminalTheme` | class | terminal_themes.dart, custom_theme_provider.dart, local_terminal_view.dart, terminal_view.dart, theme_picker.dart | Constructed with palette/cursor/selection. Passed to TerminalView. Fields accessed: .background, .foreground, .palette, .fontFamily, .fontSize, .backgroundOpacity, .boldIsBright |
| `ColorPalette` | class | terminal_themes.dart, custom_theme_provider.dart | Constructed with ansiColors, background, foreground. Fields: .ansiColors, .background, .foreground, indexed access `[1]`-`[6]` |
| `CursorTheme` | class | terminal_themes.dart, custom_theme_provider.dart | Constructed with color, shape, blinkInterval. Fields: .color, .shape |
| `SelectionTheme` | class | terminal_themes.dart, custom_theme_provider.dart | Constructed with background |
| `DynamicColor.fixed()` | static method | terminal_themes.dart, custom_theme_provider.dart | Creates DynamicColor from a fixed Color |
| `CursorShape` | enum | cursor_provider.dart, cursor_type_picker.dart, terminal_themes.dart | `.block`, `.underline`, `.bar`, `.blockHollow`, `.values`, `.name` |
| `TerminalController` | class | pane_presentation_provider.dart, retained_terminal_provider.dart, find_on_page_panel.dart, image_paste_handler.dart, auto_reconnect_service.dart, crash_recovery.dart | Constructed (no-arg or with config). Methods: write(), dispose(), createFormatter(), clear(), setSearchHighlights(), scrollToTop(), pasteImage(), terminal. Properties: onBell, onOutput, onResize |
| `TerminalScrollController` | class | pane_presentation_provider.dart, retained_terminal_provider.dart | Constructed. Methods: dispose(), jumpTo(). Properties: hasClients, position |
| `TerminalConfig` | class | retained_terminal_provider.dart | Constructed with scrollbackLimit, scrollToBottom |
| `ScrollToBottom` | enum | retained_terminal_provider.dart | `.both` |
| `TerminalConnectionState` | enum | pane_presentation_provider.dart, retained_terminal_provider.dart | `.failed`, `.disconnected`, `.connecting`, `.connected` |
| `TerminalView` | widget | local_terminal_view.dart, terminal_view.dart | Constructed with controller, theme, padding, focusNode, scrollController, autofocus, linkSettings |
| `LinkSettings` | class | local_terminal_view.dart, terminal_view.dart | Constructed (`const LinkSettings()`) |
| `Searcher` | class | find_on_page_panel.dart | Constructed with `Terminal`. Method: search(query) |
| `SearchHit` | class | find_on_page_panel.dart | Fields: .row, .col |
| `Formatter` | class | auto_reconnect_service.dart, crash_recovery.dart | From createFormatter(). Methods: format(), dispose() |
| `FormatterFormat` | enum | auto_reconnect_service.dart, crash_recovery.dart | `.plain` |

### 1.2 From libghostty (via `package:libghostty/libghostty.dart`)

| API | Kind | Used In | How |
|-----|------|---------|-----|
| `LibGhostty.setLogger()` | static method | sshotty_logger.dart | Installs global logger callback |
| `SysLogLevel` | enum type | sshotty_logger.dart | Type of `level` param in logger callback |

---

## 2. flterm APIs EXPORTED but NOT USED

From the flterm barrel (`flterm.dart`) — the app only uses 17 of ~50 exported types.

| Exported Type | Kind | Why Unused |
|--------------|------|------------|
| `DeviceAttributesResponse` | class (re-exported from libghostty) | Terminal device attribute parsing, not needed |
| `FormatterExtra` | class | Extra formatter options, not used |
| `GridRef` | class (re-exported) | Grid coordinate reference, not accessed directly |
| `Key` | enum (re-exported) | Raw key codes, input handling via TerminalController |
| `Mods` | class (re-exported) | Key modifiers, not accessed |
| `MouseTracking` | enum (re-exported) | Mouse tracking mode, not configured |
| `PointTag` | enum (re-exported) | Point tagging, internal libghostty detail |
| `Position` | class (re-exported) | Cursor position type, not used |
| `Scrollbar` | enum (re-exported) | Scrollbar visibility, not configured |
| `Selection` | class (re-exported) | Selection state, not accessed directly |
| `SelectionGestureBehavior` | enum (re-exported) | Gesture behavior, not configured |
| `SelectionGestureBehaviors` | class (re-exported) | All gesture behaviors, not configured |
| `TerminalMode` | enum (re-exported) | Terminal mode flags, not accessed |
| `TerminalScreen` | enum (re-exported) | Screen buffer selection, not used |
| `UnderlineStyle` | enum (re-exported) | Underline style, not configured |
| `initializeForWeb` | function (re-exported) | Web-specific init, not called (desktop app) |
| `OnResize` | typedef | Resize callback type, controller handles it |
| `CellRange` | class | Cell range, not used |
| `KeyboardState` | class | Keyboard modifier state, not accessed |
| `MouseAutoHide` | class | Mouse auto-hide config, not configured |
| `GestureModifier` | enum | Gesture modifier keys, not configured |
| `LineSelectMode` | enum | Line selection mode, not configured |
| `TerminalGestureSettings` | class | Gesture settings, not configured |
| `TerminalSelectionShape` | enum | Selection shape, not configured |
| `HyperlinkStyle` | class | Hyperlink text style, not configured |
| `HyperlinkTheme` | class | Hyperlink theme, not configured |
| `ActivationModifier` | class | Link activation modifier, not configured |
| `ActivatedLink` | class | Activated link info, not used |
| `LinkHighlightMode` | enum | Link highlight mode, not configured |
| `LinkRule` | class | Link detection rule, `LinkSettings` default used instead |
| `LinkType` | enum | Link type discriminator, not used |
| `LinkedFile` | class | Linked file info, not used |
| `TerminalScope` | widget | Terminal scope widget, not used |
| `TerminalScrollPosition` | enum | Scroll position type, not used |

**Total unused from flterm barrel**: ~35 of ~50 exported types/classes/enums.

---

## 3. libghostty APIs EXPORTED but NOT USED

From the libghostty barrel (`libghostty.dart`) — the app only uses 2 of ~80 exported symbols.

### 3.1 Re-exported through flterm (used transitively via flterm barrel)

These are used by the app but imported through `package:flterm/flterm.dart`, not directly:
- `CursorShape`, `DeviceAttributesResponse`, `Formatter`, `FormatterExtra`, `FormatterFormat`, `GridRef`, `Key`, `Mods`, `MouseTracking`, `PointTag`, `Position`, `Scrollbar`, `Selection`, `SelectionGestureBehavior`, `SelectionGestureBehaviors`, `TerminalMode`, `TerminalScreen`, `UnderlineStyle`, `initializeForWeb`

Some of these are USED (CursorShape, Formatter, FormatterFormat). Others are NOT used even transitively.

### 3.2 Directly exported from libghostty but NEVER used

These are types exported in the libghostty barrel that are never referenced, even transitively:

| Exported Type | Kind | Notes |
|--------------|------|-------|
| `DecodedImage` | class | Kitty image protocol — internal |
| `PngDecoder` | class | Png decoding — internal |
| `CellColor` | class | Cell color type — not used |
| `CellWidth` | enum | Cell width — not used |
| `DefaultColor` | enum | Default color — not used |
| `DeviceAttributesPrimary` | class | Terminal attributes — not queried |
| `DeviceAttributesSecondary` | class | Same |
| `DeviceAttributesTertiary` | class | Same |
| `InvalidValueException` | class | Exception type — not caught |
| `LibGhosttyException` | class | Base exception — not caught |
| `MouseEncoderSize` | enum | Mouse encoding — not used |
| `MouseFormat` | enum | Mouse format — not used |
| `NamedColor` | class | Named color — not used |
| `OptimizeMode` | enum | Render optimization — not configured |
| `OutOfMemoryException` | class | OOM error — not caught |
| `PaletteColor` | class | Palette color — not used |
| `RgbColor` | class | RGB color — not used |
| `SemanticContent` | enum | Semantic content type — not used |
| `SemanticPrompt` | enum | Semantic prompt type — not used |
| `SgrAttribute` | class | SGR attribute — not used |
| `TerminalColors` | class | Terminal colors — not used |
| `TerminalSizeInfo` | class | Terminal size info — not used |
| `ColorScheme` | enum | Color scheme — not used |
| `FocusEvent` | enum | Focus event — not used |
| `KittyImageCompression` | enum | Kitty image compression — internal |
| `KittyImageFormat` | enum | Kitty image format — internal |
| `KittyPlacementLayer` | enum | Kitty placement — internal |
| `ModeReportState` | enum | Mode report — not used |
| `MouseAction` | enum | Mouse action — not used |
| `MouseButton` | enum | Mouse button — not used |
| `OptionAsAlt` | enum | Option key behavior — not used |
| `OscCommandType` | enum | OSC command type — internal |
| `SelectionAdjust` | enum | Selection adjustment — not used |
| `SelectionGestureAutoscroll` | enum | Autoscroll — not used |
| `SelectionGestureEventOption` | enum | Gesture option — not used |
| `SelectionOrder` | enum | Selection order — not used |
| `SgrAttributeTag` | enum | SGR attribute tag — internal |
| `SizeReportStyle` | enum | Size report — not used |
| `TerminalScreen` | enum | Screen buffer — not used |
| `LibGhosttyBuildInfo` | class | Build info — not used |
| `FocusEventEncode` | class | Focus encode — not used |
| `SizeReportStyleEncode` | class | Size encode — not used |
| `KittyKeyFlags` | class | Kitty key flags — internal |
| `OscCommand` | class | OSC command — internal |
| `OscParser` | class | OSC parser — internal |
| `pasteEncode` | function | Paste encode — not called (uses controller.pasteImage) |
| `pasteIsSafe` | function | Paste safety check — not called |
| `SgrParser` | class | SGR parser — internal |
| `LogCallback` | typedef | Logger callback type — used implicitly via LibGhostty.setLogger |
| `CellIterator` | class | Cell iteration — not used |
| `Cursor` | class | Cursor state — not used directly |
| `DirtyState` | enum | Dirty state — internal |
| `KeyEncoder` | class | Key encoder — not used directly |
| `KeyEvent` | class | Key event — not used directly |
| `KittyGraphics` | class | Kitty graphics — internal |
| `KittyImage` | class | Kitty image — internal |
| `MouseEncoder` | class | Mouse encoder — not used |
| `MouseEvent` | class | Mouse event — internal |
| `Placement` | class | Image placement — internal |
| `RenderInfo` | class | Render info — internal |
| `RenderState` | class | Render state — internal |
| `RowIterator` | class | Row iteration — not used |
| `RowSelectionRange` | class | Row selection — not used |
| `SelectionGesture` | class | Selection gesture — internal |
| `SelectionGestureBehaviors` | class | Gesture behaviors — not configured |
| `SelectionGestureEvent` | class | Gesture event — internal |
| `SelectionGestureGeometry` | class | Gesture geometry — internal |
| `SelectionGestureState` | class | Gesture state — internal |
| `Terminal` | class | Core terminal — accessed via controller.terminal only |
| `TrackedGridRef` | class | Tracked grid reference — internal |
| `TerminalMode` | class | Terminal mode — not accessed |
| `Listenable` | mixin | Listenable mixin — internal |

**Total unused from libghostty barrel**: ~70 of ~80 exported symbols.

---

## 4. Summary

| Package | Exported | Used (directly) | Used (via flterm re-export) | Unused |
|---------|----------|----------------|----------------------------|--------|
| **flterm** | ~50 types | 17 types | N/A | ~33 types |
| **libghostty** | ~80 types | 2 types | ~8 types (CursorShape, Formatter, FormatterFormat, etc.) | ~70 types |

### What to do about unused libghostty/flterm exports

**Unlike dartssh2**, the unused libghostty/flterm APIs are **internal to the vendored package**, not added by sshotty. The barrel exports are set by upstream. Removing them would mean maintaining a fork with a trimmed barrel, which has no practical benefit since these are vendored packages that get compiled together with the app anyway — tree-shaking during Flutter's build removes unused code at the binary level.

**Recommendation**: Do NOT trim the barrel exports. Unlike dartssh2 where removing unused modules saved compilation time and binary size, libghostty is a C FFI native asset package. The Dart types are just bindings; tree-shaking already handles them. Focus should be on:

1. **Actually using more features**: Link detection (`LinkRule`), hyperlink theme customization (`HyperlinkTheme`, `HyperlinkStyle`), gesture settings
2. **Nothing to remove**: sshotty didn't add any custom changes to libghostty or flterm — the submodule is at upstream with no sshotty-specific commits
