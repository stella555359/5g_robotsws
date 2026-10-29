*** Settings ***
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED


Documentation
...
...  AUTHOR          :   Shaheena Parveen
...  MAINTAINER      :   shaheena.parveen@nokia.com
...  INTRODUCTION    :   Verification of CB013440 Enhanced Broadcast and Control Channel Transmission for non-BF cells
...  in NSA mode with using 2TX for SSB, TRS, cell specific PDCCH,and cell specific PDSCH and UE specific PDCCH.
...  TEST SET NAME   :   CB013440-CB013440 Enhanced Broadcast and Control Channel Transmission for non-BF cells
...  REFERENCES      :   CB013440-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_28814;5G_CP_ARC_ALG_15845

Resource         ${CURDIR}/resources/CB013440_Resource_A.robot
Library          taf.sw.scout    WITH NAME     scout
Library          DateTime
Library          logging


Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with CB013440_A.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}    1    4
...                 AND       Check gNB Bulid

Suite Teardown      Run Keywords    wts_sim_keywords.Clean edaemon and egate
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Teardown      Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}          ${CURDIR}/config/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${UE_ID}       101
${target_cell}    10
${enb_id}    1
${enb_target}    2
${start_ueid}   101
${end_ueid}     101
${QFI_ID1}     1
${TRF_ID1}     1
${exp_dscp}        0
${AP_XML}=      ${CURDIR}/config/iphy.xml

*** Test Cases ***
[1][1.0]USCB013440-A#B2_Verification of 2TX transmission of SSB, TRS and cell specific PDSCH for Closed Loop 4x4 or 4x2 DL MIMO mode_FDD_NSA
    set test variable      ${LOG_PATH}
    log to console   Suite setup successful ...
    NSA X2AP Link Should be UP    ${enb_id}    ${enb_target}
    Collect BIP and decode with NSA    test_scenario=DL_data_13440_enabled
    Verifying MIB with CB013440 Enabled      ${path_BIP}
    Verifying SIB with CB013440 Enabled      ${path_BIP}
    Verifying MSG2    ${path_BIP}






