import { View, Text } from '@tarojs/components'
import { useEffect, useState } from 'react'
import './index.scss'

export interface ActionSheetOption {
  key: string
  label: string
  color?: string
  onClick?: () => void
}

interface ActionSheetProps {
  visible: boolean
  title?: string
  options: ActionSheetOption[]
  onClose?: () => void
}

export function ActionSheet({ visible, title, options, onClose }: ActionSheetProps) {
  const [show, setShow] = useState(visible)

  useEffect(() => {
    setShow(visible)
  }, [visible])

  const handleSelect = (option: ActionSheetOption) => {
    setShow(false)
    option.onClick?.()
    onClose?.()
  }

  const handleClose = () => {
    setShow(false)
    onClose?.()
  }

  if (!show && !visible) return null

  return (
    <View className={`actionsheet-overlay ${visible ? 'active' : ''}`} onClick={handleClose}>
      <View className="actionsheet-container" onClick={(e) => e.stopPropagation()}>
        {title && <Text className="actionsheet-title">{title}</Text>}
        <View className="actionsheet-options">
          {options.map((option) => (
            <View
              key={option.key}
              className="actionsheet-option"
              style={{ color: option.color || 'var(--text-primary)' }}
              onClick={() => handleSelect(option)}
            >
              <Text>{option.label}</Text>
            </View>
          ))}
        </View>
        <View className="actionsheet-cancel" onClick={handleClose}>
          <Text>取消</Text>
        </View>
      </View>
    </View>
  )
}
