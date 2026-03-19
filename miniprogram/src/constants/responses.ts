export const petResponses = [
  { pattern: /累|疲|倦|撑|崩|烦|难|苦|压力/, text: '累了就歇歇，你已经很努力了 🤍 轻轻抱抱你~' },
  { pattern: /面试|hr|HR|笔试|offer|Offer|OFFER/, text: '面试官看到你一定会心动的！咕咕为你加油 ✨' },
  { pattern: /拒|没过|挂|凉|凉凉|拒绝|失败/, text: '他们眼光有问题！你是最棒的，咕咕最喜欢你 🫂' },
  { pattern: /开心|高兴|棒|好消息|发|拿到|通过|过了/, text: '太好了！咕咕也为你感到超级开心~ 🎉🎊' },
  { pattern: /不知道|迷茫|迷失|找不到|方向/, text: '迷茫也没关系，每一步都算数的，我一直陪着你 🌟' },
]

export const defaultResponses = [
  '嗯嗯，我都听到了，说出来感觉好一点了吗？ 🐧',
  '你已经很棒了，不管怎样咕咕都支持你 ✨',
  '今天的委屈，明天变成铠甲，加油！',
  '咕咕在这里，轻轻抱抱你 🤍',
]

export function getPetResponse(userText: string): string {
  for (const response of petResponses) {
    if (response.pattern.test(userText)) {
      return response.text
    }
  }
  return defaultResponses[Math.floor(Math.random() * defaultResponses.length)]
}
