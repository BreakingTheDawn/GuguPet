import { View, Text } from '@tarojs/components'
import { useState } from 'react'
import Taro from '@tarojs/taro'
import './index.scss'

interface TabItem {
  pagePath: string
  text: string
  icon: string
  activeIcon: string
}

const tabList: TabItem[] = [
  { pagePath: '/pages/home/index', text: '倾诉室', icon: '🏠', activeIcon: '🏠' },
  { pagePath: '/subpackages/stats/pages/index', text: '看板', icon: '📊', activeIcon: '📊' },
  { pagePath: '/subpackages/knowledge/pages/index', text: '专栏', icon: '📚', activeIcon: '📚' },
  { pagePath: '/pages/profile/index', text: '我的', icon: '👤', activeIcon: '👤' },
]

export default function TabBar() {
  const [current, setCurrent] = useState(0)

  const handleTabClick = (index: number, path: string) => {
    setCurrent(index)
    Taro.switchTab({ url: path })
  }

  return (
    <View className="custom-tabbar">
      {tabList.map((item, index) => (
        <View
          key={item.pagePath}
          className={`tabbar-item ${current === index ? 'active' : ''}`}
          onClick={() => handleTabClick(index, item.pagePath)}
        >
          <Text className="tabbar-icon">{current === index ? item.activeIcon : item.icon}</Text>
          <Text className="tabbar-text">{item.text}</Text>
        </View>
      ))}
    </View>
  )
}
