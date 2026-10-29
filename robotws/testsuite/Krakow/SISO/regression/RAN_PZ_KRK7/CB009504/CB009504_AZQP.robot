*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_GMC

Documentation
...            author:       Mateusz Matusik, mateusz.matusik@nokia.com
...            maintainer:   Mateusz Matusik, mateusz.matusik@nokia.com

Resource    ./resources/common.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     ta5g_testline_management
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations     WITH NAME   gnb_cell
Library     taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations     WITH NAME   gnb_ru


Suite Setup       Testline Setup    reach_on_air=yes    wts=${WTS_CFG}    config=${SUITE_CONFIG}    reboot_after_config=yes
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup
Test Teardown     Run Keywords
...               Test Case Teardown
...      AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report
...      AND      Trigger Site Reset to Reset number of recoveries

*** Variables ***
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../../../RRM/Airphone/resources/former_l3_sw2
${SCF_FILE}            ${CURDIR}/resources/AZQP/SBTS00/scf_config.xml
${WTS_CFG}             ${CURDIR}/resources/AZQP/SBTS00/basic_setup.cfg
${IPHY_XML}            ${CURDIR}/resources/AZQP/SBTS00/iphy.xml
${DELTA_MW}            ${CURDIR}/resources/maintenanceWindow.json
${DELTA_DEL_MW}        ${CURDIR}/resources/deconfigure_maintenanceWindow.json
&{RU1_recovery_params}       maintenanceWindowResult=Radio recovery reset:MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1
&{RU2_recovery_params}       maintenanceWindowResult=Radio recovery reset:MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-2
&{RU1_recovery_result}       MRBTS-1/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1=&{RU1_recovery_params}
&{RU2_recovery_result}       MRBTS-1/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1=&{RU2_recovery_params}
&{SUITE_CONFIG}        scf=${SCF_FILE}    iphy=${IPHY_XML}    wait_for_state=Configured

*** Test Cases ***
[1]CB009504_A_02_degraded_NRCell_block_unblock
    [Tags]    AZQP_A_02
    ##FID 1908
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    Trigger RF Fault With SA L3 Call    rf_number=0    fault_id=1908    cell_array=txArray6:1
    Sleep     35s
    Verify If Expected Alarm Is Active    expected_alarm=1908
    Check If Cell Is In Given State  state=degraded    cell_id=3
    Block And Unblock Single Cell Multiple Times    cell_id=3    quantity=10
    Verify If Expected Alarm Is Active    expected_alarm=1908
    Check If Cell Is In Given State  state=degraded    cell_id=3
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 0 1908 txArray6:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1908
    Check If Cell Is In Given State  state=online    cell_id=3
    ##FID1907
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    Trigger RF Fault With SA L3 Call    rf_number=0    fault_id=1907    cell_array=txArray2:1
    Sleep     35s
    Verify If Expected Alarm Is Active    expected_alarm=1907
    Check If Cell Is In Given State  state=degraded    cell_id=1
    SA L3 Call
    Block And Unblock Single Cell Multiple Times    cell_id=1    quantity=10
    Execute AP AaShell Command    cancel_rf_fault 0 1907 txArray2:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1907
    Check If Cell Is In Given State  state=online    cell_id=1
    ##FID1910
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    Trigger RF Fault With SA L3 Call    rf_number=1    fault_id=1910    cell_array=txArray2:1
    Sleep     35s
    Verify If Expected Alarm Is Active    expected_alarm=1910
    Check If Cell Is In Given State  state=degraded    cell_id=2
    Block And Unblock Single Cell Multiple Times    cell_id=2    quantity=10
    Verify If Expected Alarm Is Active    expected_alarm=1910
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 1910 txArray2:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1910
    Check If Cell Is In Given State  state=online    cell_id=2
    ##FID1920
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    Trigger RF Fault With SA L3 Call    rf_number=0    fault_id=1920    cell_array=txArray6:1
    Sleep     35s
    Verify If Expected Alarm Is Active    expected_alarm=1920
    Check If Cell Is In Given State  state=degraded    cell_id=3
    Block And Unblock Single Cell Multiple Times    cell_id=3    quantity=10
    Verify If Expected Alarm Is Active    expected_alarm=1920
    Check If Cell Is In Given State  state=degraded    cell_id=3
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 0 1920 txArray6:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1920
    Check If Cell Is In Given State  state=online    cell_id=3
    #FID2922
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    Trigger RF Fault With SA L3 Call    rf_number=0    fault_id=2922    cell_array=txArray2:1
    Sleep     35s
    Verify If Expected Alarm Is Active    expected_alarm=2922
    Check If Cell Is In Given State  state=degraded    cell_id=1
    Block And Unblock Single Cell Multiple Times    cell_id=1    quantity=10
    Verify If Expected Alarm Is Active    expected_alarm=2922
    Check If Cell Is In Given State  state=degraded    cell_id=1
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 0 2922 txArray2:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=2922
    Check If Cell Is In Given State  state=online    cell_id=1
    ##FID2923
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    Trigger RF Fault With SA L3 Call    rf_number=1    fault_id=2923    cell_array=rxArray1:1
    Sleep     35s
    Verify If Expected Alarm Is Active    expected_alarm=2923
    Check If Cell Is In Given State  state=degraded    cell_id=2
    Block And Unblock Single Cell Multiple Times    cell_id=2    quantity=10
    Verify If Expected Alarm Is Active    expected_alarm=2923
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 2923 rxArray1:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=2923
    Check If Cell Is In Given State  state=online    cell_id=2
    ##FID1911
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    Trigger RF Fault With SA L3 Call    rf_number=0    fault_id=1911    cell_array=rxArray5:1
    Sleep     35s
    Verify If Expected Alarm Is Active    expected_alarm=1911
    Check If Cell Is In Given State  state=degraded    cell_id=3
    Block And Unblock Single Cell Multiple Times    cell_id=3    quantity=10
    Verify If Expected Alarm Is Active    expected_alarm=1911
    Check If Cell Is In Given State  state=degraded    cell_id=3
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 0 1911 rxArray5:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1911
    Check If Cell Is In Given State  state=online    cell_id=3

    [Teardown]    Teardown without site reset

