<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>訂單財務總覽</h2>
    </div>

    <el-table :data="viewData" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="order_id" label="訂單編號" width="160" sortable fixed />
      <el-table-column prop="customer_name" label="客戶名稱" min-width="180" />
      <el-table-column prop="order_status" label="訂單狀態" width="120" align="center">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.order_status)">{{ scope.row.order_status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="total_order_amount" label="訂單總金額" width="160" align="right">
        <template #default="scope">
          <strong style="color: #F56C6C;">NT$ {{ formatAmount(scope.row.total_order_amount) }}</strong>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const viewData = ref([])
const loading = ref(true)

const fetchViewData = async () => {
  try {
    loading.value = true
    const response = await fetch('http://localhost:8000/api/view/order-financial-summary')
    const json = await response.json()
    if (json.status === 'success') {
      viewData.value = json.data
    }
  } catch (error) {
    ElMessage.error('撈取會計視圖資料失敗')
  } finally {
    loading.value = false
  }
}

const getStatusType = (status) => {
  if (status === '已結清') return 'success'
  if (status === '待結款') return 'warning'
  if (status === '草稿') return 'info'
  return ''
}

const formatAmount = (amount) => {
  if (amount === null || amount === undefined) return '0'
  return Number(amount).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

onMounted(() => {
  fetchViewData()
})
</script>

<style scoped>
.page-container {
  padding: 20px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}
.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
h2 {
  margin: 0;
  color: #303133;
}
</style>
