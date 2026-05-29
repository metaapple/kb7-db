-- =========================================================
-- MySQL 8 인덱스 검색 속도 비교 실습
-- CTE 없이 대량 데이터 넣기
-- =========================================================

DROP DATABASE IF EXISTS index_test_simple;
CREATE DATABASE index_test_simple;
USE index_test_simple;

-- ---------------------------------------------------------
-- 1. 숫자 생성용 테이블
-- 0 ~ 9까지 숫자만 넣어둠
-- ---------------------------------------------------------

CREATE TABLE num (
    n INT
);

INSERT INTO num VALUES
(0), (1), (2), (3), (4), (5), (6), (7), (8), (9);


-- ---------------------------------------------------------
-- 2. PK 없는 테이블
-- ---------------------------------------------------------

CREATE TABLE member_no_pk (
    member_id INT NOT NULL,
    member_name VARCHAR(30),
    email VARCHAR(100),
    address VARCHAR(20)
) ENGINE=InnoDB;


-- ---------------------------------------------------------
-- 3. PK 있는 테이블
-- ---------------------------------------------------------

CREATE TABLE member_pk (
    member_id INT NOT NULL PRIMARY KEY,
    member_name VARCHAR(30),
    email VARCHAR(100),
    address VARCHAR(20)
) ENGINE=InnoDB;


-- ---------------------------------------------------------
-- 4. 대량 데이터 한꺼번에 넣기
-- 10 x 10 x 10 x 10 x 10 = 100,000건
-- ---------------------------------------------------------

INSERT INTO member_no_pk
(member_id, member_name, email, address)
SELECT
    a.n * 10000 + b.n * 1000 + c.n * 100 + d.n * 10 + e.n + 1 AS member_id,
    CONCAT('회원', a.n * 10000 + b.n * 1000 + c.n * 100 + d.n * 10 + e.n + 1) AS member_name,
    CONCAT('user', a.n * 10000 + b.n * 1000 + c.n * 100 + d.n * 10 + e.n + 1, '@test.com') AS email,
    CASE 
        WHEN e.n IN (0, 1) THEN '서울'
        WHEN e.n IN (2, 3) THEN '부산'
        WHEN e.n IN (4, 5) THEN '대구'
        WHEN e.n IN (6, 7) THEN '인천'
        ELSE '광주'
    END AS address
FROM num a
CROSS JOIN num b
CROSS JOIN num c
CROSS JOIN num d
CROSS JOIN num e;


-- PK 테이블에도 같은 데이터 복사
INSERT INTO member_pk
SELECT *
FROM member_no_pk;


-- 통계 갱신
ANALYZE TABLE member_no_pk;
ANALYZE TABLE member_pk;


-- ---------------------------------------------------------
-- 5. 데이터 개수 확인
-- ---------------------------------------------------------

SELECT COUNT(*) AS no_pk_count FROM member_no_pk;
SELECT COUNT(*) AS pk_count FROM member_pk;

-- =========================================
-- no pk
-- =========================================

-- 1	SIMPLE	member_no_pk		ALL	99675	10.00	Using where
-- member_id = 90000 찾기
-- ↓
-- member_id에 인덱스 없음
-- ↓
-- 처음부터 끝까지 전부 확인
-- ↓
-- 전체 테이블 탐색

EXPLAIN
SELECT *
FROM member_no_pk
WHERE member_id = 90000;


-- =========================================
-- pk
-- =========================================

-- 1	SIMPLE	member_pk	const	PRIMARY	PRIMARY	4	const	1	100.00	
-- member_id = 90000 찾기
-- ↓
-- PRIMARY KEY 인덱스 사용
-- ↓
-- B+Tree로 빠르게 이동
-- ↓
-- 해당 행 찾기

EXPLAIN
SELECT *
FROM member_pk
WHERE member_id = 90000;

-- =========================================
-- no secondary index(보조 인덱스 없음)
-- =========================================
-- 1	SIMPLE	member_pk		ALL		100198	10.00	Using where
-- email = 'user90000@test.com' 찾기
-- ↓
-- email 인덱스 없음
-- ↓
-- 모든 행의 email 값을 하나씩 비교
-- ↓
-- 전체 테이블 탐색

EXPLAIN 
SELECT *
FROM member_pk
WHERE email = 'user90000@test.com';

-- =========================================
-- secondary index(보조 인덱스 생성) 
-- =========================================
CREATE INDEX idx_member_email
ON member_pk(email);

ANALYZE TABLE member_pk;

-- 1	SIMPLE	member_pk  ref	idx_member_email	403	const	1	100.00	
EXPLAIN 
SELECT *
FROM member_pk
WHERE email = 'user90000@test.com';

