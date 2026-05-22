# DB02 - SQL 학습 가이드

## 📋 프로젝트 개요

이 프로젝트는 **DDL(ALTER TABLE)** 과 **제약조건(PK/FK)** 을 중심으로 SQL을 학습하기 위한 자료입니다.

- `userTBL` / `buyTBL` : **1:1 관계** (구매 정보는 회원당 최대 1건)
- `memberTBL` / `productTBL` : 회원·상품 마스터 테이블 (FK 없이 독립 구성)
- `membertbl_export.csv` : `memberTBL` 샘플 데이터 (CSV 가져오기 연습)

---

## 🗂️ 데이터베이스 구조

### ERD — userTBL ↔ buyTBL (1:1)

```mermaid
erDiagram
    userTBL ||--|| buyTBL : "1대1"
    userTBL {
        string userName PK
        int birthYear
        string addr
        string mobile
    }
    buyTBL {
        string userName PK
        string prodName
        int price
        int amount
    }
```

> `buyTBL.userName` 은 PK이면서 `userTBL.userName` 을 참조하는 FK입니다. (`FK_userTBL_TO_buyTBL_1`)

### ERD — memberTBL · productTBL (독립)

```mermaid
erDiagram
    memberTBL {
        string memberID PK
        string memberName
        string memberAddress
    }
    productTBL {
        string productName PK
        int cost
        string makeDate
        string company
        int amount
    }
```

### DB01 vs DB02 관계 비교

```mermaid
flowchart LR
    subgraph db01["DB01 1:N"]
        M1[memberTBL]
        O1[orderTBL]
        M1 -->|memberID FK| O1
    end
    subgraph db02["DB02 1:1"]
        U[userTBL]
        B[buyTBL]
        U <-->|userName| B
    end
```

---

## 📊 테이블 정보

### 1️⃣ userTBL (고객 테이블)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|--------|------|
| userName | VARCHAR(3) | PRIMARY KEY | 고객 이름 (PK) |
| birthYear | INT | NULL | 출생 연도 |
| addr | VARCHAR(2) | NULL | 주소 |
| mobile | VARCHAR(12) | NOT NULL | 휴대폰 번호 |

---

### 2️⃣ buyTBL (구매 테이블, 1:1)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|--------|------|
| userName | VARCHAR(3) | PRIMARY KEY, FOREIGN KEY | 고객 이름 (`userTBL` 참조) |
| prodName | VARCHAR(3) | NULL | 상품명 |
| price | INT | NULL | 가격 |
| amount | INT | NULL | 수량 |

> `buyTBL.userName` 이 PK이면서 FK이므로, 한 고객당 구매 행은 **최대 1개** (1:1 관계).

---

### 3️⃣ memberTBL (회원 테이블)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|--------|------|
| memberID | VARCHAR(256) | PRIMARY KEY | 회원 고유 ID |
| memberName | VARCHAR(500) | NULL | 회원 이름 |
| memberAddress | VARCHAR(500) | NULL | 회원 주소 |

**CSV 샘플 데이터 (`membertbl_export.csv`):**

| memberID | memberName | memberAddress |
|----------|-----------|---------------|
| Choi | 최지훈 | 대구 수성구 범어동 |
| Dang | 당당이 | 경기 부천시 중동 |
| Han | 한주연 | 인천 남구 주안동 |
| Jee | 지은이 | 서울 은평구 증산동 |
| Kim | 김민수 | 서울 강남구 역삼동 |
| Lee2 | 이하늘 | 광주 북구 용봉동 |
| Park | 박서연 | 부산 해운대구 우동 |
| Sang | 상길이 | 경기 성남시 분당구 |

---

### 4️⃣ productTBL (상품 테이블)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|--------|------|
| productName | VARCHAR(500) | PRIMARY KEY | 상품명 |
| cost | INT | NULL | 원가 |
| makeDate | VARCHAR(500) | NULL | 제조일 |
| company | VARCHAR(500) | NULL | 제조사 |
| amount | INT | NULL | 재고 수량 |

---

## 🔍 주요 SQL 쿼리

### 기본 조회
```sql
-- 전체 회원 조회
SELECT * FROM memberTBL;

-- 전체 상품 조회
SELECT * FROM productTBL;

-- 고객·구매 조회 (1:1 JOIN)
SELECT *
FROM userTBL u
JOIN buyTBL b ON u.userName = b.userName;
```

### 1:1 JOIN 흐름

```mermaid
flowchart TD
    A[userTBL] --> B{JOIN ON userName}
    C[buyTBL] --> B
    B --> D[결과 1행]
```

