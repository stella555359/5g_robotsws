*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED
#...             CONFIGS_Bangalore/RRM/ET/CB008278/8278_F_TC4.yaml

Resource         ../CB007145/resources/common/CB007145_Resource.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Prepare TL with all config files
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Manasa
...             maintainer:        manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     CB008278_F#TC4_10MHz_AEHC_Multiple_UE_attachment_with_PDCCH_configuration_with_CCE_split_with_3_symbols
...                               CB008278_F#B1_TC4 testcase validates setup of TDD cell with 10MHz bandwidth 
...                               followed by system information transmission and UE attach/data transfer for multiple. 
...                               PDCCH configuration with CCE split for all slots. CORESET(0) on 3symbols.
...             TEST SET NAME:    CB008278-E_F_BB_Pooling_PDCCH_Configuration
...             TESTING SPLIT:    Refer CB008278 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008278 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18854



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_fb.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1

${SCFC}     ${CURDIR}/config/SCF_8278_F_TC4.xml
${AP_XML}   ${CURDIR}/config/IPHY_8278_F_TC4.xml

*** Test Cases ***
[1]CB008278_F#TC4_10MHz_AEHC_Multiple_UE_attachment_with_PDCCH_configuration_with_CCE_split_with_3_symbols
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
#Step 1. Attach SA UE-1,2,3 on cell-1 and Start Data Traffic
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id2}    
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id2}   Traffic_rate=mbps     ul_rate=10
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id2}   dl_rate=22
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id2}   ul_rate=6.4
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id2}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id2}
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

