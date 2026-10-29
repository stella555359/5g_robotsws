*** Settings ***

Documentation
...   author: SG04
...   contact: SG04
...   Description: Test Suite for CB006943

Library           Process
Library           String
Library           taf.collectors.core    WITH NAME    core
Library           taf.collectors.btslog  WITH NAME   btslog

Library           Collections
Library           DateTime
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.selenium.sbts    WITH NAME    sbts
Library           ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library           ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library           taf.sw.scout    WITH NAME     scout
Library           taf.analyzer.netconf
Library           taf.collectors.simple    WITH NAME    simple
Library           OperatingSystem     WITH NAME    os

Library           taf.collectors.pmcounters    WITH NAME    PM
Library           ./testsuite/Bangalore/ORAN/SG04/resources/orualarm.py

Resource          taf/rfrl/common_resources/common_step/interface.robot
Resource          ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
#Resource    	/home/ute/robotws/testsuite/Bangalore/ORAN/SG04/resources/Common_resource.robot

Test Setup      Preconditions
Test Teardown	Test Teardown

*** Variables ***
${host1}=     10.58.238.71
${user1}=     ute
${password1}=    BT5l@bus3rl0g1n
${host2}=     192.168.255.129
${user2}=    toor4nsn
${password2}=    oZPS0POrRieRtu
${UE_PC}=    10.45.150.167
${id}=    inbabtslabuser
${password}=    BT5l@bus3rl0g1n
${ru_ip}=     192.168.1.131
${ru_id}=    User1-vSFQEFw1
${ru_pass}=  Q+*!LD0sem
${cmnd1}=    ru -almtest 0009 1 101
${cmnd2}=    ru -almtest 0009 0 101
${cmnd3}=    ru -almtest 0002 1 1
${cmnd4}=    ru -almtest 0002 0 1
${fault-severity1}=     Major
${fault-severity13_1}=     Warning
${fault-severity2}=     Critical
${Nokia_faultid1}=     1921
${Nokia_faultid2}=     1937
${CONFIGURATION}		    1_2_CLOUD970
${fault_log_status}=    2.0
${RMOD_ID}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1

&{CB006943_A_TC014_OAM}    QC_ID_FL00=QC_31646    QC_ID_SBTS24R1=QC_692712    QC_ID_SBTS25R2=QC_140899

*** Test Cases ***
CB006943_A_TC014_OAM
    [Tags]    TRUNK_SG04_No	OAM14	QCD_MN_RAN    QCP_RAN_VRF

    coam.setup_admin	bts_host=192.168.255.129    timeout=300

    Step1: Login to ORU and using debug command,raise Fault ID-9 with Severity Major Transmission quality deteriorated
    Step2: Verify ORU availability-state and operational-state
    Step3: Cancel the fault 9 using the debug command

    Step4: Login to ORU and using debug command,raise Fault ID-2 with Severity Critical Unit dangerously overheating
    Step5: Verify ORU availability-state and operational-state
    Step6: Cancel the fault 2 using the debug command
    Step7: Verify ORU availability-state and operational-state
    ${fault_log_status}=    Set Variable    1.0

*** Keywords ***

Preconditions
    Log to console   --Test setup--
	delete_files_netconf    host=192.168.255.129

Step1: Login to ORU and using debug command,raise Fault ID-9 with Severity Major Transmission quality deteriorated
    Log to Console    \n-- Login to FJT and raising ${Nokia_faultid1} --
    coam.get_active_alarms
    RU_execute    ${UE_PC}    ${id}    ${password}    ${ru_ip}    ${ru_id}    ${ru_pass}    ${cmnd1}
    sleep     10
    coam.assert_alarm_active    faultId=${Nokia_faultid1}    severity=${fault-severity1}    timeout=150
    Log to Console    \n -- Exepcted Fault ID generated --

