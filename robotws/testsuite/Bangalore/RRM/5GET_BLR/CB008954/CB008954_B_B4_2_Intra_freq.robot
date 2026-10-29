*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Introduction : This Test scenario validates the intra gNB HO with the cell setup of 2BWP's i.e 20Mhz & 30Mhz in source cell
...                            FDD and 30Mhz, 40Mhz in target cell FDD
...             Test Set Name: [1]CB008954_B_B4_2_Intra_freq_intra_DU_handover_UE_supporting_second_BWP
...             Testing Split: CB008954 Split B testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008954 CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND    Add routes
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/intra_xn_ho.cfg
${WTS_DIR}          /opt/iphy/latest
${start_ue}        51
${end_ue}        53
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
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${SCFC}=                   ${CURDIR}/config/SBTS25R2/TC1_IntragNB_HO_SCF.xml
${AP_XML}=                 ${CURDIR}/config/wts/TC1_IntragNB_HO_IPHY.xml

*** Test Cases ***
[1]CB008954_B_B4_2_Intra_freq_intra_DU_handover_UE_supporting_second_BWP
    [Documentation]   This scenario is to verify the cell setup with 2 dedicated BWPS 20,30,MHz in Source gNB and 30,40Mhz in Target gNB

     ${large_bwp_rnti}    MultiUE Register should be Successful     ${51}    ${52}
     MultiUE Trigger UL Traffic for SA    ${51}  ${52}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${51}  ${52}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     Start Log         ttitrace
     sleep    5s
     ${scen3}     Stop Log     ttitrace         test_scenario=mix1
     Get Configured Measurements of UE${start_ue}
     Start Log      btslog     cprt
     ${houe_small_bwp_rnti}    Trigger A3 RsrpAndRsrq Measurement for intragnb HO Custom   51     52    1    53
     sleep    5s
     Verify Counters incrementing as expected
     ${scen1}     Stop Log      btslog     cprt
     Verify locationAndBandwith for allocated BWP     ${scen1}[cprt]/NODECPRT_GNB.pcap     32174
     Start Log         ttitrace
     sleep    5s
     ${scen4}     Stop Log     ttitrace         test_scenario=mix2
     MultiUE Deregister should be Successful     ${51}      ${52}
     sleep   30s
     ${small_bwp_rnti}    MultiUE Register should be Successful     ${54}    ${54}
     MultiUE Trigger UL Traffic for SA    ${54}  ${54}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${54}  ${54}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     Verify 8954 counters cell3

     Start Log         ttitrace
     sleep    5s
     ${scen5}     Stop Log     ttitrace         test_scenario=mix3
     MultiUE Deregister should be Successful     ${54}      ${54}
     sleep   30s

     ${large1_bwp_rnti}    MultiUE Register should be Successful     ${53}    ${53}
    MultiUE Trigger UL Traffic for SA    ${53}  ${53}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${53}  ${53}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    Verify 8954 counters cell4

     Start Log         ttitrace
     sleep    5s
     ${scen6}     Stop Log     ttitrace         test_scenario=mix4


     Decode TTI Trace   mix1
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${3}
     ${large_bwp_id}   Set Variable    ${2}
     ${small_bwp_size}    Set Variable    ${160}
     ${second_bwp_size}    Set Variable    ${0}
     ${large_bwp_num_prb}    Set Variable    ${106}
     ${Mix1}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    large_bwp_ues=${large_bwp_rnti}
    should contain    ${Mix1}     pass
     Decode TTI Trace   mix2
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${3}
     ${large_bwp_id}   Set Variable    ${2}
     ${small_bwp_size}    Set Variable    ${160}
     ${second_bwp_size}    Set Variable    ${0}
     ${large_bwp_num_prb}    Set Variable    ${216}
     ${Mix2}     validate_bwps    ${scen4}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}   ${large_bwp_id}
     ...     ${small_bwp_size}   ${second_bwp_size}    ${large_bwp_num_prb}    small_bwp_ues=${houe_small_bwp_rnti}
     should contain    ${Mix2}     pass

     Decode TTI Trace   mix3
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${3}
     ${large_bwp_id}   Set Variable    ${2}
     ${small_bwp_size}    Set Variable    ${160}
     ${second_bwp_size}    Set Variable    ${0}
     ${large_bwp_num_prb}    Set Variable    ${106}
     ${Mix3}    validate_bwps    ${scen5}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    small_bwp_ues=${small_bwp_rnti}
    should contain    ${Mix3}     pass

     Decode TTI Trace   mix4
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${3}
     ${large_bwp_id}   Set Variable    ${2}
     ${small_bwp_size}    Set Variable    ${160}
     ${second_bwp_size}    Set Variable    ${0}
     ${large_bwp_num_prb}    Set Variable    ${216}
     ${Mix4}     validate_bwps    ${scen6}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    large_bwp_ues=${large1_bwp_rnti}
    should contain    ${Mix4}     pass
