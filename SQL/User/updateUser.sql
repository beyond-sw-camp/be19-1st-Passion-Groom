-- 회원 상세정보 입력
UPDATE member
SET member_job = '프론트엔드 개발자',
    member_age = 29,
    member_gender = 1,
    member_career = '삼성전자 3년',
    introduction = '성실한 멘티입니다.',
    member_porfol = 'https://www.portfolio.test.com/hong'
where member_email = 'eogrg@test.com';

select * from member;
