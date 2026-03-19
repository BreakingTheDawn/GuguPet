import { View, Text } from '@tarojs/components'
import { useState, useEffect } from 'react'
import './index.scss'

interface Bird3DProps {
  isHappy?: boolean
  onHappyEnd?: () => void
}

export default function Bird3D({ isHappy = false, onHappyEnd }: Bird3DProps) {
  const [animationClass, setAnimationClass] = useState('bird-idle')

  useEffect(() => {
    if (isHappy) {
      setAnimationClass('bird-happy')
      const timer = setTimeout(() => {
        setAnimationClass('bird-idle')
        onHappyEnd?.()
      }, 1800)
      return () => clearTimeout(timer)
    }
  }, [isHappy, onHappyEnd])

  return (
    <View className="bird-container">
      <View className={`bird-shadow ${isHappy ? 'shadow-happy' : ''}`} />
      <View className={`bird-wrapper ${animationClass}`}>
        <View className="bird-emoji">🐧</View>
      </View>
      <View className="side-bubble">
        {isHappy ? '🥰' : '🫂'}
      </View>
    </View>
  )
}
