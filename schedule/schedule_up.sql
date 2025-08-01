UPDATE schedule 
SET 
    schedule_content = 'React Hook 심화 학습 (일정 변경)',
    schedule_dt = '2024-08-08 15:00:00'  -- 시간 변경
WHERE schedule_id = 1;

select * from schedule;