# UNIVERSAL UI/UX DESIGN RULES
## Product Design System — Desktop + Mobile + Every Screen

> **Core philosophy:** Less is more. Simplicity is the goal. Every design decision must have a reason.
>
> Design for the user's **context, screen, task, environment, motivation, expectations, and available actions** — not for the designer's preference.
>
> A beautiful interface that is difficult to understand or operate is not good UI.

---

# 0. THE NORTH STAR

## The product must feel:

- Simple
- Useful
- Calm
- Predictable
- Fast
- Focused
- Easy to learn
- Easy to operate
- Easy to recover from mistakes
- Appropriate to the user's situation
- Consistent without becoming rigid

## Core rule

> **Do not ask: "How can we fit everything on this screen?"**
>
> Ask: **"What does this user need to accomplish here, right now?"**

---

# 1. DESIGN FOR THE REAL USER CONTEXT

Before designing or changing a screen, understand:

### Who is the user?

- New user
- Returning user
- Expert/power user
- Staff/operator
- Manager
- Admin
- Customer
- Mobile user
- Desktop user

### Why are they using the app?

Are they:

- Trying to complete a task quickly?
- Searching for information?
- Entering data?
- Checking a status?
- Fixing an error?
- Making a decision?
- Under time pressure?
- Repeating a routine operation?
- Learning the product?
- Comparing information?
- Browsing?
- Lost and looking for direction?

### What state might the user be in?

The user may be:

- Stressed
- Busy
- Distracted
- Bored
- Tired
- In a hurry
- Unfamiliar with the system
- Already familiar with the system
- Recovering from an error
- Looking for one specific thing

The UI must still communicate clearly under these conditions.

---

# 2. DESIGN FROM USER MOTIVATION, NOT FEATURES

Never begin with:

> "We have these 20 features, so put all 20 on the screen."

Begin with:

> "What is the user trying to accomplish?"

Then determine:

```text
USER GOAL
    ↓
USER CONTEXT
    ↓
USER TASK
    ↓
REQUIRED INFORMATION
    ↓
AVAILABLE ACTIONS
    ↓
PRIMARY ACTION
    ↓
SUPPORTING ACTIONS
    ↓
SUCCESS / COMPLETION STATE
```

Features should follow the user's workflow.

The workflow should NOT be forced to follow the application's internal architecture.

---

# 3. LESS IS MORE

## The principle

Every visible element competes for attention.

Remove anything that does not help the user:

- Understand
- Decide
- Navigate
- Act
- Confirm
- Recover

### Remove:

- Decorative containers
- Unnecessary cards
- Repeated headings
- Duplicate actions
- Redundant descriptions
- Excessive icons
- Excessive borders
- Unnecessary shadows
- Unnecessary animations
- Repeated confirmations
- Unnecessary fields
- Unnecessary steps
- Unnecessary scrolling
- Empty states with no useful guidance
- Information that can be inferred
- Controls that rarely matter

### Important

> **Less does NOT mean removing useful functionality.**
>
> It means removing unnecessary cognitive and visual complexity.

---

# 4. EVERY SCREEN MUST HAVE A PURPOSE

Every screen must answer:

1. Why does this screen exist?
2. What does the user need to understand?
3. What is the user's primary task?
4. What is the primary action?
5. What useful result does the screen provide?
6. What happens after the action?

If these questions cannot be answered, reconsider the screen.

## Every screen must provide value

A screen should provide at least one meaningful outcome:

- Information
- Decision support
- Progress
- Creation
- Editing
- Search
- Navigation
- Confirmation
- Error recovery
- Completion

Do not create screens merely because the architecture has another entity or database table.

---

# 5. ONE PRIMARY ACTION PER SCREEN

## Rule

> **Each screen should have ONE dominant primary action.**

Supporting actions are allowed, but they must not compete with the primary action.

Examples:

```text
Purchase Order
Primary: Save Purchase Order

Supporting:
- Cancel
- Add item
- Import
- View supplier
```

```text
Product Details
Primary: Edit Product

Supporting:
- View history
- Delete
- Scan barcode
```

## Do not create:

- 5 equally prominent buttons
- Multiple competing CTAs
- Every action styled as primary
- Large buttons everywhere

Visual hierarchy must communicate importance.

---

# 6. SCREEN COUNT AND STEP COUNT ARE NOT THE GOAL

Do NOT optimize for:

> "Fewer screens = better UX."

And do NOT optimize for:

> "Fewer clicks = better UX."

The real goal is:

> **Minimum unnecessary effort for the user's actual task.**

A three-screen workflow can be better than a one-screen workflow if the one-screen version is confusing, overloaded, and error-prone.

Likewise, one extra confirmation can be correct for a destructive operation.

Evaluate:

- Cognitive effort
- Physical effort
- Typing effort
- Navigation effort
- Error risk
- Recovery effort
- Context switching
- Information clarity

Optimize the whole experience, not an arbitrary step count.

---

# 7. FOLLOW THE WAY PEOPLE WORK

The application workflow must match the user's real-world workflow.

## Do not force users to think like the database.

Bad:

```text
Database structure
    ↓
Entity A
    ↓
Entity B
    ↓
Entity C
    ↓
User somehow completes task
```

Better:

```text
Real-world task
    ↓
Required information
    ↓
Natural sequence
    ↓
System actions
    ↓
Useful result
```

The available functionality should follow the user's way of working.

---

# 8. SMALL SCREENS: BIG CHALLENGE

Mobile has limited:

- Physical screen space
- Attention
- Typing comfort
- Precision
- Memory
- Available context

Therefore:

> **Mobile is not a shrunken desktop.**

Design the mobile experience independently while maintaining the same product language.

---

# 9. DESIGN FOR FAT FINGERS

Touch controls must be easy to hit.

## Minimum target

Use approximately **48px / 9mm or larger** touch targets where practical.

Do not rely only on the visible icon size.

The entire interactive hit area should be large enough.

### Bad

```text
×  ×  ×
```

Tiny icons placed next to each other.

### Better

```text
[   Edit   ]   [ Delete ]
```

with sufficient spacing.

## Important

> Provide enough space between targets so users do not accidentally activate the wrong action.

Especially for:

- Delete
- Back
- Close
- Menu
- Tabs
- Row actions
- Bottom navigation
- Form controls
- Scanner controls

---

# 10. MINIMIZE TYPING

