*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...  AUTHOR          :   Kiran.G  kiran.1.g@nokia.com
...  MAINTAINER      :   Kiran.G  kiran.1.g@nokia.com
...  INTRODUCTION    :   CB013138 RIM Mitigation Enhancemment
...  TEST SET NAME   :   CB013138_A_01_03_E_Robsutness_RI_based_DL_mitigation_ManualTrigger
...  TESTING SPLIT   :   Split-A , Split-E
...  CONTACTS        :   kiran.1.g@nokia.com
...  REFERENCES      :   CB013138-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_26469;5G_RAN_USR_RRM_26605;5G_RAN_USR_RRM_26495;5G_PM_1974

Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../CB009215/resources/CB009215_keyword.robot
Resource         CB013138_resource.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout


Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with A3.json
...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    1

Test Teardown       Run Keywords    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262223;0x58057a=4
${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-60,-65,-65,-65,-68,-68,-68,-70,-70,-72,-72,-75,-75,-68,-68,
...                       -68,-68,-67,-67,-67,-69,-69,-65,-65,-65,-115,-115,-115,-115,-115

*** Test Cases ***
[1]CB013138_A_01_03_E_Robsutness_RI_based_DL_mitigation_ManualTrigger
    Set test variable      ${LOG_PATH}
    Setup X2 Link
    Perform SCF Delta Commissioning with RIDetectDLMitigation.json
    sleep  20s  reason=Wait for RIParameterexecution
    Register and Send High Data
    Check Tput    ue_id=1   scell_idx=0
    Activate RI
    sleep  10s
    Activate RI DL Mitigation interaction with Manual Trigger and Check Alarm
    sleep  10s
    Stop log    snapshot  test_scenario=snap

*** Keywords ***
Activate RI DL Mitigation interaction with Manual Trigger and Check Alarm
    Start Log    btslog
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=400
    Wait For Fault To Be Up     fault_id=7535   timeout=400
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus two preceding slots
    Log to console    Counter Validation
    run keyword and continue on failure    Verify The Counter for Special and 2 DL Slots
    Log to console     Change the DL Muting Max range and PDCCH Muting false on Special slot
    Perform SCF Delta Commissioning with RimDLMutingMaxrange_PDCCHMuting_false.json
    Log to console    PDCCHMuting
    sleep    10s
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus two preceding slots
    Log to console    Counter Validation
#    Get Snapshot
    run keyword and continue on failure    Verify The Counter for Special and 1 DL Slot
    Log to console    Enable Manual Trigger for Special and 2 DL Slots
    Perform SCF Delta Commissioning with Manual_Trigger_2DL_Slots.json
    Wait For Fault To Be Down   fault_id=7535   timeout=100
    Wait For Fault To Be Up     fault_id=7525   timeout=100
    Log to console    Counter Validation
    run keyword and continue on failure    Verify The Counter for Special and 2 DL Slots
    Log to console    Enable Manual Trigger for Special and 1 DL Slot and PDCCH Muting true on Special Slot
    Perform SCF Delta Commissioning with Manual_Trigger_1DL_Slot_PDCCHMuting_true.json
    Wait For Fault To Be Up     fault_id=7525   timeout=100
    Log to console    Counter Validation
    run keyword and continue on failure    Verify The Counter for Special and 1 DL Slot
    Log to console    Disable Manual Trigger
    Perform SCF Delta Commissioning with Disable_Manual_Trigger.json
    Wait For Fault To Be Up   fault_id=7535   timeout=200
#    Get Snapshot
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus the preceding slot
    Verify The Counter for Special and 1 DL Slot
    Deactivate RI
    Log to console     RI deactivated and waiting for 7525 and 7535 down after RI disappear
    Wait For Fault To Be down     fault_id=7525   timeout=500
    Wait For Fault To Be down     fault_id=7535   timeout=100
	Log to Console    Counter Validation for No Muting
	Verify The Counter for No Muting
    ${syslog_path}    Stop Log    btslog    test_scenario=syslog
    sleep    5s

Verify The Counter for Special and 2 DL Slots
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    298.0<= ${Special_slot} <= 302.0
    Should be True    298.0<= ${Preceding_DL_slot} <= 302.0
    Should be True    298.0<= ${Preceding_2_DL_slot} <= 302.0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}

Verify The Counter for 1 DL Slot
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} == 0
    Should be True    298.0<= ${Preceding_DL_slot} <= 302.0
    Should be True    ${Preceding_2_DL_slot} == 0
#    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}

Verify The Counter for 2 DL Slots
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} == 0
    Should be True    298.0<= ${Preceding_DL_slot} <= 302.0
    Should be True    298.0<= ${Preceding_2_DL_slot} <= 302.0
#    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}

Verify The Counter for Special and 1 DL Slot
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    298.0<= ${Special_slot} <= 302.0
    Should be True    298.0<= ${Preceding_DL_slot} <= 302.0
    Should be True    ${Preceding_2_DL_slot} == 0
#    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}