-- 이력 조회
SELECT 
    mat.matching_number as 매칭번호,
    mat.matching_status as 상태,
    mat.matching_start as 승인시각,
    mem.member_name as 멘티명,
    mem.member_point as 현재포인트
FROM matching mat
JOIN member mem ON mat.member_id = mem.member_id