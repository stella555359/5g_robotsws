*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}        ${False}
${needRecovery}       False

*** Keywords ***
SyVe_CM_CB007010-B_004_Provision_Delta_Plan_With_Partial_Activation_Operation
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:TA_RAN_ST_CB007010-B_B2_003_CM_Provision delta plan for SBTS from SMO
    ...  The main steps performed for the test are:
    ...  - Provision Online Parameter With noServiceLossAllowed Success On NetConf
    ...  - Check Online Parameter Be Updated On NetAct
    ...  - Check Online Operation Feedback and CCN Message On VES
    ...  - Provision SiteReset Parameter With partialServiceLossAllowed Failed On NetConf
    ...  - Provision RatReset Parameter With forcedPlanFileActivation Success On NetConf
    ...  - Check RatReset Parameter Be Updated On NetAct
    ...  - Check RatReset Operation Feedback and CCN Message On VES
    ...  - Provision ObjLock Parameter With enableAutoLockFalse Failed On NetConf
    ...  - Provision ObjLock Parameter With enableAutoLockTrue Success On NetConf
    ...  - Check ObjLock Parameter Be Updated On NetAct
    ...  - Check ObjLock Operation Feedback and CCN Message On VES
    ...  Pass criteria: Provision delta plan from NetConf,and check parameter value on NetAct and CCN on ONAP.
    ...  Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.08.2023 - New case

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Provision Online Parameter With noServiceLossAllowed Success On NetConf
    Step 2: Check Online Parameter Be Updated On NetAct
    Step 3: Check Online Operation Feedback and CCN Message On VES
    Step 4: Provision SiteReset Parameter With partialServiceLossAllowed Failed On NetConf
    Step 5: Provision RatReset Parameter With forcedPlanFileActivation Success On NetConf
    Step 6: Check RatReset Parameter Be Updated On NetAct
    Step 7: Check RatReset Operation Feedback and CCN Message On VES
    Step 8: Provision ObjLock Parameter With enableAutoLockFalse Failed On NetConf
    Step 9: Provision ObjLock Parameter With enableAutoLockTrue Success On NetConf
    Step 10: Check ObjLock Parameter Be Updated On NetAct
    Step 11: Check ObjLock Operation Feedback and CCN Message On VES


