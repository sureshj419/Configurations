##USAGE
##Latest Usage Example as below
##./ArchiveAndEnableOTA.sh Job_Name KCI KCI 10 /Users/madhav/KCICIScripts/OTA/KCI-OTA Job_Name_For_Sub_DirName /Users/madhav/KCICIScripts/OTA/testOTA/binaries/iphone KCI_10.ipa /Users/madhav/KCICIScripts/OTA/testOTA/binaries/ipad KCI_10.ipa /Users/madhav/KCICIScripts/OTA/testOTA/binaries/android luavmandroid.apk /Users/madhav/KCICIScripts/OTA/testOTA/binaries/androidTab luavmandroid.apk /Users/madhav/KCICIScripts/OTA/testOTA/binaries/windows8 windows8.xap /Users/madhav/KCICIScripts/OTA/testOTA/binaries/windows81 windows81.xap /Users/madhav/KCICIScripts/OTA/testOTA/templates com.kone.containerapp TestProj iphone,ipad,android,androidT,win8,win81 DetailsOfBuildCanBeSeenAsBelow s3://kony-ci0001-storage1 KCI/GEM http://kony-ci0001-storage1.s3-website-eu-west-1.amazonaws.com true ios ios

###############################################################
#                     ArchiveAndEnableOTA		              #
###############################################################
# Purpose:
# Purpose of this file to create OTA artefacts and publish the
# created artefacts to s3 bucket							  #
###############################################################

#Adding the input parameters to the local parameters.

echo "Perform archive and enable OTA"
JOB_NAME="$1"
echo "JOB_NAME => $JOB_NAME"

IPHONE_BINARY_NAME="$2"
echo "IPHONE_BINARY_NAME => $IPHONE_BINARY_NAME"

IPHONE_TAB_BINARY_NAME="$3"
echo "IPHONE_TAB_BINARY_NAME => $IPHONE_TAB_BINARY_NAME"

BUILD_NO="$4"
echo "BUILD_NO => $BUILD_NO"

TGT_DIR="build$BUILD_NO"
echo "TGT_DIR => $TGT_DIR"

OTA_TEMP_DIR="$5"
echo "OTA_TEMP_DIR => $OTA_TEMP_DIR"

OTA_SUB_DIR="$6"
echo "OTA_SUB_DIR => $OTA_SUB_DIR"

IPHONE_BINARY_PATH="$7"
echo "IPHONE_BINARY_PATH => $IPHONE_BINARY_PATH"
IPHONE_BINARY="$8"
echo "IPHONE_BINARY => $IPHONE_BINARY"
IPHONE_TAB_BINARY_PATH="$9"
echo "IPHONE_TAB_BINARY_PATH => $IPHONE_TAB_BINARY_PATH"
IPHONE_TAB_BINARY="${10}"
echo "IPHONE_TAB_BINARY => $IPHONE_TAB_BINARY"

ANDROID_BINARY_PATH="${11}"
echo "ANDROID_BINARY_PATH => $ANDROID_BINARY_PATH"
ANDROID_BINARY="${12}"
echo "ANDROID_BINARY => $ANDROID_BINARY"
ANDROID_TAB_BINARY_PATH="${13}"
echo "ANDROID_TAB_BINARY_PATH => $ANDROID_TAB_BINARY_PATH"
ANDROID_TAB_BINARY="${14}"
echo "ANDROID_TAB_BINARY => $ANDROID_TAB_BINARY"

WINDOWS8_BINARY_PATH="${15}"
echo "WINDOWS8_BINARY_PATH => $WINDOWS8_BINARY_PATH"
WINDOWS8_BINARY="${16}"
echo "WINDOWS8_BINARY => $WINDOWS8_BINARY"
#WINDOWS8_TAB_BINARY_PATH="${17}"
#echo "WINDOWS8_TAB_BINARY_PATH => $WINDOWS8_TAB_BINARY_PATH"
#WINDOWS8_TAB_BINARY="${18}"
#echo "WINDOWS8_TAB_BINARY => $WINDOWS8_TAB_BINARY"

WINDOWS81_BINARY_PATH="${17}"
echo "WINDOWS81_BINARY_PATH => $WINDOWS81_BINARY_PATH"
WINDOWS81_BINARY="${18}"
echo "WINDOWS81_BINARY => $WINDOWS81_BINARY"
#WINDOWS81_TAB_BINARY_PATH="${21}"
#echo "WINDOWS81_TAB_BINARY_PATH => $WINDOWS81_TAB_BINARY_PATH"
#WINDOWS81_TAB_BINARY="${22}"
#echo "WINDOWS81_TAB_BINARY => $WINDOWS81_TAB_BINARY"


TEMPLATE_FILES_PATH="${19}"
echo "TEMPLATE_FILES_PATH => $TEMPLATE_FILES_PATH"

TITLE_NAME="$JOB_NAME#$BUILD_NO"
echo "TITLE_NAME => $TITLE_NAME"

BUNDLE_IDENTIFIER="${20}"
echo "BUNDLE_IDENTIFIER => $BUNDLE_IDENTIFIER"

APP_ID="${21}"
echo "APP_ID => $APP_ID"

CHANNELS="${22}"
echo "CHANNELS => $CHANNELS"

BUILD_DETAILS="${23}"
echo "BUILD_DETAILS => $BUILD_DETAILS"

S3_SERVER_URL="${24}"
echo "S3_SERVER_URL => $S3_SERVER_URL"

S3_SUB_FOLDER_URL="${25}"
echo "S3_SUB_FOLDER_URL => $S3_SUB_FOLDER_URL"

S3_OTA_URL="${26}"
echo "S3_OTA_URL => $S3_OTA_URL"

EXECUTE_PIPELINE="${27}"
echo "EXECUTE_PIPELINE => $EXECUTE_PIPELINE"

BUILD_MACHINE_OS="${28}"
echo "BUILD_MACHINE_OS => $BUILD_MACHINE_OS"

ANDROID_TARGET_SLAVE_IN_PIPE_LINE="${29}"
echo "ANDROID_TARGET_SLAVE_IN_PIPE_LINE => $ANDROID_TARGET_SLAVE_IN_PIPE_LINE"

NOTIFICATION_FOLDER="${30}"
echo "NOTIFICATION_FOLDER => $NOTIFICATION_FOLDER"

ANDROID_ENABLED="false"
echo "ANDROID_ENABLED initial value=> $ANDROID_ENABLED"
ANDROID_TAB_ENABLED="false"
echo "ANDROID_TAB_ENABLED initial value=> $ANDROID_TAB_ENABLED"

IPHONE_ENABLED="false"
echo "IPHONE_ENABLED initial value=> $IPHONE_ENABLED"
IPHONE_TAB_ENABLED="false"
echo "IPHONE_TAB_ENABLED initial value=> $IPHONE_TAB_ENABLED"

WINDOWS8_ENABLED="false"
echo "WINDOWS8_ENABLED initial value=> $WINDOWS8_ENABLED"
WINDOWS8_TAB_ENABLED="false"
#cho "WINDOWS8_TAB_ENABLED initial value=> $WINDOWS8_TAB_ENABLED"
WINDOWS81_ENABLED="false"
echo "WINDOWS81_ENABLED initial value=> $WINDOWS81_ENABLED"
WINDOWS81_TAB_ENABLED="false"
echo "WINDOWS81_TAB_ENABLED initial value=> $WINDOWS81_TAB_ENABLED"


# Condition to check if the number of parameters passed as input 
# are correct or not.

