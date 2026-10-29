*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mundanad Vishnu
...              :contact: mundanad.vishnu@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for Admission control of NBR Non GBR DRB
...                               when NBR bearers Exceed Cells NBR max amount Limitation (SA) which is triggered by
...                               Initial Context Setup Request procedure with HPA
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20699



Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         CB008227_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_FR1_TDD_HPA.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_AEHC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${sa_ue_id1}      1
${sa_ue_id2}      2
${sa_ue_id3}      3
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC23
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${no_of_cells}   2

*** Test Cases ***

CB008227-C#B1_TC23_NBR bearers Exceed _Cells_NBR_max_amount_Limitation_with HPA_Initial Context Setup with PDU session
    [Documentation]   This user scenario describes the gNB behaviour for Admission control of NBR Non GBR DRB
    ...               when NBR bearers Exceed Cells NBR max amount Limitation (SA) which is triggered by
    ...               Initial Context Setup Request procedure with HPA
    Verify actNbrForNonGbrBearers In CellSetupReq
    Start Log    btslog   cprt
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    Register NBR UE and establish NBR Call      ${sa_ue_id1}
    sleep  5s
    ${path1}    Stop Log    cprt   test_scenario=bearersetupue1
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    300000   60000
    Start Log    cprt
    Register NBR UE and establish NBR Call      ${sa_ue_id2}
    sleep  5s
    ${path2}    Stop Log    cprt   test_scenario=bearersetupue2
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    300000   60000
    Start Log    cprt
    Attach NBR UE with HPA     ${sa_ue_id3}
    Sleep    5s    reason=wait to trigger DL and UL data succesfully
    ${path3}    Stop Log    cprt   test_scenario=bearersetuphpaue
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    300000   60000
    Validate DL UL Traffic For NBR UE
    Deregister UEs
    Stop Log   btslog

*** Keywords ***

Validate DL UL Traffic For NBR UE
    Validate DL UL Throughput For UE     ${sa_ue_id2}   ${Pdu_session_ID}   ${QFI_ID}   50   20

Attach NBR UE with HPA
    [Arguments]    ${sa_ue_id}
    log to console   UE${sa_ue_id} attach trigerring now...
    wtsrunner.ue_nr_rrc_setup_param    id=${sa_ue_id}    establishment_cause=highPriorityAccess
    UE Register should be Successful   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA    ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        Trigger UL Traffic SA    ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        sleep  1s
    END

Deregister UEs
    FOR    ${ueid}    IN RANGE    ${sa_ue_id1}    ${sa_ue_id3}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
    END

Register NBR UE and establish NBR Call
    [Arguments]    ${sa_ue_id}
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Successful   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA    ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        Trigger UL Traffic SA    ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        sleep  1s
    END

