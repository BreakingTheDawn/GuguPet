import { View, Text } from '@tarojs/components'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import { getCountdownColorConfig, ColorType } from '../../config'
import './index.scss'

dayjs.extend(relativeTime)

interface CountdownCardProps {
  title: string
  date: string
  color: ColorType
  onDelete?: () => void
}

export function CountdownCard({ title, date, color, onDelete }: CountdownCardProps) {
  const targetDate = dayjs(date)
  const now = dayjs()
  const daysLeft = targetDate.diff(now, 'day')
  const isExpired = daysLeft < 0
  const displayDays = isExpired ? 0 : daysLeft

  const colorConfig = getCountdownColorConfig(color)

  return (
    <View className="countdown-card" style={{ backgroundColor: colorConfig.bg }}>
      <View className="countdown-header">
        <Text className="countdown-tag" style={{ color: colorConfig.text }}>
          {colorConfig.name}
        </Text>
        {onDelete && (
          <View className="countdown-delete" onClick={onDelete}>
            <Text>×</Text>
          </View>
        )}
      </View>
      <Text className="countdown-title">{title}</Text>
      <View className="countdown-days">
        <Text className="countdown-number" style={{ color: colorConfig.text }}>
          {displayDays}
        </Text>
        <Text className="countdown-unit" style={{ color: colorConfig.text }}>
          天
        </Text>
      </View>
      <Text className="countdown-date">{targetDate.format('MM月DD日')}</Text>
    </View>
  )
}
