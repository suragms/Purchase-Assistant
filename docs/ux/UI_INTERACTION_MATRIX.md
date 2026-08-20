# UI Interaction Matrix — PurchaseAssistant

This document details the interaction states, mouse cursor behavior, keyboard navigation accessibility, and touch gesture handling across all interactive components in the application.

---

## Interactive Control Matrix

| Control Category | Control Name | Default State | Hover State (Desktop) | Focus State | Pressed / Active State | Disabled State | Loading State | Error State | Keyboard Shortcuts | Touch Behavior |
|---|---|---|---|---|---|---|---|---|---|---|
| **Primary Buttons** | `AppPrimaryButton`, `FilledButton` | Hexa primary color background, white bold text, 16px radius, min 48px height. | Darkened primary background, `SystemMouseCursors.click`, subtle scale (1.01). | 2px primary focus ring around border. | Scale down (0.98), dark active background. | Muted grey background (`HexaColors.gray300`), white text, disabled cursor. | Centered white `CircularProgressIndicator(20px)`, button disabled. | Red border, error shake animation if invalid. | `Enter` or `Space` triggers `onPressed`. | Min 48px touch height, haptic feedback on save. |
| **Secondary Buttons** | `AppSecondaryButton`, `OutlinedButton` | Transparent/white background, primary border and text. | Light primary tint background (`HexaColors.brandPrimary.withAlpha(0.08)`), click cursor. | 2px primary focus ring. | Darker tint background, active press depth. | Grey border and text, disabled cursor. | Muted spinner inside button. | Red border, red error text. | `Enter` or `Space` triggers `onPressed`. | Min 48px touch target. |
| **Icon Buttons** | `IconButton` | Transparent background, 24px icon, 48px padded target. | Circle hover fill (`HexaColors.gray100`), click cursor. | Focus halo around icon circle. | Scale down (0.95), dark tint. | Grey icon (alpha 0.38), disabled. | Replaced by 20px `CircularProgressIndicator`. | Red icon color. | `Enter` or `Space` activates. | Min 48px tap region. |
| **Input Fields** | `AppTextField`, `TextField`, `TextFormField` | Grey fill (`#F3F4F6`), 16px radius, grey border, hint text. | Border darkens to `HexaColors.gray400`, `SystemMouseCursors.text`. | 1.5px primary border, floating label active, cursor visible. | Text selection active, handles visible. | Light grey background, muted text, non-editable. | Read-only mode or suffix spinner. | 1.5px red border, red error text below field. | `Tab` / `Shift+Tab` to move focus, `Enter` to submit form. | Tap focuses field and opens soft keyboard; drag dismisses keyboard. |
| **Autocomplete / Search** | `PartyInlineSuggestField`, `HexaElevatedAutocomplete` | Text input + search icon. | Border hover tint, click cursor on suggestion rows. | Focus opens suggestion overlay portal below field. | Highlighted active suggestion row. | Non-interactive field. | Suffix spinner while fetching suggestions. | "No matches found" or error banner inside overlay. | `Arrow Down` / `Arrow Up` navigates options, `Enter` selects, `Esc` closes. | Single tap on suggestion commits selection and closes overlay immediately. |
| **Dropdown Selects** | `DropdownButtonFormField`, `SearchPickerSheet` | Filled container + down arrow icon + current value label. | Hover tint on container, click cursor. | Primary focus border. | Dropdown menu opens or bottom sheet slides up. | Disabled dropdown styling. | "Loading options..." placeholder. | Red border, error message below. | `Space` / `Enter` opens menu, `Arrow Keys` navigate, `Enter` confirms. | Tap opens `SearchPickerSheet` or bottom picker on mobile. |
| **Table Rows** | Data table rows (Stock, Catalog, Purchases) | Alternating row background or white surface. | Background light blue/grey (`HexaColors.gray50`), `SystemMouseCursors.click`. | Keyboard focus outline on row. | Active row highlight, detail pane opens. | Dimmed opacity (0.5) for archived/deleted rows. | Skeleton placeholder row. | Red error indicator on row. | `Arrow Up` / `Arrow Down` navigates rows, `Enter` opens detail. | Tap opens detail page or master-detail pane. |
| **Filter Chips** | `HexaAccessibleFilterChip`, `FilterChip` | Unselected grey pill or selected primary pill. | Hover tint on chip, click cursor. | Focus border around chip. | Active selection toggle. | Greyed-out chip. | N/A | N/A | `Space` / `Enter` toggles selection. | Tap toggles selection; Wrap layout prevents horizontal scroll overflow. |
| **Tabs** | `TabBar`, `ChoiceChip` tabs | Muted text, transparent background. | Underline or pill hover background, click cursor. | Focus indicator around active tab. | Tab switches content view with transition. | Disabled tab. | Tab content skeleton. | Error badge on tab header if fetch fails. | `Arrow Left` / `Arrow Right` switches tabs. | Tap switches active tab, swipe on `TabBarView`. |
| **Modal Sheets** | `showHexaBottomSheet` host | Darkened backdrop (`Colors.black54`), top-rounded container. | Drag handle hover state. | Auto-focuses first input field in sheet. | Sheet slides down on drag. | Non-dismissible during save (`PopScope.canPop = false`). | Loading overlay or skeleton inside sheet. | Inline error banner or toast. | `Esc` key closes sheet (if dirty, shows discard confirm). | Swipe down on drag handle to dismiss; tap backdrop to close. |

---

## Keyboard Navigation & Focus Accessibility Rules

1. **Focus Traversal Chain:** Every form must wrap inputs in `FocusTraversalGroup(policy: OrderedTraversalPolicy())` or rely on `KeyboardSafeFormViewport`. Pressing `Tab` moves focus sequentially from top to bottom, left to right.
2. **Submit on Enter:** Single-line form fields must handle `textInputAction: TextInputAction.next` or `TextInputAction.done`. Submitting the final field triggers primary action `onSubmitted`.
3. **Escape Key Handling:** Pressing `Esc` must close active autocomplete overlays, dialogs, or modal sheets. If unsaved form changes exist, `Esc` triggers a "Discard unsaved changes?" confirmation dialog before popping.
4. **Autocomplete Overlay Navigation:**
   - `Arrow Down`: Highlights next suggestion item in overlay.
   - `Arrow Up`: Highlights previous suggestion item in overlay.
   - `Enter`: Selects highlighted suggestion item, populates field, and **closes overlay**.
   - `Esc`: Closes overlay without altering field text.
5. **No Duplicate Submissions:** Primary submit buttons must set `onPressed: _loading ? null : _submit` to disable the button during active async network requests, preventing rapid double-click duplicate API calls.

---

## Touch Interaction & Mobile Gesture Rules

1. **Touch Target Size:** All touchable widgets (buttons, icon buttons, list rows, filter chips, checkboxes) must maintain a minimum touch target area of **48x48 dp**.
2. **Keyboard Dismissal:** Tapping outside input fields or scrolling the page must execute `FocusManager.instance.primaryFocus?.unfocus()` or `ScrollViewKeyboardDismissBehavior.onDrag`.
3. **Single Tap Commit:** Tapping a search suggestion or autocomplete row must commit the selection in a **single tap**. Tapping must not require a second confirmation tap.
4. **Haptic Feedback:** Main tab navigation and primary save actions trigger `HapticFeedback.selectionClick()` or `HapticFeedback.mediumImpact()`.
