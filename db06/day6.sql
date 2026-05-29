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

select * from num;


-- ---------------------------------------------------------
-- 2. PK 없는 테이블
-- ---------------------------------------------------------

CREATE TABLE member_no_pk (
    member_id INT NOT NULL,
    member_name VARCHAR(30),
    email VARCHAR(100),
    address VARCHAR(20)
) ENGINE=InnoDB;

desc member_no_pk;

-- ---------------------------------------------------------
-- 3. PK 있는 테이블
-- ---------------------------------------------------------

CREATE TABLE member_pk (
    member_id INT NOT NULL PRIMARY KEY,
    member_name VARCHAR(30),
    email VARCHAR(100),
    address VARCHAR(20)
) ENGINE=InnoDB;

desc member_pk;

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

select * from member_no_pk;
select count(*) as row수 from member_no_pk;

-- PK 테이블에도 같은 데이터 복사
INSERT INTO member_pk
SELECT *
FROM member_no_pk;

select count(*) as row수 from member_pk;
select * from member_pk;


-- 통계 갱신
ANALYZE TABLE member_no_pk;
ANALYZE TABLE member_pk;


-- ---------------------------------------------------------
-- 5. 데이터 로우(행, row) 개수 확인
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
show index from member_pk;

-- 1	SIMPLE	member_pk  ref	idx_member_email	403	const	1	100.00	
EXPLAIN
SELECT *
FROM member_pk
WHERE email = 'user90000@test.com';

-- PK 없음 : 찾을 기준표가 없어서 전체를 뒤짐
-- PK 있음 : 기본키 인덱스로 빠르게 찾음
-- 보조 인덱스 없음 : PK가 있어도 다른 컬럼 검색은 느릴 수 있음
-- 보조 인덱스 있음 : 해당 컬럼용 찾아보기 표가 생겨서 빨라짐


-- 정규화(normalization <--> 이상현상, anomaly)

DROP DATABASE IF EXISTS normalization_lab;
CREATE DATABASE normalization_lab;
USE normalization_lab;

-- =====================================================
-- 0. 비정규형 예시
-- 한 칸에 여러 값이 들어간 상태
-- =====================================================

CREATE TABLE event_participation_unnormalized (
    customer_id VARCHAR(20),
    event_no VARCHAR(100),
    win_yn VARCHAR(100),
    grade VARCHAR(20),
    discount_rate VARCHAR(10)
);

INSERT INTO event_participation_unnormalized VALUES
('apple',  'E001,E005,E010', 'Y,N,Y', 'gold',   '10%'),
('banana', 'E002,E005',      'N,Y',   'vip',    '20%'),
('carrot', 'E003,E007',      'Y,Y',   'gold',   '10%'),
('orange', 'E004',           'N',     'silver', '5%');

SELECT * FROM event_participation_unnormalized;


-- =====================================================
-- 1. 제1정규형 1NF
-- 반복되는 값을 원자값으로 분리
-- 하지만 아직 중복과 이상 현상 존재
-- 기본키: customer_id + event_no
-- =====================================================

CREATE TABLE event_participation_1nf (
    customer_id VARCHAR(20),
    event_no VARCHAR(10),
    win_yn CHAR(1),
    grade VARCHAR(20),
    discount_rate VARCHAR(10),
    PRIMARY KEY (customer_id, event_no)
);

INSERT INTO event_participation_1nf VALUES
('apple',  'E001', 'Y', 'gold',   '10%'),
('apple',  'E005', 'N', 'gold',   '10%'),
('apple',  'E010', 'Y', 'gold',   '10%'),
('banana', 'E002', 'N', 'vip',    '20%'),
('banana', 'E005', 'Y', 'vip',    '20%'),
('carrot', 'E003', 'Y', 'gold',   '10%'),
('carrot', 'E007', 'Y', 'gold',   '10%'),
('orange', 'E004', 'N', 'silver', '5%');

SELECT * FROM event_participation_1nf;


-- 1NF 문제 확인: apple의 등급을 일부만 수정하면 갱신 이상 발생
UPDATE event_participation_1nf
SET grade = 'vip'
WHERE customer_id = 'apple'
AND event_no = 'E001';

SELECT * FROM event_participation_1nf
WHERE customer_id = 'apple';


-- 실습 복구
UPDATE event_participation_1nf
SET grade = 'gold'
WHERE customer_id = 'apple';


-- =====================================================
-- 2. 제2정규형 2NF
-- 부분 함수 종속 제거
-- customer_id -> grade, discount_rate 분리
-- customer_id + event_no -> win_yn 유지
-- =====================================================

