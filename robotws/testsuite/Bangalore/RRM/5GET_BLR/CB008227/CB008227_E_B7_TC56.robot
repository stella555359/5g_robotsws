*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behavior that NBR service
...                                works fine with enhanced DL MU-MIMO.
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_21178



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB008227_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_FR1_TDD_DL_MUMIMO_ENC_scf.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces    ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_DL_MUMIMO_Enc.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${ue_id1}      1
${ue_id2}      2
${ue_id3}      3
${ue_id4}      4
${nwslice_ID}   1
${gw_ID}     1
${Pdu_ID}       1
${Pdu_ID2}       2
${TRF_ID}     1
${TRF_ID2}     2
${QFI_ID}     1
${QFI_ID2}    2
${Q_O_ADD2}    2
${cell_id}   50
${pm_cellID}    1
${epc_log_path}    /tmp/
${TEST_NAME}        E_B7_TC56
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEQE_DL_MUMIMO_Enc.xml
${no_of_cells}   1
${FIELDS}    (itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.muStatus == 0x15)

*** Test Cases ***

CB008227-E_B7_TC56_NBR_IWK_DL_MUMIMO_Enhanced
    [Documentation]   This user scenario describes the gNB behavior that NBR service
    ...               works fine with enhanced DL MU-MIMO.
    Wait until the next Measurement Period starts
    Start Log    btslog   cprt
    Set UE1 and UE2 Pos
    #UE-1 with non-NBR bearer
    UE Register should be Success   ${ue_id1}   ${Pdu_ID}   ${nwslice_ID}   ${gw_ID}
    #UE-2 with NBR bearer
    UE Register should be Success   ${ue_id2}   ${Pdu_ID2}   ${nwslice_ID}   ${gw_ID}
    Modify PDU session for UE   ${ue_id2}   ${Pdu_ID2}
    Activate CSI Override command
    ${path1}    Stop Log    cprt   test_scenario=UE_NBR
    Send DL data to UEs and check throughput   ${ue_id1}   ${ue_id2}
    Start Log   ttitrace   ${cell_id}
    sleep   5s
    ${path2}   Stop Log   ttitrace   test_scenario=tti1
    Stop Log   btslog
    Verify DL_MUMIO Pairing     ${path2}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pm_cellID}
    ...  file_path=${pm_counter_file}
    Deregister UEs
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

***keywords****
Send DL data to UEs and check throughput
   [Arguments]    ${ue_id1}   ${ue_id2}
   FOR    ${ue_id}    IN RANGE    ${ue_id1}    ${ue_id2}+${1}
      ${Pdu_session_ID}=    Set Variable If    ${ue_id}==2    2   1
      ${QFI_ID}=    Set Variable If    ${ue_id}==2    2   1
      Trigger DL Traffic SA    ${ue_id}   175    ${Pdu_session_ID}   1    ${QFI_ID}
       sleep  1s
   END
   Wait '20s ' to stable
   Validate Throughput   ${ue_id1}   ${ue_id2}

Activate CSI Override command
    wtsrunner.csi_override_testmode_nr    profile_id=1    cqi=15   ri=0
    wtsrunner.ue_testmode_set_nr    id=1-2    testmode=csi_override    action=activate    profile_id=1

Set UE1 and UE2 Pos
    wtsrunner.ue_srs_beam_pos_nr    profile_id=1    srsMode=fixed    init_pos=1
    wtsrunner.ue_testmode_set_nr    id=1    testmode=ue_srs_beam_pos    action=activate    profile_id=1
    wtsrunner.ue_srs_beam_pos_nr    profile_id=2    srsMode=fixed    init_pos=3
    wtsrunner.ue_testmode_set_nr    id=2    testmode=ue_srs_beam_pos    action=activate    profile_id=2

Modify PDU session for UE
    [Arguments]    ${ue_id}   ${Pdu_ID2}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID2}  qosflows_to_add=${Q_O_ADD2}   by=amf
    Sleep    1s

Validate Throughput
    [Arguments]    ${ue_id1}   ${ue_id2}
    FOR    ${ue_id}    IN RANGE    ${ue_id1}    ${ue_id2}+${1}
        ${Pdu_session_ID}=    Set Variable If    ${ue_id}==2    2   1
        ${QFI_ID}=    Set Variable If    ${ue_id}==2    2   1
        ${dlrate}=    Set Variable If    ${ue_id}==2    175   175
        Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${dlrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    END

Decode TTITrace
   [Arguments]    ${ttitrace_path}=${tti}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    #Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv

Wait '${time} ' to stable
    sleep    ${time}

Deregister UEs
    FOR    ${ueid}    IN RANGE    ${ue_id1}    ${ue_id2}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
    END

