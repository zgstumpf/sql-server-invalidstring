drop table MyConstrainedTable;
create table MyConstrainedTable (
    string nvarchar(max)
);
go

alter table MyConstrainedTable
add constraint CHK_MyConstrainedTable_string CHECK (
    datalength(string) > 0 /* empty string */
    and string not like ' %' /* leading space */
    and string not like '% ' /* trailing space */
    and string not like '%  %' /* 2 consecutive spaces */
    and dbo.invalidUnicode(string) is null /* invalid character */
);
GO

/* Test. Run each insert statement to see generic constraint error. */
truncate table MyConstrainedTable;
insert MyConstrainedTable values (null); -- valid
insert MyConstrainedTable values (''); -- empty
insert MyConstrainedTable values (' '); -- single space character, caught as leading space
insert MyConstrainedTable values ('  '); -- leading space (and 2 consecutive spaces, but leading caught first)
insert MyConstrainedTable values ('abc'); -- valid
insert MyConstrainedTable values (' abc'); -- leading space
insert MyConstrainedTable values ('abc '); -- trailing space
insert MyConstrainedTable values ('a  bc'); -- 2 consecutive spaces
insert MyConstrainedTable values (nchar(10)); -- invalid Unicode
insert MyConstrainedTable values (' a' + nchar(10)); -- invalid Unicode, but leading space caught first
insert MyConstrainedTable values (nchar(10) + 'a '); -- invalid unicode, but trailing space caught first
insert MyConstrainedTable values ('a' + nchar(10) + 'def'); -- invalid Unicode
insert MyConstrainedTable values (nchar(15) + nchar(10)); -- 2 invalid Unicode, first one is caught first
insert MyConstrainedTable values (nchar(70)); -- valid
select * from MyConstrainedTable;