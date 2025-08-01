
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

-- 2. 후기 조회 프로시저

DELIMITER //

-- 특정 멘토링 상품의 모든 후기 조회
CREATE PROCEDURE p_get_reviews_by_mentoring(
    IN p_mentoring_id INT
)
BEGIN
    SELECT 
        r.review_id,
        r.review_title as '후기제목',
        r.review_detail as '후기내용',
        r.review_create as '작성일',
        r.review_update as '수정일',
        mg.mentoring_title as '멘토링제목',
        mentee.member_name as '작성자',
        mentor.member_name as '멘토',
        m.rating_mentor as '멘토평점',
        m.rating_mentee as '멘티평점'
    FROM review r
    JOIN mentoringgoods mg ON r.mentoring_id = mg.mentoring_id
    JOIN matching m ON r.matching_number = m.matching_number
    JOIN member mentee ON m.member_id = mentee.member_id
    JOIN member mentor ON mg.member_id = mentor.member_id
    WHERE r.mentoring_id = p_mentoring_id
    ORDER BY r.review_create DESC;
END//

-- 특정 회원이 작성한 모든 후기 조회
CREATE PROCEDURE p_get_reviews_by_member(
    IN p_member_id INT
)
BEGIN
    SELECT 
        r.review_id,
        r.review_title as '후기제목',
        r.review_detail as '후기내용',
        r.review_create as '작성일',
        mg.mentoring_title as '멘토링제목',
        mentor.member_name as '멘토',
        DATEDIFF(NOW(), r.review_create) as '작성후경과일',
        CASE 
            WHEN DATEDIFF(NOW(), r.review_create) <= 7 THEN '삭제가능'
            ELSE '삭제불가'
        END as '삭제가능여부'
    FROM review r
    JOIN matching m ON r.matching_number = m.matching_number
    JOIN mentoringgoods mg ON r.mentoring_id = mg.mentoring_id
    JOIN member mentor ON mg.member_id = mentor.member_id
    WHERE m.member_id = p_member_id
    ORDER BY r.review_create DESC;
END//

DELIMITER ;

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

-- 4.테스트 

-- 1. 후기 등록 테스트
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

-- 2-1. 특정 멘토링의 후기 조회
CALL p_get_reviews_by_mentoring(5);

-- 2-2. 특정 회원의 후기 조회
CALL p_get_reviews_by_member(29);

-- 3. 후기 삭제 테스트
select * from review;
CALL p_delete_review(
    7,   -- 후기 ID
    29,  -- 삭제 요청자 ID
    @result,
    @message
);
SELECT @result as '결과', @message as '메시지';

-- 3-1. 특정 회원의 후기 삭제조회
CALL p_get_reviews_by_member(29);