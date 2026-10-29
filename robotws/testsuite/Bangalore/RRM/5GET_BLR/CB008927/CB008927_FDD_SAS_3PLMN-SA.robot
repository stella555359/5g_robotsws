*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS24R2    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB008927_FDD_SAS_3PLMN-SA
...             TEST SET NAME:     CB008927_FDD_SAS_3PLMN-SA.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM
...             REQUIREMENT ID:        5G_RAN_USR_RRM_22970, 5G_RAN_USR_RRM_22760

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008927_resource.robot
Library          ../resources/python/ssh_command.py
Resource         ../resources/robot/Iperf_Traffic.robot

Suite Setup         Run keywords
...                 Log To console  SuiteSetup
...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with delta.json
...                 AND     sleep    200s
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log      btslog       snapshot       # sosreport
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/SCF_AB4-40MHZ-FDD.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_40MHZ-FDD-2Cell.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_FDD_SAS_3PLMN_SA.cfg
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
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot    DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus
@{rgs}        RG1     RG2        RG3
@{minq}       ${10}   ${20}     ${40}
@{maxq}       ${100}  ${100}    ${100}

*** Test Cases ***
[1]CB008927_C_IWK1_IWK4_CB008132_IWK_between_DLRAT1_and_DynSAS_in_SA_20MHZ_diff-Max_Min_Quota_per_slice_3PLMN_with_UEs_working_in_PSA
    ${quota_data}   Create Dictionary   RG=@{rgs}   MinQuota=@{minq}    MaxQuota=@{maxq}

    log to console   UE attach trigerring now...
    start log    cprt
    ${crnti_list1}=      MultiUE Register should be Successful    1      1      nw_id=1
    Start traffic for UE    1      1    qfi_id=1
    ${crnti_list1}=      MultiUE Register should be Successful    2      2      nw_id=2
    PDU Modfication and Deletion of other PDU    2    2    pdu_id=1    qosflows_to_add=2    qosflows_to_del=1
    Start traffic for UE    2      2    qfi_id=2
    ${crnti_list1}=      MultiUE Register should be Successful    3      3      nw_id=3
    PDU Modfication and Deletion of other PDU    3    3    pdu_id=1    qosflows_to_add=3    qosflows_to_del=1
    Start traffic for UE    3      3    qfi_id=2
    start log       ttitrace

    sleep     3s
    ${path_SCN_PA}    Stop Log      ttitrace    #test_scenario=SCN_PA
    ${path_cprt_3Slice}    Stop log     cprt     test_scenario=cprt_3Slice

    log to console      tti_path-${path_SCN_PA}
    OperatingSystem.Run      cp /tmp/iperf_DL_*.txt ${LOG_PATH}

    sleep     5s
    Decode TTI Trace    #SCN_PA
    sleep     15

    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   52
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}
    Rat1 Allocation Verification    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    ${52}
    Verify RAT1 Allocation and PSA Region    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    ${52}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}

    ${ret}      SAS_verification    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv  ${quota_data}    cellbwp=${106}
    Should Contain    ${ret}     Pass


*** Keywords ***
Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}    ${qfi_id}=1
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=175   pdu_id=1      trf_id=1       qfi_id=${qfi_id}
#    MultiUE Trigger UL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   ul_rate=175   pdu_id=1      trf_id=1       qfi_id=${qfi_id}

PDU Modfication and Deletion of other PDU
     [Arguments]          ${start_ue_id}     ${end_ue_id}      ${pdu_id}     ${qosflows_to_add}     ${qosflows_to_del}
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
     wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}
     ...           qosflows_to_del=${qosflows_to_del}       by=amf
     ${output}    Read WTS Output Until Pattern Matches    .*Added QosFlow with QFI:2 fiveQI:*.     ${Timeout_SA}
     Print Matching Lines from Output File    ${output}    .*Deleting QosFlow with QFI:1 5QI:*.
     Print Matching Lines from Output File    ${output}    .*Added QosFlow with QFI:2 fiveQI:*.
     Log to Console  ${Pdu_session_mod_patten}
     END



