# DB01 - SQL 학습 가이드

## 📋 프로젝트 개요

이 프로젝트는 기본 SQL 문법을 학습하기 위한 쇼핑몰 데이터베이스입니다.
회원 정보와 주문 정보를 관리하는 **1:N 관계**의 데이터베이스 구조를 학습합니다.

---

## 🗂️ 데이터베이스 구조

### 데이터베이스명
- **shopdb** - 쇼핑몰 데이터베이스

### 테이블 설계도

```
┌─────────────────────┐
│    memberTBL        │
├─────────────────────┤
│ memberID (PK)       │
│ memberName          │
│ memberAddress       │
└─────────────────────┘
        ▲
        │ 1:N
        │
┌─────────────────────┐
│    orderTBL         │
├─────────────────────┤
│ orderID (PK)        │
│ memberID (FK)       │
│ product             │
│ quantity            │
└─────────────────────┘
```

---

## 📊 테이블 정보

### 1️⃣ memberTBL (회원 테이블)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|--------|------|
| memberID | VARCHAR(20) | PRIMARY KEY | 회원 고유 ID |
| memberName | VARCHAR(50) | NOT NULL | 회원 이름 |
| memberAddress | VARCHAR(100) | - | 회원 주소 |

**샘플 데이터:**

| memberID | memberName | memberAddress |
|----------|-----------|---------------|
| user01 | 김철수 | 서울 |
| user02 | 이영희 | 부산 |
| user03 | 박민수 | 대전 |
| user04 | 최지연 | 광주 |

---

### 2️⃣ orderTBL (주문 테이블)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|--------|------|
| orderID | INT | PRIMARY KEY | 주문 고유 ID |
| memberID | VARCHAR(20) | FOREIGN KEY | 회원 고유 ID (memberTBL 참조) |
| product | VARCHAR(50) | NOT NULL | 주문 상품명 |
| quantity | INT | NOT NULL | 주문 수량 |

**샘플 데이터:**

| orderID | memberID | product | quantity |
|---------|----------|---------|----------|
| 1001 | user01 | 노트북 | 1 |
| 1002 | user02 | 키보드 | 1 |
| 1003 | user01 | 마우스 | 2 |
| 1004 | user03 | 모니터 | 1 |

---

## 🔍 주요 SQL 쿼리

### 기본 조회
```sql
-- 전체 회원 조회
SELECT * FROM memberTBL;

-- 전체 주문 조회
SELECT * FROM orderTBL;
```

### 조건부 조회
```sql
-- 특정 회원 조회
SELECT * FROM memberTBL WHERE memberName = '김철수';
```

### JOIN 조회
```sql
-- 주문한 회원 이름과 상품 조회
SELECT
    m.memberName AS 회원명,
    o.product AS 상품명,
    o.quantity AS 수량
FROM memberTBL m
JOIN orderTBL o ON m.memberID = o.memberID;
```

**결과:**

| 회원명 | 상품명 | 수량 |
|--------|--------|------|
| 김철수 | 노트북 | 1 |
| 이영희 | 키보드 | 1 |
| 김철수 | 마우스 | 2 |
| 박민수 | 모니터 | 1 |

### 필터링된 JOIN
```sql
-- 특정 상품을 주문한 회원 조회
SELECT
    m.memberName AS 회원명,
    o.product AS 상품명
FROM memberTBL m
JOIN orderTBL o ON m.memberID = o.memberID
WHERE o.product = '노트북';
```

**결과:**

| 회원명 | 상품명 |
|--------|--------|
| 김철수 | 노트북 |

---

## 📝 학습 목표

✅ DDL (CREATE, DROP)  
✅ DML (INSERT, SELECT)  
✅ 데이터 타입 및 제약조건  
✅ PRIMARY KEY / FOREIGN KEY  
✅ JOIN을 이용한 관계 조회  
✅ WHERE 조건절을 이용한 필터링  

---

## 🚀 실행 방법