### 조건부 조회
```sql
-- 특정 회원 조회
SELECT * FROM memberTBL WHERE memberName = '김민수';

-- 특정 지역 회원 조회
SELECT * FROM memberTBL WHERE memberAddress LIKE '%서울%';
```

### CSV 데이터 적재 (예시)
```sql
-- 테이블 생성 후, Workbench Import 또는 LOAD DATA 사용
LOAD DATA LOCAL INFILE 'membertbl_export.csv'
INTO TABLE memberTBL
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(memberID, memberName, memberAddress);
```

> CSV 경로·`LOCAL INFILE` 허용 여부는 환경에 따라 다릅니다. MySQL Workbench **Table Data Import Wizard** 로 가져와도 됩니다.

### CSV 가져오기 흐름

```mermaid
flowchart LR
    CSV[membertbl_export.csv] -->|semicolon| WIZ[Import Wizard]
    WIZ --> TBL[memberTBL]
    TBL --> Q[SELECT 확인]
```

---

## 📝 학습 목표

✅ `CREATE TABLE` 로 테이블 정의  
✅ `ALTER TABLE` 로 PRIMARY KEY / FOREIGN KEY 추가  
✅ 1:1 관계 (PK = FK 컬럼) 이해  
✅ CSV 파일로 데이터 적재  
✅ `JOIN` 으로 연관 테이블 조회  
✅ `WHERE` / `LIKE` 조건절 필터링  

---

## 🚀 실행 방법

1. 사용할 데이터베이스를 선택하거나 생성합니다.
   ```sql
   CREATE DATABASE IF NOT EXISTS day2db;
   USE day2db;
   ```
2. `day2.sql` 파일의 SQL 문을 **순서대로** 실행합니다. (테이블 생성 → `ALTER` 로 PK/FK 설정)
3. `membertbl_export.csv` 를 이용해 `memberTBL` 에 데이터를 적재합니다.
4. 위 **주요 SQL 쿼리** 를 실행해 결과를 확인합니다.

### 실행 흐름

```mermaid
flowchart TD
    S1[CREATE DATABASE day2db] --> S2[USE day2db]
    S2 --> S3[CREATE userTBL buyTBL]
    S3 --> S4[ALTER PK FK]
    S4 --> S5[CREATE memberTBL productTBL]
    S5 --> S6[ALTER PK]
    S6 --> S7[CSV Import memberTBL]
    S7 --> S8[SELECT JOIN]
```

### day2.sql — ALTER 제약조건 순서

```mermaid
sequenceDiagram
    participant SQL as day2.sql
    participant U as userTBL
    participant B as buyTBL
    SQL->>U: CREATE TABLE
    SQL->>B: CREATE TABLE
    SQL->>U: ADD PK_USERTBL
    SQL->>B: ADD PK_BUYTBL
    SQL->>B: ADD FK to userTBL
    Note over B,U: buyTBL.userName references userTBL
```

---

## 📁 파일 구성

| 파일 | 설명 |
|------|------|
| `day2.sql` | `userTBL`, `buyTBL`, `memberTBL`, `productTBL` DDL 및 제약조건 |
| `membertbl_export.csv` | `memberTBL` 회원 샘플 데이터 (세미콜론 구분) |

---

## 📐 다이어그램 요약 (Mermaid)

| 다이어그램 | 유형 | 설명 |
|-----------|------|------|
| userTBL ↔ buyTBL | `erDiagram` | 1:1 ERD |
| memberTBL · productTBL | `erDiagram` | 독립 마스터 테이블 |
| DB01 vs DB02 | `flowchart` | 1:N vs 1:1 비교 |
| 1:1 JOIN | `flowchart` | JOIN 조회 흐름 |
| CSV Import | `flowchart` | CSV → memberTBL |
| 실행 흐름 | `flowchart` | day2 학습 순서 |
| ALTER 순서 | `sequenceDiagram` | PK/FK 추가 단계 |

### day2.sql 전체 스크립트

