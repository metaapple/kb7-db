# DB06 - SQL 학습 가이드 (인덱스 · 정규화 · 트랜잭션 · DCL)

> KB7-DB 커리큘럼: [db05](../db05/) JOIN·DDL·정규화 → **db06(현재)** 인덱스·`EXPLAIN` · 정규화 복습 · TCL · DCL → [JDBC](../README.md#3-jdbc-흐름)  
> 전체 개요: [README.md](../README.md)

## 📋 프로젝트 개요

이 프로젝트는 **인덱스(PK·보조 인덱스)** 와 **`EXPLAIN` 실행 계획**, **정규화(1NF~3NF) 복습**, **트랜잭션(TCL)**, **사용자·권한(DCL)** 을 중심으로 조회 성능·데이터 무결성·권한 제어를 학습하기 위한 자료입니다.

- **전제:** [db05](../db05/)에서 DDL·FK·제약·정규화 개념을 익혔다고 가정합니다.
- **다음:** JDBC로 동일한 SQL을 Java에서 실행합니다.

### 파일 역할

| 파일 | 용도 | 포함 범위 |
|------|------|-----------|
| **`day6.sql`** | 수업 중 메인 실습 | `index_test_simple` 인덱스·`EXPLAIN` → `normalization_lab` 1NF~3NF → `SQLDB` 트랜잭션 → DCL(`testuser`) |
| **`day6-사전배포.sql`** | 수업 전·후 자율 실습 | 인덱스·트랜잭션·DCL (정규화 구간 없음, DCL 단계별 `SHOW GRANTS` 상세) |

> **배포본**은 인덱스·TCL·DCL 예습용입니다. **정규화 전 구간**은 `day6.sql`에서 진행합니다. db05 배포본과 `normalization_lab` 내용이 겹치므로, 정규화는 한쪽만 깊게 복습해도 됩니다.

### 사용 DB·테이블

- `index_test_simple` · `num` / `member_no_pk` / `member_pk` : **PK 유무** · **보조 인덱스** · `EXPLAIN` (약 10만 행)
- `normalization_lab` (`day6.sql`만) : 비정규 → **1NF · 2NF · 3NF**
- `SQLDB` · `buytbl` : **`START TRANSACTION`** · **`ROLLBACK`** · **`COMMIT`**
- `sqldb` (DCL) : **`CREATE USER`** · **`GRANT`** · **`REVOKE`** · **`DROP USER`**

---

## 🗂️ 사용 테이블 구조

### ERD — 인덱스 실습 (`index_test_simple`)

```mermaid
erDiagram
    num {
        int n
    }
    member_no_pk {
        int member_id
        varchar member_name
        varchar email
        varchar address
    }
    member_pk {
        int member_id PK
        varchar member_name
        varchar email
        varchar address
    }
```

> `member_no_pk`는 PK 없음 → `member_id` 조건 시 **Full Table Scan(`type=ALL`)**.  
> `member_pk`는 PK 인덱스 → `member_id` 조건 시 **`const` + PRIMARY**.  
> `email` 검색은 **`CREATE INDEX idx_member_email`** 후 **`ref`** 로 개선.

### ERD — 정규화 실습 (3NF, `day6.sql`)

```mermaid
erDiagram
    grade_3nf ||--o{ customer_3nf : grade
    customer_3nf ||--o{ event_participation_3nf : customer_id
    grade_3nf {
        varchar grade PK
        varchar discount_rate
    }
    customer_3nf {
        varchar customer_id PK
        varchar grade FK
    }
    event_participation_3nf {
        varchar customer_id PK
        varchar event_no PK
        char win_yn
    }
```

### ERD — 트랜잭션 실습 (`SQLDB` · `buytbl`)

```mermaid
erDiagram
    buytbl {
        int num PK
        char userID
        varchar prodName
        varchar groupName
        int price
        int amount
    }
```

### DB01 → DB06 학습 흐름

```mermaid
flowchart LR
    D1["DB01 DDL DML"] --> D2["DB02 ALTER PK FK"]
    D2 --> D3["DB03 SELECT 집계"]
    D3 --> D4["DB04 함수 JOIN"]
    D4 --> D5["DB05 JOIN DDL 정규화"]
    D5 --> D6["DB06 인덱스 TCL DCL"]
    D6 --> D7["JDBC"]
```

---

## 📊 테이블 정보

### 1️⃣ 인덱스 실습 (`index_test_simple`)

| 테이블 | PK | 용도 |
|--------|-----|------|
| `num` | 없음 | 0~9 숫자, `CROSS JOIN` 5회로 10만 행 생성 |
| `member_no_pk` | 없음 | PK 없을 때 `EXPLAIN` 비교 |
| `member_pk` | `member_id` | PK·보조 인덱스(`idx_member_email`) 비교 |

대량 INSERT 패턴 (`day6.sql`):

```sql
INSERT INTO member_no_pk (member_id, member_name, email, address)
SELECT
    a.n * 10000 + b.n * 1000 + c.n * 100 + d.n * 10 + e.n + 1,
    CONCAT('회원', ...),
    CONCAT('user', ..., '@test.com'),
    CASE WHEN e.n IN (0, 1) THEN '서울' ... END
FROM num a
CROSS JOIN num b
CROSS JOIN num c
CROSS JOIN num d
CROSS JOIN num e;
```

| `EXPLAIN` 대상 | `type` (대략) | 의미 |
|----------------|---------------|------|
| `member_no_pk` · `member_id = 90000` | `ALL` | 전체 스캔 |
| `member_pk` · `member_id = 90000` | `const` | PK로 즉시 탐색 |
| `member_pk` · `email = '...'` (인덱스 전) | `ALL` | PK 있어도 비키 컬럼은 느릴 수 있음 |
| `member_pk` · `email = '...'` (인덱스 후) | `ref` | 보조 인덱스 사용 |

```sql
ANALYZE TABLE member_pk;

CREATE INDEX idx_member_email ON member_pk(email);

EXPLAIN SELECT * FROM member_pk WHERE email = 'user90000@test.com';
```

---

### 2️⃣ 정규화 (`normalization_lab`, `day6.sql`만)

| 단계 | 테이블 | 핵심 |
|------|--------|------|
| 비정규 | `event_participation_unnormalized` | 한 칸에 `E001,E005` 등 다중값 |
| **1NF** | `event_participation_1nf` | 행 분리, 갱신 이상(`UPDATE apple` 일부만) |
| **2NF** | `customer_2nf` + `event_participation_2nf` | `grade`·`discount_rate` 분리 |
| **3NF** | `grade_3nf` + `customer_3nf` + `event_participation_3nf` | `grade` → `discount_rate` 이행 종속 제거 |

```sql
SELECT c.customer_id, e.event_no, e.win_yn, c.grade, g.discount_rate
FROM customer_3nf c
JOIN event_participation_3nf e ON c.customer_id = e.customer_id
JOIN grade_3nf g ON c.grade = g.grade;
```

---

### 3️⃣ 트랜잭션 (`SQLDB` · `buytbl`)

| 컬럼 | 설명 |
|------|------|
| `num` | `AUTO_INCREMENT` PK |
| `userID`, `prodName`, `groupName`, `price`, `amount` | 구매 데이터 |

```sql
START TRANSACTION;
DELETE FROM buytbl WHERE num = 1;
DELETE FROM buytbl WHERE num = 2;
SELECT * FROM buytbl;   -- 삭제된 상태 확인
ROLLBACK;              -- 실습 -1: 취소

START TRANSACTION;
DELETE FROM buytbl WHERE num = 1;
DELETE FROM buytbl WHERE num = 2;
COMMIT;                -- 실습 -2: 반영
```

> `SELECT @@autocommit;` — 기본값 `1`이면 문장마다 자동 커밋. 여러 DML을 묶을 때 `START TRANSACTION` 사용.

---

### 4️⃣ DCL (`testuser`@`localhost`)

| 단계 | 명령 | 설명 |
|------|------|------|
| 생성 | `CREATE USER ... IDENTIFIED BY` | 로컬 접속 계정 |
| 접속만 | `GRANT USAGE ON *.*` | DB 작업 권한 거의 없음 |
| 권한 부여 | `GRANT SELECT, INSERT, UPDATE ON sqldb.*` | 스키마 단위 권한 |
| 회수 | `REVOKE ... ON sqldb.*` | 부여 권한 제거 |
| 삭제 | `DROP USER` | 계정 제거 |

**`day6.sql`** — 한 번에 SELECT·INSERT·UPDATE 부여 후 일괄 `REVOKE`:

```sql
GRANT SELECT, INSERT, UPDATE ON sqldb.* TO 'testuser'@'localhost';
REVOKE SELECT, INSERT, UPDATE ON sqldb.* FROM 'testuser'@'localhost';
```

**`day6-사전배포.sql`** — 단계마다 `SHOW GRANTS`, `REVOKE UPDATE`만 먼저 회수하는 흐름.

---

## 🔍 주요 SQL 주제

### 인덱스 · `EXPLAIN`

```mermaid
flowchart TB
    Q["WHERE 조건"]
    Q --> N["PK 없음 ALL"]
    Q --> P["PK 있음 const"]
    Q --> E["비키 컬럼 ALL"]
    E --> I["CREATE INDEX ref"]
```

| 구분 | 요약 |
|------|------|
| **PK 없음** | 기준 인덱스 없음 → 전체 행 스캔 |
| **PK 있음** | B+Tree로 `member_id` 빠른 탐색 |
| **보조 인덱스** | `email` 등 자주 검색하는 컬럼에 `CREATE INDEX` |

---

### 정규화 1NF · 2NF · 3NF (`day6.sql`)

```mermaid
flowchart TD
    U["비정규 다중값"] --> N1["1NF 행 분리"]
    N1 --> N2["2NF customer 분리"]
    N2 --> N3["3NF grade 분리"]
```

| 정규형 | 핵심 |
|--------|------|
| **1NF** | 원자값, 반복 제거 · 갱신 이상 실습 |
| **2NF** | 복합키의 부분 함수 종속 제거 |
| **3NF** | 이행적 함수 종속 제거 |

---

### 트랜잭션(TCL)

```mermaid
stateDiagram-v2
    [*] --> Active: START TRANSACTION
    Active --> RolledBack: ROLLBACK
    Active --> Committed: COMMIT
    RolledBack --> [*]
    Committed --> [*]
```

| 명령 | 효과 |
|------|------|
| `START TRANSACTION` | 이후 DML을 하나의 작업 단위로 묶기 |
| `ROLLBACK` | 트랜잭션 내 변경 취소 |
| `COMMIT` | 변경 영구 반영 |

---

### DCL (사용자·권한)

```mermaid
flowchart LR
    C["CREATE USER"] --> G["GRANT USAGE"]
    G --> P["GRANT sqldb.*"]
    P --> R["REVOKE"]
    R --> D["DROP USER"]
```

> DCL은 **root 또는 `CREATE USER` 권한** 계정으로 실행합니다. 실습 비밀번호(`Test1234!`)는 로컬 전용 예시입니다.

---

## 📝 학습 목표

✅ `CROSS JOIN`으로 대량 데이터 생성 · `ANALYZE TABLE`  
✅ PK 유무·보조 인덱스에 따른 **`EXPLAIN` `type`** 차이 (`ALL` / `const` / `ref`)  
✅ **1NF · 2NF · 3NF** 분리와 갱신 이상 이해 (복습)  
✅ **`START TRANSACTION`** · **`ROLLBACK`** · **`COMMIT`**  
✅ **`CREATE USER`** · **`GRANT`** · **`REVOKE`** · **`SHOW GRANTS`** · **`DROP USER`**  

---

## 🚀 실행 방법

### 권장 순서

1. **`day6.sql`** — 상단(`index_test_simple`)부터 순서대로 실행 (수업 메인)
2. **`day6-사전배포.sql`** — 수업 전 인덱스·TCL·DCL 예습, 또는 DCL 단계별 확인

```mermaid
flowchart TD
    A["day6.sql 인덱스 EXPLAIN"] --> B["day6.sql 정규화"]
    B --> C["day6.sql 트랜잭션"]
    C --> D["day6.sql DCL"]
    D --> E{"예습만?"}
    E -->|예| F["배포본 인덱스 TCL DCL"]
    E -->|아니오| G["다음 JDBC"]
```

### `day6.sql` — 실행 구간 (484행)

| 행 | 내용 |
|----|------|
| 1~172 | `index_test_simple` · `num` · 10만 행 · `EXPLAIN` · 보조 인덱스 |
| 174~371 | `normalization_lab` · 비정규 → 1NF → 2NF → 3NF |
| 373~446 | `SQLDB` · `buytbl` · 트랜잭션 -1(`ROLLBACK`) · -2(`COMMIT`) · `@@autocommit` |
| 448~479 | DCL · `testuser` 생성·권한·회수·삭제 |

### `day6-사전배포.sql` — 실행 구간 (300행)

| 행 | 내용 |
|----|------|
| 1~162 | `index_test_simple` (정규화 없음) |
| 164~232 | `SQLDB` 트랜잭션 |
| 235~300 | DCL 단계별 `SHOW GRANTS` · `REVOKE UPDATE` 분리 |

### 주의 사항

- 인덱스 실습 INSERT는 **수 분** 걸릴 수 있습니다. Workbench에서 구간별 실행을 권장합니다.
- `index_test_simple`을 다시 만들려면 상단 `DROP DATABASE`부터 실행하세요.
- `day6.sql`과 **배포본**의 인덱스·`SQLDB`·DCL 블록은 **중복**입니다. 연속 실행 시 한 파일만 쓰거나, 배포본은 **DCL 상세 구간만** 추가 실행하세요.
- DCL의 `testuser`는 이미 있으면 `DROP USER IF EXISTS` 후 진행합니다.
- 정규화는 [db05/day5_수업전배포.sql](../db05/day5_수업전배포.sql)과 유사합니다. 시간이 부족하면 db06에서는 **인덱스·TCL·DCL**만 집중해도 됩니다.

---

## 📁 파일 구성

| 파일 | 설명 |
|------|------|
| `day6.sql` | 수업 메인: 인덱스·`EXPLAIN` · 정규화 · 트랜잭션 · DCL (484행) |
| `day6-사전배포.sql` | 사전 배포: 인덱스 · 트랜잭션 · DCL 상세 (300행) |
| `README.md` | 학습 가이드 (현재 문서) |

---

## 📐 다이어그램 요약 (Mermaid)

| 다이어그램 | 유형 | 설명 |
|-----------|------|------|
| member_no_pk · member_pk | `erDiagram` | 인덱스 실습 |
| grade · customer · event | `erDiagram` | 3NF |
| buytbl | `erDiagram` | 트랜잭션 |
| DB01→DB06 | `flowchart` | 커리큘럼 |
| 인덱스·EXPLAIN | `flowchart` | PK·보조 인덱스 |
| 정규화 | `flowchart` | 1NF→3NF |
| TCL | `stateDiagram` | ROLLBACK/COMMIT |
| DCL | `flowchart` | USER·GRANT |
| 실행 흐름 | `flowchart` | day6 → 배포본 선택 |
