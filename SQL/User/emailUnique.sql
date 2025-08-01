-- 중복 이메일 가입 불가
INSERT INTO member (
    member_role, member_name, member_email, member_pw, member_phone, member_location, member_job,
    member_community, member_age, member_gender, member_career, member_porfol,
    introduction, member_point, location_id, category_id
) VALUES (
    1, '중복테스트','user4@test.com', -- 이미 존재하는 이메일
    'testpassword', '010-1234-9999', '서울특별시','테스터', '온라인', 30, 1, '테스트 직무',
    NULL, '중복 이메일 테스트', 0, 14, 13
);
