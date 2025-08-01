use groom;

INSERT INTO mentoringgoods
(mentoring_title, mentoring_detail, mentoring_price, mentoring_method,
 mentoring_time, mentoring_period, mentoring_maximum, member_id, category_id, location_id)
VALUES
('React & TypeScript 실무 개발 과정', 
 '실무에서 바로 활용할 수 있는 React와 TypeScript를 함께 배우는 과정입니다. 
  컴포넌트 설계, 상태 관리, API 연동, 배포까지 전 과정을 다룹니다.
  포트폴리오용 프로젝트도 함께 만들어보세요.',
 350000, '온라인', 
 '주 2회 1.5시간', '6주', 8, 12, 1, 1);
-- 상태/종료일까지 확인 (트리거/이벤트 구성 시)
-- 테이블에 실제로 존재하는 컬럼들만 조회
SELECT *
FROM mentoringgoods
ORDER BY mentoring_id DESC
LIMIT 5;