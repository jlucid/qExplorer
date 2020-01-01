p)import base64, codecs, json, requests, os
p)import plyvel
p)databases = {}

p)def createDB(dbName,path):
    global databases
    databases[bytes(dbName,'utf-8')] =  plyvel.DB(path, create_if_missing=True)
    return dbName

p)def put(dbName,Key,Value):
    global databases
    databases[bytes(dbName,'utf-8')].put(bytes(Key,'utf-8'),bytes(Value,'utf-8'))

p)def get(dbName,Key):
    global databases
    return databases[bytes(dbName,'utf-8')].get(bytes(Key,'utf-8'))

p)def delete(dbName,Key):
    global databases
    databases[bytes(dbName,'utf-8')].delete(bytes(Key,'utf-8'))
    return True

p)def writeBatch(dbName,Keys,Values):
    global databases
    wb = databases[bytes(dbName,'utf-8')].write_batch()
    for k,v in zip(Keys,Values):
      wb.put(bytes(k,'utf-8'),bytes(v,'utf-8'))
    wb.write()

p)def deleteBatch(dbName,Keys):
    global databases
    wb = databases[bytes(dbName,'utf-8')].write_batch()
    for k in Keys:
      wb.delete(bytes(k,'utf-8'))
    wb.write()

p)def closeDB(dbName):
    global databases
    databases[bytes(dbName,'utf-8')].close()

p)def isClosed(dbName):
    global databases
    if dbName in databases.keys():
      return databases[bytes(dbName,'utf-8')].closed
    else:
      return False

p)def printDB(dbName):
  for key, value in  databases[bytes(dbName,'utf-8')]:
    print(key)
    print(value)


q).plyvel.createDB:.p.get[`createDB;<]
q).plyvel.closeDB:.p.get[`closeDB;<]
q).plyvel.put:.p.get[`put;<]
q).plyvel.get:.p.get[`get;<]
q).plyvel.delete:.p.get[`delete;<]
q).plyvel.writeBatch:.p.get[`writeBatch;<]
q).plyvel.deleteBatch:.p.get[`deleteBatch;<]
q).plyvel.isClosed:.p.get[`isClosed;<]
q).plyvel.printDB:.p.get[`printDB;<]

