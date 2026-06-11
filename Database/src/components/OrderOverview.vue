<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>訂單管理</h2>
      <el-button type="primary" size="large" @click="openDialog">
        <el-icon><Plus /></el-icon> 建立新訂單
      </el-button>
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
      <el-table-column label="目前庫存" width="120" align="right">
        <template #default="scope">
          {{ productOptions.find(p => p.product_id === scope.row.產品編號)?.stock ?? '-' }} {{ productOptions.find(p => p.product_id === scope.row.產品編號)?.unit ?? '' }}
        </template>
      </el-table-column>
      <el-table-column label="數量" width="120" align="right">
        <template #default="scope">
          {{ scope.row.數量 }} {{ productOptions.find(p => p.product_id === scope.row.產品編號)?.unit ?? '' }}
        </template>
      </el-table-column>
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
      
      <el-table-column label="操作" width="150" align="center" fixed="right">
        <template #default="scope">
          <el-button size="small" type="primary" plain @click="handleEdit(scope.row)">編輯</el-button>
          <el-button size="small" type="danger" plain @click="handleDelete(scope.row)">刪除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '編輯銷售訂單' : '建立新銷售訂單'" width="850px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        
        <h4 class="section-title">1. 訂單基本資訊</h4>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="訂單編號" prop="order_id">
              <el-input v-model="form.order_id" :disabled="isEdit" placeholder="例如: ORD-2026-001" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="選擇客戶" prop="customer_id">
              <el-select v-model="form.customer_id" filterable placeholder="請選擇下單客戶" style="width: 100%">
                <el-option 
                  v-for="c in customerOptions" 
                  :key="c.customer_id" 
                  :label="`${c.customer_id} - ${c.customer_name}`" 
                  :value="c.customer_id" 
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="下單時間" prop="order_date">
              <el-date-picker v-model="form.order_date" type="datetime" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="預計交期" prop="required_date">
              <el-date-picker v-model="form.required_date" type="datetime" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="負責業務" prop="employee_id">
          <el-input v-model="form.employee_id" placeholder="請輸入負責業務工號" style="width: 48%" />
        </el-form-item>

        <div class="detail-header">
          <h4 class="section-title" style="margin: 0;">2. 訂單產品明細</h4>
          <el-button type="success" size="small" plain @click="addDetailRow">
            <el-icon><Plus /></el-icon> 增加產品項目
          </el-button>
        </div>

        <el-table :data="form.details" border style="width: 100%; margin-top: 10px;">
          <el-table-column label="選擇產品" min-width="220">
            <template #default="scope">
              <el-select v-model="scope.row.product_id" filterable placeholder="選取規格" style="width: 100%">
                <el-option 
                  v-for="p in productOptions" 
                  :key="p.product_id" 
                  :label="`${p.product_id} (${p.material_grade} ${p.thread_size}) - 庫存: ${p.stock}`" 
                  :value="p.product_id" 
                />
              </el-select>
            </template>
          </el-table-column>

          <el-table-column label="目前庫存" width="90" align="center">
            <template #default="scope">
              {{ productOptions.find(p => p.product_id === scope.row.product_id)?.stock ?? '-' }}
            </template>
          </el-table-column>

          <el-table-column label="訂購數量" width="130">
            <template #default="scope">
              <el-input-number v-model="scope.row.quantity" :min="1" style="width: 100%" />
            </template>
          </el-table-column>

          <el-table-column label="單價" width="130">
            <template #default="scope">
              <el-input-number v-model="scope.row.unit_price" :min="0" :precision="2" :step="0.5" style="width: 100%" />
            </template>
          </el-table-column>

          <el-table-column label="包裝方式" width="110">
            <template #default="scope">
              <el-select v-model="scope.row.packaging_type">
                <el-option label="一箱" value="一箱" />
                <el-option label="一包" value="一包" />
                <el-option label="散裝" value="散裝" />
              </el-select>
            </template>
          </el-table-column>

          <el-table-column label="移除" width="80" align="center">
            <template #default="scope">
              <el-button type="danger" :icon="Delete" circle size="small" @click="removeDetailRow(scope.$index)" />
            </template>
          </el-table-column>
        </el-table>
        
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">
            {{ isEdit ? '確認更新訂單' : '確認建立訂單' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Plus, Delete } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const viewData = ref([])
const customerOptions = ref([])
const productOptions = ref([])
const loading = ref(true)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref(null)
const isEdit = ref(false)

const form = reactive({
  order_id: '',
  customer_id: '',
  employee_id: '',
  order_date: new Date(),
  required_date: new Date(new Date().setDate(new Date().getDate() + 7)),
  details: [
    { product_id: '', quantity: 1, unit_price: 0, packaging_type: '一箱' }
  ]
})

const rules = {
  order_id: [{ required: true, message: '請輸入訂單編號', trigger: 'blur' }],
  customer_id: [{ required: true, message: '請選擇客戶', trigger: 'change' }],
  employee_id: [{ required: true, message: '請輸入負責業務', trigger: 'blur' }],
  order_date: [{ required: true, message: '請選擇下單時間', trigger: 'change' }],
  required_date: [{ required: true, message: '請選擇預計交期', trigger: 'change' }]
}

const fetchViewData = async () => {
  try {
    loading.value = true
    const response = await fetch('http://localhost:8000/api/view/order-details')
    const json = await response.json()
    if (json.status === 'success') {
      viewData.value = json.data
    }
  } catch (error) {
    ElMessage.error('撈取訂單視圖資料失敗')
  } finally {
    loading.value = false
  }
}

const fetchOptions = async () => {
  try {
    const resCust = await fetch('http://localhost:8000/api/customers')
    const jsonCust = await resCust.json()
    if (jsonCust.status === 'success') customerOptions.value = jsonCust.data

    const resProd = await fetch('http://localhost:8000/api/products')
    const jsonProd = await resProd.json()
    if (jsonProd.status === 'success') productOptions.value = jsonProd.data
  } catch (error) {
    console.error('取得下拉選單選項失敗')
  }
}

const openDialog = () => {
  isEdit.value = false
  dialogVisible.value = true
}

// 🌟 點擊編輯按鈕的邏輯
const handleEdit = async (row) => {
  try {
    // 透過訂單編號，去後端撈取包含明細的完整訂單
    const response = await fetch(`http://localhost:8000/api/orders/${row.訂單編號}`)
    const json = await response.json()
    
    if (json.status === 'success') {
      const data = json.data
      isEdit.value = true
      
      // 將後端回傳的資料填入表單
      form.order_id = data.order_id
      form.customer_id = data.customer_id
      form.employee_id = data.employee_id
      form.order_date = new Date(data.order_date) // 字串轉回 Date 物件供日曆套件使用
      form.required_date = new Date(data.required_date)
      
      // 載入明細陣列
      form.details = data.details.map(d => ({
        product_id: d.product_id,
        quantity: d.quantity,
        unit_price: parseFloat(d.unit_price),
        packaging_type: d.packaging_type
      }))
      
      dialogVisible.value = true
    } else {
      ElMessage.error(json.message)
    }
  } catch (error) {
    ElMessage.error('無法讀取訂單詳細資料')
  }
}

// 🌟 點擊刪除按鈕的邏輯
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `確定要徹底刪除訂單「${row.訂單編號}」及其所有明細嗎？此操作無法復原。`,
    '嚴重警告',
    { confirmButtonText: '確定刪除', cancelButtonText: '取消', type: 'error' }
  ).then(async () => {
    try {
      const response = await fetch(`http://localhost:8000/api/orders/${row.訂單編號}`, {
        method: 'DELETE'
      })
      const json = await response.json()
      
      if (json.status === 'success') {
        ElMessage.success(json.message)
        fetchViewData()
      } else {
        ElMessage.error(json.message)
      }
    } catch (error) {
      ElMessage.error('連線伺服器失敗')
    }
  }).catch(() => {})
}

