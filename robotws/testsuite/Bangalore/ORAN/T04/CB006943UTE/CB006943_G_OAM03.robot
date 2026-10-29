*** Settings ***

Documentation    Script for CB006943_G_OAM03 Simulated_Environment
...   author: sudarsha.kanapuram@nokia.com
...   Description: NR FDD ORAN FJT Radios configured for FDD DSS RAT1 and Dynamic Switch allocation verification
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB006943_TC03_$(date +%y%m%d) CB006943_G_OAM03.robot


Resource          ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/UTE_Common_resource.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


Suite setup        Suite Setup
Test Setup         Test Preconditions
Test Teardown      Test Postconditions
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00


*** Variables ***
${Dummy_variable}    1
${para_name}=    restart-cause
${snapshot1}=    ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/fjt_4T4R_FDD_n1_n3_n75_v7.xml
${RMOD_ID}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1

*** Test Cases ***
[1][1.0] CB006943_G_TC003_OAM
    [Tags]    FL00    TRUNK_SG04    25R1    QCD_MN_RAN    QCP_RAN_VRF    6943G
    [Teardown]    run keywords
     ...      Test teardown
	 #AND    Set QC_Tag
    Link SCOUT SCF to Configuration ID for Reporting
    Step1: Enable ORU Energy saving
    Step2: Block RAT and check ORU Energy saving state
    Step3: Reset & Lock Unlock ORU & BBMOD Reset
    Step4: Lock Cells & check ORU Energy saving state
    Step5: Reset & Lock Unlock ORU & BBMOD Reset

*** Keywords ***

Step1: Enable ORU Energy saving
    Log to console    \n--Step:1 Enable ORU Energy saving Started--\n
    Enable ORU Energy Saving Feature
    sleep   5s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "AWAKE"    ${oruPowerState1}
    Log to console    \n--Step:1 ORU Power State is ${oruPowerState1}--\n

Step2: Block RAT and check ORU Energy saving state
    Log to console    \n--Step:2 Block RAT and check ORU Energy saving state Started--\n
    sleep   10s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:2 ORU Power State is ${oruPowerState1}--\n

Step3: Reset & Lock Unlock ORU & BBMOD Reset
    Log to console    \n--Step3: Reset & Lock Unlock ORU and check ORU Energy saving state Started--\n
    ${RMODS}  admin.get_ids_for_all  RMOD    connection=admin_1
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      admin.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=300s    connection=admin_1
    END
    sleep   10s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:3 ORU Power State is ${oruPowerState1} after ORU Reset--\n
    ${RMODS}  admin.get_ids_for_all  RMOD    connection=admin_1
    Log to console  \n--Performing RMODs Lock--\n
    FOR    ${RMOD}    IN  @{RMODS}
      admin.lock    dist_name=${RMOD}    timeout=300s    connection=admin_1
    END
    Sleep    10s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:3 ORU Power State is ${oruPowerState1} after ORU Lock --\n
    ${RMODS}  admin.get_ids_for_all  RMOD    connection=admin_1
    Log to console  \n--Performing RMODs Unlock--\n
    FOR    ${RMOD}    IN  @{RMODS}
      admin.unlock    dist_name=${RMOD}    timeout=300s    connection=admin_1
    END
    Sleep    100s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:3 ORU Power State is ${oruPowerState1} after ORU Unlock --\n
    ${BBMODS}  admin.get_ids_for_all  BBMOD    connection=admin_1
    Log to console  \n--Performing BBMOD reset--\n
    FOR    ${BBMOD}    IN  @{BBMODS}
      admin.reset_unit    dist_name=${BBMOD}    reset_type=Warm    timeout=300s    connection=admin_1
    END
    Log to console  \n--BBMOD reset Completed and waiting for BBMOD to come up--\n
    Sleep	200s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:3 ORU Power State is ${oruPowerState1} after BBMOD Reset --\n
    admin.Get Active alarms    connection=admin_1
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    #admin.unblock_rat    rat=LTE    timeout=100
    #sleep   30s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "AWAKE"    ${oruPowerState1}
    Log to console    \n--Step:3 ORU Power State is ${oruPowerState1} after Unblock RAT--\n
    Wait for BTS OnAir

Step4: Lock Cells & check ORU Energy saving state
    Log to console    \n--Step:4 Lock Cells and check ORU Energy saving state Started--\n
    ${BTS_details}      admin.get_bts_info    connection=admin_1
    Log    ${BTS_details}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:4 ORU Power State is ${oruPowerState1} after All Cells locked --\n

