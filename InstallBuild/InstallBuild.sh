#!/bin/bash

## usage ##
# sh InstallBuild.sh
# Provide the build URL
# Install the build (wget and unzip)
# Deply the war by copying the script to the tomcat directory
# replace properties
DBname=$1
portNumber=$2
buildPath=$3

if expr $portNumber + 0 > /dev/null 2>&1
then
    echo "$portNumber is your portNumber"
else
    echo "$portNumber isn't a number plz enter a valid number"
fi



#DBname="AdminOperations27"
mysql -u root -B -N -e "CREATE DATABASE IF NOT EXISTS $DBname"
echo "Database  $DBname Created !"
cd /home/local/ZOHOCORP/antony-7244/PycharmProjects/InstallBuild/builds



	branch_dir=`echo $buildPath | cut -d '/' -f7`
	date_dir=`echo $buildPath | cut -d '/' -f8`
    	branch_dir=$branch_dir-$date_dir
	echo $branch_dir
	if [ ! -d $branch_dir ]; then
		mkdir $branch_dir
		echo "Create directory $branch_dir"
	else
		echo "Hey!, directory $branch_dir already exists!!!"
		echo "Skippig ..."
	fi

cd $branch_dir

#echo `pwd`

#	if [ ! -d $date_dir ]; then
#		echo "Create directory $date_dir"
#		mkdir $date_dir
#	else
#		echo "Ohh! $date_dir already exists !!!"
#	fi

#	cd $date_dir

	echo `pwd`

### Installing the build

	wget $buildPath

	unzip ManageEngine_ServiceDesk.zip

	CURR_DIR=`pwd`

	SERVER_HOME=$CURR_DIR/AdventNet/Sas/tomcat

	cd $SERVER_HOME

	if [ -d $SERVER_HOME ]; then
        sed -i 's/8080/'$portNumber'/g' conf/server.xml
        sed -i 's/8443/8443/g' conf/server.xml
        sed -i 's/8080/'$portNumber'/g' conf/server.xml.orig
        sed -i 's/8443/8443/g' conf/server.xml.orig
        fi



	sleep 2
	######
	echo export JAVA_OPTS="-XX:PermSize=250M -XX:MaxPermSize=250M -Xms256m -Xmx512m -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=54321" >> $SERVER_HOME"/bin/catalina.sh"
	echo " " >> $SERVER_HOME"/bin/catalina.sh"
	sleep 1
	echo "nohup python -m SimpleHTTPServer &" >> $SERVER_HOME"/bin/catalina.sh"

cd $SERVER_HOME
cd bin

#sh linux_601run.sh

PROP_PATH="WEB-INF"
CONF_PATH="WEB-INF/conf"
CONF_FILE="database_params.conf"
WORKING_DIR=""

