-- 회원정보 수정

UPDATE member
SET 
    member_phone = '010-3483-2412',
    member_job = '요리',
    introduction = '진로전환을 고민중입니다.'
WHERE member_id = 8;

-- 회원정보 수정 후 조회
select member_id
      ,member_name
      ,member_phone
      ,member_job
      ,introduction
      ,member_update
from member
where member_id = 8;
