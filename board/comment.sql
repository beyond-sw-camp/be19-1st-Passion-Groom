-- REQ-082 회원은 게시글에 댓글을 남길 수 있고, 익명 여부 설정이 가능하다.
INSERT INTO comment (comment_text, comment_hide, post_id, member_id)
VALUES ('실명 댓글입니다.', FALSE, 1, 123);


-- REQ-083 본인의 댓글은 언제든지 삭제 할 수 있다.
DELETE FROM comment WHERE comment_num = 3 AND member_id = 30;


-- REQ-084 악성 댓글 및 욕설 댓글은 신고할 수 있다.
INSERT INTO cdeclaration (cdeclaration_detail, cdeclaration_status, comment_num, member_id2)
VALUES ('실명 댓글입니다.', FALSE, 2, 30);


-- REQ-085 해당 댓글을 삭제할 수 있다.
DELETE FROM comment WHERE comment_num = 2;


-- REQ-086 회원은 댓글에 대댓글을 남길 수 있고, 익명 여부 설정이 가능하다.
INSERT INTO dacomment (dacomment_detail, dacomment_hide, comment_num)
VALUES ('대댓글입니다.',FALSE,4);
INSERT INTO cdeclaration (cdeclaration_detail, cdeclaration_status, comment_num, member_id2)
VALUES ('실명 댓글입니다.', FALSE, 2, 30);


-- REQ-087 본인의 대댓글은 언제든지 삭제 할 수 있다.
DELETE from dacomment WHERE dacomment_num = 5 AND member_id = 0;
DELETE FROM cdeclaration WHERE cdeclaration_num = 6;



-- REQ-088 악성 대댓글 및 욕설 대댓글은 신고할 수 있다.
INSERT INTO cdeclaration (cdeclaration_detail, cdeclaration_status, comment_num, member_id2)
VALUES ('너무 문제가 많아요.', FALSE, 3, 40);