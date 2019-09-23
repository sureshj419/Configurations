#!/bin/sh
#################################################################
#                 AppPublishScript	                            #
#################################################################
# Purpose:							#
# Purpose of this file to publish the generated binaries from   #
# App Factory to the App Store & Playstore in Slave(MAC) 	    #
#################################################################

# Adding the input parameter to a local parameter
publish_folder="$1"
propertyFile="$2"
BUILD_NO=$3

# Condition to check if the number of parameters passed as input 
# are correct or not
if [ "$#" -eq 2 ]; then
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

    cd "$WORKSPACE"
    BASE_FOLDER=$(echo ${KCI_S3_BASE_URL}/{KCI_S3_SUB_FOLDER_URL}/build{${BUILD_NO}})
    APK_NAME=$(echo ${KCI_PROPS_APP_ID}_${BUILD_NO}.apk)
    IPA_NAME=$(echo ${KCI_PROPS_APP_ID}_${BUILD_NO}.ipa)
    echo "IPA_NAME ::$IPA_NAME"
    echo "APK_NAME ::$APK_NAME"
    #On Mac Slave
    #We provide the path for aws on mac by using source
    #source /Users/Shared/Jenkins/.bash_profile

    echo "Publish for Android Phone :: "$STORE_PUBLISH_ANDROID_APP
    echo "Publish for iPhone Phone :: "$STORE_PUBLISH_IOS_APP
    if [ $STORE_PUBLISH_ENABLED = "true" ]; then
        sleep 30
        echo
        echo "-----------------------------------------------------------"
        echo "Copying the App binaries from AWS to the workspace"
        echo "-----------------------------------------------------------"
        iosbinaryExists="false"
        androidbinaryExists="false"
        ANDROID_PHONE_BINARY=${BASE_FOLDER}/android/
        IPHONE_BINARY=${BASE_FOLDER}/iphone/

        echo "ANDROID_PHONE_BINARY::"${ANDROID_PHONE_BINARY}
        echo "IPHONE_BINARY::"${IPHONE_BINARY}

        if [[ $STORE_PUBLISH_ANDROID_APP = "true" ]]; then
            while [[ $androidbinaryExists != "true" ]]
                do
                sleep 30
                aws s3 cp ${ANDROID_PHONE_BINARY} ./ --recursive

                if [ -f "$APK_NAME" ]; then
                echo "The android binary file $APK_NAME found."
                androidbinaryExists="true"
                fi
                echo " androidbinaryExists is :::: "$androidbinaryExists
            done
        fi

        if [[ $STORE_PUBLISH_IOS_APP = "true" ]]; then
            while [[ $iosbinaryExists != "true" ]]
                do
                sleep 30
                aws s3 cp ${IPHONE_BINARY} ./ --recursive

                if [ -f "$IPA_NAME" ]; then
                echo "The iphone binary file $IPA_NAME found."
                iosbinaryExists="true"
                fi
            done
        fi

        if [ $androidbinaryExists = "true" ]; then
            echo
            echo "-----------------------------------------------------------"
            echo "Initiate the copy of Android Binary"
            echo "-----------------------------------------------------------"
            cp -a "./" "${WORKSPACE}/ci_config/$PUBLISH_AUTOMATION_FOLDER/Android"
            echo
            echo "-----------------------------------------------------------"
            echo "Copying completed of Android Binary"
            echo "-----------------------------------------------------------"
        else
            echo "The required files binary not found."
            echo "The binary file found is ::: "$androidbinaryExists
        fi

        if [ $iosbinaryExists = "true" ]; then
            echo
            echo "-----------------------------------------------------------"
            echo "Initiate the copy of iOS Binary"
            echo "-----------------------------------------------------------"
            cp -a "./" "${WORKSPACE}/ci_config/$PUBLISH_AUTOMATION_FOLDER/iPhone"
            echo
            echo "-----------------------------------------------------------"
            echo "Copying completed of iOS Binary"
            echo "-----------------------------------------------------------"
        else
            echo "The required files binary not found."
            echo "The binary file found is ::: "$iosbinaryExists
        fi
    fi

	# Checking if the folder exists  
	if [ -d "${WORKSPACE}/ci_config/$publish_folder" ]; then
        echo "The Publish folder $publish_folder found."
        if [ $STORE_PUBLISH_IOS_APP = "true" ]; then
            cd "${WORKSPACE}/ci_config/$publish_folder/iPhone"
            APP_IDENTIFIER=$iphonebundleidentifierkey
            sed -i '' -e "s/@app_identifier/$APP_IDENTIFIER/" Appfile
            sed -i '' -e "s/@apple_id/$APPLE_ID/" Appfile
            sed -i '' -e "s/@appstore_team_name/$APPSTORE_TEAM_NAME/" Appfile
            sed -i '' -e "s/@apple_id/$APPLE_ID/" Deliverfile
            ##fastlane deliver init
            ##fastlane deliver precheck
            ##fastlane deliver
            ##Using Pilot instead of deliver for uploading to Test Flight
            fastlane pilot upload --skip_waiting_for_build_processing true
        fi

        if [ $STORE_PUBLISH_ANDROID_APP = "true" ]; then
            cd "${WORKSPACE}/ci_config/$publish_folder/Android"
            APP_IDENTIFIER=$(awk 'BEGIN {print ENVIRON["android.packagename"]}')
            sed -i '' -e "s/@android_package_name/$APP_IDENTIFIER/" Appfile
            sed -i '' -e "s/@json_key_file/$ANDROID_JSON_KEY_FILE/" Appfile
            fastlane supply init
            ##fastlane supply precheck
            fastlane supply --track internal
        fi
	else
    	echo "The Publish folder $publish_folder not found."
  	fi
  else
    echo "The property file $propertyFile not found."
  fi
else
  echo "Wrong number of parameters!!"
fi
