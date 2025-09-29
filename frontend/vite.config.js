import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss({
      config: {
        content: ["./index.html", "./src/**/*.{js,jsx,ts,tsx}"],
        theme: {
          extend: {
            colors: {
              primary: {
                50: '#eff6ff',
                100: '#dbeafe',
                500: '#3b82f6',
                600: '#2563eb',
                700: '#1d4ed8',
              },
              gray: {
                50: '#f9fafb',
                100: '#f3f4f6',
                200: '#e5e7eb',
                300: '#d1d5db',
                400: '#9ca3af',
                500: '#6b7280',
                600: '#4b5563',
                700: '#374151',
                800: '#1f2937',
                900: '#111827',
              },
              green: {
                600: '#16a34a',
              },
            },
            animation: {
              'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
              'bounce-slow': 'bounce 2s infinite',
              'fade-in': 'fadeIn 0.3s ease-in-out',
              'check': 'check 0.5s ease-out forwards',
            },
            keyframes: {
              fadeIn: {
                'from': { opacity: 0, transform: 'translateY(10px)' },
                'to': { opacity: 1, transform: 'translateY(0)' },
              },
              check: {
                '0%': { transform: 'scale(0)' },
                '50%': { transform: 'scale(1.2)' },
                '100%': { transform: 'scale(1)' },
              },
            },
          },
        },
      },
    }),
  ],
})