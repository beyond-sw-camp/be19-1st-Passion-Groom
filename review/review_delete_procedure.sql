-- 3. 후기 삭제 프로시저 (7일 제한)

DELIMITER //

CREATE PROCEDURE p_delete_review(
    IN p_review_id INT,
    IN p_member_id INT,  -- 삭제 요청자
    OUT p_result VARCHAR(50),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE review_writer INT DEFAULT 0;
    DECLARE days_passed INT DEFAULT 0;
    DECLARE review_exists INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR';
        SET p_message = '시스템 오류가 발생했습니다.';
    END;

    START TRANSACTION;
    
    -- 1. 후기 존재 및 작성자 확인
    SELECT COUNT(*), 
           COALESCE(MAX(m.member_id), 0),
           COALESCE(MAX(DATEDIFF(NOW(), r.review_create)), 999)
    INTO review_exists, review_writer, days_passed
    FROM review r
    JOIN matching m ON r.matching_number = m.matching_number
    WHERE r.review_id = p_review_id;
    
    IF review_exists = 0 THEN
        SET p_result = 'FAILED';
        SET p_message = '해당 후기를 찾을 수 없습니다.';
        ROLLBACK;
    ELSEIF review_writer != p_member_id THEN
        SET p_result = 'FAILED';
        SET p_message = '본인이 작성한 후기만 삭제할 수 있습니다.';
        ROLLBACK;
    ELSEIF days_passed > 7 THEN
        SET p_result = 'FAILED';
        SET p_message = CONCAT('후기 작성 후 7일이 경과하여 삭제할 수 없습니다. (', days_passed, '일 경과)');
        ROLLBACK;
    ELSE
        -- 후기 삭제
        DELETE FROM review WHERE review_id = p_review_id;
        
        SET p_result = 'SUCCESS';
        SET p_message = '후기가 성공적으로 삭제되었습니다.';
        COMMIT;
    END IF;
END//

DELIMITER ;

-- 2. 후기 삭제 테스트
select * from review;
CALL p_delete_review(
    7,   -- 후기 ID
    29,  -- 삭제 요청자 ID
    @result,
    @message
);
SELECT @result as '결과', @message as '메시지';

-- 3. 특정 회원의 후기 삭제조회
CALL p_get_reviews_by_member(29);