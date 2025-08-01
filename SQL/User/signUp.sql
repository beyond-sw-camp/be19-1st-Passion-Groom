-- 회원가입
INSERT INTO member (
    member_role, member_name, member_email, member_pw,
    member_phone, member_location, category_id, location_id
)
VALUES
    (1, '신초보', 'eogrg@test.com', 'rgokb', '01040593231', '부산광역시', 9, 9),
    (1, '이학생', 'rgehd@test.com', 'sfgbpk', '01049833495', '인천광역시', 10, 10),
    (1, '강내기', 'btbbd@test.com', 'asfbpkrt', '01033395201', '서울특별시', 11, 11);

SELECT * FROM member;
