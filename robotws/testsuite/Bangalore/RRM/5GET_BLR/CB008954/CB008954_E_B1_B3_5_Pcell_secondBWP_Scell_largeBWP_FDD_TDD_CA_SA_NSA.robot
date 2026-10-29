*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Introduction : This Test scenario validates the carrier aggregation with the cell setup of 3BWP's i.e 80Mhz, 90Mhz & 100Mhz
...                            in pCELL FDD and 20Mhz, 30Mhz, 40Mhz in sCELL FDD
...             Test Set Name: [1]CB008954_E_B1_B3_7_Carrier_Aggregation_Pcell_configured_with_second_BWP_and_Scell_configured_
...                             with_large_dedicated_BWP_FDD-TDD_SA-NSA_mode
...             Testing Split: CB008954 Split E testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008954 CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb
Resource    ../resources/ECEcommon/common_deal_config_file.robot

Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND    Add routes
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${SCFC}=                   ${CURDIR}/config/SBTS25R2/TC7_T_F_CA_SCF.xml
${AP_XML}=                 ${CURDIR}/config/wts/TC7_T_F_CA_IPHY.xml
${wts_cfg_file}      ${CURDIR}/config/wts/ca_t41_f66.cfg
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
${IPHY_FILE}                    ${CURDIR}/config/wts/TC7_T_F_CA_IPHY.xml
${nsa_st_ue_id}    11
${nsa_en_ue_id}     11
${start_ue_id}     1
${end_ue_id}    2
${r&d_parameter}    0x890073=0
*** Test Cases ***
[1]CB008954_E_B1_B3_5_Carrier_Aggregation_Pcell_configured_with_second_BWP_and_Scell_configured_with_large_dedicated_BWP_FDD-TDD_SA-NSA_mode

    [Documentation] 	This scenario is to verify the carrier aggregation & 3 dedicated BWPS 80,90,100MHz in pCell TDD and 10,20,30Mhz in sCell FDD
     Start Log      btslog     cprt
     ${large_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${2}
     ${scen1}     Stop Log      btslog     cprt
     Verify locationAndBandwith for allocated BWP     ${scen1}[cprt]/NODECPRT_GNB.pcap     32174
     MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

     Start Log         ttitrace
     sleep    3s
     ${scen3}     Stop Log     ttitrace         test_scenario=mix1

     Verify Scell Addition On High Data Traffic   ${1}   ${2}     1     1099
     Verify DL Tput For 2CC T_F
     Start Log         ttitrace
     sleep    3s
     ${scen4}     Stop Log     ttitrace         test_scenario=mix2

     MultiUE Deregister should be Successful     ${1}      ${2}

    X2AP Link Should be UP
    log to console   NSA UE attach trigerring now...
    ${nsa_large_bwp_rnti}    MultiUE NSA Attach    ${11}  ${11}   3
    MultiUE DL Traffic Start for NSA    ${11}    ${11}    kbps    10    id=2    trf_id=1

     Start Log         ttitrace
     sleep    3s
     ${scen5}     Stop Log     ttitrace         test_scenario=mix3

    Verify NSA Scell Addition On High Data Traffic      ${11}   ${11}   1    1099
     Start Log         ttitrace
     sleep    3s
     ${scen6}     Stop Log     ttitrace         test_scenario=mix4

     Decode TTI Trace   mix1
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${2}
     ${large_bwp_id}   Set Variable    ${3}
     ${small_bwp_size}    Set Variable    ${217}
     ${second_bwp_size}    Set Variable    ${245}
     ${large_bwp_num_prb}    Set Variable    ${273}
     ${Mix1}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    large_bwp_ues=${large_bwp_rnti}

     Decode TTI Trace   mix2
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${2}
     ${large_bwp_id}   Set Variable    ${3}
    ${small_bwp_size}    Set Variable    ${106}
     ${second_bwp_size}    Set Variable    ${160}
     ${large_bwp_num_prb}    Set Variable    ${216}
     ${Mix2}     validate_bwps    ${scen4}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}   ${large_bwp_id}
     ...     ${small_bwp_size}   ${second_bwp_size}    ${large_bwp_num_prb}    second_bwp_ues=${large_bwp_rnti}
     Decode TTI Trace   mix3
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${2}
     ${large_bwp_id}   Set Variable    ${3}
     ${small_bwp_size}    Set Variable    ${217}
     ${second_bwp_size}    Set Variable    ${245}
     ${large_bwp_num_prb}    Set Variable    ${273}
     ${Mix3}    validate_bwps    ${scen5}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
     ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    large_bwp_ues=${nsa_large_bwp_rnti}

     Decode TTI Trace   mix4
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${2}
     ${large_bwp_id}   Set Variable    ${3}
    ${small_bwp_size}    Set Variable    ${106}
     ${second_bwp_size}    Set Variable    ${160}
     ${large_bwp_num_prb}    Set Variable    ${216}
     ${Mix4}     validate_bwps    ${scen6}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}   ${large_bwp_id}
     ...     ${small_bwp_size}   ${second_bwp_size}    ${large_bwp_num_prb}    second_bwp_ues=${nsa_large_bwp_rnti}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   common_deal_config_file.Get GNB Swconfig File     ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   common_deal_config_file.Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
