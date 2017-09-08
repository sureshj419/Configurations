#!/bin/sh
###############################################################
#                       ipaGenerate		                      #
###############################################################
# Purpose:
# Purpose of this file to generate the ipa for iOS_build.	  #
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
		xcode_updater_jar="$KCI_GEN_IPA_TASK_XCODE_UPDATER_JAR"
		infoPlistConfig_file="$KCI_GEN_IPA_TASK_INFOPLIST_CONFIG_PATH"
		xcodeConfig_file="$KCI_GEN_IPA_TASK_XCODE_CONFIG_PATH"
		# the entitlements file need to be added to the projects root folder when your project requries any entitlements.
		entitlements_file="$IOS_ENTITLEMENTS_FILE"

		echo "****************Renaming the orginal KAR file************"
		echo "Source is => $project_dir/$ios_binary_dir/$ios_kar_orig_file_name.KAR"
		echo "Target is => $project_dir/binaries/iphone/$renamed_iphone_installer.KAR"
		renamed_iphone_installer=$(echo $TagName | tr -d '\r')_$(echo $IPA_BUILD_NUMBER | tr -d '\r')
		echo "renamed_iphone_installer => $renamed_iphone_installer"
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
		echo "kar_name => ${kar_name}.kar"
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
		fi
		
		#New code for creating the jenkins build folder with binaries sub folder (if not already existing) and then remove ipa files and kar files from binaries folder and also remove the trigger file from jenkins build folder and copy the latest trigger file from the build machine. For now it is assumed that the trigger file is part of the ci script files folder on build machine. later on all these files can be moved to the svn itself and pulled as needed
		##START

		
#Condition to check if Jenkins_build directory exists and delete older ipa,kar and trigger files else create new directory. 

		echo "Checking if Jenkins_build directory exists, if not create the same along with sub directory binaries. Delete older ipa, kar and trigger files."
		mkdir -p $JENKINS_OUTPUT_BINARY_DIR; cd $JENKINS_OUTPUT_BINARY_DIR; rm -f *.ipa; rm -f *.KAR; cd $JENKINS_BUILD_DIR
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
				cp $ECLIPSE_LOCATION/plugins/com.kony.ios_*.jar "${DIR}"
			echo "Copying the ios plugin to folder completed"
			
			cd ${DIR}
			echo "PWD --> "${DIR}
			
#Moving .jar file to plugin.zip file and Unzipping of the plugin jar
			mv com.kony.ios_*.jar plugin.zip
			tar -vxf plugin.zip
			tar -vxf iOS-GA-*.zip
			
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

		echo "**********Printing the perl extract command"

		cd $JENKINS_OUTPUT_BINARY_DIR
		echo "The current directory is `pwd`"
		lzldkar_name="${kar_name}"

		if [ -f "${lzldkar_name}.kar" ]
		then
			echo "$lzldkar_name.kar found."
			if [ -d "${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}" ]; then
				rm -rf ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}
			fi
			mkdir -p ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}
			if [ -f "${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${lzldkar_name}.kar" ]	
			then
				rm -rf ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${lzldkar_name}.kar
			fi
			echo "copying $lzldkar_name.kar to ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}"
			cp $lzldkar_name.kar ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}
		else
			echo "$lzldkar_name.kar not found."
		fi
		echo "changing directory to gen directory"
		cd $(echo $GENDIR | tr -d '\r')
		echo "**********Printing the perl extract command"

		echo "running perl extract command - existing one"

		PERLEXTRACTCMD="perl extract.pl $(echo ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER} | tr -d '\r')/$(echo $lzldkar_name | tr -d '\r').KAR KCI"
		echo "${PERLEXTRACTCMD}"
		$PERLEXTRACTCMD
		echo ""

		echo "Checking timestamp after extraction of KAR and before XCode changes"

		echo `date +%T\ `

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
		#Creating a new file Config.properties and Adding the required buid settings to the file as the tool below takes the values from property file and modifies the build settings.
		echo "Creating the Config.properties file with required properties"
		echo 'IPHONEOS_DEPLOYMENT_TARGET=10.2\r\nONLY_ACTIVE_ARCH=NO\r\nGCC_OPTIMIZATION_LEVEL=s\r\nINFOPLIST_FILE=Info.plist\r\nOTHER_CFLAGS=-fstack-protector\r\nOTHER_LDFLAGS=-all_load,-ObjC,$(SQL_LIBRARY),$(DATAVIZ_LIBRARY),-lc++,$(PROTECTION_LIBRARY),$(ARXAN_OTHERFLAGS),-framework,JavaScriptCore' >> $xcodeConfig_file
		echo "CODE_SIGN_ENTITLEMENTS=$entitlements_file\r\nPROVISIONING_PROFILE=$PROVISIONING_PROFILE\r\nPROVISIONING_PROFILE[sdk\=iphoneos*]=$PROVISIONING_PROFILE\r\nCODE_SIGN_IDENTITY=$DEVELOPER_NAME\r\nCODE_SIGN_IDENTITY[sdk\=iphoneos*]=$DEVELOPER_NAME\r\nDEVELOPMENT_TEAM=$DEVELOPMENT_TEAM" >> $xcodeConfig_file
		
		echo "Running the xCode Automation tool to make the xCode and Info.Plist changes"
		java -jar xCodeAutomation.jar Info.Plist_Config.json currBuildInfoPlistXml.xml XCodeCurBuildProperties.xml "$xcodeConfig_file" "$KCI_GEN_IPA_TASK_XCODE_VERSION" $IOS_ENTITLEMENTS_REQUIRED "$entitlements_file" "$bundlekey"

		
