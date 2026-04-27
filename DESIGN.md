---
name: Clinical Clarity
colors:
  surface: '#f9f9fd'
  surface-dim: '#d9dadd'
  surface-bright: '#f9f9fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f7'
  surface-container: '#edeef1'
  surface-container-high: '#e7e8eb'
  surface-container-highest: '#e2e2e6'
  on-surface: '#191c1e'
  on-surface-variant: '#41474e'
  inverse-surface: '#2e3133'
  inverse-on-surface: '#f0f0f4'
  outline: '#72787f'
  outline-variant: '#c1c7cf'
  surface-tint: '#316289'
  primary: '#074469'
  on-primary: '#ffffff'
  primary-container: '#2a5c82'
  on-primary-container: '#a5d4ff'
  inverse-primary: '#9ccbf7'
  secondary: '#006a68'
  on-secondary: '#ffffff'
  secondary-container: '#91f0ec'
  on-secondary-container: '#006e6c'
  tertiary: '#5a3b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#76510e'
  on-tertiary-container: '#fac67a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cde5ff'
  primary-fixed-dim: '#9ccbf7'
  on-primary-fixed: '#001d32'
  on-primary-fixed-variant: '#124a6f'
  secondary-fixed: '#94f2ef'
  secondary-fixed-dim: '#78d6d2'
  on-secondary-fixed: '#00201f'
  on-secondary-fixed-variant: '#00504e'
  tertiary-fixed: '#ffddb0'
  tertiary-fixed-dim: '#f1be72'
  on-tertiary-fixed: '#281800'
  on-tertiary-fixed-variant: '#614000'
  background: '#f9f9fd'
  on-background: '#191c1e'
  surface-variant: '#e2e2e6'
typography:
  h1:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  h2:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.25'
    letterSpacing: -0.01em
  h3:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.0'
    letterSpacing: 0.05em
  button:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '1.0'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style
The design system is anchored in the concept of "Guided Confidence." It prioritizes a high-quality, professional aesthetic that balances clinical precision with human empathy. The target audience includes patients seeking reliable care and practitioners requiring streamlined workflows. 

The visual style follows a **Modern Corporate** movement with a lean towards **Minimalism**. It utilizes generous white space to reduce cognitive load—essential for healthcare contexts where users may be stressed or anxious. The interface feels "breathable," using subtle depth and a restricted color palette to emphasize critical health data and primary actions.

## Colors
The palette is led by **Medical Blue (#2A5C82)**, a shade chosen for its association with institutional trust and stability. The secondary **Mint Teal (#48A9A6)** is reserved for "positive momentum" actions, such as scheduling appointments or completing health goals, providing a calming alternative to traditional high-contrast action colors.

The neutral scale favors cool slates over pure greys to maintain a sterile yet modern feel. Backgrounds use a very light tint to allow white "Surface" cards to pop visually, creating a clear distinction between the canvas and interactive content.

## Typography
This design system utilizes a dual-font strategy to maximize both character and readability. **Manrope** is used for headlines to provide a modern, slightly rounded warmth that feels approachable. **Inter** is the workhorse for all functional text, chosen for its exceptional legibility in data-heavy environments and small screen sizes.

Line heights are intentionally generous (1.5x to 1.6x for body text) to ensure that medical instructions and patient data are easy to scan without eye fatigue.

## Layout & Spacing
The design system employs a **Fluid Grid** model built on an 8px base unit. This ensures mathematical harmony across all screen sizes. For mobile views, a 4-column grid is used with 20px side margins to provide a spacious "frame" for content.

Vertical spacing is intentionally "loose." Section headers should be separated from content by at least `lg` (24px) units, and related grouped items should use `md` (16px). This creates a rhythmic hierarchy that prevents the interface from feeling cluttered, even when displaying complex lab results or schedules.

## Elevation & Depth
To maintain a high-quality, clinical feel, the design system avoids heavy shadows. Instead, it uses **Tonal Layers** combined with **Ambient Shadows**. 

- **Level 0 (Background):** Flat, cool-toned neutral.
- **Level 1 (Cards/Surface):** White background with a 1px border in a light neutral tint.
- **Level 2 (Active/Floating):** An extremely diffused shadow (15% opacity of the Primary Color) with a 12px blur, used for elevated states like active inputs or navigation bars.

This subtle use of depth suggests layers of information without overwhelming the user with heavy 3D metaphors.

## Shapes
A **Rounded (0.5rem)** logic is applied across the system. This level of corner radius is a strategic choice: it is softer and more "human" than sharp corners, yet more structured and professional than fully pill-shaped "playful" designs. 

Cards and containers use `rounded-lg` (1rem) to create a soft frame for internal content. Buttons and input fields use the standard 0.5rem radius to maintain a consistent interactive language.

## Components
- **Buttons:** Primary buttons use the Medical Blue with white text. Secondary/Success actions (e.g., "Confirm Appointment") use the Mint Teal. Use "Ghost" buttons (border-only) for secondary navigation to maintain visual hierarchy.
- **Input Fields:** Use a 1px border in a light slate. On focus, the border should transition to the Primary Blue with a 2px outer glow. Labels are always visible above the field in `body-sm`.
- **Cards:** The primary container for health data. Use white backgrounds, a subtle 1px border, and `rounded-lg` corners. Avoid inner padding smaller than 16px.
- **Chips:** Used for medical tags or status filters. These should have a light-tinted background (5-10% opacity of the color) with high-contrast text for accessibility.
- **Progress Bars:** Essential for health tracking. Use a thin track height (4px or 8px) with the Mint Teal for completion states.
- **Alerts/Toasts:** Use the full-width banner style for critical errors, utilizing the defined Error and Warning tokens. Ensure icons are paired with text for accessibility.