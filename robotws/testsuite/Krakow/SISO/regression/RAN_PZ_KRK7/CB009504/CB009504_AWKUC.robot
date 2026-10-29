*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD_GMC

Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com

Resource     ./resources/common.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup       Testline Setup    reach_on_air=without_x2_link    wts=${WTS_CFG}    config=${SUITE_CONFIG}    reboot_after_config=yes
Suite Teardown    Testline Teardown

Test Setup        Run Keywords
...               Test Case Setup
...      AND      Update actForceUnitAutoReset Flag
...      AND      gnb_bbu.Reset gNB via GUI
...      AND      Sleep    180s    reason=Wait for gNB startup
...      AND      gnbcell.Wait For All Cells To Be OnAir    timeout=360
...      AND      Start And Stop SA L3 Call For 2 UEs
Test Teardown     Run Keywords
...               Test Case Teardown
...      AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report

*** Variables ***
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../../../resources/Airphone
${SCF_FILE}              ${CURDIR}/resources/AWKUC/SBTS00/scf_config.xml
${WTS_CFG}               ${CURDIR}/resources/AWKUC/SBTS00/basic_setup.cfg
${IPHY_XML}              ${CURDIR}/resources/AWKUC/SBTS00/iphy.xml
${DELTA_MW}              ${CURDIR}/resources/maintenanceWindow.json
${DELTA_DEL_MW}          ${CURDIR}/resources/deconfigure_maintenanceWindow.json
&{SUITE_CONFIG}          scf=${SCF_FILE}    iphy=${IPHY_XML}     rnd_gnb=${RND_FLAGS}    wait_for_state=Configured
&{RND_FLAGS}             0x50000F=5   # FriRadioResetCount
&{recovery_params}       maintenanceWindowResult=Radio recovery reset:MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1,MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-2
&{no_recovery_params}    maintenanceWindowResult=No recovery reset needed
&{recovery_result}       MRBTS-1/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1=&{recovery_params}
&{no_recovery_result}    MRBTS-1/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1=&{no_recovery_params}

*** Test Cases ***
[1]CB009504_A_01_Triggering_fault_to_verify_the_cell_is_set_up_and_operates_with_reduced_performance.
    Trigger AWKUC CB009504-A Base Scenario    FID=2923
    Trigger AWKUC CB009504-A Base Scenario    FID=2922
    Trigger AWKUC CB009504-A Base Scenario    FID=1920
    Trigger AWKUC CB009504-A Base Scenario    FID=1908

[1]CB009504_B_09_failed_RU_recovery_after_FID_trigger
    Trigger AWKUC CB009504-B Fail Scenario    FID=1920
    Trigger AWKUC CB009504-B Fail Scenario    FID=2923
    Trigger AWKUC CB009504-B Fail Scenario    FID=1908
    Trigger AWKUC CB009504-B Fail Scenario    FID=2922

[1]CB009504_B_13_degraded_NRcell_lock_unlock_after_failed_RU_recovery
    Trigger AWKUC CB009504-B Lock Scenario    FID=2922
    Trigger AWKUC CB009504-B Lock Scenario    FID=2923
    Trigger AWKUC CB009504-B Lock Scenario    FID=1908
    Trigger AWKUC CB009504-B Lock Scenario    FID=1920

[1]CB009504_C_22_failed_RU_recovery_in_maintenance_window
    Trigger AWKUC CB009504-C Fail Scenario    FID_1=2923    FID_2=2922
    Trigger AWKUC CB009504-C Fail Scenario    FID_1=1908    FID_2=1920
    Trigger AWKUC CB009504-C Fail Scenario With Critical Faults

*** Keywords ***
Start And Stop SA L3 Call For 2 UEs
    [Arguments]    ${ue_id_1}=1    ${ue_id_2}=2
    Start SA L3 Call    ue_id=${ue_id_1}
    Start SA L3 Call    ue_id=${ue_id_2}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_id_1}    wait=10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_id_2}
    Stop SA L3 Call    ue_id=${ue_id_1}
    Stop SA L3 Call    ue_id=${ue_id_2}

