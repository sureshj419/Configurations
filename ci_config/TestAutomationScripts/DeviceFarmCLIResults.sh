#!/bin/sh
runArnList="$1"
AndroidBinaryFile="$2"
TestFile="$3"
DevicePool="$4"
awsregion="$5"
iPhoneBinaryFile="$6"
projectName="$7"
DevicesNotAvailable="$8"

INDEX_FILE="${WORKSPACE}/index.html"

cd "$WORKSPACE"
cp -f "./ci_config/notification_templates/df_test_results.html" "$INDEX_FILE"
##"./index.html"

TEST_STATUS="PASSED"

if [ "$#" -eq 8 ]; then
  echo "Correct number of parameters"
  echo "The RUN ARN list is ::: "${runArnList}
  	RUN_TEMPLATE="<h2 class='test-result-name'>Project Name : ${projectName}</h2><h3 class='test-result-name'>Selected Device Pools : ${DevicePool}</h3><h3 class='test-result-name'>Devices Not Available in Devicefarm : ${DevicesNotAvailable}</h3>"
	sed -i -e 's|$NEW_JOB_TEMPLATE|'"$RUN_TEMPLATE"'$NEW_JOB_TEMPLATE|' "$INDEX_FILE"
	for tempRunArn in $(echo $runArnList | sed "s/,/ /g")
	do	
		status="RUNNING"
		while [[ $status != "COMPLETED" ]]
		do
			sleep 30
			status=`aws devicefarm get-run --arn ${tempRunArn} --region ${awsregion} --query run.status`
			status=`echo "${status//[$'\t\r\n ']}"`
			status=`echo "${status//\"}"`
			echo " Run Status is :::: "$status
			
			if [ $status = "FAILED" ]; then
				break
			fi
		done
		if [[ $status = "COMPLETED" ]]; then
			echo "************Run completed*****************"
			
			runOutput=`aws devicefarm get-run --arn ${tempRunArn} --region ${awsregion} --query run.[name,totalJobs,platform]`
			runOutput=${runOutput//[$'\t\r\n\" \[\]']}

			AppName=`echo $runOutput | awk -F"," '{print $1}'`
			totalJobs=`echo $runOutput | awk -F"," '{print $2}'`
			AppPlatform=`echo $runOutput | awk -F"," '{print $3}'`
				
			echo "total jobs"${totalJobs}
			totalJobs=$((totalJobs-1))
			
			for i in $(seq -f "%05g" 0 ${totalJobs})
			do
				tempRunArn="${tempRunArn/run/job}"
				jobArn=`echo ${tempRunArn}/${i}`
				
				jobDetails=`aws devicefarm get-job --arn ${jobArn} --region ${awsregion} --query job.[name,counters.total]`
				jobDetails=${jobDetails//[$'\t\r\n\"\[\]']}
					
				jobName=`echo $jobDetails | awk -F"," '{print $1}'`
				jobName=`echo "${jobName//\&/\\&}"`
				echo "Job Name ::: "$jobName
				
				TABLE_TEMPLATE="<h3 class='test-result-name'>************************************************************************</h3><p>Job Name(Device) : ${jobName} , Binary Name(${AppPlatform}) : ${AppName} </p><h3 class='test-result-name'>************************************************************************</h3><table class='test-result-table' cellspacing='0'><thead><tr><td class='test-result-table-header-cell'><b>Name</b></td><td class='test-result-table-header-cell'><b>URL</b></td><td class='test-result-table-header-cell'><b>Status</b></td></tr></thead><tbody>TEST_ARTIFACTS_ROWS</tbody></table>"
				
				sed -i -e 's|$NEW_JOB_TEMPLATE|'"$TABLE_TEMPLATE"'$NEW_JOB_TEMPLATE|' "$INDEX_FILE"
				artifactRow=""
				listSuites=`aws devicefarm list-suites --arn ${jobArn} --region ${awsregion} --query "suites[*].name|length(@)"`
                totalSuites=${listSuites//[$'\t\r\n\"\[\]']}
				echo "total Suites"${totalSuites}
				totalSuites=$((totalSuites-1))
				
				for j in $(seq -f "%05g" 0 ${totalSuites})
				do
					jobArn="${jobArn/job/suite}"
					suiteArn=`echo ${jobArn}/${j}`
					
					suiteDetails=`aws devicefarm get-suite --arn ${suiteArn} --region ${awsregion} --query suite.[name,counters.total]`
					suiteDetails=${suiteDetails//[$'\t\r\n\"\[\]']}
                    suiteName=`echo $suiteDetails | awk -F"," '{print $1}'`
					totalTests=`echo $suiteDetails | awk -F"," '{print $2}'`
                    echo "Suite Nmae : $suiteName"
					echo "total Tests"${totalTests}
					SUITE_ROW="<tr><td class='test-result-table-header-cell' colspan='2'><b>Suite Name : ${suiteName}</b></td><td class='test-result-table-header-cell'><b>Total Tests : ${totalTests}</b></td></tr>"
					artifactRow="${artifactRow}${SUITE_ROW}"
					
					totalTests=$((totalTests-1))
					
					for k in $(seq -f "%05g" 0 ${totalTests})
					do
						suiteArn="${suiteArn/suite/test}"
						testArn=`echo ${suiteArn}/${k}`
						
						testDetails=`aws devicefarm get-test --arn ${testArn} --region ${awsregion} --query test.[result,name]`
						testDetails=${testDetails//[$'\t\r\n\"\[\]']}
						testStatus=`echo $testDetails | awk -F"," '{print $1}'`
						testName=`echo $testDetails | awk -F"," '{print $2}'`
						echo "Test Nmae : $testName"
						echo "Test Status"${testStatus}
						artifactStatus=`echo "${testStatus//\"}"`
						TEST_ROW="<tr><td class='test-result-table-header-cell'  colspan='2'><b>Test Name : ${testName}</b></td><td class='test-result-table-header-cell'></td></tr>"
						artifactRow="${artifactRow}${TEST_ROW}"
						
						if [[ $artifactStatus = "FAILED" ]]; then
							TEST_STATUS="FAILED"
						fi
					
						testArtifacts=`aws devicefarm list-artifacts --arn ${testArn} --type FILE --region ${awsregion} --query 'artifacts[*].{NAME:name,URL:url}'`
						testArtifacts=${testArtifacts//[$'\t\r\n\" \[\]']}
						testArtifacts="$(echo $testArtifacts | sed 's/},{/#/g')"
						testArtifacts="$(echo $testArtifacts | sed 's/{//g')"
						testArtifacts="$(echo $testArtifacts | sed 's/}//g')"
						
						prefixURL="URL:"
						prefixNAME="NAME:"
						old_IFS=$IFS
						IFS="#"
						
						for testArtifactsTemp in $testArtifacts;
						do
							artifactURL=`echo $testArtifactsTemp | awk -F"," '{print $1}'`
							artifactURL=${artifactURL#$prefixURL}
							
							artifactName=`echo $testArtifactsTemp | awk -F"," '{print $2}'`
							artifactName=${artifactName#$prefixNAME}
							echo "artifactName ::: "$artifactName
							artifactURL=`echo "${artifactURL//\&/\\&}"`
							echo "artifactURL ::: "$artifactURL
							artifactRow="${artifactRow}<tr class='test-result-step-row test-result-step-row-altone' style='display: true;'><td class='test-result-step-command-cell'>${artifactName}</td><td class='test-result-step-result-cell-notperformed'><a style='' href='$artifactURL'>Click here to download File</a></td><td class='test-result-step-command-cell'>${artifactStatus}</td></tr>"
							
						done
						IFS=${old_IFS}

						
					done
				done
			sed -i -e 's|TEST_ARTIFACTS_ROWS|'"$artifactRow"'|' "$INDEX_FILE"
			done
		else
			echo "There is an issue with the RUN!!"
		fi
	done
	sed -i -e 's|$NEW_JOB_TEMPLATE|'" "'|' "$INDEX_FILE"
	echo -e "\r\nTEST_EXECUTION_STATUS=$TEST_STATUS\r\nNOTIFICATION_TEMPLATE=$INDEX_FILE" >> "${WORKSPACE}/ci_config/DeviceFarmCLI.properties"
else
  echo "Wrong number of parameters!!"
fi
