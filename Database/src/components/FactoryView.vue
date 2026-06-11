<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>生產進度管理</h2>
    </div>

    <el-table :data="viewData" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="order_id" label="訂單編號" width="160" sortable fixed />
      <el-table-column prop="product_id" label="產品編號" width="140" />
      <el-table-column label="產品規格" min-width="180">
        <template #default="scope">
          {{ scope.row.material_grade }} {{ scope.row.thread_size }} {{ scope.row.head_type || '' }}
        </template>
      </el-table-column>
      <el-table-column prop="quantity" label="生產數量" width="100" align="right" />
      <el-table-column prop="packaging_type" label="包裝方式" width="100" align="center" />
      
      <el-table-column label="生產進度" width="160" align="center">
        <template #default="scope">
          <el-select 
            v-model="scope.row.production_status" 
            @change="(val) => handleStatusChange(scope.row, val)"
            style="width: 100%"
            :class="getStatusClass(scope.row.production_status)"
          >
            <el-option label="待進料" value="待進料" />
            <el-option label="打頭中" value="打頭中" />
            <el-option label="搓牙中" value="搓牙中" />
            <el-option label="待包裝" value="待包裝" />
            <el-option label="已完成" value="已完成" />
          </el-select>
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
    const response = await fetch('http://localhost:8000/api/view/factory-production')
    const json = await response.json()
    if (json.status === 'success') {
      viewData.value = json.data
    }
  } catch (error) {
    ElMessage.error('撈取工廠視圖資料失敗')
  } finally {
    loading.value = false
  }
}

const handleStatusChange = async (row, newStatus) => {
  try {
    const response = await fetch(`http://localhost:8000/api/orders/${row.order_id}/details/${row.product_id}/production-status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ production_status: newStatus })
    })
    
    const json = await response.json()
    if (json.status === 'success') {
      ElMessage.success(`訂單 ${row.order_id} 產品 ${row.product_id} 狀態已更新為：${newStatus}`)
    } else {
      ElMessage.error(json.message)
      // 回滾狀態
      fetchViewData()
    }
  } catch (error) {
    ElMessage.error('更新生產進度失敗')
    fetchViewData()
  }
}

const getStatusClass = (status) => {
  if (status === '已完成') return 'status-success'
  if (status === '搓牙中' || status === '打頭中') return 'status-warning'
  if (status === '待進料') return 'status-info'
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
/* 可選：針對下拉選單增加顏色樣式，但 Element UI 的 el-select 原生不支援直接變色，這裡可用自訂 class */
:deep(.status-success .el-input__inner) {
  color: #67C23A;
  font-weight: bold;
}
:deep(.status-warning .el-input__inner) {
  color: #E6A23C;
  font-weight: bold;
}
</style>
