<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>訂單總覽</h2>
      <el-button type="primary" @click="fetchOrders">重新整理</el-button>
    </div>

    <el-alert v-if="error" :title="error" type="error" show-icon class="alert" />

    <el-table :data="orderList" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="order_id" label="訂單編號" width="130" fixed />
      <el-table-column prop="customer_id" label="客戶編號" width="130" />
      <el-table-column prop="customer_name" label="客戶名稱" min-width="180" />
      <el-table-column prop="employee_id" label="員工編號" width="120" />
      <el-table-column prop="order_date" label="訂單日期" width="180" />
      <el-table-column prop="required_date" label="需求日期" width="180" />
      <el-table-column prop="order_status" label="狀態" width="130" />
    </el-table>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000'

const orderList = ref([])
const loading = ref(false)
const error = ref('')

const fetchOrders = async () => {
  loading.value = true
  error.value = ''
  try {
    const response = await fetch(`${API_BASE_URL}/api/orders`)
    const json = await response.json()
    if (!response.ok || json.status !== 'success') {
      throw new Error(json.detail || json.message || '訂單資料讀取失敗')
    }
    orderList.value = json.data
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(fetchOrders)
</script>

<style scoped>
.page-container {
  padding: 20px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.alert {
  margin-bottom: 16px;
}

h2 {
  margin: 0;
  color: #303133;
}
</style>
