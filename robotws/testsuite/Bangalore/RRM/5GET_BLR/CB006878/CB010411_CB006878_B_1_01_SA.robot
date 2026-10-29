*** Settings ***
Force Tags      CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00

Documentation
...
...             author:            Mohan
...             maintainer:        mohanavel.p@nokia.com
...
...             INTRODUCTION:     CB010411-CB006878_B#1_01_LongPucch_SA_multiBWP_100MHz_slotRatio3_7_csiReportPeriodicity_slots320_1UE_ecpri
...             TESTING SPLIT:    Refer CB006878 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB010411 - CB006878 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_16315

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/common_log_collection.robot
Resource            ../resources/robot/Airphone.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Library             ../resources/python/IphyUpdate.py
Library             ./resources/verify_rnti_bwpid.py


Suite Setup     Run keywords    Test Suite Setup
...             AND             AIC Software Build Info
...             AND             Fetch Taf Library used in TL
...             AND             Suite bringup
...             AND             Log To Console   loading cfg file...
...             AND             Start WTS Using WTS_Runner    ${wts_cfg_file}

suite teardown          Run keywords        Kill WTS processes Using WTS_Runner


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/AiC_MultiUe_VONR_tdd.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${RMOD_name}   AZQJ
${nwslice_ID}    1
${gw_ID}     1
${gw_ID2}     2
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${Pdu_session_ID}    1
${Pdu_session_ID2}    2
${epc_log_path}     /tmp/
${UE_ID}     1
${NSA_UE_ID}     11
${UE_ID2}     2
${NSA_UE_ID2}     12
${BEARER_ID}     2
${vdu_file_path}     ${CURDIR}/config/SBTS/CB006878_vDU_scf.xml
${vcu_file_path}     ${CURDIR}/config/SBTS/CB006878_vCU_scf.xml
${iphy_file_path}         ${CURDIR}/config/CB006878_AiC_iphy.xml
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${gscn_value}   7828

*** Test Cases ***
[1]CB006878_B#1_01_LongPucch_SA_multiBWP_100MHz_1UE_ecpri
    [Setup]         Run keywords    Log to console     \n-----> Test Setup <-----
    ...             AND             Testcase Setup
    ${LOG_PATH}  Set Variable     ${LOG_PATH}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Start Syslog Monitoring
    Start CPIF_CPRT Monitoring
    UE Register should be Successful     ue_id=${UE_ID}
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=15       pdu_id=1      trf_id=1      qfi_id=${QFI_ID}
    sleep   2s
    UE PDU Addition should be Successful      ue_id=1    nw_id=1    pdu_id=2    gw_id=2

    #UE MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=15       pdu_id=1      trf_id=1      qfi_id=${QFI_ID}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=15       pdu_id=2      trf_id=1      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=15       pdu_id=2      trf_id=1      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Stop and Collect CPIF_CPRT Monitoring
    ${bwpid}    Create List     2
    ${crnti_list}     Create List
    Collect and Decode TTitrace   Scenario1
    Validate UE bwpid from TTI traces    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/Scenario1    ${crnti_list}     ${bwpid}
    #Run Keyword And Continue on Failure    Syslog should contain CSI Reports in syslogs    NAME=ue_attach_TC13      csi_regex=${syslog_regex_csi}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.015     pdu_id=1    qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.015     pdu_id=1    qfi_id=${QFI_ID}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.015     pdu_id=2    qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.015     pdu_id=2    qfi_id=${QFI_ID}

    #UE MOVING FROM POWER SAVING BWP PROFILE TO LARGE  BWP PROFILE
    #Start L2 BIP Trace Capturing
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=2      pdu_id=1     trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${Pdu_session_ID}
    sleep   3s      reason=Wait for successful BWP switch
    Sleep  20s
    Stop and Collect Syslog Monitoring
    ${bwpid}    Create List     1
    Collect and Decode TTitrace   Scenario2
    Validate UE bwpid from TTI traces    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/Scenario2    ${crnti_list}     ${bwpid}
    #Run Keyword And Continue on Failure    Syslog should contain CSI Reports in syslogs    NAME=ue_dci_switch2LGBWP_TC13
    #...     csi_regex=${syslog_regex_csi}
    Validate UL Traffic For SA   ue_id=${UE_ID}     pdu_id=1    ul_rate=0.015        qfi_id=${QFI_ID}
    Validate DL Traffic For SA   ue_id=${UE_ID}     pdu_id=1    dl_rate=2           qfi_id=${QFI_ID}
    Validate DL Traffic For SA   ue_id=${UE_ID}     pdu_id=2    dl_rate=0.015       qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     pdu_id=2    ul_rate=0.015       qfi_id=${QFI_ID}
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

*** Keywords ***
Suite bringup
    Prepare AIC TL with all config files   ${vcu_file_path}   ${vdu_file_path}
    ...   ${RMOD_name}   ${iphy_file_path}

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Collect and Decode TTitrace
    [Arguments]   ${scenario}
    ${cells}  create list   NRCELL-1
    Start L2Ps TTI logs from vDU    ${cells}
    sleep  5s
    ${tti}    Stop L2Ps TTI logs from vDU    test_scenario=${scenario}
    Decode TTI Trace    ${scenario}

Create Rntibwp Dictionary
    [Arguments]   ${rnti}   ${bwpid}
    ${Dict1}   Create Dictionary
    ${len}   Get Length    ${rnti}
    FOR    ${i}    IN RANGE   ${len}
         Set To Dictionary   ${Dict1}    ${rnti}[${i}]   ${bwpid}[${i}]
    END
    Run Keyword if   ${len}==0    Set To Dictionary   ${Dict1}    ${EMPTY}   ${bwpid}[0]
    [Return]   &{Dict1}

Verify Rnti ueBWPid
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}
    ${rntibwp}   Create Rntibwp Dictionary   ${rnti}   ${bwp}
    ${Result}  verify_rnti_bwpid.check_rnti_bwpid    ${csv_file_path}   ${rntibwp}   False
    [Return]   ${Result}

Validate UE bwpid from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}
    ${Check}  Verify Rnti ueBWPid    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${bwp}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Bwpid is not matching
    ${Check1}  Verify Rnti ueBWPid    ${csv_file_path}/output_ul_formated.csv     ${rnti}   ${bwp}
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail   Bwpid is not matching
