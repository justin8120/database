<template>
  <el-container class="layout-container">
    <el-aside width="240px" class="aside-menu">
      <div class="system-title">
        <h3>出貨訂單資料庫</h3>
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
          <span>訂單總覽</span>
        </el-menu-item>

        <el-menu-item index="/products">
          <el-icon><Goods /></el-icon>
          <span>產品管理</span>
        </el-menu-item>

        <el-menu-item index="/customers">
          <el-icon><User /></el-icon>
          <span>客戶管理</span>
        </el-menu-item>

        <el-menu-item index="/purchases">
          <el-icon><Money /></el-icon>
          <span>原料進貨</span>
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
import { Goods, List, Money, User } from '@element-plus/icons-vue'
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

.system-title h3 {
  margin: 0;
}

.el-menu {
  border-right: none;
}

.main-content {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>
