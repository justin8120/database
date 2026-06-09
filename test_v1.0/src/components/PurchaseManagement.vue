<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>原料進貨</h2>
      <el-button type="primary" @click="fetchPurchases">重新整理</el-button>
    </div>

    <el-alert v-if="error" :title="error" type="error" show-icon class="alert" />

    <el-table :data="purchaseList" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="purchase_id" label="進貨編號" width="130" fixed />
      <el-table-column prop="purchase_time" label="進貨時間" width="180" />
      <el-table-column prop="supplier_name" label="供應商" min-width="180" />
      <el-table-column prop="product_id" label="產品編號" width="130" />
      <el-table-column prop="product_spec" label="產品規格" min-width="220" />
      <el-table-column prop="quantity" label="數量" width="100" align="right" />
      <el-table-column prop="unit" label="單位" width="90" />
      <el-table-column label="總金額" width="140" align="right">
        <template #default="{ row }">
          {{ formatCurrency(row.total_amount) }}
        </template>
      </el-table-column>
      <el-table-column prop="employee_id" label="員工編號" width="120" />
    </el-table>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000'

const purchaseList = ref([])
const loading = ref(false)
const error = ref('')

const fetchPurchases = async () => {
  loading.value = true
  error.value = ''
  try {
    const response = await fetch(`${API_BASE_URL}/api/purchases`)
    const json = await response.json()
    if (!response.ok || json.status !== 'success') {
      throw new Error(json.detail || json.message || '進貨資料讀取失敗')
    }
    purchaseList.value = json.data
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

onMounted(fetchPurchases)
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
