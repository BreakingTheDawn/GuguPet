import { View, Text, Switch } from '@tarojs/components'
import { useState } from 'react'
import { useStore } from '../../store'
import { menu, texts, colors, getRandomPetMessage } from '../../config'
import { useScreen } from '../../hooks'
import Bird3D from '../../components/Bird3D'
import './index.scss'

export default function ProfilePage() {
  const [birdState, setBirdState] = useState<'idle' | 'dancing'>('idle')
  const [birdMsg, setBirdMsg] = useState('')
  const [showBirdMsg, setShowBirdMsg] = useState(false)
  const [darkMode, setDarkMode] = useState(false)
  const { user } = useStore()
  const { getResponsiveValue, getResponsiveFontSize } = useScreen()

  const handleBirdTap = () => {
    const msg = getRandomPetMessage()
    setBirdMsg(msg)
    setShowBirdMsg(true)
    setBirdState('dancing')

    setTimeout(() => {
      setBirdState('idle')
    }, 1800)

    setTimeout(() => {
      setShowBirdMsg(false)
    }, 2500)
  }

  const statsData = [
    { value: 45, label: texts.profile.statsLabels.days },
    { value: 28, label: texts.profile.statsLabels.applications },
    { value: 3, label: texts.profile.statsLabels.interviews },
  ]

  const progressData = [
    { key: 'interview', value: 3, max: 10, label: texts.profile.progressLabels.interview },
    { key: 'offer', value: 1, max: 10, label: texts.profile.progressLabels.offer },
    { key: 'rejected', value: 2, max: 10, label: texts.profile.progressLabels.rejected },
  ]

  const getProgressColor = (key: string) => {
    const colorMap = {
      interview: colors.progress.interview.fill,
      offer: colors.progress.offer.fill,
      rejected: colors.progress.rejected.fill,
    }
    return colorMap[key as keyof typeof colorMap] || colors.primary
  }

  const getProgressMutedClass = (key: string) => {
    return key === 'offer' ? 'success' : key === 'rejected' ? 'muted' : ''
  }

  return (
    <View className="profile-page">
      <View className="profile-header">
        <Text
          className="profile-title"
          style={{ fontSize: getResponsiveFontSize(28) }}
        >
          {texts.profile.title}
        </Text>
      </View>

      <View className="user-section">
        <View className="user-card">
          <View className="user-info">
            <View className="user-avatar">
              <Text style={{ fontSize: getResponsiveFontSize(32) }}>👤</Text>
            </View>
            <View className="user-details">
              <Text className="user-name">{texts.profile.defaultUserName}</Text>
              <Text className="user-status">{texts.profile.defaultUserStatus}</Text>
            </View>
          </View>

          <View className="pet-section" onClick={handleBirdTap}>
            <Bird3D isHappy={birdState === 'dancing'} />
            {showBirdMsg && (
              <View className="pet-message">
                <Text>{birdMsg}</Text>
              </View>
            )}
          </View>
        </View>

        <View className="stats-card">
          {statsData.map((stat, index) => (
            <View key={stat.label} className="stat-item-wrapper">
              <View className="stat-item">
                <Text className="stat-value">{stat.value}</Text>
                <Text className="stat-label">{stat.label}</Text>
              </View>
              {index < statsData.length - 1 && <View className="stat-divider" />}
            </View>
          ))}
        </View>
      </View>

      <View className="progress-section">
        <View className="section-header">
          <Text className="section-title">{texts.profile.progressLabels.interview}</Text>
        </View>
        <View className="progress-card">
          {progressData.map((item) => (
            <View key={item.key} className="progress-item">
              <View className="progress-bar">
                <View
                  className={`progress-fill ${getProgressMutedClass(item.key)}`}
                  style={{
                    width: `${(item.value / item.max) * 100}%`,
                    backgroundColor: getProgressColor(item.key),
                  }}
                />
              </View>
              <View className="progress-info">
                <Text className="progress-label">{item.label}</Text>
                <Text className={`progress-value ${getProgressMutedClass(item.key)}`}>
                  {item.value}
                </Text>
              </View>
            </View>
          ))}
        </View>
      </View>

      <View className="menu-section">
        <View className="menu-list">
          {menu.profile.menuItems.map((item, index) => (
            <View
              key={item.key}
              className={`menu-item ${index === menu.profile.menuItems.length - 1 ? 'last' : ''}`}
            >
              <View className="menu-icon">
                <Text>{item.icon}</Text>
              </View>
              <Text className="menu-label">{item.label}</Text>
              <Text className="menu-arrow">›</Text>
            </View>
          ))}
        </View>
      </View>

      <View className="settings-section">
        <View className="settings-card">
          <View className="settings-item">
            <Text className="settings-label">深色模式</Text>
            <Switch
              checked={darkMode}
              onChange={(e) => setDarkMode(e.detail.value)}
              color={colors.primary}
            />
          </View>
        </View>
      </View>
    </View>
  )
}
