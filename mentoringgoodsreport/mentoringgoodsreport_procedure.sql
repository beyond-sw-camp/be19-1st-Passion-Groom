use groom;
DELIMITER //

CREATE PROCEDURE p_update_report_status()
BEGIN
    -- mentoring_id별 신고 횟수 5회 이상인 것만 찾아서 상태 변경
    UPDATE mentoringgoodsreport r
    JOIN matching m ON r.matching_number = m.matching_number
    JOIN (
        SELECT m2.mentoring_id
        FROM mentoringgoodsreport r2
        JOIN matching m2 ON r2.matching_number = m2.matching_number
        GROUP BY m2.mentoring_id
        HAVING COUNT(*) >= 5
    ) t ON m.mentoring_id = t.mentoring_id
    SET r.mentoringgoodsreport_status = 'in_review'
    WHERE r.mentoringgoodsreport_status = 'pending';
END;
//

DELIMITER ;

CALL p_update_report_status();

select * from mentoringgoodsreport;

UPDATE mentoringgoodsreport r
JOIN matching m ON r.matching_number = m.matching_number
SET r.mentoringgoodsreport_status = 'approved'
WHERE m.mentoring_id = 4;

UPDATE mentoringgoodsreport
SET mentoringgoodsreport_status = 'rejected'
WHERE mentoringgoodsreport_status = 'in_review'
  AND mentoringgoodsreport_create < NOW() - INTERVAL 3 DAY;