[1]CB009504_B_10_successful_RU_recovery_after_FID_trigger
    [Tags]    AZQP_B_10
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=actForceUnitAutoReset    value=true
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=nonCritTrxFailRecoveryCtrl    value=Multiple
    Sleep    4min
    ##FID 1911
    Change UE Location  ue_id=2  node_id=2  cell_id=2
    Change UE Location  ue_id=1  node_id=2  cell_id=3
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray3:1 CRI
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray8:1 CRI
    Wait for RU recovery and runtime
    Verify If Given Alarm Is Not Active    alarm=1911
    Check If Cell Is In Given State  state=online    cell_id=2
    SA L3 Call
    ##FID 1908
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 0 1908 txArray6:1 MAJ
    Wait for RU recovery and runtime    ru_id=1
    Verify If Given Alarm Is Not Active    alarm=1908
    Check If Cell Is In Given State  state=online    cell_id=3
    SA L3 Call
    ##FID 1907
    Change UE Location  ue_id=2  node_id=2  cell_id=2
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 1 1907 txArray4:1 CRI
    Execute AP AaShell Command    trigger_rf_fault 1 1907 txArray2:1 CRI
    Wait for RU recovery and runtime
    Verify If Given Alarm Is Not Active    alarm=1907
    Check If Cell Is In Given State  state=online    cell_id=2
    SA L3 Call

    Trigger Site Reset to Reset number of recoveries

    ##FID 1910
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 1 1910 txArray4:1 CRI
    Execute AP AaShell Command    trigger_rf_fault 1 1910 txArray2:1 CRI
    Wait for RU recovery and runtime
    Verify If Given Alarm Is Not Active    alarm=1910
    Check If Cell Is In Given State  state=online    cell_id=2
    SA L3 Call
    ##FID 1920
    Execute AP AaShell Command    trigger_rf_fault 1 1920 txArray4:1 MAJ
    Wait for RU recovery and runtime
    Verify If Given Alarm Is Not Active    alarm=1920
    Check If Cell Is In Given State  state=online    cell_id=2
    SA L3 Call
    ##FID 2922
    Execute AP AaShell Command    trigger_rf_fault 1 2922 txArray2:1 MAJ
    Wait for RU recovery and runtime
    Verify If Given Alarm Is Not Active    alarm=2922
    Check If Cell Is In Given State  state=online    cell_id=2
    SA L3 Call
    ##FID 2923
    Execute AP AaShell Command    trigger_rf_fault 1 2923 rxArray3:1 MAJ
    Expect no RU recovery
    Verify If Expected Alarm Is Active    expected_alarm=2923
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 2923 rxArray3:1 MAJ

    Trigger Site Reset to Reset number of recoveries

    Execute AP AaShell Command    trigger_rf_fault 1 1920 txArray4:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1920 txArray6:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1920 txArray2:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 2923 rxArray3:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 2923 rxArray5:1 MAJ persistent
    Execute AP AaShell Command    trigger_rf_fault 1 2923 rxArray8:1 MAJ persistent
    Wait for RU recovery and runtime
    Verify If Expected Alarm Is Active    expected_alarm=1920
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 1920 txArray4:1 MAJ
    Execute AP AaShell Command    cancel_rf_fault 1 1920 txArray6:1 MAJ
    Execute AP AaShell Command    cancel_rf_fault 1 1920 txArray2:1 MAJ
    Execute AP AaShell Command    cancel_rf_fault 1 2923 rxArray3:1 MAJ
    Execute AP AaShell Command    cancel_rf_fault 1 2923 rxArray5:1 MAJ
    Execute AP AaShell Command    cancel_rf_fault 1 2923 rxArray8:1 MAJ
    Sleep    10s

