import { View, Text, Image } from '@tarojs/components'
import './index.scss'

interface ColumnCardProps {
  title: string
  description: string
  price: number
  image?: string
  author: string
  readCount: number
  onClick?: () => void
}

export function ColumnCard({
  title,
  description,
  price,
  image,
  author,
  readCount,
  onClick,
}: ColumnCardProps) {
  return (
    <View className="column-card" onClick={onClick}>
      {image && (
        <Image className="column-card-image" src={image} mode="aspectFill" />
      )}
      <View className="column-card-content">
        <Text className="column-card-title">{title}</Text>
        <Text className="column-card-desc">{description}</Text>
        <View className="column-card-footer">
          <View className="column-card-author">
            <Text className="column-card-author-name">{author}</Text>
          </View>
          <View className="column-card-info">
            <Text className="column-card-read">{readCount}人已读</Text>
            <Text className="column-card-price">¥{price}</Text>
          </View>
        </View>
      </View>
    </View>
  )
}