Typing on mobile is slow and error-prone.

Prefer:

- Autocomplete
- Search suggestions
- Recent values
- Defaults
- Remembered values
- Personalized data
- Selectors
- Date pickers
- Numeric keyboards
- Barcode/QR scanning
- Device capabilities
- Reusable templates
- Autofill
- Smart suggestions
- Context-aware defaults

## Rule

> If the system already knows something, do not make the user type it again.

---

# 11. FORM DESIGN

Forms should be:

- Short
- Clear
- Grouped logically
- Predictable
- Easy to scan
- Easy to correct
- Optimized for the device

## Remove unnecessary fields.

Before adding a field ask:

1. Is it required?
2. Is it useful now?
3. Can it be inferred?
4. Can it be populated automatically?
5. Can it be requested later?
6. Can the system obtain it from another source?

## Field width

Do NOT make every field `width: 100%`.

Field width should communicate the expected data length.

Examples:

```text
Quantity       [  10  ]
PIN            [ **** ]
Date           [ 09/08/2026 ]
Email          [ user@example.com          ]
Description    [                         ]
```

Long fields can be wide.

Short fields should remain visually compact.

## Form spacing

Avoid:

- Huge vertical gaps
- Giant labels
- Excessive helper text
- Oversized inputs
- Empty containers

But do not compress so much that fields become difficult to scan or tap.

---

# 12. DESKTOP DESIGN RULES

Desktop provides more space, but that does NOT mean:

> "Fill the entire screen."

Use the available space intelligently.

## Desktop priorities

- Information density
- Scanability
- Multiple related pieces of information
- Efficient navigation
- Keyboard efficiency
- Tables
- Side-by-side comparison
- Persistent context
- Power-user workflows

## Avoid

- Giant empty containers
- Full-width inputs without reason
- Huge cards
- Excessive page padding
- Overly tall forms
- Centering everything
- Excessive whitespace
- Horizontal overflow
- Content hidden behind fixed navigation
- Nested scrolling unless necessary

---

# 13. DESKTOP VIEWPORT RULE

Design for realistic desktop sizes.

At minimum review:

```text
1280 × 720
1366 × 768
1440 × 900
1920 × 1080
```

The application must remain usable at smaller common desktop sizes.

Never assume everyone has a large monitor.

---

# 14. MOBILE VIEWPORT RULE

Review at realistic mobile sizes:

```text
360 × 800
375 × 812
390 × 844
412 × 915
```

Check:

- Keyboard open
- Keyboard closed
- Portrait
- Landscape when relevant
- Browser/app safe areas
- Bottom navigation
- Long content
- Error messages
- Empty states
- Dialogs
- Sheets
- Tables
- Forms

---

# 15. RESPONSIVE DESIGN

Responsive design is not:

```text
Desktop width × 0.5
```

Responsive design means the layout adapts to the user's available space and task.

## Desktop

Can use:

- Sidebar
- Multi-column layouts
- Dense tables
- Side panels
- Persistent controls

## Tablet

May use:

- Collapsible sidebar
- Reduced columns
- Compact controls
- Adaptive tables

## Mobile

Prefer:

- Single-column layouts
- Cards/lists
- Bottom navigation where appropriate
- Sheets/drawers
- Progressive disclosure
- One primary task
- Large touch targets

---

# 16. NEVER ALLOW CONTENT TO ESCAPE THE VIEWPORT

Audit every screen for:

- Horizontal overflow
- Vertical overflow
- Fixed elements covering content
- Dialogs extending beyond viewport
- Dropdowns clipped by containers
- Tooltips clipped
- Tables extending outside the application
- Buttons hidden behind navigation
- Keyboard covering fields
- Bottom sheets extending below the viewport
- Content behind headers
- Content behind sidebars

The user must always understand:

> Where am I?
> What can I do?
> What happened?
> How do I continue?

---

# 17. SCROLLING RULES

Scrolling is not inherently bad.

Unnecessary scrolling is bad.

## Avoid:

```text
Page
 ↓
Nested container
 ↓
Nested table
 ↓
Nested panel
 ↓
Another scroll
```

Users should not have to hunt for which area scrolls.

Prefer a clear primary scroll context.

## Long pages

Use:

- Sticky context where useful
- Section hierarchy
- Progressive disclosure
- Pagination
- Search
- Filters
- Tabs when appropriate
- Virtualized lists for very large data

---

# 18. INFORMATION HIERARCHY

Every screen needs hierarchy.

Users should immediately see:

```text
WHAT IS THIS?
    ↓
WHAT MATTERS?
    ↓
WHAT CAN I DO?
    ↓
WHAT HAPPENED?
```

Use:

- Size
- Weight
- Contrast
- Position
- Spacing
- Alignment
- Proximity
- Color
- Containers only when needed

Do not make everything visually loud.

---

# 19. DOMINANCE / FOCUS

The most important element should visually dominate.

Dominance can come from:

- Size
- Position
- Contrast
- Negative space
- Typography
- Color

Do not make every element dominant.

> **One clear focal point reduces cognitive effort.**

---

# 20. BALANCE

Arrange positive elements and negative space so that no unnecessary area overwhelms the rest of the design.

Balance does NOT mean equal-sized elements.

It means:

> Everything feels intentional and fits together.

Avoid:

- Huge empty areas
- Heavy sidebar + tiny content
- Huge cards beside tiny controls
- Unbalanced forms
- Random spacing

---

# 21. RHYTHM

Repeated visual patterns help users understand the interface.

Maintain consistent:

- Spacing
- Heading levels
- Field layouts
- Row heights
- Button styles
- Card structure
- Section patterns
- Navigation patterns

Users should learn one pattern and recognize it elsewhere.

---

# 22. HARMONY

All parts of the interface should feel like one product.

Maintain consistency in:

- Color
- Typography
- Spacing
- Radius
- Icons
- Components
- Motion
- Interaction behavior
- Language
- Error messages

Consistency does not mean every screen must look identical.

It means users should understand the same design language everywhere.

---

# 23. ALIGNMENT

Alignment creates order and helps the eye move through the screen.

Use intentional:

- Left edges
- Baselines
- Columns
- Form labels
- Table columns
- Section headers
- Button groups

Avoid arbitrary alignment.

Do not center content simply because there is empty space.

---

# 24. PROXIMITY

Elements that belong together should visually belong together.

Example:

