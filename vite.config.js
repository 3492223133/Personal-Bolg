/**
 * Vite 配置文件
 * 包含代理、别名等配置
 */

import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  // 开发服务器配置
  server: {
    port: 5173,  // 前端端口
    // 代理配置 - 解决 CORS 跨域问题
    proxy: {
      '/api': {
        target: 'http://localhost:8080',  // 后端服务地址
        changeOrigin: true,  // 允许跨域
        secure: false,  // 如果是 https 接口，需要配置这个参数
        // 路径重写（如果后端接口没有 /api 前缀才需要）
        // rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
