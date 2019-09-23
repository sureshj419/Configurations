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
