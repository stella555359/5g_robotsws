*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Introduction : This Test scenario validates the carrier aggregation with the cell setup of 1BWP's i.e 100Mhz
...                            in pCELL TDD and 10, 20 & 30Mhz in sCELL FDD
...             Test Set Name:[1]CB008954_E_B5_10_Scell_addition_and_CA_band_combination_selection_in_case_of_
...                            limited_BCS_support_in_UE_TDD_FDD_CA_mode
...             Testing Split: CB008954 Split E testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008954 CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=TC10_T_F_CA_SCF.xml
...                 AND     gnb.Perform gNB reboot
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      80

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/ca_t41_f28.cfg
${WTS_DIR}          /opt/iphy/latest
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
${start_ue_id}     1
${end_ue_id}        2
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${IPHY_FILE}                    ${CURDIR}/config/wts/TC10_T_F_CA_IPHY.xml
${SCFC}=        ${CURDIR}/config/SBTS25R1/TDD_2cell_scf.xml
${AP_XML}=      ${CURDIR}/config/wts/TDD_2cell_iphy.xml

*** Test Cases ***
[1]CB008954_E_B5_7_Scell_addition_and_CA_band_combination_selection_in_case_of_limited_BCS_support_in_UE_TDD_FDD_CA_mode

    [Documentation]     This scenario is to verify the carrier aggregation & 3 dedicated BWPS 80,90,100MHz in pCell TDD and 10,20,30Mhz in sCell FDD

    Start Log      btslog     cprt
    ${large_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${2}
    ${scen1}     Stop Log      btslog     cprt
     Verify locationAndBandwith for allocated BWP     ${scen1}[cprt]/NODECPRT_GNB.pcap     1099
     MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

	 Start Log         ttitrace
     sleep    3s
     ${scen3}     Stop Log     ttitrace         test_scenario=mix1

     Verify Scell Addition On High Data Traffic   ${1}   ${2}     1     28875
     Verify DL Tput For 2CC_T_F
     Verify CA Counters    200    200     2100    2
     Start Log         ttitrace
     sleep    3s
     ${scen4}     Stop Log     ttitrace         test_scenario=mix2


     Decode TTI Trace   mix1
     ${small_bwp_id}    Set variable    ${0}
     ${second_bwp_id}   Set Variable    ${0}
     ${large_bwp_id}   Set Variable    ${1}
     ${small_bwp_size}    Set Variable    ${0}
     ${second_bwp_size}    Set Variable    ${0}
     ${large_bwp_num_prb}    Set Variable    ${273}
     ${Mix1}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    large_bwp_ues=${large_bwp_rnti}

     Decode TTI Trace   mix2
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${2}
     ${large_bwp_id}   Set Variable    ${3}
    ${small_bwp_size}    Set Variable    ${52}
     ${second_bwp_size}    Set Variable    ${106}
     ${large_bwp_num_prb}    Set Variable    ${160}
     ${Mix2}     validate_bwps    ${scen4}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}   ${large_bwp_id}
     ...     ${small_bwp_size}   ${second_bwp_size}    ${large_bwp_num_prb}    second_bwp_ues=${large_bwp_rnti}
     [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

