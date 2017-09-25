#!/bin/sh
###############################################################
#                 KickStarterScript		                      #
###############################################################
# Purpose:
# Purpose of this file to remove the pervious binaries on the #
# master and trigger the Slave job based on the platform 
# selected by user.											  #
###############################################################

# Adding the input parameter to a local parameter
propertyFile="$1"

# Condition to check if the number of parameters passed as input 
# are correct or not
if [ "$#" -eq 1 ]; then
  echo "Correct number of parameters"
  
# Checking if the property file exists  
  
  if [ -f "$propertyFile" ]; then
    echo "The property file $propertyFile found."

# Read the keys and values in the property file

    while IFS='=' read -r key value
    do
      key=$(echo $key | tr '.' '_')
      eval "${key}='${value}'"
    done < "$propertyFile"

		echo off

		echo "Executing the shell script on master"

# Creating local parametes for the type of the build required.
	
		iosBuild=false
		andBuild=false
		winBuild=false
		
# Read the property file and check for which platforms to be build and correspondingly making the 
# particular parameters defined above as either true or false.

		if [ $BUILD_FOR_IOS_RC_CLIENT = "true" ] || [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = "true" ]; then
			iosBuild=true
		fi
		if [ $BUILD_FOR_ANDROID_RC_CLIENT = "true" ] || [ $BUILD_FOR_ANDROID_TAB_RC_CLIENT = "true" ]; then
		andBuild=true
		fi
		if [ $BUILD_FOR_WINDOWS8_RC_CLIENT = "true" ] || [ $BUILD_FOR_WINDOWS81_RC_CLIENT = "true" ] || [ $BUILD_FOR_WINDOWS10_RC_CLIENT = "true" ] || [ $BUILD_FOR_WINDOWS81_TAB_RC_CLIENT = "true" ] || [ $BUILD_FOR_WINDOWS10_TAB_RC_CLIENT = "true" ]; then
			winBuild=true
		fi

		echo " iosBuild ::"$iosBuild
		echo " andBuild ::"$andBuild
		echo " winBuild ::"$winBuild
		
		executePipeline=false   # executePipeline -- to check if more than one platform build is needed and it is made true or false
		KCI_MACHINE_LABEL=ios  # KCI_MACHINE_LABEL is defined to trigger the build either on win_slave or mac_slave.

		echo "KCI_MACHINE_LABEL before is "$KCI_MACHINE_LABEL

		if [ $iosBuild = true ] && [ $winBuild = true ]; then
			executePipeline=true
		else 
			if [ $iosBuild = true ]; then
				KCI_MACHINE_LABEL=ios
			else 
				KCI_MACHINE_LABEL=windows
			fi
			
		fi
		if [ $KCI_MACHINE_LABEL = "windows" ]; then
			echo "Machine label is windows"
			if [ $winBuild = false ] && [ $andBuild = true ]; then
				echo "Checking if Windows job exists"
				if [[ ! -z $KCI_WIN_SLAVE_INIT_JOB_NAME ]];then
					echo "Windows job exists. Redirecting android build to Win Slave"
				else
					echo "Windows job does not exists. Redirecting android build to Mac Slave"
					KCI_MACHINE_LABEL=ios
				fi
			fi
		else 
			echo "Machine label is ios"
		fi
		echo "executePipeline is "${executePipeline}
		echo "KCI_MACHINE_LABEL after is "$KCI_MACHINE_LABEL
		
		workspaceNew=`echo $WORKSPACE`
		echo "workspaceNew is ::"$workspaceNew
		
		# Re-writing the property files based on the platfomrs.
		# If the job is triggered in Mac Slave/ Win Slave. The Slave specific properties are re-written in the file.
		# If the job is triggered in Mac Slave and Win Slave. Two property files will created with Slave specific properties.

		newCommonPropertyFileName=`echo ${appidkey}_Config.properties`
		echo "newCommonPropertyFileName ::  $newCommonPropertyFileName"

		macPropertyFileName=`echo ${appidkey}_Config_Mac.properties`
		echo "macPropertyFileName ::  $macPropertyFileName"

		winPropertyFileName=`echo ${appidkey}_Config_Win.properties`
		echo "winPropertyFileName ::  $winPropertyFileName"
		
		#This was old hardcoded property being used..
		#common_config_file_path="F:/Work/Projects/Alticor/PropertiesFiles/ci_config"
		#Added below property directly in the config file and commented the below line as well
		common_config_file_path="${MASTER_COMMON_CONFIG_FILE_PATH}/ci_config"
		
		echo "common_config_file_path ::  $common_config_file_path"
		
		if [ -d $common_config_file_path ]; then
			
			if [ -f "$WORKSPACE/ci_config"/${appidkey}_Config.properties ]; then
				cp "$WORKSPACE/ci_config"/${appidkey}_Config.properties $common_config_file_path
				echo "Copying property file successfull"
			fi
			
			if [ -f "$WORKSPACE/ci_config"/DeviceFarmCLI.properties ]; then
				cp "$WORKSPACE/ci_config"/DeviceFarmCLI.properties $common_config_file_path
				echo "Copying DeviceFarmCLI file successfull"
			fi

			if [ -f "$WORKSPACE/ci_config"/${appidkey}.keystore ]; then
				cp "$WORKSPACE/ci_config"/${appidkey}.keystore $common_config_file_path/ScriptUtils
				echo "Copying keystore file successfull"
			fi
			
			if [ -f "$WORKSPACE/ci_config"/$KCI_PRJ_PROP_XML ]; then
				cp "$WORKSPACE/ci_config"/$KCI_PRJ_PROP_XML $common_config_file_path/ScriptUtils/Prop/$KCI_PRJ_PROP_XML
				echo "Copying projectprop file successfull"
			fi
			
			if [ -f "$WORKSPACE/ci_config"/$KCI_GEN_IPA_TASK_INFOPLIST_CONFIG_PATH ]; then
				cp "$WORKSPACE/ci_config"/$KCI_GEN_IPA_TASK_INFOPLIST_CONFIG_PATH $common_config_file_path/ScriptUtils/xcode_configs/$KCI_GEN_IPA_TASK_INFOPLIST_CONFIG_PATH
				echo "Copying xcode_configs Plist_Config file successfull"
			fi
			
			if [ -f "$WORKSPACE/ci_config"/$KCI_GEN_IPA_TASK_XCODE_EXPORT_OPTIONS_FILE ]; then
				cp "$WORKSPACE/ci_config"/$KCI_GEN_IPA_TASK_XCODE_EXPORT_OPTIONS_FILE $common_config_file_path/ScriptUtils/xcode_configs/$KCI_GEN_IPA_TASK_XCODE_EXPORT_OPTIONS_FILE
				echo "Copying xcode_configs exportOptionsPlist file successfull"
			fi
			
			if [ -f "$WORKSPACE/ci_config"/$IOS_ENTITLEMENTS_FILE ]; then
				cp "$WORKSPACE/ci_config"/$IOS_ENTITLEMENTS_FILE $common_config_file_path/ScriptUtils/xcode_configs/$IOS_ENTITLEMENTS_FILE
				echo "Copying xcode_configs IOS_ENTITLEMENTS_FILE:$IOS_ENTITLEMENTS_FILE file successfull"
			fi
			
			cd "$workspaceNew"
			echo "Removing the old config folder in worksapce"
			rm -rf ci_config
			echo "trying to copy the common ci_config to workspace"
			cp -R "$common_config_file_path" "$WORKSPACE/ci_config"
			echo "Copy the common ci_config to workspace is completed"
		fi
		  
		cd "$workspaceNew/ci_config"

		pwd

		if [ "$executePipeline" = "true" ]; then
			
		 cp $newCommonPropertyFileName $macPropertyFileName
		 cp $newCommonPropertyFileName $winPropertyFileName
		# rm -rf $newCommonPropertyFileName 
		 
		fi
		echo -e "\r\nexecutePipeline=$executePipeline\r\nKCI_MACHINE_LABEL=$KCI_MACHINE_LABEL" >> $newCommonPropertyFileName

		ws_loc=`printenv MAC_workspace.location`
		eclipse_loc=`printenv MAC_eclipse.equinox.path`
		imgMagic_home=`printenv MAC_imagemagic.home`
		and_home=`printenv MAC_android.home`

		if [ "$executePipeline" = "true" ]; then
			ws_loc=`printenv MAC_workspace.location`
			eclipse_loc=`printenv MAC_eclipse.equinox.path`
			imgMagic_home=`printenv MAC_imagemagic.home`
			and_home=`printenv MAC_android.home`
			KCI_MACHINE_LABEL=ios
			echo -e "\r\nworkspace.location=${ws_loc}\r\neclipse.equinox.path=${eclipse_loc}\r\nimagemagic.home=${imgMagic_home}\r\nandroid.home=${and_home}\r\nJENKINS_BASE_HOME=${MAC_JENKINS_BASE_HOME}\r\nCONFIG_FILE=${MAC_CONFIG_FILE}\r\nECLIPSE_LOCATION=${MAC_ECLIPSE_LOCATION}\r\nSTORAGE_LOCATION=${MAC_STORAGE_LOCATION}\r\nPLUGIN_PROPERTIES_FILE=${MAC_PLUGIN_PROPERTIES_FILE}\r\nKCI_PLUGIN_CONFIG_FILES=${MAC_KCI_PLUGIN_CONFIG_FILES}\r\nKCI_PROPERTIES_ROOT_DIRECTORY=$MAC_KCI_PROPERTIES_ROOT_DIRECTORY\r\nKCI_SCRIPTS_DIR=${MAC_KCI_SCRIPTS_DIR}\r\nKCI_PROPS_DIR=${MAC_KCI_PROPS_DIR}\r\nKCI_OTA_TEMP_DIR=${MAC_KCI_OTA_TEMP_DIR}\r\nKCI_WORKSPACE_SUB_FOLDER=${MAC_KCI_WORKSPACE_SUB_FOLDER}" >> $macPropertyFileName
			echo -e "\r\nexecutePipeline=$executePipeline\r\nKCI_MACHINE_LABEL=$KCI_MACHINE_LABEL" >> $macPropertyFileName	
			
			ws_loc=`printenv WIN_workspace.location`
			eclipse_loc=`printenv WIN_eclipse.equinox.path`
			imgMagic_home=`printenv WIN_imagemagic.home`
			and_home=`printenv WIN_android.home`
			KCI_MACHINE_LABEL=windows
			echo -e "\r\nworkspace.location=${ws_loc}\r\neclipse.equinox.path=${eclipse_loc}\r\nimagemagic.home=${imgMagic_home}\r\nandroid.home=${and_home}\r\nJENKINS_BASE_HOME=${WIN_JENKINS_BASE_HOME}\r\nCONFIG_FILE=${WIN_CONFIG_FILE}\r\nECLIPSE_LOCATION=${WIN_ECLIPSE_LOCATION}\r\nSTORAGE_LOCATION=${WIN_STORAGE_LOCATION}\r\nPLUGIN_PROPERTIES_FILE=${WIN_PLUGIN_PROPERTIES_FILE}\r\nKCI_PLUGIN_CONFIG_FILES=${WIN_KCI_PLUGIN_CONFIG_FILES}\r\nKCI_PROPERTIES_ROOT_DIRECTORY=$WIN_KCI_PROPERTIES_ROOT_DIRECTORY\r\nKCI_SCRIPTS_DIR=${WIN_KCI_SCRIPTS_DIR}\r\nKCI_PROPS_DIR=${WIN_KCI_PROPS_DIR}\r\nKCI_OTA_TEMP_DIR=${WIN_KCI_OTA_TEMP_DIR}\r\nKCI_WORKSPACE_SUB_FOLDER=${WIN_KCI_WORKSPACE_SUB_FOLDER}" >> $winPropertyFileName
			echo -e "\r\nexecutePipeline=$executePipeline\r\nKCI_MACHINE_LABEL=$KCI_MACHINE_LABEL" >> $winPropertyFileName
		else 

			if [ "$KCI_MACHINE_LABEL" = "ios" ]; then
				ws_loc=`printenv MAC_workspace.location`
				eclipse_loc=`printenv MAC_eclipse.equinox.path`
				imgMagic_home=`printenv MAC_imagemagic.home`
				and_home=`printenv MAC_android.home`
			else
				ws_loc=`printenv WIN_workspace.location`
				eclipse_loc=`printenv WIN_eclipse.equinox.path`
				imgMagic_home=`printenv WIN_imagemagic.home`
				and_home=`printenv WIN_android.home`
			fi    

			echo "${ws_loc}"
			echo "${eclipse_loc}"
			echo "${imgMagic_home}"
			echo "${and_home}"

			echo -e "\r\nworkspace.location=${ws_loc}\r\neclipse.equinox.path=${eclipse_loc}\r\nimagemagic.home=${imgMagic_home}\r\nandroid.home=${and_home}" >> $newCommonPropertyFileName
			
			if [ "$KCI_MACHINE_LABEL" = "ios" ]; then
				echo -e "\r\nJENKINS_BASE_HOME=${MAC_JENKINS_BASE_HOME}\r\nCONFIG_FILE=${MAC_CONFIG_FILE}\r\nECLIPSE_LOCATION=${MAC_ECLIPSE_LOCATION}\r\nSTORAGE_LOCATION=${MAC_STORAGE_LOCATION}\r\nPLUGIN_PROPERTIES_FILE=${MAC_PLUGIN_PROPERTIES_FILE}\r\nKCI_PLUGIN_CONFIG_FILES=${MAC_KCI_PLUGIN_CONFIG_FILES}\r\nKCI_PROPERTIES_ROOT_DIRECTORY=$MAC_KCI_PROPERTIES_ROOT_DIRECTORY\r\nKCI_SCRIPTS_DIR=${MAC_KCI_SCRIPTS_DIR}\r\nKCI_PROPS_DIR=${MAC_KCI_PROPS_DIR}\r\nKCI_OTA_TEMP_DIR=${MAC_KCI_OTA_TEMP_DIR}\r\nKCI_WORKSPACE_SUB_FOLDER=${MAC_KCI_WORKSPACE_SUB_FOLDER}" >> $newCommonPropertyFileName
			else
				echo -e "\r\nJENKINS_BASE_HOME=${WIN_JENKINS_BASE_HOME}\r\nCONFIG_FILE=${WIN_CONFIG_FILE}\r\nECLIPSE_LOCATION=${WIN_ECLIPSE_LOCATION}\r\nSTORAGE_LOCATION=${WIN_STORAGE_LOCATION}\r\nPLUGIN_PROPERTIES_FILE=${WIN_PLUGIN_PROPERTIES_FILE}\r\nKCI_PLUGIN_CONFIG_FILES=${WIN_KCI_PLUGIN_CONFIG_FILES}\r\nKCI_PROPERTIES_ROOT_DIRECTORY=$WIN_KCI_PROPERTIES_ROOT_DIRECTORY\r\nKCI_SCRIPTS_DIR=${WIN_KCI_SCRIPTS_DIR}\r\nKCI_PROPS_DIR=${WIN_KCI_PROPS_DIR}\r\nKCI_OTA_TEMP_DIR=${WIN_KCI_OTA_TEMP_DIR}\r\nKCI_WORKSPACE_SUB_FOLDER=${WIN_KCI_WORKSPACE_SUB_FOLDER}" >> $newCommonPropertyFileName
			fi
			
		fi
		
		# Deleting the existing property/zip files and Creating a zip file with updated properties.
		 rm -rf $JOB_NAME.tar.gz
		 
		 tar -zcvf $JOB_NAME.tar.gz *
		 
		## DELETING BINARIES FOLDERS IN MASTER 
		if [ "$executePipeline" = "true" ]; then
			echo "executePipeline is true deleting both workspace binaries in ::$KCI_WIN_SLAVE_MAIN_JOB_NAME :: and ::$KCI_MAC_SLAVE_MAIN_JOB_NAME jobs"
				cd "$JENKINS_HOME/jobs/$KCI_WIN_SLAVE_MAIN_JOB_NAME"
				if [ -d "workspace" ]; then
					cd workspace
					pwd
					ls
					rm -rf binaries
				fi

				cd "$JENKINS_HOME/jobs/$KCI_MAC_SLAVE_MAIN_JOB_NAME"
				if [ -d "workspace" ]; then
					cd workspace
					pwd
					ls
					rm -rf binaries
				fi
		else 
			echo "executePipeline is false and KCI_MACHINE_LABEL is ::$KCI_MACHINE_LABEL"
			if [ "$KCI_MACHINE_LABEL" = "ios" ]; then
				cd "$JENKINS_HOME/jobs/$KCI_MAC_SLAVE_MAIN_JOB_NAME"
				if [ -d "workspace" ]; then
					cd workspace
					pwd
					ls
					rm -rf binaries
				fi
			else
				cd "$JENKINS_HOME/jobs/$KCI_WIN_SLAVE_MAIN_JOB_NAME"
				if [ -d "workspace" ]; then
					cd workspace
					pwd
					ls
					rm -rf binaries
				fi
			fi    	
		fi
  else
    echo "The property file $propertyFile not found."
  fi
else
  echo "Wrong number of parameters!!"
fi