[1]CB009504_B_20_additional_FID_appear_after_failed_RU_recovery
    [Tags]    AZQP_B_20
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=actForceUnitAutoReset    value=true
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=nonCritTrxFailRecoveryCtrl    value=Multiple
    Execute egate command ext    cmd=csi_override_testmode_nr profile_id=2 ri=1 ri_mode=fixed

    ##FID 1911
    Change UE Location  ue_id=2  node_id=2  cell_id=2
    Change UE Location  ue_id=1  node_id=2  cell_id=2
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray3:1 CRI persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray8:1 CRI persistent
    Wait for RU recovery and runtime
    Verify If Expected Alarm Is Active    expected_alarm=1911
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call

    ##FID 1908
    Execute AP AaShell Command    trigger_rf_fault 1 1908 txArray4:1 MAJ persistent
    Expect no RU recovery
    Verify If Expected Alarm Is Active    expected_alarm=1908
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 1908 txArray4:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1908
    Check If Cell Is In Given State  state=degraded    cell_id=2

    ##FID 1907
    Execute AP AaShell Command    trigger_rf_fault 1 1907 txArray2:1 CRI persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1907 txArray4:1 CRI persistent
    Expect no RU recovery
    Execute egate command ext    cmd=ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
    Execute egate command ext    cmd=ue_testmode_set_nr id=2 testmode=csi_override profile_id=2 action=activate
    Verify If Expected Alarm Is Active    expected_alarm=1907
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 1907 txArray2:1
    Execute AP AaShell Command    cancel_rf_fault 1 1907 txArray4:1
    Execute egate command ext    cmd=ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=deactivate
    Execute egate command ext    cmd=ue_testmode_set_nr id=2 testmode=csi_override profile_id=2 action=deactivate
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1907
    Check If Cell Is In Given State  state=degraded    cell_id=2

    Trigger Site Reset to Reset number of recoveries
    ##FID 1911
    Change UE Location  ue_id=2  node_id=2  cell_id=2
    Change UE Location  ue_id=1  node_id=2  cell_id=2
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray3:1 CRI persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray8:1 CRI persistent
    Wait for RU recovery and runtime
    Verify If Expected Alarm Is Active    expected_alarm=1911
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call

    ##FID 1910
    Execute AP AaShell Command    trigger_rf_fault 1 1910 txArray4:1 CRI persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1910 txArray2:1 CRI persistent
    Expect no RU recovery
    Execute egate command ext    cmd=csi_override_testmode_nr profile_id=2 ri=1 ri_mode=fixed
    Execute egate command ext    cmd=ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
    Execute egate command ext    cmd=ue_testmode_set_nr id=2 testmode=csi_override profile_id=2 action=activate
    Verify If Expected Alarm Is Active    expected_alarm=1910
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 1910 txArray4:1
    Execute AP AaShell Command    cancel_rf_fault 1 1910 txArray2:1
    Execute egate command ext    cmd=ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=deactivate
    Execute egate command ext    cmd=ue_testmode_set_nr id=2 testmode=csi_override profile_id=2 action=deactivate
    Trigger RU2 reset to fix AP
    Verify If Given Alarm Is Not Active    alarm=1910
    Check If Cell Is In Given State  state=degraded    cell_id=2

    ##FID 1920
    Execute AP AaShell Command    trigger_rf_fault 1 1920 txArray4:1 MAJ persistent
    Expect no RU recovery
    Verify If Expected Alarm Is Active    expected_alarm=1920
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 1920 txArray4:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=1920
    Check If Cell Is In Given State  state=degraded    cell_id=2

    Trigger Site Reset to Reset number of recoveries
    ##FID 1911
    Change UE Location  ue_id=2  node_id=2  cell_id=2
    Change UE Location  ue_id=1  node_id=2  cell_id=2
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray3:1 CRI persistent
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray8:1 CRI persistent
    Wait for RU recovery and runtime
    Verify If Expected Alarm Is Active    expected_alarm=1911
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call

    ##FID 2922
    Execute AP AaShell Command    trigger_rf_fault 1 2922 txArray2:1 MAJ persistent
    Expect no RU recovery
    Verify If Expected Alarm Is Active    expected_alarm=2922
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 2922 txArray2:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=2922
    Check If Cell Is In Given State  state=degraded    cell_id=2

    ##FID 2923
    Execute AP AaShell Command    trigger_rf_fault 1 2923 rxArray3:1 MAJ persistent
    Expect no RU recovery
    Verify If Given Alarm Is Not Active    alarm=2923
    Check If Cell Is In Given State  state=degraded    cell_id=2
    SA L3 Call
    Execute AP AaShell Command    cancel_rf_fault 1 2923 rxArray3:1
    Sleep     35s
    Verify If Given Alarm Is Not Active    alarm=2923
    Check If Cell Is In Given State  state=degraded    cell_id=2

