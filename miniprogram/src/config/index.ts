import colorsConfig from './colors.json'
import menuConfig from './menu.json'
import textsConfig from './texts.json'
import countdownConfig from './countdown.json'
import uiConfig from './ui.json'
import columnsConfig from './columns.json'
import statsConfig from './stats.json'

export type ColorType = 'pink' | 'blue' | 'green' | 'purple'

export interface CountdownColorConfig {
  bg: string
  text: string
  name: string
}

export interface ColorsConfig {
  primary: string
  primaryLight: string
  primaryDark: string
  textPrimary: string
  textSecondary: string
  textMuted: string
  background: {
    primary: string
    secondary: string
    tertiary: string
  }
  card: {
    bg: string
    border: string
    shadow: string
  }
  countdown: Record<ColorType, CountdownColorConfig>
  progress: {
    interview: { bg: string; fill: string }
    offer: { bg: string; fill: string }
    rejected: { bg: string; fill: string }
  }
}

export interface MenuItem {
  key: string
  label: string
  icon: string
}

export interface TabBarItem {
  key: string
  label: string
  icon: string
  activeIcon: string
}

export interface MenuConfig {
  profile: {
    menuItems: MenuItem[]
  }
  tabBar: {
    items: TabBarItem[]
  }
}

export interface TextsConfig {
  app: {
    name: string
    version: string
  }
  home: {
    title: string
    subtitle: string
    emptyText: string
    emptySubtext: string
    inputPlaceholder: string
  }
  profile: {
    title: string
    defaultUserName: string
    defaultUserStatus: string
    statsLabels: {
      days: string
      applications: string
      interviews: string
    }
    progressLabels: {
      interview: string
      offer: string
      rejected: string
    }
  }
  pet: {
    name: string
    messages: string[]
  }
  knowledge: {
    title: string
    subtitle: string
    emptyText: string
  }
  stats: {
    title: string
    subtitle: string
  }
}

export interface CountdownItem {
  id: string
  title: string
  date: string
  color: ColorType
}

export interface CountdownConfig {
  defaultCountdowns: CountdownItem[]
  colorTypes: ColorType[]
}

export interface UIConfig {
  animation: {
    idleDuration: number
    happyDuration: number
    messageShowDuration: number
    responseDelay: number
  }
  layout: {
    headerPaddingTop: number
    headerPaddingHorizontal: number
    cardPadding: number
    cardBorderRadius: number
    messageMaxWidth: string
    avatarSize: number
    inputHeight: number
    sendBtnWidth: number
  }
  spacing: {
    xs: number
    sm: number
    md: number
    lg: number
    xl: number
  }
  borderRadius: {
    sm: number
    md: number
    lg: number
    xl: number
    full: number
  }
}

export interface ColumnItem {
  id: string
  title: string
  description: string
  price: number
  author: string
  readCount: number
  image: string
}

export interface ColumnsConfig {
  columns: ColumnItem[]
  banner: {
    title: string
    description: string
  }
}

export interface TodoItem {
  id: string
  title: string
  done: boolean
  tag: string
}

export interface RecommendationItem {
  id: string
  title: string
  company: string
  location: string
}

export interface StatsConfig {
  defaultTodos: TodoItem[]
  defaultRecommendations: RecommendationItem[]
  birdTips: string[]
}

export const colors = colorsConfig as ColorsConfig
export const menu = menuConfig as MenuConfig
export const texts = textsConfig as TextsConfig
export const countdown = countdownConfig as CountdownConfig
export const ui = uiConfig as UIConfig
export const columns = columnsConfig as ColumnsConfig
export const stats = statsConfig as StatsConfig

export function getCountdownColorConfig(color: ColorType): CountdownColorConfig {
  return colors.countdown[color]
}

export function getRandomPetMessage(): string {
  const messages = texts.pet.messages
  return messages[Math.floor(Math.random() * messages.length)]
}

export function getRandomBirdTip(): string {
  const tips = stats.birdTips
  return tips[Math.floor(Math.random() * tips.length)]
}
