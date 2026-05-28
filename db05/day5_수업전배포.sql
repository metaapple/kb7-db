-- ddl


-- 조인 확인 문제
use sqldb;

CREATE TABLE COMPANY (
    ID VARCHAR(50) PRIMARY KEY,
    NAME VARCHAR(100),
    ADDR VARCHAR(200),
    TEL VARCHAR(20)
);

CREATE TABLE PRODUCT (
    ID INT PRIMARY KEY,
    NAME VARCHAR(50),
    CONTENT VARCHAR(100),
    PRICE INT,
    COMPANY VARCHAR(50),
    IMG VARCHAR(50),
    FOREIGN KEY (COMPANY) REFERENCES COMPANY(ID)
);

INSERT INTO company (ID, NAME, ADDR, TEL) VALUES
('c100', 'good', 'seoul', '011'),
('c200', 'joa', 'busan', '012'),
('c300', 'maria', 'ulsan', '013'),
('c400', 'my', 'kwangju', '014');

INSERT INTO PRODUCT (ID, NAME, CONTENT, PRICE, COMPANY, IMG) VALUES
(110, 'food11', 'fun food11', 11000, NULL, '11.png'),
(111, 'food12', 'fun food12', 12000, NULL, '12.png'),
(100, 'food1', 'fun food1', 1000, 'c100', '1.png'),
(101, 'food2', 'fun food2', 2000, 'c200', '2.png'),
(102, 'food3', 'fun food3', 3000, 'c300', '3.png'),
(103, 'food4', 'fun food4', 4000, 'c300', '4.png'),
(104, 'food5', 'fun food5', 5000, 'c100', '5.png'),
(105, 'food6', 'fun food6', 6000, 'c100', '6.png'),
(106, 'food7', 'fun food7', 7000, 'c200', '7.png'),
(107, 'food8', 'fun food8', 8000, 'c300', '8.png'),
(108, 'food9', 'fun food9', 9000, 'c100', '9.png'),
(109, 'food10', 'fun food10', 10000, 'c100', '10.png');

SELECT P.ID AS Product_ID, P.NAME AS Product_Name, C.NAME AS Company_Name
FROM PRODUCT P
INNER JOIN COMPANY C ON P.COMPANY = C.ID;

SELECT 
P.ID AS Product_ID, 
P.NAME AS Product_Name, C.NAME AS Company_Name
FROM PRODUCT P
LEFT OUTER JOIN COMPANY C 
ON P.COMPANY = C.ID;

SELECT 
P.ID AS Product_ID, 
P.NAME AS Product_Name, C.NAME AS Company_Name
FROM PRODUCT P
RIGHT OUTER JOIN COMPANY C 
ON P.COMPANY = C.ID;

create table p (
	pid int
);
rename table p to p2;
desc p2;


-- ddl 실습

-- =====================================================
-- DDL 실습 전체 스크립트 (MySQL 8)
-- PDF 기반 통합 실습
-- =====================================================

-- =====================================================
-- 1. DATABASE 생성
-- =====================================================

DROP DATABASE IF EXISTS tableDB;
CREATE DATABASE tableDB;
USE tableDB;

-- =====================================================
-- 2. usertbl 생성
-- =====================================================

DROP TABLE IF EXISTS usertbl;

CREATE TABLE usertbl (
    userID CHAR(8) NOT NULL PRIMARY KEY,
    name VARCHAR(10) NOT NULL,
    birthYear INT NOT NULL,
    addr CHAR(2) NOT NULL,
    mobile1 CHAR(3) NULL,
    mobile2 CHAR(8) NULL,
    height SMALLINT NULL,
    mDate DATE NULL
);

-- =====================================================
-- 3. buytbl 생성 (외래키 포함)
-- =====================================================

DROP TABLE IF EXISTS buytbl;

CREATE TABLE buytbl (
    num INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    userID CHAR(8) NOT NULL,
    prodName CHAR(6) NOT NULL,
    groupName CHAR(4) NULL,
    price INT NOT NULL,
    amount SMALLINT NOT NULL,

    CONSTRAINT FK_buytbl_usertbl
    FOREIGN KEY(userID)
    REFERENCES usertbl(userID)
);

-- =====================================================
-- 4. 데이터 입력
-- =====================================================

