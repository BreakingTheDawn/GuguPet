import Taro from '@tarojs/taro'

export const storage = {
  get<T>(key: string): T | null {
    try {
      const value = Taro.getStorageSync(key)
      return value ? JSON.parse(value) : null
    } catch {
      return null
    }
  },

  set<T>(key: string, value: T): void {
    try {
      Taro.setStorageSync(key, JSON.stringify(value))
    } catch {
      // ignore
    }
  },

  remove(key: string): void {
    try {
      Taro.removeStorageSync(key)
    } catch {
      // ignore
    }
  },

  clear(): void {
    try {
      Taro.clearStorageSync()
    } catch {
      // ignore
    }
  },
}

export const router = {
  navigateTo(url: string, params?: Record<string, any>) {
    const queryString = params
      ? '?' + Object.entries(params).map(([k, v]) => `${k}=${encodeURIComponent(v)}`).join('&')
      : ''
    Taro.navigateTo({ url: url + queryString })
  },

  navigateBack(delta = 1) {
    Taro.navigateBack({ delta })
  },

  switchTab(url: string) {
    Taro.switchTab({ url })
  },

  reLaunch(url: string) {
    Taro.reLaunch({ url })
  },
}
