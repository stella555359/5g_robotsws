*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008200_Resource.robot
Resource          ./resources/common/common_setup_teardown.robot
Library          ./resources/python/PM_Counter_Verify.py

#Suite Setup         Run keywords     Add RD Parameters To GNB Swconfig File    0x480005=0
#...                 AND     gnb.Perform gNB reboot
#...                 AND     sleep   600s

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_2CC_TDD_VONR_MultiUE.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
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
...             Requirement ID:    5G_PM_461

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_tdd_multi_ue_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${10}

*** Test Cases ***
[1]CB008200-E_2_UEs_with_buffered_UL_data_in_5QI-1_DRB
#    [Tags]     QC_201786      QCD_MN_RAN    QCP_RAN_ET

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