Start SA L3 Call For 2 UEs
    [Arguments]    ${ue_id_1}=1    ${ue_id_2}=2
    Start SA L3 Call    ue_id=${ue_id_1}
    Start SA L3 Call    ue_id=${ue_id_2}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_id_1}    wait=10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_id_2}

Stop SA L3 Call For 2 UEs
    [Arguments]    ${ue_id_1}=1    ${ue_id_2}=2
    Stop SA L3 Call    ue_id=${ue_id_1}
    Stop SA L3 Call    ue_id=${ue_id_2}

Trigger AWKUC CB009504-A Base Scenario
    [Arguments]    ${FID}=2923
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${FID}' in ('2922','2923','1920','1908')    msg=Invalid KW parameter: FID
    #---------------------------------------------------------------------------------------------------------------
    ${array}    Set Variable If   '${FID}' == '2923'    rx    tx
    Sleep    250s    reason=Wait for RUs to be in runtime
    Execute AP AaShell Command    trigger_rf_fault 0 ${FID} ${array}Array3:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 ${FID} ${array}Array2:1 MAJ persistent
    Run Keyword If    '${FID}' == '1908'    Sleep    30s    reason=Wait for the alarm 1908 to be reported
    Verify If Expected Alarm Is Active    expected_alarm=${FID}
    Check If All Cells Are In Given State  state=degraded
    Start And Stop SA L3 Call For 2 UEs
    Execute AP AaShell Command    cancel_rf_fault 0 ${FID} ${array}Array3:1
    Execute AP AaShell Command    cancel_rf_fault 1 ${FID} ${array}Array2:1
    Run Keyword If    '${FID}' == '1908'    Sleep    30s    reason=Wait for the alarm 1908 to be cancelled
    Verify If Given Alarm Is Not Active    alarm=${FID}
    Check If All Cells Are In Given State  state=online

Trigger AWKUC CB009504-B Fail Scenario
    [Arguments]    ${FID}=2923
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${FID}' in ('2922','2923','1920','1908')    msg=Invalid KW parameter: FID
    #---------------------------------------------------------------------------------------------------------------
    ${array}    Set Variable If   '${FID}' == '2923'    rx    tx
    Sleep    250s    reason=Wait for RUs to be in runtime
    Execute AP AaShell Command    trigger_rf_fault 0 ${FID} ${array}Array3:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 ${FID} ${array}Array2:1 MAJ persistent
    Run Keyword If    '${FID}' == '1908'    Sleep    30s    reason=Wait for the alarm 1908 to be reported
    Run Keyword If    '${ENB_BRANCH}' != 'SBTS25R3'    gnbcell.Wait For All Cells Statuses    availability_status=failed    timeout=360
    gnbcell.Wait For All Cells Statuses    availability_status=degraded
    Verify If Expected Alarm Is Active    expected_alarm=${FID}
    Start SA L3 Call For 2 UEs
    Execute AP AaShell Command    cancel_rf_fault 0 ${FID} ${array}Array3:1
    Execute AP AaShell Command    cancel_rf_fault 1 ${FID} ${array}Array2:1
    Run Keyword If    '${FID}' == '1908'    Sleep    30s    reason=Wait for the alarm 1908 to be cancelled
    Verify If Given Alarm Is Not Active    alarm=${FID}
    Check If All Cells Are In Given State  state=online
    Stop SA L3 Call For 2 UEs

