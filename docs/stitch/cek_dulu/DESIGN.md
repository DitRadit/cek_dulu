---
name: Cek Dulu
colors:
  surface: '#FFFFFF'
  surface-dim: '#d0dbe9'
  surface-bright: '#f7f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#edf4ff'
  surface-container: '#e4effd'
  surface-container-high: '#dee9f8'
  surface-container-highest: '#d8e4f2'
  on-surface: '#121d27'
  on-surface-variant: '#3f4944'
  inverse-surface: '#27313c'
  inverse-on-surface: '#e8f2ff'
  outline: '#6f7a74'
  outline-variant: '#bec9c3'
  surface-tint: '#086b53'
  primary: '#005440'
  on-primary: '#ffffff'
  primary-container: '#E3F2EE'
  on-primary-container: '#9aedcf'
  inverse-primary: '#84d6b9'
  secondary: '#2c6197'
  on-secondary: '#ffffff'
  secondary-container: '#91c2fe'
  on-secondary-container: '#124f84'
  tertiary: '#78352b'
  on-tertiary: '#ffffff'
  tertiary-container: '#954c41'
  on-tertiary-container: '#ffd3cc'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a0f3d4'
  primary-fixed-dim: '#84d6b9'
  on-primary-fixed: '#002117'
  on-primary-fixed-variant: '#00513e'
  secondary-fixed: '#d2e4ff'
  secondary-fixed-dim: '#a0c9ff'
  on-secondary-fixed: '#001c37'
  on-secondary-fixed-variant: '#05497d'
  tertiary-fixed: '#ffdad4'
  tertiary-fixed-dim: '#ffb4a8'
  on-tertiary-fixed: '#3b0804'
  on-tertiary-fixed-variant: '#743329'
  background: '#F4F6F8'
  on-background: '#121d27'
  surface-variant: '#d8e4f2'
  risk-high: '#C0392B'
  risk-medium: '#E08A00'
  risk-neutral: '#3B6EA5'
  text-primary: '#1D2733'
  text-secondary: '#5B6672'
typography:
  headline-senior:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: Montserrat
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-md:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  title-sm:
    fontFamily: Montserrat
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-senior:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-senior:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 26px
  label-lg:
    fontFamily: Montserrat
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  label-md:
    fontFamily: Montserrat
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  caption:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

# Design System: Cek Dulu (Pelindung Penipuan Online)

Design an Android mobile app (Material 3 style, 360x800 dp) called "Cek Dulu".
Purpose: the user shares a screenshot of a suspicious message/ad; the app reads it ON-DEVICE, shows a scam-risk level with a short plain-language reason and next steps. Elderly users get a "Senior mode" with huge text, voice explanation, and one button "Tanya keluarga" that sends a masked summary to a trusted family companion before they send money.
All UI text must be in Indonesian (Bahasa Indonesia), simple everyday words, no jargon.

## Visual Direction & Tone
- Tone: calm, trustworthy, protective, never alarmist or accusatory.
- Material 3 aesthetic, clean card surfaces, generous padding and clear hierarchy.

## Color Palette
- Primary: #0F6E56 (deep emerald green)
- Primary Container: #E3F2EE (light mint tint)
- Background: #F4F6F8 (soft cool gray)
- Surface: #FFFFFF
- High risk: #C0392B (crimson warning, always with icon + text label)
- Medium / suspicious: #E08A00 (amber caution)
- No known warning signs: #3B6EA5 (blue-gray, NOT green, never implies "safe")
- Text Primary: #1D2733
- Text Secondary: #5B6672

## Typography
- Headlines, titles, risk labels, buttons: Montserrat (SemiBold/Bold)
- Body text, captions, chips: Poppins (Regular/Medium)
- Standard mode: Body 16sp, Titles 20-22sp
- Senior mode: Body 22sp+, Headline 32sp Montserrat Bold

## Shapes & Components
- 16-20dp rounded cards, 12-16dp rounded buttons.
- Touch target min 48dp (senior mode 64dp+).
- Primary buttons: filled green (#0F6E56), text white. Secondary: outlined green.
- One primary action per screen.

## Copy Rules
- Never say "aman" / "safe" / "pasti". Use: "Tidak ditemukan tanda bahaya yang kami kenali".
- Results are indications: "kemungkinan", "indikasi".
- Footnote on results: "Hasil ini indikasi, bukan putusan."
