*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB005788/CB005788_AVQL.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   SBTS23R4    CONFIGURED

Resource         ./resources/CB005788_common_resources.robot


Suite Setup         Run Keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with 5GC000430_5GC001116.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready

Suite Teardown      Run Keywords     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...  AUTHOR          :  Ragunath Seenan
...  MAINTAINER      :  ragunath.seenan@nokia.com
...  INTRODUCTION    :  This test scenario describes on-line feature activation and deactivation by following NIDD
...                     actMicroDtx= True
...                     actRFCooling= True/False
...                     allowGBRMutingForRfCooling= On/Off
...                     Verifies below counters
...                     M55601C00016    No of samples when the NR cell is in RF cooling mode0
...                     M55601C00017    No of NR cell state changes to RF cooling mode0
...                     M55601C00018    No of samples when the NR cell is in RF cooling mode2
...                     M55601C00019    No of NR cell state changes to RF cooling mode2
...  TEST SET NAME   :  CB005788_A_Validate_Counter_Samples_And_NumOf_CellStateChange_When_NRcells_inRFcoolingMode
...  TESTING SPLIT   :  CB005788-A
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_19715, 5G_RAN_USR_RRM_19716

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/basic_config_tc01.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${scell_idx}    0
${nwslice_ID}    1
${gw_ID}     1
${pdu_id}    1
${nw_id}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${ue_id}     1
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id}      1
${en_ue_id}      1
${startMutingParam}    --db 1 set_temp_rating HIGH
${stopMutingParam}    --db 1 set_temp_rating NORMAL

*** Test Cases ***
[1]CB005788_A_Validate_Counter_Samples_And_NumOf_CellStateChange_When_NRcells_inRFcoolingMode
    Set test variable     ${LOG_PATH}

    Start Log    cprt
    Perform SCF Delta Commissioning with CB005788_Activation.json
    Configure ETH And Load CFG      ${wts_cfg_file}
    Sleep    3s
    ${path1}    Stop Log    cprt    test_scenario=activation

    Verify allowGbrForRfCooling In CellSetupReq     ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    1

    Start Log    cprt    sherpa
    Wait until the next Measurement Period starts
    Start Slot Muting    ${startMutingParam}
    sleep   60s
    Stop Slot Muting    ${stopMutingParam}
    sleep   60s
    Start Slot Muting    ${startMutingParam}
    sleep   60s
    Stop Slot Muting    ${stopMutingParam}
    Wait until the current Measurement Period stops
    ${pm_files}     Collect and Store PM Counter Files
    ${path2}    Stop Log    sherpa     cprt    test_scenario=rfcooling

    Validate NR CELL RF COOL MODE0 SAMPLES     ${pm_files}
    Validate NR CELL RF COOL MODE0 STATE CHANGE     ${pm_files}
    Validate NR CELL RF COOL MODE2 SAMPLES     ${pm_files}
    Validate NR CELL RF COOL MODE2 STATE CHANGE     ${pm_files}

    Verify rfCooling rfUnitShare tgtMutingRatio in SlotBlankingReq     ${path2}[cprt]/NODECPRT_GNB.pcap    sctp    1     0     35

    Decode Sherpa pcap     rfcooling

