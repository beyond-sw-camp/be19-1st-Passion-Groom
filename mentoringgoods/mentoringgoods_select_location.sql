use groom;


-- 회원의 등록한 위치 내의 멘토링 상품 조회
SELECT 
	l.location_name,
    mg.mentoring_id,
    mg.mentoring_title,
    mg.mentoring_detail,
    mg.mentoring_price,
    mg.mentoring_method,
    mg.mentoring_time,
    mg.mentoring_period,
    mg.mentoring_maximum,
    mg.mentoring_like,
    m.member_name as mentor_name,
    m.member_rating as mentor_rating,
    c.category_name
FROM mentoringgoods mg
JOIN member m ON mg.member_id = m.member_id
JOIN category c ON mg.category_id = c.category_id
JOIN location l ON mg.location_id = l.location_id
WHERE l.location_id = (
    SELECT location_id 
    FROM member 
    WHERE member_id = 11 -- 현재 로그인한 회원의 ID
)
ORDER BY mg.mentoring_like DESC, mg.mentoring_dt DESC;
