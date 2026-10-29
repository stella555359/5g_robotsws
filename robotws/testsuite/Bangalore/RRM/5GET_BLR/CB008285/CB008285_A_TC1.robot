*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   VARIANT_SA_FS_ECPRI_MMWV_TDD

Resource         CB008285_Resource.robot
Resource         ../CB007145/resources/common/CB007145_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes how to configure a gNB with FR2 SA Cell with Single SSB
...             TEST SET NAME:    CB008285
...             TESTING SPLIT:    Refer CB008285 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008285 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20099



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_4cell_2CG.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1

${SCFC}=                   ${CURDIR}/config/A_TC1/SCF_8285_A_TC1_GMC.xml
${AP_XML}=                 ${CURDIR}/config/A_TC1/IPHY_8285_A_TC1.xml


*** Test Cases ***
[1][2.0] CB008285-A#B1#TC1_FR2_Standalone_deployment_For_Single_SSB

    [Tags]     QC_300420
    set test variable      ${LOG_PATH}
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    log to console   "UE attach trigerring now"
#Step 1. Attach SA UE-1 on cell-1 and Start Data Traffic
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=30
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=30
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}


