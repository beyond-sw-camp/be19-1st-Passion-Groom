DELIMITER $$

CREATE TRIGGER auto_log_file_upload
    AFTER INSERT ON file
    FOR EACH ROW
BEGIN
    IF NEW.record_id IS NOT NULL THEN
        INSERT INTO record (
            record_title,
            record_text,
            member_role,
            matching_number
        ) 
        SELECT 
            CONCAT('파일 업로드: ', NEW.file_name),
            CONCAT('파일이 업로드되었습니다. 파일명: ', NEW.file_name, ', 크기: ', NEW.file_type),
            '멘토',
            (SELECT matching_number FROM record WHERE record_id = NEW.record_id);
    END IF;
END$$

DELIMITER ;

INSERT INTO file (
    file_name,
    file_type,
    file_rename,
    file_path,
    file_order,
    record_id
) VALUES (
    'React_기초_자료.pdf',
    'application/pdf',
    'react_basics_20240801_001.pdf',
    '/uploads/mentoring/react_basics_20240801_001.pdf',
    1,
    1  -- 기록 ID
);

select * from file;