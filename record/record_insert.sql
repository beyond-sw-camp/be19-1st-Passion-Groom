INSERT INTO record (
    record_title,
    record_text,
    member_role,
    matching_number
) VALUES (
    'React 기초 개념 학습 - 1회차',
    '오늘은 React의 기본 개념과 컴포넌트 구조에 대해 학습했습니다. 멘티가 JavaScript 기초가 탄탄해서 이해도가 높았습니다. 다음 시간에는 실제 프로젝트를 시작할 예정입니다.',
    '멘토',
    1  -- 매칭 번호
);

INSERT INTO record (
    record_title,
    record_text,
    member_role,
    matching_number
) VALUES (
    '첫 번째 React 수업 후기',
    'React 개념이 처음엔 어려웠지만 멘토님의 친절한 설명으로 이해할 수 있었습니다. 컴포넌트와 props에 대한 개념이 명확해졌고, 다음 수업이 기대됩니다.',
    '멘티',
    1
);

select * from record;