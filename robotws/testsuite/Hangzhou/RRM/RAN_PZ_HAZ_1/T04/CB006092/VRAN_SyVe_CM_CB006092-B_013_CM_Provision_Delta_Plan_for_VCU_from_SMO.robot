*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB006092-B_013_CM_Provision delta plan for SBTS from SMO for vCU
...                and RAN_ST_CB006092-B_025_C&P_Duration of CM Provision Operation from SMO for delta plan in vCU
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${cu_oamssh_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${e2e_provision_outage_duration_cu}    660
${e2e_provision_no_outage_duration_cu}    180

*** Keywords ***
VRAN_SyVe_CM_CB006092-B_013_CM_Provision_Delta_Plan_for_VCU_from_SMO
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    07.07.2025, lixin.kang@nokia-sbell.com
    Step 1: Provision Delta Plan Contain Online Parameter On NetConf
    Step 2: Check Online Parameter Be Updated On NetAct
    Step 3: Check Online Operation Feedback and CCN Message On VES
    Step 4: Provision Delta Plan Contain Locking Parameter On NetConf
    Step 5: Check Locking Parameter Be Updated On NetAct
    Step 6: Check Locking Operation Feedback and CCN Message On VES
    Step 7: Provision Delta Plan Contain RatReset Parameter On NetConf
    Step 8: Check RatReset Parameter Be Updated On NetAct
    Step 9: Check RatReset Operation Feedback and CCN Message On VES
    Step 10: Check RatReset Parameter Be Updated On VES

Step ${index}: Provision Delta Plan Contain ${Type} Parameter On NetConf
    Log To Console    Step ${index}: Provision Delta Plan Contain ${Type} Parameter On NetConf
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_${Type}_${time}.xml
    ${fileName_updated}    Set Variable    onap_${Type}_${time}_updated.xml
    Set Test Variable    ${fileName_init}
    Login To vCU By Rest
    ${current_value}    Get Parameter Value From vCU   ${paramScfDN_${Type}}    ${paramName_${Type}}
    Remove Values From List    ${paramValuesPool_${Type}}    ${current_value}
    ${valueToSet}    Evaluate    random.choice(${paramValuesPool_${Type}})    modules=random, sys
    ${paramXpathOnap}    Transfer SCF DN To Xpath Of ONAP Get Result    ${paramScfDN_${Type}}
    ${paramNA_dic}    Create Dictionary    ${paramName_${Type}}=${valueToSet}
    Set Test Variable    ${paramNA_dic}
    Set Test Variable    ${valueToSet}
    ${paramValue_dic}    Create Dictionary
    Run Keyword If    "${Type}"=="Online"    Set to Dictionary    ${paramValue_dic}    ${paramName_Online}=${valueToSet}
    Run Keyword If    "${Type}"=="Locking"    Set to Dictionary    ${paramValue_dic}    ${paramName_Locking}=${valueToSet}
    Run Keyword If    "${Type}"=="RatReset"    Set to Dictionary    ${paramValue_dic}     ${paramName_RatReset}=${valueToSet}
    Set Test Variable    ${paramValue_dic}
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ${paramXpathOnap}/attributes/${paramName_${Type}} --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 160s
    Set Test Variable    ${cmd_getConfig}
    #Simulator
    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
	${param_dic}    Create Dictionary     ${paramScfDN_${Type}}=${paramValue_dic}
	Generate Delta Plan For NetConf    ${param_dic}    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	Start Ves Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	${start_time}    Get Time
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${ONAP["host_ip"]}    ${ONAP["user"]}
	...    ${ONAP["pwd"]}    ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n
	Check ${Type} Parameter Action On VCU
	Wait Until Keyword Succeeds    10min    60s    Check All Cells On Air In vCU
	Wait Until Keyword Succeeds    10min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
	${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
	Run Keyword If    "${Type}"=="Online" 	Should Be True    ${time}<${e2e_provision_no_outage_duration_cu}
    ...    ELSE IF    "${Type}"=="RatReset"    Should Be True    ${time}<${e2e_provision_outage_duration_cu}

Step ${index}: Check ${Type} Parameter Be Updated On NetAct
    Log To Console    Step ${index}: Check ${Type} Parameter Be Updated On NetAct
    Wait Until Keyword Succeeds    10x    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vCU_id}    dist_name=PLMN-PLMN/${paramScfDN_${Type}}   ui_values=${True}    &{paramNA_dic}

Check ${Type} Parameter Action On VCU
    Log To Console    Check ${Type} Parameter Action On VCU
    Run Keyword If    "${Type}"== "RatReset"    Check VCU Resetting
    ...    ELSE IF    "${Type}"== "Online"     Check vCU Online

Step ${index}: Check ${Type} Parameter Be Updated On VES
    Log To Console    Step ${index}: Check ${Type} Parameter Be Updated On VES
    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}   ${TEST_LOG_DIRECTORY}/${fileName_init}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${fileName_init}
    Should Contain    ${file_content}    <${paramName_RatReset}>${valueToSet}</${paramName_RatReset}>

