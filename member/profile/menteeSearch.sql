-- 회원정보 전체 조회
select * from member;


-- 멘티 회원들만 전체 조회 role=3 == 멘티
select * 
    from member
    where member_role = 3;
