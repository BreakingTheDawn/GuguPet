import { View, Text, Button } from '@tarojs/components'
import { useEffect, useState } from 'react'
import './index.scss'

interface ModalProps {
  visible: boolean
  title?: string
  content?: string
  showCancel?: boolean
  confirmText?: string
  cancelText?: string
  onConfirm?: () => void
  onCancel?: () => void
  onClose?: () => void
  children?: React.ReactNode
}

export function Modal({
  visible,
  title,
  content,
  showCancel = true,
  confirmText = '确定',
  cancelText = '取消',
  onConfirm,
  onCancel,
  onClose,
  children,
}: ModalProps) {
  const [show, setShow] = useState(visible)

  useEffect(() => {
    setShow(visible)
  }, [visible])

  const handleCancel = () => {
    setShow(false)
    onCancel?.()
    onClose?.()
  }

  const handleConfirm = () => {
    onConfirm?.()
    onClose?.()
  }

  if (!show && !visible) return null

  return (
    <View className={`modal-overlay ${visible ? 'active' : ''}`} onClick={handleCancel}>
      <View className="modal-container" onClick={(e) => e.stopPropagation()}>
        {title && <Text className="modal-title">{title}</Text>}
        {content && <Text className="modal-content">{content}</Text>}
        {children}
        <View className="modal-actions">
          {showCancel && (
            <Button className="modal-btn modal-btn-cancel" onClick={handleCancel}>
              {cancelText}
            </Button>
          )}
          <Button className="modal-btn modal-btn-confirm" onClick={handleConfirm}>
            {confirmText}
          </Button>
        </View>
      </View>
    </View>
  )
}
