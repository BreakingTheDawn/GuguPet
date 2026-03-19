import { View, Text } from '@tarojs/components'
import { useState } from 'react'
import { ColumnCard } from '../../../components/ColumnCard'
import { Modal } from '../../../components/Modal'
import { texts, columns, ColumnItem } from '../../../config'
import { useScreen } from '../../../hooks'
import './index.scss'

export default function KnowledgePage() {
  const [selectedColumn, setSelectedColumn] = useState<ColumnItem | null>(null)
  const [showPreview, setShowPreview] = useState(false)
  const { getResponsiveFontSize } = useScreen()

  const handleColumnClick = (column: ColumnItem) => {
    setSelectedColumn(column)
    setShowPreview(true)
  }

  return (
    <View className="knowledge-page">
      <View className="knowledge-header">
        <Text
          className="knowledge-title"
          style={{ fontSize: getResponsiveFontSize(28) }}
        >
          {texts.knowledge.title}
        </Text>
        <Text className="knowledge-subtitle">{texts.knowledge.subtitle}</Text>
      </View>

      <View className="banner-section">
        <View className="banner-content">
          <Text className="banner-title">{columns.banner.title}</Text>
          <Text className="banner-desc">{columns.banner.description}</Text>
        </View>
        <View className="banner-bird">
          <Text style={{ fontSize: getResponsiveFontSize(48) }}>📚</Text>
        </View>
      </View>

      <View className="columns-section">
        <View className="section-header">
          <Text className="section-title">热门专栏</Text>
        </View>
        <View className="columns-list">
          {columns.columns.map((column) => (
            <ColumnCard
              key={column.id}
              title={column.title}
              description={column.description}
              price={column.price}
              author={column.author}
              readCount={column.readCount}
              image={column.image}
              onClick={() => handleColumnClick(column)}
            />
          ))}
        </View>
      </View>

      <Modal
        visible={showPreview}
        title={selectedColumn?.title || ''}
        content={selectedColumn ? `作者: ${selectedColumn.author}\n价格: ¥${selectedColumn.price}\n\n${selectedColumn.description}\n\n精彩内容预览即将上线...` : ''}
        confirmText="立即购买"
        cancelText="再看看"
        onConfirm={() => {
          setShowPreview(false)
        }}
        onCancel={() => setShowPreview(false)}
        onClose={() => setShowPreview(false)}
      />
    </View>
  )
}
