import { View, Text } from '@tarojs/components'
import { useState, useEffect } from 'react'
import './index.scss'

interface ToastProps {
  message: string
  visible: boolean
  duration?: number
  type?: 'success' | 'error' | 'info'
  onClose?: () => void
}

export function Toast({ message, visible, duration = 2000, type = 'info', onClose }: ToastProps) {
  useEffect(() => {
    if (visible && duration > 0) {
      const timer = setTimeout(() => {
        onClose?.()
      }, duration)
      return () => clearTimeout(timer)
    }
  }, [visible, duration, onClose])

  if (!visible) return null

  return (
    <View className={`toast toast-${type}`}>
      <Text className="toast-message">{message}</Text>
    </View>
  )
}

let toastInstance: { show: (message: string, type?: 'success' | 'error' | 'info') => void } | null = null

export function showToast(message: string, type: 'success' | 'error' | 'info' = 'info') {
  if (toastInstance) {
    toastInstance.show(message, type)
  }
}

export function initToast(instance: typeof toastInstance) {
  toastInstance = instance
}
