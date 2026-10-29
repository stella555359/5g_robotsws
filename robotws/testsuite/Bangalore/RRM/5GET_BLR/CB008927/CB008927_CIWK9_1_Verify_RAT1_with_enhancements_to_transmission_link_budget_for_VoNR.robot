*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT     TOOLS_PROFILE_TTI_LEGACY
Documentation
...  AUTHOR          :   Sunil T Kurian    sunil.t_kurian@nokia.com
...  MAINTAINER      :   Sunil T Kurian    sunil.t_kurian@nokia.com
...  INTRODUCTION    :   CB008927 DL resource allocation type 1
...  TEST SET NAME   :  CB008927_CIWK9_1_Verify_RAT1_with_enhancements_to_transmission_link_budget_for_VoNR
...  TESTING SPLIT   :   bunde1-C
...  CONTACTS        :   I_MN_RAN_L2_5G_BLR_ET_CB008927@internal.nsn.com
...  REFERENCES      :   CB008927-CFAM, CB009425 CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_23238

Resource         ./CB008927_resource.robot
Resource         ../CB009425/CB009425_Resource_New.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup           Run keywords    Log To console  Suitesetup
...                 AND     Prepare TL with all config files
...                 AND     Add routes 3AMF
...                 AND    Suite setup from scratch

Test Setup     Load CFG Config And Capture CPRT Traces Cells on-air check OFF    ${wts_cfg_file}


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_CIWK9_4Cell_30Mhz.lua
${WTS_DIR}          /opt/iphy/latest
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${st_ue_id}      ${1}
${en_ue_id}      ${2}
${SCFC}=        ${CURDIR}/config/SCF/SCF_C_IWK9_4Cell_30Mhz.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_C_IWK9_4Cell_30Mhz.xml
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${FILTER_B003}                 (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3

@{QOS_Prof2}               1       2          3                #4
@{QOS_Prof2_speed_ul}      1      32         amr_wb_23_85     #30
@{QOS_Prof2_speed_dl}      1      32         amr_wb_23_85     #30
@{QOS_Prof2_unit}          kbps   kbps       rtp_codec        #kbps

*** Test Cases ***
[1]CB008927_CIWK9_1_Verify_RAT1_with_enhancements_to_transmission_link_budget_for_VoNR
    X2AP Link Should be UP
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof2}       ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof2_speed_ul}    ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof2_speed_dl}    ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof2_unit}    ${2}=${QOS_Prof2_unit}

    Start Log    btslog    cprt
    ${crnti_list}     ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Log to Console             crnti_list with${crnti_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list}
    ${duration}      Set Variable    -1
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    ${crnti_list1}=      MultiUE Register should be Successful    3      7
    Start traffic for UE    3     7
    ${SC1}    Stop log   btslog   cprt   test_scenario=Test1_VoNRandNonGBR_withoutBLER
    start log       biptaf
    start log       ttitrace
    sleep     2s
    ${path_SCN_PA}    Stop Log      ttitrace     test_scenario=Test1_VoNRandNonGBR_withoutBLER
    ${path_SCN_PA_1}    Stop Log      biptaf     test_scenario=Test1_VoNRandNonGBR_withoutBLER
    CB008927_resource.Convert BIP To CSV By MCShark    ${path_SCN_PA_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_PA_1}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${FILTER_B003}    csv_title_list=${COLUMN_NAME}
    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}
    Common TTI PCAP to CSV Converter     Test1_VoNRandNonGBR_withoutBLER
    Rat1 Allocation Verification    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    ${50}
    Verify RAT1 Allocation and PSA Region    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    ${50}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}
    MultiUE Deregister should be Successful     1    2
    CB008927_resource.Perform SCF Delta Commissioning with Delta_CB008927_CIWK_9.json
    sleep    30s
    Set user defined bler for multiple UE    ${st_ue_id}       ${en_ue_id}     dl    60
    Start Log    btslog    cprt
    ${crnti_list}     ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Log to Console             crnti_list with${crnti_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list}
    ${duration}      Set Variable    -1
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Start log    ttitrace
    sleep    2s
    ${SC2}    Stop log    ttitrace      test_scenario=Test2_VoNR_WithBLER
    ${SC3}    Stop log   btslog   cprt     test_scenario=Test2_VoNR_WithBLER

    Common TTI PCAP to CSV Converter    Test2_VoNR_WithBLER
    Run Keyword And Continue On Failure     final verdict for enh retx    ${crnti_list[0]}    ${SC2}[ttitrace]/output_dl_formated.csv
    ...      maxPrbsVoNR=${32}    tc_scen=${4}
    Run Keyword And Continue On Failure     final verdict for mcs drop    ${crnti_list[0]}     ${SC2}[ttitrace]/output_dl_formated.csv
	...    dlMcsDropLimitForVoNR=2      tc_scen=${1}
    Run Keyword And Continue On Failure    final verdict for min tbs prb    ${crnti_list[0]}    ${SC2}[ttitrace]/output_ul_formated.csv
    ...    minPuschPrbForMinTbsVoNR=${3}     ulMinTbsForVoNR=${224}    tc_scen=${1}
    Run Keyword And Continue On Failure     Rat1 Allocation Verification    ${SC2}[ttitrace]/output_dl_formated.csv    ${50}
    Run Keyword And Continue On Failure     Verify RAT1 Allocation and PSA Region    ${SC2}[ttitrace]/output_dl_formated.csv    ${50}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}
    Stop log     snapshot
    MultiUE Deregister should be Successful   1    7

*** Keywords ***
Add routes 3AMF
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.123/24 dev eth3
    Run    sudo ip addr add 10.0.1.124/24 dev eth3
    Run    sudo ip addr add 10.0.1.125/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3


Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=60   pdu_id=1      trf_id=1       qfi_id=1

Load CFG Config And Capture CPRT Traces Cells on-air check OFF
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    CB008927_resource.Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    ${cprt_log_1}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log_1}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}
