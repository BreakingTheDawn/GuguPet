import { Component } from 'react'
import './app.scss'

class App extends Component {
  componentDidMount() {
    console.log('App launched.')
  }

  render() {
    return this.props.children
  }
}

export default App
