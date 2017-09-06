#!/bin/sh
###############################################################
#                 MainScript		                          #
###############################################################
# Purpose:
# Purpose of this file is to trigger the build on slave,      #
# generate binaries for the RequiredPlatforms and making the  #
#android build signed.
###############################################################

# Adding the input parameter to a local parameter
propertyFile="$1"
EXECUTE_PIPELINE="$2"
BuildMachineOS="$3"
ANDROID_TARGET_SLAVE_IN_PIPELINE="$4"
CLOUD_USERNAME="$5"
CLOUD_PASSWORD="$6"


# Condition to check if the number of parameters passed as input 
# are correct or not
if [ "$#" -eq 6 ]; then
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

    echo "MAC_workspace.location::${MAC_workspace_location}"
    echo "WIN_workspace.location::${WIN_workspace_location}"
    echo "KCI_GEN_IPA_TASK_PRO_PROFILE:: ${KCI_GEN_IPA_TASK_PRO_PROFILE}"
    echo "KCI_GEN_IPA_TASK_PRO_PROFILE_NAME:: ${KCI_GEN_IPA_TASK_PRO_PROFILE_NAME}"

		echo "************************************************************"
		echo "PRE BUILD ACTIVITIES - COPY NECESSARY FILES - START"
		#ws_loc=`printenv workspace.location`
		#ws_loc="${workspace_location}"
		ws_loc="$WORKSPACE/workspace"
		echo "${ws_loc}"
		echo "Printing workspace location :::"$ws_loc
		cd ${ws_loc}

		pwd
		
		eclipse_equinox=`printenv eclipse.equinox.path`
		echo "eclipse_equinox ::$eclipse_equinox"
		imagemagic_home=`printenv imagemagic.home`
		echo "imagemagic_home ::$imagemagic_home"
		android_home=`printenv android.home`
		echo "android_home ::$android_home"
		
		rm HeadlessBuild-Global.properties
		if [ "$KCI_MACHINE_LABEL" = "windows" ]; then
			finalString=$(echo ${ws_loc} | sed 's/\\/\//g')
			echo $finalString
			echo "workspace.location=$finalString" >> HeadlessBuild-Global.properties
		else
			echo "workspace.location=${ws_loc}" >> HeadlessBuild-Global.properties
		fi
		
		echo "eclipse.equinox.path=${eclipse_equinox}" >> HeadlessBuild-Global.properties
		echo "imagemagic.home=${imagemagic_home}" >> HeadlessBuild-Global.properties
		echo "android.home=${android_home}" >> HeadlessBuild-Global.properties

		#cp $JENKINS_BASE_HOME/$KCI_PROPS_DIR/$KCI_GLBL_PROP .
		#cp $JENKINS_BASE_HOME/$KCI_PROPS_DIR/$KCI_TAG_CODE_REVIEW .
		cp $JENKINS_BASE_HOME/$KCI_PROPS_DIR/$KCI_ANT_CTRB .

		cd ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR
		cp $JENKINS_BASE_HOME/$KCI_PROPS_DIR/$KCI_BLD_PROP .
		cp $JENKINS_BASE_HOME/$KCI_PROPS_DIR/$KCI_PRJ_PROP_XML .
		#cp $JENKINS_BASE_HOME/$KCI_PROPS_DIR/$KCI_PRJ_PROP_XML .

		echo "PRE BUILD ACTIVITIES - COPY NECESSARY FILES - END"
		echo "************************************************************"
		
		echo "************************************************************"
		echo "PRE BUILD ACTIVITIES - PERFORM PLUGIN UPGRADE - START"

		cd ${ws_loc}

		#aws s3 cp s3://kony-ci0001-storage1/libraries/kony-appfactory-libraries/PluginUpgrade.jar .
		cp $KCI_PLUGIN_CONFIG_FILES/PluginUpgrade.jar ${ws_loc}

		#Updating the kony plugins based on the plugins defined for respective project.
		#Write the status and visualizer version details in a file.
		java -jar ${ws_loc}/PluginUpgrade.jar ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/konyplugins.xml $STORAGE_LOCATION $DOWNLOAD_URL $STORAGE_URL $fromStorageURL $PLUGINS_FOLDER $ECLIPSE_LOCATION $PLUGIN_PROPERTIES_FILE

		pluginPropertyFile="${PLUGIN_PROPERTIES_FILE}/PLUGIN_DEPENDENCY_STATUS.properties"
		
