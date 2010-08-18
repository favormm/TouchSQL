#!/usr/bin/python

import TouchSQL

#theDatabase = TouchSQL.CSqliteDatabase.alloc().initInMemory()
theDatabase = TouchSQL.CSqliteDatabase.alloc().initWithPath_('/Users/schwa/Desktop/test.db')
theDatabase.open_(None)

# theStatement = TouchSQL.CSqliteStatement.alloc().initWithDatabase_string_(theDatabase, 'create table foo (name varchar(100), value integer)')
# print theStatement
# 
# print theStatement.step_(None)


theStatement = TouchSQL.CSqliteStatement.alloc().initWithDatabase_string_(theDatabase, 'SELECT * FROM messages')

print theStatement.rows_(None)