```text
Supplier
[ ABC Traders ]
```

should feel like one unit.

Do not create:

```text
Supplier

            [ ABC Traders ]
```

with excessive unrelated space.

Use spacing to communicate relationships.

> Proximity reduces cognitive effort.

---

# 25. SEPARATE CONTENT FROM CONTROLS

Users should be able to distinguish:

- Information
- Actions
- Navigation
- Status
- Configuration

Do not make every piece of content look like a button.

Do not make every button look like content.

Controls should communicate their interactivity.

---

# 26. COLOR SYSTEM

Color must have a job.

Use color to communicate:

- Brand
- Status
- Attention
- Selection
- Errors
- Success
- Warnings
- Information
- Interaction

Do not use color merely because it looks attractive.

## Semantic color

Maintain consistent meanings:

```text
Success
Warning
Error
Info
Neutral
Selected
Disabled
```

Never rely on color alone to communicate critical meaning.

Combine color with:

- Text
- Icon
- Shape
- Position
- Status label

---

# 27. CONTRAST

Contrast should guide attention and improve readability.

Use contrast for:

1. Readability
2. Hierarchy
3. Interaction
4. Focus
5. Status

Do not create extreme contrast everywhere.

If everything is high contrast, nothing is dominant.

---

# 28. TYPOGRAPHY

Typography is not simply choosing a font.

Design:

- Font family
- Size
- Weight
- Line height
- Letter spacing
- Alignment
- Hierarchy
- Text length
- Wrapping
- Density

## Typography must support scanning.

Users should quickly distinguish:

```text
Page title
Section title
Field label
Primary value
Secondary information
Helper text
Status
Action
```

Avoid:

- Huge headings consuming useful space
- Tiny secondary text
- Excessive font weights
- Long paragraphs inside operational screens

---

# 29. ICONS

Icons are visual cues, not decoration.

Use icons when they:

- Improve recognition
- Reduce reading
- Support navigation
- Communicate status
- Clarify an action

Do not use ambiguous icons for important actions without labels/tooltips where needed.

Maintain:

- Consistent icon family
- Stroke/weight
- Size
- Alignment
- Meaning

---

# 30. IMAGERY

Images should communicate something.

Use imagery to:

- Explain
- Identify
- Orient
- Add context
- Support understanding

Avoid decorative images that consume valuable screen space without helping the user.

---

# 31. DATA DESIGN

Data should be presented according to the user's task.

Ask:

> What does the user need to compare, identify, monitor, or decide?

Choose:

- Table
- List
- Card
- Chart
- Metric
- Timeline
- Detail view
- Grouped data

based on the context.

Do not use charts because charts look impressive.

Do not show every available database field.

---

# 32. SIMPLIFY VISUAL INFORMATION

For complex information:

```text
RAW INFORMATION
      ↓
REMOVE NOISE
      ↓
GROUP RELATED INFORMATION
      ↓
ESTABLISH HIERARCHY
      ↓
SHOW WHAT MATTERS
      ↓
ALLOW DETAILS ON DEMAND
```

The goal is not to hide information.

The goal is to present the right information at the right moment.

---

# 33. PROGRESSIVE DISCLOSURE

Do not show everything immediately.

Show:

```text
Essential
   ↓
Useful
   ↓
Advanced
   ↓
Rare
```

Advanced functionality can be available without dominating the primary workflow.

---

# 34. SEARCH

Search should be designed around user intent.

Support where appropriate:

- Autocomplete
- Recent searches
- Suggestions
- Typo tolerance
- Filters
- Clear results
- Empty results guidance
- Fast scanning

If the user knows exactly what they want, let them get there quickly.

---

# 35. REDUCE REPETITIVE WORK

If a user performs the same operation repeatedly, optimize it.

Use:

- Defaults
- Recent values
- Templates
- Bulk actions
- Keyboard shortcuts
- Barcode scanning
- Batch operations
- Auto-save where appropriate
- Remembered preferences
- Smart suggestions

The UI should become faster as users become familiar with it.

---

# 36. INTERACTION COST

For important workflows, measure more than clicks.

Evaluate:

```text
Clicks
Taps
Typing
Scrolling
Navigation
Reading
Decision-making
Waiting
Error correction
Context switching
```

A workflow with 5 clicks and 0 typing may be better than 3 clicks requiring difficult manual input.

---

# 37. FEEDBACK

Every meaningful action should provide appropriate feedback.

Examples:

- Loading
- Saved
- Failed
- Updated
- Deleted
- Uploaded
- Scanned
- Synced
- Validation error

Feedback should be:

- Timely
- Clear
- Brief
- Relevant

Do not force users to confirm obvious successful operations.

---

# 38. LOADING STATES

Never leave users wondering:

> "Did it work?"

Use:

- Skeletons
- Progress indicators
- Button loading state
- Optimistic UI where safe
- Clear retry actions

Do not use a full-screen spinner for tiny operations.

---

# 39. ERROR DESIGN

Errors should help users recover.

Every important error should answer:

1. What happened?
2. Why?
3. What can I do?
4. Can I recover without losing my work?

Bad:

> Error 500

Better:

> Purchase could not be saved because the supplier is missing. Select a supplier and try again.

---

# 40. VALIDATION

Validate as early as useful, without becoming annoying.

Prefer:

- Inline validation
- Correct input types
- Constraints
- Helpful examples
- Clear error messages
- Preservation of entered data

Do not make users submit an entire form just to discover one obvious error.

---

# 41. CONFIRMATION RULE

Do not ask:

> "Are you sure?"

for every action.

Use confirmation for:

- Destructive operations
- Irreversible operations
- High-impact actions

Avoid confirmation for:

- Routine actions
- Reversible actions
- Obvious saves
- Navigation

Where possible, use undo instead of confirmation.

---

# 42. DEFAULTS

Good defaults reduce work.

Defaults should be:

- Sensible
- Context-aware
- Safe
- Easy to change

Never silently choose a dangerous or irreversible value.

---

# 43. PERSONALIZATION

Use known user context when useful.

Examples:

- Recent suppliers
- Recent products
- Preferred filters
- Last-used location
- Common quantities
- Frequently used actions

Personalization should reduce effort, not surprise users.

---

# 44. NAVIGATION

Navigation should answer:

> Where am I?
> Where can I go?
> Where should I go next?

Use clear:

