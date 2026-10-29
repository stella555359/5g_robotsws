*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors: Ganesha U
...              :contact: ganesha.u@nokia.com
...              This user scenario describes attachment of the RedCap UE to the 35MHz cell.
...              CB008152_A_IWK.4_TC16_RedCap_UE_attach_ when_CB007552_enabled



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         resources_keywords.resource
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords      Prepare TL with all config files
...                 AND    Suite setup from scratch
...                 AND    Start WTS Using WTS_Runner Check Redcap   ${wts_cfg_file}

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_n66_red.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${SCFC}=                   Bangalore/RRM/ET/CB008152/CB008152_A_TC16_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008152/CB008152_A_TC16_iphy.xml

*** Test Cases ***
[1]CB008152_A_IWK.4_TC16_RedCap_UE_attach_ when_CB007552_enabled
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start log  btslog   cprt
    log to console   Suite setup successful ...
    Redcap UE Register should be Successful     3
    Send DL and UL Data
    sleep    10s     reason=wait to stable data
    Validate DL Traffic For SA      ue_id=3     dl_rate=214
    UE Deregister should be Successful     3
    ${sherp_tti}    Stop Log   btslog   cprt  snapshot  test_scenario=dl_logs

*** Keywords ***
Send DL and UL Data
    Trigger DL Data Traffic for SA    ue_id=3     Traffic_rate=mbps     dl_rate=175     pdu_id=1     trf_id=1
    Trigger DL Data Traffic for SA    ue_id=3     Traffic_rate=mbps     dl_rate=175     pdu_id=1     trf_id=2

