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
Library        SSHLibrary
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb
Resource    ../resources/ECEcommon/common_deal_config_file.robot


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Add RadParam to swconfig     "0x890073=0"      IP=192.168.255.129
...                 AND    Add routes

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu
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
${SCFC2}=                   ${CURDIR}/config/SBTS25R2/TC7_T_F_CA_SCF.xml
${AP_XML2}=                 ${CURDIR}/config/wts/TC7_T_F_CA_IPHY.xml
${wts_cfg_file2}      ${CURDIR}/config/wts/trail.cfg
${r&d_parameter}    0x890073=0
${nsa_st_ue_id}    151
${nsa_en_ue_id}     151
${start_ue_id}     51
${end_ue_id}    52

*** Test Cases ***
[1]CB008954_B_B4_2_Intra_freq_intra_DU_handover_UE_supporting_second_BWP
    [Documentation]   This scenario is to verify the cell setup with 2 dedicated BWPS 20,30,MHz in Source gNB and 30,40Mhz in Target gNB

     Prepare TL with all config files
     Start WTS Using WTS_Runner      ${wts_cfg_file}
     sleep  60s   reason=wait for mib sib
#     Start Log      btslog     cprt

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

[1]CB008954_E_B1_B3_5_Carrier_Aggregation_Pcell_configured_with_second_BWP_and_Scell_configured_with_large_dedicated_BWP_FDD-TDD_SA-NSA_mode
    [Documentation]     This scenario is to verify the carrier aggregation & 3 dedicated BWPS 80,90,100MHz in pCell TDD and 10,20,30Mhz in sCell FDD
    Set Global Variable     ${SCFC}         ${CURDIR}/config/SBTS25R2/TC7_T_F_CA_SCF.xml
    Set Global Variable     ${AP_XML}                 ${CURDIR}/config/wts/TC7_T_F_CA_IPHY.xml
    Set Global Variable     ${wts_cfg_file2}      ${CURDIR}/config/wts/ca_t41_f66_new.cfg

     Prepare TL with all config files
     Start WTS Using WTS_Runner      ${wts_cfg_file2}
     sleep  60s   reason=wait for mib sib
     Start Log      btslog     cprt

    Set Test Variable   ${start_ue_id}     1
    Set Test Variable    ${end_ue_id}     2
    Set Test Variable    ${nsa_st_ue_id}    11
    Set Test Variable     ${nsa_en_ue_id}     11

     ${large_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${2}
     ${scen1}     Stop Log      btslog     cprt
     Verify locationAndBandwith for allocated BWP     ${scen1}[cprt]/NODECPRT_GNB.pcap     28875
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

Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}     ${IP}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
        SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