Step ${index}: Provision ${Type} Parameter With ${Condition} Success On NetConf
    Log To Console    Step ${index}: Provision ${Type} Parameter With ${Condition} Success On NetConf
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_${Type}_${time}.xml
    ${fileName_updated}    Set Variable    onap_${Type}_${time}_updated.xml
    ${current_value}    Get Parameter Value From WebEM    ${paramScfDN_${Type}}    ${paramName_${Type}}
    Run Keyword If    "${Type}"=="Online"    Set Test Variable    ${current_value_Online}    ${current_value}
    Run Keyword If    "${Type}"=="RatReset"    Set Test Variable    ${current_value_RatReset}     ${current_value}
    Run Keyword If    "${Type}"=="ObjLock"    Set Test Variable    ${current_value_ObjLock}     ${current_value}
    Remove Values From List    ${paramValuesPool_${Type}}    ${current_value}
    ${valueToSet}    Evaluate    random.choice(${paramValuesPool_${Type}})    modules=random, sys
    ${paramXpathOnap}    Transfer SCF DN To Xpath Of ONAP Get Result    ${paramScfDN_${Type}}
    ${paramXpathOnap_LTE}    Transfer SCF DN To Xpath Of ONAP Get Result    ${paramScfDN_LTE}

    #used for check on Netact
    ${valueToSetNA}    Run Keyword If    "${valueToSet}"=="off"    Set Variable    0
    ...    ELSE IF    "${valueToSet}"=="on"    Set Variable    1
    ...    ELSE IF    "${valueToSet}"=="true"    Set Variable    1
    ...    ELSE IF    "${valueToSet}"=="false"    Set Variable    0
    ...    ELSE    Set Variable    ${valueToSet}
    ${paramNA_dic}    Create Dictionary    ${paramName_${Type}}=${valueToSetNA}
    Set Test Variable    ${paramNA_dic}
    #used for CCN check
    ${paramValue_dic}    Create Dictionary
    Run Keyword If    "${Type}"=="Online"    Set to Dictionary    ${paramValue_dic}    ${paramName_Online}=${valueToSet}
    Run Keyword If    "${Type}"=="RatReset"    Set to Dictionary    ${paramValue_dic}     ${paramName_RatReset}=${valueToSet}
    Run Keyword If    "${Type}"=="ObjLock"    Set to Dictionary    ${paramValue_dic}     ${paramName_ObjLock}=${valueToSet}
    Set Test Variable    ${paramValue_dic}
    #used for onap plan
    ${tmp_dic1}    Create Dictionary     planFileActivationMode=noServiceLossAllowed    forcedPlanFileActivation=false    enableAutoLock=Enabled
    ${tmp_dic2}    Create Dictionary     planFileActivationMode=noServiceLossAllowed    forcedPlanFileActivation=true    enableAutoLock=Enabled
    ${tmp_dic3}    Create Dictionary     planFileActivationMode=totalServiceLossAllowed    forcedPlanFileActivation=true    enableAutoLock=Enabled
    ${param_dic}    Create Dictionary     ${paramScfDN_${Type}}=${paramValue_dic}
    Run Keyword If    "${Type}"=="Online"    Set To Dictionary    ${param_dic}    ${paramScfDN_LTE}=${tmp_dic1}
    Run Keyword If    "${Type}"=="RatReset"    Set To Dictionary    ${param_dic}    ${paramScfDN_LTE}=${tmp_dic2}
    Run Keyword If    "${Type}"=="ObjLock"    Set To Dictionary    ${param_dic}    ${paramScfDN_LTE}=${tmp_dic3}
    ${tmp}    Set Variable    ${paramXpathOnap_LTE}/attributes
    ${filter}    Set Variable
    ...    ${paramXpathOnap}/attributes/${paramName_${Type}}|${tmp}/planFileActivationMode|${tmp}/forcedPlanFileActivation|${tmp}/enableAutoLock
    ${cmd_getConfig}    Set Variable    get-config --source running --filter-xpath ${filter} --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 180s

    #Simulator
    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
	Generate Delta Plan For NetConf    ${param_dic}    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}
	Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
	Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	...   ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n
	Set Test Variable    ${needRecovery}    True
	Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

    # below are used for real ONAP
#    Exucute One Command On Netconf CLI
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_getConfig}
#    Get File From Pod To Local    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}
#    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
#    Generate Delta Plan For NetConf    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}    ${paramONAP_dic}
#    Put File From Local To Pod    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}
#    ...    /tmp/${Test Results Dir}/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
#    ${LogFile}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}
#    ...    BTS_ID=${BTS_ID}    smod_SN=${Primary_SN}
#    Set Test Variable    ${LogFile}
#    ${output}    Exucute One Command On Netconf CLI
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_editConfig}
#    Should Contain    ${output}    \r\nOK\r\n
#    Set Test Variable    ${needRecovery}    True
#    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check ${Type} Parameter Be Updated On NetAct
    Log To Console    Step ${index}: Check Parameter Be Updated On NetAct
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${paramScfDN_${Type}}    &{paramNA_dic}

Step ${index}: Check ${Type} Operation Feedback and CCN Message On VES
    Log To Console    Step ${index}: Check ${Type} Operation Feedback and CCN Message On VES
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
    Log    ${target_VES_CCN_feedback}
    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1}
	${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${paramScfDN_${Type}}    ${Primary_SN}    ${MPLANE_IP}    replace    ${paramValue_dic}
    Log    ${target_VES_CCN_msg}
    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"

    #below are real ONAP
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile}
#    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
#    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
#    Log    ${target_VES_CCN_feedback}
#    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1}
#    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
#    ...    ${VES_CCN_msgs}    ${paramScfDN_${Type}}    ${Primary_SN}    ${MPLANE_IP}    replace    ${paramValue_dic}
#    log    ${target_VES_CCN_msg}
#    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"


