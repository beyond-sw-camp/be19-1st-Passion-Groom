SELECT 
    r.record_id,
    r.record_title,
    r.record_text,
    r.member_role,
    r.record_create,
    COUNT(f.file_id) as 첨부파일수
FROM record r
LEFT JOIN file f ON r.record_id = f.record_id
WHERE r.matching_number = 1 
  AND r.member_role = '멘토'
GROUP BY r.record_id
ORDER BY r.record_create DESC;
— 멘토만 조회