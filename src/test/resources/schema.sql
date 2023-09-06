drop table if exists item cascade;
create table item (
    id bigint generated by DEFAULT as IDENTITY,
    item_name varchar(10),
    price integer,
    quantity integer,
    primary key (id)
);