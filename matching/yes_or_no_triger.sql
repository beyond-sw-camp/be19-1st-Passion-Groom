DELIMITER $$
CREATE PROCEDURE check_matching_eligibility(
    IN p_matching_number INT
)
BEGIN
    SELECT 
        mat.matching_number,
        mat.matching_status,
        mem.member_name as 멘티명,
        mem.member_point as 보유포인트,
        mg.mentoring_price as 필요포인트,
        (mem.member_point - mg.mentoring_price) as 승인후포인트,
        CASE 
            WHEN mat.matching_status != 'pending' THEN '승인불가 - 잘못된 상태'
            WHEN mem.member_point < mg.mentoring_price THEN '승인불가 - 포인트 부족'
            ELSE '승인가능'
        END as 승인가능여부,
        mg.mentoring_title as 멘토링명,
        mentor.member_name as 멘토명
    FROM matching mat
    JOIN member mem ON mat.member_id = mem.member_id
    JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
    JOIN member mentor ON mg.member_id = mentor.member_id
    WHERE mat.matching_number = p_matching_number;
END$$
DELIMITER ;
UPDATE matching SET matching_status = 'canceled' 
WHERE matching_status = 'pending';
INSERT INTO matching (matching_status, matching_reasons, member_id, mentoring_id) VALUES
('', '', , ),
('', '', , );
SELECT 
    mat.matching_number,
    mem.member_name as 멘티명,
    mg.mentoring_title as 멘토링명,
    mg.mentoring_price as 가격,
    mem.member_point as 멘티포인트
FROM matching mat
JOIN member mem ON mat.member_id = mem.member_id
JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
WHERE mat.matching_status = 'pending'
ORDER BY mat.matching_number DESC
LIMIT 5;
SET @test_matching_1 = (SELECT MAX(matching_number) FROM matching WHERE matching_status = 'pending');
SET @test_matching_2 = @test_matching_1 - 1;
SET @test_matching_3 = @test_matching_1 - 2;
SELECT 
    @test_matching_1 as 테스트매칭1,
    @test_matching_2 as 테스트매칭2,
    @test_matching_3 as 테스트매칭3;
CALL check_matching_eligibility(@test_matching_1);
CALL check_matching_eligibility(@test_matching_2);
CALL check_matching_eligibility(@test_matching_3);
-- 신청 가능 여부
SELECT 
    mat.matching_number,
    mat.matching_status,
    mat.matching_create,
    mem.member_name as 멘티명,
    mem.member_point as 보유포인트,
    mg.mentoring_title as 멘토링명,
    mg.mentoring_price as 필요포인트,
    (mem.member_point - mg.mentoring_price) as 승인후예상포인트
FROM matching mat
JOIN member mem ON mat.member_id = mem.member_id
JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
WHERE mat.matching_status = 'pending'
ORDER BY mat.matching_number DESC
LIMIT 10;
SELECT 
    @test_matching_1 as 테스트매칭1,
    @test_matching_2 as 테스트매칭2;
SELECT 
    mem.member_name as 멘티명,
    mem.member_point as 승인전포인트,
    mg.mentoring_price as 차감될포인트,
    mat.matching_status as 현재상태
FROM matching mat
JOIN member mem ON mat.member_id = mem.member_id
JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
WHERE mat.matching_number = @test_matching_3;
-- 수락 프로시저
CALL do_approve_matching(@test_matching_3);