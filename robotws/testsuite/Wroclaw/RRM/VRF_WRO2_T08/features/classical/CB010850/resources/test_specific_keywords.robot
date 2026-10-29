*** Settings ***
Documentation
...   author:  Marcin Bednarski
...   contact: marcin.bednarski@nokia.com

Library     taf.ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB010850/resources/test_specific_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008717/resources/test_specific_keywords_CB008717.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.bip_log_collector.BipLogCollector  WITH NAME  BIP
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}     /home/ute/testline_configuration/7_16_UTE5GCLOUDT095/attenuator_config.yaml
${UE_ALIAS}                UE_1
${GNB_CELL_1}              GNB_1_CELL_210
${GNB_CELL_2}              GNB_1_CELL_211
${GNB_CELL_3}              GNB_1_CELL_212
${GNB_CELL_4}              GNB_1_CELL_213
${ENB_CELL_1}              ENB_1_CELL_21


*** Keywords ***
Test Setup
    Set Testname Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Initialize Attenuator
    Verify Bts Is Operational
    Collect Scf Before Test


Test Teardown
    Verify Bts Is Operational
    Add Scout Scf Id To Test Data
    WATCHDOG.Stop Watching Alarms
    Release Attenuator
    Run Keyword And Ignore Error    interface.Common Step Trigger
    Run Keyword And Ignore Error    Clear Admin Logs
    Run Keyword If Test Failed      Make Webui Snapshot


TC07_CB010850_Aa_B1_B2_Feature_activation_and_deactivation_SA_20MHz_HighEgdel
    Start Collecting Logs
    Activate Feature And Confirm Bts Is Operational
    Deactivate Feature And Confirm Bts Is Operational
    Stop Collecting Logs


Start Collecting Logs
    Log To Console  \nStarting Logs Collection...
    test_specific_keywords.Create Syslog Collector  BtsLog.tgz
    Start Syslog


Stop Collecting Logs
    Log To Console  \nStopping Logs Collection...
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Set Test Variable    ${BTS_LOG_PATH}    ${OUTPUT_DIR}/${TEST_NAME}/btslog/btslogs_merged/btslog.LOG


Verify Bts Is Operational
    Log To Console  \nBTS Verification Ongoing...
    Verify Gnb Is OnAir
    WATCHDOG.Check Detected Alarms


Activate Feature And Confirm Bts Is Operational
    Log To Console  \nFeature Activation Ongoing...
    Execute Delta Recommissioning   cb010850=True
    Verify Bts Is Operational


Deactivate Feature And Confirm Bts Is Operational
    Log To Console  \nFeature Deactivation Ongoing...
    Execute Delta Recommissioning   cb010850=False
    Verify Bts Is Operational


TC10_CB010850_Ab_B3_Single_UE_scheduling_SA_25MHz_HighEgde
    Start Collecting Logs
    Activate Feature And Confirm Bts Is Operational
    Prepare Ue
    Attach To Target Cell    ${GNB_CELL_2}  0dB
    Start Ul Throughput
    Collect Bip Log
    Stop Ul Throughput
    taf.ue.Detach UE  UE_1
    Verify Number Of Prbs In Json File    72    76
    [Teardown]  Run Keywords    Deactivate Feature And Confirm Bts Is Operational    AND    Stop Collecting Logs


Prepare UE
    taf.ue.Require UE  ${UE_ALIAS}  capabilities=REAL_ANDROID_UE
    Run Keyword And Ignore Error  taf.ue.Detach UE  UE_1
    Builtin.Sleep  10s


Collect Bip Log
    BIP.Start Log Collecting
    Builtin.Sleep    3s
    BIP.Stop Log Collecting
    ${pcap_path}=   BIP.Download Log    ${LOG_PATH}/${TESTNAME}/
    Set Test Variable    ${PCAP_PATH}    ${pcap_path}


Start Ul Throughput
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL
    ...     ue_alias=UE_1
    ...     direction=UL
    ...     duration=30s
    ...     throughput=100Mbits/sec
    ...     protocol=udp
    ...     packet_size=1400


Stop Ul Throughput
    taf.ue.Await Data Transfer Finish   DT_UL


Verify Number Of Prbs In Json File
    [Arguments]     ${target_num_prb}   ${target_sum_prb}
    Convert To Json And Verify Num Of Prbs   ${PCAP_PATH}    ${LOG_PATH}/${TESTNAME}/json_file.json
    ...     ${target_num_prb}   ${target_sum_prb}


Attach To Target Cell
    [Arguments]    ${target_cell}    ${attenuation}
    Set Attenuation For Target Cell    ${target_cell}    ${attenuation}
    Attach  ${UE_ALIAS}
    Builtin.Sleep    10s


TC22_CB010850_Ac_IWK9_PRB_Blanking_with_multiple_BWPs_VoNR_SA_25MHz_HighEgde
    Start Collecting Logs
    Prepare Ue
    Attach To Target Cell    ${GNB_CELL_3}  0dB
    Start Voice Call    VC    UE_1    +555800903300998    60s
    Start Ul Throughput
    Collect Bip Log
    Stop Ul Throughput
    Await Voice Call Finish    VC
    Stop Collecting Logs
    Verify Number Of Prbs In Json File    99    107


TC20_CB010850_Ac_IWK9_PRB_Blanking_with_multiple_BWPs_ANR_HO_SA+NSA_25MHz_HighEgde
    Start Collecting Logs
    Remove Nrrel Object
    Prepare Ue
    Attach To Target Cell    ${GNB_CELL_3}  0dB
    Perform Intra Gnb Handover    ${GNB_CELL_3}    ${GNB_CELL_4}
    Start Ul Throughput
    Collect Bip Log
    Stop Ul Throughput
    Stop Collecting Logs
    Verify Intra Gnb Handover    ${BTS_LOG_PATH}
    Verify Number Of Prbs In Json File    99    107


TC27_CB010850_Ac_IWK12_Interworking_with_initial_BWP_SA+NSA_20MHz_HighEgde_with_smallest_RRC_setup
    Start Collecting Logs
    Prepare Ue
    Attach To Target Cell    ${GNB_CELL_1}  0dB
    Start Ul Throughput
    Collect Bip Log
    Stop Ul Throughput
    Verify Number Of Prbs In Json File    72    76
    Stop Collecting Logs
