-- 왼쪽에 진하게 표시된 db가 없는 경우, 선택된 db가 없다는 의미..

-- sql문 사용할 때는 반드시  db를 먼저 선택하고 해주세요.alter

-- db선택함.

use employees;

create table test (
	testid int,
    testpw int
    );
    
    
    

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