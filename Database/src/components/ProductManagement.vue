<template>
  <div class="page-container">
    <div class="header-actions">
      <h2>產品規格管理</h2>
      <el-button type="primary" size="large" @click="openDialog">
        <el-icon><Plus /></el-icon> 新增產品規格
      </el-button>
    </div>

    <el-table :data="productList" v-loading="loading" border stripe style="width: 100%">
      <el-table-column prop="product_id" label="產品編號" width="160" fixed />
      <el-table-column prop="material_grade" label="材質" width="100" />
      <el-table-column prop="thread_system" label="規範" width="100" />
      <el-table-column prop="thread_size" label="尺寸" width="100" />
      <el-table-column prop="thread_pitch" label="牙型" width="100" />
      <el-table-column prop="head_type" label="頭型" width="120" />
      <el-table-column prop="length_mm" label="長度 (mm)" width="100" align="right" />
      <el-table-column prop="unit" label="單位" width="80" align="center" />
      
      <el-table-column label="操作" min-width="150" align="center">
        <template #default="scope">
          <el-button size="small" type="primary" plain @click="handleEdit(scope.row)">編輯</el-button>
          <el-button size="small" type="danger" plain @click="handleDelete(scope.row)">刪除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '編輯產品規格' : '新增產品規格'" width="600px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="110px" style="padding-right: 20px;">
        
        <el-form-item label="產品編號" prop="product_id">
          <el-input v-model="form.product_id" :disabled="isEdit" placeholder="例如: PR-SS-0001" />
        </el-form-item>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="材質" prop="material_grade">
              <el-input v-model="form.material_grade" placeholder="例如: 304, 316" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="頭型" prop="head_type">
              <el-input v-model="form.head_type" placeholder="例如: 六角頭, 圓頭" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="螺紋規範" prop="thread_system">
              <el-select v-model="form.thread_system" placeholder="請選擇規範" style="width: 100%">
                <el-option label="公制" value="公制" />
                <el-option label="英制" value="英制" />
                <el-option label="美制" value="美制" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="牙型" prop="thread_pitch">
              <el-select v-model="form.thread_pitch" placeholder="請選擇牙型" style="width: 100%">
                <el-option label="粗牙" value="粗牙" />
                <el-option label="細牙" value="細牙" />
                <el-option label="自攻牙" value="自攻牙" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="尺寸" prop="thread_size">
              <el-input v-model="form.thread_size" placeholder="例如: M5, M10" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="長度 (mm)" prop="length_mm">
              <el-input-number v-model="form.length_mm" :min="0" :precision="2" :step="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="計量單位" prop="unit">
          <el-radio-group v-model="form.unit">
            <el-radio label="千隻" value="千隻">千隻</el-radio>
            <el-radio label="公斤" value="公斤">公斤</el-radio>
            <el-radio label="件" value="件">件</el-radio>
          </el-radio-group>
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

const productList = ref([])
const loading = ref(true)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref(null)
const isEdit = ref(false) // 記錄目前是新增還是編輯狀態

// 1. 表單資料結構
const form = reactive({
  product_id: '',
  material_grade: '',
  thread_system: '',
  thread_size: '',
  thread_pitch: '',
  head_type: '',
  length_mm: 0,
  unit: '千隻'
})

// 2. 表單驗證規則
const rules = {
  product_id: [{ required: true, message: '請輸入產品編號', trigger: 'blur' }],
  material_grade: [{ required: true, message: '請輸入材質', trigger: 'blur' }],
  thread_system: [{ required: true, message: '請選擇規範', trigger: 'change' }],
  thread_size: [{ required: true, message: '請輸入尺寸', trigger: 'blur' }],
  thread_pitch: [{ required: true, message: '請選擇牙型', trigger: 'change' }],
  unit: [{ required: true, message: '請選擇計量單位', trigger: 'change' }]
}

// --- 取得所有產品資料 ---
const fetchProducts = async () => {
  try {
    loading.value = true
    const response = await fetch('http://localhost:8000/api/products')
    const json = await response.json()
    if (json.status === 'success') {
      productList.value = json.data
    }
  } catch (error) {
    ElMessage.error('取得產品資料失敗')
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

// --- 刪除產品 ---
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `確定要刪除產品「${row.product_id}」嗎？此操作無法復原。`,
    '警告',
    { confirmButtonText: '確定刪除', cancelButtonText: '取消', type: 'warning' }
  ).then(async () => {
    try {
      const response = await fetch(`http://localhost:8000/api/products/${row.product_id}`, {
        method: 'DELETE'
      })
      const json = await response.json()
      
      if (json.status === 'success') {
        ElMessage.success(json.message)
        fetchProducts() // 重新整理表格
      } else {
        ElMessage.error(json.message)
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
      if (form.length_mm <= 0) {
        ElMessage.warning('長度必須大於 0')
        return
      }

      try {
        submitLoading.value = true
        
        // 判斷網址與 API 方法
        const url = isEdit.value 
          ? `http://localhost:8000/api/products/${form.product_id}`
          : 'http://localhost:8000/api/products'
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
          fetchProducts() // 刷新表格
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
  form.product_id = ''
  form.length_mm = 0
}

onMounted(() => {
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