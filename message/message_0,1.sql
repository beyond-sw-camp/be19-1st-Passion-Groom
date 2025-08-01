UPDATE message 
SET mentor_read = TRUE 
WHERE message_id = 2;

UPDATE message 
SET mentee_read = TRUE 
WHERE message_id = 1;
