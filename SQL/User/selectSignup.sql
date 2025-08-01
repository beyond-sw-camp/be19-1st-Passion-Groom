-- 회원 가입일자, 수정일자 조회
UPDATE member
set member_job = '풀스택 개발자'
   ,member_age = 31
   ,member_gender = 2
   ,member_career = '삼성전자 2년'
   ,introduction = '열심히 배우는 멘티입니다.'
   ,member_porfol = 'https://protfolio.test.com/btbbd'
WHERE member_email = 'btbbd@test.com';

select * from member;

select member_name, member_email, member_job, member_age
      ,member_gender, member_career, introduction, member_porfol
      ,member_create, member_update
from member
where member_email = 'btbbd@test.com';
