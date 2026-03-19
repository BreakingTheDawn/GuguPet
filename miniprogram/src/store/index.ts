import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { storage } from '../services/storage'

interface User {
  id: string
  name: string
  avatar?: string
}

interface Pet {
  mood: 'idle' | 'happy' | 'sad' | 'thinking'
  name: string
}

interface Countdown {
  id: string
  title: string
  date: string
  color: 'pink' | 'blue' | 'green' | 'purple'
}

interface AppState {
  user: User | null
  setUser: (user: User | null) => void

  pet: Pet
  setPetMood: (mood: Pet['mood']) => void

  countdowns: Countdown[]
  addCountdown: (countdown: Countdown) => void
  removeCountdown: (id: string) => void
  updateCountdown: (id: string, updates: Partial<Countdown>) => void

  messages: Array<{ id: string; role: 'user' | 'pet'; content: string; timestamp: number }>
  addMessage: (role: 'user' | 'pet', content: string) => void
  clearMessages: () => void
}

const customStorage = {
  getItem: (name: string): string | null => {
    try {
      const value = storage.get(name)
      return value ? JSON.stringify(value) : null
    } catch {
      return null
    }
  },
  setItem: (name: string, value: string): void => {
    try {
      storage.set(name, JSON.parse(value))
    } catch {
      // ignore
    }
  },
  removeItem: (name: string): void => {
    try {
      storage.remove(name)
    } catch {
      // ignore
    }
  },
}

export const useStore = create<AppState>()(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),

      pet: {
        mood: 'idle',
        name: '咕咕',
      },
      setPetMood: (mood) => set((state) => ({ pet: { ...state.pet, mood } })),

      countdowns: [],
      addCountdown: (countdown) =>
        set((state) => ({
          countdowns: [...state.countdowns, countdown],
        })),
      removeCountdown: (id) =>
        set((state) => ({
          countdowns: state.countdowns.filter((c) => c.id !== id),
        })),
      updateCountdown: (id, updates) =>
        set((state) => ({
          countdowns: state.countdowns.map((c) =>
            c.id === id ? { ...c, ...updates } : c
          ),
        })),

      messages: [],
      addMessage: (role, content) =>
        set((state) => ({
          messages: [
            ...state.messages,
            { id: Date.now().toString(), role, content, timestamp: Date.now() },
          ],
        })),
      clearMessages: () => set({ messages: [] }),
    }),
    {
      name: 'gugupet-storage',
      storage: createJSONStorage(() => customStorage),
    }
  )
)
