*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED     VARIANT_SA_FS_ECPRI_MMWV_TDD

Resource         CB008285_Resource.robot
Resource         ../CB007145/resources/common/CB007145_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${LUA_CFG}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes how to configure a gNB with FR2 SA Cell with 32 SSB
...             TEST SET NAME:    CB008285
...             TESTING SPLIT:    Refer CB008285 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008285 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20140



*** Variables ***
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC2

${LUA_CFG}=                ${CURDIR}/config/A_TC2/32_SSB_BASIC_CONFIG_FILE.cfg
${SCFC}=                   ${CURDIR}/config/A_TC2/SCF_32SSB_4cell_2CG.xml
${AP_XML}=                 ${CURDIR}/config/A_TC2/iphy_32SSB_4cell_2CG.xml


*** Test Cases ***
CB008285-A#B4_TC2_RRC_connection_establishment_release_FR2_32_SSB_CELL
    [Tags]    QC_302569
    set test variable      ${LOG_PATH}
    log to console   "UE attach trigerring now"
    Link SCOUT SCF to Configuration ID for Reporting
#Step 1. Attach SA UE-1 on cell-1 and Start Data Traffic
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    Trigger High DL Traffic for SA    ${sa_ue_id1}    Traffic_rate=mbps     dl_rate=500
    Trigger High UL Traffic for SA    ${sa_ue_id1}    Traffic_rate=mbps     ul_rate=150
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=468
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=140
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}

