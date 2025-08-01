DROP TABLE IF EXISTS cash;
DROP TABLE IF EXISTS memberclaration;
DROP TABLE IF EXISTS cdeclaration;
DROP TABLE IF EXISTS postdeclaration;
DROP TABLE IF EXISTS likementoring;
DROP TABLE IF EXISTS file;
DROP TABLE IF EXISTS dacomment;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS record;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS matching;
DROP TABLE IF EXISTS mentoringgoods;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS location;

CREATE TABLE IF NOT EXISTS location (
    location_id int NOT NULL AUTO_INCREMENT,
    location_name varchar(255) NOT NULL,
    PRIMARY KEY (location_id)
);

CREATE TABLE IF NOT EXISTS category (
    category_id int NOT NULL AUTO_INCREMENT,
    category_name varchar(255) NOT NULL,
    category_create timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    category_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (category_id)
);

CREATE TABLE IF NOT EXISTS member (
    member_id int NOT NULL AUTO_INCREMENT,
    member_role tinyint NOT NULL CHECK (member_role IN(0, 1, 2, 3)),
    member_name varchar(30) NOT NULL,
    member_email varchar(255) NOT NULL UNIQUE,
    member_pw varchar(40) NOT NULL,
    member_phone varchar(20) NOT NULL UNIQUE,
    member_location varchar(255) NULL,
    member_job varchar(255) NULL,
    member_community varchar(100) NULL CHECK (member_community IN('온라인', '오프라인', '혼합')),
    member_age int NULL CHECK (member_age >= 1 AND member_age <= 101),
    member_gender int NULL,
    member_career varchar(255) NULL,
    member_porfol varchar(255) NULL,
    introduction varchar(255) NULL,
    member_point int NULL DEFAULT 0,
    member_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    member_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    member_rating decimal(2,1) NULL,
    member_certify_status enum('none', 'pending', 'approved', 'rejected') NOT NULL DEFAULT 'none',
    location_id int NOT NULL,
    category_id int NOT NULL,
    PRIMARY KEY (member_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE IF NOT EXISTS mentoringgoods (
    mentoring_id int NOT NULL AUTO_INCREMENT,
    mentoring_title varchar(255) NOT NULL,
    mentoring_detail text NOT NULL,
    mentoring_dt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mentoring_update_dt timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    mentoring_price int NOT NULL,
    mentoring_method varchar(100) NOT NULL CHECK (mentoring_method IN('온라인', '오프라인', '혼합')),
    mentoring_like int NULL DEFAULT 0,
    mentoring_time varchar(255) NOT NULL,
    mentoring_period varchar(255) NOT NULL,
    mentoring_maximum int NOT NULL,
    member_id int NOT NULL,
    category_id int NOT NULL,
    location_id int NOT NULL,
    PRIMARY KEY (mentoring_id),
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(category_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id)
);

CREATE TABLE IF NOT EXISTS matching (
    matching_number int NOT NULL AUTO_INCREMENT,
    matching_status enum('pending','approved','rejected','canceled','finished') NOT NULL DEFAULT 'pending',
    matching_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    matching_start timestamp NULL DEFAULT current_timestamp,
    matching_finish timestamp NULL DEFAULT current_timestamp,
    rating_mentor decimal(2,1) NULL,
    rating_mentee decimal(2,1) NULL,
    matching_reasons varchar(255) NULL,
    member_id int NOT NULL,
    mentoring_id int NOT NULL,
    PRIMARY KEY (matching_number),
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (mentoring_id) REFERENCES mentoringgoods(mentoring_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS schedule (
    schedule_id int NOT NULL AUTO_INCREMENT,
    schedule_content varchar(255) NOT NULL,
    schedule_dt timestamp NOT NULL,
    matching_number int NOT NULL,
    PRIMARY KEY (schedule_id),
    FOREIGN KEY (matching_number) REFERENCES matching(matching_number) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS record (
    record_id int NOT NULL AUTO_INCREMENT,
    record_title varchar(255) NOT NULL,
    record_text varchar(255) NOT NULL,
    record_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    member_role varchar(10) NOT NULL CHECK (member_role IN('멘토','멘티')),
    matching_number int NOT NULL,
    PRIMARY KEY (record_id),
    FOREIGN KEY (matching_number) REFERENCES matching(matching_number) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS review (
    review_id int NOT NULL AUTO_INCREMENT,
    review_title varchar(255) NOT NULL,
    review_detail varchar(255) NOT NULL,
    review_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    review_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    mentoring_id int NOT NULL,
    matching_number int NOT NULL,
    PRIMARY KEY (review_id),
    FOREIGN KEY (mentoring_id) REFERENCES mentoringgoods(mentoring_id) ON DELETE CASCADE,
    FOREIGN KEY (matching_number) REFERENCES matching(matching_number) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS message (
    message_id int NOT NULL AUTO_INCREMENT,
    message_title varchar(255) NOT NULL,
    message_content varchar(255) NOT NULL,
    message_dt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mentor_read boolean NULL DEFAULT false,
    mentee_read boolean NULL DEFAULT false,
    matching_number int NOT NULL,
    PRIMARY KEY (message_id),
    FOREIGN KEY (matching_number) REFERENCES matching(matching_number) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS post (
    post_id int NOT NULL AUTO_INCREMENT,
    post_title varchar(255) NOT NULL,
    post_detail varchar(255) NOT NULL,
    post_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    post_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    post_like int NULL DEFAULT 0,
    member_id int NOT NULL,
    PRIMARY KEY (post_id),
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS comment (
    comment_num int NOT NULL AUTO_INCREMENT,
    comment_text varchar(255) NOT NULL,
    comment_hide boolean NULL DEFAULT false,
    comment_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comment_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    comment_like int NULL DEFAULT 0,
    post_id int NOT NULL,
    member_id int NOT NULL,
    PRIMARY KEY (comment_num),
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dacomment (
    dacomment_num int NOT NULL AUTO_INCREMENT,
    dacomment_detail varchar(255) NOT NULL,
    dacomment_hide boolean NULL DEFAULT false,
    dacomment_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dacomment_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    dacomment_like int NULL DEFAULT 0,
    comment_num int NOT NULL,
    member_id int NOT NULL,
    PRIMARY KEY (dacomment_num),
    FOREIGN KEY (comment_num) REFERENCES comment(comment_num) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS file (
    file_id int NOT NULL AUTO_INCREMENT,
    file_name varchar(255) NOT NULL,
    file_type varchar(255) NOT NULL,
    file_rename varchar(255) NOT NULL,
    file_path varchar(255) NOT NULL,
    file_dt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    file_order int NULL,
    record_id int NULL,
    mentoring_id int NULL,
    post_id int NULL,
    PRIMARY KEY (file_id),
    FOREIGN KEY (record_id) REFERENCES record(record_id) ON DELETE CASCADE,
    FOREIGN KEY (mentoring_id) REFERENCES mentoringgoods(mentoring_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS likementoring (
    like_num int NOT NULL AUTO_INCREMENT,
    member_id int NOT NULL,
    mentoring_id int NOT NULL,
    PRIMARY KEY (like_num),
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (mentoring_id) REFERENCES mentoringgoods(mentoring_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS postdeclaration (
    declaration_num int NOT NULL AUTO_INCREMENT,
    declaration_detail varchar(255) NOT NULL,
    declaration_status boolean NULL DEFAULT false,
    declaration_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    post_id int NOT NULL,
    member_id1 int NOT NULL,
    member_id2 int NOT NULL,
    PRIMARY KEY (declaration_num),
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id1) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id2) REFERENCES member(member_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cdeclaration (
    cdeclaration_num int NOT NULL AUTO_INCREMENT,
    cdeclaration_detail varchar(255) NOT NULL,
    cdeclaration_status boolean NULL DEFAULT false,
    cdeclaration_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comment_num int NOT NULL,
    member_id1 int NOT NULL,
    member_id2 int NOT NULL,
    PRIMARY KEY (cdeclaration_num),
    FOREIGN KEY (comment_num) REFERENCES comment(comment_num) ON DELETE CASCADE,
    FOREIGN KEY (member_id1) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id2) REFERENCES member(member_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS mentoringgoodsreport (
    mentoringgoodsreport_id int NOT NULL AUTO_INCREMENT,
    mentoringgoodsreport_detail varchar(255) NOT NULL,
    mentoringgoodsreport_status enum('pending', 'in_review', 'accepted', 'rejected') NOT NULL DEFAULT 'pending',
    mentoringgoodsreport_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    matching_number int NOT NULL,
    PRIMARY KEY (mentoringgoodsreport_id),
    FOREIGN KEY (matching_number) REFERENCES matching(matching_number) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cash (
    cash_num int NOT NULL AUTO_INCREMENT,
    cash_amount int NOT NULL,
    cash_method varchar(255) NOT NULL,
    cash_stamp_dt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    member_id int NOT NULL,
    PRIMARY KEY (cash_num),
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE
);

