import Taro from '@tarojs/taro'

export type ScreenSize = 'small' | 'medium' | 'large'
export type DeviceType = 'phone' | 'tablet'
export type Orientation = 'portrait' | 'landscape'

export interface ScreenInfo {
  width: number
  height: number
  pixelRatio: number
  safeArea: {
    top: number
    bottom: number
    left: number
    right: number
  }
  screenSize: ScreenSize
  deviceType: DeviceType
  orientation: Orientation
  isNotch: boolean
  statusBarHeight: number
}

const DESIGN_WIDTH = 750

let cachedScreenInfo: ScreenInfo | null = null

export function getScreenInfo(): ScreenInfo {
  if (cachedScreenInfo) {
    return cachedScreenInfo
  }

  try {
    // 使用新的 API 替代已弃用的 getSystemInfoSync
    const windowInfo = Taro.getWindowInfo()
    const deviceInfo = Taro.getDeviceInfo()
    const appBaseInfo = Taro.getAppBaseInfo()

    const { windowWidth, windowHeight, pixelRatio, safeArea } = windowInfo
    const { statusBarHeight } = appBaseInfo

    const screenSize: ScreenSize = windowWidth < 350 ? 'small' : windowWidth < 414 ? 'medium' : 'large'
    const deviceType: DeviceType = windowWidth >= 600 ? 'tablet' : 'phone'
    const orientation: Orientation = windowWidth > windowHeight ? 'landscape' : 'portrait'
    const isNotch = (safeArea?.top ?? 0) > 20

    cachedScreenInfo = {
      width: windowWidth,
      height: windowHeight,
      pixelRatio,
      safeArea: {
        top: safeArea?.top ?? 0,
        bottom: safeArea?.bottom ?? windowHeight,
        left: safeArea?.left ?? 0,
        right: safeArea?.right ?? windowWidth,
      },
      screenSize,
      deviceType,
      orientation,
      isNotch,
      statusBarHeight: statusBarHeight ?? 20,
    }

    return cachedScreenInfo
  } catch {
    return {
      width: 375,
      height: 667,
      pixelRatio: 2,
      safeArea: { top: 0, bottom: 667, left: 0, right: 375 },
      screenSize: 'medium',
      deviceType: 'phone',
      orientation: 'portrait',
      isNotch: false,
      statusBarHeight: 20,
    }
  }
}

export function pxToRpx(px: number): number {
  const { width } = getScreenInfo()
  return (px / width) * DESIGN_WIDTH
}

export function rpxToPx(rpx: number): number {
  const { width } = getScreenInfo()
  return (rpx / DESIGN_WIDTH) * width
}

export function scaleSize(designSize: number): number {
  const { width } = getScreenInfo()
  const scale = width / (DESIGN_WIDTH / 2)
  return designSize * scale
}

export function getResponsiveValue(values: {
  small?: number
  medium?: number
  large?: number
  tablet?: number
}): number {
  const { screenSize, deviceType } = getScreenInfo()

  if (deviceType === 'tablet' && values.tablet !== undefined) {
    return values.tablet
  }

  return values[screenSize] ?? values.medium ?? values.large ?? values.small ?? 0
}

export function getResponsiveFontSize(baseFontSize: number): number {
  const { screenSize } = getScreenInfo()
  const scaleMap = {
    small: 0.9,
    medium: 1,
    large: 1.1,
  }
  return Math.round(baseFontSize * scaleMap[screenSize])
}

export function getSafeAreaPadding(): {
  top: number
  bottom: number
  left: number
  right: number
} {
  const { safeArea, height, width } = getScreenInfo()
  return {
    top: safeArea.top,
    bottom: height - safeArea.bottom,
    left: safeArea.left,
    right: width - safeArea.right,
  }
}

export function clearScreenInfoCache(): void {
  cachedScreenInfo = null
}

export function isLandscape(): boolean {
  return getScreenInfo().orientation === 'landscape'
}

export function isTablet(): boolean {
  return getScreenInfo().deviceType === 'tablet'
}

export function hasNotch(): boolean {
  return getScreenInfo().isNotch
}
