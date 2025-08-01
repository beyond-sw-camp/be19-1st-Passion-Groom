select * from member;

-- 로그인 유효성 검사 (email, password 일치하는지)
Select *
from member
where member_email = 'eogrg@test.com'
     and member_pw = 'rgokb';
