-- 관리자가 전체 회원 리스트 확인
select *
from member;

-- 존재하지 않는 회원 조회 시(결과가 없어야 함)
select *
from member
where member_id = 1234;
