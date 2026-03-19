import { colors } from '../config'

export const theme = {
  colors: {
    primary: colors.primary,
    primaryLight: colors.primaryLight,
    primaryDark: colors.primaryDark,

    textPrimary: colors.textPrimary,
    textSecondary: colors.textSecondary,
    textMuted: colors.textMuted,

    background: colors.background,

    card: colors.card,

    countdown: colors.countdown,
  },

  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px',
  },

  borderRadius: {
    sm: '8px',
    md: '12px',
    lg: '16px',
    xl: '20px',
    full: '9999px',
  },

  shadows: {
    card: '0 4px 20px rgba(100,80,200,0.1)',
    modal: '0 8px 32px rgba(100,80,200,0.15)',
    button: '0 4px 12px rgba(108,92,231,0.35)',
  },
}
