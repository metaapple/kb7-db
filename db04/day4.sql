-- MySQL 내장 함수 실습 스크립트
-- 제어 흐름 / 문자열 / 수학 / 날짜시간 / 형 변환

DROP DATABASE IF EXISTS func_practice;
CREATE DATABASE func_practice;
USE func_practice;

-- height DECIMAL(5,1) : 소수 저장용 데이터 타입, DECIMAL(전체자리수, 소수자리수)
-- 숫자 총 5칸, 소수는 1칸 사용
-- 정수 자리수 + 소수 자리수 = 총 5자리
-- 1234.5, 99.9, 180 가능, 12345.6 불가능
-- 최대 저장 가능 값 = 9999.9

CREATE TABLE memberTBL (
    memberID INT PRIMARY KEY AUTO_INCREMENT,
    memberName VARCHAR(30),
    age INT,
    height DECIMAL(5,1),
    phone VARCHAR(20),
    address VARCHAR(100),
    joinDate DATE,
    point INT,
    grade VARCHAR(10)
);

desc membertbl;

INSERT INTO memberTBL
(memberName, age, height, phone, address, joinDate, point, grade)
VALUES
('김철수', 25, 175.5, '010-1111-2222', '서울 강남구', '2024-01-15', 1200, 'SILVER'),
('이영희', 31, 162.3, '010-3333-4444', '부산 해운대구', '2023-11-02', 3500, 'GOLD'),
('박민수', 19, 181.0, NULL, '대전 중구', '2025-03-10', 500, 'BRONZE'),
('최지은', 42, 158.8, '010-5555-6666', '인천 남동구', '2022-07-20', 7200, 'VIP'),
('정하늘', 28, 169.4, NULL, '서울 마포구', '2024-09-01', 2100, 'SILVER');

-- insert구문을 이용해서 값들을 넣음.(실제 값 == 인스턴스)

select * from membertbl;

-- 1. 제어 흐름 함수
SELECT
    memberName,
    point,
    IF(point >= 3000, '우수회원', '일반회원') AS 회원구분
FROM memberTBL;

SELECT
    memberName,
    phone,
    IFNULL(phone, '전화번호 없음') AS phone_result
FROM memberTBL;

SELECT
    memberName,
    age,
    CASE
        WHEN age < 20 THEN '10대'
        WHEN age < 30 THEN '20대'
        WHEN age < 40 THEN '30대'
        ELSE '40대 이상'
    END AS age_group
FROM memberTBL;

-- 2. 문자열 함수
SELECT
    memberName,
    CONCAT(memberName, '님') AS name_text,
    CONCAT_WS(' / ', memberName, address, grade) AS member_info
FROM memberTBL;

SELECT
    memberName,
    LENGTH(memberName) AS byte_length,
    CHAR_LENGTH(memberName) AS char_length
FROM memberTBL;

SELECT
    memberName,
    LEFT(phone, 3) AS phone_start,
    RIGHT(phone, 4) AS phone_end
FROM memberTBL
WHERE phone IS NOT NULL;

SELECT
    memberName,
    address,
    REPLACE(address, '서울', 'SEOUL') AS changed_address
FROM memberTBL;

SELECT
    memberName,
    SUBSTRING(address, 1, 2) AS region
FROM memberTBL;

SELECT
    TRIM('   MySQL 함수 실습   ') AS trim_result;

-- 3. 수학 함수
SELECT
    memberName,
    height,
    ROUND(height, 0) AS rounded_height,
    CEIL(height) AS ceil_height,
    FLOOR(height) AS floor_height
FROM memberTBL;

SELECT
    memberName,
    point,
    MOD(point, 1000) AS point_remainder,
    SQRT(point) AS sqrt_point
FROM memberTBL;

SELECT
    ABS(-100) AS abs_result,
    POW(2, 3) AS pow_result,
    RAND() AS random_value,
    SIGN(-30) AS sign_result;

-- 4. 날짜 및 시간 함수
SELECT
    CURDATE() AS today,
    CURTIME(),
    NOW() AS now_time,
    SYSDATE() AS sys_time;

SELECT
    memberName,
    joinDate,
    DATEDIFF(CURDATE(), joinDate) AS 가입후_지난일수
FROM memberTBL;

SELECT
    memberName,
    joinDate,
    DATE_ADD(joinDate, INTERVAL 100 DAY) AS 가입_100일후,
    DATE_SUB(joinDate, INTERVAL 30 DAY) AS 가입_30일전
FROM memberTBL;

SELECT
    memberName,
    joinDate,
    YEAR(joinDate) AS 가입연도,
    MONTH(joinDate) AS 가입월,
    DAY(joinDate) AS 가입일
FROM memberTBL;