Step ${index}: Provision ${Type} Parameter With ${Condition} Failed On NetConf
    Log To Console    Step ${index}: Provision ${Type} Parameter With ${Condition} Failed On NetConf
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_${time}.xml
    ${fileName_updated}    Set Variable    onap_${time}_updated.xml
    ${current_value}    Get Parameter Value From WebEM    ${paramScfDN_${Type}}    ${paramName_${Type}}
    Remove Values From List    ${paramValuesPool_${Type}}    ${current_value}
    ${valueToSet}    Evaluate    random.choice(${paramValuesPool_${Type}})    modules=random, sys
    ${paramXpathOnap}    Transfer SCF DN To Xpath Of ONAP Get Result    ${paramScfDN_${Type}}
    ${paramXpathOnap_LTE}    Transfer SCF DN To Xpath Of ONAP Get Result    ${paramScfDN_LTE}
    ${paramValue_dic}    Create Dictionary
    Run Keyword If    "${Type}"=="SiteReset"    Set to Dictionary    ${paramValue_dic}    ${paramName_SiteReset}=${valueToSet}
    Run Keyword If    "${Type}"=="ObjLock"    Set to Dictionary    ${paramValue_dic}     ${paramName_ObjLock}=${valueToSet}
    Set Test Variable    ${paramValue_dic}
    #used for onap plan
    ${tmp_dic4}    Create Dictionary    planFileActivationMode=partialServiceLossAllowed    forcedPlanFileActivation=false    enableAutoLock=Enabled
    ${tmp_dic5}    Create Dictionary     planFileActivationMode=totalServiceLossAllowed    forcedPlanFileActivation=true    enableAutoLock=Disabled
    ${param_dic}    Create Dictionary     ${paramScfDN_${Type}}=${paramValue_dic}
    Run Keyword If    "${Type}"=="SiteReset"    Set To Dictionary    ${param_dic}    ${paramScfDN_LTE}=${tmp_dic4}
    Run Keyword If    "${Type}"=="ObjLock"    Set To Dictionary    ${param_dic}    ${paramScfDN_LTE}=${tmp_dic5}
    ${tmp}    Set Variable    ${paramXpathOnap_LTE}/attributes
    ${filter}    Set Variable
    ...    ${paramXpathOnap}/attributes/${paramName_${Type}}|${tmp}/planFileActivationMode|${tmp}/forcedPlanFileActivation|${tmp}/enableAutoLock
    ${cmd_getConfig}    Set Variable    get-config --source running --filter-xpath ${filter} --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 120s

    # Simulator
    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
	Generate Delta Plan For NetConf    ${param_dic}    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}
	Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	...  ${cmd_editConfig}
	log    ${output}
	${error_content}    Fetch From Right    ${output}    \r\nERROR\r\n
    log    ${error_content}
    ${errors_list}    Split String   ${error_content}    \r\n\r\n
    log    ${errors_list[0]}
    ${tmp1}    Set Variable    Plan does not meet criteria set by PlanFileActivationMode.
    ${tmp2}    Set Variable    Parameters in requested plan require Site Reset or total service loss and it is not allowed.
    ${tmp3}    Set Variable    Automatic locking not possible because enableAutoLock = disabled..
    ${subMessage}    Set Variable If    "${Type}"=="SiteReset"   ${tmp1} ${tmp2}    ${tmp3}
    Should Match Regexp    ${errors_list[0]}    type:\\s*application
    Should Match Regexp    ${errors_list[0]}    tag:\\s*operation-failed
    Should Match Regexp    ${errors_list[0]}    severity:\\s*error
    ${path}    Should Match Regexp    ${errors_list[0]}    path:\\s*/_3gpp-common-managed-element:ManagedElement.*MRBTS-${BTS_ID}.*
    Should Contain    ${path}    /_3gpp-common-managed-element:ManagedElement[id='MRBTS-${BTS_ID}']
    Should Match Regexp    ${errors_list[0]}    message:\\s*${subMessage}