if [ "$#" -eq 30 ]; then
  echo "Correct number of parameters have been passed!!"

  echo "Now setting iphone and android enablement options based on channels selected"
  CHANNELS_LIST=$(echo $CHANNELS | tr "," "\n")
  for CHANNEL in $CHANNELS_LIST
    do
      if [ "$CHANNEL" = "android" ]; then
        ANDROID_ENABLED="true"
        echo "android mobile enabled"
      fi
      if [ "$CHANNEL" = "androidT" ]; then
        ANDROID_TAB_ENABLED="true"
        echo "android tab enabled"
      fi
      if [ "$CHANNEL" = "iphone" ]; then
        IPHONE_ENABLED="true"
        echo "iphone mobile enabled"
      fi
      if [ "$CHANNEL" = "ipad" ]; then
        IPHONE_TAB_ENABLED="true"
        echo "iphone tab enabled"
      fi
      if [ "$CHANNEL" = "win8" ]; then
        WINDOWS8_ENABLED="true"
        echo "windows 8 mobile enabled"
      fi
      if [ "$CHANNEL" = "win8T" ]; then
        WINDOWS8_TAB_ENABLED="true"
        echo "windows 8 tab enabled"
      fi
      if [ "$CHANNEL" = "win81" ]; then
        WINDOWS81_ENABLED="true"
        echo "windows 8.1 mobile enabled"
      fi
       if [ "$CHANNEL" = "win81T" ]; then
         WINDOWS81_TAB_ENABLED="true"
         echo "windows 8.1 tab enabled"
       fi
    done

 ### Below code no longer required since all the binaries are now being copied back to master before being fed to OTA process
  # Deviation for Pipeline (Since the same job will be called from both Mac and Win slaves)
  # Have to ensure that in case of Pipeline, even though all platforms are targeted for build,
  # Perform OTA activities for Windows binaries only when the OTA job is called from Windows slave
  # Perform OTA activities for iOS binaries only when the OTA job is called from Mac slave
  # if [ "$EXECUTE_PIPELINE" = "true" ]; then
  #   echo "This is a Pipeline build!!"
  #   BUILD_MACHINE_OS=`echo "$BUILD_MACHINE_OS" | tr '[:upper:]' '[:lower:]'`
  #   echo "BUILD_MACHINE_OS:: $BUILD_MACHINE_OS"
  #   if [ "$BUILD_MACHINE_OS" = "ios" ]; then
  #     echo "Targeted OTA process to be run on MAC slave, so windows binaries wont be part of OTA, hence not to be enabled in OTA html"
  #     WINDOWS8_ENABLED="false"
  #     WINDOWS81_ENABLED="false"
  #     ## if target slave for running android slave has not been set to ios, then it should not be part of OTA initiated from Mac Slave
  #     if [ "$ANDROID_TARGET_SLAVE_IN_PIPE_LINE" != "ios" ]; then
  #       echo "ANDROID_TARGET_SLAVE_IN_PIPE_LINE has been set to $ANDROID_TARGET_SLAVE_IN_PIPE_LINE hence android binaries wont be part of OTA initiated from Mac slave"
  #       ANDROID_ENABLED="false"
  #       ANDROID_TAB_ENABLED="false"
  #     fi
  #   elif [ "$BUILD_MACHINE_OS" = "windows" ]; then
  #     echo "Targeted OTA process to be run on Windows slave, so ios binaries wont be part of OTA, hence not to be enabled in OTA html"
  #     IPHONE_ENABLED="false"
  #     IPHONE_TAB_ENABLED="false"
  #     ## if target slave for running android slave has not been set to windows, then it should not be part of OTA initiated from Windows Slave
  #     if [ "$ANDROID_TARGET_SLAVE_IN_PIPE_LINE" != "windows" ]; then
  #       echo "ANDROID_TARGET_SLAVE_IN_PIPE_LINE has been set to $ANDROID_TARGET_SLAVE_IN_PIPE_LINE hence android binaries wont be part of OTA initiated from Windows slave"
  #       ANDROID_ENABLED="false"
  #       ANDROID_TAB_ENABLED="false"
  #     fi
  #   else
  #     echo "BUILD_MACHINE_OS value is set to $BUILD_MACHINE_OS - That is not ios or windows!! So going ahead with OTA for all channels!!"
  #   fi
  # fi

  echo "ANDROID_ENABLED updated value=> $ANDROID_ENABLED"
  echo "ANDROID_TAB_ENABLED updated value=> $ANDROID_TAB_ENABLED"

  echo "IPHONE_ENABLED updated value=> $IPHONE_ENABLED"
  echo "IPHONE_TAB_ENABLED updated value=> $IPHONE_TAB_ENABLED"

  echo "WINDOWS8_ENABLED updated value=> $WINDOWS8_ENABLED"
  # echo "WINDOWS8_TAB_ENABLED updated value=> $WINDOWS8_TAB_ENABLED"
  echo "WINDOWS81_ENABLED updated value=> $WINDOWS81_ENABLED"
  # echo "WINDOWS81_TAB_ENABLED updated value=> $WINDOWS81_TAB_ENABLED"

  #Standard Download Link Label
  STD_INSTALL_LINK_LABEL="Click Here to Install"
  STD_DOWNLOAD_LINK_LABEL="Click Here to Download"
  ARTEFACT_UNAVAILABLE_LABEL="Artifact Currently Unavailable"
  DISABLED_LINK_STYLE="pointer-events: none; cursor: default; color:black;"
  LINK_UNLINK="true"

  # Checking and creating $OTA_TEMP_DIR folder if not already available
  echo "Checking if $OTA_TEMP_DIR already exists?"
  if [ -d "$OTA_TEMP_DIR" ]; then
    echo "Folder $OTA_TEMP_DIR already exists!"
  else
    echo "Folder $OTA_TEMP_DIR does not exist!"
    echo "Creating folder $OTA_TEMP_DIR"
    mkdir -p "$OTA_TEMP_DIR"
    chmod -R 777 "$OTA_TEMP_DIR"
    if [ -d "$OTA_TEMP_DIR" ]; then
      echo "Created folder $OTA_TEMP_DIR"
    else
      echo "Unable to create Folder $OTA_TEMP_DIR"
      #echo "Exiting...."
      #exit
    fi
  fi
  # Checking and creating $OTA_TEMP_DIR/$OTA_SUB_DIR folder if not already available
  echo "Checking if $OTA_SUB_DIR folder exists under $OTA_TEMP_DIR"
  if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR" ]; then
    echo "$OTA_TEMP_DIR/$OTA_SUB_DIR folder already exists"
  else
    echo "Creating folder $OTA_SUB_DIR under $OTA_TEMP_DIR folder"
    mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR
    if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR" ]; then
      echo "Created folder $OTA_SUB_DIR under $OTA_TEMP_DIR folder"
    else
      echo "Unable to create folder $OTA_SUB_DIR under $OTA_TEMP_DIR folder"
      #echo "Exiting...."
      #exit
    fi
  fi
  # Creating $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder
  echo "Creating $TGT_DIR folder under $OTA_TEMP_DIR/$OTA_SUB_DIR folder"
  mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR
  if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR" ]; then
    echo "Created $TGT_DIR folder under $OTA_TEMP_DIR/$OTA_SUB_DIR folder"
  else
    echo "Unable to create $TGT_DIR folder under $OTA_TEMP_DIR/$OTA_SUB_DIR folder"
    ##echo "Exiting...."
    #exit
  fi
  ## Now creating OTA artefacts as applicable
  echo "Attempting to copy the template files to the target folder"
  if [ -d "$NOTIFICATION_FOLDER" ]; then
    echo "$NOTIFICATION_FOLDER exists"
    #Copy template index file to the target OTA folder
    echo "Copying template index.html file to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
    cp "$NOTIFICATION_FOLDER/index_orig.html" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/index.html" 
    chmod 777 "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/index.html"
    INDEX_FILE="$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/index.html"
    echo "INDEX_FILE => $INDEX_FILE"

    ## If INDEX_FILE template has been successfully copied in steps above, apply project specific customizations
    echo "Checking if template $INDEX_FILE is in place, and if found, apply project specific customizations"
    if [ -f "$INDEX_FILE" ]; then
      echo "Template $INDEX_FILE is in place, applying project specific customizations"
      sed -i -e 's|$Project_Name|'"$TITLE_NAME"'|g' $INDEX_FILE
      sed -i -e 's|$ota_serv_url|'"$S3_OTA_URL"'|g' $INDEX_FILE
      sed -i -e 's|$ota_sub_fldr_url|'"$S3_SUB_FOLDER_URL"'|g' $INDEX_FILE
      sed -i -e 's|$job_name|'"$JOB_NAME"'|g' $INDEX_FILE
      sed -i -e 's|$build_no|'"$TGT_DIR"'|g' $INDEX_FILE
      sed -i -e 's|$Build_Details|'"$BUILD_DETAILS"'|g' $INDEX_FILE

      # Enable triggered channels installers in OTA index.html file
      ENABLE_NONE="none"
      # Android Mobile
      if [ $ANDROID_ENABLED != "true" ]; then
        sed -i -e 's|$Android_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      else
        sed -i -e 's|$Android_Enable|'"$ANDROID_ENABLED"'|g' $INDEX_FILE
      fi
      # Android Tablet
      if [ $ANDROID_TAB_ENABLED != "true" ]; then
        sed -i -e 's|$AndroidT_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      else
        sed -i -e 's|$AndroidT_Enable|'"$ANDROID_TAB_ENABLED"'|g' $INDEX_FILE
      fi
      # iPhone Mobile
      if [ $IPHONE_ENABLED != "true" ]; then
        sed -i -e 's|$iPhone_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      else
        sed -i -e 's|$iPhone_Enable|'"$IPHONE_ENABLED"'|g' $INDEX_FILE
      fi
      # iPhone Tablet
      if [ $IPHONE_TAB_ENABLED != "true" ]; then
        sed -i -e 's|$iPhoneT_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      else
        sed -i -e 's|$iPhoneT_Enable|'"$IPHONE_TAB_ENABLED"'|g' $INDEX_FILE
      fi
      # Windows 8 Mobile
      if [ $WINDOWS8_ENABLED != "true" ]; then
        sed -i -e 's|$Windows8_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      else
        sed -i -e 's|$Windows8_Enable|'"$WINDOWS8_ENABLED"'|g' $INDEX_FILE
      fi
      # Windows 8 Tablet
      # if [ $WINDOWS8_TAB_ENABLED != "true" ]; then
      #   sed -i -e 's|$Windows8T_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      # else
      #   sed -i -e 's|$Windows8T_Enable|'"$WINDOWS8_TAB_ENABLED"'|g' $INDEX_FILE
      # fi
      # Windows 8.1 Mobile
      if [ $WINDOWS81_ENABLED != "true" ]; then
        sed -i -e 's|$Windows81_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      else
        sed -i -e 's|$Windows81_Enable|'"$WINDOWS81_ENABLED"'|g' $INDEX_FILE
      fi
      # Windows 8.1 Tablet
      # if [ $WINDOWS81_TAB_ENABLED != "true" ]; then
      #   sed -i -e 's|$Windows81T_Enable|'"$ENABLE_NONE"'|g' $INDEX_FILE
      # else
      #   sed -i -e 's|$Windows81T_Enable|'"$WINDOWS81_TAB_ENABLED"'|g' $INDEX_FILE
      # fi

    else
      echo "$INDEX_FILE does not exist"
      #echo "Exiting...."
      #exit
    fi

    ## Checking if iphone mobile and/or tablet is in scope for this build and performing iphone mobile and/or tablet specific OTA activities
    if [ $IPHONE_ENABLED = "true" ] || [ $IPHONE_TAB_ENABLED = "true" ]; then
      echo "iphone mobile and/or tablet related OTA in scope"
      IPHONE_BINARY_LABEL=""
	  IPHONE_DOWNLOAD_LABEL=""
      IPHONE_LINK=""
      IPHONE_KAR_LABEL=""
      IPHONE_KAR_LINK=""
      IPAD_BINARY_LABEL=""
      IPAD_LINK=""
      IPAD_KAR_LABEL=""
      IPAD_KAR_LINK=""
	  IPHONE_LINK_UNLINK="true"
	  IPAD_LINK_UNLINK="true"

      ###START OF IPHONE MOBILE OTA
      if [ $IPHONE_ENABLED = "true" ]; then
        IPHONE_PLIST_FILE="$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone.plist"
        IPHONE_STRING="iphone.plist"
        IPHONE_FOLDER_NAME="iphone"

        echo "Attempting to perform iphone mobile related OTA activities"
        if [ -d "$IPHONE_BINARY_PATH" ]; then
          echo "$IPHONE_BINARY_PATH exists"

          # Creating $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone folder
          echo "Creating $IPHONE_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
          mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME
          if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME" ]; then
            echo "Created $IPHONE_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
            # Now copy iphone related artefacts under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone folder
            echo "Now attempting to copy iphone artefacts to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME folder"

            IPHONE_KAR=$(echo ${IPHONE_BINARY_NAME}_${BUILD_NO}.KAR)
            echo "IPHONE_BINARY => $IPHONE_BINARY"
            echo "IPHONE_KAR => $IPHONE_KAR"
            echo "Copying iphone mobile kar and binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME folder"
	    cp "$IPHONE_BINARY_PATH/$IPHONE_KAR" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME/$IPHONE_KAR"
	    ls -ltra "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME/"
            cp "$IPHONE_BINARY_PATH/$IPHONE_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME/$IPHONE_BINARY"
            ls -ltra "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME/"
	    
            if [ -f "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME/$IPHONE_BINARY" ]; then
              echo "Successfully copied $IPHONE_BINARY to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME location"
              IPHONE_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
			  IPHONE_DOWNLOAD_LABEL=$STD_DOWNLOAD_LINK_LABEL
              echo "IPHONE_BINARY_LABEL value is set to :: $IPHONE_BINARY_LABEL"
            else
              echo "Could not copy $IPHONE_BINARY to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME location"
              IPHONE_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
			  IPHONE_DOWNLOAD_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
              echo "Changing IPHONE_BINARY_LABEL value to :: $IPHONE_BINARY_LABEL"
            fi
            if [ -f "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME/$IPHONE_KAR" ]; then
              echo "Successfully copied $IPHONE_KAR to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME location"
              IPHONE_KAR_LABEL=$STD_INSTALL_LINK_LABEL
              echo "IPHONE_KAR_LABEL value is set to :: $IPHONE_KAR_LABEL"
            else
              echo "Could not copy $IPHONE_KAR to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME location"
              IPHONE_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
              echo "Changing IPHONE_KAR_LABEL value to :: $IPHONE_KAR_LABEL"
            fi

            ## Copy iphone plist template file to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder
            echo "Copying iphone.plist template file to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
            cp "$TEMPLATE_FILES_PATH/iphone_orig.plist" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone.plist"
	    chmod 777 "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone.plist"
	    ls -ltra "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/"
            echo "IPHONE_PLIST_FILE => $IPHONE_PLIST_FILE"
            echo "IPHONE_STRING => $IPHONE_STRING"
            if [ -f "$IPHONE_PLIST_FILE" ]; then
              echo "$IPHONE_PLIST_FILE is in place"
              IPHONE_PLIST_STRING="$IPHONE_FOLDER_NAME/$IPHONE_BINARY"
              echo "Applying changes to iphone plist file:: $IPHONE_PLIST_FILE"
              sed -i -e 's|$ota_serv_url|'"$S3_OTA_URL"'|g' $IPHONE_PLIST_FILE
              sed -i -e 's|$ota_sub_fldr_url|'"$S3_SUB_FOLDER_URL"'|g' $IPHONE_PLIST_FILE
              sed -i -e 's|$job_name|'"$JOB_NAME"'|g' $IPHONE_PLIST_FILE
              sed -i -e 's|$build_no|'"$TGT_DIR"'|g' $IPHONE_PLIST_FILE
              sed -i -e 's|$iPhone_Installer|'"$IPHONE_PLIST_STRING"'|g' $IPHONE_PLIST_FILE
              sed -i -e 's|$bundleIdentifier|'"$BUNDLE_IDENTIFIER"'|g' $IPHONE_PLIST_FILE
			  sed -i -e 's|$title|'"$APP_ID"'|g' $IPHONE_PLIST_FILE
              echo "Done with applying changes to iphone plist file:: $IPHONE_PLIST_FILE"
            else
             echo "$IPHONE_PLIST_FILE does not exist"
             IPHONE_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
			 IPHONE_DOWNLOAD_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
			 IPHONE_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
            fi
          else
            echo "Unable to create $IPHONE_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
			IPHONE_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
			IPHONE_DOWNLOAD_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
			IPHONE_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
          fi
        else
          echo "$IPHONE_BINARY_PATH does not exist"
		  IPHONE_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
		  IPHONE_DOWNLOAD_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
		  IPHONE_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
        fi
            ## If INDEX_FILE template has been successfully copied in the previous steps above, apply iphone specific changes
            echo "Checking if template $INDEX_FILE is in place, and if found, apply iPhone mobile specific changes"
            if [ -f "$INDEX_FILE" ]; then
              echo "Template $INDEX_FILE is in place, applying iphone specific changes"
			  echo "$IPHONE_BINARY_LABEL"
              if [ "$IPHONE_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
			    IPHONE_LINK=$DISABLED_LINK_STYLE
				IPHONE_LINK_UNLINK="false"
				
              fi
              if [ "$IPHONE_KAR_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
                IPHONE_KAR_LINK=$DISABLED_LINK_STYLE
				
              fi
              echo "Applying iphone specific changes on $INDEX_FILE file"
			  sed -i -e 's|$iphone_plist|'"$IPHONE_STRING"'|g' $INDEX_FILE
              sed -i -e 's|$iphone_folder_name|'"$IPHONE_FOLDER_NAME"'|g' $INDEX_FILE
              sed -i -e 's|$iphone_kar|'"$IPHONE_KAR"'|g' $INDEX_FILE
			  sed -i -e 's|$iphone_ipa|'"$IPHONE_BINARY"'|g' $INDEX_FILE
			  
              ##NEW START
			  echo "$IPHONE_LINK"
              sed -i -e 's|$iPhone_link|'"$IPHONE_LINK"'|g' $INDEX_FILE
			  sed -i -e 's|$iPhone_delink|'"$IPHONE_LINK_UNLINK"'|g' $INDEX_FILE
              sed -i -e 's|$iPhone_binary_label|'"$IPHONE_BINARY_LABEL"'|g' $INDEX_FILE
			   sed -i -e 's|$iphone_download_label|'"$IPHONE_DOWNLOAD_LABEL"'|g' $INDEX_FILE
              sed -i -e 's|$iPhone_kar_link|'"$IPHONE_KAR_LINK"'|g' $INDEX_FILE
              sed -i -e 's|$iPhone_kar_label|'"$IPHONE_KAR_LABEL"'|g' $INDEX_FILE
              ##NEW END
			  

              echo "Done with applying iphone specific changes on $INDEX_FILE file"
            else
              echo "$INDEX_FILE does not exist"
              #echo "Exiting...."
              #exit
            fi
       fi
      ###END OF IPHONE MOBILE OTA

      ###START OF IPHONE TAB OTA
      if [ $IPHONE_TAB_ENABLED = "true" ]; then
        IPHONE_TAB_PLIST_FILE="$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphoneT.plist"
        IPHONE_TAB_STRING="iphoneT.plist"
        IPHONE_TAB_FOLDER_NAME="ipad"

        echo "Attempting to perform iphone tab related OTA activities"
        if [ -d "$IPHONE_TAB_BINARY_PATH" ]; then
          echo "$IPHONE_TAB_BINARY_PATH exists"

          # Creating $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/ipad folder
          echo "Creating $IPHONE_TAB_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
          mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME
          if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME" ]; then
            echo "Created $IPHONE_TAB_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
            # Now copy iphone related artefacts under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/ipad folder
            echo "Now attempting to copy iphone artefacts to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME folder"

            IPHONE_TAB_KAR=$(echo ${IPHONE_TAB_BINARY_NAME}_${BUILD_NO}.KAR)
            echo "IPHONE_TAB_BINARY => $IPHONE_TAB_BINARY"
            echo "IPHONE_TAB_KAR => $IPHONE_TAB_KAR"
            echo "Copying iphone tablet kar and binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME folder"
            cp "$IPHONE_TAB_BINARY_PATH/$IPHONE_TAB_KAR" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME/$IPHONE_TAB_KAR"
            cp "$IPHONE_TAB_BINARY_PATH/$IPHONE_TAB_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME/$IPHONE_TAB_BINARY"
            ## Insert code here to check if the iphone tab binary and kar file got copied to the intended folder
            if [ -f "$IPHONE_TAB_BINARY_PATH/$IPHONE_TAB_BINARY" ]; then
              echo "Successfully copied $IPHONE_TAB_BINARY to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME location"
              IPAD_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
              echo "IPAD_BINARY_LABEL value is set to :: $IPAD_BINARY_LABEL"
            else
              echo "Could not copy $IPHONE_TAB_BINARY to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME location"
              IPAD_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
              echo "Changing IPAD_BINARY_LABEL value to :: $IPAD_BINARY_LABEL"
            fi
            if [ -f "$IPHONE_TAB_BINARY_PATH/$IPHONE_TAB_KAR" ]; then
              echo "Successfully copied $IPHONE_TAB_KAR to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME location"
              IPAD_KAR_LABEL=$STD_INSTALL_LINK_LABEL
              echo "IPAD_KAR_LABEL value is set to :: $IPAD_KAR_LABEL"
            else
              echo "Could not copy $IPHONE_TAB_KAR to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_TAB_FOLDER_NAME location"
              IPAD_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
              echo "Changing IPAD_KAR_LABEL value to :: $IPAD_KAR_LABEL"
            fi

            ## Copy iphone tab plist template file to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder
            echo "Copying iphoneT.plist template file to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
            cp "$TEMPLATE_FILES_PATH/iphoneT_orig.plist" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphoneT.plist"
            echo "IPHONE_TAB_PLIST_FILE => $IPHONE_TAB_PLIST_FILE"
            echo "IPHONE_TAB_STRING => $IPHONE_TAB_STRING"
            if [ -f "$IPHONE_TAB_PLIST_FILE" ]; then
              echo "$IPHONE_TAB_PLIST_FILE is in place"
              IPHONE_TAB_PLIST_STRING="$IPHONE_TAB_FOLDER_NAME/$IPHONE_TAB_BINARY"
              echo "Applying changes to iphone tab plist file:: $IPHONE_TAB_PLIST_FILE"
              sed -i -e 's|$ota_serv_url|'"$S3_OTA_URL"'|g' $IPHONE_TAB_PLIST_FILE
              sed -i -e 's|$ota_sub_fldr_url|'"$S3_SUB_FOLDER_URL"'|g' $IPHONE_TAB_PLIST_FILE
              sed -i -e 's|$job_name|'"$JOB_NAME"'|g' $IPHONE_TAB_PLIST_FILE
              sed -i -e 's|$build_no|'"$TGT_DIR"'|g' $IPHONE_TAB_PLIST_FILE
              sed -i -e 's|$iPhoneT_Installer|'"$IPHONE_TAB_PLIST_STRING"'|g' $IPHONE_TAB_PLIST_FILE
              sed -i -e 's|$bundleIdentifier|'"$BUNDLE_IDENTIFIER"'|g' $IPHONE_TAB_PLIST_FILE
			  sed -i -e 's|$title|'"$APP_ID"'|g' $IPHONE_PLIST_FILE
              echo "Done with applying changes to iphone tab plist file:: $IPHONE_TAB_PLIST_FILE"
            else
             echo "$IPHONE_TAB_PLIST_FILE does not exist"
             IPAD_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
			 IPAD_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
            fi
          else
            echo "Unable to create $IPHONE_TAB_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
			IPAD_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
			IPAD_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
          fi

        else
          echo "$IPHONE_TAB_BINARY_PATH does not exist"
		  IPAD_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
		  IPAD_KAR_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
        fi
            ## If INDEX_FILE template has been successfully copied in the previous steps above, apply iphone specific changes
            echo "Checking if template $INDEX_FILE is in place, and if found, apply iPhone tab specific changes"
            if [ -f "$INDEX_FILE" ]; then
              echo "Template $INDEX_FILE is in place, applying iphone specific changes"
              if [ "$IPAD_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
                IPAD_LINK=$DISABLED_LINK_STYLE
				IPAD_LINK_UNLINK="false"
              fi
              if [ "$IPAD_KAR_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
                IPAD_KAR_LINK=$DISABLED_LINK_STYLE
              fi
              echo "Applying iphone specific changes on $INDEX_FILE file"
              sed -i -e 's|$iphoneT_plist|'"$IPHONE_TAB_STRING"'|g' $INDEX_FILE
              sed -i -e 's|$iphoneT_folder_name|'"$IPHONE_TAB_FOLDER_NAME"'|g' $INDEX_FILE
              sed -i -e 's|$iphoneT_kar|'"$IPHONE_TAB_KAR"'|g' $INDEX_FILE
              ##NEW START
              sed -i -e 's|$iPad_link|'"$IPAD_LINK"'|g' $INDEX_FILE
			   sed -i -e 's|$iPad_delink|'"$IPAD_LINK_UNLINK"'|g' $INDEX_FILE
              sed -i -e 's|$iPad_binary_label|'"$IPAD_BINARY_LABEL"'|g' $INDEX_FILE
              sed -i -e 's|$iPad_kar_link|'"$IPAD_KAR_LINK"'|g' $INDEX_FILE
              sed -i -e 's|$iPad_kar_label|'"$IPAD_KAR_LABEL"'|g' $INDEX_FILE
              ##NEW END

              echo "Done with applying iphone tab specific changes on $INDEX_FILE file"
            else
              echo "$INDEX_FILE does not exist"
              #echo "Exiting...."
              #exit
            fi
       fi
      ###END OF IPHONE TAB OTA
    else
      echo "iphone mobile / tablet related OTA not in scope"
    fi

    ## Checking if android mobile and/or tablet is in scope for this build and performing android mobile and/or tablet specific OTA activities
    if [ $ANDROID_ENABLED = "true" ] || [ $ANDROID_TAB_ENABLED = "true" ]; then
      echo "android mobile and/or tablet related OTA in scope"
      ANDROID_BINARY_LABEL=""
      ANDROID_LINK=""
      ANDROID_TAB_BINARY_LABEL=""
      ANDROID_TAB_LINK=""
	  ANDROID_LINK_UNLINK="true"
	  ANDROID_TAB_LINK_UNLINK="true"


      ###START OF ANDROID MOBILE OTA
      if [ $ANDROID_ENABLED = "true" ]; then
        ANDROID_FOLDER_NAME="android"
        echo "ANDROID_FOLDER_NAME => $ANDROID_FOLDER_NAME"
        ANDROID_STRING="$ANDROID_FOLDER_NAME/$ANDROID_BINARY"
        echo "ANDROID_STRING => $ANDROID_STRING"
        echo "Attempting to perform android mobile related OTA activities"
         if [ -d "$ANDROID_BINARY_PATH" ]; then
           echo "$ANDROID_BINARY_PATH exists"
           echo "Creating $ANDROID_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
           mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME
           if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME" ]; then
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME folder is in place"
             echo "ANDROID_BINARY => $ANDROID_BINARY"
             echo "Copying android mobile binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME folder"
             cp "$ANDROID_BINARY_PATH/$ANDROID_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME/$ANDROID_BINARY"
             if [ -f "$ANDROID_BINARY_PATH/$ANDROID_BINARY" ]; then
               echo "Successfully copied $ANDROID_BINARY to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME/$ANDROID_BINARY location"
               ANDROID_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
               echo "ANDROID_BINARY_LABEL value is set to :: $ANDROID_BINARY_LABEL"
             else
               echo "Could not copy $ANDROID_BINARY to $ANDROID_BINARY_PATH location"
               ANDROID_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
               echo "Changing ANDROID_BINARY_LABEL value to :: $ANDROID_BINARY_LABEL"
             fi
           else
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME folder does not exist"
			 ANDROID_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
           fi
          else
           echo "$ANDROID_BINARY_PATH does not exist"
		   ANDROID_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
         fi

            ## If INDEX_FILE template has been successfully copied in the previous steps above, apply android specific changes
             echo "Checking if template $INDEX_FILE is in place, and if found, apply android specific changes"
             if [ -f "$INDEX_FILE" ]; then
               echo "Template $INDEX_FILE is in place, applying android specific changes"
               if [ "$ANDROID_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
                 ANDROID_LINK=$DISABLED_LINK_STYLE
				 ANDROID_LINK_UNLINK="false"
               fi
               sed -i -e 's|$Android_Installer|'"$ANDROID_STRING"'|g' $INDEX_FILE
               ##NEW START
               sed -i -e 's|$android_link|'"$ANDROID_LINK"'|g' $INDEX_FILE
			   sed -i -e 's|$android_delink|'"$ANDROID_LINK_UNLINK"'|g' $INDEX_FILE
               sed -i -e 's|$android_binary_label|'"$ANDROID_BINARY_LABEL"'|g' $INDEX_FILE
               ##NEW END
               echo "Done with applying android specific changes on $INDEX_FILE file"
             else
               echo "$INDEX_FILE does not exist"
               #echo "Exiting...."
               #exit
             fi
      fi
      ###END OF ANDROID MOBILE OTA

      ###START OF ANDROID TAB OTA
      if [ $ANDROID_TAB_ENABLED = "true" ]; then
        ANDROID_TAB_FOLDER_NAME="androidTab"
        echo "ANDROID_TAB_FOLDER_NAME => $ANDROID_TAB_FOLDER_NAME"
        ANDROID_TAB_STRING="$ANDROID_TAB_FOLDER_NAME/$ANDROID_BINARY"
        echo "ANDROID_TAB_STRING => $ANDROID_TAB_STRING"
        echo "Attempting to perform android tab related OTA activities"
         if [ -d "$ANDROID_TAB_BINARY_PATH" ]; then
           echo "$ANDROID_TAB_BINARY_PATH exists"
           echo "Creating $ANDROID_TAB_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
           mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_TAB_FOLDER_NAME
           if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_TAB_FOLDER_NAME" ]; then
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_TAB_FOLDER_NAME folder is in place"
             echo "ANDROID_TAB_BINARY => $ANDROID_TAB_BINARY"
             echo "Copying android tab binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_TAB_FOLDER_NAME folder"
             cp "$ANDROID_TAB_BINARY_PATH/$ANDROID_TAB_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_TAB_FOLDER_NAME/$ANDROID_BINARY"
             if [ -f "$ANDROID_TAB_BINARY_PATH/$ANDROID_TAB_BINARY" ]; then
               echo "Successfully copied $ANDROID_TAB_BINARY to $ANDROID_TAB_BINARY_PATH location"
               ANDROID_TAB_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
               echo "ANDROID_TAB_BINARY_LABEL value is set to :: $ANDROID_TAB_BINARY_LABEL"
             else
               echo "Could not copy $ANDROID_TAB_BINARY to $ANDROID_TAB_BINARY_PATH location"
               ANDROID_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
               echo "Changing ANDROID_TAB_BINARY_LABEL value to :: $ANDROID_TAB_BINARY_LABEL"
             fi
           else
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_TAB_FOLDER_NAME folder does not exist"
			 ANDROID_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
           fi
          else
           echo "$ANDROID_TAB_BINARY_PATH does not exist"
			ANDROID_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL		   
         fi
		 ## If INDEX_FILE template has been successfully copied in the previous steps above, apply android specific changes
		 echo "Checking if template $INDEX_FILE is in place, and if found, apply android specific changes"
		 if [ -f "$INDEX_FILE" ]; then
		   echo "Template $INDEX_FILE is in place, applying android specific changes"
		   if [ "$ANDROID_TAB_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
			 ANDROID_TAB_LINK=$DISABLED_LINK_STYLE
			 ANDROID_TAB_LINK_UNLINK="false"
		   fi

		   sed -i -e 's|$AndroidT_Installer|'"$ANDROID_TAB_STRING"'|g' $INDEX_FILE
		   ##NEW START
		   sed -i -e 's|$android_tab_link|'"$ANDROID_TAB_LINK"'|g' $INDEX_FILE
		   sed -i -e 's|$android_tab_binary_label|'"$ANDROID_TAB_BINARY_LABEL"'|g' $INDEX_FILE
		   sed -i -e 's|$android_tab_delink|'"$ANDROID_TAB_LINK_UNLINK"'|g' $INDEX_FILE
		   ##NEW END
		   echo "Done with applying android tab specific changes on $INDEX_FILE file"
		 else
		   echo "$INDEX_FILE does not exist"
		   #echo "Exiting...."
		   #exit
		 fi
      fi
      ###END OF ANDROID TAB OTA

    else
      echo "android mobile / tablet related OTA not in scope"
    fi


    ## WINDOWS OTA START
    ## Checking if windows mobile and/or tablet is in scope for this build and performing windows mobile and/or tablet specific OTA activities
    if [ $WINDOWS8_ENABLED = "true" ]  || [ $WINDOWS81_ENABLED = "true" ] ; then
	#|| [ $WINDOWS8_TAB_ENABLED = "true" ]
	#|| [ $WINDOWS81_TAB_ENABLED = "true" ]
      echo "windows mobile and/or tablet related OTA in scope"
      WINDOWS8_BINARY_LABEL=""
      WINDOWS8_LINK=""
      #WINDOWS8_TAB_BINARY_LABEL=""
      #WINDOWS8_TAB_LINK=""
      WINDOWS81_BINARY_LABEL=""
      WINDOWS81_LINK=""
      #WINDOWS81_TAB_BINARY_LABEL=""
      #WINDOWS81_TAB_LINK=""
	  WINDOWS8_LINK_UNLINK="true"
	  WINDOWS81_LINK_UNLINK="true"


      ###START OF WINDOWS8 MOBILE OTA
      if [ $WINDOWS8_ENABLED = "true" ]; then
        WINDOWS8_FOLDER_NAME="windows8"
        echo "WINDOWS8_FOLDER_NAME => $WINDOWS8_FOLDER_NAME"
        WINDOWS8_STRING="$WINDOWS8_FOLDER_NAME/$WINDOWS8_BINARY"
        echo "WINDOWS8_STRING => $WINDOWS8_STRING"
        echo "Attempting to perform windows8 mobile related OTA activities"
         if [ -d "$WINDOWS8_BINARY_PATH" ]; then
           echo "$WINDOWS8_BINARY_PATH exists"
           echo "Creating $WINDOWS8_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
           mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_FOLDER_NAME
           if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_FOLDER_NAME" ]; then
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_FOLDER_NAME folder is in place"
             echo "WINDOWS8_BINARY => $WINDOWS8_BINARY"
             echo "Copying windows8 mobile binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_FOLDER_NAME folder"
             cp "$WINDOWS8_BINARY_PATH/$WINDOWS8_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_FOLDER_NAME/$WINDOWS8_BINARY"
             if [ -f "$WINDOWS8_BINARY_PATH/$WINDOWS8_BINARY" ]; then
               echo "Successfully copied $WINDOWS8_BINARY to $WINDOWS8_BINARY_PATH location"
               WINDOWS8_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
               echo "WINDOWS8_BINARY_LABEL value is set to :: $WINDOWS8_BINARY_LABEL"
             else
               echo "Could not copy $WINDOWS8_BINARY to $WINDOWS8_BINARY_PATH location"
               WINDOWS8_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
               echo "Changing WINDOWS8_BINARY_LABEL value to :: $WINDOWS8_BINARY_LABEL"
             fi
           else
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_FOLDER_NAME folder does not exist"
			 WINDOWS8_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
           fi
          else
           echo "$WINDOWS8_BINARY_PATH does not exist"
		   WINDOWS8_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
         fi
		 ## If INDEX_FILE template has been successfully copied in the previous steps above, apply windows8 specific changes
		 echo "Checking if template $INDEX_FILE is in place, and if found, apply windows8 specific changes"
		 if [ -f "$INDEX_FILE" ]; then
		   echo "Template $INDEX_FILE is in place, applying windows8 specific changes"
		   if [ "$WINDOWS8_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
			 WINDOWS8_LINK=$DISABLED_LINK_STYLE
			 WINDOWS8_LINK_UNLINK="false"
		   fi
		   sed -i -e 's|$Windows8_Installer|'"$WINDOWS8_STRING"'|g' $INDEX_FILE
		   ##NEW START
		   sed -i -e 's|$windows8_link|'"$WINDOWS8_LINK"'|g' $INDEX_FILE
		   sed -i -e 's|$windows8_binary_label|'"$WINDOWS8_BINARY_LABEL"'|g' $INDEX_FILE
		   sed -i -e 's|$win8_delink|'"$WINDOWS8_LINK_UNLINK"'|g' $INDEX_FILE
		   ##NEW END
		   echo "Done with applying windows8 specific changes on $INDEX_FILE file"
		 else
		   echo "$INDEX_FILE does not exist"
		   #echo "Exiting...."
		   #exit
		 fi
      fi
      ###END OF WINDOWS8 MOBILE OTA

      ###START OF WINDOWS8 TAB OTA
       if [ $WINDOWS8_TAB_ENABLED = "true" ]; then
         WINDOWS8_TAB_FOLDER_NAME="windows8Tab"
         echo "WINDOWS8_TAB_FOLDER_NAME => $WINDOWS8_TAB_FOLDER_NAME"
         WINDOWS8_TAB_STRING="$WINDOWS8_TAB_FOLDER_NAME/$WINDOWS8_TAB_BINARY"
         echo "WINDOWS8_TAB_STRING => $WINDOWS8_TAB_STRING"
         echo "Attempting to perform windows8 tab related OTA activities"
          if [ -d "$WINDOWS8_TAB_BINARY_PATH" ]; then
            echo "$WINDOWS8_TAB_BINARY_PATH exists"
            echo "Creating $WINDOWS8_TAB_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
            mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_TAB_FOLDER_NAME
            if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_TAB_FOLDER_NAME" ]; then
              echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_TAB_FOLDER_NAME folder is in place"
              echo "WINDOWS8_TAB_BINARY => $WINDOWS8_TAB_BINARY"
              echo "Copying windows8 tab binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_TAB_FOLDER_NAME folder"
              cp "$WINDOWS8_TAB_BINARY_PATH/$WINDOWS8_TAB_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_TAB_FOLDER_NAME/$WINDOWS8_TAB_BINARY"
                 if [ -f "$WINDOWS8_TAB_BINARY_PATH/$WINDOWS8_TAB_BINARY" ]; then
                   echo "Successfully copied $WINDOWS8_TAB_BINARY to $WINDOWS8_TAB_BINARY_PATH location"
                   WINDOWS8_TAB_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
                   echo "WINDOWS8_TAB_BINARY_LABEL value is set to :: $WINDOWS8_TAB_BINARY_LABEL"
                 else
                   echo "Could not copy $WINDOWS8_TAB_BINARY to $WINDOWS8_TAB_BINARY_PATH location"
                   WINDOWS8_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
                   echo "Changing WINDOWS8_TAB_BINARY_LABEL value to :: $WINDOWS8_TAB_BINARY_LABEL"
                 fi
      
            else
              echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS8_TAB_FOLDER_NAME folder does not exist"
	  			WINDOWS8_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
            fi
           else
            echo "$WINDOWS8_TAB_BINARY_PATH does not exist"
	  			WINDOWS8_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL	  
          fi
           ## If INDEX_FILE template has been successfully copied in the previous steps above, apply windows8 specific changes
              echo "Checking if template $INDEX_FILE is in place, and if found, apply android specific changes"
              if [ -f "$INDEX_FILE" ]; then
                echo "Template $INDEX_FILE is in place, applying android specific changes"
                  if [ "$WINDOWS8_TAB_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
                    WINDOWS8_TAB_LINK=$DISABLED_LINK_STYLE
                  fi
                sed -i -e 's|$Windows8T_Installer|'"$WINDOWS8_TAB_STRING"'|g' $INDEX_FILE
                 ##NEW START
                 sed -i -e 's|$windows8_tab_link|'"$WINDOWS8_TAB_LINK"'|g' $INDEX_FILE
                 sed -i -e 's|$windows8_tab_binary_label|'"$WINDOWS8_TAB_BINARY_LABEL"'|g' $INDEX_FILE
                 ##NEW END
                echo "Done with applying windows 8 tablet specific changes on $INDEX_FILE file"
              else
                echo "$INDEX_FILE does not exist"
                #echo "Exiting...."
                #exit
              fi
	  
       fi
      ###END OF WINDOWS8 TAB OTA


      ###START OF WINDOWS8.1 MOBILE OTA
      if [ $WINDOWS81_ENABLED = "true" ]; then
        WINDOWS81_FOLDER_NAME="windows81"
        echo "WINDOWS81_FOLDER_NAME => $WINDOWS81_FOLDER_NAME"
        WINDOWS81_STRING="$WINDOWS81_FOLDER_NAME/$WINDOWS81_BINARY"
        echo "WINDOWS81_STRING => $WINDOWS81_STRING"
        echo "Attempting to perform windows8.1 mobile related OTA activities"
         if [ -d "$WINDOWS81_BINARY_PATH" ]; then
           echo "$WINDOWS81_BINARY_PATH exists"
           echo "Creating $WINDOWS81_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
           mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_FOLDER_NAME
           if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_FOLDER_NAME" ]; then
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_FOLDER_NAME folder is in place"
             echo "WINDOWS81_BINARY => $WINDOWS81_BINARY"
             echo "Copying windows8.1 mobile binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_FOLDER_NAME folder"
             cp "$WINDOWS81_BINARY_PATH/$WINDOWS81_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_FOLDER_NAME/$WINDOWS81_BINARY"
             if [ -f "$WINDOWS81_BINARY_PATH/$WINDOWS81_BINARY" ]; then
               echo "Successfully copied $WINDOWS81_BINARY to $WINDOWS81_BINARY_PATH location"
               WINDOWS81_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
               echo "WINDOWS81_BINARY_LABEL value is set to :: $WINDOWS81_BINARY_LABEL"
             else
               echo "Could not copy $WINDOWS81_BINARY to $WINDOWS81_BINARY_PATH location"
               WINDOWS81_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
               echo "Changing WINDOWS81_BINARY_LABEL value to :: $WINDOWS81_BINARY_LABEL"
             fi
           else
             echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_FOLDER_NAME folder does not exist"
			 WINDOWS81_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
           fi
          else
           echo "$WINDOWS81_BINARY_PATH does not exist"
		   WINDOWS81_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
         fi
		 ## If INDEX_FILE template has been successfully copied in the previous steps above, apply windows8.1 specific changes
		 echo "Checking if template $INDEX_FILE is in place, and if found, apply android specific changes"
		 if [ -f "$INDEX_FILE" ]; then
		   echo "Template $INDEX_FILE is in place, applying android specific changes"
		   if [ "$WINDOWS81_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
			 WINDOWS81_LINK=$DISABLED_LINK_STYLE
			 WINDOWS81_LINK_UNLINK="false"
		   fi
		   sed -i -e 's|$Windows81_Installer|'"$WINDOWS81_STRING"'|g' $INDEX_FILE
		   ##NEW START
		   sed -i -e 's|$windows81_link|'"$WINDOWS81_LINK"'|g' $INDEX_FILE
		   sed -i -e 's|$windows81_binary_label|'"$WINDOWS81_BINARY_LABEL"'|g' $INDEX_FILE
		   sed -i -e 's|$win81_delink|'"$WINDOWS81_LINK_UNLINK"'|g' $INDEX_FILE
		   ##NEW END
		   echo "Done with applying android specific changes on $INDEX_FILE file"
		 else
		   echo "$INDEX_FILE does not exist"
		   echo "Exiting...."
		   exit
		 fi
      fi
      ###END OF WINDOWS8.1 MOBILE OTA

      ###START OF WINDOWS8.1 TAB OTA
       if [ $WINDOWS81_TAB_ENABLED = "true" ]; then
         WINDOWS81_TAB_FOLDER_NAME="windows81Tab"
         echo "WINDOWS81_TAB_FOLDER_NAME => $WINDOWS81_TAB_FOLDER_NAME"
         WINDOWS81_TAB_STRING="$WINDOWS81_TAB_FOLDER_NAME/$WINDOWS81_TAB_BINARY"
         echo "WINDOWS81_TAB_STRING => $WINDOWS81_TAB_STRING"
         echo "Attempting to perform windows8.1 tab related OTA activities"
          if [ -d "$WINDOWS81_TAB_BINARY_PATH" ]; then
            echo "$WINDOWS81_TAB_BINARY_PATH exists"
            echo "Creating $WINDOWS81_TAB_FOLDER_NAME folder under $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
            mkdir -p $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_TAB_FOLDER_NAME
            if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_TAB_FOLDER_NAME" ]; then
              echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_TAB_FOLDER_NAME folder is in place"
              echo "WINDOWS81_TAB_BINARY => $WINDOWS81_TAB_BINARY"
              echo "Copying windows8.1 tab binary to $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_TAB_FOLDER_NAME folder"
              cp "$WINDOWS81_TAB_BINARY_PATH/$WINDOWS81_TAB_BINARY" "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_TAB_FOLDER_NAME/$WINDOWS81_TAB_BINARY"
                 if [ -f "$WINDOWS81_TAB_BINARY_PATH/$WINDOWS81_TAB_BINARY" ]; then
                   echo "Successfully copied $WINDOWS81_TAB_BINARY to $WINDOWS81_TAB_BINARY_PATH location"
                   WINDOWS81_TAB_BINARY_LABEL=$STD_INSTALL_LINK_LABEL
                   echo "WINDOWS81_TAB_BINARY_LABEL value is set to :: $WINDOWS81_TAB_BINARY_LABEL"
                 else
                   echo "Could not copy $WINDOWS81_TAB_BINARY to $WINDOWS81_TAB_BINARY_PATH location"
                   WINDOWS81_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
                   echo "Changing WINDOWS81_TAB_BINARY_LABEL value to :: $WINDOWS81_TAB_BINARY_LABEL"
                 fi
            else
              echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$WINDOWS81_TAB_FOLDER_NAME folder does not exist"
             WINDOWS81_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL	  
            fi
           else
            echo "$WINDOWS81_TAB_BINARY_PATH does not exist"
		     WINDOWS81_TAB_BINARY_LABEL=$ARTEFACT_UNAVAILABLE_LABEL
          fi
			## If INDEX_FILE template has been successfully copied in the previous steps above, apply windows8.1 specific changes
              echo "Checking if template $INDEX_FILE is in place, and if found, apply android specific changes"
              if [ -f "$INDEX_FILE" ]; then
                echo "Template $INDEX_FILE is in place, applying android specific changes"
                  if [ "$WINDOWS81_TAB_BINARY_LABEL" != "$STD_INSTALL_LINK_LABEL" ]; then
                    WINDOWS81_TAB_LINK=$DISABLED_LINK_STYLE
                  fi
                sed -i -e 's|$Windows81T_Installer|'"$WINDOWS81_TAB_STRING"'|g' $INDEX_FILE
                 ##NEW START
                  sed -i -e 's|$windows81_tab_link|'"$WINDOWS81_TAB_LINK"'|g' $INDEX_FILE
                  sed -i -e 's|$windows81_tab_binary_label|'"$WINDOWS81_TAB_BINARY_LABEL"'|g' $INDEX_FILE
                 ##NEW END
                echo "Done with applying windows 8.1 Tab specific changes on $INDEX_FILE file"
              else
                echo "$INDEX_FILE does not exist"
                echo "Exiting...."
                exit
              fi
       fi
      ###END OF WINDOWS8.1 TAB OTA

    else
      echo "windows mobile / tablet related OTA not in scope"
    fi

    ## WINDOWS OTA END

  else
    echo "$TEMPLATE_FILES_PATH does not exist"
    #echo "Exiting...."
    #exit
  fi

  #Removing backup files created while replacing template content
  if [ -f "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/index.html-e" ]; then
    echo "Deleting backup index file $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/index.html-e"
    rm -f $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/index.html-e
  fi
  if [ -f "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone.plist-e" ]; then
    echo "Deleting backup plist file $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone.plist-e"
    rm -f $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphone.plist-e
  fi
  if [ -f "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphoneT.plist-e" ]; then
    echo "Deleting backup plist file $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphoneT.plist-e"
    rm -f $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/iphoneT.plist-e
  fi
  if [ $KCI_ENABLE_S3_PUBLISH = "true" ]; then
  	echo "Listing the OTA contents"
  	ls -ltra "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/"
  	ls -ltra "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$IPHONE_FOLDER_NAME"
  	ls -ltra "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR/$ANDROID_FOLDER_NAME"
  
  	## Publish the created OTA artefacts to S3 bucket
  	##START
  	if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR" ]; then
	    echo "Trying to publish contents of $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR to S3 bucket"
	    echo "Changing directory to $OTA_TEMP_DIR/$OTA_SUB_DIR"
	    cd $OTA_TEMP_DIR/$OTA_SUB_DIR
	    echo "Now Issuing the following cp command on S3"
	    #echo "aws s3 cp $TGT_DIR $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR --recursive"
	    #aws s3 cp $TGT_DIR $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR --recursive
	    #echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/"
	    #aws s3 ls $S3_SERVER_URL/$S3_SUB_FOLDER_URL/
	    #echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/"
	    #aws s3 ls $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/
	    #echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR/"
	    #aws s3 ls $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR/

	   # echo "AWS_ACCESS_KEY_ID=$KCI_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$KCI_AWS_SECRET_ACCESS_KEY $KCI_AWS_CLI_CMD s3 cp $TGT_DIR $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR --recursive"
	    #AWS_ACCESS_KEY_ID=$KCI_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$KCI_AWS_SECRET_ACCESS_KEY $KCI_AWS_CLI_CMD s3 cp $TGT_DIR $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR --recursive
	   # echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/"
	    #AWS_ACCESS_KEY_ID=$KCI_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$KCI_AWS_SECRET_ACCESS_KEY $KCI_AWS_CLI_CMD s3 ls $S3_SERVER_URL/$S3_SUB_FOLDER_URL/
	    #echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/"
	    #AWS_ACCESS_KEY_ID=$KCI_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$KCI_AWS_SECRET_ACCESS_KEY $KCI_AWS_CLI_CMD s3 ls $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/
	    #echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR/"
	    #AWS_ACCESS_KEY_ID=$KCI_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$KCI_AWS_SECRET_ACCESS_KEY $KCI_AWS_CLI_CMD s3 ls $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR/
	    
	    echo "$KCI_AWS_CLI_CMD s3 cp --profile $KCI_S3_PROFILE_NAME $TGT_DIR $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR --recursive"
	    $KCI_AWS_CLI_CMD s3 cp --profile Kony $TGT_DIR $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR --recursive
	    echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/"
	    $KCI_AWS_CLI_CMD s3 ls --profile $KCI_S3_PROFILE_NAME $S3_SERVER_URL/$S3_SUB_FOLDER_URL/
	    echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/"
	    $KCI_AWS_CLI_CMD s3 ls --profile $KCI_S3_PROFILE_NAME $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/
	    echo "Listing contents of $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR/"
	    $KCI_AWS_CLI_CMD s3 ls --profile $KCI_S3_PROFILE_NAME $S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME/$TGT_DIR/


	    echo "Done with attempt to publish to s3 bucket!!"
	  else
	    echo "Unable to find $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder!!"
	  fi
	  ##END
	  echo "DONE with S3 Publish!!!"
	else 
	  ## Publish the created OTA artefacts to Tomcat OTA
	  ##START
	  KCI_TOMCAT_OTA_DIR=$S3_SERVER_URL/$S3_SUB_FOLDER_URL/$JOB_NAME
	  if [ ! -d "$KCI_TOMCAT_OTA_DIR" ]; then
		mkdir -p $KCI_TOMCAT_OTA_DIR
	  fi
	  if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR" ]; then
		echo "Trying to publish contents of $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR to Tomcat"
		echo "Changing directory to $OTA_TEMP_DIR/$OTA_SUB_DIR"
		cd $OTA_TEMP_DIR/$OTA_SUB_DIR
		echo "Now Issuing the following cp command on Tomcat"
		if [ ! -d "$KCI_TOMCAT_OTA_DIR/$TGT_DIR" ]; then
			mkdir -p $KCI_TOMCAT_OTA_DIR/$TGT_DIR
		fi
		echo "cp $TGT_DIR $KCI_TOMCAT_OTA_DIR/$TGT_DIR "
		cp -r $TGT_DIR $KCI_TOMCAT_OTA_DIR 
		echo "Listing contents of $KCI_TOMCAT_OTA_DIR/"
		ls $KCI_TOMCAT_OTA_DIR/
		echo "Listing contents of $KCI_TOMCAT_OTA_DIR/$TGT_DIR/"
		ls $KCI_TOMCAT_OTA_DIR/$TGT_DIR/
   
		echo "Done with attempt to publish to Tomcat!!"
	  else
		echo "Unable to find $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder!!"
	  fi
	  ##END
	    echo "DONE with Tomcat Publish!!!"
	fi
	
   #Code to remove contents of OTA_TEMP_DIR
   #Checking if the OTA_TEMP_DIR exists
   if [ -d "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR" ]; then	
		echo "$OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR folder"
		#Navigating to the directory.
		echo "$OTA_TEMP_DIR/$OTA_SUB_DIR exists"
		echo "navigating to $OTA_TEMP_DIR/$OTA_SUB_DIR"
		cd $OTA_TEMP_DIR/$OTA_SUB_DIR
		#Renaming the current build folder to temp so to delete the previous folders using the common name build.
		echo "renaming $TGT_DIR to temp"
		mv  $TGT_DIR temp
		echo "Deleting the previous build folders"
		rm -rf build*/
		#Renaming the folder back to build $BUILD_NO
		echo "Renaming the current build folder from temp to $TGT_DIR"
		mv temp $TGT_DIR
		#Removing all the folders and files in build 
		#except .html files which are used for email purpose.
		echo "copying the index.html file to $OTA_TEMP_DIR/$OTA_SUB_DIR"
		mv $TGT_DIR/*.html $OTA_TEMP_DIR/$OTA_SUB_DIR
		#removing the files in the $TGT_DIR
		echo "removing all the files & folders inside $TGT_DIR"
		rm -rf $TGT_DIR/*
		echo "copying the index.html file back to $TGT_DIR"
		mv $OTA_TEMP_DIR/$OTA_SUB_DIR/*.html $OTA_TEMP_DIR/$OTA_SUB_DIR/$TGT_DIR
		ls
	else
		echo "Folder doesn't exists"
	fi
	#End of code to remove contents of OTA_TEMP_DIR.
	
else
  echo "Error:: Wrong number of parameters, check again!! $# number of parameters have been entered!!"
  echo "Usage is as below:::"
  echo "ArchiveAndEnableOTA.sh JOB_NAME IPHONE_BINARY_NAME IPHONE_TAB_BINARY_NAME %BUILD_NUMBER% OTA_TEMP_DIR OTA_SUB_DIR IPHONE_BINARY_PATH IPHONE_BINARY IPHONE_TAB_BINARY_PATH IPHONE_TAB_BINARY ANDROID_BINARY_PATH ANDROID_BINARY ANDROID_TAB_BINARY_PATH ANDROID_TAB_BINARY WINDOWS8_BINARY_PATH WINDOWS8_BINARY WINDOWS81_BINARY_PATH WINDOWS81_BINARY TEMPLATE_FILES_PATH BUNDLE_IDENTIFIER APP_ID CHANNELS BUILD_DETAILS S3_SERVER_URL S3_SUB_FOLDER_URL S3_OTA_URL EXECUTE_PIPELINE BUILD_MACHINE_OS ANDROID_TARGET_SLAVE_IN_PIPE_LINE NOTIFICATION_FOLDER"
  #echo "Exiting...."
  #exit
fi

#############ENDING#####################
