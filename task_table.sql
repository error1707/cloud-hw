CREATE TABLE tasks (
    id      Uint64 NOT NULL,
    PRIMARY KEY (id),

    model   String,
    status  String,
    result  String
);

CREATE TABLE serial NOT NULL(
    id Uint8,
    PRIMARY KEY (id),

    max_task_id Uint64
);
COMMIT;

INSERT INTO serial (id, max_task_id) VALUES (0, 0);