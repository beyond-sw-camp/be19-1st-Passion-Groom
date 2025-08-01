-- 1. 상품 삭제 프로시저 (매칭 데이터 보존)

DELIMITER //

CREATE PROCEDURE p_delete_mentoring_goods(
    IN p_mentoring_id INT,
    IN p_member_id INT,  -- 삭제하려는 멘토의 ID
    OUT p_result VARCHAR(50),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE ongoing_count INT DEFAULT 0;
    DECLARE owner_check INT DEFAULT 0;
    DECLARE total_matching INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR';
        SET p_message = '시스템 오류가 발생했습니다.';
    END;

    START TRANSACTION;

    -- 1. 소유권 확인
    SELECT COUNT(*) INTO owner_check
    FROM mentoringgoods 
    WHERE mentoring_id = p_mentoring_id AND member_id = p_member_id;

    IF owner_check = 0 THEN
        SET p_result = 'FAILED';
        SET p_message = '본인의 상품만 삭제할 수 있습니다.';
        ROLLBACK;
    ELSE
        -- 2. 진행중인 매칭 체크
        SELECT COUNT(*) INTO ongoing_count
        FROM matching 
        WHERE mentoring_id = p_mentoring_id 
        AND matching_status IN ('approved');

        IF ongoing_count &gt; 0 THEN
            SET p_result = 'FAILED';
            SET p_message = CONCAT('진행중인 매칭이 ', ongoing_count, '건 있어 삭제할 수 없습니다.');
            ROLLBACK;
        ELSE
            -- 3. 전체 매칭 수 확인
            SELECT COUNT(*) INTO total_matching
            FROM matching 
            WHERE mentoring_id = p_mentoring_id;

            -- 4. 연관 데이터 삭제 (매칭 데이터는 보존)
            -- 4-1. 좋아요 데이터 삭제
            DELETE FROM likementoring WHERE mentoring_id = p_mentoring_id;

            -- 4-2. 파일 데이터 삭제
            DELETE FROM file WHERE mentoring_id = p_mentoring_id;

            -- 4-3. 리뷰 데이터 삭제 (선택적 - 보존할지 삭제할지 정책에 따라)
            DELETE FROM review WHERE mentoring_id = p_mentoring_id;

            -- 4-4. 멘토링 상품 삭제
            DELETE FROM mentoringgoods WHERE mentoring_id = p_mentoring_id;

            SET p_result = 'SUCCESS';
            IF total_matching &gt; 0 THEN
                SET p_message = CONCAT('상품이 삭제되었습니다. (', total_matching, '건의 매칭 이력은 보존됨)');
            ELSE
                SET p_message = '상품이 성공적으로 삭제되었습니다.';
            END IF;

            COMMIT;
        END IF;
    END IF;
END//

DELIMITER ;


-- 2. 상품 삭제 테스트

CALL p_delete_mentoring_goods(
    4,   -- 멘토링 ID
    16,  -- 멘토 ID
    @result, 
    @message
);
SELECT @result as '결과', @message as '메시지';