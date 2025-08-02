DELIMITER $$

CREATE TRIGGER trg_member_certify_update
BEFORE UPDATE ON member
FOR EACH ROW
BEGIN
  -- 경력(member_career값이 변경되면 인증상태를 'pending'으로 설정
  IF NEW.member_career IS NOT NULL AND NEW.member_career <> OLD.member_career THEN
    SET NEW.member_certify_status = 'pending';

    -- 멘토였던 경우 일반회원으로 강등
    IF OLD.member_role = 2 THEN
      SET NEW.member_role = 1;
    END IF;
  END IF;

  -- 인증 상태가 'approved'로 바뀌면 멘토(member_role = 2)로 변경
  IF NEW.member_certify_status = 'approved' AND OLD.member_certify_status <> 'approved' THEN
    SET NEW.member_role = 2;
  END IF;

  -- 인증 상태가 'rejected'로 바뀌면 경력을 NULL로 변경
  IF NEW.member_certify_status = 'rejected' AND OLD.member_certify_status <> 'rejected' THEN
    SET NEW.member_career = NULL;
  END IF;
END$$

DELIMITER ;

-- 쿼리 조회
select member_role,member_name,member_certify_status ,member_career
from member
where member_id = 12;


UPDATE member
SET member_career = '디자인경력 4년차'
WHERE member_id = 12;

UPDATE member
SET member_certify_status = 'approved'
WHERE member_id = 12;


UPDATE member
SET member_career = '디자인경력 5년차'
WHERE member_id = 12;

UPDATE member
SET member_certify_status = 'rejected'
WHERE member_id = 12;
