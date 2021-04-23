import subprocess

from flask import Flask, render_template, request

HomeDir = "/home/test/"

app = Flask(__name__)

def executeShell(command):
    process = subprocess.check_output(command, shell=True);
    process = str(process)
    process = process.split('\\n')

    return process



@app.route('/')
def index():
   return render_template('html/index.html')

@app.route('/index',methods = ['POST', 'GET'])
def result():
      result = request.form
      url=request.form["url"]
      db = request.form["db"]
      port = request.form["port"]
      print(url,db,port)
      InstallBuild = HomeDir
      if not url :
          print("URL empty")

      else:

          InstallBuildSuccess = subprocess.check_output(
              "sh " + HomeDir + "PycharmProjects/InstallBuild/InstallBuild.sh " + db + " " + port + " " + url, shell=True);
          print(InstallBuildSuccess)
      return render_template("html/index.html")

@app.route("/GetAllRunningBuilds")
def GetAllRunningBuilds():
    SplitVar = "/AdventNet/Sas/tomcat/conf/logging.properties"
    ListOfBuilds = []
    RunningBuilds=[]
    process = subprocess.check_output("ps auxx | grep 'builds'", shell=True);
    process = str(process)
    #print (process)


    RunningBuilds = process.split('org.apache.catalina.startup.Bootstrap start')
    print (RunningBuilds)

    #print (RunningBuilds.__len__())


    for build in RunningBuilds:
        if "builds/" in build:
            print (build)
            print("+++++++++++++++")
            StartIndex = build.index(HomeDir)
            EndIndex = build.index(SplitVar)
            print(build[StartIndex:EndIndex])
            BuildName = build[StartIndex:EndIndex]

            DBNameQuery = "grep 'db.schemaname' " + BuildName + "/AdventNet/Sas/tomcat/webapps/ROOT/WEB-INF/conf/configuration.properties"
            PortQuery = "grep 'sdp.domain.name' " + BuildName + "/AdventNet/Sas/tomcat/webapps/ROOT/WEB-INF/conf/app.properties"

            DBNAME = GetDBname(DBNameQuery)
            PORT = GetPORT(PortQuery)
            print (PORT)
            BuildDetails=[]
            BuildDetails.append(BuildName)
            BuildDetails.append(PORT)

            BuildDetails.append(DBNAME)

            ListOfBuilds.append(BuildDetails)
            print (ListOfBuilds)

    return render_template("html/index.html" ,ListOfBuilds=ListOfBuilds)


def GetDBname(DBNameQuery) :
    DBNAME = subprocess.check_output(DBNameQuery, shell=True);
    DBNAME = str(DBNAME)
    DBNAME = DBNAME.split("=")
    DBNAME = DBNAME[1]
    DBNAME = DBNAME[:-1]
    return DBNAME

def GetPORT(PORTQuery) :
    PORT = subprocess.check_output(PORTQuery, shell=True);
    PORT = str(PORT)
    print (PORT)
    PORT = PORT.split(":")
    print (PORT)

    PORT = PORT[1]
    PORT = PORT[:-1]

    return PORT

@app.route("/StartBuild/<BuildToStart>" )
def StartBuild(BuildToStart) :
   # BuildToStart = BuildToStart.split("+++")
   # BuildToStart = BuildToStart[0]+"/"+BuildToStart[1]
   # BuildToStart =BuildToStart[1]

    print(BuildToStart)

    BuildToStart = HomeDir+"PycharmProjects/InstallBuild/builds/"+BuildToStart

    print(BuildToStart)
    Started = subprocess.check_output("sh "+BuildToStart+"/AdventNet/Sas/tomcat/bin/catalina.sh  run &", shell=True);
    print(Started)
    return GetAllRunningBuilds()


@app.route("/StopBuild/<BuildToStop>")
def StopBuild(BuildToStop) :
    try :
        print("buildStopped")
        BuildToStop = BuildToStop.split("+++")
        BuildToStop = BuildToStop[0]+"/"+BuildToStop[1]
        print(BuildToStop)
        Started = subprocess.check_output("pkill -f '"+BuildToStop+"'", shell=True);
    except :
        print("An exception occurred")
    return GetAllRunningBuilds()
@app.route("/GetallBuilds")
def GetAllBuilds():
    GetAllBuilds = executeShell("ls " + HomeDir +"PycharmProjects/InstallBuild/" + "builds")
    for build in GetAllBuilds:
        build=build.split("\n")
        print(build)
    return render_template("html/index.html" ,GetAllBuilds=build)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8001)