```sql
CREATE TABLE `userTBL` (
	`userName`	varchar(3)	NOT NULL	COMMENT '고객이름, 실제로는 256글자로 설정',
	`birthYear`	int	NULL,
	`addr`	varchar(2)	NULL,
	`mobile`	varchar(12)	NOT NULL
);

CREATE TABLE `buyTBL` (
	`userName`	varchar(3)	NOT NULL	COMMENT '고객이름, 실제로는 256글자로 설정',
	`prodName`	varchar(3)	NULL,
	`price`	int	NULL,
	`amount`	int	NULL
);

ALTER TABLE `userTBL` ADD CONSTRAINT `PK_USERTBL` PRIMARY KEY (
	`userName`
);

ALTER TABLE `buyTBL` ADD CONSTRAINT `PK_BUYTBL` PRIMARY KEY (
	`userName`
);

ALTER TABLE `buyTBL` ADD CONSTRAINT `FK_userTBL_TO_buyTBL_1` FOREIGN KEY (
	`userName`
)
REFERENCES `userTBL` (
	`userName`
);

CREATE TABLE `memberTBL` (
	`memberID`	varchar(256)	NOT NULL,
	`memberName`	varchar(500)	NULL,
	`memberAddress`	varchar(500)	NULL
);

CREATE TABLE `productTBL` (
	`productName`	varchar(500)	NOT NULL,
	`cost`	int	NULL,
	`makeDate`	varchar(500)	NULL,
	`company`	varchar(500)	NULL,
	`amount`	int	NULL
);

ALTER TABLE `memberTBL` ADD CONSTRAINT `PK_MEMBERTBL` PRIMARY KEY (
	`memberID`
);

ALTER TABLE `productTBL` ADD CONSTRAINT `PK_PRODUCTTBL` PRIMARY KEY (
	`productName`
);
```

<br><br>

### MySQL Workbench · ERD (공통)



---

<br>
<img width="2454" height="1363" alt="image" src="https://github.com/user-attachments/assets/663c7dd4-f2d7-495f-9b02-a10daa0bcaa3" />
<img width="2454" height="1363" alt="image" src="https://github.com/user-attachments/assets/32ec5ffe-ee1a-4772-838f-6112e79eb41e" />
<img width="2301" height="1305" alt="image" src="https://github.com/user-attachments/assets/e11186ce-1903-43cc-97cc-b6aec576bc36" />
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/4b5704af-424c-4eaf-91ef-72161f0d3070" />
<img width="1672" height="941" alt="image" src="https://github.com/user-attachments/assets/d9b6b650-e880-4ec6-a351-52eb1569b95c" />

<br>
- 테이블+데이터 삭제 vs. 데이터만 삭제 <br>
- 데이터만 삭제(전체 row삭제, 속도가 매우 빠름. 조건 줄 수 없음)<br>
- truncate(자르다라는 의미)<br>
<img width="788" height="730" alt="image" src="https://github.com/user-attachments/assets/0612339c-9be2-48af-97dd-514921e3784d" />
- 테이블+삭제 삭제<br>
<img width="726" height="734" alt="image" src="https://github.com/user-attachments/assets/d3176020-7f6f-4965-9ad0-c3bfb8f12385" />

<hr>
- https://www.erdcloud.com/ --> SQL문 자동생성(table + 제약조건)<br>
- import(sql --> erd)<br>
- export(erd --> sql)<br>
- 외래키 설정은 외래키가 되는 항목(컬럼)을 새로운 테이블로 drag/drop<br>


<img width="456" height="143" alt="image" src="https://github.com/user-attachments/assets/0fcb4b81-6a47-4117-9130-990108fe5e6b" />
<img width="1880" height="1759" alt="image" src="https://github.com/user-attachments/assets/97e1fe5a-ffeb-43cd-bd3f-75f9b47cc03d" />
<img width="2377" height="1757" alt="image" src="https://github.com/user-attachments/assets/3a1334e0-8418-44ae-a86d-1415d8784012" />
<img width="1626" height="967" alt="image" src="https://github.com/user-attachments/assets/3a220129-5bc6-45d7-9aa4-14bc5152234d" />

<br>
- csv/json파일로 테이블에 데이터 넣기(import), 밖으로 내보내기(export)<br>
- db명 : mydb<br>
- memberTBL/productTBL<br>
- csv/json<br>
<br>
<img width="666" height="917" alt="image" src="https://github.com/user-attachments/assets/7dd9332e-6f34-42ff-8777-f270344b336b" />
<img width="1852" height="854" alt="image" src="https://github.com/user-attachments/assets/8995dccb-e6e5-405f-bd2b-3d80c58af7dc" />
<img width="1834" height="1051" alt="image" src="https://github.com/user-attachments/assets/d5fb2c03-beaf-4e3f-a64c-f2cf1b028c0b" />
<img width="766" height="733" alt="image" src="https://github.com/user-attachments/assets/94269599-4a2c-437c-b47a-fc85bf96d406" />
<img width="1575" height="1194" alt="image" src="https://github.com/user-attachments/assets/0fb1db7f-0b9d-45ff-bacf-16131d58d194" />
<br>






