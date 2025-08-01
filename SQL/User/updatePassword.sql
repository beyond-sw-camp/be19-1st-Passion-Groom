-- 이메일로 비밀번호 변경
UPDATE member
SET member_pw = 'test1234'
WHERE member_email = 'eogrg@test.com';


-- 변경된 비밀번호 확인
SELECT member_name
      ,member_email
      ,member_pw
from member
where member_email = 'eogrg@test.com';