1. `day1.sql` 파일의 SQL 문을 순서대로 실행합니다.
2. shopdb 데이터베이스가 생성되고 테이블과 데이터가 로드됩니다.
3. SELECT 쿼리를 실행하여 데이터를 조회합니다.

<hr>
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/3f0a9100-09a4-4bde-bd5a-2e5638c60b45" />
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/2c449aa7-4482-4b90-89c9-36f97e7cb737" />

```

-- 1. DB 생성
DROP DATABASE IF EXISTS shopdb;
CREATE DATABASE shopdb;
USE shopdb;

-- 2. 회원 테이블 생성
CREATE TABLE memberTBL (
    memberID VARCHAR(20) PRIMARY KEY,
    memberName VARCHAR(50) NOT NULL,
    memberAddress VARCHAR(100)
);

-- 3. 주문 테이블 생성
CREATE TABLE orderTBL (
    orderID INT PRIMARY KEY,
    memberID VARCHAR(20) NOT NULL,
    product VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_order_member
        FOREIGN KEY (memberID)
        REFERENCES memberTBL(memberID)
);

-- 4. 회원 데이터 입력 DML
INSERT INTO memberTBL
(memberID, memberName, memberAddress)
VALUES
('user01', '김철수', '서울'),
('user02', '이영희', '부산'),
('user03', '박민수', '대전'),
('user04', '최지연', '광주');

-- 5. 주문 데이터 입력 DML
INSERT INTO orderTBL
(orderID, memberID, product, quantity)
VALUES
(1001, 'user01', '노트북', 1),
(1002, 'user02', '키보드', 1),
(1003, 'user01', '마우스', 2),
(1004, 'user03', '모니터', 1);

-- 6. 전체 회원 조회
SELECT *
FROM memberTBL;

-- 7. 전체 주문 조회
SELECT *
FROM orderTBL;

-- 8. 김철수 회원 조회
SELECT *
FROM memberTBL
WHERE memberName = '김철수';

-- 9. 주문한 회원 이름과 상품 조회 JOIN
SELECT
    m.memberName AS 회원명,
    o.product AS 상품명,
    o.quantity AS 수량
FROM memberTBL m
JOIN orderTBL o
ON m.memberID = o.memberID;

-- 10. 특정 상품을 주문한 회원 조회
SELECT
    m.memberName AS 회원명,
    o.product AS 상품명
FROM memberTBL m
JOIN orderTBL o
ON m.memberID = o.memberID
WHERE o.product = '노트북';

```
<br>
<img width="1024" height="1536" alt="image" src="https://github.com/user-attachments/assets/9ed390f8-77e5-4184-9731-19789776757b" />

<br><br>

- delete/update 해제<br>
  <img width="400" height="300" alt="image" src="https://github.com/user-attachments/assets/4f8a19b3-a759-462f-ba12-64ad77b42ea7" />
  <img width="400" height="300" alt="image" src="https://github.com/user-attachments/assets/c8d14c77-ceb4-49e6-9920-6ad77c509ef5" />

<br><br>
- ERD <br>
<img width="400" height="350" alt="image" src="https://github.com/user-attachments/assets/51c84a12-674b-4b80-935f-7e00a4433900" />
<img width="400" height="350" alt="image" src="https://github.com/user-attachments/assets/c24a3eca-9cf3-4ddd-90dd-5946c8b2d24d" />
<img width="400" height="350" alt="image" src="https://github.com/user-attachments/assets/aec4686b-24da-41a8-b11f-8d844ce05111" />
<img width="400" height="350" alt="image" src="https://github.com/user-attachments/assets/0717a36f-25e4-4c88-83b7-93207d5c95fb" />
<img width="400" height="350" alt="image" src="https://github.com/user-attachments/assets/e9513be7-f285-4a92-9077-8ece5636efcc" />
<img width="400" height="300" alt="image" src="https://github.com/user-attachments/assets/ca450cee-562c-408b-af2a-8ba6bbe408ab" />
<img width="500" height="350" alt="image" src="https://github.com/user-attachments/assets/e25868e9-c661-47aa-9962-f17695cc39fb" />