Step5: Reset & Lock Unlock ORU & BBMOD Reset
    Log to console    \n--Step:5 Reset & Lock Unlock ORU and check ORU Energy saving state Started--\n
    ${RMODS}  admin.get_ids_for_all  RMOD    connection=admin_1
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      admin.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=300s    connection=admin_1
    END
    sleep   10s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:5 ORU Power State is ${oruPowerState1} after ORU Reset--\n
    ${RMODS}  admin.get_ids_for_all  RMOD    connection=admin_1
    Log to console  \n--Performing RMODs Lock--\n
    FOR    ${RMOD}    IN  @{RMODS}
      admin.lock    dist_name=${RMOD}    timeout=300s    connection=admin_1
    END
    Sleep    10s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:5 ORU Power State is ${oruPowerState1} after ORU Lock --\n
    ${RMODS}  admin.get_ids_for_all  RMOD    connection=admin_1
    Log to console  \n--Performing RMODs Unlock--\n
    FOR    ${RMOD}    IN  @{RMODS}
      admin.unlock    dist_name=${RMOD}    timeout=300s    connection=admin_1
    END
    Sleep    100s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:5 ORU Power State is ${oruPowerState1} after ORU Unlock --\n
    ${BBMODS}  admin.get_ids_for_all  BBMOD    connection=admin_1
    Log to console  \n--Performing BBMOD reset--\n
    FOR    ${BBMOD}    IN  @{BBMODS}
      admin.reset_unit    dist_name=${BBMOD}    reset_type=Warm    timeout=300s    connection=admin_1
    END
    Log to console  \n--BBMOD reset Completed and waiting for BBMOD to come up--\n
    Sleep	150s
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "SLEEP"    ${oruPowerState1}
    Log to console    \n--Step:5 ORU Power State is ${oruPowerState1} after BBMOD Reset --\n
    admin.Get Active alarms    connection=admin_1
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    ${oruPowerState1}=	Get ORU Power state
    Should Be True    "AWAKE"    ${oruPowerState1}
    Log to console    \n--Step:3 ORU Power State is ${oruPowerState1} after Unblock RAT--\n
    Check BTS is OnAir

Test teardown
    Log to console   --\n Test teardown Started\n--
#    Disable ORU Energy Saving Feature
    sleep   5s
    Check BTS is OnAir
#    Run Keyword If		"${dcap_log_status}" == "1.0"   DCAP Stop
#    ...    ELSE    DCAP Stop with log Transfer
#    admin.teardown_all_aliases_for_admin
    RP Settings
    Run Keyword If		"${sw_release}" == "None"
    ...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
    ...   console=true
    Log to console   --\n Test teardown COMPLETED \n--
    interface.Common step trigger

Enable ORU Energy Saving Feature
   ${BTS_details}      admin.get_bts_info    connection=admin_1
   Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
   admin.Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1
   ...                                        parameter=oruEnergySavingEnabled
   ...                                        operation=update
   ...                                        value=true    connection=admin_1

Disable ORU Energy Saving Feature
   ${BTS_details}      admin.get_bts_info    connection=admin_1
   Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
   admin.Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1
   ...                                        parameter=oruEnergySavingEnabled
   ...                                        operation=update
   ...                                        value=false
   ...										  connection=admin_1

Get ORU Power state
    ${bts_info}=    admin.get_bts_info    connection=admin_1
    ${oruPowerState}=    Create List	${bts_info['radioModules']['rmod'][0]['status']['powerState']}
    Log To Console	\n O-RU Power State: ${oruPowerState[0]}
    [Return]    ${oruPowerState[0]}

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    admin.get_bts_statuses    connection=admin_1
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        admin.lock    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${cell}    timeout=90    connection=admin_1
    END

Unlock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
        admin.unlock           dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${cell}    timeout=180    connection=admin_1
    END

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    admin.get_bts_statuses    connection=admin_1
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    admin.get_bts_statuses    connection=admin_1
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

DCAP Start
    Log to console    \n-- Connecting to DCAP Server--\n
    rd.connect_to     host=${dcaphost}      port=${dcapport}     rd_version=${dcap_version}    username=${dcap_uname}
    ...     password=${dcap_pwd}    secure=True
    ${bts_info}=    create dictionary    host=${btshost1}    port=${btsport}    username=${bts_uname}     password=${bts_pwd}
    #${gnb_custom_profile}=    Create List    condor5gSyslog
    ${output}=     rd.start_trace    tag=start_trace      duration=-1     bts=${bts_info}    tag=newtrace
    ...    gnb_trace_profile=dcap-lite-default    bts_trace_profile=dcap-lite-default
    Log to console    \n-- Started GNB Custom Traces --\n
    ${trace_d}=    Get Dictionary Values   ${output}
	${trace_id}=    Set Variable    ${trace_d}[0]
    Log to console    \n DCAP Trace ID: ${trace_id} \n
    Set suite variable    ${trace_id}

DCAP Stop
    Log to console    \n-- Stop DCAP Traces & Skipping log Transfer --\n
    rd.stop_trace      trace_id=${trace_id}

DCAP Stop with log Transfer
    rd.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n
    rd.get_results    result_id=${trace_id}       target_dir=/home/ute/results/${TEST_NAME}    timeout=200
    os.Run    sudo mv '/home/ute/results/${TEST_NAME}' /sharedvolume/Execution_CRT_Logs/