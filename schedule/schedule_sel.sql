SELECT 
    s.schedule_id,
    s.schedule_content,
    s.schedule_dt,
    CASE 
        WHEN s.schedule_dt > NOW() THEN '예정'
        WHEN DATE(s.schedule_dt) = CURDATE() THEN '오늘'
        ELSE '완료'
    END as 일정상태,
    mentor.member_name as 멘토명,
    mentee.member_name as 멘티명,
    mg.mentoring_title as 멘토링명
FROM schedule s
JOIN matching mat ON s.matching_number = mat.matching_number
JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
JOIN member mentor ON mg.member_id = mentor.member_id
JOIN member mentee ON mat.member_id = mentee.member_id
WHERE s.matching_number = 1
ORDER BY s.schedule_dt ASC;

SELECT 
    s.schedule_id,
    s.schedule_content,
    s.schedule_dt,
    TIME(s.schedule_dt) as 시간,
    mentor.member_name as 멘토명,
    mentee.member_name as 멘티명
FROM schedule s
JOIN matching mat ON s.matching_number = mat.matching_number
JOIN mentoringgoods mg ON mat.mentoring_id = mg.mentoring_id
JOIN member mentor ON mg.member_id = mentor.member_id
JOIN member mentee ON mat.member_id = mentee.member_id
WHERE DATE(s.schedule_dt) = CURDATE()
ORDER BY s.schedule_dt ASC;