<br><br>
- font
<img width="807" height="603" alt="image" src="https://github.com/user-attachments/assets/2afc2bf6-d920-44e6-a650-8976b0bf7f44" />

<br><br>
<img width="956" height="454" alt="image" src="https://github.com/user-attachments/assets/b367cc96-39ce-46f5-84c9-a847cfd8ccd9" />
<img width="1075" height="613" alt="image" src="https://github.com/user-attachments/assets/fe3bfe0f-421e-4cac-8866-fd34f4570160" />
<img width="974" height="552" alt="image" src="https://github.com/user-attachments/assets/05afb239-0d4c-4261-8c13-9eaa22b1367f" />
<img width="1074" height="613" alt="image" src="https://github.com/user-attachments/assets/7b470713-cc29-427a-9968-27f55189f60b" />

<img width="975" height="553" alt="image" src="https://github.com/user-attachments/assets/84a06e24-4be5-448c-bf3b-16d5a213f158" />
<img width="980" height="556" alt="image" src="https://github.com/user-attachments/assets/e1c72cb2-2729-44ba-968b-55e40468bc7d" />
<img width="1074" height="611" alt="image" src="https://github.com/user-attachments/assets/cc8f80e7-770a-49ac-bd4f-2e50b0714932" />
<img width="1072" height="611" alt="image" src="https://github.com/user-attachments/assets/d1f406a0-5dda-4746-9e03-aa1b01393557" />
<img width="1075" height="612" alt="image" src="https://github.com/user-attachments/assets/f67247cd-a2d9-4081-8dad-b8fc056b71f1" />
<img width="1076" height="613" alt="image" src="https://github.com/user-attachments/assets/e1bd0e80-26ec-43b4-a603-e1bfe43410bf" />
<img width="1073" height="609" alt="image" src="https://github.com/user-attachments/assets/d4483935-fc3c-4089-b9c7-6c6cfa2bcd3a" />
<img width="1075" height="609" alt="image" src="https://github.com/user-attachments/assets/2f0ead46-b3bc-461f-ad5a-64eb3dba21e4" />

<br><br>
- 샘플데이터 다운로드/설치 : https://dev.mysql.com/doc/index-other.html <br>
  <img width="1550" height="470" alt="image" src="https://github.com/user-attachments/assets/5127cf21-3452-4ad5-8ebc-cf72db8544ce" />
  <img width="609" height="229" alt="image" src="https://github.com/user-attachments/assets/197fa586-15b9-400e-be1f-88b05b6cb31e" />



<br><br>
- db지정하지 않는 경우 기본 db로 인식하도록 설정 <br>
<img width="622" height="627" alt="image" src="https://github.com/user-attachments/assets/56dd6ac1-733b-49b6-9441-8f521ca26034" />

<br><br>
C:\Program Files\MySQL\MySQL Server 8.4\bin
<img width="882" height="662" alt="image" src="https://github.com/user-attachments/assets/773171d6-2c23-4b34-9561-619a2fe770dc" />
<img width="2054" height="1731" alt="image" src="https://github.com/user-attachments/assets/23ab206c-f958-4de7-92c8-d65e2b4ea8e7" />
<img width="962" height="1123" alt="image" src="https://github.com/user-attachments/assets/f22097ee-3bee-41c1-bc7f-633a60edc6a7" />
<img width="1234" height="1239" alt="image" src="https://github.com/user-attachments/assets/ea9cc914-d791-4260-b213-fff2588fed80" />
<img width="1068" height="1071" alt="image" src="https://github.com/user-attachments/assets/e13d42e1-45ef-4d26-93a1-e8e6633d0bd9" />

<br><br>

```

mysql -h ip -P port -u 사용자id -p 패스워드 
-h 지정하지 않으면 localhost
-P 지정하지 않으면 3306

```

<br><br>
- 실제 데이터가 저장되는 폴더 위치
  <img width="1852" height="1421" alt="image" src="https://github.com/user-attachments/assets/97bf49ac-68cc-4169-80dc-f33f6ef1466f" />





