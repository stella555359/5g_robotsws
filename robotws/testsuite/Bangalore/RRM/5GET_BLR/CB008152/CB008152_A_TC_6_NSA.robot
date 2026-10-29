*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...	author/contact: kshitij.tyagi@nokia.com


Resource         ./resources_keywords.resource

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

#Resource           ../CB008541/resources/CB008541_Keywords.robot
#Resource           ./resources_keywords.resource

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/basic_setup_TC6.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        11
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${file_path}    /opt/iphy/latest/egate_console.log
${SA_flag}     0
${scs}    kHz15
${prb}    188
${SCFC}=                   Bangalore/RRM/ET/CB008152/CB008152_A_TC6_NSA_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008152/CB008152_A_TC6_NSA_iphy.xml
${reconf_filepath}      ${CURDIR}/../../../../../


*** Test Cases ***
[1]CB008152_A_B1_TC6_Verify_UE_attach_MAX_DL_UL_traffic_NSA
    [Documentation]    This test case Verifies  NSA UE attach and Data transfer with FDD 35MHz
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console    Triggering UE attach...
    X2AP Link Should be UP
    Start log   btslog    biptaf
    Attach UE and start low data
    Stop Log   biptaf    test_scenario=NSA_attach
    Start max DL Data Transfer
    ${expected_thp}       Create List    770
    Verify DL THP for single cell config    st_ue_id=11    en_ue_id=11    scell_idx=8    expected_thp=${expected_thp}
    Stop Data Transfer
    Start max UL Data Transfer
    Verify UL THP for single cell config     UE_ID=11      scell_idx=8      ul_thp=390
    Stop Data Transfer
    Start max DL Data Transfer
    Start max UL Data Transfer
    sleep   20s    reason=Wait for successful traffic start
    ${expected_thp}       Create List    770
    Verify DL THP for single cell config    st_ue_id=11    en_ue_id=11    scell_idx=8    expected_thp=${expected_thp}
    Verify UL THP for single cell config     UE_ID=11      scell_idx=8      ul_thp=390
    Verify chBW from RRCReconfig message
    UE Detach should be Successful   ${UE_ID}
    Stop Log    btslog      test_scenario=TC_6_syslog


*** Keywords ***

Attach UE and start low data
    LTE Attach should be Successful  NSA_UE_ID=${UE_ID}
    UE Attach should be Successful  NSA_UE_ID=${UE_ID}
    Sleep    2s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     dl_rate=150       trf_id=${TRF_ID}
    Trigger UL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=150       trf_id=${TRF_ID}
    Sleep    8s
    Validate DL Traffic For NSA   ue_id=${UE_ID}      dl_rate=140
    Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=140

Start max DL Data Transfer
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=1
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=2
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=3
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=4
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=5
    sleep   10s    reason=Wait for successful traffic start

Start max UL Data Transfer
    Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=150       trf_id=1
    Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=150       trf_id=2
    Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=150       trf_id=3
    sleep   10s    reason=Wait for successful traffic start

Stop Data Transfer
    Stop Data Traffic for NSA    ue_id=${UE_ID}

Verify chBW from RRCReconfig message

    verify_reconfig.check_reconfig_msg     ${file_path}    ${SA_flag}
    OperatingSystem.Run    mv ${reconf_filepath}/Reconfig_MSG_* ${LOG_PATH}/
    ${output}    OperatingSystem.Get File   ${LOG_PATH}/Reconfig_MSG_1.txt
    BuiltIn.Should Match Regexp    ${output}
    ...    downlinkConfigCommon.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n
    ...    .*\\n.*\n.*subcarrierSpacing\\s${scs}.*\n.*carrierBandwidth\\s${prb}
    BuiltIn.Should Match Regexp    ${output}
    ...    uplinkConfigCommon.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\n.*subcarrierSpacing\\skHz15
    ...    .*\n.*carrierBandwidth\\s${prb}


