-- 중복 전화번호 가입 제한
INSERT INTO member (
    member_role, member_name, member_email, member_pw, member_phone, member_location, member_job,
    member_community, member_age, member_gender, member_career, member_porfol,
    introduction, member_point,location_id, category_id
) VALUES (
    1, '전화번호중복테스트', 'phone_dup@test.com', 'testpassword',
    '010-1000-0014', -- 중복 전화번호
    '서울특별시', '테스터', '온라인', 28, 1, '테스트 경력', NULL,
    '중복 전화번호 테스트', 0, 14, 13
);
