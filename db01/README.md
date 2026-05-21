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