Step ${index}: Check ${Type} Operation Feedback and CCN Message On VES
    Log To Console    Step ${index}: Check ${Type} Operation Feedback and CCN Message On VES
    ${op}    Set Variable If    "${Type}"=="Online" or "${Type}"=="Locking"   replace    add
    ${VES_CCN_msgs}    Stop Ves Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    vCU    ${vesSourceName}    provision    completed
    Log    ${target_VES_CCN_feedback}
    Should Be True    "${target_VES_CCN_feedback.__len__()}">="${1}"
	${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${paramScfDN_${Type}}   vCU    ${vesSourceName}    ${dnPrefix}    ${cu_oamssh_ip}    ${op}    ${paramValue_dic}
    Log    ${target_VES_CCN_msg}
    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"

Set Test Data
    ${paramName_Online}    Set Variable    a1MeashoPrefNRLayerEnabled
    @{paramValuesPool_Online}    Create List    rsrp    rsrpAndRsrq
    ${paramScfDN_Online}    Set Variable    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${paramName_Locking}    Set Variable    actAperCsi
    @{paramValuesPool_Locking}    Create List    true    false
    ${paramScfDN_Locking}    Set Variable    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${paramName_RatReset}    Set Variable    actNonBfAndBfCa
    @{paramValuesPool_RatReset}     Create List    true    false
    ${paramScfDN_RatReset}    Set Variable    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRDU-1
    Set Test Variable    ${paramName_Online}
    Set Test Variable    ${paramValuesPool_Online}
    Set Test Variable    ${paramScfDN_Online}
    Set Test Variable    ${paramName_Locking}
    Set Test Variable    ${paramValuesPool_Locking}
    Set Test Variable    ${paramScfDN_Locking}
    Set Test Variable    ${paramName_RatReset}
    Set Test Variable    ${paramValuesPool_RatReset}
    Set Test Variable    ${paramScfDN_RatReset}

Check VCU Resetting
    Wait Until Keyword Succeeds    300s    3s    Check IP Is Pingable    ${cu_oamssh_ip}    expect_pingable=${False}
    Wait Until Keyword Succeeds    300s    3s    Check IP Is Pingable    ${cu_oamssh_ip}    expect_pingable=${True}

Check vCU Online
    FOR    ${index}    IN RANGE    5
        Check All Cells On Air In vCU
        Sleep    10s
    END

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vDU}
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vcu_id}    ${cu_release}    ${cu_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate VDU To ONAP Simulator    ${vCU_id}    ${ONAP['host_ip']}
    Login To vCU By Rest
    ${vesSourceName}    Get Parameter Value From vCU     MRBTS-${vCU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vCU     MRBTS-${vCU_id}   dnPrefix
    Set Test Variable    ${dnPrefix}
    Set Test Data

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    Teardown NetAct