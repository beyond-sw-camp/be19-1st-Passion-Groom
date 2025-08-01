-- 중복 신청 방지 트리거 생성
DELIMITER $$

CREATE TRIGGER prevent_duplicate_application
    BEFORE INSERT ON matching
    FOR EACH ROW
BEGIN
    DECLARE duplicate_count INT DEFAULT 0;
    DECLARE error_message VARCHAR(255);
    
    -- 같은 멘티(member_id)가 같은 멘토링 상품(mentoring_id)에 
    -- 활성 상태(pending, approved)로 신청한 건수 확인
    SELECT COUNT(*) INTO duplicate_count
    FROM matching 
    WHERE member_id = NEW.member_id 
      AND mentoring_id = NEW.mentoring_id 
      AND matching_status IN ('pending', 'approved');
    
    -- 중복 신청이 발견되면 에러 발생
    IF duplicate_count > 0 THEN
        SET error_message = CONCAT(
            '중복 신청 불가: 멘티 ID ', NEW.member_id, 
            '가 멘토링 ID ', NEW.mentoring_id, 
            '에 이미 신청했습니다.'
        );
        
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = error_message;
    END IF;
    
END$$

DELIMITER ;

-- 트리거 테스트용 시나리오
-- 1
INSERT INTO matching (matching_status, member_id, mentoring_id, matching_reasons) 
VALUES ('pending', 12, 1, '프로그래밍 실력 향상을 위해 신청합니다.');


-- 2
INSERT INTO matching (matching_status, member_id, mentoring_id, matching_reasons) 
VALUES ('pending', 12, 1, '다시 한번 신청해봅니다.');


-- 3
INSERT INTO matching (matching_status, member_id, mentoring_id, matching_reasons) 
VALUES ('pending', 12, 2, 'Node.js도 배우고 싶습니다.');

-- 4
INSERT INTO matching (matching_status, member_id, mentoring_id, matching_reasons) 
VALUES ('pending', 13, 1, '저도 React를 배우고 싶습니다.');

-- 5
UPDATE matching 
SET matching_status = 'rejected', matching_reasons = '멘토 일정상 거절'
WHERE member_id = 12 AND mentoring_id = 1;

-- 거절된 후 다시 신청 시도
INSERT INTO matching (matching_status, member_id, mentoring_id, matching_reasons) 
VALUES ('pending', 12, 1, '거절된 후 다시 신청합니다.');