#Converting the .xml files of xcode project settings to project.pbxproj and Info.plist.
		
		cd ${PROJDIR}/
		echo "Converting Xcode XML to XCode project"
		plutil -convert xml1 -o ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj ${DIR}/AutomationFiles/XCodeCurBuildProperties.xml

		echo "Converting Info.Plist XML to Info.Plist Plist file"
		plutil -convert xml1 -o ${PROJDIR}/Info.plist ${DIR}/AutomationFiles/currBuildInfoPlistXml.xml
		echo "Completed modifying Xcode settings!!!"
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
		echo "Performing xcodebuild clean with target ${PROJECT_NAME} and sdk as ${TARGET_SDK} and configuration as ${RELEASE_CONF}"
		xcodebuild clean -project ${PROJDIR}/VMAppWithKonylib.xcodeproj -configuration ${RELEASE_CONF} -target "${PROJECT_NAME}" -sdk "${TARGET_SDK}"

		##Step 2 - Create Xcode Archive
		echo "Performing xcodebuild Archive with project ${PROJDIR}/VMAppWithKonylib.xcodeproj and archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive"
		xcodebuild archive -project ${PROJDIR}/VMAppWithKonylib.xcodeproj -scheme KRelease -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive

		##Step 3 - Export Xcode Archive and Generate IPA
		echo "Performing xcodebuild Export with project archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive, exportPath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${ipa_name} and exportProvisioningProfile ${PRO_PROFILE_NAME}"
		xcodebuild -exportArchive -archivePath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${PROJECT_NAME}.xcarchive -exportPath ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}/${ipa_name} -exportFormat IPA -exportProvisioningProfile "${PRO_PROFILE_NAME}"

		echo "Checking timestamp after XCode build"

		echo `date +%T\ `

		echo "checking if the pb.proj file exists in folder "
#Condition to check if project.pbxproj exists before copying the updated project.pbxproj file or else delete if the file exists
				
				if [ -f "${DIR}/PBProjTemp/project.pbxproj" ]
					then
					echo "file found removing file before copying new one"
					rm -f ${PROJDIR}/VMAppWithKonylib.xcodeproj/project.pbxproj
					cp ${DIR}/PBProjTemp/project.pbxproj  ${PROJDIR}/VMAppWithKonylib.xcodeproj
				fi
		echo "Done copying original project.pbxproj to AutomationFiles folder"
		echo "Making zip of DSYM files"

		cd ${JENKINS_OUTPUT_BINARY_DIR}/$JOB_NAME/build${IPA_BUILD_NUMBER}
		 zip -r buildArtifex${IPA_BUILD_NUMBER}.zip ${PROJECT_NAME}.xcarchive

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