SELECT
    LAST_DAY(CURDATE()) AS 이번달_마지막날;

-- 5. 형 변환 함수
SELECT
    CAST('2025-05-20' AS DATE) AS cast_date,
    CAST('12345' AS UNSIGNED) AS cast_number,
    CAST(12345 AS CHAR) AS cast_char;

SELECT
    CONVERT('2025-05-20', DATE) AS convert_date,
    CONVERT(12345, CHAR) AS convert_char;

-- 6. 실무형 조회 예제
SELECT
    memberName,
    grade,
    point,
    CASE
        WHEN point >= 7000 THEN '최우수 고객'
        WHEN point >= 3000 THEN '우수 고객'
        WHEN point >= 1000 THEN '일반 고객'
        ELSE '신규 고객'
    END AS customer_level
FROM memberTBL
ORDER BY point DESC;

SELECT
    memberName,
    IFNULL(phone, '미등록') AS phone,
    CONCAT(SUBSTRING(address, 1, 2), ' 지역 회원') AS region_label,
    DATEDIFF(CURDATE(), joinDate) AS active_days
FROM memberTBL
ORDER BY active_days DESC;


-- ---------------------
-- join연습

USE sqldb;
CREATE TABLE stdtbl(
	stdName VARCHAR(10) NOT NULL PRIMARY KEY,
	addr CHAR(4) NOT NULL
);

CREATE TABLE clubtbl(
	clubName VARCHAR(10) NOT NULL PRIMARY KEY,
	roomNo CHAR(4) NOT NULL
);

CREATE TABLE stdclubtbl(
	num int AUTO_INCREMENT NOT NULL PRIMARY KEY,
	stdName VARCHAR(10) NOT NULL,
	clubName VARCHAR(10) NOT NULL,
	FOREIGN KEY(stdName) REFERENCES stdtbl(stdName),
	FOREIGN KEY(clubName) REFERENCES clubtbl(clubName)
);



-- 회원 데이터

-- 학생 테이블 데이터
INSERT INTO stdtbl VALUES
('김범수', '경남'),
('성시경', '서울'),
('조용필', '경기'),
('은지원', '경북'),
('바비킴', '서울');

-- alt + = (글자깨짐 사라짐)
select * from stdtbl;

-- 동아리 테이블 데이터
INSERT INTO clubtbl VALUES
('수영', '101호'),
('바둑', '102호'),
('축구', '103호'),
('봉사', '104호');

select * from clubtbl;

-- 학생_동아리 테이블 데이터
INSERT INTO stdclubtbl(stdName, clubName) VALUES
('김범수', '바둑'),
('김범수', '축구'),
('조용필', '축구'),
('은지원', '축구'),
('은지원', '봉사'),
('바비킴', '봉사');

select * from stdclubtbl;

-- join을 해보자.!!!
-- 하나 이상의 테이블을 합해서 원하는 컬럼들 조회를 해야할 때

select S.stdName, addr, clubName
from stdtbl S
inner join stdclubtbl SC
on S.stdName = SC.stdName;

select S.stdName, addr, C.clubName, roomNo
from stdtbl S
inner join stdclubtbl SC
on S.stdName = SC.stdName
inner join clubtbl C
on SC.clubName = C.clubName
order by S.stdName
limit 3;

select SC.num, SC.stdName, SC.clubName, C.roomNo
from stdclubtbl SC
left join clubtbl C
on SC.clubName = C.clubName;

-- ---------------------
-- self join
USE sqldb;
CREATE TABLE emptbl(emp CHAR(3), manager CHAR(3), empTel VARCHAR(8));
INSERT INTO empTbl VALUES('나사장', NULL, '0000');
INSERT INTO empTbl VALUES('김재무', '나사장', '2222');
INSERT INTO empTbl VALUES('김부장', '김재무', '2222-1');
INSERT INTO empTbl VALUES('이부장', '김재무', '2222-2');
INSERT INTO empTbl VALUES('우대리', '이부장', '2222-2-1');
INSERT INTO empTbl VALUES('지사원', '이부장', '2222-2-2');
INSERT INTO empTbl VALUES('이영업', '나사장', '1111');
INSERT INTO emptbl VALUES('한과장', '이영업', '1111-1');
INSERT INTO empTbl VALUES('최정보', '나사장', '5355');
INSERT INTO empTbl VALUES('윤차장', '최정보','3355-1');
INSERT INTO empTbl VALUES('이주임', '윤자장', '5335-1-1');
SELECT * FROM empTbl;

SELECT A.emp AS '부하직원', B.emp AS '직속상관', B.empTel AS '직속상관연락처'
FROM empTbl A
INNER JOIN empTbl B
	ON A.manager = B.emp
