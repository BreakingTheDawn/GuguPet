export default defineAppConfig({
  pages: [
    'pages/home/index',
    'pages/stats/index',
    'pages/knowledge/index',
    'pages/profile/index',
  ],
  window: {
    backgroundTextStyle: 'light',
    navigationBarBackgroundColor: '#FFF8EF',
    navigationBarTitleText: '职宠小窝',
    navigationBarTextStyle: 'black',
  },
  tabBar: {
    color: '#B0A8C8',
    selectedColor: '#6C5CE7',
    backgroundColor: '#FFFFFF',
    borderStyle: 'white',
    list: [
      { pagePath: 'pages/home/index', text: '倾诉室' },
      { pagePath: 'pages/stats/index', text: '看板' },
      { pagePath: 'pages/knowledge/index', text: '专栏' },
      { pagePath: 'pages/profile/index', text: '我的' },
    ],
  },
})
