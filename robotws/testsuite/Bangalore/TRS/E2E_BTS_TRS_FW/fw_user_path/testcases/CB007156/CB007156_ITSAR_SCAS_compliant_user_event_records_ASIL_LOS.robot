*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate Certifictes installed properly or not"
    ...     [Date]                  "05-06-2021"
    ...     [Author]                "Shankar Kumar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "CMP"
    ...     [Feature_ID]            "CB007156"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "XXXXXXX"
    ...     [Config]    	    "gNB should configured"

Force Tags         CA_E2ET_BTSTRSPZ        SBTS00    SBTS23R3     4G_FDD         QCD_MN_RAN        QCP_RAN_ET      CRT

variables       ta_e2e_bts_trs_fw
Resource       ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB007156_ITSAR & SCAS compliant user event records_ASIL_LOS

###Pre-Condition
    Perform Commissioning    scf_file=${cmp_full_commissioning_with_wrong_path}   verify_bts_status=False   timeout=600
    Sleep   200
    Verify Alarm	faultid=${CMP_retrival_fault_ID}	alarm_type=active    severity=major	should_exist=${True}
    Reset Bts   should_be_onair=False
    Sleep   200
    Verify Alarm	faultid=${CMP_retrival_fault_ID}	alarm_type=active    severity=major	should_exist=${True}
    #Add eventlog check
    ${event_logs}=	Get Infomodel Dump    dist_name_regex=SYSTEM_LOG
    ${logs}=           Get Dictionary Values       ${event_logs}
    ${cnt}=    Get length    ${logs}
    Log	 ${cnt}
    ${index}    Set Variable    ${0}
    FOR            ${i}        IN      @{logs}
    	${KeyIsPresent}=    Run Keyword And Return Status       Dictionary Should Contain Key       ${i}
        ...     additionalText
    	${data}=           Run Keyword If      ${KeyIsPresent}==True     Get From Dictionary             ${i}
        ...  additionalText
    	Log		${data}
    	${data}=	Convert To String	${data}
        ${data}=    Remove String       ${data}     "
    	${index}=    Evaluate    ${index}+1
        Run Keyword If	 "${data}" == cert_fail 	Set Suite Variable        ${mark}	yes
    	Exit For Loop IF	  	"${data}" == cert_fail
    END
    Log		${index}
    Should be equal     ${mark}        yes
    Perform Recommissioning   type=param    param_path=${CMP_Sever_Path}    operation=update
    ...      value=${CMP_Path}   timeout=300
    Reset Bts   should_be_onair=False
    Sleep   200
    Verify Alarm	faultid=${CMP_retrival_fault_ID}	alarm_type=active    severity=major	should_exist=${False}
    #Add eventlog check
    ${event_logs}=	Get Infomodel Dump    dist_name_regex=SYSTEM_LOG
    ${logs}=           Get Dictionary Values       ${event_logs}
    ${cnt}=    Get length    ${logs}
    Log	 ${cnt}
    ${index}    Set Variable    ${0}
    FOR            ${i}        IN      @{logs}
    	${KeyIsPresent}=    Run Keyword And Return Status       Dictionary Should Contain Key       ${i}
        ...     additionalText
    	${data}=           Run Keyword If      ${KeyIsPresent}==True     Get From Dictionary             ${i}
        ...     additionalText
    	Log		${data}
    	${data}=	Convert To String	${data}
        ${data}=    Remove String       ${data}     "
    	${index}=    Evaluate    ${index}+1
        Run Keyword If		"${data}" == cert_pass	Set Suite Variable   ${mark} 	yes2
    	Exit For Loop IF	  	"${data}" == cert_pass
    END
    Log		${index}
    Should be equal     ${mark}        yes2
    Configure Switch	device=device_bh		command_profile=shutdown_port
    sleep   200
    Verify Alarm	faultid=${LOS_fault_ID}    alarm_type=active    severity=Critical	should_exist=${True}
    ${event_logs}=	Get Infomodel Dump    dist_name_regex=SYSTEM_LOG
    ${logs}=           Get Dictionary Values       ${event_logs}
    ${cnt}=    Get length    ${logs}
    Log     ${cnt}
    ${index}    Set Variable    ${0}
    FOR    ${i}    IN    @{logs}
       ${KeyIsPresent}=    Run Keyword And Return Status       Dictionary Should Contain Key       ${i}
       ...  additionalText
       ${data}=           Run Keyword If      ${KeyIsPresent}==True     Get From Dictionary             ${i}
       ...     additionalText
       Log     ${data}
       ${data}=    Convert To String   ${data}
       ${data}=    Remove String       ${data}     "
       ${index}=    Evaluate    ${index}+1
       Run Keyword If     "${data}" == "SM-1011 61029: LOS on SMOD-1, EIF1 with state disabled"  Set Suite Variable
       ...  ${mark}   yes3
       Exit For Loop IF        "${data}" == "SM-1011 61029: LOS on SMOD-1, EIF1 with state disabled"
    END
    Should be equal     ${mark}        yes3
    Configure Switch	device=device_bh		command_profile=enable_port
    sleep   200
    Verify Alarm	faultid=${LOS_fault_ID}    alarm_type=active    severity=major	should_exist=${False}