INSERT INTO usertbl VALUES
('LSG', '이승기', 1987, '서울', '011', '1111111', 182, '2008-08-08'),
('KBS', '김범수', 1979, '경남', '011', '2222222', 173, '2012-04-04'),
('KKH', '김경호', 1971, '전남', '019', '3333333', 177, '2007-07-07');

INSERT INTO buytbl(userID, prodName, groupName, price, amount) VALUES
('KBS', '운동화', NULL, 30, 2),
('KBS', '노트북', '전자', 1000, 1),
('LSG', '모니터', '전자', 200, 1);

-- =====================================================
-- 5. 조회
-- =====================================================

SELECT * FROM usertbl;
SELECT * FROM buytbl;

-- JOIN 조회
SELECT
    u.userID,
    u.name,
    b.prodName,
    b.price,
    b.amount
FROM usertbl u
INNER JOIN buytbl b
ON u.userID = b.userID;

-- =====================================================
-- 6. UNIQUE 제약조건
-- =====================================================


ALTER TABLE usertbl
ADD email VARCHAR(30) UNIQUE;

-- 테스트
UPDATE usertbl
SET email = 'aaa@test.com'
WHERE userID = 'LSG';

select * from usertbl;

-- error
UPDATE usertbl
SET email = 'aaa@test.com'
WHERE userID = 'KBS';

-- =====================================================
-- 7. CHECK 제약조건
-- =====================================================

ALTER TABLE usertbl
ADD CONSTRAINT CK_height
CHECK(height >= 100);

select * from usertbl;

-- error
INSERT INTO usertbl
(userID, name, birthYear, height, addr)
VALUES
('APP', '이순신', 1982, 50, '서울');

-- ok
INSERT INTO usertbl
(userID, name, birthYear, height, addr)
VALUES
('APP', '이순신', 1982, 150, '서울');

select * from usertbl;

-- =====================================================
-- 8. DEFAULT 설정
-- =====================================================

ALTER TABLE usertbl
ADD point INT DEFAULT 0;

-- DEFAULT 자동 입력 확인
INSERT INTO usertbl
(userID, name, birthYear, addr)
VALUES
('WB', '원빈', 1982, '서울');

SELECT * FROM usertbl;

-- =====================================================
-- 9. ALTER TABLE 실습
-- =====================================================

-- 컬럼 추가
ALTER TABLE usertbl
ADD homepage VARCHAR(30)
DEFAULT 'http://www.naver.com';

-- 컬럼 수정
ALTER TABLE usertbl
MODIFY homepage VARCHAR(50);

desc usertbl;

-- 컬럼 이름 변경
ALTER TABLE usertbl
CHANGE COLUMN name uName VARCHAR(20) NULL;

desc usertbl;

-- 컬럼 삭제
ALTER TABLE usertbl
DROP COLUMN mobile1;

desc usertbl;

-- =====================================================
-- 10. 복합 PRIMARY KEY
-- =====================================================

DROP TABLE IF EXISTS prodtbl;

CREATE TABLE prodtbl (
    prodCode CHAR(3) NOT NULL,
    prodID CHAR(4) NOT NULL,
    prodDate DATETIME NOT NULL,
    prodCur CHAR(10) NULL,

    CONSTRAINT PK_prodtbl
    PRIMARY KEY(prodCode, prodID)
);

SHOW INDEX FROM prodtbl;

-- =====================================================
-- 11. RENAME 실습
-- =====================================================

RENAME TABLE prodtbl TO producttbl;

desc producttbl;

ALTER TABLE producttbl
RENAME COLUMN prodCur TO status;

-- =====================================================
-- 12. TRUNCATE 실습
-- =====================================================

TRUNCATE TABLE producttbl;

-- =====================================================
-- 13. DROP 실습
-- 외래키 테이블 먼저 삭제
-- =====================================================

DROP TABLE IF EXISTS buytbl;
DROP TABLE IF EXISTS usertbl;
DROP TABLE IF EXISTS producttbl;

-- =====================================================
-- 14. DATABASE 삭제
-- =====================================================

DROP DATABASE IF EXISTS tableDB;



-- 정규화 확인

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

INSERT INTO customer_3nf VALUES
('apple',  'gold'),
('banana', 'vip'),
('carrot', 'gold'),
('orange', 'silver');

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
