import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

const devServerPort = Number(process.env.VITE_DEV_SERVER_PORT ?? '3036')
const devServerHost = process.env.VITE_DEV_SERVER_HOST ?? '0.0.0.0'
const hmrHost = process.env.VITE_HMR_HOST ?? devServerHost
const hmrPort = Number(process.env.VITE_HMR_PORT ?? devServerPort)
const hmrProtocol = process.env.VITE_HMR_PROTOCOL ?? 'ws'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  server: {
    host: devServerHost,
    port: devServerPort,
    strictPort: true,
    hmr: {
      host: hmrHost,
      port: hmrPort,
      protocol: hmrProtocol,
    },
  },
})