[1]CB009504_C_21_successful_RU_recovery_in_maintenance_window
    [Tags]    AZQP_C_21
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=actForceUnitAutoReset    value=false
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=nonCritTrxFailRecoveryCtrl    value=Multiple
    ${window_start}    Schedule Maintenance Window Start Time    minutes=5
    Configure Maintenance Window    scheduled_startTime=${window_start}

    ##FID 1911
    Change UE Location  ue_id=2  node_id=2  cell_id=2
    Change UE Location  ue_id=1  node_id=2  cell_id=2
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray3:1 CRI
    Execute AP AaShell Command    trigger_rf_fault 1 1911 rxArray8:1 CRI
    Sleep     8min
    Verify If Given Alarm Is Not Active    alarm=1911
    gnb_bbu.Verify gNB Configuration Parameters Have Expected Values    param_dict=${RU2_recovery_result}
    Check If Cell Is In Given State  state=online    cell_id=2
    SA L3 Call

    Deconfigure Maintenance Window
    ${window_start}    Schedule Maintenance Window Start Time    minutes=5
    Configure Maintenance Window    scheduled_startTime=${window_start}

    ##FID 2923
    Change UE Location  ue_id=2  node_id=2  cell_id=3
    SA L3 Call
    Execute AP AaShell Command    trigger_rf_fault 0 2923 rxArray5:1 MAJ
    Sleep     8min
    Verify If Given Alarm Is Not Active    alarm=2923
    gnb_bbu.Verify gNB Configuration Parameters Have Expected Values    param_dict=${RU1_recovery_result}
    Check If Cell Is In Given State  state=online    cell_id=3
    SA L3 Call

    [Teardown]    Teardown without site reset

*** Keywords ***
Trigger Site Reset to Reset number of recoveries
    Trigger site reset
    Sleep    60s
    Wait Until Keyword Succeeds    1 min    10 sec    gnb_ru.wait_for_all_radio_unit_statuses   operational_state=enabled   timeout=600
    Sleep    240s

Wait for RU recovery and runtime
    [Arguments]    ${ru_id}=2
    Wait Until Keyword Succeeds    1 min    10 sec    gnb_ru.wait_for_radio_unit_statuses   ru_id=${ru_id}   operational_state=disabled   timeout=600
    Sleep    30s
    Wait Until Keyword Succeeds    1 min    10 sec    gnb_ru.wait_for_all_radio_unit_statuses   operational_state=enabled   timeout=600
    Sleep    240s

Expect no RU recovery
    [Arguments]    ${ru_id}=2
    Run Keyword And Expect Error	STARTS:Keyword 'gnb_ru.wait_for_radio_unit_statuses' failed after retrying for 1 minute
    ...    Wait Until Keyword Succeeds    1 min    10 sec    gnb_ru.wait_for_radio_unit_statuses   ru_id=${ru_id}   operational_state=disabled
    ...    timeout=240

Trigger RU${ru_id:\d+} reset to fix AP
    gnb_ru.reset_radio_unit    radio_unit_id=${ru_id}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb_ru.wait_for_radio_unit_statuses   ru_id=${ru_id}   operational_state=enabled   timeout=600
    Sleep    240s

Teardown without site reset
    Run Keywords
    ...    Test Case Teardown
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report
