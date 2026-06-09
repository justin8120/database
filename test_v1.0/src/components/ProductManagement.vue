<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>產品管理</h2>
      <el-button type="primary" @click="fetchProducts">重新整理</el-button>
    </div>

    <el-alert v-if="error" :title="error" type="error" show-icon class="alert" />

    <el-table :data="productList" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="product_id" label="產品編號" width="130" fixed />
      <el-table-column prop="material_grade" label="材質" width="100" />
      <el-table-column prop="thread_system" label="螺紋系統" width="120" />
      <el-table-column prop="thread_size" label="尺寸" width="100" />
      <el-table-column prop="thread_pitch" label="牙距" width="120" />
      <el-table-column prop="head_type" label="頭型" width="120" />
      <el-table-column prop="length_mm" label="長度 mm" width="110" align="right" />
      <el-table-column prop="unit" label="單位" width="100" />
    </el-table>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000'

const productList = ref([])
const loading = ref(false)
const error = ref('')

const fetchProducts = async () => {
  loading.value = true
  error.value = ''
  try {
    const response = await fetch(`${API_BASE_URL}/api/products`)
    const json = await response.json()
    if (!response.ok || json.status !== 'success') {
      throw new Error(json.detail || json.message || '產品資料讀取失敗')
    }
    productList.value = json.data
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(fetchProducts)
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