#		Reading the file to get the visualizer version details for the respective project.
		if [ -f "$pluginPropertyFile" ]; then
			echo "The property file $pluginPropertyFile found."

			while IFS='=' read -r propname propvalue
			do
			  propname=$(echo $propname | tr '.' '_')
			  echo "propname is :::: $propname"
			  echo "propvalue is :::: $propvalue"
			  eval "${propname}='${propvalue}'"
			done < "$pluginPropertyFile"
			echo "Plugins version is :::: $PLUGINS_VERSION"
		else
			echo "The property file $pluginPropertyFile not found."
		fi
		
		echo "PRE BUILD ACTIVITIES - PERFORM PLUGIN UPGRADE - END"
		echo "************************************************************"
		
		# Setting the environment variables according to the slave on which job is triggered.

		echo "************************************************************"
		echo "PRE BUILD ACTIVITIES - SETUP JAVA_HOME and GRADLE_HOME BASED ON PLUGIN VERSION - START"

		#Comparing the plugin version with the base version 7.2.1 and use gradle 2.14.1 with java 8 for the 
		#versions grater or equel to base version.
		###TOCHANGE###
		baseversion="730"
		echo "Plugins version is :::: $PLUGINS_VERSION"
		pluginversion=`echo "${PLUGINS_VERSION//.}"`
		###TOCHANGE###
		#Path settings for windows slave
		if [ "$KCI_MACHINE_LABEL" = "windows" ]; then
			export HOME=D:/cygwin64/bin/bash
			export JAVA_HOME=/cygdrive/d/KonyVisualizerEnterprise7.3.0/Java/jdk1.8.0_112
			echo "Printing JAVA_HOME :: "$JAVA_HOME
			export GRADLE_HOME=D:/KonyVisualizerEnterprise7.3.0/gradle
			echo "Printing GRADLE_HOME :: "$GRADLE_HOME
			export PATH=$PATH:/usr/bin:$JAVA_HOME/bin:$GRADLE_HOME/bin
		fi
		#Path settings for mac slave
		if [ "$KCI_MACHINE_LABEL" == "ios" ]; then
		    export ANT_HOME=/Applications/KonyVisualizerEnterprise7.3.0/Ant
		    echo "Printing Ant Home :: "$ANT_HOME
		    export GRADLE_HOME=/Applications/KonyVisualizerEnterprise7.3.0/gradle
		    echo "Printing GRADLE_HOME :: "$GRADLE_HOME
			cd /Applications/KonyVisualizerEnterprise7.3.0
			#rm -rf gradle
			#if [[ $pluginversion -lt $baseversion ]]; then
			#	cp -R gradleOLD gradle
			#	export JAVA_HOME=/Applications/KonyVisualizerEnterprise7.3.0/jdk1.8.0_112.jdk/Contents/Home
			#else
			#	cp -R gradle-2.14.1 gradle
			#	export JAVA_HOME=/Applications/KonyVisualizerEnterprise7.3.0/jdk1.8.0_112.jdk/Contents/Home
			#fi
			export JAVA_HOME=/Applications/KonyVisualizerEnterprise7.3.0/jdk1.8.0_112.jdk/Contents/Home
		    echo "Printing JAVA_HOME :: "$JAVA_HOME
		    export PATH=$PATH:$ANT_HOME/bin:$JAVA_HOME/bin:$GRADLE_HOME/bin
		    echo "Printing path ::"$PATH
		fi
		
		echo "PRE BUILD ACTIVITIES - SETUP JAVA_HOME and GRADLE_HOME BASED ON PLUGIN VERSION - END"
		echo "************************************************************"
		
		echo "************************************************************"
		echo "PRE BUILD ACTIVITIES - UPDATE GLOBAL PROPERTIES WITH ACTUAL VALUES - START"

		CONFIG_FILE=$propertyFile

		cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		
		# Modifying the HeadlessBuild.properties , HeadlessBuild-Global.properties,
		# projectprop.xml files according to the given parameter values in property file using JAVA

		#java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_GLBL_PROP workspace.location false

		#java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_GLBL_PROP eclipse.equinox.path false

		#java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_GLBL_PROP imagemagic.home false

		#java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_GLBL_PROP android.home false

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP appid false

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP version false

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP android.packagename false

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP middleware_server_ip false

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP middleware_https_port false

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP middleware_web_context false

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP build_mode true

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_PROP $KCI_UPDATE_SINGLE $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP remove_print_statements true

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE appnamekey ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML appnamekey

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE iphonebundleidentifierkey ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML iphonebundleidentifierkey

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE mwaddrkey ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML mwaddrkey

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE appidkey ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML appidkey

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE appversionkey ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML appversionkey

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE appversioncode ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML appversioncode

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE iphonebundleversionkey ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML iphonebundleversionkey

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE build ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML build

		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE removeprintstatements ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML removeprintstatements
		
		java -jar $KCI_UPDATEPROPS_JAR $KCI_UPDATE_XML $KCI_UPDATE_PROJPROPXML $CONFIG_FILE androidmapkey2 ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_PRJ_PROP_XML androidmapkey2

		echo "KCI_UPDATE_HEADLESSBUILD_JAR ::"$KCI_UPDATE_HEADLESSBUILD_JAR
		echo "CONFIG_FILE ::"$CONFIG_FILE
		echo "KCI_BLD_PROP ::"${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP

		java -jar $KCI_UPDATE_HEADLESSBUILD_JAR $CONFIG_FILE ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR/$KCI_BLD_PROP $EXECUTE_PIPELINE $BuildMachineOS $ANDROID_TARGET_SLAVE_IN_PIPELINE $CLOUD_USERNAME $CLOUD_PASSWORD

		echo "PRE BUILD ACTIVITIES - UPDATE GLOBAL PROPERTIES WITH ACTUAL VALUES - END"
		echo "************************************************************"

		echo "************************************************************"
		echo "PRE BUILD ACTIVITIES - PERFORM BUILD FOR TARGETED PLATFORMS - START"

		echo "KCI_UI_LOCAL_MODULE_DIR ::$KCI_UI_LOCAL_MODULE_DIR"

		cd ${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR
		pwd
		$KCI_ANT_CMD #command "ant" is given to trigger the build.
		

		echo "PRE BUILD ACTIVITIES - PERFORM BUILD FOR TARGETED PLATFORMS - END"
		echo "************************************************************"
		
		echo "************************************************************"
		echo "POST BUILD ACTIVITY - CODE SIGN AND GENERATE IPA - START"
		if [ "$KCI_MACHINE_LABEL" == "ios" ]; then

		echo off
			echo "BUILD_FOR_IOS_RC_CLIENT ::$BUILD_FOR_IOS_RC_CLIENT"
			echo "BUILD_FOR_IOS_IPAD_RC_CLIENT ::$BUILD_FOR_IOS_IPAD_RC_CLIENT"
			echo "${ws_loc}"
			project_dir="${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR"
			echo "project_dir ::$project_dir"
			iPhoneBuild="false"  # iPhoneBuild parameter is set to true/false if ipa generation is required for iphone.
			iPadBuild="false"    # iPadBuild parameter is set to true/false if ipa generation is required for ipad. 
			build_Status="true" # build_Status parameter is set to true/false based on the binaries generated.
			
		
	# Read the property file and check for which platforms (iphone/ipad) to be build and correspondingly making the particular parameters defined above as either # true or false.	
	
	if [ $BUILD_FOR_IOS_RC_CLIENT = "true" ]; then
				if [ -d "$project_dir/binaries/iphone" ]; then
					if [ -f "$project_dir/binaries/iphone/$KCI_GEN_IPA_TASK_IOS_ORIG_KAR_FILE_NAME.kar" ]; then
						iPhoneBuild="true"
					else
						build_Status="false"
					fi
				fi
			fi
			
			if [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = "true" ]; then
				if [ -d "$project_dir/binaries/ipad" ]; then
					if [ -f "$project_dir/binaries/ipad/$KCI_GEN_IPA_TASK_IOS_IPAD_ORIG_KAR_FILE_NAME.kar" ]; then
						iPadBuild="true"
					else
						build_Status="false"
					fi
				fi
			fi
			echo "iPhoneBuild after checking for binaries ::$iPhoneBuild"
			echo "iPadBuild after checking for binaries ::$iPadBuild"
			
			#Read the property file and generate the ipa build for iphone/ipad.
			if [ $BUILD_FOR_IOS_RC_CLIENT = "true" ] && [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = "true" ]; then
				cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
				chmod 777 ipaGenerate.sh
				echo "Build required for both iPhone and iPad"
				if [ $BUILD_FOR_IOS_RC_CLIENT = "true" ] && [ $iPhoneBuild = "true" ]; then
					echo "Generating build for iPhone"
					./ipaGenerate.sh  $propertyFile true false $project_dir
				fi
				if [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = "true" ] && [ $iPadBuild = "true" ]; then
					echo "Generating build for iPad"
					./ipaGenerate.sh $propertyFile false true $project_dir
				fi
			else
				echo "Build required for either iPhone or iPad"
				if [ $BUILD_FOR_IOS_RC_CLIENT = "true" ] || [ $BUILD_FOR_IOS_IPAD_RC_CLIENT = "true" ]; then
					if [ $iPhoneBuild = "true" ] || [ $iPadBuild = "true" ]; then
						cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
						chmod 777 ipaGenerate.sh
						./ipaGenerate.sh $propertyFile $BUILD_FOR_IOS_RC_CLIENT $BUILD_FOR_IOS_IPAD_RC_CLIENT $project_dir
					else 
						echo "Unable to find the binaries. Hence stop executing ipa generation"	
					fi	
				fi	
			fi
		else
			echo "Build for iOS is false"
		fi
		
		echo "POST BUILD ACTIVITY - CODE SIGN AND GENERATE IPA - END"
		echo "************************************************************"
		echo off

		echo "************************************************************"
		echo "POST BUILD ACTIVITY - Repackage and generate Android APK - START"

		#Read the property file and check if build for android phone/tab are true or false.
		if [ $BUILD_FOR_ANDROID_RC_CLIENT = "true" ] || [ $BUILD_FOR_ANDROID_TAB_RC_CLIENT = "true" ]; then
		
			echo "${ws_loc}"

			APK_NAME=$(echo ${binaryname}_${PARENT_BUILD_NUMBER})

			BUILD_FOR_ANDROID_MOBILE=$BUILD_FOR_ANDROID_RC_CLIENT
			BUILD_FOR_ANDROID_TABLET=$BUILD_FOR_ANDROID_TAB_RC_CLIENT

			project_dir="${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR"

			## EXECUTE THE FOLLOWING CODE IN CASE OF PIPELINE FOR ANDROID - START

			echo "EXECUTE_PIPELINE ::$EXECUTE_PIPELINE"
			echo "ANDROID_TARGET_SLAVE_IN_PIPELINE ::$ANDROID_TARGET_SLAVE_IN_PIPELINE"
			echo "BuildMachineOS ::$BuildMachineOS"

			if [ $EXECUTE_PIPELINE = "true" ]; then
			  if [ $ANDROID_TARGET_SLAVE_IN_PIPELINE = "ios" ] && [ $BuildMachineOS = "ios" ]; then
				if [ $BUILD_FOR_ANDROID_RC_CLIENT = "true" ]; then
					BUILD_FOR_ANDROID_MOBILE="true"
				fi
				if [ $BUILD_FOR_ANDROID_TAB_RC_CLIENT = "true" ]; then
					BUILD_FOR_ANDROID_TABLET="true"
				fi
			  elif [ $ANDROID_TARGET_SLAVE_IN_PIPELINE = "windows" ] && [ $BuildMachineOS = "windows" ]; then
				if [ $BUILD_FOR_ANDROID_RC_CLIENT = "true" ]; then
					BUILD_FOR_ANDROID_MOBILE="true"
				fi
				if [ $BUILD_FOR_ANDROID_TAB_RC_CLIENT = "true" ]; then
					BUILD_FOR_ANDROID_TABLET="true"
				fi
			  else
				if [ $BUILD_FOR_ANDROID_RC_CLIENT = "true" ]; then
					BUILD_FOR_ANDROID_MOBILE="false"
				fi
				if [ $BUILD_FOR_ANDROID_TAB_RC_CLIENT = "true" ]; then
					BUILD_FOR_ANDROID_TABLET="false"
				fi
			  fi
			fi

			## EXECUTE THE ABOVE CODE IN CASE OF PIPELINE FOR ANDROID - END
			echo "KCI_ANT_MODE is ::$KCI_ANT_MODE"
			echo "BUILD_FOR_ANDROID_MOBILE is ::$BUILD_FOR_ANDROID_MOBILE"
			echo "BUILD_FOR_ANDROID_TABLET is ::$BUILD_FOR_ANDROID_TABLET"
			
			#If the android phone build is true then copy the apk file to the specified location.
			if [ $BUILD_FOR_ANDROID_MOBILE = "true" ]; then
				#cd ${ws_loc}/$KCI_TEMP_DIR/$KCI_UI_LOCAL_MODULE_DIR/$KCI_TEMP_SUB_DIR_1/$KCI_UI_APP_ID
				#$KCI_ANT_CMD $KCI_ANT_MODE
				#mv $project_dir/binaries/android/luavmandroid.apk $project_dir/binaries/android/$APK_NAME.apk
				if [ $KCI_ANT_MODE = "release" ]; then 
					cp "${ws_loc}/temp/$KCI_UI_LOCAL_MODULE_DIR/build/luaandroid/dist/$KCI_UI_LOCAL_MODULE_DIR/build/outputs/apk/$KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk" $project_dir/binaries/android/$KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk

					#If unsigned.apk file exists then copy the keystore and zipalign files to binary folder.
					if [ -f "$project_dir/binaries/android/$KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk" ]; then
						echo "APK for mobile found"
						echo "copying keystore file to binary folder"
						cp $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR/$KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME $project_dir/binaries/android
						echo "copying zipalign file to binary folder"
						
						#Based on the BuildMachineOS zipalign command is been executed.
						if [ $BuildMachineOS = "windows" ]; then
							echo "Executing zipalign command on $BuildMachineOS"
							cp $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR/zipalign.exe $project_dir/binaries/android
						else 
							echo "Executing zipalign command on $BuildMachineOS"
							cp $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR/zipalign $project_dir/binaries/android
						fi
						echo "copying keystore file and zipalign file to binary folder completed "
				
						cd $project_dir/binaries/android
					
						pwd 
						
						echo "Signing Android Mobile APK file - START"
						
						# The "jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore" 
						# command is used to sign the android.apk file.
						jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME -storepass $KCI_ANDROID_SIGNING_KEYSTORE_PASS -keypass $KCI_ANDROID_SIGNING_CERTIFICATE_PASS $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $KCI_ANDROID_SIGNING_KEYSTORE_ALIAS_NAME

						jarsigner -verify -certs $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $KCI_ANDROID_SIGNING_KEYSTORE_ALIAS_NAME 				
						
						if [ -f $APK_NAME.apk ]; then
							rm $APK_NAME.apk
						fi
						
						if [ $BuildMachineOS = "windows" ]; then
							echo "Executing zipalign command on $BuildMachineOS"
							./zipalign.exe -v 4 $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $APK_NAME.apk
						else 
							echo "Executing zipalign command on $BuildMachineOS"
							chmod 777 zipalign
							./zipalign -v 4 $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $APK_NAME.apk
						fi
						rm -rf $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk
						echo "Signing Android Mobile APK file - COMPLETED"
						#$project_dir/binaries/android/$APK_NAME.apk
						
					else
						build_Status="false"
					fi
				else 
					if [ $KCI_ANT_MODE = "debug" ]; then 
						cp "${ws_loc}/temp/$KCI_UI_LOCAL_MODULE_DIR/build/luaandroid/dist/$KCI_UI_LOCAL_MODULE_DIR/build/outputs/apk/$KCI_UI_LOCAL_MODULE_DIR-debug.apk" $project_dir/binaries/android/$APK_NAME.apk
					fi
				fi
			else
				echo "BUILD_FOR_ANDROID_RC_CLIENT property has been set to false, hence skipping Repackaging of APK task"

			fi

			#The below code is been executed if the android tablet build is true.
			# Copy the apk file to the specified location.
			if [ $BUILD_FOR_ANDROID_TABLET = "true" ]; then
				#mv $project_dir/binaries/tabrcandroid/luavmandroid.apk $project_dir/binaries/tabrcandroid/$APK_NAME.apk
				if [ $KCI_ANT_MODE = "release" ]; then 
					cp "${ws_loc}/temp/$KCI_UI_LOCAL_MODULE_DIR/build/luatabrcandroid/dist/$KCI_UI_LOCAL_MODULE_DIR/build/outputs/apk/$KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk" $project_dir/binaries/tabrcandroid/$KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk
					
					#If unsigned.apk file exists then copy the keystore and #
					#zipalign files to binary folder.
					if [ -f "$project_dir/binaries/tabrcandroid/$KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk" ]; then
						echo "APK for tablet is available"
						echo "copying keystore file to binary folder"
						cp $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR/$KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME $project_dir/binaries/tabrcandroid
						echo "copying zipalign file to binary folder"
						if [ $BuildMachineOS = "windows" ]; then
							echo "Executing zipalign command on $BuildMachineOS"
							cp $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR/zipalign.exe $project_dir/binaries/tabrcandroid
						else 
							echo "Executing zipalign command on $BuildMachineOS"
							cp $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR/zipalign $project_dir/binaries/tabrcandroid
						fi

						echo "copying keystore file and zipalign file to binary folder completed "
						
						cd $project_dir/binaries/tabrcandroid
						
						pwd 
						
						echo "Signing Android tablet APK file - START"
						
						#The "jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore" 
						#command is used to sign the android.apk file for android tablet.
						jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME -storepass $KCI_ANDROID_SIGNING_KEYSTORE_PASS -keypass $KCI_ANDROID_SIGNING_CERTIFICATE_PASS $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $KCI_ANDROID_SIGNING_KEYSTORE_ALIAS_NAME

						jarsigner -verify -certs $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $KCI_ANDROID_SIGNING_KEYSTORE_ALIAS_NAME 				
						
						#jarsigner -verbose -keystore $KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME -storepass $KCI_ANDROID_SIGNING_KEYSTORE_PASS $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $KCI_ANDROID_SIGNING_KEYSTORE_ALIAS_NAME
						#jarsigner -verbose -verify -keystore $KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk

						
						if [ -f $APK_NAME.apk ]; then
							rm $APK_NAME.apk
						fi
						
						if [ $BuildMachineOS = "windows" ]; then
							echo "Executing zipalign command on $BuildMachineOS"
							./zipalign.exe -v 4 $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $APK_NAME.apk
						else 
							echo "Executing zipalign command on $BuildMachineOS"
							chmod 777 zipalign
							./zipalign -v 4 $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk $APK_NAME.apk
						fi
						rm -rf $KCI_UI_LOCAL_MODULE_DIR-release-unsigned.apk
						echo "Signing Android tablet APK file - COMPLETED"
					else
						build_Status="false"
					fi
					
				else 
					if [ $KCI_ANT_MODE = "debug" ]; then 
						cp "${ws_loc}/temp/$KCI_UI_LOCAL_MODULE_DIR/build/luatabrcandroid/dist/$KCI_UI_LOCAL_MODULE_DIR/build/outputs/apk/$KCI_UI_LOCAL_MODULE_DIR-debug.apk" $project_dir/binaries/tabrcandroid/$APK_NAME.apk
					fi
				fi
			else
				echo "BUILD_FOR_ANDROID_TAB_RC_CLIENT property has been set to false, hence skipping Repackaging of tablet APK task"
			fi
		else 
		echo "Build for android is false"
		fi
		echo "POST BUILD ACTIVITY - Repackage and generate Android APK - END"
		echo "************************************************************"

		echo "************************************************************"
		echo "POST BUILD ACTIVITY - Repackage WINDOWS Binaries - START"

		echo "${ws_loc}"

		WIN_NAME=$(echo ${binaryname}_${PARENT_BUILD_NUMBER})
		project_dir="${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR"

		#Repacking the windows binaries if build for windows is true.
		if [ $BUILD_FOR_WINDOWS8_RC_CLIENT = "true" ]; then
			mv $project_dir/$KCI_GEN_WINDOWS8_BINARY_DIR/$KCI_GEN_WINDOWS8_ORIG_FILE_NAME $project_dir/$KCI_GEN_WINDOWS8_BINARY_DIR/$WIN_NAME.xap
		else
			build_Status="false"
			echo "BUILD_FOR_WINDOWS8_RC_CLIENT property has been set to false, hence skipping Repackaging of XAP task"
		fi

		if [ $BUILD_FOR_WINDOWS81_RC_CLIENT = "true" ]; then
			mv $project_dir/$KCI_GEN_WINDOWS81_BINARY_DIR/$KCI_GEN_WINDOWS81_ORIG_FILE_NAME $project_dir/$KCI_GEN_WINDOWS81_BINARY_DIR/$WIN_NAME.xap
		else
			build_Status="false"
			echo "KCI_GEN_WINDOWS81_BINARY_DIR property has been set to false, hence skipping Repackaging of XAP task"
		fi

		if [ $BUILD_FOR_WINDOWS81_TAB_RC_CLIENT = "true" ]; then
			mv $project_dir/binaries/windows/windows8/$appid.appx $project_dir/binaries/windows/windows8/$WIN_NAME.appx
		else
			build_Status="false"
			echo "BUILD_FOR_WINDOWS81_TAB_RC_CLIENT property has been set to false, hence skipping Repackaging of XAP task"
		fi
		echo "POST BUILD ACTIVITY - Repackage WINDOWS Binaries - END"
		echo "************************************************************"

		echo "************************************************************"
		echo "Copy artifacts to another folder"

		echo "Workspace Location on slave ::${ws_loc}"
		
	#Condition to check if binaries are not generated and sending emails for the job failure.
	if [ $build_Status = "false" ]; then
		#Code for generating the email if the main job fails.
		#Creating the parameter to assign the index_fail.html file location.
		echo "$PROP_ROOT_DIR/$JOB_NAME"			
		echo "$KCI_PROPERTIES_ROOT_DIRECTORY/$KCI_MAC_SLAVE_INIT_JOB_NAME/notification_templates/index_fail.html"
		Template_FOLDER="$KCI_PROPERTIES_ROOT_DIRECTORY/$KCI_MAC_SLAVE_INIT_JOB_NAME/notification_templates/index_fail.html"
		#Verifying if the $Template_FOLDER exists.
		if [ -f "$Template_FOLDER" ]; then
			echo "$Template_FOLDER exists"
			echo "started copying the index file"
			echo "INDEX1_FILE => $Template_FOLDER"
			#Assinging the values to the index_fail.html.
			sed -i -e 's|$KCI_UI_SVN_PATH|'"$KCI_UI_SVN_PATH"'|g' $Template_FOLDER
			sed -i -e 's|$KCI_UI_GIT_BRANCH|'"$KCI_UI_GIT_BRANCH"'|g' $Template_FOLDER
			sed -i -e 's|$appid|'"$appid"'|g' $Template_FOLDER
			sed -i -e 's|$iphonebundleidentifierkey|'"$iphonebundleidentifierkey"'|g' $Template_FOLDER
			sed -i -e 's|$KCI_GEN_IPA_TASK_DEVELOPER_NAME|'"$KCI_GEN_IPA_TASK_DEVELOPER_NAME"'|g' $Template_FOLDER
			sed -i -e 's|$KCI_GEN_IPA_TASK_PRO_PROFILE_NAME|'"$KCI_GEN_IPA_TASK_PRO_PROFILE_NAME"'|g' $Template_FOLDER
			#Deleting the created index_fail.html-e file.
			rm -f $KCI_PROPERTIES_ROOT_DIRECTORY/$KCI_MAC_SLAVE_INIT_JOB_NAME/notification_templates/index_fail.html-e
		else
			echo "$Template_FOLDER does not exist"
			#echo "Exiting...."
			#exit
		fi
		#End of the code for generating the email if the build fails.
	fi
	#End of the condition to check if binaries are not created and sending emails for job failure.

		project_dir="${ws_loc}/$KCI_UI_LOCAL_MODULE_DIR"

		echo "project_dir ::$project_dir"
		
		echo "Jenkins WORKSPACE ::$WORKSPACE"
		cd $WORKSPACE

		rm -rf binaries

		cp -R $project_dir/binaries $WORKSPACE
		
		if [ $BUILD_FOR_ANDROID_MOBILE = "true" ]; then
			cd  $WORKSPACE/binaries/android
		else 
			if [ $BUILD_FOR_ANDROID_TAB_RC_CLIENT = "true" ]; then
				cd  $WORKSPACE/binaries/tabrcandroid
			fi
		fi
		if [ -f "zipalign" ]; then
			rm -rf zipalign
		fi
		if [ -f "$KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME" ]; then
			rm -rf "$KCI_ANDROID_SIGNING_KEYSTORE_FILE_NAME"
		fi
		if [ -f "luavmandroid.apk" ]; then
			rm -rf luavmandroid.apk
		fi
  else
    echo "The property file $propertyFile not found."
  fi
else
  echo "Wrong number of parameters!!"
fi
