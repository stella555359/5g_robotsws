*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS25R1    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Mateusz Kuropka
...              :contact: mateusz.kuropka@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Resource     feature_keywords.robot
Resource     ../../VRF_WRO2_T04/resources/ute_report.robot


Suite Setup    Run Keywords    Install BSR package
...            AND             With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/${IPHY}
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Start Default Logging
...            AND             Modify SCTP Timeout
...            AND             With Simulator Configuration    config=${BASIC_SETUP}


Suite Teardown    Run Keywords    Stop Default Logging
...            AND                stop_tcpdump_on_remote_interface

*** Variables ***
${IPHY}=              iphy_aqql_2TDD_2FDD_Subbeam.xml
${SCFC}=              Full_Configuration_scf_intra_gNB_intra_freq_HO_pass.xml
${BASIC_SETUP}=       ${CURDIR}/config/wts_2TDD_2FDD_intra_gNB_intra_freq_HO.lua
@{SWCONFIG_FLAGS_LIST}=        ${rdActInterGnbCaWithSrsForSbBf}    ${rdComponentBitMapProfile}
${rdActInterGnbCaWithSrsForSbBf}=        0x590287=1   # rdActInterGnbCaWithSrsForSbBf
${rdComponentBitMapProfile}=        0x5808FF=2  # Activate profile: 1 - All events in tti


*** Test Cases ***
CB011117_A#2a_intra-gnb_intra-freq_HO_with_subbandBF_single_UE
    Perform UE Attach And Start Data Traffic Then Trigger Event A3 And Setup SB Beamforming    alias=SUBBAND
    [Teardown]    Add Scout Data Info To Testcase

*** Keywords ***
Perform UE Attach And Start Data Traffic Then Trigger Event A3 And Setup SB Beamforming
    [Arguments]          ${alias}
    start_tcpdump_on_remote_interface    log_filename_prefix=${alias}    alias=${alias}
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1   enb_id=2    pdu_id=1    gw_id=1
    Activate Srs Beam Test Mode
    Start Specific Data DL Traffic    ue_id=1    pdu_id=1  mbps_per_trf_id=150    first_trf_id=1    last_trf_id=6
    Start TTI trace collection
    Sleep    3
    Trigger intra-gNB intra-frequency handover based on A3 event
    Sleep    3
    Deregister UE    ue_id=1
    Stop TTI trace collection
    Convert TTI trace from pcap  format=excelCsv  directory_name=${alias}
    Perform TTI Checks    alias=${alias}

Perform TTI Checks
    [Arguments]    ${alias}
    log to console     Start Check beamType in TTI Trace
    ${have_subband}    contain_subband    file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${alias}/output_dl.csv
    Should Be True    ${have_subband}