WHERE A.emp = '우대리';

-- MySQL 내장 함수 실습 스크립트
-- 제어 흐름 / 문자열 / 수학 / 날짜시간 / 형 변환

DROP DATABASE IF EXISTS func_practice;
CREATE DATABASE func_practice;
USE func_practice;

-- height DECIMAL(5,1) : 소수 저장용 데이터 타입, DECIMAL(전체자리수, 소수자리수)
-- 숫자 총 5칸, 소수는 1칸 사용
-- 정수 자리수 + 소수 자리수 = 총 5자리
-- 1234.5, 99.9, 180 가능, 12345.6 불가능
-- 최대 저장 가능 값 = 9999.9

CREATE TABLE memberTBL (
    memberID INT PRIMARY KEY AUTO_INCREMENT,
    memberName VARCHAR(30),
    age INT,
    height DECIMAL(5,1),
    phone VARCHAR(20),
    address VARCHAR(100),
    joinDate DATE,
    point INT,
    grade VARCHAR(10)
);

desc membertbl;

INSERT INTO memberTBL
(memberName, age, height, phone, address, joinDate, point, grade)
VALUES
('김철수', 25, 175.5, '010-1111-2222', '서울 강남구', '2024-01-15', 1200, 'SILVER'),
('이영희', 31, 162.3, '010-3333-4444', '부산 해운대구', '2023-11-02', 3500, 'GOLD'),
('박민수', 19, 181.0, NULL, '대전 중구', '2025-03-10', 500, 'BRONZE'),
('최지은', 42, 158.8, '010-5555-6666', '인천 남동구', '2022-07-20', 7200, 'VIP'),
('정하늘', 28, 169.4, NULL, '서울 마포구', '2024-09-01', 2100, 'SILVER');

-- insert구문을 이용해서 값들을 넣음.(실제 값 == 인스턴스)

select * from membertbl;

-- 1. 제어 흐름 함수
SELECT
    memberName,
    point,
    IF(point >= 3000, '우수회원', '일반회원') AS 회원구분
FROM memberTBL;

SELECT
    memberName,
    phone,
    IFNULL(phone, '전화번호 없음') AS phone_result
FROM memberTBL;

SELECT
    memberName,
    age,
    CASE
        WHEN age < 20 THEN '10대'
        WHEN age < 30 THEN '20대'
        WHEN age < 40 THEN '30대'
        ELSE '40대 이상'
    END AS age_group
FROM memberTBL;

-- 2. 문자열 함수
SELECT
    memberName,
    CONCAT(memberName, '님') AS name_text,
    CONCAT_WS(' / ', memberName, address, grade) AS member_info
FROM memberTBL;

SELECT
    memberName,
    LENGTH(memberName) AS byte_length,
    CHAR_LENGTH(memberName) AS char_length
FROM memberTBL;

SELECT
    memberName,
    LEFT(phone, 3) AS phone_start,
    RIGHT(phone, 4) AS phone_end
FROM memberTBL
WHERE phone IS NOT NULL;

SELECT
    memberName,
    address,
    REPLACE(address, '서울', 'SEOUL') AS changed_address
FROM memberTBL;

SELECT
    memberName,
    SUBSTRING(address, 1, 2) AS region
FROM memberTBL;

SELECT
    TRIM('   MySQL 함수 실습   ') AS trim_result;

-- 3. 수학 함수
SELECT
    memberName,
    height,
    ROUND(height, 0) AS rounded_height,
    CEIL(height) AS ceil_height,
    FLOOR(height) AS floor_height
FROM memberTBL;

SELECT
    memberName,
    point,
    MOD(point, 1000) AS point_remainder,
    SQRT(point) AS sqrt_point
FROM memberTBL;

SELECT
    ABS(-100) AS abs_result,
    POW(2, 3) AS pow_result,
    RAND() AS random_value,
    SIGN(-30) AS sign_result;

-- 4. 날짜 및 시간 함수
SELECT
    CURDATE() AS today,
    CURTIME(),
    NOW() AS now_time,
    SYSDATE() AS sys_time;

SELECT
    memberName,
    joinDate,
    DATEDIFF(CURDATE(), joinDate) AS 가입후_지난일수
FROM memberTBL;

SELECT
    memberName,
    joinDate,
    DATE_ADD(joinDate, INTERVAL 100 DAY) AS 가입_100일후,
    DATE_SUB(joinDate, INTERVAL 30 DAY) AS 가입_30일전
FROM memberTBL;

SELECT
    memberName,
    joinDate,
    YEAR(joinDate) AS 가입연도,
    MONTH(joinDate) AS 가입월,
    DAY(joinDate) AS 가입일
FROM memberTBL;

