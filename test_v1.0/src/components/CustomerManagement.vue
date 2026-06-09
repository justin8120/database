<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>客戶管理</h2>
      <el-button type="primary" @click="fetchCustomers">重新整理</el-button>
    </div>

    <el-alert v-if="error" :title="error" type="error" show-icon class="alert" />

    <el-table :data="customerList" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="customer_id" label="客戶編號" width="130" fixed />
      <el-table-column prop="customer_name" label="客戶名稱" min-width="180" />
      <el-table-column prop="contact_person" label="聯絡人" width="130" />
      <el-table-column prop="phone_number" label="電話" width="150" />
      <el-table-column prop="shipping_address" label="出貨地址" min-width="240" />
      <el-table-column label="信用額度" width="140" align="right">
        <template #default="{ row }">
          {{ formatCurrency(row.credit_limit) }}
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000'

const customerList = ref([])
const loading = ref(false)
const error = ref('')

const fetchCustomers = async () => {
  loading.value = true
  error.value = ''
  try {
    const response = await fetch(`${API_BASE_URL}/api/customers`)
    const json = await response.json()
    if (!response.ok || json.status !== 'success') {
      throw new Error(json.detail || json.message || '客戶資料讀取失敗')
    }
    customerList.value = json.data
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const formatCurrency = (value) => {
  if (value === null || value === undefined) return '0'
  return Number(value).toLocaleString()
}

onMounted(fetchCustomers)
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
