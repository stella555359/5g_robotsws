*** Settings ***
Force Tags      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008200_Resource.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ./resources/python/PM_Counter_Verify.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_VONR_MultiUE.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Check Cell On Air      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Test Teardown    Run Keywords   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
...              AND        Link SCOUT SCF to Configuration ID for Reporting


Documentation
...
...             author:            Samik Sarkar, samik.sarkar@nokia.com
...             maintainer:        Samik Sarkar, samik.sarkar@nokia.com
...
...             INTRODUCTION:     Feature provides counters for measuring VoNR statistics for clear understanding of the
...                               performance of Voice over NR calls in the network.The feature provides counters related
...                               to Retainability, Accessibility, Utilzation and VoNR Quality.
...                               The feature also provides some counters at PMQAP level
...             TEST SET NAME:    CB008200-E_1_UEs_with_buffered_DL_data_in_5QI-1_DRB.
...                               The purpose of this test is to verify the PM Counter ACC_UE_DL_DRB_DATA_5QI1 update for VoNR per cell for classical
...                               gNB when UE is having DL buffer data in their DRB
...
...             TESTING SPLIT:     See CB008200 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008200 CFAM
...             Requirement ID:    5G_PM_460

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_fdd_multi_ue_vonr_new.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${10}

*** Test Cases ***
[1][1.0] CB008200-E_1_UEs_with_buffered_DL_data_in_5QI-1_DRB
#    [Tags]     QC_201785      QCD_MN_RAN    QCP_RAN_ET

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}

#Step 1. Attach 6 VONR UEs, with PDU session 5QI-6 nonGBR qosflow which is default
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1

#Step 2. Establish pdu_id=2 for 5QI-5 SIP Signalling
    MultiUE PDU Addition should be Successful        ${st_ue_id}    ${en_ue_id}    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=2   qosflows_to_add=2
    Sleep   1s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=2    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=2    trf_id=1       qfi_id=2

#Step 3. Establish pdu_id=2 for 5QI-1 VoNR Call
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=2      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=2     num_trf_id=20    qfi_id=3    rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=2     num_trf_id=20    qfi_id=3    rtp_codec=custom
    sleep       900s
    Wait until the current Measurement Period stops  additional_time=${0}
    CB008200_Resource.Collect PM Counters
    Get buffer counters and validate    M55308C32000    M55308C32001    M55308C02001    M55308C02003    M55308C01000    M55308C01001
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
