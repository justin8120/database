<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>進貨紀錄管理</h2>
      <el-button type="warning" size="large" @click="openDialog">
        <el-icon><Plus /></el-icon> 登記進貨
      </el-button>
    </div>

    <el-table :data="purchaseList" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="purchase_id" label="單號" width="120" fixed />
      <el-table-column prop="purchase_time" label="進貨時間" width="180" sortable>
        <template #default="scope">
          {{ formatDateTime(scope.row.purchase_time) }}
        </template>
      </el-table-column>
      <el-table-column prop="supplier_name" label="供應商名稱" min-width="150" />
      <el-table-column prop="product_id" label="產品編號" width="140" />
      <el-table-column prop="product_spec" label="產品規格" min-width="200" />
      <el-table-column label="數量" width="120" align="right">
        <template #default="scope">
          {{ scope.row.quantity }} {{ scope.row.unit }}
        </template>
      </el-table-column>
      <el-table-column label="總金額" width="130" align="right">
        <template #default="scope">
          NT$ {{ formatCurrency(scope.row.total_amount) }}
        </template>
      </el-table-column>
      <el-table-column prop="employee_id" label="經辦人" width="100" align="center" />
      
      <el-table-column label="操作" width="150" align="center" fixed="right">
        <template #default="scope">
          <el-button size="small" type="primary" plain @click="handleEdit(scope.row)">編輯</el-button>
          <el-button size="small" type="danger" plain @click="handleDelete(scope.row)">刪除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '編輯進貨紀錄' : '登記進貨'" width="600px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="110px" style="padding-right: 20px;">
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="進貨單號" prop="purchase_id">
              <el-input v-model="form.purchase_id" :disabled="isEdit" placeholder="例如: PU-2026-0001" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="進貨時間" prop="purchase_time">
              <el-date-picker 
                v-model="form.purchase_time" 
                type="datetime" 
                placeholder="選擇日期與時間" 
                style="width: 100%" 
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="進貨產品" prop="product_id">
          <el-select v-model="form.product_id" filterable placeholder="請選擇或搜尋產品編號" style="width: 100%">
            <el-option 
              v-for="product in productOptions" 
              :key="product.product_id" 
              :label="`${product.product_id} (${product.material_grade} ${product.thread_system} ${product.thread_size}x${product.length_mm}mm)`" 
              :value="product.product_id" 
            />
          </el-select>
        </el-form-item>

        <el-form-item label="供應商名稱" prop="supplier_name">
          <el-input v-model="form.supplier_name" placeholder="請輸入供應商公司名稱" />
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="進貨數量" prop="quantity">
              <el-input-number v-model="form.quantity" :min="1" style="width: 100%;" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="總金額" prop="total_amount">
              <el-input-number v-model="form.total_amount" :min="0" :step="1000" style="width: 100%;" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="經辦人員" prop="employee_id">
          <el-input v-model="form.employee_id" placeholder="請輸入員工編號" />
        </el-form-item>
        
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">
            {{ isEdit ? '確認更新' : '確認新增' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const purchaseList = ref([])
const productOptions = ref([]) // 🌟 存放下拉選單用的產品資料
const loading = ref(true)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref(null)
const isEdit = ref(false)

// 1. 表單資料結構
const form = reactive({
  purchase_id: '',
  purchase_time: '',
  product_id: '',
  supplier_name: '',
  quantity: 1,
  total_amount: 0,
  employee_id: ''
})

// 2. 驗證規則
const rules = {
  purchase_id: [{ required: true, message: '請輸入進貨單號', trigger: 'blur' }],
  purchase_time: [{ required: true, message: '請選擇進貨時間', trigger: 'change' }],
  product_id: [{ required: true, message: '請選擇進貨產品', trigger: 'change' }],
  supplier_name: [{ required: true, message: '請輸入供應商名稱', trigger: 'blur' }],
  employee_id: [{ required: true, message: '請輸入經辦人員', trigger: 'blur' }]
}

// --- 取得進貨紀錄 ---
const fetchPurchases = async () => {
  try {
    loading.value = true
    const response = await fetch('http://localhost:8000/api/purchases')
    const json = await response.json()
    if (json.status === 'success') {
      purchaseList.value = json.data
    }
  } catch (error) {
    ElMessage.error('取得進貨紀錄失敗')
  } finally {
    loading.value = false
  }
}

// --- 🌟 取得產品清單 (供下拉選單使用) ---
const fetchProducts = async () => {
  try {
    const response = await fetch('http://localhost:8000/api/products')
    const json = await response.json()
    if (json.status === 'success') {
      productOptions.value = json.data
    }
  } catch (error) {
    console.error('取得產品選項失敗')
  }
}

// --- 開啟與操作 ---
const openDialog = () => {
  isEdit.value = false
  dialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm(
    `確定要刪除單號「${row.purchase_id}」嗎？`,
    '警告',
    { confirmButtonText: '確定刪除', cancelButtonText: '取消', type: 'warning' }
  ).then(async () => {
    try {
      const response = await fetch(`http://localhost:8000/api/purchases/${row.purchase_id}`, {
        method: 'DELETE'
      })
      const json = await response.json()
      if (json.status === 'success') {
        ElMessage.success(json.message)
        fetchPurchases()
      } else {
        ElMessage.error(json.message)
      }
    } catch (error) {
      ElMessage.error('連線伺服器失敗')
    }
  }).catch(() => {})
}

// --- 送出表單 ---
const submitForm = () => {
  if (!formRef.value) return
  
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        submitLoading.value = true
        
        // 確保將 Date 物件轉為 ISO 字串格式，FastAPI 才能正確解析
        const payload = { ...form }
        if (payload.purchase_time instanceof Date) {
          payload.purchase_time = payload.purchase_time.toISOString()
        }

        const url = isEdit.value 
          ? `http://localhost:8000/api/purchases/${form.purchase_id}`
          : 'http://localhost:8000/api/purchases'
        const method = isEdit.value ? 'PUT' : 'POST'

        const response = await fetch(url, {
          method: method,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        })
        const json = await response.json()
        
        if (json.status === 'success') {
          ElMessage.success(json.message)
          dialogVisible.value = false
          fetchPurchases()
        } else {
          ElMessage.error(json.message)
        }
      } catch (error) {
        ElMessage.error('連線伺服器失敗')
      } finally {
        submitLoading.value = false
      }
    } else {
      ElMessage.warning('請填寫所有必填欄位')
      return false
    }
  })
}

const resetForm = () => {
  if (formRef.value) formRef.value.resetFields()
  form.purchase_id = ''
  form.quantity = 1
  form.total_amount = 0
}

const formatCurrency = (value) => {
  if (!value) return '0'
  return Number(value).toLocaleString()
}

const formatDateTime = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('zh-TW', { 
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit'
  })
}

// 🌟 同時啟動兩支資料獲取 API
onMounted(() => {
  fetchPurchases()
  fetchProducts()
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
.dialog-footer {
  display: flex;
  justify-content: flex-end;
}
</style>