const addDetailRow = () => {
  form.details.push({ product_id: '', quantity: 1, unit_price: 0, packaging_type: '一箱' })
}

const removeDetailRow = (index) => {
  if (form.details.length === 1) {
    ElMessage.warning('訂單至少需要一筆產品明細！')
    return
  }
  form.details.splice(index, 1)
}

const submitForm = () => {
  if (!formRef.value) return
  
  const hasEmptyProduct = form.details.some(d => !d.product_id)
  if (hasEmptyProduct) {
    ElMessage.warning('請確保所有明細列都已選擇產品規格！')
    return
  }

  if (new Date(form.required_date) <= new Date(form.order_date)) {
    ElMessage.warning('預計交期必須晚於下單時間！')
    return
  }

  formRef.value.validate(async (valid) => {
    if (valid) {
      const hasInvalidPrice = form.details.some(d => d.unit_price <= 0)
      if (hasInvalidPrice) {
        ElMessage.warning('單價必須大於 0')
        return
      }

      try {
        submitLoading.value = true
        
        // 判斷網址與方法：編輯用 PUT，新增用 POST
        const url = isEdit.value 
          ? `http://localhost:8000/api/orders/${form.order_id}`
          : 'http://localhost:8000/api/orders'
        const method = isEdit.value ? 'PUT' : 'POST'

        const payload = JSON.parse(JSON.stringify(form))
        
        const response = await fetch(url, {
          method: method,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        })
        const json = await response.json()
        
        if (json.status === 'success') {
          ElMessage.success(json.message)
          dialogVisible.value = false
          fetchViewData()
        } else {
          ElMessage.error(json.message)
        }
      } catch (error) {
        ElMessage.error('連線伺服器失敗')
      } finally {
        submitLoading.value = false
      }
    } else {
      ElMessage.warning('請填寫所有主檔必填欄位')
      return false
    }
  })
}

const resetForm = () => {
  if (formRef.value) formRef.value.resetFields()
  form.order_id = ''
  form.details = [ { product_id: '', quantity: 1, unit_price: 0, packaging_type: '一箱' } ]
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
  fetchOptions()
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
.section-title {
  margin-top: 20px;
  margin-bottom: 15px;
  color: #409EFF;
  border-left: 4px solid #409EFF;
  padding-left: 10px;
}
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 25px;
  margin-bottom: 10px;
}
.dialog-footer {
  display: flex;
  justify-content: flex-end;
}
</style>