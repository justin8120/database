# database
本資料庫範例使用Vite作為前端顯示，需安裝Node.js  
後端連線資料庫使用FastAPI，需要安裝Python並於Python中安裝  
### Node.js套件安裝指令
```sh
npm install
```
### FastAPI安裝指令
```sh
pip install "fastapi[standard]"
```
## 程式開啟可透過start_servers.bat或執行下方指令開啟
### 前端程式指令
```cmd
start "Frontend (Vite/Vue)" cmd /k "npm run dev"
```
### 後端程式指令
```cmd
start "Backend (FastAPI)" cmd /k "cd backend && uvicorn main:app --reload"
```