- Active state
- Labels
- Hierarchy
- Breadcrumbs when useful
- Back behavior
- Consistent navigation

Do not create multiple competing navigation systems.

---

# 45. MOBILE NAVIGATION

Mobile navigation should expose the most important destinations.

Do not put every feature into bottom navigation.

Use:

```text
Primary destinations
        ↓
Secondary destinations
        ↓
Rare/advanced features
```

Rare features can live in menus/settings.

---

# 46. DESKTOP NAVIGATION

Desktop can support persistent navigation, but the sidebar should not dominate the screen.

Optimize:

- Width
- Grouping
- Labels
- Active state
- Collapse behavior
- Keyboard access

Do not waste horizontal space.

---

# 47. TABLES

Tables are powerful but dangerous on small screens.

Desktop tables should support where useful:

- Sorting
- Filtering
- Search
- Pagination
- Column visibility
- Bulk selection
- Row actions
- Sticky headers
- Clear status
- Appropriate density

Mobile should NOT automatically force a giant horizontal table.

Consider:

- Cards
- Lists
- Row expansion
- Detail pages
- Horizontal scrolling only when genuinely appropriate

---

# 48. MOBILE FORMS

Mobile forms should:

- Use appropriate keyboards
- Minimize typing
- Use large targets
- Avoid unnecessary fields
- Group related information
- Preserve entered values
- Keep primary action reachable
- Handle keyboard appearance correctly

Never let the keyboard cover the active field or primary action.

---

# 49. DESKTOP FORMS

Desktop forms should use available width intelligently.

Prefer:

```text
Short field     Short field
Long field
Long field
```

when the data relationship supports it.

Do not create a giant vertical list of full-width fields.

Use sections only when they improve comprehension.

---

# 50. MODALS / DIALOGS / SHEETS

A modal should have a clear reason to interrupt the current context.

Avoid modal chains:

```text
Screen
 ↓
Modal
 ↓
Modal
 ↓
Modal
```

Prefer:

- Inline editing
- Side panel
- Sheet
- Dedicated page

when the task is substantial.

Dialogs must remain within the viewport.

---

# 51. DRAWERS / SIDE PANELS

Use side panels when the user needs to inspect or edit information while preserving the original context.

Good for:

- Quick details
- Filters
- Secondary editing
- Preview
- Related information

Do not turn the side panel into an entire hidden application.

---

# 52. BARCODE / CAMERA WORKFLOWS

For scanning-heavy applications:

```text
OPEN SCANNER
      ↓
SCAN
      ↓
IDENTIFY RESULT
      ↓
TAKE REQUIRED ACTION
      ↓
SAVE / COMPLETE
      ↓
READY FOR NEXT SCAN
```

Do not force users to repeatedly:

```text
Open
Scan
Close
Open
Scan
Close
```

Support continuous workflows when appropriate.

---

# 53. KEYBOARD + POWER USERS

Desktop applications should support efficient operation.

Where appropriate:

- Tab navigation
- Enter
- Escape
- Arrow keys
- Shortcuts
- Search shortcuts
- Quick actions

Do not force expert users to repeatedly use the mouse for routine work.

---

# 54. ACCESSIBILITY

Accessibility is part of the product, not an afterthought.

Check:

- Keyboard navigation
- Focus visibility
- Screen-reader semantics
- Labels
- Touch targets
- Contrast
- Error identification
- Reduced motion
- Text scaling
- Color-independent status
- Logical reading order

---

# 55. EMPTY STATES

An empty state should explain:

```text
What is empty?
Why?
What can I do?
```

If an action can resolve the empty state, make it obvious.

---

# 56. FIRST-USE EXPERIENCE

New users should not need documentation to understand the basics.

Provide:

- Clear labels
- Obvious primary actions
- Useful defaults
- Contextual guidance
- Good empty states
- Progressive disclosure

Do not overwhelm new users with every advanced feature.

---

# 57. EXPERT-USE EXPERIENCE

Experienced users should become faster.

Provide:

- Shortcuts
- Defaults
- Recent values
- Bulk operations
- Search
- Keyboard navigation
- Fast repeat workflows
- Fewer unnecessary interruptions

A simple interface should not become slow for power users.

---

# 58. MOTION

Animation must communicate something.

Use motion for:

- State change
- Spatial relationship
- Feedback
- Orientation
- Loading

Avoid animation merely to make the interface "feel modern."

Motion should never slow down routine work.

---

# 59. VISUAL DECORATION

Decoration has a short shelf life.

Do not add:

- Random gradients
- Excessive glass effects
- Huge shadows
- Decorative blobs
- Unnecessary animations
- Excessive rounded cards
- Visual noise

unless they serve a clear product purpose.

> **If an element does not communicate, guide, encourage, motivate, educate, or help the user act, question why it exists.**

---

# 60. DESIGN SYSTEM CONSISTENCY

Create reusable tokens for:

```text
Colors
Typography
Spacing
Radius
Borders
Shadows
Icons
Motion
Breakpoints
Touch targets
Component states
```

Do not invent values randomly per screen.

---

# 61. COMPONENT REUSE

Before creating a new component:

```text
1. Search existing components.
2. Reuse if possible.
3. Extend if necessary.
4. Create new only when justified.
```

One concept should have one consistent interaction pattern wherever possible.

---

# 62. DESIGN FOR LEARNING

A good interface teaches itself through repetition.

Once a user learns:

```text
Search
Filter
Edit
Save
Back
```

the same patterns should behave similarly throughout the product.

Consistency reduces learning effort.

---

# 63. DESIGN FOR RECOVERY

Users will make mistakes.

Design for:

- Undo
- Cancel
- Back
- Edit
- Retry
- Restore
- Clear errors
- Preserve entered information

Never make users fear clicking.

---

# 64. DESIGN FOR SPEED

Perceived speed matters.

Optimize:

- Initial loading
- Navigation
- Search
- Feedback
- Data entry
- Repeated actions

But do not sacrifice clarity merely to reduce one loading state or one click.

---

# 65. SCREEN-BY-SCREEN DESIGN METHOD

For EVERY screen, complete this checklist.

## A. Context

```text
User:
Situation:
Device:
Viewport:
Experience level:
Frequency of use:
Stress/urgency:
```

## B. Purpose

```text
Why does this screen exist?
What useful outcome does it provide?
```

## C. Primary task

```text
What is the ONE thing the user should accomplish?
```

