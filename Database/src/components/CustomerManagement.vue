<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>客戶資料管理</h2>
      <el-button type="success" size="large" @click="openDialog">
        <el-icon><Plus /></el-icon> 新增客戶
      </el-button>
    </div>

    <el-table :data="customerList" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="customer_id" label="客戶編號" width="150" fixed />
      <el-table-column prop="customer_name" label="公司名稱" min-width="200" />
      <el-table-column prop="contact_person" label="聯絡人" width="120" />
      <el-table-column prop="phone_number" label="聯絡電話" width="150" />
      <el-table-column prop="shipping_address" label="送貨地址" min-width="250" />
      <el-table-column label="信用額度" width="150" align="right">
        <template #default="scope">
          NT$ {{ formatCurrency(scope.row.credit_limit) }}
        </template>
      </el-table-column>
      
      <el-table-column label="操作" min-width="150" align="center" fixed="right">
        <template #default="scope">
          <el-button size="small" type="primary" plain @click="handleEdit(scope.row)">編輯</el-button>
          <el-button size="small" type="danger" plain @click="handleDelete(scope.row)">刪除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '編輯客戶資料' : '新增客戶資料'" width="550px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="110px" style="padding-right: 20px;">
        
        <el-form-item label="客戶編號" prop="customer_id">
          <el-input v-model="form.customer_id" :disabled="isEdit" placeholder="例如: CUST001" />
        </el-form-item>
        
        <el-form-item label="公司名稱" prop="customer_name">
          <el-input v-model="form.customer_name" placeholder="請輸入完整公司名稱" />
        </el-form-item>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="主要聯絡人" prop="contact_person">
              <el-input v-model="form.contact_person" placeholder="可留空" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="聯絡電話" prop="phone_number">
              <el-input v-model="form.phone_number" placeholder="可留空" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="送貨地址" prop="shipping_address">
          <el-input v-model="form.shipping_address" type="textarea" placeholder="請輸入完整送貨與發票地址" />
        </el-form-item>
        
        <el-form-item label="信用額度" prop="credit_limit">
          <el-input-number v-model="form.credit_limit" :min="0" :step="10000" style="width: 100%;" />
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

const customerList = ref([])
const loading = ref(true)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref(null)
const isEdit = ref(false) // 🌟 記錄目前是新增還是編輯狀態

// 1. 表單資料結構
const form = reactive({
  customer_id: '',
  customer_name: '',
  contact_person: '',
  phone_number: '',
  shipping_address: '',
  credit_limit: 0
})

// 2. 表單驗證規則
const rules = {
  customer_id: [
    { required: true, message: '請輸入客戶編號', trigger: 'blur' },
    { min: 3, max: 20, message: '長度需在 3 到 20 個字元之間', trigger: 'blur' }
  ],
  customer_name: [
    { required: true, message: '請輸入公司名稱', trigger: 'blur' }
  ],
  shipping_address: [
    { required: true, message: '請輸入送貨地址', trigger: 'blur' }
  ]
}

// --- 取得所有客戶資料 ---
const fetchCustomers = async () => {
  try {
    loading.value = true
    const response = await fetch('http://localhost:8000/api/customers')
    const json = await response.json()
    if (json.status === 'success') {
      customerList.value = json.data
    }
  } catch (error) {
    ElMessage.error('取得客戶資料失敗')
  } finally {
    loading.value = false
  }
}

// --- 開啟對話框 (新增) ---
const openDialog = () => {
  isEdit.value = false
  dialogVisible.value = true
}

// --- 開啟對話框 (編輯) ---
const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(form, row) // 將該列資料完整複製進表單中
  dialogVisible.value = true
}

// --- 刪除客戶 ---
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `確定要刪除客戶「${row.customer_name}」嗎？此操作無法復原。`,
    '警告',
    { confirmButtonText: '確定刪除', cancelButtonText: '取消', type: 'warning' }
  ).then(async () => {
    try {
      const response = await fetch(`http://localhost:8000/api/customers/${row.customer_id}`, {
        method: 'DELETE'
      })
      const json = await response.json()
      
      if (json.status === 'success') {
        ElMessage.success(json.message)
        fetchCustomers() // 重新整理表格
      } else {
        ElMessage.error(json.message) // 顯示如「已有訂單不可刪除」的錯誤
      }
    } catch (error) {
      ElMessage.error('連線伺服器失敗')
    }
  }).catch(() => {
    ElMessage.info('已取消刪除')
  })
}

// --- 送出表單 (自動判斷 POST 還是 PUT) ---
const submitForm = () => {
  if (!formRef.value) return
  
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        submitLoading.value = true
        
        // 判斷網址與 API 方法
        const url = isEdit.value 
          ? `http://localhost:8000/api/customers/${form.customer_id}`
          : 'http://localhost:8000/api/customers'
        const method = isEdit.value ? 'PUT' : 'POST'

        const response = await fetch(url, {
          method: method,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(form)
        })
        const json = await response.json()
        
        if (json.status === 'success') {
          ElMessage.success(json.message)
          dialogVisible.value = false
          fetchCustomers() // 刷新表格
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

// --- 重置表單 ---
const resetForm = () => {
  if (formRef.value) formRef.value.resetFields()
  form.customer_id = ''
  form.credit_limit = 0
}

// --- 格式化金額 ---
const formatCurrency = (value) => {
  if (!value) return '0'
  return Number(value).toLocaleString()
}

onMounted(() => {
  fetchCustomers()
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