Trigger AWKUC CB009504-B Lock Scenario
    [Arguments]    ${FID}=2923
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${FID}' in ('2922','2923','1920','1908')    msg=Invalid KW parameter: FID
    #---------------------------------------------------------------------------------------------------------------
    ${array}    Set Variable If   '${FID}' == '2923'    rx    tx
    Sleep    250s    reason=Wait for RUs to be in runtime
    Execute AP AaShell Command    trigger_rf_fault 0 ${FID} ${array}Array3:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 ${FID} ${array}Array2:1 MAJ persistent
    Run Keyword If    '${FID}' == '1908'    Sleep    30s    reason=Wait for the alarm 1908 to be reported
    Run Keyword If    '${ENB_BRANCH}' != 'SBTS25R3'    gnbcell.Wait For All Cells Statuses    availability_status=failed    timeout=360
    gnbcell.Wait For All Cells Statuses    availability_status=degraded
    Verify If Expected Alarm Is Active    expected_alarm=${FID}
    Start SA L3 Call For 2 UEs
    Lock And Unlock All Cells Multiple Times
    Start SA L3 Call For 2 UEs
    Execute AP AaShell Command    cancel_rf_fault 0 ${FID} ${array}Array3:1
    Execute AP AaShell Command    cancel_rf_fault 1 ${FID} ${array}Array2:1
    Run Keyword If    '${FID}' == '1908'    Sleep    30s    reason=Wait for the alarm 1908 to be cancelled
    Verify If Given Alarm Is Not Active    alarm=${FID}
    Check If All Cells Are In Given State  state=online
    Stop SA L3 Call For 2 UEs

Trigger AWKUC CB009504-C Fail Scenario
    [Arguments]    ${FID_1}=2923    ${FID_2}=2922
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${FID_1}' in ('2923','1908')    msg=Invalid KW parameter: FID
    Should Be True    '${FID_2}' in ('2922','1920')    msg=Invalid KW parameter: FID
    #---------------------------------------------------------------------------------------------------------------
    ${FID_1_array}    Set Variable If   '${FID_1}' == '1908'    tx    rx
    ${FID_2_array}    Set Variable       tx
    Sleep    250s    reason=Wait for RUs to be in runtime
    ${window_start}    Schedule Maintenance Window Start Time    minutes=5
    Configure Maintenance Window    scheduled_startTime=${window_start}
    Execute AP AaShell Command    trigger_rf_fault 0 ${FID_1} ${FID_1_array}Array3:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 ${FID_2} ${FID_2_array}Array2:1 MAJ persistent
    Run Keyword If    '${FID_1}' == '1908'    Sleep    30s    reason=Wait for the alarm 1908 to be reported
    Verify If Expected Alarm Is Active    expected_alarm=${FID_1}
    Verify If Expected Alarm Is Active    expected_alarm=${FID_2}
    Check If All Cells Are In Given State  state=degraded
    Start And Stop SA L3 Call For 2 UEs
    Sleep    420s    reason=Wait for entering maintenance window and applying auto recovery actions
    Run Keyword If  '${ENB_BRANCH}' == 'SBTS25R3'
    ...  gnb_bbu.Verify gNB Configuration Parameters Have Expected Values    param_dict=${no_recovery_result}
    ...  ELSE
    ...  gnb_bbu.Verify gNB Configuration Parameters Have Expected Values    param_dict=${recovery_result}
    Check If All Cells Are In Given State  state=degraded
    Verify If Expected Alarm Is Active    expected_alarm=${FID_1}
    Verify If Expected Alarm Is Active    expected_alarm=${FID_2}
    Start And Stop SA L3 Call For 2 UEs
    Deconfigure Maintenance Window
    gnb_bbu.Reset gNB via GUI
    Sleep    120s    reason=Wait for gNB startup
    gnbcell.Wait For All Cells To Be OnAir    timeout=360

Trigger AWKUC CB009504-C Fail Scenario With Critical Faults
    Sleep    250s    reason=Wait for RUs to be in runtime
    ${window_start}    Schedule Maintenance Window Start Time    minutes=5
    Configure Maintenance Window    scheduled_startTime=${window_start}
    Execute AP AaShell Command    trigger_rf_fault 0 1911 rxArray3:1 CRI persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1907 txArray2:1 CRI persistent
    gnbcell.Wait For All Cells Statuses    availability_status=failed    timeout=360
    Sleep    60s    reason=Wait for complete RU restart
    gnbcell.Wait For All Cells Statuses    availability_status=failed
    Sleep    420s    reason=Wait for entering maintenance window and no auto recovery actions due to no pending RU reset
    gnb_bbu.Verify gNB Configuration Parameters Have Expected Values    param_dict=${no_recovery_result}
    Verify If Expected Alarm Is Active    expected_alarm=1911
    Verify If Expected Alarm Is Active    expected_alarm=1907
    Deconfigure Maintenance Window
