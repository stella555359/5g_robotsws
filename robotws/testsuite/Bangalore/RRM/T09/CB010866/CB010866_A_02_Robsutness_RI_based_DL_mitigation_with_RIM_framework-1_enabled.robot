*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...  AUTHOR          :   Ganesha.U  ganesha.u@nokia.com
...  MAINTAINER      :   Ganesha.U  ganesha.u@nokia.com
...  INTRODUCTION    :   CB010866 RIM Mitigation Enhancemment
...  TEST SET NAME   :   CB010866_A_02_Robsutness_RI_based_DL_mitigation_RIM-RS_is_detected_before_RI_disappears_
...                      stop_DL_mitigation_after_supervision_timer_of_RIM-RS
...  TESTING SPLIT   :   Split-A
...  CONTACTS        :   Ganesha.u@nokia.com
...  REFERENCES      :   CB010866-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_24246;5G_RAN_USR_RRM_24301

Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         CB010866_resource.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ta5g_enb
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          taf.sw.scout    WITH NAME     scout
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Library          ../../../resources/python/avg_dl_data.py


Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with Enable_RIMRS.json
...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    4



Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262219
${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

*** Test Cases ***
[1]CB010866_A_02_Robsutness_RI_based_DL_mitigation_RIM-RS_is_detected_before_RI_disappears_stop_DL_mitigation_after_supervision_timer_of_RIM-RS
    Set test variable      ${LOG_PATH}
    Register and Send High Data
    Check Tput    ue_id=1   scell_idx=0
    FOR    ${item}    IN RANGE   ${94}   ${96}
         Activate and Dectivate RI and Check Alarm    ${item}
    END
    sleep  10s  reason=stable data
    Check Tput    ue_id=1   scell_idx=0
    Stop log    snapshot  test_scenario=snap

*** Keywords ***
Activate and Dectivate RI and Check Alarm
    [Arguments]    ${item}
    common_log_collection.Start Log    btslog
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=RI triggered DL mitigation on PDSCH special slot
    Log to console    Counter Validation
    Verify The Counter
    Generate RS1    ${item}
    Log to console     RS1 Triggered
    Wait For Fault To Be Up     fault_id=7527   timeout=1200
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=RIM RS1 is detected
    Deactivate RI
    Log to console     RI deactivated and waiting for 7525 down.
    Wait For Fault To Be down     fault_id=7525   timeout=500
    Log to console    alarm 7527 and 7535 will go down after 10 min of RI disappear.
    Wait For Fault To Be down     fault_id=7527   timeout=650
    Wait For Fault To Be down     fault_id=7535   timeout=100
    ${syslog_path}    Stop Log    btslog    test_scenario=syslog${item}
    sleep    5s

Register and Send High Data
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=1
    FOR    ${trf}    IN RANGE   ${1}   ${6}
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     dl_rate=175     pdu_id=1   trf_id=${trf}
    END
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=175     pdu_id=1   trf_id=1
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=175     pdu_id=1   trf_id=2
    sleep    10s

Check Tput
    [Arguments]    ${ue_id}=1   ${scell_idx}=0
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_DL} > 600
    ${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_UL} > 150

Verify The Counter
    PM_Counters.Wait until the next Measurement Period starts
    PM_Counters.Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Special_slots}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=NRCELL-1
    Should be True    ${Special_slots} == 300.0
