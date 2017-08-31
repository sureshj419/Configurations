#!/bin/sh

propertyFile="$1"
ProjectName="$2"
APK_NAME="$3"
IPA_NAME="$4"
BASE_FOLDER="$5"

cd "$WORKSPACE"

echo `pwd`

if [ "$#" -eq 5 ]; then
  echo "Correct number of parameters"
  if [ -f "$propertyFile" ]; then
    echo "The property file $propertyFile found."

    while IFS='=' read -r key value
    do
      eval "${key}='${value}'"
    done < "$propertyFile"
	
	echo
	echo "-----------------------------------------------------------"
	echo "Creating devicefarm project with the AppID"
	echo "-----------------------------------------------------------"

	tempprojectName="\`${ProjectName}\`"
	projectslist=`aws devicefarm list-projects --region ${awsregion} --query projects[?name==${tempprojectName}]`
	projectslist=`echo "${projectslist//[$'\]\r,\[ ']}"`
	projectExists=${#projectslist[0]}

		if [ $projectExists == 0 ];	then
			echo "No project exists with name :: "${ProjectName}
			projectArn=`aws devicefarm create-project --name ${ProjectName} --region ${awsregion} --query project.arn`
			projectArn=`echo "${projectArn//[$'\t\r\n ']}"`
			projectArn=`echo "${projectArn//\"}"`
		else
			echo "Project exists with name :: "${ProjectName}
			projectslist=`echo "${projectslist}" | grep project:`
			projectslist=`echo "${projectslist//\"}"`
			projectArn=`echo "${projectslist/'arn:'}"`
		fi
		
		echo "Project ARN is ::"$projectArn
		
		echo "Testing for Android Phone :: "$TestAndroidPhone
		echo "Testing for IPhone Phone :: "$TestIPhone
		if [[ $TestAndroidPhone = "true" || $TestIPhone = "true" ]]; then
			sleep 30
			echo
			echo "-----------------------------------------------------------"
			echo "Copying the App binary and Test package to the workspace"
			echo "-----------------------------------------------------------"
			binaryExists="false"
			testPackageExists="false"
			ANDROID_PHONE_BINARY=${BASE_FOLDER}/android/$APK_NAME
			IPHONE_BINARY=${BASE_FOLDER}/iphone/$IPA_NAME
			
			if [[ $TestAndroidPhone = "true" ]]; then
				
				while [[ $binaryExists != "true" ]]
				do
					sleep 30
					aws s3 cp ${ANDROID_PHONE_BINARY} . 
				
					if [ -f "$APK_NAME" ]; then
	    					echo "The android binary file $APK_NAME found."
	    					binaryExists="true"
	    				fi
					echo " binaryExists is :::: "$binaryExists
				done
				 
			fi
			if [[ $TestIPhone = "true" ]]; then
				binaryExists="false"
				
				while [[ $binaryExists != "true" ]]
				do
					sleep 30
					aws s3 cp ${IPHONE_BINARY} . 
				
					if [ -f "$IPA_NAME" ]; then
	    					echo "The iphone binary file $IPA_NAME found."
	    					binaryExists="true"
	    				fi
	    			done
			fi
			TestFile="${ProjectName}_TestApp.zip"
			if [ -f "$TestFile" ]; then
    				echo "The test file $TestFile found."
    				testPackageExists="true"
    			fi
			
			if [[ $binaryExists = "true" && $testPackageExists = "true" ]]; then
				echo
				echo "-----------------------------------------------------------"
				echo "Initiate the testing for ANDROID/IPHONE Mobiles"
				echo "-----------------------------------------------------------"
				./ci_config/TestAutomationScripts/DeviceFarmCLIRun.sh $projectArn $APK_NAME $TestFile $IPA_NAME "${ProjectName}" "$propertyFile"
				echo
				echo "-----------------------------------------------------------"
				echo "Testing completed for ANDROID/IPHONE Mobiles"
				echo "-----------------------------------------------------------"
			else
				echo "The required files binary or test file not found."
				echo "The test file found is ::: "$testPackageExists
				echo "The binary file found is ::: "$binaryExists
			fi
		fi
		
		
		echo "Testing for Android Tablet :: "$TestAndroidTablet
		echo "Testing for IPAD :: "$TestIPad
		if [[ $TestAndroidTablet = "true" || $TestIPad = "true" ]]; then
			sleep 30
			echo
			echo "-----------------------------------------------------------"
			echo "Copying the App binary and Test package to the workspace"
			echo "-----------------------------------------------------------"
			binaryExists="false"
			testPackageExists="false"
			ANDROID_TAB_BINARY=${BASE_FOLDER}/androidTab/$APK_NAME
			IPAD_BINARY=${BASE_FOLDER}/ipad/$IPA_NAME
			
			if [[ $TestAndroidTablet = "true" ]]; then
				
				while [[ $binaryExists != "true" ]]
				do
					sleep 30
					aws s3 cp ${ANDROID_TAB_BINARY} . 
				
					if [ -f "$APK_NAME" ]; then
	    					echo "The android binary file $APK_NAME found."
	    					binaryExists="true"
	    				fi
					echo " binaryExists is :::: "$binaryExists
				done
				 
			fi
			if [[ $TestIPad = "true" ]]; then
				binaryExists="false"
				
				while [[ $binaryExists != "true" ]]
				do
					sleep 30
					aws s3 cp ${IPAD_BINARY} . 
				
					if [ -f "$IPA_NAME" ]; then
	    					echo "The ipad binary file $IPA_NAME found."
	    					binaryExists="true"
	    				fi
	    			done
			fi
			TestFile="${ProjectName}_TestApp.zip"
			if [ -f "$TestFile" ]; then
    				echo "The test file $TestFile found."
    				testPackageExists="true"
    			fi
			
			if [[ $binaryExists = "true" && $testPackageExists = "true" ]]; then
				echo
				echo "-----------------------------------------------------------"
				echo "Initiate the testing for ANDROID Tablet/IPAD"
				echo "-----------------------------------------------------------"
				./ci_config/TestAutomationScripts/DeviceFarmCLIRun.sh $projectArn $APK_NAME $TestFile $IPA_NAME "${ProjectName}" "$propertyFile"
				echo
				echo "-----------------------------------------------------------"
				echo "Testing completed for ANDROID Tablet/IPAD"
				echo "-----------------------------------------------------------"
			else
				echo "The required files binary or test file not found."
				echo "The test file found is ::: "$testPackageExists
				echo "The binary file found is ::: "$binaryExists
			fi
		fi
 else
    echo "The property file $propertyFile not found."
  fi
else
  echo "Wrong number of parameters!!"
fi
