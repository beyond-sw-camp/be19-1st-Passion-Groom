-- 이름, 전화번호로 아이디(이메일)를 조회한다.
select member_name, member_phone, member_email 
  from member
where member_name = '신초보' and member_phone = '01040593231';
