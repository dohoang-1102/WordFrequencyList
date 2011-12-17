import sqlite3;
from datetime import datetime, date;
import time

# return category id
def getCategoryId(count):
    if count < 910:
        return 0
    elif count < 2275:
        return 1
    elif count < 4323:
        return 2
    elif count < 7395:
        return 3
    else:
        return 4

# return group id
def getGroupId(category, count):
    if category == 0:
        return (count)/200;
    elif category == 1:
        return (count-910)/200;
    elif category == 2:
        return (count-2275)/200;
    elif category == 3:
        return (count-4323)/200;
    else:
        return (count-7395)/200;

inConn = sqlite3.connect('mysql.sqlite')
outConn = sqlite3.connect('WordFrequencyList.sqlite')
 
inCursor = inConn.cursor()
outCursor = outConn.cursor()
 
outConn.execute("DELETE FROM ZWORD")
 
maxId = 0
count = -1
inCursor.execute("select * from word order by frequency desc")
#print inCursor.fetchall()
for row in inCursor:
	if row[0] > maxId:
		maxId = row[0]
	
	count = count + 1
	# Create ZWORD entry
	vals = []
	vals.append(count+1)                                    # Z_PK	row[0]
	vals.append(1)                                          # Z_ENT
	vals.append(1)                                          # Z_OPT
	vals.append(0)                                          # ZMARKSTATUS
	vals.append(row[2])                                     # ZRANK
	vals.append(getCategoryId(count))                       # ZCATEGORY	row[11]
	vals.append(getGroupId(getCategoryId(count), count))    # ZGROUP
	vals.append(row[3])                                     # ZTRANSLATE
	vals.append("")                                         # ZMARKDATE
	vals.append(row[1])                                     # ZSPELL
	vals.append(row[5])                                     # ZPHONETIC
	vals.append(row[4])                                     # ZDETAIL
	vals.append(row[6])                                     # ZSOUNDFILE
	vals.append(row[7])                                     # ZTAGS
	outConn.execute("insert into ZWORD values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", vals)
    
    
print count+1 
outConn.execute("update Z_PRIMARYKEY set Z_MAX=? where Z_NAME = 'Word'", [count+1])
 
outConn.commit()