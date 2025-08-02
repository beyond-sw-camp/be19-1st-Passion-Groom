select member_id, member_name, member_point, member_update from member where member_id = 3;
-- cash 테이블에 포인트가 추가 되었을 때 실행되는 트리거 생성 

DELIMITER $$

CREATE TRIGGER trg_add_point_after_cash_insert
AFTER INSERT ON cash
FOR EACH ROW
BEGIN
  UPDATE member
  SET member_point = member_point + NEW.cash_amount,
      member_update = NOW()
  WHERE member_id = NEW.member_id;
END$$

DELIMITER ;

-- 회원, 현재 포인트, 회원 마지막 수정일자 조회

SELECT member_id, member_name, member_point, member_update
FROM member
WHERE member_id = 3;

-- 포인트 추가
INSERT into cash (cash_amount, cash_method, cash_stamp_dt, member_id)
values (1000,'무통장입금',now(),3);


-- 추가 후 회원, 현재 포인트, 회원 마지막 수정일자 조회
SELECT member_id, member_name, member_point, member_update
FROM member
WHERE member_id = 3;
