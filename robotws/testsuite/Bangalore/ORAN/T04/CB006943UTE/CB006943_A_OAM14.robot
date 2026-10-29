*** Settings ***

Documentation    Script for CB006943_A_OAM14 Simulated_Environment
...   author: sudarsha.kanapuram@nokia.com
...   Description: CB006943
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB006943_TC14_$(date +%y%m%d) CB006943_A_OAM14.robot


Resource          ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/UTE_Common_resource.robot
Resource    ./testsuite/Bangalore/ORAN/T04/CB006943UTE/Resources/AP_backdoor_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


Suite setup        Suite Setup
Test Setup         Test Preconditions
Test Teardown      Test Postconditions
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00


*** Variables ***
${Dummy_variable}    1
${Nokia_faultid1}=     1921
${Nokia_faultid2}=     1937
${fault-severity1}=     Major
${fault-severity13_1}=     Warning
${fault-severity2}=     Critical
${snapshot1}=    ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/fjt_4T4R_FDD_n1_n3_n75_v7.xml
${RMOD_ID}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1

*** Test Cases ***
CB006943_A_TC014_OAM
    [Tags]    FL00    TRUNK_SG04    25R1    QCD_MN_RAN    QCP_RAN_VRF    6943G
    [Teardown]    run keywords
     ...      Test teardown
	#admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
	Link SCOUT SCF to Configuration ID for Reporting
	Test steps


*** Keywords ***
Test steps
    Step1: Login to ORU and using debug command,raise Fault ID-9 with Severity Major Transmission quality deteriorated
    Step2: Verify ORU availability-state and operational-state
    Step3: Cancel the fault 9 using the debug command

    Step4: Login to ORU and using debug command,raise Fault ID-2 with Severity Critical Unit dangerously overheating
    Step5: Verify ORU availability-state and operational-state
    Step6: Cancel the fault 2 using the debug command
    Step7: Verify ORU availability-state and operational-state




Step1: Login to ORU and using debug command,raise Fault ID-9 with Severity Major Transmission quality deteriorated
    Log to Console    \n-- Login to FJT and raising ${Nokia_faultid1} --
    admin.get_active_alarms    connection=${ADMIN_ALIAS}
	RU test fault trigger    IQ over Input    9     Tx-Array-00:0    MAJOR     PERSISTENT     RU
    sleep     10
    admin.assert_alarm_active    faultId=${Nokia_faultid1}    severity=${fault-severity1}    timeout=150    connection=${ADMIN_ALIAS}
    Log to Console    \n -- Exepcted Fault ID generated --

Step2: Verify ORU availability-state and operational-state
    Log to console  \n--Get ORU ID--
    FOR    ${x}    IN RANGE    0    3
        ${target_ru} =    Set Variable    '${RMOD_ID}'
        Set suite variable    ${oru_id}    ${x}
        ${bts_info}=    admin.get_bts_info    connection=${ADMIN_ALIAS}
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
    RU test fault clear    IQ over Input    9
    sleep   20
    run keyword and continue on failure     admin.assert_alarm_inactive      faultId=${Nokia_faultid1}    severity=${fault-severity1}
    ...    connection=${ADMIN_ALIAS}
    admin.get_cells_info    connection=${ADMIN_ALIAS}
    admin.get_active_alarms    connection=${ADMIN_ALIAS}
	Log to console  \n--Executing Test steps END--\n

Step4: Login to ORU and using debug command,raise Fault ID-2 with Severity Critical Unit dangerously overheating
    Log to Console    \n--Login to FJT and raising ${Nokia_faultid2} --
    admin.get_active_alarms    connection=${ADMIN_ALIAS}
    RU test fault trigger    Unit dangerously overheating    2     N75N3N1-G-RU    CRITICAL     PERSISTENT     N75N3N1-G-RU
    sleep     10
    admin.assert_alarm_active      faultId=${Nokia_faultid2}    severity=${fault-severity2}    timeout=750    connection=${ADMIN_ALIAS}
    Log to Console    \n--Exepcted Fault ID 2 generated --

Step5: Verify ORU availability-state and operational-state
    Log to console  \n--Get ORU ID--
    FOR    ${x}    IN RANGE    0    3
        ${target_ru} =    Set Variable    '${RMOD_ID}'
        Set suite variable    ${oru_id}    ${x}
        ${bts_info}=    admin.get_bts_info    connection=${ADMIN_ALIAS}
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
    RU test fault clear    Unit dangerously overheating    2
    sleep   20
    run keyword and continue on failure     admin.assert_alarm_inactive      faultId=${Nokia_faultid2}    severity=${fault-severity2}
	...    connection=${ADMIN_ALIAS}
    admin.get_cells_info    connection=${ADMIN_ALIAS}
    admin.get_active_alarms    connection=${ADMIN_ALIAS}

Step7: Verify ORU availability-state and operational-state
    Log to console  \n--Get ORU ID--\n
    FOR    ${x}    IN RANGE    0    3
        ${target_ru} =    Set Variable    '${RMOD_ID}'
        Set suite variable    ${oru_id}    ${x}
        ${bts_info}=    admin.get_bts_info    connection=${ADMIN_ALIAS}
        ${ru_identy}=    Evaluate    ${bts_info} ['radioModules']['rmod'][${x}]['id']['internal']
        Exit For Loop IF    '${ru_identy}' == ${target_ru}
        Log to console    ${ru_identy}
    END
    Log to console  \n-- Checking RMOD Availability state --

    should be true    '${bts_info ['radioModules']['rmod'][${oru_id}]['status']['operationalState']}' == 'enabled'
    Log to console  \n-- RMOD Operational status is: ENABLED

Test teardown
    Log to console   \n--Test teardown Started--\n
    Check BTS is OnAir
    RP Settings
    sleep    5
    Run Keyword If		"${sw_release}" == "None"
    ...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
    ...   console=true
    sleep    10
    interface.Common step trigger
    Log to console   \n--Test teardown completed--\n

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    admin.get_bts_statuses    connection=admin_1
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}


