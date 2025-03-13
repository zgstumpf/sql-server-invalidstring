drop function dbo.invalidUnicode;
go

create function invalidUnicode(@string nvarchar(max)) returns int
begin
    /*
    Iterates through @string and returns the first invalid Unicode character found.
    Returns null if none are found.
    */

    /* Must avoid int overflow if @string is at max length */
    declare @n int, @i int = 0;
    while @i < len(@string) begin
        set @n = unicode(substring(@string, @i + 1, 1));

        if exists (
            select 1
            from (values /* https://www.ssec.wisc.edu/~tomw/java/unicode.html - integers for Unicode characters */
                  (0, 31)
                , (127, 159)
                , (160, 160)
                , (8192, 8207)
                , (8232, 8239)
                , (8298, 8303)
            ) as InvalidRanges(l, r)
            where @n between l and r
        ) return @n;

        set @i += 1;
    end;

    return null;
end;
go