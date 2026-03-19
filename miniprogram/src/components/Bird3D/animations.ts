import Taro from '@tarojs/taro'

// Bird3D animations configuration
export const birdAnimations = {
  idle: {
    duration: 4,
    repeat: Infinity,
    ease: 'easeInOut',
  },
  happy: {
    duration: 1.8,
    repeat: 1,
    ease: 'easeInOut',
  },
}

export const getDevicePerformance = (): 'high' | 'medium' | 'low' => {
  try {
    // 使用新的 API 替代已弃用的 getSystemInfoSync
    const deviceInfo = Taro.getDeviceInfo() as any
    const { benchmarkLevel } = deviceInfo
    if (benchmarkLevel >= 20) return 'high'
    if (benchmarkLevel >= 10) return 'medium'
    return 'low'
  } catch {
    return 'medium'
  }
}

export const getAnimationConfig = () => {
  const level = getDevicePerformance()

  const configs = {
    high: {
      enableFilter: true,
      enableShadow: true,
      fps: 60,
    },
    medium: {
      enableFilter: false,
      enableShadow: true,
      fps: 30,
    },
    low: {
      enableFilter: false,
      enableShadow: false,
      fps: 24,
    },
  }

  return configs[level]
}
