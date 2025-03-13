# sql-server-invalidstring
**Prevent bad data in nchar, nvarchar, char, and varchar columns via a trigger or constraint.**

## Null strings
Without proper checks, here are some "null" strings that can enter your database and introduce errors in your applications or data analytics:

`''`

An empty string. May appear if the application user submits an empty form field. Is there a meaningful difference between this and null? I don't think so.

`' '`

A single space character, which is essentially an empty string because it contains no meaningful data.

`'      '`

Multiple space characters. Common in nchar and char columns. Still contains no meaningful data.

None of these strings should enter your database. `null` should replace them since it means absence of data. This trigger/constraint will stop these invalid strings but allow `null` to pass.

## Spaces in weird places
`    Jon Doe`

`Jon Doe    `

`Jon    Doe`

This trigger/constraint will stop these strings, only allowing `Jon Doe` to pass.

## Unusual Unicode characters
What is the difference between `'ab'` and `'a​b'`? If you don't believe they are different, copy and paste them into a character counter, and you will see that the second string has a third character. This third character is a Unicode *zero-width space*. If this entered your database or applications, it could get very confusing.

Did you know SQL Server allows a column to contain a *delete* character?

This trigger/constraint will stop strings containing these unusual characters and many more.

## Usage

A constraint is the conventional way to check for bad data. If you add a constraint to your table, it ensures any existing data and future data meet the constraint. However, a constraint does not provide a useful error message when it is violated, which is why this repository contains the same string-checking logic in a trigger. The trigger provides custom error messages. However, when you add a trigger, it will not check existing data, only future data. If you want to use the trigger, make sure to add the constraint first to check existing data. Once the constraint passes all the existing data, you can remove the constraint and add the trigger.

Copy/paste the necessary code from constraint.sql and/or trigger.sql, making sure to customize table/column names in the code to the ones in your database.
