import { useState, useEffect, useCallback } from 'react'
import Taro, { useReady } from '@tarojs/taro'
import {
  getScreenInfo,
  clearScreenInfoCache,
  ScreenInfo,
  ScreenSize,
  DeviceType,
  Orientation,
} from '../utils/screen'

export interface UseScreenReturn {
  screenInfo: ScreenInfo
  screenSize: ScreenSize
  deviceType: DeviceType
  orientation: Orientation
  isLandscape: boolean
  isTablet: boolean
  isNotch: boolean
  safeAreaPadding: {
    top: number
    bottom: number
    left: number
    right: number
  }
  getResponsiveValue: (values: {
    small?: number
    medium?: number
    large?: number
    tablet?: number
  }) => number
  getResponsiveFontSize: (baseFontSize: number) => number
}

export function useScreen(): UseScreenReturn {
  const [screenInfo, setScreenInfo] = useState<ScreenInfo>(getScreenInfo)

  const updateScreenInfo = useCallback(() => {
    clearScreenInfoCache()
    setScreenInfo(getScreenInfo())
  }, [])

  useReady(() => {
    updateScreenInfo()
  })

  useEffect(() => {
    const handleResize = () => {
      updateScreenInfo()
    }

    const unsubscribe = Taro.onWindowResize(handleResize)

    return () => {
      unsubscribe?.()
    }
  }, [updateScreenInfo])

  const getResponsiveValue = useCallback(
    (values: {
      small?: number
      medium?: number
      large?: number
      tablet?: number
    }): number => {
      const { screenSize, deviceType } = screenInfo

      if (deviceType === 'tablet' && values.tablet !== undefined) {
        return values.tablet
      }

      return values[screenSize] ?? values.medium ?? values.large ?? values.small ?? 0
    },
    [screenInfo]
  )

  const getResponsiveFontSize = useCallback(
    (baseFontSize: number): number => {
      const { screenSize } = screenInfo
      const scaleMap = {
        small: 0.9,
        medium: 1,
        large: 1.1,
      }
      return Math.round(baseFontSize * scaleMap[screenSize])
    },
    [screenInfo]
  )

  const safeAreaPadding = {
    top: screenInfo.safeArea.top,
    bottom: screenInfo.height - screenInfo.safeArea.bottom,
    left: screenInfo.safeArea.left,
    right: screenInfo.width - screenInfo.safeArea.right,
  }

  return {
    screenInfo,
    screenSize: screenInfo.screenSize,
    deviceType: screenInfo.deviceType,
    orientation: screenInfo.orientation,
    isLandscape: screenInfo.orientation === 'landscape',
    isTablet: screenInfo.deviceType === 'tablet',
    isNotch: screenInfo.isNotch,
    safeAreaPadding,
    getResponsiveValue,
    getResponsiveFontSize,
  }
}

export interface UseResponsiveLayoutReturn {
  containerStyle: Record<string, string | number>
  headerStyle: Record<string, string | number>
  cardStyle: Record<string, string | number>
  fontSize: {
    xs: number
    sm: number
    base: number
    lg: number
    xl: number
    '2xl': number
    '3xl': number
  }
  spacing: {
    xs: number
    sm: number
    md: number
    lg: number
    xl: number
  }
}

export function useResponsiveLayout(): UseResponsiveLayoutReturn {
  const { screenSize, getResponsiveValue, getResponsiveFontSize } = useScreen()

  const containerStyle = {
    paddingTop: getResponsiveValue({ small: 16, medium: 24, large: 28 }),
    paddingHorizontal: getResponsiveValue({ small: 16, medium: 20, large: 24 }),
    paddingBottom: getResponsiveValue({ small: 80, medium: 100, large: 120 }),
  }

  const headerStyle = {
    marginBottom: getResponsiveValue({ small: 16, medium: 24, large: 32 }),
  }

  const cardStyle = {
    padding: getResponsiveValue({ small: 16, medium: 20, large: 24 }),
    borderRadius: getResponsiveValue({ small: 12, medium: 16, large: 20 }),
  }

  const fontSize = {
    xs: getResponsiveFontSize(12),
    sm: getResponsiveFontSize(13),
    base: getResponsiveFontSize(14),
    lg: getResponsiveFontSize(16),
    xl: getResponsiveFontSize(18),
    '2xl': getResponsiveFontSize(20),
    '3xl': getResponsiveFontSize(24),
  }

  const spacing = {
    xs: getResponsiveValue({ small: 3, medium: 4, large: 5 }),
    sm: getResponsiveValue({ small: 6, medium: 8, large: 10 }),
    md: getResponsiveValue({ small: 12, medium: 16, large: 20 }),
    lg: getResponsiveValue({ small: 18, medium: 24, large: 30 }),
    xl: getResponsiveValue({ small: 24, medium: 32, large: 40 }),
  }

  return {
    containerStyle,
    headerStyle,
    cardStyle,
    fontSize,
    spacing,
  }
}
