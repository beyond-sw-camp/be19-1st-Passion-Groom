-- 후기에서 반영한 평점을 합한 평균평점 조회
select member_role
      ,member_name
      ,member_job
      ,member_age
      ,member_rating
from member
where member_rating is not null;
