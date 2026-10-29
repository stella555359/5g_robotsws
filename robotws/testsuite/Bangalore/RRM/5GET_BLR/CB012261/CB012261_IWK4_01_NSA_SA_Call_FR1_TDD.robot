*** Settings ***
Force Tags      CLOUD_5G_I_MO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 neravati.dheeraj_nehru@nokia.com
...             maintainer:             neravati.dheeraj_nehru@nokia.com
...
...             INTRODUCTION:      CB012261_C_IWK4_01_UL_MU_MIMO_CB008360_AB1
...             TEST SET NAME:     CB012261_C_IWK4_01_UL_MU_MIMO_CB008360_AB1
...             TESTING SPLIT:     See CB012261 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB012261 CFAM


Resource         ./CB012261_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Update bsr package
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot   # sosreport
...                 AND     Kill WTS processes Using WTS_Runner

Test Teardown       Run Keyword and Ignore Error      Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/SCFC_IWK_CB008360.xml
${AP_XML}=      ${CURDIR}/config/SCF/IPHY_AEQE_1CELL_8D8U_IWK_CB008360.xml

${wts_cfg_file}    ${CURDIR}/config/wts/wts_IWK_CB008360.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus
${PM_PCELL_COUNTER1}        M55306C00001
${PM_PCELL_COUNTER2}        M55306C00001
${PM_PCELL_COUNTER3}        M55306C00001
${PM_PCELL_COUNTER4}        M55306C00001
${PM_PCELL_COUNTER5}        M55306C00001
${PM_PCELL_COUNTER6}        M55306C00001
${PM_PCELL_COUNTER7}        M55306C00001
${PM_PCELL_COUNTER8}        M55306C00001
${PM_PCELL_COUNTER9}        M55306C03001
${PM_PCELL_COUNTER10}       M55306C06001

${duration}     120

*** Test Cases ***
[1]CB012261_C_IWK4_01_UL_MU_MIMO_CB008360_AB1

    sleep     180s
    log to console   UE attach trigerring now...
    start log    btslog
    ${crnti_ist1}=      MultiUE Register should be Successful    1      2
    sleep    2s
    Configure location for UE     1     1     2     3
    Configure location for UE     2     2     3     3
    sleep    2s

    Start log       ttitrace
    Trigger UL Traffic for SA MU MIMO UE      1     140
    Trigger UL Traffic for SA MU MIMO UE      2     140
#    MultiUE Trigger UL Traffic for SA with duration    1    2    Traffic_rate=mbps    ul_rate=${150}    duration=${duration}
    sleep     5s
    ${path_tti}    Stop Log      ttitrace    test_scenario=SCN1
    sleep     ${duration}s

    ${tp_ue1}      Validate SA UL Traffic    ue_id=${1}    rate=${140}    call_dur=${duration}
    ${tp_ue2}      Validate SA UL Traffic    ue_id=${2}    rate=${140}    call_dur=${duration}

    Common TTI PCAP to CSV Converter    SCN1    dir=ul
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}
    ${path_syslog}    Stop log    btslog
    ${search_string}        Create List      WRN/     ERR/
    syslog_search      ${path_syslog}[btslog]/gnb_syslog.log         ${search_string}

    ${ret}    Verify_2prb_CB012261    ${path_tti}[ttitrace]/output_ul_formated.csv    TDD    longpucch     shortprach     UL_MIMO
    ...            ${50}     ${44}    ${7}    ${1}     Enabled
    Should Contain    ${ret}     Pass

*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
     ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
     coam.teardown admin

Configure location for UE
    [Arguments]    ${profile_id}    ${id}     ${quad_post}     ${sub_quad_post}
    wtsrunner.ul_mimo_srs_beam_pos_nr    profile_id=${profile_id}    mode=fixed     test_type=UL_MIMO init_quad_pos=${quad_post}
    ...      init_sub_quad_pos=${sub_quad_post}    step=5      trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr     id=${id}    testmode=ul_mimo_srs_beam_pos    profile_id=${profile_id}    action=activate

Trigger UL Traffic for SA MU MIMO UE
    [Arguments]    ${id}     ${tp_mbps}
    wtsrunner.trf_data_start     ue=${id}    pdu=1    qfi=1     dir=ul    trf_id=1    mbps=${tp_mbps}     protocol=tcp
