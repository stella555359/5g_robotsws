*** Settings ***

Documentation
...               Feature    : Verification of Load-based Tx path switch off on 4Tx cell
...               Feature Id : CB008392
...               Author     : shubhen
...               Email Id   : Shubhendra.kumar_sahoo@nokia.com

Resource          ../CB007814_114DCAP/resources/CB007623_keywords.robot
Resource                  ../resources/Common_resource.robot
Library             Process
Test setup        Run keywords  Prepare environment     AND     CB007623_keywords.Admin Setup
#Test setup         CB007623_keywords.Admin Setup
Test Teardown     Run keywords  CB007623_keywords.Admin Teardown
Suite teardown      Restore environment
Force Tags        CRT    SBTS24R3	FL00    QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
&{CB008392_A-Verification_of_Load_based_Tx_path_switch_off_on_4Tx_cell}
...     QC_ID_FL00=QC_31516   QC_ID_SBTS24R3=QC_852743
${DELTA_FILE}     ${CURDIR}/resources/config/SCF_9322_Feature_Paramters.xml
@{UE_alias}=       UE1
@{direction_dl}=   dl
@{duration}=       700s
@{timeout}         180
@{udpcalltype}=    UDP
@{deviation_dl}=   10
${counter_initial_value_1}  M55601C
${value1}                   02002
${counter_increment}        1
@{capabilities}    Legacy_1
@{throughput_dl}=   150
@{throughput_ul}=   100
${NCAV}            NCAV
${BTS_ID}                   MRBTS-1236
@{LTE_cell}     0
@{NR_cell}      3
*** Test Cases ***
CB008392_A-Verification_of_Load_based_Tx_path_switch_off_on_4Tx_cell
	[Documentation]		The purpose of this test case is to verify of Load-based Tx path switch off on 4Tx cell
	[Tags]    Split_A
    Lock cells  ${LTE_cell}
    Lock NR cells  ${NR_cell}
	${actNrLBRTXPowerSaving}		Get Current Parameter Value    ${dist_name}	     actNrLBRTXPowerSaving
	Parameter value change    ${dist_name} 	  		actNrLBRTXPowerSaving		true
    Sleep   120s
    ${date}     Run      date | cut -c1-3
    ${Value}        Get Current Parameter Value from selenium       ${dist_name}/NRCELL-1      Energy saving state
    log     ${Value}
    FOR    ${a}    IN RANGE    1    10
        ${Value}        Get Current Parameter Value from selenium       ${dist_name}/NRCELL-1      Energy saving state
        Exit For Loop IF    '${Value}'=='reducedEnergySaving'
        Sleep    1m    reason=Wait for energy state
    END
#	#	start NAA application
	ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
    ${count_1}      Counter value       M55601C02001
    ${count_1}      Counter value       M55601C02002
	Stop BTS logs and check

**** Keywords ***

Counter value
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=90    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NCAV']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Prepare environment
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    ${Pre_execution_scf_file}   COAM.Get Current Scf File       local_dir_path=${OUTPUT_DIR}/SCF    file_name=Pre_execution_scf.xml
    ...                         connection=${connection}
    Set Suite variable          ${Pre_execution_scf_file}
    ${Branch}       CB007623_keywords.Get Branch
    Set Suite variable      ${SCF_file}         ${CURDIR}/resources/config/SCF_9322_Feature_Paramters.xml
    COAM.Perform Commissioning      bts_id=${BTS_ID}        scf_file=${SCF_file}          skip_parameter_relation_errors=True
    ...                             should_activate=True    timeout=600     connection=${connection}
    Wait Until Keyword Succeeds    15 times    30    CB007623_keywords.Check BTS is OnAir
    COAM.teardown_admin    connection=${connection}
    #Get Hostname

Restore environment
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    Collect snapshot from BTS
    Log to console      \nPerforming commissioning
    COAM.Perform Commissioning      bts_id=${BTS_ID}        scf_file=${Pre_execution_scf_file}          skip_parameter_relation_errors=True
    ...                             should_activate=True    timeout=500     connection=${connection}
    Wait Until Keyword Succeeds    15 times    30    CB007623_keywords.Check BTS is OnAir
    COAM.teardown_admin    connection=${connection}

Collect snapshot from BTS
    [Documentation]     Download BTS snapshot
    Log to console      \nCollecting snapshot
    ${status}           Run keyword and return status       COAM.Collect Snapshot   target_file_name=${OUTPUT_DIR}/Snapshot.zip
    ...                                                                             coverage=Full
    ...                                                                             force=True
    ...                                                                             timeout=1000
    ...                                                                             connection=${connection}
    Run Keyword If      '${status}'=='False'                Log                     Snapshot collection failed !!!          ERROR


