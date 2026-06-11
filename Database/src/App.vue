<template>
  <el-container class="layout-container">
    <el-aside width="240px" class="aside-menu">
      <div class="system-title">
        <h3>🔩 進出貨管理系統</h3>
      </div>
      
      <el-menu
        :default-active="$route.path"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/orders">
          <el-icon><List /></el-icon>
          <span>訂單綜合管理</span>
        </el-menu-item>
        
        <el-menu-item index="/products">
          <el-icon><Goods /></el-icon>
          <span>產品規格管理</span>
        </el-menu-item>
        
        <el-menu-item index="/customers">
          <el-icon><User /></el-icon>
          <span>客戶資料管理</span>
        </el-menu-item>
        
        <el-menu-item index="/purchases">
          <el-icon><Money /></el-icon>
          <span>進貨紀錄管理</span>
        </el-menu-item>

        <div style="color: #909399; padding: 10px 20px; font-size: 12px; margin-top: 10px;">角色專屬視圖</div>
        
        <el-menu-item index="/role/sales">
          <el-icon><Briefcase /></el-icon>
          <span>業務查看系統</span>
        </el-menu-item>
        
        <el-menu-item index="/role/factory">
          <el-icon><Setting /></el-icon>
          <span>工廠生產系統</span>
        </el-menu-item>
        
        <el-menu-item index="/role/finance">
          <el-icon><DataLine /></el-icon>
          <span>會計財務系統</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container>
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
// 如果需要使用 Element Plus 的小圖示，記得引入（可選）
import { List, Goods, User, Money, Briefcase, Setting, DataLine } from '@element-plus/icons-vue'
</script>

<style scoped>
.layout-container {
  height: 100vh;
}
.aside-menu {
  background-color: #304156;
}
.system-title {
  height: 60px;
  line-height: 60px;
  text-align: center;
  color: #fff;
  background-color: #2b3643;
}
.el-menu {
  border-right: none;
}
.main-content {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>