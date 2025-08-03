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

-- 2-1. 특정 멘토링의 후기 조회
CALL p_get_reviews_by_mentoring(5);

-- 2-2. 특정 회원의 후기 조회
CALL p_get_reviews_by_member(29);
