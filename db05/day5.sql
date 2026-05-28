-- join 복습

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

-- 테이블의 구조(제약조건)
desc company;
desc product;

-- 테이블의 인스턴스
select * from company;
select * from product;

-- select 컬럼명, 컬럼명
-- from 테이블명
-- where 조건;

-- 양쪽 테이블에 공통적으로 있는 항목의 값들을 찾아서 조회
select P.id as pid, P.name as pname , C.name as `c name`
from product P 
inner join company C
on C.id = P.company;

-- 한쪽만 조회화면에 보이게 하고 싶은 경우(outer join)
select C.name as `c name`, C.tel, P.id as pid, P.name as pname
from company C 
left join product P
on C.id = P.company;

select P.id as pid, P.name as pname, C.name as `c name`, C.tel
from company C 
right join product P
on C.id = P.company;

-- ddl 연습
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
	
	foreign key (userID)
    references usertbl(userID)
);

desc usertbl;
desc buytbl;

-- =====================================================
-- 4. 데이터 입력
-- =====================================================

INSERT INTO usertbl VALUES
('LSG', '이승기', 1987, '서울', '011', '1111111', 182, '2008-08-08'),
('KBS', '김범수', 1979, '경남', '011', '2222222', 173, '2012-04-04'),
('KKH', '김경호', 1971, '전남', '019', '3333333', 177, '2007-07-07');

select * from usertbl;

INSERT INTO buytbl(userID, prodName, groupName, price, amount) VALUES
('KBS', '운동화', NULL, 30, 2),
('KBS', '노트북', '전자', 1000, 1),
('LSG', '모니터', '전자', 200, 1);

-- fk error --> 자동증가는 됨. 
INSERT INTO buytbl VALUES (null, 'AAA', '운동화', NULL, 30, 2);
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`tabledb`.`buytbl`, CONSTRAINT `buytbl_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `usertbl` (`userID`))	0.000 sec 

-- fk ok
INSERT INTO buytbl VALUES (null, 'KKH', '운동화', NULL, 30, 2);

select * from buytbl;

select U.*, B.*
from usertbl U
inner join buytbl B
on U.userID = B.userID;


-- unique 제약조건 추가 
alter table usertbl
add email varchar(30) unique;

desc usertbl;

select * from usertbl;

update usertbl
set email = "aaa@email.com"
where userId = "LSG";

-- unique error
update usertbl
set email = "aaa@email.com"
where userId = "KBS";
-- Error Code: 1062. Duplicate entry 'aaa@email.com' for key 'usertbl.email'	0.000 sec

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

show databases;

-- ===========  중요!!! =====================
-- select결과  --> 컬럼명 + 검색결과 데이터
-- insert, update, delete결과 --> 처리된 row수(정수)
-- =========================================

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

show databases;
show tables;
show index from prodtbl;

use mysql;
show tables;


