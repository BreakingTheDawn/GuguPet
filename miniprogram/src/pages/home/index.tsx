import { View, Text, Input } from '@tarojs/components'
import { useState, useRef, useEffect } from 'react'
import { useStore } from '../../store'
import { getPetResponse } from '../../constants/responses'
import { texts, ui } from '../../config'
import { useScreen } from '../../hooks'
import Bird3D from '../../components/Bird3D'
import './index.scss'

export default function HomePage() {
  const [inputValue, setInputValue] = useState('')
  const [isHappy, setIsHappy] = useState(false)
  const [showResponse, setShowResponse] = useState(false)
  const [petMessage, setPetMessage] = useState('')
  const messagesEndRef = useRef<any>(null)
  
  const { messages, addMessage } = useStore()
  const { getResponsiveFontSize, safeAreaPadding } = useScreen()

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSend = () => {
    if (!inputValue.trim()) return

    addMessage('user', inputValue.trim())
    const response = getPetResponse(inputValue.trim())
    
    setInputValue('')
    setIsHappy(true)
    setPetMessage(response)

    setTimeout(() => {
      addMessage('pet', response)
      setShowResponse(true)
    }, ui.animation.responseDelay)

    setTimeout(() => {
      setIsHappy(false)
    }, ui.animation.happyDuration)
  }

  const handleHappyEnd = () => {
    setTimeout(() => {
      setShowResponse(false)
    }, ui.animation.responseDelay)
  }

  return (
    <View className="home-page">
      <View className="home-header">
        <Text
          className="home-title"
          style={{ fontSize: getResponsiveFontSize(28) }}
        >
          {texts.home.title}
        </Text>
        <Text className="home-subtitle">{texts.home.subtitle}</Text>
      </View>

      <View className="messages-container">
        {messages.length === 0 ? (
          <View className="empty-state">
            <Text
              className="empty-text"
              style={{ fontSize: getResponsiveFontSize(18) }}
            >
              {texts.home.emptyText}
            </Text>
            <Text className="empty-subtext">{texts.home.emptySubtext}</Text>
          </View>
        ) : (
          messages.map((msg) => (
            <View
              key={msg.id}
              className={`message message-${msg.role}`}
            >
              {msg.role === 'pet' && (
                <View className="message-avatar">
                  <Text>🫂</Text>
                </View>
              )}
              <View className="message-bubble">
                <Text>{msg.content}</Text>
              </View>
              {msg.role === 'user' && (
                <View className="message-avatar user">
                  <Text>👤</Text>
                </View>
              )}
            </View>
          ))
        )}
        {showResponse && (
          <View className="message message-pet">
            <View className="message-avatar">
              <Text>🫂</Text>
            </View>
            <View className="message-bubble">
              <Text>{petMessage}</Text>
            </View>
          </View>
        )}
        <View ref={messagesEndRef} />
      </View>

      <View className="bird-section">
        <Bird3D isHappy={isHappy} onHappyEnd={handleHappyEnd} />
      </View>

      <View
        className="input-section"
        style={{ paddingBottom: `calc(12px + ${safeAreaPadding.bottom}px)` }}
      >
        <View className="input-wrapper">
          <Input
            className="message-input"
            placeholder={texts.home.inputPlaceholder}
            value={inputValue}
            onInput={(e) => setInputValue(e.detail.value)}
            onConfirm={handleSend}
            confirmType="send"
          />
          <View className="send-btn" onClick={handleSend}>
            <Text>发送</Text>
          </View>
        </View>
      </View>
    </View>
  )
}
