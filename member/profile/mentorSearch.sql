-- 회원정보 전체 조회
select * from member;


-- 멘토 회원들만 전체 조회 role=2 == 멘토
select * 
    from member
    where member_role = 2;
