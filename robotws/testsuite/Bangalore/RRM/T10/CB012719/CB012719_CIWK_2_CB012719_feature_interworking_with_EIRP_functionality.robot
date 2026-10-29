*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...  AUTHOR          :   Kiran Vilas Gawade
...  MAINTAINER      :   Kiran Vilas Gawade
...  INTRODUCTION    :  CB012719 feature allows the traffic in proctected slot whne the cellload is above the
...                    above the thershold value with the configured powerr backoff.
...  TEST SET NAME   :   [1]CB012719_C#IWK_2_ CB012719 feature interworking with EIRP functionality
...  TESTING SPLIT   :   SPLIT-C
...  CONTACTS        :  Kiran Vilas Gawade
...  REFERENCES      :   CFAM CB012719
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_27576

Library          ../../../resources/python/avg_dl_data.py
Resource         ./CB012719_Resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with EIRP_config.json
...       AND    Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR__FS_tddlte_0ms_4_gp_RIM_FW1.json
...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    2

Test Teardown    Run Keywords    Stop Log   btslog    snapshot  sosreport
...   AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}       ${WTS_DIR}/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262223;0x58057a=4
${Pdu_session_ID}       1
${nwslice_ID}           1
#${NOISE_POWER_RI}=       SEPARATOR=
#...                   -40,-45,-50,-55,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,
#...                    -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${NOISE_POWER_RI}       SEPARATOR=
...                       -60,-63,-66,-69,-70,-75,-80,-83,-86,-89,-93,-97,-100,-103,-106,-109,-112,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
*** Test Cases ***
[1]CB012719_C_IWK_2_CB012719_feature_interworking_with_EIRP_functionality

    Set test variable      ${LOG_PATH}
    Setup X2 Link
    Perform SCF Delta Commissioning with rim_pwr.json
    sleep    60s
    Perform SCF Delta Commissioning with delta_rim_drb_config.json
    sleep    60s
    ${protected_slots}    Create List    ${2}    ${3}    ${12}    ${13}
    Wait until the next Measurement Period starts  additional_time=${0}
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1     1        2
    Trigger High DL Data and UL Data      1        2
    BuiltIn.Log                  Throughput before RI
    Validate Throughput      1        2
    Wait until the current Measurement Period stops
    ${Before_RI}         Collect EIRP Counters
    Start log       btslog
    BuiltIn.Log                  RI Triggered
    Activate RI         ${NOISE_POWER_RI}
    Wait For Fault To Be Up     fault_id=7525   timeout=200

    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    Generate RS1andRS2      profile_id=1     config_mode=standalone     victim_cell=1   aggressor_cell=1
    ...    rsSetId=22223     numRsSetId=1     rimRsType=rsType1AndType2     rsNearFarConfig=0    propagation_delay=16
    ...    rsType1NScId=1,2,3,4,5,6,7,8     rsType2NScId=101,102,103,104,105,106,107,108     numRbForRs=96
    ...    rsPattern1Period=50    repetitionRsType1=4     repetitionRsType2=4   rim_framework=framework_1
    ...    factorRsSequence=1     factorRsSequenceRS2=1     offsetRsSequence=1     offsetRsSequenceRS2=1
    ...    numRsType1SetId=65536    numRsType2SetId=65536    rimRsTxPower=-330    rimRsTxPowerRS2=-330
    ...    globalF0ForRs=631206    startFreqOffsetForRs=105,201
    BuiltIn.Log                  RIM-RS
    Wait For Fault To Be Up     fault_id=7527   timeout=500
    Wait For Fault To Be Up     fault_id=7535   timeout=100

    Perform SCF Delta Commissioning with on_rim_pwr_red.json
    sleep    10s
    ${Active_alarm}    ta5g_enb.get_active_alarms
    ${faluts_supres}    Create List    7535
    ${rc}     get_list_of_faults_check    ${Active_alarm}    ${faluts_supres}
    Should Contain	${rc}	fail


    Perform SCF Delta Commissioning with change_thershold_to_low.json
    sleep    200s

    Start Log         ttitrace
    sleep     2s
    ${high_load}     Stop Log     ttitrace

    BuiltIn.Log                  Throughput after RIM
    Validate Throughput      1        2

    Stop log       btslog
    sleep     5s

    Wait until the current Measurement Period stops
    ${After_RI}         Collect EIRP Counters

    Decode TTI Trace
    ${high_status}   get_cqi_derived_verify   ${high_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}

    Should Contain    	${high_status}	 pass
    Should Contain    	${high_status_sche}    pass
    Should be True      ${After_RI} < ${Before_RI}

*** Keywords ***

Trigger High DL Data and UL Data
    [Arguments]    ${st_ue_id}=1        ${en_ue_id}=1
    FOR    ${id}    IN RANGE   ${st_ue_id}        ${en_ue_id}+1
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${id}      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=1
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${id}      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=2
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${id}      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=3
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${id}      Traffic_rate=mbps     ul_rate=100     pdu_id=1   trf_id=1
    sleep    10s
    END

Validate Throughput
    [Arguments]    ${st_ue_id}=1        ${en_ue_id}=1   ${scell_idx}=0
    FOR    ${id}    IN RANGE   ${st_ue_id}        ${en_ue_id}+1
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${id}    ${scell_idx}
    Should be True    ${DATA_DL} > 100
    ${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${id}    ${scell_idx}
    Should be True    ${DATA_UL} > 1
    END

Collect EIRP Counters
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${ACTUAL_TX_POWER}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00464    moc=NRCELL-1
    ${ACTUAL_TX_POWER_BEAM_0}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00400    moc=NRCELL-1
    ${ACTUAL_TX_POWER_BEAM_1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00401    moc=NRCELL-1
    ${EIRP_SAMPLES}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00000    moc=NRCELL-1
    ${EIRP_SEGMENT_1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00101    moc=NRCELL-1
    [Return]      ${EIRP_SEGMENT_1}
