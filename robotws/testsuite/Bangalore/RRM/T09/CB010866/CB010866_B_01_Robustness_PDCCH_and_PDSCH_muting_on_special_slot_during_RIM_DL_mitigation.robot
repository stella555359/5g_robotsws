*** Settings ***
Force Tags        CLOUD_5G_I_MP_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation  This user scenario verifies the PDCCH and PDSCH slots muting during RIM mitigation period
...  AUTHOR          :   Meghana S  meghana.s@nokia.com
...  MAINTAINER      :   Meghana S  meghana.s@nokia.com
...  INTRODUCTION    :   CB010866 RIM Mitigation Enhancemment
...  TEST SET NAME   :   CB010866_B_01_Robustness_PDCCH_and_PDSCH_muting_on_special_slot_during_RIM_DL_mitigation
...  TESTING SPLIT   :   Split-B
...  CONTACTS        :   Meghana.s@nokia.com
...  REFERENCES      :   CB010866-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_25026


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
...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_scf_Rim_detection.json
...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    2

Test Teardown    Run Keywords    Get Sos Report
...              AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/new_basic.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262219
${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${start_cell}=     1
${end_cell}=       2

*** Test Cases ***
[1]CB010866_B_01_Robustness_PDCCH_and_PDSCH_muting_on_special_slot_during_RIM_DL_mitigation
    [Tags]    QC_363194      QCD_MN_RAN    QCP_RAN_ET
    Set test variable      ${LOG_PATH}
    Register UE and Send High Data
    Check Throughput    ue_id=1   scell_idx=0
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=1000
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot
    Log to console    Counter Validation
    Verify The Counter
    Perform SCF Delta Commissioning with PDCCH_Delta_Configuration_scf_PDCCHMuting_On.json
        Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot
    Perform SCF Delta Commissioning with PDCCH_Delta_Configuration_scf_PDCCHMuting_OFF.json
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot
    Sleep    10s
    Deactivate RI
    Wait For Fault To Be down     fault_id=7525   timeout=800
    Wait For Fault To Be down     fault_id=7535   timeout=800


*** Keywords ***
Register UE and Send High Data
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=1
    FOR    ${trf}    IN RANGE   ${1}   ${6}
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     dl_rate=175     pdu_id=1   trf_id=${trf}
    END
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=175     pdu_id=1   trf_id=1
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=175     pdu_id=1   trf_id=2
    sleep    10s

Check Throughput
    [Arguments]    ${ue_id}=1   ${scell_idx}=0
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_DL} > 600
    ${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_UL} > 150

Verify The Counter
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Special_slots}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=NRCELL-1
    Should be True    ${Special_slots} == 300.0

