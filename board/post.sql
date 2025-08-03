-- REQ-074 회원은 게시글의 제목과 내용을 작성해야 한다.
INSERT INTO post (post_title, post_detail, member_id)
VALUES ('제목 예시', '내용 예시입니다.', 1);


-- REQ-075 게시글에 파일을 등록할 수 있다.
INSERT INTO file (
    file_name, file_type, file_rename, file_path, file_order, post_id
) VALUES (
    'image2.jpg', 'image/jpeg2', '20250801_abc1234.jpg', '/uploads/20250801/', 1, 10
);


-- REQ-076 회원은 게시글에 좋아요 1개를 줄 수 있다.
UPDATE post
SET post_like = post_like + 1
WHERE post_id = 3;


-- REQ-077 본인이 작성한 게시글의 내용을 수정할 수 있다.
UPDATE post
SET post_detail = '수정된 게시글 내용입니다.'
WHERE post_id = 1;


-- REQ-078 작성한 본인의 글은 삭제 할 수 있다.
DELETE FROM post WHERE member_id = 1;


-- REQ-079 좋아요가 높은 순으로 조회할 수 있다.
SELECT * FROM post
ORDER BY post_like DESC;


-- REQ-080 악성 게시글은 신고할 수 있다.
insert into postdeclaration (declaration_detail) VALUES ('신고합니다아아아아.');


-- REQ-081 해당 게시판을 삭제 할 수 있다.
DELETE FROM post WHERE post_id = 2;