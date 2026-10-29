*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R1    SBTS23R2    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: kavya
...              :contact: kavya.kavya@nokia.com

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ./CB008941_resource.robot
Test Timeout       600 minutes

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM}
##...                 AND     Perform SCF Delta Commissioning with TC_2.json
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=TC2_scfc.xml
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    240
...                 AND     Perform SCF Delta Commissioning with merged_json.json
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords    Stop Log        snapshot
#...                 Fetch AMF and Nglink Status
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Stop Log        btslog
#snapshot    sosreport

#...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
#...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   11   15



*** Variables ***
#${IPHY_FILE}                    ${CURDIR}/config/wts/Conf_7752-B-SANSA-TDD-iphy.xml
${IPHY_FILE}                    ${CURDIR}/config/wts/8941_tc2_iphy.xml
${TEST_NAME}        TC2
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_NSA_tc2_CB008941.cfg
#${CURDIR}/config/wts/basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving

*** Test Cases ***
[1][1.0] CB008941_A3_1_UL_Fragmentaion_is_enabled_and_Successfull_NSA_call_in_UL_and_DL_with_multiple_UEs_in_TDD_with_noBF_Frame_structure_semistatic

#    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    Read Cellsetup msg      ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...
    Start Log       biptaf
    ${crnti_list_1}=      CB008941_resource.MultiUE Attach for NSA    11  18
    ${scen1}     Stop Log     biptaf    test_scenario=attach1
    CB008941_resource.MultiUE DL Traffic Start for NSA    11  18    Traffic_rate=kbps     dl_rate=15          trf_id=${TRF_ID}
    CB008941_resource.MultiUE UL Traffic Start for NSA    11  18    Traffic_rate=kbps     ul_rate=15          trf_id=${TRF_ID}
    Start Log    biptaf     ttitrace
    sleep    1s
    ${scen3}     Stop Log     ttitrace     biptaf    test_scenario=data_1_15
    sleep   30s    #run for 5min


    Validate UL Traffic For MultiUE for NSA   11  18     0.015     2
    Validate DL Traffic For MultiUE for NSA   11  18     0.015     2
    CB008941_resource.MultiUE DL Traffic Stop for NSA     11  18  2   1
    CB008941_resource.MultiUE UL Traffic Stop for NSA   11  18    2   1
    CB008941_resource.MultiUE Detach for NSA     11  18
#    Decode TTI Trace   data_1_15

#    ${rc}    tti_utility.verify_sliv   ${scen3}[ttitrace]/output_ul_formated.csv    ulFdSchedData   SLIV
#    Should Contain  ${rc}   Pass
    ${rc}    Read pucch boundary      ${scen1}[biptaf]/BIP_L1L2.pcap
    Should Contain  ${rc}   pass
    ${rc}    Read pucch boundary      ${scen3}[biptaf]/BIP_L1L2.pcap
    Should Contain  ${rc}   pass
#    ${rc}    Read pucch boundary      ${scen1}[biptaf]/BIP_L1L2.pcap
#    Should Contain  ${rc}   pass
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

