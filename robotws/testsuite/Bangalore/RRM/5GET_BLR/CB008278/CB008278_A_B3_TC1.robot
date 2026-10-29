*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED
#...             CONFIGS_Bangalore/RRM/ET/CB008278/8278_A_B3_TC1.yaml

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
...             author:            Mundanad Vishnu
...             maintainer:        mundanad.vishnu@nokia.com
...
...             INTRODUCTION:     Multiple UE SA data call on 10MHZ TDD with Frame Strcuture 5GC001208 and CB006878 enable
...             TEST SET NAME:    CB008278-A Basic 10 MHz support for CHILE AEHC
...             TESTING SPLIT:    Refer CB008278 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008278 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18745



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_10MHz.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}

${SCFC}     ${CURDIR}/config/SCF_8278_A_B3_TC1.xml
${AP_XML}   ${CURDIR}/config/IPHY_8278_A_B1_TC1.xml


*** Test Cases ***
[1]CB008278-A#B3_TC1_MultipleUE_SA_call_TDD_10MHz_CB006878_enable_frameStructureType_5GC001208
    set test variable      ${LOG_PATH}
    Start Log        cprt      btslog
    log to console   UE attach trigerring now...
    sleep     60s
#Step 1. Attach SA UE-1,2,3 on cell-1 and Start Data Traffic
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id3}     ${1}    ${1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id3}   Traffic_rate=mbps     dl_rate=150
    ...    pdu_id=${1}     trf_id=${1}   qfi_id=${1}
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id3}   Traffic_rate=mbps     ul_rate=150
    ...    pdu_id=${1}     trf_id=${1}   qfi_id=${1}
    sleep  60s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id3}   dl_rate=36   pdu_id=${1}     qfi_id=${1}
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id3}   ul_rate=4.5    pdu_id=${1}     qfi_id=${1}
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id3}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id3}
    Stop Log      cprt     btslog      snapshot        sosreport
