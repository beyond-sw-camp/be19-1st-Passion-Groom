-- 관리자가 회원구분 값 수정 가능 여부 및 수정 후에 반영된지 확인

-- 조회
select member_role,member_name,member_certify_status ,member_career
from member
where member_id = 12;


-- 회원구분 값 직접 수정(1=일반회원->2=멘토)
UPDATE member
SET member_role = 2
WHERE member_id = 12;

