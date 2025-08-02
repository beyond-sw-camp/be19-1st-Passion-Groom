-- 회원 가입시 무조건 일반회원, 회원구분 확인
-- role=0관리자, 1=일반회원, 2=멘토, 3=멘티
INSERT INTO member (
    member_id, member_name, member_email, member_pw, member_phone, member_location,
    member_job, member_community, member_age, member_gender,
    location_id, category_id
) VALUES (
    50, '테스트회원', 'test@test.test', 'testpw', '010-1234-2342', '서울특별시',
    '요리사', '오프라인', 29, 1,
    6, 4
);

select * from member;
