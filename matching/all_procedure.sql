-- 통합 매칭 관리 프로시저
DELIMITER $$
CREATE PROCEDURE manage_matching(
    IN p_action VARCHAR(20),           -- 'CREATE', 'CHECK', 'APPROVE', 'REJECT', 'LIST', 'FINISH'
    IN p_matching_number INT,		   -- 신청 여부 수락 거절 목록 매칭완료 멘티가 취소
    IN p_member_id INT,
    IN p_mentoring_id INT,
    IN p_reject_reason VARCHAR(255)
)
BEGIN
    -- 변수 선언
    DECLARE v_member_id INT;
    DECLARE v_mentoring_id INT;
    DECLARE v_mentor_id INT;
    DECLARE v_member_role TINYINT;
    DECLARE v_current_points INT;
    DECLARE v_mentor_points INT;
    DECLARE v_required_points INT;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_max_capacity INT;
    DECLARE v_current_count INT;
    DECLARE v_new_matching_id INT;
    DECLARE v_mentor_earning INT;
    DECLARE v_platform_fee INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    -- 1. CREATE: 매칭 신청 (일반 사용자가 신청)
    IF p_action = 'CREATE' THEN
        START TRANSACTION;
        
        -- 회원 정보 확인 (일반회원만 신청 가능)
        SELECT member_role, member_point 
        INTO v_member_role, v_current_points
        FROM member 
        WHERE member_id = p_member_id;
        
        IF v_member_role != 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '신청불가: 일반회원만 매칭 신청이 가능합니다';
        END IF;
        
        -- 멘토링 정보 및 멘토 정보 확인
        SELECT mg.mentoring_maximum, mg.mentoring_price, mg.member_id
        INTO v_max_capacity, v_required_points, v_mentor_id
        FROM mentoringgoods mg
        WHERE mg.mentoring_id = p_mentoring_id;
        
        -- 자신의 멘토링에는 신청 불가
        IF p_member_id = v_mentor_id THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '신청불가: 자신의 멘토링에는 신청할 수 없습니다';
        END IF;
        
        -- 현재 신청자 수 확인
        SELECT COUNT(*) INTO v_current_count
        FROM matching 
        WHERE mentoring_id = p_mentoring_id 
        AND matching_status IN ('pending', 'approved', 'finished');
        
        -- 신청 가능 여부 체크
        IF v_current_count >= v_max_capacity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '신청불가: 정원이 초과되었습니다';
        END IF;
        
        IF v_current_points < v_required_points THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '신청불가: 포인트가 부족합니다';
        END IF;
        
        -- 중복 신청 체크
        IF EXISTS(
            SELECT 1 FROM matching  
            WHERE member_id = p_member_id 
            AND mentoring_id = p_mentoring_id 
            AND matching_status IN ('pending', 'approved')
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '신청불가: 이미 신청한 멘토링입니다';
        END IF;
        
        -- 매칭 신청 등록
        INSERT INTO matching (matching_status, member_id, mentoring_id)
        VALUES ('pending', p_member_id, p_mentoring_id);
        
        SET v_new_matching_id = LAST_INSERT_ID();
        
        COMMIT;
        
        SELECT 
            v_new_matching_id as 신청번호,
            '신청완료' as 처리결과,
            v_required_points as 필요포인트,
            v_current_points as 보유포인트,
            '멘토 승인 대기중' as 상태;
    
    -- 2. CHECK: 매칭 가능 여부 확인
    ELSEIF p_action = 'CHECK' THEN
        SELECT 
            mat.matching_number,
            mat.matching_status,
            mem.member_name as 신청자명,
            CASE 
                WHEN mem.member_role = 1 THEN '일반회원'
                WHEN mem.member_role = 3 THEN '멘티'
                ELSE '기타'
            END as 현재역할,
            mem.member_point as 보유포인트,
            mg.mentoring_price as 필요포인트,
            (mem.member_point - mg.mentoring_price) as 승인후포인트,
            CASE 
                WHEN mat.matching_status != 'pending' THEN '승인불가 - 잘못된 상태'
                WHEN mem.member_point < mg.mentoring_price THEN '승인불가 - 포인트 부족'
                WHEN mg.mentoring_maximum <= (
                    SELECT COUNT(*) FROM matching m2 
                    WHERE m2.mentoring_id = mg.mentoring_id 
                    AND m2.matching_status IN ('approved', 'finished')
                ) THEN '승인불가 - 정원초과'
                ELSE '승인가능'
            END as 승인가능여부, 
            mg.mentoring_title as 멘토링명,
            mg.mentoring_maximum as 최대정원,
            (SELECT COUNT(*) FROM matching m2 
             WHERE m2.mentoring_id = mg.mentoring_id 
             AND m2.matching_status IN ('approved', 'finished')) as 현재신청자수,
            mentor.member_name as 멘토명
        FROM matching mat
        JOIN member mem ON mat.member_id = mem.member_id
        JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
        JOIN member mentor ON mg.member_id = mentor.member_id
        WHERE mat.matching_number = p_matching_number;
    
    -- 3. APPROVE: 매칭 승인 (멘토가 승인)
    ELSEIF p_action = 'APPROVE' THEN
        START TRANSACTION;
        
        -- 매칭 정보 조회
        SELECT 
            mat.member_id, 
            mat.mentoring_id, 
            mat.matching_status,
            mem.member_point,
            mem.member_role,
            mg.mentoring_price,
            mg.mentoring_maximum,
            mg.member_id
        INTO 
            v_member_id, 
            v_mentoring_id, 
            v_current_status,
            v_current_points,
            v_member_role,
            v_required_points,
            v_max_capacity,
            v_mentor_id
        FROM matching mat
        JOIN member mem ON mat.member_id = mem.member_id
        JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
        WHERE mat.matching_number = p_matching_number;
        
        -- 현재 신청자 수 확인
        SELECT COUNT(*) INTO v_current_count
        FROM matching 
        WHERE mentoring_id = v_mentoring_id 
        AND matching_status IN ('approved', 'finished');
        
        -- 승인 가능 여부 체크
        IF v_current_status != 'pending' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '승인불가: 이미 처리된 매칭입니다';
        ELSEIF v_current_points < v_required_points THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '승인불가: 포인트가 부족합니다';
        ELSEIF v_current_count >= v_max_capacity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '승인불가: 정원이 초과되었습니다';
        END IF;
        
        -- 포인트 계산 (플랫폼 수수료 10%)
        SET v_mentor_earning = FLOOR(v_required_points * 0.9);
        SET v_platform_fee = v_required_points - v_mentor_earning;
        
        -- 멘토 현재 포인트 조회
        SELECT member_point INTO v_mentor_points
        FROM member 
        WHERE member_id = v_mentor_id; 
        
        -- 1. 매칭 상태 업데이트 (트리거가 역할 변경 처리)
        UPDATE matching 
        SET matching_status = 'approved',
            matching_start = CURRENT_TIMESTAMP
        WHERE matching_number = p_matching_number;
        
        -- 2. 멘티 포인트 차감
        UPDATE member 
        SET member_point = member_point - v_required_points
        WHERE member_id = v_member_id;
        
        -- 3. 멘토에게 포인트 지급 (수수료 제외)
        UPDATE member 
        SET member_point = member_point + v_mentor_earning
        WHERE member_id = v_mentor_id;
        
        -- 4. 멘티 결제 내역 추가 (포인트 사용)
        INSERT INTO cash (cash_amount, cash_method, member_id)
        VALUES (-v_required_points, '포인트결제', v_member_id);
        
        -- 5. 멘토 수익 내역 추가
        INSERT INTO cash (cash_amount, cash_method, member_id)
        VALUES (v_mentor_earning, '멘토링수익', v_mentor_id);
        
        -- 6. 플랫폼 수수료 내역 추가 (관리자 계정에)
        INSERT INTO cash (cash_amount, cash_method, member_id)
        VALUES (v_platform_fee, '플랫폼수수료', 11); -- 관리자 ID
        
        COMMIT;
        
        -- 결과 반환
        SELECT 
            p_matching_number as 매칭번호,
            '승인완료' as 처리결과,
            '트리거가 역할변경 처리' as 역할변경,
            v_required_points as 차감포인트,
            (v_current_points - v_required_points) as 멘티잔여포인트,
            v_mentor_earning as 멘토수익,
            (v_mentor_points + v_mentor_earning) as 멘토총포인트,
            v_platform_fee as 플랫폼수수료;
    
    -- 4. REJECT: 매칭 거절
    ELSEIF p_action = 'REJECT' THEN
        START TRANSACTION;
        
        -- 현재 상태 확인
        SELECT matching_status INTO v_current_status
        FROM matching 
        WHERE matching_number = p_matching_number;
        
        IF v_current_status != 'pending' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '거절불가: 이미 처리된 매칭입니다';
        END IF;
        
        -- 매칭 상태 업데이트
        UPDATE matching 
        SET matching_status = 'rejected',
            matching_reasons = IFNULL(NULLIF(p_reject_reason, ''), '멘토에 의한 거절')
        WHERE matching_number = p_matching_number;
        
        COMMIT;
        
        SELECT 
            p_matching_number as 매칭번호,
            '거절완료' as 처리결과,
            IFNULL(NULLIF(p_reject_reason, ''), '멘토에 의한 거절') as 거절사유;
    
    -- 5. LIST: 매칭 목록 조회
    ELSEIF p_action = 'LIST' THEN
        SELECT  
            mat.matching_number,
            mat.matching_status,
            mem.member_name as 신청자명,
            CASE 
                WHEN mem.member_role = 1 THEN '일반회원'
                WHEN mem.member_role = 3 THEN '멘티'
                ELSE '기타'
            END as 현재역할,
            mg.mentoring_title as 멘토링명,
            mg.mentoring_price as 가격,
            mem.member_point as 신청자포인트,
            (mem.member_point - mg.mentoring_price) as 승인후포인트,
            CASE 
                WHEN mem.member_point >= mg.mentoring_price THEN '승인가능'
                ELSE '포인트부족'
            END as 승인가능여부,
            mat.matching_create as 신청일시,
            mentor.member_name as 멘토명,
            mat.matching_reasons as 처리사유
        FROM matching mat
        JOIN member mem ON mat.member_id = mem.member_id
        JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
        JOIN member mentor ON mg.member_id = mentor.member_id
        WHERE mat.matching_status = IFNULL(NULLIF(p_reject_reason, ''), 'pending')
        ORDER BY mat.matching_create ASC;
    
    -- 6. FINISH: 매칭 완료
    ELSEIF p_action = 'FINISH' THEN
        START TRANSACTION;
        
        -- 현재 상태 확인
        SELECT matching_status INTO v_current_status
        FROM matching 
        WHERE matching_number = p_matching_number;
        
        IF v_current_status != 'approved' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '완료불가: 승인된 매칭만 완료 처리할 수 있습니다';
        END IF;
        
        -- 매칭 상태 업데이트
        UPDATE matching 
        SET matching_status = 'finished',
            matching_finish = CURRENT_TIMESTAMP
        WHERE matching_number = p_matching_number;
        
        COMMIT;
        
        SELECT 
            p_matching_number as 매칭번호,
            '완료처리됨' as 처리결과,
            CURRENT_TIMESTAMP as 완료시간;
    
    -- 7. CANCEL: 매칭 취소 (멘티가 취소)
    ELSEIF p_action = 'CANCEL' THEN
        START TRANSACTION;
        
        -- 매칭 정보와 현재 상태 확인
        SELECT 
            mat.matching_status,
            mat.member_id,
            mg.mentoring_price,
            mg.member_id
        INTO 
            v_current_status,
            v_member_id,
            v_required_points,
            v_mentor_id
        FROM matching mat
        JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
        WHERE mat.matching_number = p_matching_number;
        
        IF v_current_status NOT IN ('approved') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '취소불가: 승인된 매칭만 취소할 수 있습니다';
        END IF;
        
        -- 포인트 계산 (환불 시 수수료 10% 차감)
        SET v_mentor_earning = FLOOR(v_required_points * 0.9);
        SET v_platform_fee = v_required_points - v_mentor_earning;
        
        -- 1. 매칭 상태 업데이트
        UPDATE matching 
        SET matching_status = 'canceled',
            matching_reasons = IFNULL(NULLIF(p_reject_reason, ''), '멘티에 의한 취소')
        WHERE matching_number = p_matching_number;
        
        -- 2. 멘티에게 포인트 환불 (취소 수수료 5% 차감)
        UPDATE member 
        SET member_point = member_point + FLOOR(v_required_points * 0.95)
        WHERE member_id = v_member_id;
        
        -- 3. 멘토에게서 포인트 차감
        UPDATE member 
        SET member_point = member_point - v_mentor_earning
        WHERE member_id = v_mentor_id;
        
        -- 4. 취소 수수료 내역 추가
        INSERT INTO cash (cash_amount, cash_method, member_id)
        VALUES (FLOOR(v_required_points * 0.95), '매칭취소환불', v_member_id);
        
        INSERT INTO cash (cash_amount, cash_method, member_id)
        VALUES (-v_mentor_earning, '매칭취소차감', v_mentor_id);
        
        COMMIT;
        
        SELECT 
            p_matching_number as 매칭번호,
            '취소완료' as 처리결과,
            FLOOR(v_required_points * 0.95) as 환불포인트,
            FLOOR(v_required_points * 0.05) as 취소수수료;
    
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '잘못된 액션입니다. CREATE, CHECK, APPROVE, REJECT, LIST, FINISH, CANCEL 중 하나를 사용하세요';
    END IF;
    
END$$
DELIMITER ;

-- 사용 예시

-- 1. 일반회원이 매칭 신청 (일반회원ID=32, 멘토링ID=1)
CALL manage_matching('CREATE', 0, 32, 1, '');

-- 2. 매칭 가능 여부 확인 (매칭번호=1)
CALL manage_matching('CHECK', 1, 0, 0, '');

-- 3. 멘토가 매칭 승인 (매칭번호=1) - 일반회원→멘티 전환 + 포인트 처리
CALL manage_matching('APPROVE', 1, 0, 0, '');

-- 4. 멘토가 매칭 거절 (매칭번호=2)
CALL manage_matching('REJECT', 2, 0, 0, '시간대가 맞지 않음');

-- 5. 대기중인 매칭 목록 조회
CALL manage_matching('LIST', 0, 0, 0, 'pending');

-- 6. 승인된 매칭 목록 조회
CALL manage_matching('LIST', 0, 0, 0, 'approved');

-- 7. 매칭 완료 처리 (매칭번호=1)
CALL manage_matching('FINISH', 1, 0, 0, '');

-- 8. 매칭 취소 (멘티가 취소, 매칭번호=1)
CALL manage_matching('CANCEL', 1, 0, 0, '개인 사정');

-- 조회용 쿼리

-- 특정 멘티의 매칭 이력 조회
SELECT 
    mat.matching_number,
    mat.matching_status,
    mg.mentoring_title,
    mg.mentoring_price,
    mat.matching_create,
    mat.matching_start,
    mat.matching_finish,
    mat.matching_reasons
FROM matching mat
JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
WHERE mat.member_id = ? -- 멘티 ID
ORDER BY mat.matching_create DESC;

-- 특정 멘토의 매칭 이력 조회
SELECT 
    mat.matching_number,
    mat.matching_status,
    mem.member_name as 멘티명,
    mg.mentoring_title,
    mg.mentoring_price,
    mat.matching_create,
    mat.matching_start,
    mat.matching_finish
FROM matching mat
JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
JOIN member mem ON mat.member_id = mem.member_id
WHERE mg.member_id = ? -- 멘토 ID
ORDER BY mat.matching_create DESC;

-- 포인트 거래 내역 조회
SELECT 
    c.cash_num,
    c.cash_amount,
    c.cash_method,
    c.cash_stamp_dt,
    m.member_name
FROM cash c
JOIN member m ON c.member_id = m.member_id
WHERE c.member_id = ? -- 회원 ID
ORDER BY c.cash_stamp_dt DESC;