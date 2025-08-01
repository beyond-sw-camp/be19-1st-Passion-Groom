UPDATE record 
SET 
    record_text = CONCAT(record_text, '\n\n[수정사항] 추가 과제: React Hook 학습 자료 검토'),
    record_update = CURRENT_TIMESTAMP
WHERE record_id = 1;

select * from record r ;