Set Test Data
    ${paramName_Online}    Set Variable    actARPBasedAC    #forceSingleTxModeSupportEnabled
    @{paramValuesPool_Online}    Create List    on    off
    ${paramScfDN_Online}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${paramName_SiteReset}    Set Variable    actMplaneFronthaulFirewall
    @{paramValuesPool_SiteReset}     Create List    true    false
    ${paramScfDN_SiteReset}    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${paramName_RatReset}    Set Variable    actDDDSPeriodOptimization
    @{paramValuesPool_RatReset}    Create List    true    false
    ${paramScfDN_RatReset}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ${paramName_ObjLock}    Set Variable    actCceSplit
    @{paramValuesPool_ObjLock}    Create List    true    false
    ${paramScfDN_ObjLock}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${paramScfDN_LTE}    Set Variable    MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}
    Set Test Variable    ${paramName_Online}
    Set Test Variable    ${paramValuesPool_Online}
    Set Test Variable    ${paramScfDN_Online}
    Set Test Variable    ${paramName_SiteReset}
    Set Test Variable    ${paramValuesPool_SiteReset}
    Set Test Variable    ${paramScfDN_SiteReset}
    Set Test Variable    ${paramName_RatReset}
    Set Test Variable    ${paramValuesPool_RatReset}
    Set Test Variable    ${paramScfDN_RatReset}
    Set Test Variable    ${paramName_ObjLock}
    Set Test Variable    ${paramValuesPool_ObjLock}
    Set Test Variable    ${paramScfDN_ObjLock}
    Set Test Variable    ${paramScfDN_LTE}

TC SetUp
    Log To Console    TC SetUp
    Common Test Setup    SetValidatePlanAgainstDetectedHW=${False}
    ${BTS_ID}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${BTS_ID}
    ${NRBTS_ID}    Fetch NRBTS ID
    Set Test Variable    ${NRBTS_ID}
    ${LNBTS_ID}    Fetch LNBTS ID
    Set Test Variable    ${LNBTS_ID}
    ${Primary_SN}    Set Variable
    ${bts_info}    coam.Get Bts Info
    ${smod_info_list}=    Get From Dictionary    ${bts_info}    systemModules
    FOR    ${smod}    IN    @{smod_info_list}
        ${sn}    Get From Dictionary    ${smod}    serialNumber
        ${id}    Get From Dictionary    ${smod}    id
        ${config_DN}    Get From Dictionary    ${id}    configuration
        ${mode_name}    Fetch From Right    ${config_DN}    /
        ${Primary_SN}    Set Variable If  "${mode_name}"=="SMOD-1"    ${sn}    ${Primary_SN}
        Exit For Loop If    "${mode_name}"=="SMOD-1"
    END
    Set Test Variable    ${Primary_SN}
#    ${validateHW_curValue}    Set ValidatePlanAgainstDetectedHW Value Admin    ${BTS_ID}    true
#    Set Test Variable    ${validateHW_curValue}
    Set Test Data
#    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
#    Set Test Variable    ${user}    ${ONAP["user"]}
#    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
#    ${ONAP_INFOR}    Get Informations From ONAP    ${host_ip}    ${user}    ${pwd}
#    Set Test Variable      ${ONAP_INFOR}
#    run keyword if    ${Integrate_Need}    Integrate SBTS To ONAP    ${BTS_ID}    ${host_ip}    ${user}    ${pwd}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}

TC TearDown
    Log To Console    TC TearDown
    Run Keyword If    ${needRecovery}    Recovery SBTS
    Common Test Teardown

Recovery SBTS
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_Online}    parameter=${paramName_Online}    value=${current_value_Online}
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_RatReset}    parameter=${paramName_RatReset}    value=${current_value_RatReset}
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_ObjLock}    parameter=${paramName_ObjLock}    value=${current_value_ObjLock}
#    coam.Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/MNL-1   parameter=validatePlanAgainstDetectedHW   value=${validateHW_curValue}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms