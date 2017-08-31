#!/bin/sh
propertyFile="$1"
PARENT_JOB_NAME="$2"
PARENT_BUILD_NUMBER="$3"
if [ "$#" -eq 3 ]; then
  echo "Correct number of parameters"
  if [ -f "$propertyFile" ]; then
    echo "The property file $propertyFile found."

    while IFS='=' read -r key value
    do
      key=$(echo $key | tr '.' '_')
      eval "${key}='${value}'"
    done < "$propertyFile"
		echo "************************************************************"
		echo "Archive and Enable OTA - ACTIVITIES START"

		echo "PARENT_BUILD_NUMBER ::"${PARENT_BUILD_NUMBER}
		echo "PARENT_JOB_NAME ::"${PARENT_JOB_NAME}
		echo "propertyFile ::"${propertyFile}

		#ws_loc=`printenv workspace.location`
		#echo "${ws_loc}"
		#echo "Printing workspace location :::"$ws_loc

		IPA_NAME=$(echo ${binaryname}_${PARENT_BUILD_NUMBER}.ipa)
		APK_NAME=$(echo ${binaryname}_${PARENT_BUILD_NUMBER}.apk)
		WIN_NAME=$(echo ${binaryname}_${PARENT_BUILD_NUMBER}.xap) 

		echo "IPA_NAME ::$IPA_NAME"
		echo "APK_NAME ::$APK_NAME"
		echo "WIN_NAME ::$WIN_NAME"

		IPA_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
		AND_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
		WIN_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_WIN_SLAVE_MAIN_JOB_NAME\\workspace"

		AND_TAB_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
		
		echo "IPA_BINARY_FOLDER ::$IPA_BINARY_FOLDER"
		echo "AND_BINARY_FOLDER ::$AND_BINARY_FOLDER"
		echo "WIN_BINARY_FOLDER ::$WIN_BINARY_FOLDER"

		# CHECKING FOR MOBILES
		
		if [ $EXECUTE_PIPELINE = true ]; then
			AND_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
		else
			if [ $BUILD_FOR_IOS_RC_CLIENT = true ]; then
				AND_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
			else 
				if [[ ! -z $ENGIE_WIN_SLAVE_INIT_JOB_NAME ]];then
					echo "Windows job exists. Redirecting android build to Win Slave"
					AND_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_WIN_SLAVE_MAIN_JOB_NAME\\workspace"
				else
					echo "Windows job does not exists. Redirecting android build to Mac Slave"
					AND_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
				fi
			fi
		fi	
		
		# CHECKING FOR TABLETS
		if [ $EXECUTE_PIPELINE = true ]; then
			AND_TAB_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
		else
			if [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = true ]; then
				AND_TAB_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
			else 
				if [[ ! -z $ENGIE_WIN_SLAVE_INIT_JOB_NAME ]];then
					echo "Windows job exists. Redirecting android build to Win Slave"
					AND_TAB_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_WIN_SLAVE_MAIN_JOB_NAME\\workspace"
				else
					echo "Windows job does not exists. Redirecting android build to Mac Slave"
					AND_TAB_BINARY_FOLDER="$JENKINS_HOME\\jobs\\$ENGIE_MAC_SLAVE_MAIN_JOB_NAME\\workspace"
				fi
			fi
			
		fi

		OTA_PUBLISH_URL=$ENGIE_CI_S3_BASE_URL

		#if [ $ENGIE_CI_ENABLE_S3_PUBLISH = "true" ]; then
		#	OTA_PUBLISH_URL=$ENGIE_CI_S3_BASE_URL
		#else 
		#	OTA_PUBLISH_URL=$ENGIE_OTA_SERVER_URL
		#fi

		echo "OTA_PUBLISH_URL ::"$OTA_PUBLISH_URL

		BUILD_DETAILS=""

		if [ $BUILD_FOR_IOS_RC_CLIENT = "true" ] || [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = "true" ]; then
		BUILD_DETAILS="<B>GIT_PATH:-</B>$ENGIE_UI_SVN_PATH</Br><B>GIT_BRANCH:-</B>$ENGIE_UI_GIT_BRANCH</Br><B>APPLICATION_ID:-</B>$appid</Br><B>IPHONEBUNDLEKEY:-</B>$iphonebundleidentifierkey</Br><B>IPA_PROVISIONING_PROFILE:-</B>$ENGIE_CI_GEN_IPA_TASK_PRO_PROFILE_NAME</Br>"
		else
		BUILD_DETAILS="<B>GIT_PATH:-</B>$ENGIE_UI_SVN_PATH</Br><B>GIT_BRANCH:-</B>$ENGIE_UI_GIT_BRANCH</Br><B>APPLICATION_ID:-</B>$appid</Br>"
		fi

		#BUILD_DETAILS="<B>GIT_PATH:-</B>$ENGIE_UI_SVN_PATH</Br><B>GIT_BRANCH:-</B>$ENGIE_UI_GIT_BRANCH</Br><B>APPLICATION_ID:-</B>$appid</Br><B>IPHONEBUNDLEKEY:-</B>$iphonebundleidentifierkey</Br>"

		echo "BUILD Details ::$BUILD_DETAILS"
		echo "setting build details done"

		CHANNELS=""
		echo "Initial value of CHANNELS:: $CHANNELS"
		if [ $BUILD_FOR_IOS_RC_CLIENT = "true" ]; then
		  if [ "$CHANNELS" = "" ]; then
			CHANNELS+="iphone"
		  else
			CHANNELS+=",iphone"
		  fi
		fi
		#echo "1 CHANNELS:: $CHANNELS"
		if [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = "true" ]; then
		  if [ "$CHANNELS" = "" ]; then
			CHANNELS+="ipad"
		  else
			CHANNELS+=",ipad"
		  fi
		fi
		#echo "2 CHANNELS:: $CHANNELS"
		if [ $BUILD_FOR_ANDROID_RC_CLIENT = "true" ]; then
		  if [ "$CHANNELS" = "" ]; then
			CHANNELS+="android"
		  else
			CHANNELS+=",android"
		  fi
		fi
		#echo "3 CHANNELS:: $CHANNELS"
		if [ $BUILD_FOR_ANDROID_TAB_RC_CLIENT = "true" ]; then
		  if [ "$CHANNELS" = "" ]; then
			CHANNELS+="androidT"
		  else
			CHANNELS+=",androidT"
		  fi
		fi
		#echo "4 CHANNELS:: $CHANNELS"
		if [ $BUILD_FOR_WINDOWS8_RC_CLIENT = "true" ]; then
		  if [ "$CHANNELS" = "" ]; then
			CHANNELS+="win8"
		  else
			CHANNELS+=",win8"
		  fi
		fi
		#echo "5 CHANNELS:: $CHANNELS"
		if [ $BUILD_FOR_WINDOWS81_RC_CLIENT = "true" ]; then
		  if [ "$CHANNELS" = "" ]; then
			CHANNELS+="win81"
		  else
			CHANNELS+=",win81"
		  fi
		fi
		#echo "6 CHANNELS:: $CHANNELS"
		if [ $BUILD_FOR_WINDOWS10_RC_CLIENT = "true" ]; then
		  if [ "$CHANNELS" = "" ]; then
			CHANNELS+="win10"
		  else
			CHANNELS+=",win10"
		  fi
		fi
		echo "CHANNELS:: $CHANNELS"

		echo "Parent Job Name :: ${PARENT_JOB_NAME} :: Build Number :: $PARENT_BUILD_NUMBER" 
		echo "ENGIE_CI_ANT_MODE ::$ENGIE_CI_ANT_MODE"
		
		#Parameter to direct to the notification templates for index_orig.html file which is used to generate email for
		#successful build
		SCRIPTUTILS_FOLDER="$JENKINS_HOME\\jobs\\$KICKSTARTER_JOB_NAME\\workspace\\ci_config\\ScriptUtils\\Prop"
		NOTIFICATION_FOLDER="$JENKINS_HOME\\jobs\\$KICKSTARTER_JOB_NAME\\workspace\\ci_config\\notification_templates"

		cd "$JENKINS_HOME\\jobs\\$KICKSTARTER_JOB_NAME\\workspace\\ci_config\\ScriptUtils"
		 
		 tr -d '\r\f' <ArchiveAndEnableOTA.sh >ArchiveAndEnableOTANew.sh
		 
		 rm -rf ArchiveAndEnableOTA.sh
		 
		 mv ArchiveAndEnableOTANew.sh ArchiveAndEnableOTA.sh

		if [ $ENGIE_CI_ANT_MODE = "debug" ]; then
		 #$ENGIE_CI_PWR_SHELL_EXEC_CMD $ENGIE_CI_ENABLE_OTA $PARENT_JOB_NAME $binaryname $PARENT_BUILD_NUMBER $WIN_ENGIE_OTA_TEMP_DIR $PARENT_JOB_NAME ${ws_loc}/$ENGIE_UI_LOCAL_MODULE_DIR/$ENGIE_CI_GEN_IPA_TASK_IOS_BINARY_DIR $IPA_NAME ${ws_loc}/$ENGIE_UI_LOCAL_MODULE_DIR/binaries/android $APK_NAME $JENKINS_BASE_HOME/$ENGIE_CI_PROPS_DIR $iphonebundleidentifierkey $ENGIE_UI_APP_ID $CHANNELS $BUILD_DETAILS $ENGIE_CI_S3_BASE_URL $ENGIE_CI_S3_SUB_FOLDER_URL $ENGIE_CI_S3_OTA_URL
		 echo "Ant mode is ::ENGIE_CI_ANT_MODE"
		 $ENGIE_CI_PWR_SHELL_EXEC_CMD $ENGIE_CI_ENABLE_OTA $PARENT_JOB_NAME $binaryname $binaryname $PARENT_BUILD_NUMBER $WIN_ENGIE_OTA_TEMP_DIR $PARENT_JOB_NAME "$IPA_BINARY_FOLDER/$ENGIE_CI_GEN_IPA_TASK_IOS_BINARY_DIR" $IPA_NAME "$IPA_BINARY_FOLDER/$ENGIE_CI_GEN_IPA_TASK_IOS_IPAD_BINARY_DIR" $IPA_NAME "$AND_BINARY_FOLDER/binaries/android" $APK_NAME "$AND_TAB_BINARY_FOLDER/binaries/tabrcandroid" $APK_NAME "$WIN_BINARY_FOLDER/$ENGIE_CI_GEN_WINDOWS8_BINARY_DIR" $WIN_NAME "$WIN_BINARY_FOLDER/$ENGIE_CI_GEN_WINDOWS81_BINARY_DIR" $WIN_NAME "$SCRIPTUTILS_FOLDER" $iphonebundleidentifierkey $ENGIE_UI_APP_ID $CHANNELS $BUILD_DETAILS $ENGIE_CI_S3_BASE_URL $ENGIE_CI_S3_SUB_FOLDER_URL $ENGIE_CI_S3_OTA_URL $EXECUTE_PIPELINE $BuildMachineOS $ANDROID_TARGET_SLAVE_IN_PIPELINE "$NOTIFICATION_FOLDER"
		else
		 #cd $JENKINS_BASE_HOME/$ENGIE_CI_SCRIPTS_DIR
		 #$ENGIE_CI_PWR_SHELL_EXEC_CMD $ENGIE_CI_ENABLE_OTA $PARENT_JOB_NAME $binaryname $PARENT_BUILD_NUMBER $WIN_ENGIE_OTA_TEMP_DIR $PARENT_JOB_NAME ${ws_loc}/$ENGIE_UI_LOCAL_MODULE_DIR/$ENGIE_CI_GEN_IPA_TASK_IOS_BINARY_DIR $IPA_NAME ${ws_loc}/$ENGIE_UI_LOCAL_MODULE_DIR/binaries/android $APK_NAME $JENKINS_BASE_HOME/$ENGIE_CI_PROPS_DIR $iphonebundleidentifierkey $ENGIE_UI_APP_ID $CHANNELS $BUILD_DETAILS $ENGIE_CI_S3_BASE_URL $ENGIE_CI_S3_SUB_FOLDER_URL $ENGIE_CI_S3_OTA_URL
		 echo "Ant mode is ::ENGIE_CI_ANT_MODE"
		 $ENGIE_CI_PWR_SHELL_EXEC_CMD $ENGIE_CI_ENABLE_OTA $PARENT_JOB_NAME $binaryname $binaryname $PARENT_BUILD_NUMBER $WIN_ENGIE_OTA_TEMP_DIR $PARENT_JOB_NAME "$IPA_BINARY_FOLDER/$ENGIE_CI_GEN_IPA_TASK_IOS_BINARY_DIR" $IPA_NAME "$IPA_BINARY_FOLDER/$ENGIE_CI_GEN_IPA_TASK_IOS_IPAD_BINARY_DIR" $IPA_NAME "$AND_BINARY_FOLDER/binaries/android" $APK_NAME "$AND_TAB_BINARY_FOLDER/binaries/tabrcandroid" $APK_NAME "$WIN_BINARY_FOLDER/$ENGIE_CI_GEN_WINDOWS8_BINARY_DIR" $WIN_NAME "$WIN_BINARY_FOLDER/$ENGIE_CI_GEN_WINDOWS81_BINARY_DIR" $WIN_NAME "$SCRIPTUTILS_FOLDER" $iphonebundleidentifierkey $ENGIE_UI_APP_ID $CHANNELS $BUILD_DETAILS $ENGIE_CI_S3_BASE_URL $ENGIE_CI_S3_SUB_FOLDER_URL $ENGIE_CI_S3_OTA_URL $EXECUTE_PIPELINE $BuildMachineOS $ANDROID_TARGET_SLAVE_IN_PIPELINE "$NOTIFICATION_FOLDER"
		fi

		echo "Archive and Enable OTA - ACTIVITIES END"
		echo "************************************************************"
  else
    echo "The property file $propertyFile not found."
  fi
else
  echo "Wrong number of parameters!!"
fi
