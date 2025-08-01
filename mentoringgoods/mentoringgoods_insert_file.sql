use groom;
-- 멘토링 상품 1번에 대한 대표 이미지 등록 (file_order = 0)
INSERT INTO file (
    file_name, file_type, file_rename, file_path, file_dt, file_order, mentoring_id
) VALUES (
    '대표이미지.png',
    'image/png',
    'thumb_001.png',
    '/upload/mentoring/thumb_001.png',
    NOW(),
    0,
    1
);

-- 멘토링 ID 1번의 대표 이미지 조회
SELECT * FROM file
WHERE mentoring_id = 1 AND file_order = 0;
