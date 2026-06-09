import { createRouter, createWebHistory } from 'vue-router'

// 1. 引入各個功能頁面的元件
import OrderOverview from '../components/OrderOverview.vue'
// 提示：後續可以建立這三個對應的元件檔案
import ProductManagement from '../components/ProductManagement.vue' 
import CustomerManagement from '../components/CustomerManagement.vue'
import PurchaseManagement from '../components/PurchaseManagement.vue'

// 2. 定義路由清單
const routes = [
  {
    path: '/',
    redirect: '/orders' // 預設首頁重新導向到訂單畫面
  },
  {
    path: '/orders',
    name: 'Orders',
    component: OrderOverview
  },
  {
    path: '/products',
    name: 'Products',
    component: ProductManagement
  },
  {
    path: '/customers',
    name: 'Customers',
    component: CustomerManagement
  },
  {
    path: '/purchases',
    name: 'Purchases',
    component: PurchaseManagement
  }
]

// 3. 建立路由實例
const router = createRouter({
  history: createWebHistory(), // 使用 HTML5 History 模式（網址不會有 # 號）
  routes
})

export default router