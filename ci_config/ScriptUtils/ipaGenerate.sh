###############################################################
#                       ipaGenerate		              #
###############################################################
# Purpose:
# Purpose of this file to generate the ipa for iOS_build.     #
###############################################################

#Adding the input parameters to the local parameters.
propertyFile="$1"
iPhoneBuild="$2"
iPadBuild="$3"
projectDir="$4"

echo "This sh file contain the code for ipa generation"

# Condition to check if the number of parameters passed as input 
# are correct or not
if [ "$#" -eq 4 ]; then
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
		echo "projectDir from input ::$projectDir"
		
		#Local parameters are created for the generation of ipa. 
		project_dir="$projectDir"
		TagName="$binaryname"
		IPA_BUILD_NUMBER="$PARENT_BUILD_NUMBER"
		ios_binary_dir="$KCI_GEN_IPA_TASK_IOS_BINARY_DIR"
		ios_kar_orig_file_name="$KCI_GEN_IPA_TASK_IOS_ORIG_KAR_FILE_NAME"
		TARGET_SDK="$KCI_GEN_IPA_TASK_TARGET_SDK"
		PKG_PLTFRM="$KCI_GEN_IPA_TASK_PKG_PLTFRM"
		channels="iPhone"
		bundlekey=""
		echo "iPhoneBuild ::$iPhoneBuild"
		echo "iPadBuild ::$iPadBuild"
		
		#Condition to check if the build is either for iphone or ipad
		if [ $iPadBuild = "true" ]; then
			ios_binary_dir="$KCI_GEN_IPA_TASK_IOS_IPAD_BINARY_DIR"
			ios_kar_orig_file_name="$KCI_GEN_IPA_TASK_IOS_IPAD_ORIG_KAR_FILE_NAME"
			TARGET_SDK="$KCI_GEN_IPA_IPAD_TASK_TARGET_SDK"
			PKG_PLTFRM="$KCI_GEN_IPA_IPAD_TASK_PKG_PLTFRM"
			channels="iPad"
			bundlekey="$ipadbundleidentifierkey"
			#"$KCI_GEN_IPA_TASK_CHANNELS"
		elif [ $iPhoneBuild = "true" ]; then
			ios_binary_dir="$KCI_GEN_IPA_TASK_IOS_BINARY_DIR"
			ios_kar_orig_file_name="$KCI_GEN_IPA_TASK_IOS_ORIG_KAR_FILE_NAME"
			TARGET_SDK="$KCI_GEN_IPA_TASK_TARGET_SDK"
			PKG_PLTFRM="$KCI_GEN_IPA_TASK_PKG_PLTFRM"
			channels="iPhone"
			bundlekey="$iphonebundleidentifierkey"
		fi

		#Local parameters are created and assigned with values from the property file.

		mac_pwd="$KCI_GEN_IPA_TASK_MAC_PWD"
		jenkins_autofiles_dir="$KCI_GEN_IPA_TASK_AUTOMATION_FILES_PATH"
		#Updated below properties with new values to accomodate the latest script changes
		#xcode_updater_jar="$XCODE_CONFIG_UPDATER_JAR"
		#infoPlistConfig_file="$INFOPLIST_CONFIG_FILE"
		#xcodeConfig_file="Config.properties"
		xcode_updater_jar="$KCI_GEN_IPA_TASK_XCODE_UPDATER_JAR"
		infoPlistConfig_file="$KCI_GEN_IPA_TASK_INFOPLIST_CONFIG_PATH"
		exportOptionsPlist_file="$KCI_GEN_IPA_TASK_XCODE_EXPORT_OPTIONS_FILE"
		xcodeConfig_file="$KCI_GEN_IPA_TASK_XCODE_CONFIG_PATH"
		# the entitlements file need to be added to the projects root folder when your project requries any entitlements.
		entitlements_file="$IOS_ENTITLEMENTS_FILE"

		echo "****************Renaming the orginal KAR file************"
		echo "Source is => $project_dir/$ios_binary_dir/$ios_kar_orig_file_name.KAR"
		renamed_iphone_installer=$(echo $TagName | tr -d '\r')_$(echo $IPA_BUILD_NUMBER | tr -d '\r')
		echo "renamed_iphone_installer => $renamed_iphone_installer"
		echo "Target is => $project_dir/binaries/iphone/$renamed_iphone_installer.KAR"
		renamed_iphone_kar=$(echo $renamed_iphone_installer | tr -d '\r')"FunctionalModule"
		build_folder=$(echo "build"$IPA_BUILD_NUMBER | tr -d '\r')
		build_artifex=$(echo "buildArtifex"$IPA_BUILD_NUMBER | tr -d '\r')

		#Checking for the condition whether the build is for ipad or iphone and moving the kar files to a specified location.

		if [ $iPadBuild = "true" ]; then
			mv $project_dir/$KCI_GEN_IPA_TASK_IOS_IPAD_BINARY_DIR/$KCI_GEN_IPA_TASK_IOS_IPAD_ORIG_KAR_FILE_NAME.KAR $project_dir/$KCI_GEN_IPA_TASK_IOS_IPAD_BINARY_DIR/$renamed_iphone_installer.KAR
		elif [ $iPhoneBuild = "true" ]; then
			mv $project_dir/$KCI_GEN_IPA_TASK_IOS_BINARY_DIR/$KCI_GEN_IPA_TASK_IOS_ORIG_KAR_FILE_NAME.KAR $project_dir/$KCI_GEN_IPA_TASK_IOS_BINARY_DIR/$renamed_iphone_installer.KAR
		fi

		echo "****************** Renamed KAR file *********************"

		echo "********************"
		
		#Creating the local parameters with the values from the propertyFile required for ipa generation.

		Plugin_version="$KCI_GEN_IPA_TASK_MAC_IOS_PLUGINS"
		echo "Plugin_version => ${Plugin_version}"
		APP_NAME="$binaryname"
		echo "APP_NAME => ${APP_NAME}"
		echo "IPA_BUILD_NUMBER => ${IPA_BUILD_NUMBER}"
		ipa_name="$renamed_iphone_installer"
		echo "ipa_name => ${ipa_name}.ipa"
		kar_name="$renamed_iphone_installer"
		echo "kar_name => ${kar_name}.KAR"
		DIR="$KCI_GEN_IPA_TASK_MAC_PLUGIN_PATH"
		echo "DIR => ${DIR}"
		BUILDDIR="$KCI_GEN_IPA_TASK_MAC_DIR_FOR_BUILDS"
		echo "BUILDDIR => ${BUILDDIR}"
		JENKINS_BUILD_DIR="$KCI_GEN_IPA_TASK_JENKINS_BUILD_DIR"
		echo "JENKINS_BUILD_DIR => ${JENKINS_BUILD_DIR}"
		JENKINS_OUTPUT_BINARY_DIR="$KCI_GEN_IPA_TASK_JENKINS_OUTPUT_BINARY_DIR"
		echo "JENKINS_OUTPUT_BINARY_DIR => ${JENKINS_OUTPUT_BINARY_DIR}"
		PROJECT_NAME="$KCI_GEN_IPA_TASK_PROJECT_NAME"
		echo "PROJECT_NAME => ${PROJECT_NAME}"
		echo "TARGET_SDK => ${TARGET_SDK}"
		SCHEME="$KCI_GEN_IPA_TASK_SCHEME"
		echo "SCHEME => ${SCHEME}"
		DEVELOPER_NAME="$IPHONE_IOS_DEVELOPER_NAME"
		echo "DEVELOPER_NAME => ${DEVELOPER_NAME}"
		PRO_PROFILE_FILE="$IPHONE_IOS_PRO_PROFILE_FILE"
		echo "PRO_PROFILE_FILE => ${PRO_PROFILE_FILE}"
		OUTPUT_PATH="$KCI_GEN_IPA_TASK_OUTPUT_PATH"
		echo "OUTPUT_PATH => ${OUTPUT_PATH}"
		echo "PKG_PLTFRM => ${PKG_PLTFRM}"
		KEYCHAIN="$KCI_GEN_IPA_TASK_KEYCHAIN"
		echo "KEYCHAIN => ${KEYCHAIN}"
		CODESIGN_ALLOCATE="$KCI_GEN_IPA_TASK_CODESIGN_ALLOCATE"
		echo "CODESIGN_ALLOCATE => ${CODESIGN_ALLOCATE}"
		MAC_PWD="$KCI_GEN_IPA_TASK_MAC_PWD"
		echo "MAC_PWD => ${MAC_PWD}"
		DEVELOPER_DIR="$KCI_GEN_IPA_TASK_DEVELOPER_DIR"
		echo "DEVELOPER_DIR => ${DEVELOPER_DIR}"
		RELEASE_CONF="$KCI_GEN_IPA_TASK_RELEASE_CONF"
		echo "RELEASE_CONF => ${RELEASE_CONF}"
		PRO_PROFILE_NAME="$IPHONE_IOS_PRO_PROFILE_NAME"
		echo "PRO_PROFILE_NAME => ${PRO_PROFILE_NAME}"
		DEVELOPMENT_TEAM="${IPHONE_IOS_DEVELOPMENT_TEAM}"
		echo "DEVELOPMENT_TEAM => ${DEVELOPMENT_TEAM}"
		PROVISIONING_PROFILE="${IPHONE_IOS_PRO_PROFILE}"
		echo "PROVISIONING_PROFILE => ${PROVISIONING_PROFILE}"
		PROVISIONING_PROFILE_NAME="${IPHONE_IOS_PRO_PROFILE_NAME}"
		echo "PROVISIONING_PROFILE => ${PROVISIONING_PROFILE_NAME}"
		#Added below assignment for handling new variable
		IOS_DEPLOYMENT_TARGET="${KCI_GEN_IPA_IOS_DEPLOYMENT_TARGET}"
		echo "IOS_DEPLOYMENT_TARGET => ${IOS_DEPLOYMENT_TARGET}"
		PROJDIR=$(echo $DIR | tr -d '\r')/$(echo $Plugin_version | tr -d '\r')
		echo "PROJDIR => ${PROJDIR}"
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		echo "**************"
		GENDIR=$(echo $DIR | tr -d '\r')/$(echo $Plugin_version | tr -d '\r')/gen
		echo "GENDIR => ${GENDIR}"
		
		# Setting profile and code signing properties for iPadBuild
		if [ $iPadBuild = "true" ]; then
			DEVELOPER_NAME="$IPAD_IOS_DEVELOPER_NAME"
			echo "DEVELOPER_NAME => ${DEVELOPER_NAME}"
			PRO_PROFILE_FILE="$IPAD_IOS_PRO_PROFILE_FILE"
			echo "PRO_PROFILE_FILE => ${PRO_PROFILE_FILE}"
			PRO_PROFILE_NAME="$IPAD_IOS_PRO_PROFILE_NAME"
			echo "PRO_PROFILE_NAME => ${PRO_PROFILE_NAME}"
			DEVELOPMENT_TEAM="${IPAD_IOS_DEVELOPMENT_TEAM}"
			echo "DEVELOPMENT_TEAM => ${DEVELOPMENT_TEAM}"
			PROVISIONING_PROFILE="${IPAD_IOS_PRO_PROFILE}"
			echo "PROVISIONING_PROFILE => ${PROVISIONING_PROFILE}"
			PROVISIONING_PROFILE_NAME="${IPAD_IOS_PRO_PROFILE_NAME}"
			echo "PROVISIONING_PROFILE_NAME => ${PROVISIONING_PROFILE_NAME}"
		fi
		
		#New code for creating the jenkins build folder with binaries sub folder (if not already existing) and then remove ipa files and kar files from binaries folder and also remove the trigger file from jenkins build folder and copy the latest trigger file from the build machine. For now it is assumed that the trigger file is part of the ci script files folder on build machine. later on all these files can be moved to the svn itself and pulled as needed
		##START

		
		#Condition to check if Jenkins_build directory exists and delete older ipa,kar and trigger files else create new directory. 

		echo "Checking if Jenkins_build directory exists, if not create the same along with sub directory binaries. Delete older ipa, kar and trigger files."
		######mkdir -p $JENKINS_OUTPUT_BINARY_DIR; cd $JENKINS_OUTPUT_BINARY_DIR; rm -f *.ipa; rm -f *.KAR; cd $JENKINS_BUILD_DIR
		
		cd $JENKINS_OUTPUT_BINARY_DIR;
		echo "Verify the build directories in Jenkins Output Directory"
		#ls -ltra
		## Remove old binaries before new ones generated
		if [ -d "$JOB_NAME" ]; then
			rm -rf $JOB_NAME/*
		fi
		echo "verify the build directories after removing"
		#ls -ltra
		cd $JENKINS_BUILD_DIR
		##; rm -f $trigger_file
		echo "Done with initial cleanup"

		#echo "Copy latest trigger file"
		#cp $trigger_file $JENKINS_BUILD_DIR
		#echo "Done with copying trigger file"

		echo "Modifying the plugin folder"
		if [ -d "${DIR}" ]; then
			echo "${DIR} found"
			cd ${DIR}
				echo "Files in the folder"
				ls
				echo "Deleting files in the folder"
				rm -rf *
				echo "Clean completed"

			#Modifying and copying the plugins folder.		
	
			echo "Copying the ios plugin to folder"
			        # Commenting for now 16June2018 and adding a different line below
				#cp $ECLIPSE_LOCATION/plugins/com.kony.ios_*.jar "${DIR}"
				#cp /Users/Shared/Jenkins/Home/tempPlugins/iOS-GA-*.zip "${DIR}"
				#If using custom plugin (Ex:Korea) use the custom plugin, else use generic iOS plugin
				if [ $KCI_USE_CUSTOM_PLUGIN = "true" ]; then
				  echo "Copying the ios plugin from Custom Plugin folder"
				  cp $JENKINS_BASE_HOME/$KCI_CUSTOM_PLUGIN_PATH/iOS-GA-*.zip "${DIR}" 
				else
				  echo "Copying the ios plugin from Viz Plugin folder"
				  cp $ECLIPSE_LOCATION/plugins/com.kony.ios_*.jar "${DIR}"
				fi
				
			echo "Copying the ios plugin to folder completed"
			
			cd ${DIR}
			echo "PWD --> "${DIR}
			
			#Moving .jar file to plugin.zip file and Unzipping of the plugin jar
			#commenting below line june 16 2018
			#mv com.kony.ios_*.jar plugin.zip
			#tar -vxf plugin.zip
			#tar -vxf iOS-GA-*.zip
			if [ $KCI_USE_CUSTOM_PLUGIN = "true" ]; then
			 tar -xf iOS-GA-*.zip 
			else
			 mv com.kony.ios_*.jar plugin.zip
			 tar -xf plugin.zip
			 # Start : Updated the code 8x support
			 mv plugin.zip plugin.jar
			 tar -xf *.zip
			 # End : Updated the code 8x support
			fi			
			
			
			
			echo "Completed Unzip of plugin jar"
			pwd
			ls
		fi

		echo "Checking if Automation Files directory exists, if exists then remove files else create the same "
		if [ -d "${DIR}/AutomationFiles" ]
		then
			echo "Directory present"
			rm *
			cd ${DIR}
			mkdir -p "AutomationFiles";
		else
			cd ${DIR}
			mkdir -p "AutomationFiles";
		fi

		cd $jenkins_autofiles_dir

		#Copying the latest Xcode settings updated jar file, Info.plist and Xcode config file.

		echo "Copy latest Xcode settings updater jar file"
		cp $jenkins_autofiles_dir/$xcode_updater_jar ${DIR}/AutomationFiles
		echo "Done with copying Xcode settings updater jar file"

		echo "Copy latest Info.Plist config file"
		cp $jenkins_autofiles_dir/$infoPlistConfig_file ${DIR}/AutomationFiles
		echo "Done with copying Info.Plist config file"
		## Added the below line as Xcode options for Export to IPA is changed from Xcode7 (Optional) and from Xcode8.3(mandatory)
		echo "Copy latest exportOptionsPlist config file"
		cp $jenkins_autofiles_dir/$exportOptionsPlist_file ${DIR}/AutomationFiles
		echo "Done with copying exportOptionsPlist config file named:$exportOptionsPlist_file"

		if [ -f "${JENKINS_OUTPUT_BINARY_DIR}/$renamed_iphone_installer.KAR" ]
		then
			rm -rf ${JENKINS_OUTPUT_BINARY_DIR}/$renamed_iphone_installer.KAR
		fi
		cp $project_dir/$ios_binary_dir/$renamed_iphone_installer.KAR $JENKINS_OUTPUT_BINARY_DIR

		echo "Copy required KAR and automation files to folders complete"
		echo "**********************************************************"

		echo "Checking if the PBProj temp folder exists"
		if [ -d "${DIR}/PBProjTemp" ]
		then
			echo "Temp directory found checking for file"
			
				#Xcode project settings are in project.pbxproj file.
				#Checking if the propery file of Xcode exists and copying project.pbxproj. 
				if [ -f "${DIR}/PBProjTemp/project.pbxproj" ]
					then
					echo "File exists in the folder. Removing the existing file"
					rm -f ${DIR}/PBProjTemp/project.pbxproj
					echo "Copying project.pbxproj from ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj to ${DIR}/PBProjTemp"
					cp ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj ${DIR}/PBProjTemp
				else
					echo "File not found copying the file"
					echo "Copying project.pbxproj from ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj to ${DIR}/PBProjTemp"
					cp ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj ${DIR}/PBProjTemp
				fi
		else
			echo "Folder not found creating directory for first time"
			mkdir -p ${DIR}/PBProjTemp
			echo "Copying project.pbxproj from ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj to ${DIR}/PBProjTemp"
			cp ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj ${DIR}/PBProjTemp
		fi

		echo "Done copying original project.pbxproj back to plugin folder"

		echo "Checking timestamp before starting KAR extraction"

		echo `date +%T\ `

		cd $JENKINS_OUTPUT_BINARY_DIR
		echo "The current directory is `pwd`"
		lzldkar_name="${kar_name}"

		if [ -f "${lzldkar_name}.KAR" ]
		then
			echo "$lzldkar_name.KAR found."
			if [ -d "${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}" ]; then
				rm -rf ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}
			fi
			mkdir -p ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}
			if [ -f "${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${lzldkar_name}.KAR" ]	
			then
				rm -rf ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${lzldkar_name}.KAR
			fi
			echo "Moving $lzldkar_name.KAR to ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}"
			mv $lzldkar_name.KAR ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/$lzldkar_name.KAR
		else
			echo "$lzldkar_name.KAR not found."
		fi
		echo "changing directory to gen directory"
		
		cd $(echo $GENDIR | tr -d '\r')
		echo "The current directory is `pwd`"
		echo "**********Printing the perl extract command"

		echo "running perl extract command - existing one"

		PERLEXTRACTCMD="perl extract.pl $(echo ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER} | tr -d '\r')/$(echo $lzldkar_name | tr -d '\r').KAR KCI"
		echo "${PERLEXTRACTCMD}"
		$PERLEXTRACTCMD
		echo ""

		echo "Checking timestamp after extraction of KAR and before XCode changes"

		echo `date +%T\ `
		
		###Added to remove ^M chars in the script file as it gives the below Error
		###/bin/sh^M: bad interpreter: No such file or directory
		###START####
		cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		tr -d '\r\f' <AddFiles.sh >AddFilesNew.sh
		rm -rf AddFiles.sh 
		mv AddFilesNew.sh AddFiles.sh
		
		chmod 777 AddFiles.sh 
		
		tr -d '\r\f' <AddImportText.sh >AddImportTextNew.sh
		rm -rf AddImportText.sh 
		mv AddImportTextNew.sh AddImportText.sh
		
		chmod 777 AddImportText.sh 
		###END####
		
		if [ "$KCI_USE_ASSET_CATALOG" = '' ]; then
			KCI_USE_ASSET_CATALOG="false" 
		fi
		 
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "EIA_APAC" ]; then
		  echo "EXEC_ADDNL_TASKS_FOR_REGION has been set to $EXEC_ADDNL_TASKS_FOR_REGION"
		  echo "Starting additional activities specific for EIA-APAC region builds"   
		  ## Replacing the files in AppDelegateExtension folder with the contents of AppDelegateExtension.zip file 
		  #Switching to scripts directory
		  cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		  #ls
		  #chmod 777 AppDelegateFilesReplace.sh 
		  chmod 777 AddFiles.sh 
		  
		  #Replacing files in AppDelegateExtension folder
		  #./AppDelegateFilesReplace.sh ${PROJDIR} $jenkins_autofiles_dir AppDelegateExtension.zip
		  ./AddFiles.sh $KCI_GEN_IPA_TASK_MAC_PLUGIN_PATH VMAppWithKonylib true $jenkins_autofiles_dir AppDelegateExtension.zip
		  #Adding Framework files
		  #Check if the "nativebinding" folder and its subfolder "Libraries" exist under VMAppWithKonylib folder and if not create the folders
		 	# if [ -d "${PROJDIR}/nativebinding/Libraries" ]; then
		    	#  echo "${PROJDIR}/nativebinding/Libraries folder exists!"
		    	#  echo "Adding the framework files"
		    	#  ./AddFiles.sh ${PROJDIR}/nativebinding Libraries true $jenkins_autofiles_dir Tealium.zip
		  	# else
		    #echo "${PROJDIR}/nativebinding/Libraries folder does not exists!"
		    #echo "Creating the missing folders.."
		    #mkdir -p ${PROJDIR}/nativebinding/Libraries
		    #if [ -d "${PROJDIR}/nativebinding/Libraries" ]; then
		    #  echo "Adding the framework files"
		    #  ./AddFiles.sh ${PROJDIR}/nativebinding Libraries true $jenkins_autofiles_dir Tealium.zip
			# else
		     # echo "Could not create the missing folders.."
		  #  fi
		  #fi
		  #ls
		  ####Renaming the Bridging Header with App Id instead of App name as App Name can be in Non-English chars - Start
		  #mv "${PROJDIR}/FFI/*-Bridging-Header.h" "${PROJDIR}/FFI/$TGT_HDR_FILE_NAME"
		  #cd "${PROJDIR}/FFI"
		  #for file in *-Bridging-Header.h
		  #  do
		  #	mv -v "$file" "AmwayJapan-Bridging-Header.h"
		   # done
		  ####End
		  #Switching to scripts directory
		  cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		  ## Adding import header statements in the targeted header file
		  chmod 777 AddImportText.sh
		  ###Added to remove ^M chars in the script file
		  sed -i '' 's/^M$//' AddImportText.sh 
		  #Adding import header statements in the targeted header file (information picked from config)
		  ./AddImportText.sh "${PROJDIR}/FFI/$TGT_HDR_FILE_NAME" "$IMPORT_HDR_FILE_NAMES"
		  #Adding "AppIdKey""-Swift.h" as an import statement for one of the files
		  #echo "Adding $KCI_UI_APP_ID-Swift.h as import statement in DownloadWrapper.m"
		  #./AddImportText.sh ${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m "$KCI_UI_APP_ID-Swift.h"
		  #Replacing the temporary header with AppIdKey
		  echo "Replacing the temporary header with AppIdKey"
		  #June 17 2018 replacing below line with 2 lines below that to make the replacement generic
		  #sed -i -e 's|amwayapp-Swift.h|'"$KCI_UI_APP_NAME"-Swift.h'|g' ${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m
		  #removing existing import statement
		  sed -i '' '/#import.*-Swift.h/d' ${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m
		  #adding new import statement based on config
          	  ./AddImportText.sh "${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m" "$KCI_UI_APP_NAME/$KCI_UI_APP_NAME-Swift.h"
		  echo "If found, remove temporary file created"
		  cd ${PROJDIR}/FFI/downloadffi/downloadffi
		  rm -rf DownloadWrapper.m-e
		  echo "Done cleanup of file"
		  #echo "Replacing the App Name in all generated .m files inside FFI folder"
		  #cd ${PROJDIR}/FFI
		  #find ./ -type f -exec sed -i '' "s:$KCI_UI_APP_NAME:$KCI_UI_APP_NAME/$KCI_UI_APP_NAME:g" {} \;
		  echo "Done with additional activities specific for EIA-APAC region builds"   
		fi
		##New Code for Handling LAS Project
		##START
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "LAS" ]; then
		  echo "EXEC_ADDNL_TASKS_FOR_REGION has been set to $EXEC_ADDNL_TASKS_FOR_REGION"
		  echo "Starting additional activities specific for $EXEC_ADDNL_TASKS_FOR_REGION region builds"   
		  ## Replacing the files in AppDelegateExtension folder with the contents of AppDelegateExtension.zip file 
		  #Switching to scripts directory
		  cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		  #ls
		  chmod 777 AddFiles.sh 
		  #Replacing files in AppDelegateExtension folder
		  #./AppDelegateFilesReplace.sh ${PROJDIR} $jenkins_autofiles_dir AppDelegateExtension.zip
		  ./AddFiles.sh $KCI_GEN_IPA_TASK_MAC_PLUGIN_PATH VMAppWithKonylib true $jenkins_autofiles_dir AppDelegateExtension.zip
		  
		  ## Adding import header statements in the targeted header file
		  #Switching to scripts directory
		  cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		  #Adding import header statements in the targeted header file (information picked from config)
		  ./AddImportText.sh "${PROJDIR}/FFI/$TGT_HDR_FILE_NAME" "$IMPORT_HDR_FILE_NAMES"

		  echo "Replacing the temporary header with AppIdKey"
		  #removing existing import statement
		  sed -i '' '/#import.*-Swift.h/d' ${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m
		  #adding new import statement based on config
                  ./AddImportText.sh "${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m" "$KCI_UI_APP_NAME/$KCI_UI_APP_NAME-Swift.h"
		  echo "If found, remove temporary file created"
		  cd ${PROJDIR}/FFI/downloadffi/downloadffi
		  rm -rf DownloadWrapper.m-e
		  echo "Done cleanup of file"
		  #echo "Replacing the App Name in all generated .m files inside FFI folder"
		  #cd ${PROJDIR}/FFI
		  #find ./ -type f -exec sed -i '' "s:$KCI_UI_APP_NAME:$KCI_UI_APP_NAME/$KCI_UI_APP_NAME:g" {} \;
		  echo "Done with additional activities specific for Amway $EXEC_ADDNL_TASKS_FOR_REGION builds"  
		fi
		##END
		##New Code for Handling CN Project
		##START
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "CN_DH" ]; then
		  echo "EXEC_ADDNL_TASKS_FOR_REGION has been set to $EXEC_ADDNL_TASKS_FOR_REGION"
		  echo "Starting additional activities specific for $EXEC_ADDNL_TASKS_FOR_REGION region builds"

		  cd "${PROJDIR}/FFI"
		  mv -v "JSMessageCenterIOSMsgCenterFFIFFIClass.m" "JSMessageCenterIOSMsgCenterFFIFFIClass.mm"
		  		  
		  if [[ "$KCI_GEN_IPA_USE_COCOAPODS" != '' && $KCI_GEN_IPA_USE_COCOAPODS = "true" ]]; then	
		      echo "Installing Pods - Start"
		      cd ${PROJDIR}
		      pod install
		      echo "Installing Pods - End"
		  fi

		  echo "Done with additional activities specific for Amway $EXEC_ADDNL_TASKS_FOR_REGION builds"  
		fi
		##END
		##New Code for Handling CN- Content Hub  Project
		##START
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "CN_CH" ]; then
		  echo "EXEC_ADDNL_TASKS_FOR_REGION has been set to $EXEC_ADDNL_TASKS_FOR_REGION"
		  echo "Starting additional activities specific for $EXEC_ADDNL_TASKS_FOR_REGION region builds"   
		  ## Replacing the files in AppDelegateExtension folder with the contents of AppDelegateExtension.zip file 
		  #Switching to scripts directory
		  cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		  #ls
		  chmod 777 AddFiles.sh 
		  #Replacing files in AppDelegateExtension folder
		  #./AppDelegateFilesReplace.sh ${PROJDIR} $jenkins_autofiles_dir AppDelegateExtension.zip
		  #./AddFiles.sh $KCI_GEN_IPA_TASK_MAC_PLUGIN_PATH VMAppWithKonylib true $jenkins_autofiles_dir AppDelegateExtension.zip
		  
		  ## Adding import header statements in the targeted header file
		  #Switching to scripts directory
		  cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		  #Adding import header statements in the targeted header file (information picked from config)
		  ./AddImportText.sh "${PROJDIR}/FFI/$TGT_HDR_FILE_NAME" "$IMPORT_HDR_FILE_NAMES"

		  echo "Replacing the temporary header with AppIdKey"
		  #removing existing import statement
		  sed -i '' '/#import.*-Swift.h/d' ${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m
		  #adding new import statement based on config
                  ./AddImportText.sh "${PROJDIR}/FFI/downloadffi/downloadffi/DownloadWrapper.m" "$KCI_UI_APP_NAME/$KCI_UI_APP_NAME-Swift.h"
		  echo "If found, remove temporary file created"
		  cd ${PROJDIR}/FFI/downloadffi/downloadffi
		  rm -rf DownloadWrapper.m-e
		  echo "Done cleanup of file"
		  #echo "Replacing the App Name in all generated .m files inside FFI folder"
		  #cd ${PROJDIR}/FFI
		  #find ./ -type f -exec sed -i '' "s:$KCI_UI_APP_NAME:$KCI_UI_APP_NAME/$KCI_UI_APP_NAME:g" {} \;
		  
		  if [[ "$KCI_GEN_IPA_USE_COCOAPODS" != '' && $KCI_GEN_IPA_USE_COCOAPODS = "true" ]]; then	
		      echo "Installing Pods - Start"
		      cd ${PROJDIR}
		      pod install
		      echo "Installing Pods - End"
		  fi
		  echo "Done with additional activities specific for Amway $EXEC_ADDNL_TASKS_FOR_REGION builds"  
		fi
		##END
		#New Code for Handling Tealium for NA Project
		###START
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "NA" ]; then
		  echo "EXEC_ADDNL_TASKS_FOR_REGION has been set to $EXEC_ADDNL_TASKS_FOR_REGION"
		  echo "Starting additional activities specific for NA region builds"   	  	  
		fi		
		###END
		
		#Adding Asset Catalog files in VMAppWithKonylib folder if Asset catalog param is true
		echo "KCI_USE_ASSET_CATALOG:$KCI_USE_ASSET_CATALOG"
		if [ $KCI_USE_ASSET_CATALOG = "true" ]; then
			cd $JENKINS_BASE_HOME/$KCI_SCRIPTS_DIR
		  	echo "Adding the Asset Catalog folder"
			./AddFiles.sh $KCI_GEN_IPA_TASK_MAC_PLUGIN_PATH VMAppWithKonylib true $jenkins_autofiles_dir Assets.zip
		fi
		
                #Converting the project.pbxproj and the Info.plist to the appropriate .xml files for better understanding.		
		###Making changes to the Xcode - Info.Plist and Xcode settings
		echo "Making changes to the Xcode - Info.Plist and Xcode settings"
		echo "Converting XCode project to XML"
		plutil -convert xml1 -o ${DIR}/AutomationFiles/XCodeCurBuildProperties.xml  ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj

		echo "Converting Info plist file to XML"
		plutil -convert xml1 -o ${DIR}/AutomationFiles/currBuildInfoPlistXml.xml  ${PROJDIR}/Info.plist

		
		#Modifying the project.pbxproj , Info.plist files according to the parameter values in property file using JAVA.	
		cd ${DIR}/AutomationFiles/
		echo "Removing the existing Config.properties file"
		rm -f ${DIR}/AutomationFiles/Config.properties
		# Passing empty string the entitlements file when IOS_ENTITLEMENTS_REQUIRED is false.
		if [ $IOS_ENTITLEMENTS_REQUIRED = "false" ]; then
			entitlements_file="";
			IOS_ENTITLEMENTS_CAPABILITIES_LIST=false;
			echo "Passing empty entitlements file:$entitlements_file"
		fi
		
		#Creating a new file Config.properties and Adding the required buid settings to the file as the tool below takes the values from property file and modifies the build settings.
		echo "Creating the Config.properties file with required properties"
		echo "IPHONEOS_DEPLOYMENT_TARGET=$IOS_DEPLOYMENT_TARGET"
		echo 'IPHONEOS_DEPLOYMENT_TARGET='"${IOS_DEPLOYMENT_TARGET}"''
		echo "Printing configuration values 1"
		echo 'IPHONEOS_DEPLOYMENT_TARGET='"${IOS_DEPLOYMENT_TARGET}"'\r\nONLY_ACTIVE_ARCH=NO\r\nGCC_OPTIMIZATION_LEVEL=s\r\nINFOPLIST_FILE=Info.plist\r\nOTHER_CFLAGS=-fstack-protector\r\nOTHER_LDFLAGS=-all_load,-ObjC,$(SQL_LIBRARY),$(DATAVIZ_LIBRARY),-lc++,$(PROTECTION_LIBRARY),$(ARXAN_OTHERFLAGS),-framework,JavaScriptCore'
		
		#Start: Code changes for V8 and V7 specific projects.
		if [ $KCI_VISUALIZER_VERSION = "V8" ]; then
			echo 'IPHONEOS_DEPLOYMENT_TARGET='"${IOS_DEPLOYMENT_TARGET}"'\r\nONLY_ACTIVE_ARCH=NO\r\nGCC_OPTIMIZATION_LEVEL=s' >> $xcodeConfig_file
		else
			echo 'IPHONEOS_DEPLOYMENT_TARGET='"${IOS_DEPLOYMENT_TARGET}"'\r\nONLY_ACTIVE_ARCH=NO\r\nGCC_OPTIMIZATION_LEVEL=s\r\nINFOPLIST_FILE=Info.plist\r\nOTHER_CFLAGS=-fstack-protector\r\nOTHER_LDFLAGS=-all_load -ObjC $(SQL_LIBRARY) $(DATAVIZ_LIBRARY) -lc++ $(PROTECTION_LIBRARY) $(ARXAN_OTHERFLAGS) -framework JavaScriptCore' >> $xcodeConfig_file
		fi
		#End: Code changes for V8 and V7 specific projects.
		
		#echo 'IPHONEOS_DEPLOYMENT_TARGET='"${IOS_DEPLOYMENT_TARGET}"'\r\nONLY_ACTIVE_ARCH=NO\r\nGCC_OPTIMIZATION_LEVEL=s\r\nINFOPLIST_FILE=Info.plist\r\nOTHER_CFLAGS=-fstack-protector\r\nOTHER_LDFLAGS=-all_load -ObjC $(SQL_LIBRARY) $(DATAVIZ_LIBRARY) -lc++ $(PROTECTION_LIBRARY) $(ARXAN_OTHERFLAGS) -framework JavaScriptCore' >> $xcodeConfig_file
		#echo 'IPHONEOS_DEPLOYMENT_TARGET='"${IOS_DEPLOYMENT_TARGET}"'\r\nONLY_ACTIVE_ARCH=NO\r\nGCC_OPTIMIZATION_LEVEL=s' >> $xcodeConfig_file
		echo "Printing configuration values 2"
		echo "CODE_SIGN_ENTITLEMENTS=$entitlements_file\r\nPROVISIONING_PROFILE=$PROVISIONING_PROFILE\r\nPROVISIONING_PROFILE_NAME=$PROVISIONING_PROFILE_NAME\r\nPROVISIONING_PROFILE[sdk\=iphoneos*]=$PROVISIONING_PROFILE\r\nCODE_SIGN_IDENTITY=$DEVELOPER_NAME\r\nCODE_SIGN_IDENTITY[sdk\=iphoneos*]=$DEVELOPER_NAME\r\nDEVELOPMENT_TEAM=$DEVELOPMENT_TEAM"
		echo "CODE_SIGN_ENTITLEMENTS=$entitlements_file\r\nPROVISIONING_PROFILE=$PROVISIONING_PROFILE\r\nPROVISIONING_PROFILE_NAME=$PROVISIONING_PROFILE_NAME\r\nPROVISIONING_PROFILE[sdk\=iphoneos*]=$PROVISIONING_PROFILE\r\nCODE_SIGN_IDENTITY=$DEVELOPER_NAME\r\nCODE_SIGN_IDENTITY[sdk\=iphoneos*]=$DEVELOPER_NAME\r\nDEVELOPMENT_TEAM=$DEVELOPMENT_TEAM" >> $xcodeConfig_file
		#Add additional parameters for tasks specific to EIA, APAC
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "EIA_APAC" ]; then
		   echo "Adding extra parameters for EIA, APAC projects"	
		   #echo "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES\r\nCLANG_ENABLE_MODULES=YES\r\nSWIFT_OBJC_BRIDGING_HEADER=FFI/$TGT_HDR_FILE_NAME\r\nSWIFT_VERSION=4.0\r\nGCC_C_LANGUAGE_STANDARD=compiler-default" >> $xcodeConfig_file
		   echo "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES\r\nCLANG_ENABLE_MODULES=YES\r\nSWIFT_OBJC_BRIDGING_HEADER=FFI/$TGT_HDR_FILE_NAME\r\nSWIFT_SWIFT3_OBJC_INFERENCE=On\r\nSWIFT_VERSION=4.0\r\nGCC_C_LANGUAGE_STANDARD=compiler-default" >> $xcodeConfig_file
		   #echo "Verify if any App Name Translation is required::$KCI_UI_APP_NAME_TRANSLATION"
			#if [ "$KCI_UI_APP_NAME_TRANSLATION" != '' ]; then	
				#echo "PRODUCT_MODULE_NAME=$KCI_UI_APP_NAME\r\n" >> $xcodeConfig_file
				#echo "PRODUCT_NAME=$KCI_UI_APP_NAME_TRANSLATION\r\n" >> $xcodeConfig_file
			#fi
		fi
		#Add additional parameters for tasks specific to only EIA
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "EIA" ]; then
		    echo "Adding extra parameters for EIA projects"
		    echo "CLANG_ENABLE_MODULES=YES" >> $xcodeConfig_file
		fi
		#Add additional parameters for tasks specific to LAS
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "LAS" ]; then
		   echo "Adding extra parameters for LAS project"	
		   echo "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES\r\nCLANG_ENABLE_MODULES=YES\r\nSWIFT_OBJC_BRIDGING_HEADER=FFI/$TGT_HDR_FILE_NAME\r\nSWIFT_VERSION=4.0\r\nGCC_C_LANGUAGE_STANDARD=compiler-default" >> $xcodeConfig_file
		fi
		#Add additional parameters for tasks specific to NA
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "NA" ]; then
		   echo "Adding extra parameters for NA projects"
		   echo "GCC_C_LANGUAGE_STANDARD=compiler-default\r\nCLANG_ENABLE_MODULES=YES" >> $xcodeConfig_file
		fi
		
		
		#Add additional parameters for tasks specific to CN
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "CN" ]; then
		   echo "Adding extra parameters for CN projects"
		   echo "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES\r\nCLANG_ENABLE_MODULES=YES\r\nSWIFT_SWIFT3_OBJC_INFERENCE=On\r\nGCC_C_LANGUAGE_STANDARD=compiler-default" >> $xcodeConfig_file
		fi
		
		#Add additional parameters for tasks specific to CN
		if [ $EXEC_ADDNL_TASKS_FOR_REGION = "CN_CH" ]; then
		    echo "Adding extra parameters for CN projects"
		    #echo "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES\r\nCLANG_ENABLE_MODULES=YES\r\nSWIFT_SWIFT3_OBJC_INFERENCE=On\r\nGCC_C_LANGUAGE_STANDARD=compiler-default" >> $xcodeConfig_file
            echo "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES\r\nCLANG_ENABLE_MODULES=YES\r\nSWIFT_SWIFT3_OBJC_INFERENCE=On\r\nSWIFT_OBJC_BRIDGING_HEADER=FFI/$TGT_HDR_FILE_NAME\r\nGCC_C_LANGUAGE_STANDARD=gnu99\r\nCLANG_CXX_LANGUAGE_STANDARD=gnu++14" >> $xcodeConfig_file
		fi
		echo "KCI_USE_ASSET_CATALOG:$KCI_USE_ASSET_CATALOG"
		echo "KCI_CATALOG_LAUNCHIMAGE_NAME::$KCI_CATALOG_LAUNCHIMAGE_NAME"
		#Added below for Referencing Launch Image from Asset catalog if not provided in Visualizer
		if [[ "$KCI_CATALOG_LAUNCHIMAGE_NAME" != '' && $KCI_USE_ASSET_CATALOG = "true" ]]; then		
 		  	echo "Adding the Launch Image Reference from Asset Catalog"		
 			echo "ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME=$KCI_CATALOG_LAUNCHIMAGE_NAME" >> $xcodeConfig_file		
 		fi
		
		echo "KCI_GEN_IPA_UNIVERSAL_APP::$KCI_GEN_IPA_UNIVERSAL_APP"
		#Added below for generating Universal IPA app 
		if [[ "$KCI_GEN_IPA_UNIVERSAL_APP" != '' && $KCI_GEN_IPA_UNIVERSAL_APP = "true" ]]; then		
 		  	echo "Adding the setting for generating universal app"		
 			echo "TARGETED_DEVICE_FAMILY=1,2" >> $xcodeConfig_file		
 		fi
		
		echo "Running the xCode Automation tool to make the xCode and Info.Plist changes"
		#java -jar xCodeAutomation.jar "$infoPlistConfig_file" currBuildInfoPlistXml.xml XCodeCurBuildProperties.xml "$xcodeConfig_file" "$KCI_GEN_IPA_TASK_XCODE_VERSION" $IOS_ENTITLEMENTS_REQUIRED "$entitlements_file" "$bundlekey"
                #Added new parameter due to the additional checks for EIA 
		#java -jar xCodeAutomation.jar "$infoPlistConfig_file" currBuildInfoPlistXml.xml XCodeCurBuildProperties.xml "$xcodeConfig_file" "$KCI_GEN_IPA_TASK_XCODE_VERSION" $IOS_ENTITLEMENTS_REQUIRED "$entitlements_file" "$bundlekey" "$EXEC_ADDNL_TASKS_FOR_EIA_APAC"
		#Made changes to accomodate region specific flag "EIA_APAC", "NA" being sent as values based on whether EXEC_ADDNL_TASKS_FOR_EIA_APAC or EXEC_ADDNL_TASKS_FOR_NA is set to true or false
		#By default left empty, so if these tasks are not assigned for that region/country then the value will be empty
		EXEC_REGIONAL_TASKS_FOR="$EXEC_ADDNL_TASKS_FOR_REGION"

		if [ $IOS_ENTITLEMENTS_REQUIRED = "true" ]; then
			if [ "$IOS_ENTITLEMENTS_CAPABILITIES_LIST" == '' ]; then
				$IOS_ENTITLEMENTS_CAPABILITIES_LIST = "false"
			fi
		fi
		### Making a copy of the XCode Properties for verification
		cp -r XCodeCurBuildProperties.xml XCodeCurBuildProperties_b4convert.xml
		
		java -jar xCodeAutomation.jar "$infoPlistConfig_file" currBuildInfoPlistXml.xml XCodeCurBuildProperties.xml "$xcodeConfig_file" "$KCI_GEN_IPA_TASK_XCODE_VERSION" "$IOS_ENTITLEMENTS_CAPABILITIES_LIST" "$entitlements_file" "$bundlekey" "$EXEC_REGIONAL_TASKS_FOR" "$KCI_VISUALIZER_VERSION"
		
		#Converting the .xml files of xcode project settings to project.pbxproj and Info.plist.
		
		cd ${PROJDIR}/
		echo "Converting Xcode XML to XCode project"
		plutil -convert xml1 -o ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj ${DIR}/AutomationFiles/XCodeCurBuildProperties.xml

		echo "Converting Info.Plist XML to Info.Plist Plist file"
		plutil -convert xml1 -o ${PROJDIR}/Info.plist ${DIR}/AutomationFiles/currBuildInfoPlistXml.xml
		echo "Completed modifying Xcode settings!!!"


		#Added below for showing Unicode characters in App name
		if [[ "$KCI_GEN_IPA_UNICODE_APP_NAME" != '' && $KCI_GEN_IPA_UNICODE_APP_NAME = "true" ]]; then
			echo "Setting Unicode characters for App name as::$KCI_UI_APP_NAME"
		    $KCI_PLISTBUDDY_HOME -c "print :objects:1D6058950D05DD3E006BFB54:buildSettings:KONY_PRODUCT_NAME" ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj
            $KCI_PLISTBUDDY_HOME -c "set :objects:1D6058950D05DD3E006BFB54:buildSettings:KONY_PRODUCT_NAME $KCI_UI_APP_NAME" ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj
			
			echo "Setting Unicode characters for SWIFT_OBJC_BRIDGING_HEADER as::FFI/$TGT_HDR_FILE_NAME"
            $KCI_PLISTBUDDY_HOME -c "print :objects:1D6058950D05DD3E006BFB54:buildSettings:SWIFT_OBJC_BRIDGING_HEADER" ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj
            $KCI_PLISTBUDDY_HOME -c "set :objects:1D6058950D05DD3E006BFB54:buildSettings:SWIFT_OBJC_BRIDGING_HEADER FFI/$TGT_HDR_FILE_NAME" ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj
		fi


		# Copying the entitlements file to the projects root folder when IOS_ENTITLEMENTS_REQUIRED is true.
		if [ $IOS_ENTITLEMENTS_REQUIRED = "true" ]; then
			echo "Copy entitlements file to project directory"
			cp $jenkins_autofiles_dir/$entitlements_file ${PROJDIR}
			echo "Done with copying entitlements file"
		fi

		echo "The current directory is `pwd`"
		echo "export command start"
		echo "CODESIGN_ALLOCATE => ${CODESIGN_ALLOCATE}"
		EXPCODESIGNCMD="export CODESIGN_ALLOCATE=$(echo $CODESIGN_ALLOCATE | tr -d '\r')"
		$EXPCODESIGNCMD
		echo "export command end"
		echo "%%%%%%%%%%%%%%%%CODE to be tested below %%%%%%%%%%%%%%%%%%"
		#cd ${BUILDDIR}
		cd $(echo $BUILDDIR | tr -d '\r')
		#cd /Users/KCI/Desktop/plugins/
		echo "The current directory is `pwd`"
		echo "executing rm -rf command on 'build' folder"
		#rm -rf build
		rm -rf $(echo "build" | tr -d '\r')
		echo "executing rm -rf command on 'Installers' folder"
		#rm -rf Installers
		rm -rf $(echo "Installers" | tr -d '\r')
		#echo "executing mkdir command on 'Installers' folder"
		mkdir $(echo "Installers" | tr -d '\r')
		echo "Listing keychains available"
		#SECLISTKEYCHAINS=$(echo "security list-keychains -d system -s $KEYCHAIN" | tr -d '\r')
		SECLISTKEYCHAINS="security -v list-keychains -d system -s $(echo $KEYCHAIN | tr -d '\r')"
		echo "SECLISTKEYCHAINS => ${SECLISTKEYCHAINS}"
		$SECLISTKEYCHAINS
		echo "attempting to unlock security on keychain"
		#SECUNLOCKKEYCHAIN=$(echo "security unlock-keychain -p citi $KEYCHAIN" | tr -d '\r')
		SECUNLOCKKEYCHAIN="security unlock-keychain -p $(echo $MAC_PWD | tr -d '\r') $(echo $KEYCHAIN | tr -d '\r')"
		echo "SECUNLOCKKEYCHAIN => ${SECUNLOCKKEYCHAIN}"
		$SECUNLOCKKEYCHAIN
		#security -v list-keychains -d system -s /Users/KCI/Library/Keychains/login.keychain
		#security unlock-keychain -p citi /Users/KCI/Library/Keychains/login.keychain
		echo "**********************************"
		echo "done attempting to unlock security on keychain"
		echo "exporting xcode path as DEVELOPER_DIR environment variable - START"
		echo "DEVELOPER_DIR => ${DEVELOPER_DIR}"
		echo "exporting xcode path as DEVELOPER_DIR environment variable - END"
		EXPDEVDIRCMD="export DEVELOPER_DIR=$(echo $DEVELOPER_DIR | tr -d '\r')"
		$EXPDEVDIRCMD

		echo "Checking timestamp after XCode changes and before XCode build"

		echo `date +%T\ `
		
		##Step 1 - Xcode Clean

		if [[ "$KCI_GEN_IPA_USE_COCOAPODS" != '' && $KCI_GEN_IPA_USE_COCOAPODS = "true" ]]; then
		    echo "Performing xcodebuild workspace clean with target ${PROJECT_NAME} and sdk as ${TARGET_SDK} and configuration as ${RELEASE_CONF}"
		    xcodebuild clean -workspace ${PROJDIR}/VMAppWithKonylib.xcworkspace -configuration ${RELEASE_CONF} -scheme ${SCHEME} -sdk "${TARGET_SDK}"
		else
		    echo "Performing xcodebuild project clean with target ${PROJECT_NAME} and sdk as ${TARGET_SDK} and configuration as ${RELEASE_CONF}"
		    xcodebuild clean -project ${PROJDIR}/VMAppWithKonylib.xcodeproj -configuration ${RELEASE_CONF} -target "${PROJECT_NAME}" -sdk "${TARGET_SDK}"
		fi
		
		##Step 2 - Create Xcode Archive
		
		if [[ "$KCI_GEN_IPA_USE_COCOAPODS" != '' && $KCI_GEN_IPA_USE_COCOAPODS = "true" ]]; then
		    echo "Performing xcodebuild Archive with workspace ${PROJDIR}/VMAppWithKonylib.xcworkspace and archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive"
		    echo "${PROJDIR}/VMAppWithKonylib.xcworkspace -scheme ${SCHEME} -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive"
		    xcodebuild archive -workspace ${PROJDIR}/VMAppWithKonylib.xcworkspace -scheme ${SCHEME} -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive #> /dev/null
		else
		    echo "Performing xcodebuild Archive with project ${PROJDIR}/VMAppWithKonylib.xcodeproj and archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive"
		    echo "${PROJDIR}/VMAppWithKonylib.xcodeproj -scheme ${SCHEME} -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive"
		    xcodebuild archive -project ${PROJDIR}/VMAppWithKonylib.xcodeproj -scheme ${SCHEME} -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive #> /dev/null
		fi
		echo "#########Archive is Done############\n"
		
		##Step 3 - Export Xcode Archive and Generate IPA
		##echo "Performing xcodebuild Export with project archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive, exportPath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${ipa_name} and exportProvisioningProfile ${PRO_PROFILE_NAME}"
		##xcodebuild -exportArchive -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive -exportPath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${ipa_name} -exportFormat IPA -exportProvisioningProfile "${PRO_PROFILE_NAME}"
		echo "Performing xcodebuild Export with project archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive, exportPath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${ipa_name} and exportOptionsPlist ${exportOptionsPlist_file}"
		## Start - Added the below line as Xcode options for Export to IPA is changed from Xcode7 (Optional) and from Xcode8.3(mandatory)
		## Now the IPA is created as KRelease.ipa or KDebug.ipa based on the Target selected. so it needs to be renamed
		xcodebuild -exportArchive -exportOptionsPlist  ${DIR}/AutomationFiles/$exportOptionsPlist_file -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive -exportPath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER} #> /dev/null
		echo "#########Export is Done############\n"
		mv ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.ipa ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${ipa_name}.ipa
		##End of change

		echo "Checking timestamp after XCode build"

		echo `date +%T\ `

		#echo "checking if the pb.proj file exists in folder "
		#Condition to check if project.pbxproj exists before copying the updated project.pbxproj file or else delete if the file exists
		#if [ -f "${DIR}/PBProjTemp/project.pbxproj" ]
		#	then
		#	echo "file found removing file before copying new one"
		#	cp ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj ${DIR}/PBProjTemp/projectbackup.pbxproj
		#	rm -f ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj
		#	cp ${DIR}/PBProjTemp/project.pbxproj  ${PROJDIR}/VMAppWithKonylib.xcodeproj
		#fi
		#echo "Done copying original project.pbxproj to AutomationFiles folder"
		echo "Making zip of DSYM files"

		cd ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}
		zip -qr buildArtifex${IPA_BUILD_NUMBER}.zip ${PROJECT_NAME}.xcarchive

		echo "Done renaming DSYM files to zip"
		echo "Exited trigger.sh file"

		echo "Copying IPA and KAR file back to binaries folder"
		echo "Copying ipa to $project_dir/$ios_binary_dir from $JENKINS_OUTPUT_BINARY_DIR/$JOB_NAME/$build_folder"
		#Copying the IPA and KAR files back to the binaries.
		
		cp $JENKINS_OUTPUT_BINARY_DIR/$JOB_NAME/$build_folder/$renamed_iphone_installer.ipa $project_dir/$ios_binary_dir/
		
		echo "Copying IPA and KAR file back to binaries folder completed"
		echo "**********************************************************"

	else
    echo "The property file $propertyFile not found."
  fi
else
  echo "Wrong number of parameters!!"
fi