## D. Information

```text
What must the user see?
What can be hidden?
What can be inferred?
What can be loaded on demand?
```

## E. Actions

```text
Primary action:
Secondary actions:
Rare actions:
Destructive actions:
```

## F. Interaction cost

```text
Clicks:
Taps:
Typing:
Scrolling:
Navigation:
Decision effort:
Error risk:
```

## G. Responsive behavior

```text
Desktop:
Tablet:
Mobile:
Keyboard open:
Small viewport:
Large viewport:
```

## H. States

```text
Loading:
Empty:
Success:
Error:
Disabled:
Partial data:
Offline (if relevant):
```

## I. Accessibility

```text
Keyboard:
Focus:
Touch:
Contrast:
Labels:
Screen reader:
```

---

# 66. DESKTOP SCREEN REVIEW

Every desktop screen must be checked for:

- Unnecessary whitespace
- Oversized containers
- Full-width inputs
- Excessive page padding
- Excessive card height
- Horizontal overflow
- Nested scrolling
- Content hidden behind fixed UI
- Poor table density
- Weak hierarchy
- Competing primary actions
- Excessive modal usage
- Mouse-only workflows
- Unnecessary clicks
- Repeated navigation
- Poor 1280px behavior

---

# 67. MOBILE SCREEN REVIEW

Every mobile screen must be checked for:

- Tiny touch targets
- Insufficient spacing between targets
- Excessive typing
- Full-width fields that waste vertical space
- Excessive vertical scrolling
- Horizontal overflow
- Keyboard obstruction
- Bottom navigation obstruction
- Dialog overflow
- Tiny text
- Weak hierarchy
- Too many actions
- Too many fields
- Desktop UI simply compressed
- Poor one-handed operation
- Difficult recovery

---

# 68. SCREEN QUALITY GATE

Do NOT mark a screen complete until it passes:

### Purpose

- [ ] Clear purpose
- [ ] Useful outcome
- [ ] One primary action

### Simplicity

- [ ] Unnecessary elements removed
- [ ] Unnecessary fields removed
- [ ] Unnecessary steps removed
- [ ] Unnecessary text removed

### Layout

- [ ] Balanced
- [ ] Proper alignment
- [ ] Proper proximity
- [ ] Clear hierarchy
- [ ] No excessive whitespace
- [ ] No cramped areas

### Desktop

- [ ] 1280×720 tested
- [ ] 1366×768 tested
- [ ] No horizontal overflow
- [ ] No hidden content
- [ ] Appropriate information density

### Mobile

- [ ] 360×800 tested
- [ ] 375×812 tested
- [ ] 390×844 tested
- [ ] Touch targets approximately 48px or larger where appropriate
- [ ] Adequate target spacing
- [ ] Keyboard tested
- [ ] No horizontal overflow
- [ ] No content behind fixed UI

### Interaction

- [ ] Minimal typing
- [ ] Good defaults
- [ ] Autocomplete where useful
- [ ] Clear feedback
- [ ] Recoverable errors
- [ ] No unnecessary confirmation

### Accessibility

- [ ] Keyboard accessible
- [ ] Visible focus
- [ ] Contrast checked
- [ ] Color is not the only signal
- [ ] Semantic labels

---

# 69. AI CODING AGENT RULES

When an AI coding agent modifies UI:

## NEVER

- Redesign randomly
- Invent a new component when an existing one works
- Add unnecessary cards
- Add unnecessary whitespace
- Make every input full width
- Make every button primary
- Add decorative gradients without purpose
- Add arbitrary colors
- Add arbitrary spacing
- Add unnecessary animations
- Hide functionality merely to make the screen look clean
- Break desktop to fix mobile
- Break mobile to fix desktop
- Assume a large monitor
- Assume perfect network
- Remove useful information without understanding the workflow

## ALWAYS

1. Inspect the existing screen.
2. Understand the user task.
3. Understand desktop and mobile context.
4. Identify the primary action.
5. Identify unnecessary elements.
6. Reuse existing components.
7. Preserve design tokens.
8. Implement responsive behavior intentionally.
9. Test small and large viewports.
10. Check scrolling and overflow.
11. Check keyboard/touch interaction.
12. Check loading/error/empty states.
13. Check accessibility.
14. Review interaction cost.
15. Explain any significant UX tradeoff.

---

# 70. AI AGENT UX REVIEW LOOP

For every UI change:

```text
UNDERSTAND
    ↓
AUDIT
    ↓
PLAN
    ↓
IMPLEMENT
    ↓
DESKTOP REVIEW
    ↓
MOBILE REVIEW
    ↓
INTERACTION REVIEW
    ↓
ACCESSIBILITY REVIEW
    ↓
SIMPLIFY
    ↓
FINAL REVIEW
```

The final step must always be:

> **Can anything unnecessary be removed?**

---

# 71. FINAL DESIGN MANTRA

## The interface should:

```text
Communicate
    ↓
Guide
    ↓
Enable
    ↓
Confirm
    ↓
Recover
```

Not:

```text
Decorate
    ↓
Complicate
    ↓
Distract
```

---

# 72. THE FINAL QUESTION

Before shipping ANY screen, ask:

> **If I remove this element, does the user's ability to understand, decide, navigate, act, or recover become worse?**

If NO:

**Remove it.**

Then ask:

> **Can the user's task be completed with less typing, less thinking, less searching, less scrolling, or less uncertainty?**

If YES:

**Improve it.**

---

# 73. UNIVERSAL PRODUCT PRINCIPLE

> **Simple does not mean fewer features.**
>
> **Simple means the complexity of the product is handled by the product instead of being pushed onto the user.**

> **The UI should adapt to the user's context, not force the user to adapt to the UI.**

> **Every screen must earn its place. Every element must earn its space. Every interaction must have a purpose.**

> **Design for the smallest practical screen, the busiest practical user, and the most important practical task — while preserving efficiency for desktop power users.**

---

# 74. UX FOUNDATION — STRATEGY → SCOPE → STRUCTURE → SKELETON → SURFACE

Use the **five-layer User Experience model** as the foundation for every product and every screen:

```text
1. STRATEGY
      ↓
2. SCOPE
      ↓
3. STRUCTURE
      ↓
4. SKELETON
      ↓
5. SURFACE
```

Do not jump directly to colors, cards, buttons, or visual polish.