Step2: Verify ORU availability-state and operational-state
    Log to console  \n--Get ORU ID--
    FOR    ${x}    IN RANGE    0    3
        ${target_ru} =    Set Variable    '${RMOD_ID}'
        Set suite variable    ${oru_id}    ${x}
        ${bts_info}=    coam.get_bts_info
        ${ru_identy}=    Evaluate    ${bts_info} ['radioModules']['rmod'][${x}]['id']['internal']
        Exit For Loop IF    '${ru_identy}' == ${target_ru}
        Log to console    ${ru_identy}
    END
    Log to console  \n-- Checking RMOD Availability state --

    should be true    '${bts_info ['radioModules']['rmod'][${oru_id}]['status']['availabilityStatus']}' == 'degraded'
    should be true    '${bts_info ['radioModules']['rmod'][${oru_id}]['status']['operationalState']}' == 'enabled'

    Log to console  \n-- RMOD Availability status is: DEGRADED
    Log to console  \n-- RMOD Operational status is: ENABLED

Step3: Cancel the fault 9 using the debug command
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd2}
    sleep   20
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid1}    severity=${fault-severity1}
    coam.get_cells_info
    coam.get_active_alarms

Step4: Login to ORU and using debug command,raise Fault ID-2 with Severity Critical Unit dangerously overheating
    Log to Console    \n--Login to FJT and raising ${Nokia_faultid2} --
    coam.get_active_alarms
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd3}
    sleep     10
    coam.assert_alarm_active      faultId=${Nokia_faultid2}    severity=${fault-severity2}    timeout=750
    Log to Console    \n--Exepcted Fault ID 2 generated --

Step5: Verify ORU availability-state and operational-state
    Log to console  \n--Get ORU ID--
    FOR    ${x}    IN RANGE    0    3
        ${target_ru} =    Set Variable    '${RMOD_ID}'
        Set suite variable    ${oru_id}    ${x}
        ${bts_info}=    coam.get_bts_info
        ${ru_identy}=    Evaluate    ${bts_info} ['radioModules']['rmod'][${x}]['id']['internal']
        Exit For Loop IF    '${ru_identy}' == ${target_ru}
        Log to console    ${ru_identy}
    END
    Log to console  \n-- Checking RMOD Availability state --

    should be true    '${bts_info ['radioModules']['rmod'][${oru_id}]['status']['availabilityStatus']}' == 'failed'
    should be true    '${bts_info ['radioModules']['rmod'][${oru_id}]['status']['operationalState']}' == 'disabled'

    Log to console  \n-- RMOD Availability status is: FAILED
    Log to console  \n-- RMOD Operational status is: DISABLED

Step6: Cancel the fault 2 using the debug command
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd4}
    sleep   10
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid2}    severity=${fault-severity2}
    coam.get_cells_info
    coam.get_active_alarms

Step7: Verify ORU availability-state and operational-state
    Log to console  \n--Get ORU ID--\n
    FOR    ${x}    IN RANGE    0    3
        ${target_ru} =    Set Variable    '${RMOD_ID}'
        Set suite variable    ${oru_id}    ${x}
        ${bts_info}=    coam.get_bts_info
        ${ru_identy}=    Evaluate    ${bts_info} ['radioModules']['rmod'][${x}]['id']['internal']
        Exit For Loop IF    '${ru_identy}' == ${target_ru}
        Log to console    ${ru_identy}
    END
    Log to console  \n-- Checking RMOD Availability state --

#    should be true    '${bts_info ['radioModules']['rmod'][${oru_id}]['status']['availabilityStatus']}' == 'none'
    should be true    '${bts_info ['radioModules']['rmod'][${oru_id}]['status']['operationalState']}' == 'enabled'

#    Log to console  \n-- RMOD Availability status is: none
    Log to console  \n-- RMOD Operational status is: ENABLED

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_type}=enb    ${tl_name_only}=${scout_id1}

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Reset Rmod
    ${RMODS}  coam.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
		IF     "RMOD_R-1" in "${RMOD}"
			coam.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=300s
		END
    END
    Log to console  \n--Wait for O-RUs to come UP --\n
	sleep     10

Test Teardown
    Log to console   --Test teardown--
	Run Keyword If		"${fault_log_status}" == "1.0"    Log to console   --All Faults cleared--
	#Wait for BTS OnAir
	RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag
    coam.teardown_all_aliases_for_admin
