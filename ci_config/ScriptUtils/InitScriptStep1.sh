#!/bin/sh
###############################################################
#                 InitScriptStep1		                      #
###############################################################
# Purpose:
# Purpose of this file is to check the requirements and       #
# modify files required.                                      #
###############################################################

#Adding the input parameters to the local parameters.
PROP_FILE_PATH="$1"
PROP_ROOT_DIR="$2"
JOB_NAME="$3"
PROP_ZIP_FILE_NAME="$4"

# Condition to check if the number of parameters passed as input 
# are correct or not
if [ "$#" -eq 4 ]; then
    echo "Correct number of parameters"
    echo "************************************************************"
	echo "PRE BUILD ACTIVITIES - UNZIP PROPERTIES FOLDER - START"

	echo "$WORKSPACE/$PROP_FILE_PATH"
	
	cd $PROP_ROOT_DIR/$JOB_NAME
	
#Removing all the white spaces in the property file if any and #
# re-writing the property file .
	grep -v '^[[:space:]]*$' ${PROP_FILE_NAME}.properties > ${PROP_FILE_NAME}New.properties
	rm -rf ${PROP_FILE_NAME}.properties
	tr -d '\r\f' <${PROP_FILE_NAME}New.properties >${PROP_FILE_NAME}.properties
	rm -rf ${PROP_FILE_NAME}New.properties
	#mv ${PROP_FILE_NAME}New.properties ${PROP_FILE_NAME}.properties

	cd $PROP_ROOT_DIR/$JOB_NAME/ScriptUtils

	
#Re-writing all the required script files to avoid any error afetr checking out the code from gitHub
	tr -d '\r\f' <ArchiveAndEnableOTA.sh >ArchiveAndEnableOTANew.sh
	rm -rf ArchiveAndEnableOTA.sh
	mv ArchiveAndEnableOTANew.sh ArchiveAndEnableOTA.sh

	tr -d '\r\f' <MainScript.sh >MainScriptNew.sh
	rm -rf MainScript.sh
	mv MainScriptNew.sh MainScript.sh

	tr -d '\r\f' <InitScriptStep2.sh >InitScriptStep2New.sh
	rm -rf InitScriptStep2.sh
	mv InitScriptStep2New.sh InitScriptStep2.sh
	
	tr -d '\r\f' <ipaGenerate.sh >ipaGenerateNew.sh
	rm -rf ipaGenerate.sh
	mv ipaGenerateNew.sh ipaGenerate.sh

	echo "PRE BUILD ACTIVITIES - UNZIP PROPERTIES FOLDER - END"
	echo "************************************************************"
else
  echo "Wrong number of parameters!!"
fi
