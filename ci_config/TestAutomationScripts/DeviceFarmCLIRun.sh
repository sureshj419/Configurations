#!/bin/sh
projectArn="$1"
AndroidBinaryFile="$2"
TestFile="$3"
iPhoneBinaryFile="$4"
projectName="$5"
propertyFile="$6"

cd "$WORKSPACE"

echo `pwd`

if [ "$#" -eq 6 ]; then
	echo "Correct number of parameters"
	if [ -f "$propertyFile" ]; then
		echo "The property file $propertyFile found."

		while IFS='=' read -r key value
		do
		  eval "${key}='${value}'"
		done < "$propertyFile"
	
		status="INITIALIZED"
		if [[ $TestAndroidPhone = "true" || $TestAndroidTablet = "true" ]]; then
			echo
			echo "-----------------------------------------------------------"
			echo "Creating upload of Android application binary to devicefarm project"
			echo "-----------------------------------------------------------"
			
			AppType="ANDROID_APP"
			uploadAppOutput=`aws devicefarm create-upload --project-arn ${projectArn} --name ${AndroidBinaryFile} --type ${AppType} --region ${awsregion} --query upload.[arn,url]`

			uploadAppOutput=${uploadAppOutput//[$'\t\r\n\" \[\]']}

			uploadAppArn=`echo $uploadAppOutput | awk -F"," '{print $1}'`
			uploadAppUrl=`echo $uploadAppOutput | awk -F"," '{print $2}'`

			echo "Upload Application ARN is ::"$uploadAppArn
			echo "Upload Application URL is ::"$uploadAppUrl
			echo
			echo "-----------------------------------------------------"
			echo "Uploading the Android application binary to the provided URL"
			echo "-----------------------------------------------------"

			curl -T ${AndroidBinaryFile} ${uploadAppUrl}
			echo "Uploading the application binary is in progress"
			
			while [ $status != "SUCCEEDED" ]
			do
				sleep 5
				status=`aws devicefarm get-upload --arn ${uploadAppArn} --region ${awsregion} --query upload.status`
				status=`echo "${status//[$'\t\r\n ']}"`
				status=`echo "${status//\"}"`
				
				if [ $status = "FAILED" ]; then
					break
				fi
			done
			echo "Uploading the Android application binary is completed"
		fi
		
		if [[ $TestIPhone = "true" || $TestIPad = "true" ]]; then
			echo
			echo "-----------------------------------------------------------"
			echo "Creating upload of IOS application binary to devicefarm project"
			echo "-----------------------------------------------------------"
			
			AppType="IOS_APP"
			uploadAppOutput=`aws devicefarm create-upload --project-arn ${projectArn} --name ${iPhoneBinaryFile} --type ${AppType} --region ${awsregion} --query upload.[arn,url]`

			uploadAppOutput=${uploadAppOutput//[$'\t\r\n\" \[\]']}

			uploadAppArnIOS=`echo $uploadAppOutput | awk -F"," '{print $1}'`
			uploadAppUrlIOS=`echo $uploadAppOutput | awk -F"," '{print $2}'`

			echo "Upload Application ARN is ::"$uploadAppArnIOS
			echo "Upload Application URL is ::"$uploadAppUrlIOS
			echo
			echo "-----------------------------------------------------"
			echo "Uploading the IOS application binary to the provided URL"
			echo "-----------------------------------------------------"

			curl -T ${iPhoneBinaryFile} ${uploadAppUrlIOS}
			echo "Uploading the application binary is in progress"
			status="INITIALIZED"
			
			while [ $status != "SUCCEEDED" ]
			do
				sleep 5
				status=`aws devicefarm get-upload --arn ${uploadAppArnIOS} --region ${awsregion} --query upload.status`
				status=`echo "${status//[$'\t\r\n ']}"`
				status=`echo "${status//\"}"`
				
				if [ $status = "FAILED" ]; then
					break
				fi
			done
			echo "Uploading the iPhone application binary is completed"
		fi
		
		if [ $status = "SUCCEEDED" ]; then
			echo "Uploading the application binary is completed"
			echo
			echo "-----------------------------------------------------------"
			echo "Creating upload of test package to devicefarm project"
			echo "-----------------------------------------------------------"
			
			uploadTestOutput=`aws devicefarm create-upload --project-arn ${projectArn} --name ${TestFile} --type APPIUM_JAVA_TESTNG_TEST_PACKAGE --region ${awsregion} --query upload.[arn,url]`
			
			uploadTestOutput=${uploadTestOutput//[$'\t\r\n\" \[\]']}
			
			uploadTestArn=`echo $uploadTestOutput | awk -F"," '{print $1}'`
			uploadTestUrl=`echo $uploadTestOutput | awk -F"," '{print $2}'`
			
			echo "Upload Tests ARN is ::"$uploadTestArn
			echo "Upload Tests URL is ::"$uploadTestUrl
			echo
			echo "-----------------------------------------------------"
			echo "Uploading the test package to the provided URL"
			echo "-----------------------------------------------------"
				
			curl -T ${TestFile} ${uploadTestUrl}
			echo "Uploading Test package is in progress"
			status="INITIALIZED"
			
			while [ $status != "SUCCEEDED" ]
			do
				sleep 5
				status=`aws devicefarm get-upload --arn ${uploadTestArn} --region ${awsregion} --query upload.status`
				status=`echo "${status//[$'\t\r\n ']}"`
				status=`echo "${status//\"}"`
				
				if [ $status = "FAILED" ]; then
					break
				fi
			done
			
			if [ $status = "SUCCEEDED" ]; then
				echo "Uploading Test package is completed"
				
				DevicesNotAvailable='#'
				devicePoolArn=''

				createDevicePool() {
					old_IFS=$IFS
					IFS=","
					devicecount=0
					DeviceRules=''
					DevicesNotAvail=''
					devicePoolArn=''
					awsregion=$5
					
					for device in $1;
					do
						tmpdevice=`echo $device`
						echo "Device Name :::: $device"
						tempdeviceArn=`aws devicefarm list-devices --region ${awsregion} --query "devices[?starts_with(name,'$tmpdevice') && formFactor=='$2']|[0].arn"`
						tempdeviceArn=`echo "${tempdeviceArn//[$'\r']}"`
						tempdeviceArn=`echo "${tempdeviceArn//\"}"`
						
						IFS=${old_IFS}
						
						if [ $tempdeviceArn == "null" ]; then
							DevicesNotAvail=`echo "$DevicesNotAvail,$tmpdevice"`
						else
							if [ $devicecount == 0 ]; then
								
									DeviceRules=`echo '{"operator":"IN","attribute":"ARN","value":"[\"'$tempdeviceArn`
									devicecount=$((devicecount+1))
							else
								DeviceRules=`echo $DeviceRules'\",\"'$tempdeviceArn`
							fi
						fi
					done
					if [[ $DeviceRules != '' ]]; then
						DeviceRules=`echo $DeviceRules'\"]"}'`
						echo "DeviceRules :::: $DeviceRules"
						
						tempdevicepoolName="\`${3}\`"
						devicelist=`aws devicefarm list-device-pools --arn ${4} --region ${awsregion} --query devicePools[?name==${tempdevicepoolName}]`
						devicelist=`echo "${devicelist//[$'\]\r,\[ ']}"`
						deviceExists=${#devicelist[0]}
						
						if [ $deviceExists == 0 ]; then
							echo "No device pool exists with name :: "${3}
							echo
							echo "-----------------------------------------------------"
							echo "Creating Device Pool with name :: "${3}
							echo "-----------------------------------------------------"
							
							devicePoolArn=`aws devicefarm create-device-pool --project-arn ${4} --name ${3} --rules "${DeviceRules}" --region ${awsregion} --query devicePool.arn`
							
							devicePoolArn=`echo "${devicePoolArn//[$'\t\r\n ']}"`
							devicePoolArn=`echo "${devicePoolArn//\"}"`
							
							echo "Created Device Pool with ARN ::"$devicePoolArn
							echo "-----------------------------------------------------"
						else
							echo "Device pool exists with name :: "${3}
							
							devicelist=`echo "${devicelist}" | grep devicepool:`
							devicelist=`echo "${devicelist//\"}"`
							devicePoolArn=`echo "${devicelist/'arn:'}"`
							
							echo
							echo "-----------------------------------------------------"
							echo "Updating Device Pool with name :: "${3}
							echo "-----------------------------------------------------"
							
							devicePoolArn=`aws devicefarm update-device-pool --arn ${devicePoolArn} --rules "${DeviceRules}" --region ${awsregion} --query devicePool.arn`
							
							devicePoolArn=`echo "${devicePoolArn//[$'\t\r\n ']}"`
							devicePoolArn=`echo "${devicePoolArn//\"}"`
							
							echo "Updated Device Pool with ARN ::"$devicePoolArn
							echo "-----------------------------------------------------"
						fi
						return 0
					else
						return 1
					fi

					IFS=${old_IFS}
					return 0
				}
				
				scheduleRun() {
					echo
					echo "-----------------------------------------------------"
					echo "Scheduling run using the above created devicepool"
					echo "-----------------------------------------------------"
							
					runArn=`aws devicefarm schedule-run --project-arn ${1} --app-arn ${2} --device-pool-arn ${3} --test type=APPIUM_JAVA_TESTNG,testPackageArn=${4} --region ${5} --query run.arn`
					
					runArn=`echo "${runArn//[$'\t\r\n ']}"`
					runArn=`echo "${runArn//\"}"`
					echo
					echo "-----------------------------------------------------"
					echo "Scheduled run for Android with ARN :: $runArn for above device pool"
					echo "-----------------------------------------------------"
					if [ -z "$runArnList" ]; then 
						runArnList=${runArn}
					else
						runArnList=`echo "${runArnList},${runArn}"`
					fi
				}
					
				if [ $TestAndroidPhone = "true" ]; then
					DevicePoolName=`echo "${projectName}_AndroidPhoneDevices"`
					createDevicePool "$AndroidPhoneDevices" "PHONE" "${DevicePoolName}" "${projectArn}" "${awsregion}"
					DevicesNotAvailable=`echo "$DevicesNotAvailable,$DevicesNotAvail"`
					
					isPoolCreated=$?
					echo "isPoolCreated :::: $isPoolCreated"
					if [[ $isPoolCreated == 0 ]]; then
						DevicePool=`echo "${DevicePool},${DevicePoolName}"`
						scheduleRun "${projectArn}" "${uploadAppArn}" "${devicePoolArn}" "${uploadTestArn}" "${awsregion}"
					else
						echo
						echo "-----------------------------------------------------"
						echo "Device Pool not created. Unable to schedule the Run"
						echo "-----------------------------------------------------"
					fi
				fi
				
				if [[ $TestIPhone = "true" ]]; then
					DevicePoolName=`echo "${projectName}_IPhoneDevices"`
					createDevicePool "$IPhoneDevices" "PHONE" "${DevicePoolName}" "${projectArn}" "${awsregion}"
					DevicesNotAvailable=`echo "$DevicesNotAvailable,$DevicesNotAvail"`
					
					isPoolCreated=$?
					if [[ $isPoolCreated == 0 ]]; then
						DevicePool=`echo "${DevicePool},${DevicePoolName}"`
						scheduleRun "${projectArn}" "${uploadAppArnIOS}" "${devicePoolArn}" "${uploadTestArn}" "${awsregion}"
					else
						echo
						echo "-----------------------------------------------------"
						echo "Device Pool not created. Unable to schedule the Run"
						echo "-----------------------------------------------------"
					fi
				fi
				
				if [ $TestAndroidTablet = "true" ]; then
					DevicePoolName=`echo "${projectName}_AndroidTabletDevices"`
					createDevicePool "$AndroidTabletDevices" "TABLET" "${DevicePoolName}" "${projectArn}" "${awsregion}"
					DevicesNotAvailable=`echo "$DevicesNotAvailable,$DevicesNotAvail"`
					
					isPoolCreated=$?
					echo "isPoolCreated :::: $isPoolCreated"
					if [[ $isPoolCreated == 0 ]]; then
						DevicePool=`echo "${DevicePool},${DevicePoolName}"`
						scheduleRun "${projectArn}" "${uploadAppArn}" "${devicePoolArn}" "${uploadTestArn}" "${awsregion}"
					else
						echo
						echo "-----------------------------------------------------"
						echo "Device Pool not created. Unable to schedule the Run"
						echo "-----------------------------------------------------"
					fi
				fi
				
				if [[ $TestIPad = "true" ]]; then
					DevicePoolName=`echo "${projectName}_IPadDevices"`
					createDevicePool "$IPadDevices" "TABLET" "${DevicePoolName}" "${projectArn}" "${awsregion}"
					DevicesNotAvailable=`echo "$DevicesNotAvailable,$DevicesNotAvail"`
					
					isPoolCreated=$?
					if [[ $isPoolCreated == 0 ]]; then
						DevicePool=`echo "${DevicePool},${DevicePoolName}"`
						scheduleRun "${projectArn}" "${uploadAppArnIOS}" "${devicePoolArn}" "${uploadTestArn}" "${awsregion}"
					else
						echo
						echo "-----------------------------------------------------"
						echo "Device Pool not created. Unable to schedule the Run"
						echo "-----------------------------------------------------"
					fi
				fi
				
				if [ -z "$runArnList" ]; then
					echo
					echo "-----------------------------------------------------------"
					echo "The Run List is empty. Script not initiated for getting the Results"
					echo "-----------------------------------------------------------"
				else
					echo
					echo "-----------------------------------------------------------"
					echo "Initiate the script for getting the test results and artifacts"
					echo "-----------------------------------------------------------"
					prefixcomma=","
					DevicePool=${DevicePool#$prefixcomma}
					
					"${WORKSPACE}"/ci_config/TestAutomationScripts/DeviceFarmCLIResults.sh $runArnList $AndroidBinaryFile $TestFile "$DevicePool" "${awsregion}" $iPhoneBinaryFile "${projectName}" "${DevicesNotAvailable}"
					echo
					echo "-----------------------------------------------------------"
					echo "Completed getting the test results and test artifacts"
					echo "-----------------------------------------------------------"
				fi
			else
				echo "Uploading Test package is not successfull with status :: $status"
			fi
		else
			echo "Uploading application binary is not successfull with status :: $status"
		fi
	else
		echo "The property file $propertyFile not found."
	fi
else
  echo "Wrong number of parameters!!"
fi
