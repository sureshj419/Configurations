#!/bin/sh
###############################################################
#                 InitScriptStep2		                      #
###############################################################
# Purpose:
# Purpose of this file is to remove the pervious binaries on the #
# slave and trigger the MAIN_job on the slave
###############################################################
if [ $KCI_MACHINE_LABEL == windows ]
then
	export HOME=D:\cygwin64\bin\bash
    export PATH=$PATH:/usr/bin
fi

# Adding the input parameter to a local parameter
propertyFile="$1"

# Condition to check if the number of parameters passed as input 
# are correct or not
if [ "$#" -eq 1 ]; then
  echo "Correct number of parameters"
  if [ -f "$propertyFile" ]; then
    echo "The property file $propertyFile found."

	
    # Read the keys and values in the property file
    while IFS='=' read -r key value
    do
      key=$(echo $key | tr '.' '_')
      eval "${key}='${value}'"
    done < "$propertyFile"
	
	echo "************************************************************"
	echo "PRE BUILD ACTIVITIES - REMOVE BINARIES FOLDER - START"
	#ws_loc="${workspace_location}"
	ws_loc="$WORKSPACE"
	echo "${ws_loc}"
	echo "Printing workspace location :::"$ws_loc
	cd ${ws_loc}

	cd ..

	pwd 
	
	if [ $KCI_MACHINE_LABEL == windows ]; then
		
		if [ -d "$KCI_WIN_SLAVE_MAIN_JOB_NAME" ]; then
			cd "$KCI_WIN_SLAVE_MAIN_JOB_NAME"
			pwd
			echo "REMOVING WORKSPACE FOLDER"
			rm -rf "workspace"
			echo "DONE"
		else 	
			echo "Job executing for the first time. Creating main job folder"
			mkdir "$KCI_WIN_SLAVE_MAIN_JOB_NAME"
			cd "$KCI_WIN_SLAVE_MAIN_JOB_NAME"
			pwd
		fi
	else 
		
		if [ -d "$KCI_MAC_SLAVE_MAIN_JOB_NAME" ]; then
			cd "$KCI_MAC_SLAVE_MAIN_JOB_NAME"
			pwd
			echo "REMOVING WORKSPACE FOLDER"
			rm -rf "workspace"
			echo "DONE"
		else 	
			echo "Job executing for the first time. Creating main job folder"
			mkdir "$KCI_MAC_SLAVE_MAIN_JOB_NAME"
			cd "$KCI_MAC_SLAVE_MAIN_JOB_NAME"
			pwd
		fi
	fi
	
	echo "Creating WORKSPACE"
	mkdir "workspace"
	echo "DONE"
	
	cd "workspace"
	
	echo "Creating $KCI_UI_LOCAL_MODULE_DIR FOLDER"
	mkdir $KCI_UI_LOCAL_MODULE_DIR
	echo "DONE"

	echo "PRE BUILD ACTIVITIES - REMOVE BINARIES FOLDER - END"
	echo "************************************************************"

  else
    echo "The property file $propertyFile not found."
  fi
else
  echo "Wrong number of parameters!!"
fi
