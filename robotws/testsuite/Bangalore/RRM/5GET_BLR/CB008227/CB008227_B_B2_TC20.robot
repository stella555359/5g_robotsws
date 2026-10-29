*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes NBR allocations exceed UE's NBR Resource limit.
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20679



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB008227_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_FR1_TDD_60mhz_scf_off.xml
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
${sa_ue_id4}      4
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID2}    2
${QFI_ID3}    3
${QFI_ID4}    4
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${epc_log_path}    /tmp/
${TEST_NAME}        B_B2_TC20
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${no_of_cells}    2
*** Test Cases ***

CB008227-B#B2_TC20_NBR_Allocation_Exceed_UEs_NBR_Resource_limit
    [Documentation]   This user scenario describes NBR allocations exceed UE's NBR Resource limit.
    Start Log    btslog   cprt
    Attach UE with GBR/NBR/non-NBR
    Sleep    10s    reason=wait to trigger DL and UL data succesfully all UEs
    Validate DL UL Traffic For all UEs with NBRPRB 90%
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1       update      maxPrbsPerNbrUe      10
    Sleep    10s
    Validate DL UL Traffic For all UEs with NBRPRB 10%
    ${path1}    Stop Log    cprt   test_scenario=UE_NBR
    Deregister UEs
    Stop Log   btslog
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

***keywords****
Attach UE with GBR/NBR/non-NBR
    Register UE${sa_ue_id1} and establish VoNR Call
    sleep     1s
    Register UE${sa_ue_id2} and establish NBR Call
    sleep     1s
    Register UE${sa_ue_id3} and establish nGBR without NBR Call
    sleep     1s
    Register UE${sa_ue_id4} and establish nGBR without NBR Call
    sleep     1s

Validate DL UL Traffic For all UEs with NBRPRB 90%
    Validate DL UL Throughput For UE     ${sa_ue_id1}   ${Pdu_session_ID}   ${QFI_ID4}  0.022   0.022
    Validate DL UL Throughput For UE     ${sa_ue_id2}   ${Pdu_session_ID}   ${QFI_ID}   300    55
    Validate DL UL Throughput For UE     ${sa_ue_id3}   ${Pdu_session_ID}   ${QFI_ID2}   210   25
    Validate DL UL Throughput For UE     ${sa_ue_id4}   ${Pdu_session_ID}   ${QFI_ID2}   210   20

Validate DL UL Traffic For all UEs with NBRPRB 10%
    Validate DL UL Throughput For UE     ${sa_ue_id1}   ${Pdu_session_ID}   ${QFI_ID4}  0.021   0.021
    Validate DL UL Throughput For UE     ${sa_ue_id2}   ${Pdu_session_ID}   ${QFI_ID}   300    35
    Validate DL UL Throughput For UE     ${sa_ue_id3}   ${Pdu_session_ID}   ${QFI_ID2}   210   25
    Validate DL UL Throughput For UE     ${sa_ue_id4}   ${Pdu_session_ID}   ${QFI_ID2}   210   11

Register UE${sa_ue_id} and establish VoNR Call
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Success   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    1s    reason=wait command finish
    FOR    ${Q_O_ADD}    IN RANGE    ${Q_O_ADD2}     ${Q_O_ADD4}+${1}
         UE PDU Modfication should be Successful     ${sa_ue_id}    ${Pdu_session_ID}    ${Q_O_ADD}
         sleep  1s
    END
    FOR    ${QFIID}    IN RANGE    ${QFI_ID3}     ${QFI_ID4}+${1}
         Trigger VoNR DL Traffic for SA     ${sa_ue_id}    ${Pdu_session_ID}   ${TRF_ID}   ${QFIID}   rtp_codec=custom
         Trigger VoNR UL Traffic for SA     ${sa_ue_id}    ${Pdu_session_ID}   ${TRF_ID}   ${QFIID}   rtp_codec=custom
         sleep  1s
    END

Register UE${sa_ue_id} and establish NBR Call
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Successful   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA    ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        Trigger UL Traffic SA    ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        sleep  1s
    END

Register UE${sa_ue_id} and establish nGBR without NBR Call
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Successful    ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    UE PDU Modfication should be Successful     ${sa_ue_id}    ${Pdu_session_ID}    ${Q_O_ADD2}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA     ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRFID}    ${QFI_ID2}
        Trigger UL Traffic SA     ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRFID}    ${QFI_ID2}
        sleep  1s
    END

Deregister UEs
    FOR    ${ueid}    IN RANGE    ${sa_ue_id1}    ${sa_ue_id4}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
    END

