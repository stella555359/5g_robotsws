*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...
...  AUTHOR          :   Ganesha.U  ganesha.u@nokia.com
...  MAINTAINER      :   Ganesha.U  ganesha.u@nokia.com
...  INTRODUCTION    :   CB008927 DL resource allocation type 1
...  TEST SET NAME   :   CB008927_B_B4_1_SA_Verify_RAT1_Allocation_Single_Multiple_UEs_scheduling_with_specific_BW_N28FDD_Cells_cRbSize_n50_cRbStart
...  TESTING SPLIT   :   bunde1-A
...  CONTACTS        :   I_MN_RAN_L2_5G_BLR_ET_CB008927@internal.nsn.com
...  REFERENCES      :   CB008927-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_22997

Resource         ./CB008927_resource.robot
Resource         ../CB007112/resources/CB007112_keywords.robot
Resource         ../resources/robot/wts_sim_keywords.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Suite setup from scratch
...                 AND    Add routes
...                 AND    Load wts CFG Config And Capture CPRT Traces   ${wts_cfg_file}    1    4

Test Teardown    Run Keywords    Get Sos Report
...   AND    wts_sim_keywords.Clean edaemon and egate

*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_B4_1_2AMF.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TEST_NAME}        test_case
@{PhysCellID}      50    51
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_ON.csv
${FILTER_B003}    (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus      uci.an
${SCFC}=        Bangalore/RRM/ET/CB008927/SCF_CB008927_B_B4_1.xml
${AP_XML}=      Bangalore/RRM/ET/CB008927/iphy_CB008927_B_B4_1.xml
@{startPRB}     ${0}     ${0}
@{endPRB}     ${51}   ${51}

*** Test Cases ***
[1]CB008927_B_B4_1_SA_Verify_RAT1_Allocation_Single_Multiple_UEs_scheduling_with_specific_BW_and_PRB_pooling_N28FDD_Cells_cRbSize_n50_cRbStart_crb1
    set test variable      ${LOG_PATH}
    Start log   btslog   cprt
    log to console   Suite setup successful ...
    Register and Send less data     start_ue=1   end_ue=40
    Stop log   btslog   cprt    test_scenario=attach_log
    Trigger data traffic for Ues    start_ue=1   end_ue=40    dl_rate=35    ul_rate=25    step=${10}
    Start log   ttitrace
    sleep    0.5s
    ${ttidir1}   Stop log    ttitrace  test_scenario=equalload
    Common TTI PCAP to CSV Converter     equalload
    Validate RAT ALlocation    ${PhysCellID}    ${ttidir1}
    Stop Log     snapshot
    Deregister ALl Ues   1   40

*** Keywords ***
Change GSCN Value
    [Arguments]     ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c2}    Set Variable    sed -i 's/1582/${GSCN}/g' ${file_path}
    Run    ${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s

Register and Send less data
    [Arguments]   ${start_ue}   ${end_ue}
    FOR   ${ues}  IN RANGE   ${start_ue}    ${end_ue}    ${10}
       Register and send data     ${ues}
    END

Register and send data
     [Arguments]    ${ues}
     ${crnti_list}   create list
     FOR  ${UE}  IN RANGE   ${ues}   ${ues}+${5}
            ${rnti}   UE Register should be Successful And Fetch RNTI with RAT1    ${UE}
            Append To List   ${crnti_list}   ${rnti}
            wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=kbps     dl_rate=100     pdu_id=1   trf_id=1
     END
     Set Suite Variable   ${crnti_list}

Trigger data traffic for Ues
    [Arguments]   ${start_ue}   ${end_ue}    ${dl_rate}    ${ul_rate}    ${step}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}    ${step}
        wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${Ues}   ${Ues}+${4}  Traffic_rate=mbps     dl_rate=${dl_rate}    pdu_id=1   trf_id=1
        wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${Ues}   ${Ues}+${4}  Traffic_rate=mbps     ul_rate=${ul_rate}    pdu_id=1   trf_id=1
    END

Deregister ALl Ues
    [Arguments]   ${start_ue}   ${end_ue}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}    ${10}
        wts_sim_keywords.MultiUE Deregister should be Successful     ${Ues}   ${Ues}+${4}
    END

Validate RAT ALlocation
    [Arguments]    ${cellid}    ${ttidir}
    FOR     ${cellid}    IN    @{cellid}
        ${status}    Check Blankedprb   ${ttidir}[ttitrace]/output_dl_formated.csv   start_prb=${startPRB}
        ...     end_prb=${endPRB}   CellId=${cellid}
        Run Keyword and ignore error    Should Be True   ${status} == ${True}
        ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg    ${LOG_PATH}    ${cellid}    sp_10mhz_config=True
        ${cell}   Convert To Integer   ${cellid}
        Rat1 Allocation Verification    ${ttidir}[ttitrace]/output_dl_formated.csv    ${cell}
        Verify RAT1 Allocation and PSA Region    ${ttidir}[ttitrace]/output_dl_formated.csv    ${cell}    FDD
        ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}    prbblank=True    blankprblowedgedl=1     blankprbhighedgedl=1
    END
