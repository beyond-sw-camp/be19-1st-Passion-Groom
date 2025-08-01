
-- 1. 상품 수정 프로시저 (진행중인 매칭 체크)

DELIMITER //

CREATE PROCEDURE p_update_mentoring_goods(
    IN p_mentoring_id INT,
    IN p_member_id INT,  -- 수정하려는 멘토의 ID
    IN p_title VARCHAR(255),
    IN p_detail TEXT,
    IN p_price INT,
    IN p_method VARCHAR(100),
    IN p_time VARCHAR(255),
    IN p_period VARCHAR(255),
    IN p_maximum INT,
    IN p_category_id INT,
    IN p_location_id INT,
    OUT p_result VARCHAR(50),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE ongoing_count INT DEFAULT 0;
    DECLARE owner_check INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR';
        SET p_message = '시스템 오류가 발생했습니다.';
    END;

    START TRANSACTION;
    
    -- 1. 소유권 확인 (자신의 상품인지 체크)
    SELECT COUNT(*) INTO owner_check
    FROM mentoringgoods 
    WHERE mentoring_id = p_mentoring_id AND member_id = p_member_id;
    
    IF owner_check = 0 THEN
        SET p_result = 'FAILED';
        SET p_message = '본인의 상품만 수정할 수 있습니다.';
        ROLLBACK;
    ELSE
        -- 2. 진행중인 매칭 체크 (approved 상태)
        SELECT COUNT(*) INTO ongoing_count
        FROM matching 
        WHERE mentoring_id = p_mentoring_id 
        AND matching_status IN ('approved');
        
        IF ongoing_count &gt; 0 THEN
            SET p_result = 'FAILED';
            SET p_message = CONCAT('진행중인 매칭이 ', ongoing_count, '건 있어 수정할 수 없습니다.');
            ROLLBACK;
        ELSE
            -- 3. 상품 정보 업데이트
            UPDATE mentoringgoods SET
                mentoring_title = p_title,
                mentoring_detail = p_detail,
                mentoring_update_dt = CURRENT_TIMESTAMP,
                mentoring_price = p_price,
                mentoring_method = p_method,
                mentoring_time = p_time,
                mentoring_period = p_period,
                mentoring_maximum = p_maximum,
                category_id = p_category_id,
                location_id = p_location_id
            WHERE mentoring_id = p_mentoring_id AND member_id = p_member_id;
            
            SET p_result = 'SUCCESS';
            SET p_message = '상품 정보가 성공적으로 수정되었습니다.';
            COMMIT;
        END IF;
    END IF;
END//

DELIMITER ;

-- 2. 테스트

-- 상품 수정 테스트

CALL p_update_mentoring_goods(
    4,  -- 멘토링 ID
    16, -- 멘토 ID (박개발)
    '풀스택 웹 개발 심화과정',  -- 새 제목
    'React, Node.js, DB까지 고급 과정입니다.',  -- 새 설명
    250000,  -- 새 가격
    '혼합',   -- 새 방식
    '주 2회 2시간',  -- 새 시간
    '6주',    -- 새 기간
    6,        -- 새 최대인원
    1,        -- 카테고리 ID
    1,        -- 지역 ID
    @result,  
    @message
);
SELECT @result as '결과', @message as '메시지';

select * from mentoringgoods;
select * from matching;