replaceValues() {
    if [ -f $PROP_PATH/security-properties.xml ]; then
        echo "Setting the service name in security-properties"
        sed -i'' 's/SDPOnDemand/SDPOnDemand/g' $PROP_PATH/security-properties.xml
        sed -i'' 's/https/http/g' $PROP_PATH/security-properties.xml
    fi

  if [ -f $PROP_PATH/security.xml ]; then
        echo "Making HTTP in security.xml"
        sed -i'' 's/https=\"true/https=\"false/g' $PROP_PATH/security.xml
    fi


# if [ -f $CONF_PATH/server.xml.orig ]; then
#	    echo "Setting the port in server.xml.orig"
#		    sed -i'' 's/$portNumber/7070/g' $CONF_PATH/server.xml.orig
#		    sed -i'' 's/8443/7443/g' $CONF_PATH/server.xml.orig
#		    fi

    if [ -f $CONF_PATH/app.properties ]; then
        echo "Setting production mode to false in app.properties of $war_dir context"
        sed -i'' 's/production=true/production=false/g' $CONF_PATH/app.properties
    fi

    if [ -f $CONF_PATH/sas.properties ]; then
        echo "Setting production mode to false in sas.properties of $war_dir context"
        sed -i'' 's/production=true/production=false/g' $CONF_PATH/sas.properties
    fi

    dbprefix=""
    if [ -f $CONF_PATH/configuration.properties ];then
	    CONF_FILE="configuration.properties"
	    dbprefix="db."
	    sed -i'' 's/production=true/production=false/g' $CONF_PATH/configuration.properties
	    sed -i'' "s/db.schemaname=jbossdb/db.schemaname=$DBname/g" $CONF_PATH/configuration.properties
	    sed  -i "s#app.home=.*#app.home=$WORKING_DIR/$war_dir/WEB-INF#g" $CONF_PATH/$CONF_FILE
	    appcontext=""
	    if [ "x$war_dir"  != "xROOT" ];then
		    appcontext="/$war_dir"
	    fi
            sed  -i "s#app.context=.*#app.context=$appcontext#g" $CONF_PATH/$CONF_FILE
    fi

 if [ -f $CONF_PATH/app.properties ]; then
            echo "Setting the domain name in app.properties of $war_dir context"
                    sed -i'' 's/sdpondemand.manageengine.com/antony-7244.csez.zohocorpin.com:'$portNumber'/g' $CONF_PATH/app.properties
                  #  sed -i'' "s/#js.path=localjs.zohostatic.com/js.path=sdplive.estancia\/static\/$branch_dir\/$date_dir/g" $CONF_PATH/app.properties
                  #  sed -i'' "s/#css.path=localcss.zohostatic.com/css.path=sdplive.estancia\/static\/$branch_dir\/$date_dir/g" $CONF_PATH/app.properties
                  #  sed -i'' "s/#image.path=localimg.zohostatic.com/image.path=sdplive.estancia\/static\/$branch_dir\/$date_dir/g" $CONF_PATH/app.properties
                    fi

		    if [ -d $PROP_PATH ]; then
			    echo "**** replacing threshold in xml files ****"
				   xml_files=`find . -iname "*.xml"`
				    for k in $xml_files
					    do
						    sed -i  's/threshold=\"/threshold=\"100/g' $k
							    done
							    fi



}

disableLogs() {

    echo "Disabling console logs... Logs can be found in ../logs/"
    echo "

# File for container level log configuration. App specific log configuration can
    # be done inside <app>.war

    handlers = 1catalina.org.apache.juli.FileHandler

    .handlers = 1catalina.org.apache.juli.FileHandler

    1catalina.org.apache.juli.FileHandler.level = FINE
    1catalina.org.apache.juli.FileHandler.directory = ../logs/
    1catalina.org.apache.juli.FileHandler.prefix = catalina-
    " > ../conf/logging.properties
}
###===
LogsHttpServer(){
cd $SERVER_HOME"/logs"
nohup python -m SimpleHTTPServer &
}
###===

main() {

    mysql_root_pwd=$1
    if [ "x$2" = "xdisable" ]; then
    	disableLogs
    fi

    cd ../webapps/
    WORKING_DIR=`pwd`
    for war in `find *.war`
        do
            war_dir=`ls $war | cut -d'.' -f1`
            if [ ! -d $war_dir ]; then
                echo "Extracting $war..."
                unzip -qo $war -d $war_dir
		        cd $war_dir
                replaceValues
                echo "Compressing $war..."
                zip -rq $war .
                mv -f $war ../$war
                cd -
                rm -rf $war_dir
            else
    		    cd $war_dir
                replaceValues
                cd -
            fi
    done
    cd ../bin
 # export JAVA_OPTS="-XX:PermSize=250M -XX:MaxPermSize=250M -Xms256m -Xmx512m -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=3000 -Ddisable.isc.signature=true"
   # sh catalina.sh run
}

main $@

sh catalina.sh run &



#sed -i 's/-Ddb.vendor.name=mysql/-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=54321 -Ddb.vendor.name=mysql/g' bin/run.sh