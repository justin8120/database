--客戶資料表
CREATE TABLE Customers (
    customer_id VARCHAR(20) PRIMARY KEY,       --客戶編號
    customer_name VARCHAR(100) NOT NULL,       --客戶公司名稱
    contact_person VARCHAR(50),      		   --主要聯絡人
    phone_number VARCHAR(20) NOT NULL,         --聯絡電話
    shipping_address VARCHAR(255) NOT NULL,    --送貨與發票地址
    credit_limit DECIMAL(19,4),                --信用額度
	CONSTRAINT chk_credit CHECK (credit_limit > 0)
);

--產品規格表
CREATE TABLE Products (
    product_id VARCHAR(20) PRIMARY KEY,        --產品規格編號
    material_grade VARCHAR(10) NOT NULL,       --材質參數(如304, 316)
    
    --限制只能輸入這三種規範
    thread_system ENUM('公制', '英制', '美制') NOT NULL, 
    
    thread_size VARCHAR(10) NOT NULL,          --直徑規格(如M5, M10)
    
    --限制只能輸入這三種牙型
    thread_pitch ENUM('粗牙', '細牙', '自攻牙') NOT NULL,
    
    head_type VARCHAR(30),                     --頭型與槽型外觀
    length_mm DECIMAL(6,2) NOT NULL,           --螺絲長度(mm)
    
    --限制只能輸入這三種單位
    unit ENUM('千隻', '公斤', '件') NOT NULL,	   --單位
	
	stock int(11) NOT NULL DEFAULT 0,		   --庫存量
	CONSTRAINT chk_pur_len CHECK (length_mm > 0)
	CONSTRAINT chk_stock CHECK (stock>=0);
);

--原料進貨紀錄表
CREATE TABLE Purchase_Records (
    purchase_id VARCHAR(20) PRIMARY KEY,	--進貨紀錄編號
    supplier_name VARCHAR(100) NOT NULL,    --直接記錄供應商名稱
    product_id VARCHAR(20) NOT NULL,        --產品規格
    quantity INT NOT NULL,                  --進貨數量
    total_amount DECIMAL(14,4) NOT NULL,    --高精度採購總金額
    purchase_time DATETIME NOT NULL,        --進貨時間
    employee_id VARCHAR(20) NOT NULL,       --員工
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT chk_pur_qty CHECK (quantity > 0),	--數量>0
    CONSTRAINT chk_pur_amount CHECK (total_amount > 0)	--總金額>0
);

--銷售訂單總檔
CREATE TABLE Sales_Orders (
    order_id VARCHAR(20) PRIMARY KEY,          --訂單主檔編號
    customer_id VARCHAR(20) NOT NULL,          --客戶編號，對應客戶表
    employee_id VARCHAR(20) NOT NULL,          --負責業務編號
    order_date DATETIME NOT NULL,              --精確下單日期與時間
    required_date DATETIME NOT NULL,           --顧客要求之預計交期
    
    --限制只能輸入這四種訂單狀態
    order_status ENUM('草稿', '排產中', '待出貨', '已出貨') DEFAULT '草稿', 
    
    --付款狀態
    payment_status ENUM('未付款', '已付款') DEFAULT '未付款',
    
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT chk_dates CHECK (order_date <= required_date)
);

--訂單明細表
CREATE TABLE Order_Details (
    order_id VARCHAR(20),                      --訂單編號
    product_id VARCHAR(20),                    --產品編號
    quantity INT NOT NULL,                     --訂購數量
    unit_price DECIMAL(10,4) NOT NULL,         --高精度單價
    
    --限制只能輸入這三種包裝方式
    packaging_type ENUM('一箱', '一包', '散裝') DEFAULT '一箱', 
    
    --限制只能輸入這五種生產進度
    production_status ENUM('待進料', '打頭中', '搓牙中', '待包裝', '已完成') DEFAULT '待進料',
    
    PRIMARY KEY (order_id, product_id), 
    FOREIGN KEY (order_id) REFERENCES Sales_Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT,
    
    CONSTRAINT chk_quantity CHECK (quantity > 0),	--數量>0
    CONSTRAINT chk_price CHECK (unit_price > 0)		--單價>0
);