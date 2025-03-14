drop table MyTable;
create table MyTable (
    string nvarchar(max)
)
go

drop trigger TR_MyTable_string_InvalidString;
go

create trigger TR_MyTable_string_InvalidString on MyTable
after insert, update
as
    if rowcount_big() = 0 return;

    if exists(select 1 from inserted where datalength(string) = 0) throw 50000, 'Insert failed in MyTable.string: string is empty.' , 0;
    if exists(select 1 from inserted where string like ' %') throw 50001, 'Insert failed in MyTable.string: string contains a leading space.', 0;
    if exists(select 1 from inserted where string like '% ') throw 50002, 'Insert failed in MyTable.string: string contains a trailing space.', 0;
    if exists(select 1 from inserted where string like '%  %') throw 50003, 'Insert failed in MyTable.string: string contains two consecutive spaces.', 0;

    declare @invalidUnicodeInt int;
    /* Function is not applied once per row; optimizer makes it return early once first non-null value is found */
    with cte as (
        select
            dbo.invalidUnicode(string) as invalidUnicodeInt
        from inserted
    )
    select top 1
        @invalidUnicodeInt = invalidUnicodeInt
    from cte
    where invalidUnicodeInt is not null

    if @invalidUnicodeInt is not null begin
        /* highest nchar int is 1114111 (7 digits) */
        declare @message nvarchar(2048) = 'Insert failed in MyTable.string: string contains unallowed Unicode character ' + cast(@invalidUnicodeInt as nvarchar(7)) + '.';
        throw 50004, @message, 0;
    end
go

/* Test. Run each insert statement to see specific error message. */
truncate table MyTable;
insert MyTable values (null); -- valid
insert MyTable values (''); -- empty
insert MyTable values (' '); -- single space character, caught as leading space
insert MyTable values ('  '); -- leading space (and 2 consecutive spaces, but leading caught first)
insert MyTable values ('abc'); -- valid
insert MyTable values (' abc'); -- leading space
insert MyTable values ('abc '); -- trailing space
insert MyTable values ('a  bc'); -- 2 consecutive spaces
insert MyTable values (nchar(10)); -- invalid Unicode
insert MyTable values (' a' + nchar(10)); -- invalid Unicode, but leading space caught first
insert MyTable values (nchar(10) + 'a '); -- invalid unicode, but trailing space caught first
insert MyTable values ('a' + nchar(10) + 'def'); -- invalid Unicode
insert MyTable values (nchar(15) + nchar(10)); -- 2 invalid Unicode, first one is caught first
insert MyTable values (nchar(70)); -- valid
select * from Mytable;