-- PK 없음 : 찾을 기준표가 없어서 전체를 뒤짐
-- PK 있음 : 기본키 인덱스로 빠르게 찾음
-- 보조 인덱스 없음 : PK가 있어도 다른 컬럼 검색은 느릴 수 있음
-- 보조 인덱스 있음 : 해당 컬럼용 찾아보기 표가 생겨서 빨라짐


-- 기존 DB 삭제 후 새로 생성
DROP DATABASE IF EXISTS SQLDB;
CREATE DATABASE SQLDB;
USE SQLDB;

-- =========================
-- DDL : buytbl 테이블 생성
-- =========================
DROP TABLE IF EXISTS buytbl;

CREATE TABLE buytbl (
    num INT AUTO_INCREMENT PRIMARY KEY,
    userID CHAR(8) NOT NULL,
    prodName VARCHAR(20) NOT NULL,
    groupName VARCHAR(20),
    price INT NOT NULL,
    amount INT NOT NULL
);

-- =========================
-- DML : buytbl 데이터 입력
-- =========================
INSERT INTO buytbl (userID, prodName, groupName, price, amount)
VALUES
('KBS', '운동화', '의류', 30, 2),
('KBS', '노트북', '전자', 1000, 1),
('JYP', '모니터', '전자', 200, 1),
('BBK', '청바지', '의류', 50, 3),
('EJW', '책', '서적', 15, 5),
('SSK', '마우스', '전자', 20, 2),
('LJB', '커피', '식품', 5, 10),
('YJS', '키보드', '전자', 80, 1);

-- 데이터 확인
SELECT * FROM buytbl;

-- =========================
-- 트랜잭션 실습 -1 
-- =========================
START TRANSACTION;

DELETE FROM buytbl WHERE num = 1;
DELETE FROM buytbl WHERE num = 2;

-- 삭제된 상태 확인
SELECT * FROM buytbl;

-- 삭제 취소
ROLLBACK;

-- 원상복구 확인
SELECT * FROM buytbl;

-- =========================
-- 트랜잭션 실습 -2 
-- =========================
START TRANSACTION;

DELETE FROM buytbl WHERE num = 1;
DELETE FROM buytbl WHERE num = 2;

-- 삭제된 상태 확인
SELECT * FROM buytbl;

-- 삭제 반영
COMMIT;

-- 확인
SELECT * FROM buytbl;


-- =========================
-- user생성/권한 부여 실습
-- =========================
-- =====================================================
-- MySQL 8 사용자 생성 / 접속 가능 / 권한 부여 / 권한 회수 / 삭제
-- =====================================================

-- 1. 실습용 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS sqldb;

-- 2. 기존 사용자가 있으면 삭제
DROP USER IF EXISTS 'testuser'@'localhost';

-- 3. 사용자 생성
-- 이 명령만으로 'testuser'는 localhost에서 MySQL 접속 가능
CREATE USER 'testuser'@'localhost'
IDENTIFIED BY 'Test1234!';

-- 4. 접속만 가능한 기본 상태 확인
-- USAGE는 "접속은 가능하지만 DB 작업 권한은 거의 없음"을 의미
SHOW GRANTS FOR 'testuser'@'localhost';

-- 5. 접속 가능 상태를 명시적으로 표현하고 싶을 때
-- MySQL에서는 CONNECT 권한이 따로 없으므로 USAGE를 사용
GRANT USAGE
ON *.*
TO 'testuser'@'localhost';

-- 6. 다시 권한 확인
SHOW GRANTS FOR 'testuser'@'localhost';

-- 7. sqldb 데이터베이스에 작업 권한 부여
-- SELECT : 조회
-- INSERT : 추가
-- UPDATE : 수정
GRANT SELECT, INSERT, UPDATE
ON sqldb.*
TO 'testuser'@'localhost';

-- 8. 권한 부여 후 확인
SHOW GRANTS FOR 'testuser'@'localhost';

-- 9. UPDATE 권한만 회수
REVOKE UPDATE
ON sqldb.*
FROM 'testuser'@'localhost';

-- 10. 권한 회수 후 확인
SHOW GRANTS FOR 'testuser'@'localhost';

-- 11. SELECT, INSERT 권한도 회수
REVOKE SELECT, INSERT
ON sqldb.*
FROM 'testuser'@'localhost';

-- 12. 권한이 거의 없는 상태 확인
-- 다시 USAGE 상태만 남음
SHOW GRANTS FOR 'testuser'@'localhost';

-- 13. 사용자 삭제
DROP USER 'testuser'@'localhost';

-- 14. 삭제 확인
SELECT user, host
FROM mysql.user
WHERE user = 'testuser';