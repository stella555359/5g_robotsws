*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB008541/8541_B_B004_2_APoverABIO.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Madhu,Sowrabha
...              :contact: madhusudhan.y@nokia.com,sowrabha.s_m@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier
...         bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small
...         fraction of the large BWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and
...         UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Initiate Dcap
#...                 AND     DCAP Connect To gNB     
#...                 AND     Start DCAP Syslog
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
#...                 AND     Stop And Collect DCAP Syslog      log_dir=${LOG_PATH}
#...                 AND     DCAP Disconnect To gNB

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Sos Report



Test Setup        DCAP Connect To gNB     
Test Teardown     Run Keywords     Get DCAP Snapshot    log_dir=${LOG_PATH}
...     AND       DCAP Disconnect To gNB

*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/basic_setup_intrafreq.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/

*** Test Cases ***
[1]CB008541_5G_B_B004_2_Verify_UE_Connects_From_Cell_With_Configured_PS_BWP_To_Cell_Without_Configured_PS_BWP_Via_Intra_Gnb_HO
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with large BWP, small BWP and
    ...         Power Saving BWP during UE context setup. in the beginning when successful DL/UL data transfer initiated
    ...         verify that data transfer happens in the large BWP,
    ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
    ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    ...        Verify ScellA is deactivated and not used for UL/DL data transmissions when using power saving BWP. Data is switched back to Pcell.
    ...         Verify ScellA is activated and data transmission is on small BWP.
    Register UE and verify initial bwp through tti trace
    Start low DL data and verify psbwp through tti trace
    Run Keyword and Continue On Failure  Verify 8541 counters incrementing
    Trigger A3 measurement for Intragnb HO and verify UE moves to smallBWP using tti trace
    Run Keyword and Continue On Failure  Verify 8541 counters decrementing
	Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}    replace string   ${TEST_NAME}      ${SPACE}        _
    set global variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE and verify initial bwp through tti trace
    log to console   UE attach trigerring now...
    Start Log Via DCAP    btslog
#   Need to add cprt capture
    UE Register should be Successful     ${UE_ID}
    Stop Log Via DCAP   btslog  test_scenario=ue_attach
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Start Log Via DCAP   ttitrace
    Sleep   2s
    ${initial}   Stop Log Via DCAP  ttitrace  test_scenario=initial_data
    Decode TTI Trace    initial_data
    Validate UE bwpid from TTI traces     ${initial}[ttitrace]     ${crnti_list}     ${bwpid}   flag=${False}


Start low DL data and verify psbwp through tti trace
    Start Log Via DCAP    btslog   Bip_monitoring_time=10
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Stop Log Via DCAP   btslog  test_scenario=lowdata
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    Start Log Via DCAP    bip   Bip_monitoring_time=3
    Stop Log Via DCAP   bip  test_scenario=lowdata
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Start Log Via DCAP   ttitrace
    Sleep   2s
    ${lowdata}   Stop Log Via DCAP  ttitrace  test_scenario=lowdata
    Decode TTI Trace    lowdata
    Validate UE bwpid from TTI traces     ${lowdata}[ttitrace]     ${crnti_list}     ${bwpid}   flag=${False}


Trigger A3 measurement for Intragnb HO and verify UE moves to smallBWP using tti trace
#    Start Log Via DCAP    btslog   bip   Bip_monitoring_time=10D
#    neede nip log here
    Start Log Via DCAP    btslog
   	Get Configured Measurements of UE${UE_ID}
	Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${UE_ID}    1    51
    Stop Log Via DCAP   btslog    test_scenario=Handover
#    Stop Log Via DCAP   btslog  bip  test_scenario=Handover
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${smallbwp_id}
    ${crnti_list}     Create List
    Start Log Via DCAP   ttitrace
    Sleep   2s
    ${afterho}   Stop Log Via DCAP  ttitrace  test_scenario=afterho
    Decode TTI Trace    afterho
    Validate UE bwpid from TTI traces     ${afterho}[ttitrace]     ${crnti_list}     ${bwpid}   flag=${False}

Verify 8541 counters incrementing
    log to console   Waiting for counter increment
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=200
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=200
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=200
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=200

Verify 8541 counters decrementing
    log to console   Waiting for counter decrement
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=0