CREATE TABLE customer_2nf (
    customer_id VARCHAR(20) PRIMARY KEY,
    grade VARCHAR(20),
    discount_rate VARCHAR(10)
);

CREATE TABLE event_participation_2nf (
    customer_id VARCHAR(20),
    event_no VARCHAR(10),
    win_yn CHAR(1),
    PRIMARY KEY (customer_id, event_no),
    FOREIGN KEY (customer_id) REFERENCES customer_2nf(customer_id)
);

INSERT INTO customer_2nf VALUES
('apple',  'gold',   '10%'),
('banana', 'vip',    '20%'),
('carrot', 'gold',   '10%'),
('orange', 'silver', '5%');

INSERT INTO event_participation_2nf VALUES
('apple',  'E001', 'Y'),
('apple',  'E005', 'N'),
('apple',  'E010', 'Y'),
('banana', 'E002', 'N'),
('banana', 'E005', 'Y'),
('carrot', 'E003', 'Y'),
('carrot', 'E007', 'Y'),
('orange', 'E004', 'N');

SELECT * FROM customer_2nf;
SELECT * FROM event_participation_2nf;


-- 2NF 조인 결과
SELECT
    c.customer_id,
    e.event_no,
    e.win_yn,
    c.grade,
    c.discount_rate
FROM customer_2nf c
JOIN event_participation_2nf e
ON c.customer_id = e.customer_id
ORDER BY c.customer_id, e.event_no;


-- =====================================================
-- 3. 제3정규형 3NF
-- 이행적 함수 종속 제거
-- customer_id -> grade
-- grade -> discount_rate
-- 따라서 grade와 discount_rate를 별도 테이블로 분리
-- =====================================================

CREATE TABLE grade_3nf (
    grade VARCHAR(20) PRIMARY KEY,
    discount_rate VARCHAR(10)
);

CREATE TABLE customer_3nf (
    customer_id VARCHAR(20) PRIMARY KEY,
    grade VARCHAR(20),
    FOREIGN KEY (grade) REFERENCES grade_3nf(grade)
);

CREATE TABLE event_participation_3nf (
    customer_id VARCHAR(20),
    event_no VARCHAR(10),
    win_yn CHAR(1),
    PRIMARY KEY (customer_id, event_no),
    FOREIGN KEY (customer_id) REFERENCES customer_3nf(customer_id)
);

INSERT INTO grade_3nf VALUES
('gold',   '10%'),
('vip',    '20%'),
('silver', '5%');

select * from grade_3nf;

INSERT INTO customer_3nf VALUES
('apple',  'gold'),
('banana', 'vip'),
('carrot', 'gold'),
('orange', 'silver');

select * from customer_3nf;
 
INSERT INTO event_participation_3nf VALUES
('apple',  'E001', 'Y'),
('apple',  'E005', 'N'),
('apple',  'E010', 'Y'),
('banana', 'E002', 'N'),
('banana', 'E005', 'Y'),
('carrot', 'E003', 'Y'),
('carrot', 'E007', 'Y'),
('orange', 'E004', 'N');

SELECT * FROM grade_3nf;
SELECT * FROM customer_3nf;
SELECT * FROM event_participation_3nf;


-- 3NF 최종 조인 결과
SELECT
    c.customer_id,
    e.event_no,
    e.win_yn,
    c.grade,
    g.discount_rate
FROM customer_3nf c
JOIN event_participation_3nf e
ON c.customer_id = e.customer_id
JOIN grade_3nf g
ON c.grade = g.grade
ORDER BY c.customer_id, e.event_no;


-- 트랜잭션 연습
-- TCL : start transaction, rollback, commit

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

select @@autocommit;

-- Data Control Language(DCL) : 사용자 생성/권한부여, 백업/회복
-- =====================================================
-- MySQL 8 사용자 생성 / 접속 가능 / 권한 부여 / 권한 회수 / 삭제
-- =====================================================

-- 1. 실습용 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS sqldb;

-- 2. 기존 사용자가 있으면 삭제
DROP USER IF EXISTS 'testuser'@'localhost';

create user 'testuser'@'localhost'
identified by 'Test1234!';

grant usage
on *.*
to 'testuser'@'localhost';

grant select, update, insert
on sqldb.*
to 'testuser'@'localhost';

show grants 
for 'testuser'@'localhost';

REVOKE SELECT, INSERT, UPDATE
ON sqldb.*
FROM 'testuser'@'localhost';

drop user 'testuser'@'localhost';

select host, user from mysql.user;

create database jdbc_ex;
create user 'scoula'@'%' identified by '1234';
grant all privileges on jdbc_ex.* to 'scoula'@'%';
flush privileges;




