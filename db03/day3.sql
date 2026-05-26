-- 나는 주석!!!

-- db목록
show databases;

-- table목록
show tables; -- use sqldb; 선택한 db내의 테이블 목록

-- table의 스키마(구조)
describe usertbl;
desc buytbl;

-- table내의 내용(데이터) 
-- crud(삽입, 조회, 갱신, 삭제 --> DML)
-- select 컬럼명, 컬럼명, 컬럼명 from 테이블이름;
-- 조회할 때는 내가 원하는 컬럼명 순서대로 조회가 가능
select * from usertbl; -- 전체 컬럼(열)과 로우(행) 검색
select userID, addr, mDate from usertbl; -- 원하는 컬럼만 검색, 전체 행 검색
select userID, addr, mDate from usertbl where addr = '경남';
-- String s = "select * from usertbl where addr = '경남'";

select userID, addr, mDate from usertbl where addr = '경남' or addr = '서울';
select userID, addr, mDate from usertbl where addr = '경남' and userID = 'KBS';

select userID, name 
from usertbl
where birthYear >= 1970 and height >= 182;

select userID, name, birthYear 
from usertbl
where birthYear between 1970 and 1975; -- 사이값

select userID, name, birthYear 
from usertbl
where birthYear in (1971, 1973); -- 특정한 값 목록을 조건으로 하고 싶을 때

select userID, name, birthYear 
from usertbl
where name = '바비킴';

select * from usertbl;

select userID, name, birthYear 
from usertbl
where name like '김%'; -- %의 의미는 0부터 무한대

select userID, name, birthYear 
from usertbl
where name like '%김%'; 

select userID, name, birthYear 
from usertbl
where name like '_김__'; -- _의 의미는 한글자! 무조건

-- 서브쿼리 : 선행되는 쿼리를 실행하고 나서 그 결과를 다른 쿼리에서 사용하는 것.
-- (선행되는 쿼리문)
select name, height 
from usertbl
where height > 177; -- 조건값을 정확히 알고 있으면 그냥 넣으면 됨.

-- 조건값을 미리 select문을 실행해서 그 결과를 가지고 와 넣어야 될 때
select name, height 
from usertbl
where height > (select height from usertbl where name = '김경호'); 

-- 서브쿼리를 사용할 때는 별도로 서브쿼리를 먼저 테스트해보세요.!!
select height from usertbl where name = '김경호';

-- 비교연산자(>, >=, ...) 바로 옆에 쓰는 서브쿼리는 결과가 하나여야함.
-- 여러개인 경우 in같은 키워드를 추가해야주어야 함.

-- 서브쿼리 키워드
-- where height = (서브쿼리) --> 서브쿼리 결과가 1개
-- where height in (서브쿼리) --> 서브쿼리 결과가 여러개 
-- where height = any (서브쿼리)

-- ------------------------------------------------------------
-- 서브쿼리 결과가 1개이상일 때 에러남. -->  = any, in으로 수정해주어야함.
select name, height 
from usertbl
where height = (select height from usertbl where name = '김경호'); -- 177

SELECT name, height 
FROM usertbl 
WHERE height = any (SELECT height FROM usertbl WHERE addr = '경남'); -- 170, 173

SELECT name, height 
FROM usertbl 
WHERE height IN (SELECT height FROM usertbl WHERE addr = '경남'); -- 170, 173

-- ANY : 서브쿼리 결과 중 "하나만 아무거나" 만족하면 TRUE
-- < ANY  : 최대값보다 작으면 TRUE
-- > ANY  : 최소값보다 크면 TRUE

SELECT name, height
FROM usertbl
WHERE height > ANY
      (SELECT height
       FROM usertbl
       WHERE addr='경남');

SELECT name, height
FROM usertbl
WHERE height >
      (SELECT MIN(height)
       FROM usertbl
       WHERE addr='경남');
       
-- ALL : 서브쿼리 결과를 모두 만족해야 TRUE
-- < ALL : 최소값보다 작아야 TRUE --> min()함수로 변경 가능
-- > ALL : 최대값보다 커야 TRUE --> max()함수로 변경 가능

SELECT name, height
FROM usertbl
WHERE height > ALL
      (SELECT height
       FROM usertbl
       WHERE addr='경남');


SELECT name, height
FROM usertbl
WHERE height >
      (SELECT MAX(height)
       FROM usertbl
       WHERE addr='경남');
       
-- ------------------------------------------------------
-- 문자열 서브쿼리는 in, = any사용 가능
SELECT name, height 
FROM usertbl 
WHERE name in (SELECT name FROM usertbl WHERE addr = '경남');

SELECT name, height 
FROM usertbl 
WHERE name = any (SELECT name FROM usertbl WHERE addr = '경남');
-- ------------------------------------------------------


-- 정렬 order by
select name, height
from usertbl
order by height; -- 오름차순 asc가 생략됨.

select name, height
from usertbl
order by height desc; -- 내림차순은 반드스 desc로 써주어야함.

select name, height
from usertbl
order by height desc, name desc; -- 1차 정렬 후, 2차 정렬을 하고자 하는 경우 ,로 연결

select name, height
from usertbl
order by height desc, name desc
limit 5; -- limit는 맨 끝에!, 정렬한 다음 써주어야함.

select name, height
from usertbl
order by height desc, name desc
limit 0, 1; -- 행도 위치값이 있어서 맨 위가 0번임. 0번부터 1개(offet)를 가지고 와라!




-- 그룹지어 집계해보자.!!!
select * from usertbl;
select * from buytbl;

select count(*) from buytbl; -- row개수, 12개

-- group by할때 select뒤에는 그룹지을때 사용한 컬럼, 집계함수만 가능!!!
-- 순서 select~from~where --> group + having --> order by --> limit
select userId, 
	count(userId) as '로우 수', 
    sum(amount) as 합계, 
    min(price) as 가격최소값,
    max(amount) as 수량최대값
from buytbl
group by userID
having 합계 >= 5
order by 수량최대값 desc
limit 2;











