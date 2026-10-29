*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Prakhar
...         CB008954 feature testing scenarios

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot
Resource         ./CB007145_Resource.robot


Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${wts_cfg_file1}      ${CURDIR}/config/wts/H_IWK_7.2_GMC.cfg
${wts_cfg_file2}      ${CURDIR}/config/wts/basic_setup_H_5.2.cfg
${wts_cfg_file3}      ${CURDIR}/config/wts/basic_setup_n66_40MHZ_band_2cell.cfg
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
${TEST_NAME}            Cell_setup
${IPHY_FILE}             ${CURDIR}/config/wts/iphy_RJIO.xml
${SCFC}=        ${CURDIR}/config/SCF/FDD_2cell_scf.xml
#${AP_XML}=      ${CURDIR}/config/SCF/CB007145_A_2_3_5_10_iphy.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_RJIO.xml
${AP_XML_8954}      ${CURDIR}/config/SCF/iphy_RJIO_H_7_2.xml
${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${1}

${default_scf}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1/scfc.xml
${default_iphy}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1/iphy.xml

*** Test Cases ***

[1]CB008954_H_IWK_7_2_Three_dedicated_BWPs_with_dynamic_PDCCH_symbol_usage_is_high_on_second_dedicated_BWP
    [Documentation]   Dynamic PDCCH allocation with 3 BWP

    [Setup]             Run keywords     Suite setup from scratch
    ...                 AND     Update bsr package
    ...                 AND     BuiltIn.Set Suite Variable      ${iphy}         ${default_iphy}
    ...                 AND     Modify GSCN By Phy Cell ID In IPHY XML    ${default_iphy}    50     7857
    ...                 AND     Perform SCF Delta Commissioning with H_IWK_7.2_RJIO_nw.json
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Load CFG Config     ${wts_cfg_file1}
    ...                 AND     Check gNB Bulid

    Log To console  H_IWK_Dyn_PDCCH_SYM_mid_BWP
    Increase Buffer Size for VM and IPHY
    Wait until the next Measurement Period starts

    ${small_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${3}
    MultiUE Trigger UL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     dl_rate=80   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    1  3     1
    Validate DL Traffic For MultiUE for SA    1  3     80

    ${second_bwp_rnti}    MultiUE Register should be Successful     ${4}    ${4}
    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    4  4     1
    Validate DL Traffic For MultiUE for SA    4  4     50

    ${Counters}    Create Dictionary     ${PDCCH_SYMB_DIF_BWP1_BWP3}=${0}    ${PDCCH_SYMB_DIF_BWP2_BWP3}=${0}
    ...       ${PDCCH_SYMB_DIF_BWP1_BWP2}=${0}     ${PDCCH_SYMB_DIF_BWP1_PWS_BWP}=${0}   ${PDCCH_SYMB_DIF_BWP2_PWS_BWP}=${0}
    ...       ${PDCCH_SYMB_DIF_BWP3_PWS_BWP}=${0}
    Verify Counters    ${Counters}

    Wait until the next Measurement Period starts
    Modify NIDD parameters   MRBTS-1/NRBTS-1/NRCELL-1   update   actDynPdcchTdMode    perBWP
    sleep     300s

    ${Counters}    Create Dictionary     ${PDCCH_SYMB_DIF_BWP1_BWP3}=${0}    ${PDCCH_SYMB_DIF_BWP2_BWP3}=${0}
    ...       ${PDCCH_SYMB_DIF_BWP1_BWP2}=${0}     ${PDCCH_SYMB_DIF_BWP1_PWS_BWP}=${0}   ${PDCCH_SYMB_DIF_BWP2_PWS_BWP}=${0}
    ...       ${PDCCH_SYMB_DIF_BWP3_PWS_BWP}=${0}
    Verify Counters    ${Counters}

    [Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954H_IWK_5_2_SA_Initial_RRC_Setup_with_dedicated_config_initialDownlinkBWP_CNI78446_CNI81991_TDD
    [Documentation]   This test scenario is to verify gNB behavior when UE setup the RRC connection using dedicated
    ...               config in initialDownlinkBWP with regards to UE context setup when UE supporting small or
    ...               second or large dedicated BWP

    [Setup]             Run keywords    Suite setup from scratch
    ...                 AND     Update bsr package
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     BuiltIn.Set Suite Variable      ${iphy}         ${default_iphy}
    ...                 AND     Prepare TL with all config files
    ...                 AND     Modify GSCN Value In IPHY XML Custom    ${default_iphy}    AQQJ    7871
    ...                 AND     Perform SCF Delta Commissioning with H_IWK_5.2-RJIO.json
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Load CFG Config     ${wts_cfg_file2}
    ...                 AND     Check gNB Bulid

    Log To console  TestCasestartedl
    Increase Buffer Size for VM and IPHY

    ${small_bwp_rnti}    MultiUE Register should be Successful custom     ${1}    ${2}
    MultiUE Trigger UL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    1  2     10
    Validate DL Traffic For MultiUE for SA    1  2     50


    ${second_bwp_rnti}    MultiUE Register should be Successful custom     ${3}    ${4}
    MultiUE Trigger UL Traffic for SA    ${3}  ${4}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${4}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    3  4     10
    Validate DL Traffic For MultiUE for SA    3  4     50

    ${large_bwp_rnti}    MultiUE Register should be Successful custom     ${5}    ${6}
    MultiUE Trigger UL Traffic for SA    ${5}  ${6}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${5}  ${6}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    5  6     10
    Validate DL Traffic For MultiUE for SA    5  6     50

    Start Log         ttitrace
    sleep    1s
    ${scen3}     Stop Log     ttitrace       test_scenario=mix
    sleep    10s

    Common TTI PCAP to CSV Converter   mix      dir=dl
    Common TTI PCAP to CSV Converter   mix      dir=ul
    ${small_bwp_id}    Set variable    ${3}
    ${second_bwp_id}   Set Variable    ${2}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${51}
    ${second_bwp_size}    Set Variable    ${78}
    ${large_bwp_size}    Set Variable    ${133}

    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    validate_bwps    ${scen3}[ttitrace]/output_ul_formated.csv    ulFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    [Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

#[1]CB007145_A#3_SA_UEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_with_n66RU_ShortPUCCH__PRBBlankingActivated
#
#    [Setup]             Run keywords     Prepare TL with all config files
#    ...                 AND     Suite setup from scratch
#    ...                 AND     Change CFG File Value   ${wts_cfg_file3}       349000   431760  ${sa_nr_cap_band66}
#    ...                 ${nsa_nr_cap_band66}     ${nsa_nr_mrdc_band66}
#    ...                 AND     Perform SCF Delta Commissioning with Delta_config_BLANK_PRB_ON_40MHZ_2CC_AHFII.json
#    ...                 AND     sleep    60s
#    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
##    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file3}
#
#    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1
#    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=1    qfi_id=1
#    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_st_ue_id}    mbps  60  pdu_id=1  trf_id=1    qfi_id=1
#    sleep   60s
#
#    Start Log         ttitrace
#    sleep    5s
#    ${scen4}     Stop Log     ttitrace       test_scenario=sa
##    Start and Stop TTI TRACE
##    sleep   120s
#
#    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_st_ue_id}     dl_rate=150   pdu_id=1   qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_st_ue_id}     ul_rate=60   pdu_id=1   qfi_id=1
#    MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}
#
#    Decode TTI Trace    sa
#
#    ${ul_prb}=   utility.get_require_attribut   ${scen4}[ttitrace]/output_ul_formated.csv   ulFdSchedData   numOfPrb
#    ${dl_prb}=   utility.get_require_attribut   ${scen4}[ttitrace]/output_dl_formated.csv   dlFdSchedData   numOfPrb
#    ${res}       utility.get_max        ${ul_prb}   ${198}
#    Should Contain     ${res}    Pass
#    ${res}       utility.get_max        ${dl_prb}   ${208}
#    Should Contain     ${res}    Pass
#
#    [Teardown]      Run Keywords
#    ...             Sleep   1s
#    ...             AND     Kill WTS processes Using WTS_Runner
#    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
    Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}


Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Prepare TL with IPHY file change
     Log To Console    Configure ENV with AP.xml
     add simulator  sim_type=airphone  config=${AP_XML_8954}
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV
#
##based on RMOD
Modify GSCN Value In IPHY XML Custom
    [Arguments]    ${iphy_path}    ${card_name}    ${new_gscn}
    ${content}=    OperatingSystem.Get File    ${iphy_path}
    ${pattern}=    Set Variable    (<RE>[\\s\\S]*?<cardName>${card_name}</cardName>[\\s\\S]*?<GSCN>)(\\d+)(</GSCN>[\\s\\S]*?</RE>)
    ${matches}=    Get Regexp Matches    ${content}    ${pattern}
    Run Keyword If    ${matches} == []    Fail    Could not find GSCN for card ${card_name}
    ${old_gscn}=    Set Variable    ${matches}[0][1]
    Log To Console    Updating GSCN for card ${card_name}: ${old_gscn} -> ${new_gscn}
    ${replacement}=    Set Variable    \\g<1>${new_gscn}\\g<3>
    ${new_content}=    Replace String Using Regexp    ${content}    ${pattern}    ${replacement}
    Create File    ${iphy_path}    ${new_content}    encoding=UTF-8
    Send IPHY XML To Airphone custom    ${iphy_path}

Modify GSCN By Phy Cell ID In IPHY XML
    [Arguments]    ${iphy_path}    ${phy_cell_id}    ${new_gscn}
    ${content}=    OperatingSystem.Get File    ${iphy_path}
    ${pattern}=    Set Variable    (<vcell>[\\s\\S]*?<phy_cell_id>${phy_cell_id}</phy_cell_id>[\\s\\S]*?<GSCN>)(\\d+)(</GSCN>)
    ${matches}=    Get Regexp Matches    ${content}    ${pattern}
    Run Keyword If    ${matches} == []    Fail    Could not find GSCN for phy_cell_id ${phy_cell_id}
    ${old_gscn}=    Set Variable    ${matches}[0][1]
    Log To Console    Updating GSCN for phy_cell_id ${phy_cell_id}: ${old_gscn} -> ${new_gscn}
    ${replacement}=    Set Variable    \\g<1>${new_gscn}\\g<3>
    ${new_content}=    Replace String Using Regexp    ${content}    ${pattern}    ${replacement}
    Create File    ${iphy_path}    ${new_content}    encoding=UTF-8
    Send IPHY XML To Airphone custom    ${iphy_path}