A beautiful surface cannot rescue a broken strategy, structure, or workflow.

---

# 75. LAYER 1 — STRATEGY

Before designing UI, determine:

## Business goals

- What does the business need?
- What outcome must the product create?
- What problem is the product solving?
- What makes the product valuable?

## User needs

Identify the actual user and their needs.

For B2B/business applications ask:

- Who is using this?
- What job are they trying to perform?
- How frequently?
- What information do they need?
- What causes mistakes?
- What causes delay?
- What causes frustration?
- What is the cost of a bad workflow?

## First-use questions

Before designing the first experience, determine:

- What does the user expect?
- What do they need immediately?
- What do they need to understand?
- What action should be obvious?
- What can the product do automatically?
- What might confuse a new user?

## Three crucial questions

For any product/workflow:

```text
What does the user want?
What does the business need?
What must the system do to connect the two?
```

---

# 76. STRATEGY → USER CONTEXT

Never design a generic "user."

Define the context:

```text
USER
 ↓
GOAL
 ↓
ENVIRONMENT
 ↓
DEVICE
 ↓
TIME PRESSURE
 ↓
EXPERIENCE
 ↓
TASK FREQUENCY
 ↓
AVAILABLE INPUT METHOD
```

Examples:

### Desktop office user

May have:

- Large screen
- Mouse
- Keyboard
- Multiple windows
- High information density
- Repetitive tasks
- Power-user behavior

Optimize for:

- Scanability
- Dense information
- Keyboard efficiency
- Tables
- Side-by-side information
- Fast repeated actions

### Mobile user

May have:

- Small screen
- Touch
- One hand
- Unstable attention
- Limited typing comfort
- Movement/distraction

Optimize for:

- One primary task
- Large touch targets
- Minimal typing
- Clear hierarchy
- Short workflows
- Immediate feedback

---

# 77. LAYER 2 — SCOPE

Determine exactly what the product/screen needs to contain.

## Functional specifications

Define:

- Required functions
- User actions
- System responses
- Business rules
- Permissions
- Dependencies
- Edge cases

## Content requirements

Determine:

- What information must appear?
- What information is optional?
- What information is generated?
- What information can be loaded later?
- What information is unnecessary?

## Ruthless prioritization

Classify requirements:

```text
MUST HAVE
    ↓
SHOULD HAVE
    ↓
COULD HAVE
    ↓
RARE / ADVANCED
```

Do not allow every requirement to become equally visible.

---

# 78. SCOPE RULE — FUNCTIONALITY DOES NOT EQUAL VISUAL COMPLEXITY

A product can have many capabilities while presenting a simple interface.

```text
COMPLEX SYSTEM
      ↓
SMART LOGIC
      ↓
CONTEXT
      ↓
PROGRESSIVE DISCLOSURE
      ↓
SIMPLE USER EXPERIENCE
```

The system should carry complexity whenever possible.

Do not make the user manage internal system complexity.

---

# 79. LAYER 3 — STRUCTURE

Structure defines how the product behaves and how information is organized.

## Interaction Design

For every important task:

```text
USER INTENT
 ↓
AVAILABLE ACTION
 ↓
SYSTEM RESPONSE
 ↓
NEXT STATE
 ↓
SUCCESS / RECOVERY
```

Ask:

- What happens after this click?
- What changes?
- Where does the user go?
- What remains visible?
- Can the user undo?
- What if it fails?
- Can the user continue immediately?

## Information Architecture

Organize information around the user's mental model.

Do NOT organize the product merely around:

- Database tables
- Backend services
- Developer folders
- API endpoints
- Internal technical architecture

The UI should reflect the user's understanding of the work.

---

# 80. ORGANIZING PRINCIPLES

Choose a clear organizing principle.

Possible principles include:

- Task
- Workflow
- Category
- Time
- Location
- Status
- User role
- Frequency
- Priority

Do not mix organizing principles randomly.

Navigation should feel predictable.

---

# 81. ROLES AND PROCESSES

For business applications, understand:

```text
ROLE
 ↓
PERMISSION
 ↓
TASK
 ↓
WORKFLOW
 ↓
SCREEN
 ↓
ACTION
```

Different users may need different interfaces.

Do not expose every capability to everyone simply because the backend supports it.

Use:

- Role-aware navigation
- Permission-aware actions
- Contextual controls
- Progressive disclosure

---

# 82. LAYER 4 — SKELETON

The skeleton determines how information and controls are arranged before visual styling.

Design:

- Interface layout
- Navigation
- Information design
- Wireframes
- Component placement
- Interaction locations

Ask:

> Can the user understand and operate this screen before colors and decoration are added?

If no, the structure is not ready.

---

# 83. INTERFACE DESIGN

Controls should appear where users expect them.

Primary actions should be:

- Easy to find
- Easy to understand
- Easy to activate
- Consistently positioned

Do not move important actions randomly between screens.

---

# 84. NAVIGATION DESIGN

Navigation must provide orientation.

Users should know:

```text
WHERE AM I?
     ↓
WHAT CAN I DO?
     ↓
WHERE CAN I GO?
     ↓
WHAT SHOULD I DO NEXT?
```

Navigation should follow the product's information architecture.

Avoid multiple competing navigation patterns.

---

# 85. CONVENTION AND METAPHOR

Use familiar interaction conventions when they improve comprehension.

Examples:

- Back behaves like back
- Search behaves like search
- Delete behaves like delete
- Save behaves like save
- Menu behaves like menu

Do not create novel interaction patterns just to appear innovative.

Innovation is useful only when it improves the user's outcome.

---

# 86. INFORMATION DESIGN

Information must be structured for scanning.

Use:

- Hierarchy
- Grouping
- Labels
- Status
- Sorting
- Filtering
- Progressive disclosure
- Appropriate density

Do not dump raw data onto users.

Convert:

```text
RAW DATA
 ↓
STRUCTURE
 ↓
PRIORITY
 ↓
CONTEXT
 ↓
DECISION-USEFUL INFORMATION
```

---

# 87. WIREFRAME BEFORE POLISH

Before detailed visual design:

```text
USER GOAL
 ↓
CONTENT
 ↓
STRUCTURE
 ↓
WIREFRAME
 ↓
INTERACTION REVIEW
 ↓
DESKTOP REVIEW
 ↓
MOBILE REVIEW
 ↓
VISUAL DESIGN
```

