DELIMITER //

CREATE PROCEDURE p_mentoringlike(
    IN p_member_id INT,
    IN p_mentoring_id INT,
    OUT p_result VARCHAR(20),
    OUT p_current_like_count INT
)
BEGIN
    DECLARE like_exists INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR';
        SET p_current_like_count = -1;
    END;
    
    START TRANSACTION;
    
    -- 좋아요 존재 여부 확인
    SELECT COUNT(*) INTO like_exists
    FROM likementoring
    WHERE member_id = p_member_id AND mentoring_id = p_mentoring_id;
    
    IF like_exists > 0 THEN
        -- 좋아요 취소
        DELETE FROM likementoring
        WHERE member_id = p_member_id AND mentoring_id = p_mentoring_id;
        
        UPDATE mentoringgoods
        SET mentoring_like = mentoring_like - 1
        WHERE mentoring_id = p_mentoring_id;
        
        SET p_result = 'UNLIKED';
    ELSE
        -- 좋아요 추가
        INSERT INTO likementoring (member_id, mentoring_id)
        VALUES (p_member_id, p_mentoring_id);
        
        UPDATE mentoringgoods
        SET mentoring_like = mentoring_like + 1
        WHERE mentoring_id = p_mentoring_id;
        
        SET p_result = 'LIKED';
    END IF;
    
    -- 현재 좋아요 수 조회
    SELECT mentoring_like INTO p_current_like_count
    FROM mentoringgoods
    WHERE mentoring_id = p_mentoring_id;
    
    COMMIT;
END//

DELIMITER ;

-- 프로시저 사용 예제
CALL p_mentoringlike(22, 1, @result, @like_count);
SELECT @result as '실행결과', @like_count as '현재좋아요수';

-- 테스트 결과 확인 
SELECT member_id, member_name FROM member WHERE member_id = 22;
SELECT mentoring_id, mentoring_title, mentoring_like FROM mentoringgoods WHERE mentoring_id = 1;

