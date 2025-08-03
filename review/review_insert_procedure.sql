
-- 1. 후기 등록 프로시저

DELIMITER //

CREATE PROCEDURE p_insert_review(
    IN p_review_title VARCHAR(255),
    IN p_review_detail VARCHAR(255),
    IN p_mentoring_id INT,
    IN p_matching_number INT,
    IN p_member_id INT,  -- 후기 작성자 (멘티)
    OUT p_result VARCHAR(50),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE finished_check INT DEFAULT 0;
    DECLARE duplicate_check INT DEFAULT 0;
    DECLARE member_role_check INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 @error_message = MESSAGE_TEXT;
        SET p_result = 'ERROR';
        SET p_message = @error_message;
    END;

    START TRANSACTION;
    
    -- 1. 멘티 권한 체크
    SELECT member_role INTO member_role_check
    FROM member 
    WHERE member_id = p_member_id;
    
    IF member_role_check = 2 THEN
        SET p_result = 'FAILED';
        SET p_message = '멘토는 후기를 작성할 수 없습니다.';
        ROLLBACK;
    ELSE
        -- 2. 해당 매칭이 완료되었고 본인 것인지 체크
        SELECT COUNT(*) INTO finished_check
        FROM matching 
        WHERE matching_number = p_matching_number
        AND mentoring_id = p_mentoring_id
        AND member_id = p_member_id
        AND matching_status = 'finished';
        
        IF finished_check = 0 THEN
            SET p_result = 'FAILED';
            SET p_message = '멘토링이 완료된 본인의 멘토링상에만 후기를 작성할 수 있습니다.';
            ROLLBACK;
        ELSE
            -- 3. 중복 후기 체크
            SELECT COUNT(*) INTO duplicate_check
            FROM review 
            WHERE mentoring_id = p_mentoring_id 
            AND matching_number = p_matching_number;
            
            IF duplicate_check > 0 THEN
                SET p_result = 'FAILED';
                SET p_message = '이미 해당 멘토링에 후기를 작성하셨습니다.';
                ROLLBACK;
            ELSE
                -- 4. 후기 등록
                INSERT INTO review (
                    review_title, 
                    review_detail, 
                    mentoring_id, 
                    matching_number
                ) VALUES (
                    p_review_title, 
                    p_review_detail, 
                    p_mentoring_id, 
                    p_matching_number
                );
                
                SET p_result = 'SUCCESS';
                SET p_message = '후기가 성공적으로 등록되었습니다.';
                COMMIT;
            END IF;
        END IF;
    END IF;
END//

DELIMITER ;

-- 2. 후기 등록 테스트
select * from matching;

CALL p_insert_review(
    '정말 유익한 멘토링이었습니다!',
    '멘토님의 친절한 설명 덕분에 많은 것을 배웠습니다. 추천합니다!',
    5,  -- 멘토링 ID
    4,  -- 매칭 번호
    29, -- 멘티 ID
    @result,
    @message
);
SELECT @result as '결과', @message as '메시지';


-- 3. 테스트 결과
SELECT *
FROM mentoringgoods;