Do not spend hours polishing a layout that has not been validated structurally.

---

# 88. LAYER 5 — SURFACE

Only after strategy, scope, structure and skeleton are sound should you refine:

- Visual hierarchy
- Color
- Typography
- Contrast
- Uniformity
- Consistency
- Icons
- Imagery
- Spacing
- Components
- States
- Motion

Surface is important.

But surface comes last.

---

# 89. VISUAL DESIGN PRINCIPLES

Use visual design to communicate hierarchy.

The eye should naturally move:

```text
PRIMARY INFORMATION
        ↓
SECONDARY INFORMATION
        ↓
PRIMARY ACTION
        ↓
SUPPORTING INFORMATION
```

Do not make every element equally strong.

---

# 90. FOLLOW THE EYE

Review the visual scanning path.

Ask:

- What does the user notice first?
- What do they notice second?
- Where does the eye stop?
- Where is the primary action?
- Is irrelevant content stealing attention?

If the user's eye goes to the wrong thing, fix hierarchy before adding more decoration.

---

# 91. CONTRAST AND UNIFORMITY

Contrast should distinguish importance.

Uniformity should communicate consistency.

Use:

```text
CONTRAST → DIFFERENT MEANING
UNIFORMITY → SAME MEANING
```

Examples:

- Primary button differs from secondary button
- Error differs from normal state
- Active navigation differs from inactive navigation
- Same field patterns look and behave consistently

---

# 92. CONSISTENCY

Consistency reduces learning effort.

Keep consistent:

- Button behavior
- Form behavior
- Navigation
- Terminology
- Icons
- Colors
- Typography
- Spacing
- Component states
- Error patterns
- Success patterns

If the same action behaves differently on different screens, investigate why.

---

# 93. COLOR + TYPOGRAPHY

Color should communicate.

Typography should establish hierarchy.

Review:

```text
TITLE
 ↓
SECTION
 ↓
LABEL
 ↓
PRIMARY VALUE
 ↓
SECONDARY VALUE
 ↓
HELP / STATUS
```

Do not use font size as the only hierarchy mechanism.

Combine:

- Size
- Weight
- Spacing
- Contrast
- Position

---

# 94. DESKTOP UX — EXPLICIT DESIGN ORDER

For every desktop screen use this order:

```text
1. USER + CONTEXT
       ↓
2. BUSINESS GOAL
       ↓
3. USER GOAL
       ↓
4. TASK
       ↓
5. REQUIRED INFORMATION
       ↓
6. INFORMATION ARCHITECTURE
       ↓
7. PRIMARY ACTION
       ↓
8. SECONDARY / ADVANCED ACTIONS
       ↓
9. DESKTOP LAYOUT
       ↓
10. INFORMATION DENSITY
       ↓
11. NAVIGATION
       ↓
12. FORM / TABLE / DATA DESIGN
       ↓
13. WIREFRAME
       ↓
14. VISUAL HIERARCHY
       ↓
15. COLOR + TYPOGRAPHY
       ↓
16. INTERACTION STATES
       ↓
17. ERROR / EMPTY / LOADING
       ↓
18. KEYBOARD + MOUSE
       ↓
19. ACCESSIBILITY
       ↓
20. 1280 / 1366 / 1440 / 1920 REVIEW
       ↓
21. SIMPLIFY AGAIN
```

---

# 95. DESKTOP INFORMATION DENSITY

Desktop has more physical space.

Use it for useful information — not decorative whitespace.

Good desktop density:

```text
RELATED INFORMATION
        +
EASY SCANNING
        +
CLEAR GROUPING
        +
FAST ACTION
```

Bad desktop density:

```text
HUGE CARD
HUGE PADDING
HUGE INPUT
HUGE HEADER
VERY LITTLE INFORMATION
```

Do not confuse whitespace with quality.

Whitespace should separate relationships and create hierarchy.

---

# 96. DESKTOP POWER-USER RULE

Business software often has repeat users.

Design for speed after learning.

Support where appropriate:

- Keyboard navigation
- Shortcuts
- Tab order
- Enter
- Escape
- Arrow keys
- Search
- Bulk actions
- Multi-select
- Filters
- Saved filters
- Recent items
- Quick edit
- Inline editing

The interface should become more efficient as the user becomes more experienced.

---

# 97. MOBILE UX — EXPLICIT DESIGN ORDER

For every mobile screen use this order:

```text
1. USER + CONTEXT
       ↓
2. USER GOAL
       ↓
3. ONE PRIMARY TASK
       ↓
4. ESSENTIAL INFORMATION
       ↓
5. REMOVE NON-ESSENTIAL INFORMATION
       ↓
6. MINIMIZE TYPING
       ↓
7. TOUCH TARGETS
       ↓
8. PRIMARY ACTION
       ↓
9. PROGRESSIVE DISCLOSURE
       ↓
10. SINGLE-COLUMN / APPROPRIATE LAYOUT
       ↓
11. KEYBOARD BEHAVIOR
       ↓
12. LOADING / EMPTY / ERROR
       ↓
13. ONE-HANDED / TOUCH REVIEW
       ↓
14. ACCESSIBILITY
       ↓
15. 360 / 375 / 390 / 412 REVIEW
       ↓
16. SIMPLIFY AGAIN
```

---

# 98. DESKTOP VS MOBILE — SAME PRODUCT, DIFFERENT PRIORITIES

Do not make two unrelated products.

Maintain:

- Same terminology
- Same mental model
- Same data
- Same design language
- Same business rules
- Same component meaning

But adapt:

### Desktop

```text
MORE SPACE
 ↓
MORE CONTEXT
 ↓
MORE INFORMATION
 ↓
MORE POWER-USER EFFICIENCY
```

### Mobile

```text
LESS SPACE
 ↓
LESS SIMULTANEOUS INFORMATION
 ↓
MORE FOCUS
 ↓
LESS TYPING
 ↓
LARGER TOUCH TARGETS
```

---

# 99. DESKTOP → MOBILE TRANSFORMATION RULE

Never simply shrink:

```text
Desktop
   ↓
width: 100%
   ↓
Mobile
```

Instead transform:

```text
DESKTOP INFORMATION ARCHITECTURE
            ↓
IDENTIFY PRIORITY
            ↓
IDENTIFY PRIMARY TASK
            ↓
REMOVE / HIDE LOW-PRIORITY CONTENT
            ↓
CHANGE LAYOUT
            ↓
CHANGE INTERACTION MODEL
            ↓
MOBILE EXPERIENCE
```

