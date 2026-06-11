<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>業務查看系統</h2>
    </div>

    <el-table :data="viewData" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="訂單編號" label="訂單編號" width="160" sortable fixed />
      <el-table-column prop="客戶名稱" label="客戶名稱" min-width="180" />
      <el-table-column prop="下單時間" label="下單時間" width="160">
        <template #default="scope">
          {{ formatDateTime(scope.row.下單時間) }}
        </template>
      </el-table-column>
      <el-table-column prop="產品編號" label="產品編號" width="140" />
      <el-table-column prop="產品規格" label="產品規格" min-width="180" />
      <el-table-column prop="數量" label="數量" width="100" align="right" />
      <el-table-column prop="單價" label="單價" width="100" align="right">
        <template #default="scope">
          NT$ {{ scope.row.單價 }}
        </template>
      </el-table-column>
      <el-table-column prop="生產進度" label="產線進度" width="100" align="center">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.生產進度)">{{ scope.row.生產進度 }}</el-tag>
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
    const response = await fetch('http://localhost:8000/api/view/order-details')
    const json = await response.json()
    if (json.status === 'success') {
      viewData.value = json.data
    }
  } catch (error) {
    ElMessage.error('撈取業務視圖資料失敗')
  } finally {
    loading.value = false
  }
}

const formatDateTime = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('zh-TW', { 
    year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' 
  })
}

const getStatusType = (status) => {
  if (status === '已完成') return 'success'
  if (status === '搓牙中' || status === '打頭中') return 'warning'
  if (status === '待進料') return 'info'
  return ''
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
