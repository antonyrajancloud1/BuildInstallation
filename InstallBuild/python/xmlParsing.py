from xml.dom import minidom
xmldoc = minidom.parse('/home/local/ZOHOCORP/antony-7244/builds/SDPLIVE_ADMIN_OPERATIONS_BRANCH/Aug_23_2019_1/AdventNet/Sas/tomcat/webapps/ROOT/WEB-INF/v3api/security-asset-v3.xml')
itemlist = xmldoc.getElementsByTagName('url')
print(len(itemlist))
print(itemlist[0].attributes['path'].value)
for s in itemlist:
    #print(s.attributes['path'].value)
    a=s.attributes['path'].value.split("api/v3")
    print(a[1])


import psutil
for proc in psutil.process_iter():
	processName = proc.name()
	processID = proc.pid
	if "java" in processName:
		print(proc)