---

# 100. USER RESEARCH → DESIGN → TEST LOOP

UX is not a one-time design step.

Use:

```text
RESEARCH
   ↓
DEFINE
   ↓
DESIGN
   ↓
PROTOTYPE
   ↓
TEST
   ↓
OBSERVE
   ↓
IMPROVE
   ↓
TEST AGAIN
```

Where possible, use:

- User testing
- Feedback
- Analytics
- A/B testing
- Task completion
- Error frequency
- Abandonment
- Search behavior
- Conversion/completion rate

Do not assume a design is good merely because designers like it.

---

# 101. FIRST-USE VS REPEAT-USE

Every major workflow should be evaluated twice.

## First use

Optimize for:

- Understanding
- Discoverability
- Guidance
- Safe defaults
- Clear terminology
- Error prevention

## Repeat use

Optimize for:

- Speed
- Shortcuts
- Defaults
- Recent values
- Bulk actions
- Reduced repetition
- Minimal interruption

The same product must support both.

---

# 102. FORM UX — USER EXPERIENCE FIRST

Forms are not just UI components.

Evaluate the entire experience:

```text
WHY AM I FILLING THIS?
 ↓
WHAT DO I NEED?
 ↓
WHAT CAN THE SYSTEM KNOW?
 ↓
WHAT MUST I ENTER?
 ↓
WHAT CAN BE AUTOCOMPLETED?
 ↓
WHAT CAN BE DEFAULTED?
 ↓
WHAT CAN BE SCANNED?
 ↓
WHAT HAPPENS IF I MAKE A MISTAKE?
 ↓
WHAT HAPPENS AFTER SAVE?
```

---

# 103. TASK COMPLETION IS THE REAL METRIC

Do not judge UX primarily by:

- Number of screens
- Number of buttons
- Number of clicks
- Amount of whitespace
- Number of animations
- Visual trendiness

Judge by:

```text
Can users understand the task?
Can they find what they need?
Can they complete it?
Can they avoid errors?
Can they recover?
Can they do it efficiently?
Can they learn the pattern?
Can they repeat it faster?
```

---

# 104. AI AGENT — REQUIRED UX AUDIT BEFORE CODING

Before an AI coding agent changes a screen, it must reason through:

```text
1. Who uses this screen?
2. Why are they here?
3. What state are they in?
4. What task are they performing?
5. What information is essential?
6. What is the ONE primary action?
7. What actions are secondary?
8. What can be removed?
9. What can be automated?
10. What can be inferred?
11. What can be autocomplete/defaulted?
12. What should be desktop-only?
13. What should change on mobile?
14. What can cause overflow?
15. What can overlap?
16. What happens with keyboard open?
17. What happens on a small viewport?
18. What happens on slow loading?
19. What happens on failure?
20. What happens after success?
21. Can the user undo/recover?
22. Does this reuse existing components?
23. Does it preserve the design system?
24. Does it preserve business workflow?
25. Can the final result be simplified?
```

---

# 105. AI AGENT — DO NOT CODE FROM A SCREENSHOT ALONE

A screenshot shows the surface.

It does not explain:

- User goal
- Business goal
- Workflow
- Permissions
- Data relationships
- Error states
- Loading states
- Empty states
- Mobile behavior
- Desktop behavior
- Accessibility
- Power-user requirements

Therefore:

> **Understand the product and workflow before changing the UI.**

---

# 106. AI AGENT — NO BLIND REDESIGN

Before modifying an existing screen:

```text
INSPECT EXISTING IMPLEMENTATION
        ↓
UNDERSTAND CURRENT WORKFLOW
        ↓
IDENTIFY UX PROBLEMS
        ↓
SEPARATE REAL PROBLEMS FROM PREFERENCES
        ↓
PLAN CHANGES
        ↓
IMPLEMENT
        ↓
TEST
        ↓
REVIEW
```

Do not rewrite working functionality simply because a different design looks prettier.

---

# 107. COMPLETE UX DESIGN ORDER FOR EVERY PROJECT

Use this as the master sequence:

```text
PHASE 1 — DISCOVER
    ↓
User
Context
Business goals
User goals
Environment
Roles
Processes
Research

PHASE 2 — STRATEGY
    ↓
Product purpose
Business goals
User needs
First-use needs
Success criteria

PHASE 3 — SCOPE
    ↓
Functional requirements
Content requirements
Business rules
Prioritization

PHASE 4 — STRUCTURE
    ↓
Interaction design
Information architecture
Navigation
Organizing principles
Roles
Processes

PHASE 5 — SKELETON
    ↓
Interface design
Information design
Wireframes
Layout
Navigation placement
Forms
Tables
Primary actions

PHASE 6 — RESPONSIVE UX
    ↓
Desktop
Tablet
Mobile
Small viewport
Large viewport
Keyboard
Touch

PHASE 7 — SURFACE
    ↓
Hierarchy
Typography
Color
Contrast
Consistency
Icons
Imagery
Spacing
Components

PHASE 8 — STATES
    ↓
Loading
Empty
Success
Error
Disabled
Partial
Offline if relevant
Recovery

PHASE 9 — VALIDATION
    ↓
Usability
Task completion
Accessibility
Keyboard
Touch
Overflow
Scrolling
Interaction cost
First use
Repeat use

PHASE 10 — SIMPLIFY
    ↓
Remove unnecessary elements
Remove unnecessary fields
Remove unnecessary decisions
Remove unnecessary typing
Remove unnecessary scrolling
Remove unnecessary interruptions

PHASE 11 — SHIP
    ↓
Desktop QA
Mobile QA
Real workflow QA
Accessibility QA
Performance QA
Final UX review
```

---

# 108. THE FINAL MASTER RULE

> **Strategy before scope.**
>
> **Scope before structure.**
>
> **Structure before skeleton.**
>
> **Skeleton before surface.**
>
> **Desktop and mobile must each be designed for their context.**
>
> **Every screen must have a clear purpose and one primary action.**
>
> **Every visible element must earn its space.**
>
> **Every interaction must earn its cost.**
>
> **Every feature must follow the user's workflow.**
>
> **Every design must be tested against real user needs, not only visual preference.**
>
> **After everything works, simplify again.**