SELECT
    LAST_DAY(CURDATE()) AS 이번달_마지막날;

-- 5. 형 변환 함수
SELECT
    CAST('2025-05-20' AS DATE) AS cast_date,
    CAST('12345' AS UNSIGNED) AS cast_number,
    CAST(12345 AS CHAR) AS cast_char;

SELECT
    CONVERT('2025-05-20', DATE) AS convert_date,
    CONVERT(12345, CHAR) AS convert_char;

-- 6. 실무형 조회 예제
SELECT
    memberName,
    grade,
    point,
    CASE
        WHEN point >= 7000 THEN '최우수 고객'
        WHEN point >= 3000 THEN '우수 고객'
        WHEN point >= 1000 THEN '일반 고객'
        ELSE '신규 고객'
    END AS customer_level
FROM memberTBL
ORDER BY point DESC;

SELECT
    memberName,
    IFNULL(phone, '미등록') AS phone,
    CONCAT(SUBSTRING(address, 1, 2), ' 지역 회원') AS region_label,
    DATEDIFF(CURDATE(), joinDate) AS active_days
FROM memberTBL
ORDER BY active_days DESC;


-- ---------------------
-- join연습

USE sqldb;
CREATE TABLE stdtbl(
	stdName VARCHAR(10) NOT NULL PRIMARY KEY,
	addr CHAR(4) NOT NULL
);

CREATE TABLE clubtbl(
	clubName VARCHAR(10) NOT NULL PRIMARY KEY,
	roomNo CHAR(4) NOT NULL
);

CREATE TABLE stdclubtbl(
	num int AUTO_INCREMENT NOT NULL PRIMARY KEY,
	stdName VARCHAR(10) NOT NULL,
	clubName VARCHAR(10) NOT NULL,
	FOREIGN KEY(stdName) REFERENCES stdtbl(stdName),
	FOREIGN KEY(clubName) REFERENCES clubtbl(clubName)
);



-- 회원 데이터

-- 학생 테이블 데이터
INSERT INTO stdtbl VALUES
('김범수', '경남'),
('성시경', '서울'),
('조용필', '경기'),
('은지원', '경북'),
('바비킴', '서울');

-- alt + = (글자깨짐 사라짐)
select * from stdtbl;

-- 동아리 테이블 데이터
INSERT INTO clubtbl VALUES
('수영', '101호'),
('바둑', '102호'),
('축구', '103호'),
('봉사', '104호');

select * from clubtbl;

-- 학생_동아리 테이블 데이터
INSERT INTO stdclubtbl(stdName, clubName) VALUES
('김범수', '바둑'),
('김범수', '축구'),
('조용필', '축구'),
('은지원', '축구'),
('은지원', '봉사'),
('바비킴', '봉사');

select * from stdclubtbl;

-- join을 해보자.!!!
-- 하나 이상의 테이블을 합해서 원하는 컬럼들 조회를 해야할 때

select S.stdName, addr, clubName
from stdtbl S
inner join stdclubtbl SC
on S.stdName = SC.stdName;

select S.stdName, addr, C.clubName, roomNo
from stdtbl S
inner join stdclubtbl SC
on S.stdName = SC.stdName
inner join clubtbl C
on SC.clubName = C.clubName
order by S.stdName
limit 3;

select SC.num, SC.stdName, SC.clubName, C.roomNo
from stdclubtbl SC
left join clubtbl C
on SC.clubName = C.clubName;

-- ---------------------
-- self join
USE sqldb;
CREATE TABLE emptbl(emp CHAR(3), manager CHAR(3), empTel VARCHAR(8));
INSERT INTO empTbl VALUES('나사장', NULL, '0000');
INSERT INTO empTbl VALUES('김재무', '나사장', '2222');
INSERT INTO empTbl VALUES('김부장', '김재무', '2222-1');
INSERT INTO empTbl VALUES('이부장', '김재무', '2222-2');
INSERT INTO empTbl VALUES('우대리', '이부장', '2222-2-1');
INSERT INTO empTbl VALUES('지사원', '이부장', '2222-2-2');
INSERT INTO empTbl VALUES('이영업', '나사장', '1111');
INSERT INTO emptbl VALUES('한과장', '이영업', '1111-1');
INSERT INTO empTbl VALUES('최정보', '나사장', '5355');
INSERT INTO empTbl VALUES('윤차장', '최정보','3355-1');
INSERT INTO empTbl VALUES('이주임', '윤자장', '5335-1-1');
SELECT * FROM empTbl;

SELECT A.emp AS '부하직원', B.emp AS '직속상관', B.empTel AS '직속상관연락처'
FROM empTbl A
INNER JOIN empTbl B
	ON A.manager = B.emp
WHERE A.emp = '우대리';

