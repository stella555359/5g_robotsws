*** Settings ***
Documentation
...            [Author]         "Nandini R"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Resource	   ${CURDIR}/../resources/Common_Twamp.robot
Resource       ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


***Variables***
${EGATE_CONFIG}				${CURDIR}/../resources/egate_configuration.lua
${source_file}				/tmp/192.168.255.129_scf.xml
${Back_up_file}				/tmp/backup_scf.xml
${delta_dup_file}			${CURDIR}/../resources/Twamp_dup_Configuration_file.xml
${delta_dup_twamp_file}		${CURDIR}/../resources/Twamp_dup_Config_file.xml

***Test Cases***
[1][1.0] 1.0 TRS_574_TWAMP configuration with BTS Site Manager exceptions

#Step1:
	Check Boundary conditions for TWAMP measurement related parameters

#Step2:
	Check Measurement parameters cannot be changed while TWAMP session is active

#Step3:
	Check that user cannot start the measurement without giving all mandatory values

#Step4:
	Perform commissioning with with illegal values
	Compare and Exit if unexpected alarm exists after reconfiguration

*** Keywords ***

Compare and Exit if unexpected alarm exists after reconfiguration
    FOR    ${ELEMENT}  IN  @{SEM_Updation_alarms}
       Log    ${ELEMENT}
       ${status}=     run_keyword_and_return_status       Should Contain  ${SEM_alarms}   ${ELEMENT}
       ${alarmCount}=    Get Index From List    ${SEM_Updation_alarms}     ${ELEMENT}
       LOG     ${alarmCount}
       Run Keyword If     '${status}'=='True' and '${alarmCount}'>='0'     Remove From List  ${SEM_Updation_alarms}    ${alarmCount}
       LOG     ${SEM_Updation_alarms}
    END

    Log         Unexpected Alarms:
    FOR    ${ELEMENT}    IN    @{SEM_Updation_alarms}
        Log            ${ELEMENT}
    END
    Should Be Empty   ${SEM_Updation_alarms}


Check Boundary conditions for TWAMP measurement related parameters
    Run Keyword And Expect Error    *It is required that IPADDRESSV4.localIpAddr not equal to \${TWAMP-1.destIpAddress} (value: 10.0.1.2)*
    ...     Perform Parameter Comm Without Reset       MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:destIpAddress:update:10.0.1.2
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'twampDscp', u'error':*
    ...     Perform Parameter Comm Without Reset        MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:twampDscp:update:64
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'twampDscp', u'error':*
    ...     Perform Parameter Comm Without Reset        MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:twampDscp:update:-1
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'messageSize', u'error':*
    ...     Perform Parameter Comm Without Reset      MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:messageSize:update:65
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'messageSize', u'error':*
    ...     Perform Parameter Comm Without Reset      MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:messageSize:update:1401
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'plrAlarmThreshold', u'error':*
    ...     Perform Parameter Comm Without Reset        MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:plrAlarmThreshold:update:10001
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'plrAlarmThreshold', u'error':*
    ...     Perform Parameter Comm Without Reset        MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:plrAlarmThreshold:update:-1
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'rttAlarmThreshold', u'error':*
    ...     Perform Parameter Comm Without Reset        MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:rttAlarmThreshold:update:1000001
    Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'rttAlarmThreshold', u'error':*
    ...     Perform Parameter Comm Without Reset        MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:rttAlarmThreshold:update:-1

	Run     cp ${delta_file} ${delta_dup_file}
    Run     sudo sed -i 's/TWAMP-1/TWAMP-2/g' ${delta_dup_file}
	Run Keyword And Expect Error    AdminApiProcedureFailureException*    Perform ENB delta without reset			${delta_dup_file}

	FOR	${i}	IN RANGE	2	101
			Run     cp ${delta_file} ${delta_dup_file}
    		Run     sudo sed -i 's/TWAMP-1/TWAMP-${i}/g' ${delta_dup_file}
			Run     sudo sed -i 's/name="twampDscp">34/name="twampDscp">${i}/g' ${delta_dup_file}
			Set Suite variable		${delta_dup_file}		${delta_dup_file}
	END
	Sleep	300
	Run		rm -rf ${delta_dup_file}


Expect Error
	Run Keyword And Expect Error    AdminApiProcedureFailureException*    Perform Recommissioning

Check Measurement parameters cannot be changed while TWAMP session is active
	Run Keyword And Expect Error    AdminApiProcedureFailureException*    Perform Parameter comm without reset
    ... 		MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:destIpAddress:update:10.0.1.10
	Run Keyword And Expect Error    AdminApiProcedureFailureException*    Perform Parameter comm without reset
    ... 		MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:sourceIpAddress:update:10.0.1.10
	Run Keyword And Expect Error    AdminApiProcedureFailureException*    Perform Parameter comm without reset
    ... 		MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:destPort:update:5000

Check that user cannot start the measurement without giving all mandatory values
	Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'plrAlarmThreshold', u'error':*
    ...     Perform Parameter comm without reset		MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1:plrAlarmThreshold:update:-1

Perform commissioning with with illegal values
	Run     cp ${delta_file} ${delta_dup_file}
#fix
	Run     sudo sed -i 's/create/update/g' ${delta_dup_file}

	Run     sudo sed -i 's/name="twampReflectorPort">34/name="twampReflectorPort">70000/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="twampMessageRate">34/name="twampMessageRate">RATE_100/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="destIpAddress">34/name="destIpAddress">10.48.103.1290/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="destPort">34/name="destPort">5000000/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="twampDscp">34/name="twampDscp">340/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="messageSize">34/name="messageSize">50/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="plrAlarmThreshold">34/name="plrAlarmThreshold">100000/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="rttAlarmThreshold">34/name="rttAlarmThreshold">10000000/g' ${delta_dup_file}
	Run     sudo sed -i 's/name="sourceIpAddress">34/name="sourceIpAddress">10.48.103.1310/g' ${delta_dup_file}
	Run Keyword And Expect Error    *MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-1', u'parameter': u'twampDscp', u'error':*
    ...     Perform ENB delta without reset			${delta_dup_file}

Perform ENB delta without reset
    [Arguments]    ${delta_file}
	Run		python ${Covert_to_json} -o ${output_delta_json} ${delta_file}

Perform Parameter comm without reset
    [Arguments]    ${Param_value}
    @{param_list}= 		Split String		${Param_value}		:
    Perform Recommissioning    dist_name=@{param_list}[0]		 parameter=@{param_list}[1]		operation=@{param_list}[2]
    ... 		value=@{param_list}[3]