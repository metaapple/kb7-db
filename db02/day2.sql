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

