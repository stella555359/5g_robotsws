*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./CB009531_resource.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_TDD
#*** Variables ***
#${SCF_PATH}                    ${CURDIR}/config/SCF
#${LOG_PATH}                    ${OUTPUT DIR}
#${LOCAL_WTS_DIR}               ${CURDIR}/config/WTS
#${WTS_DIR}                     /opt/iphy/latest
#${scf_B06}                     ${SCF_PATH}/scf_CB009531_3F4T_B6.xml
#${iphy_CB009531_3F4T}          ${CURDIR}/config/IPHY/iphy_CB009531_3F4T.xml
#${WTS_CFG_B06}                 wts_CB009531_B06.cfg
#${SWCONFIG_B06}                0x4B000F=1;0x3F007C=1024;0x58057f=0x8000000;
#${UE3_ID}                      3
#@{5CC_scell_index}             1    2    3    4
#${egate_console_log}           /opt/wts/latest/egate_console.log
#${Egatelog_path}               ${CURDIR}
#@{dlonly_scell_index}          1    3    4
#@{no_scell_index}              2
#${BIP_CSV_NAME}                5GBipL2L1_filtering_off.csv
#${FILTER_A002}                 dldata_pdcchsendreq ||uldata_pucchreceiverespharqd
#@{COLUMN_NAME}                 frame.time    3gpp.sfn    3gpp.slot    DlData_DciInfo.dciSize    dci.dci11.HARQ_ProcessNumber
#...                            dci.dci11.FrequencyDomainResourceAssignment    dci.dci11.TimeDomainResourceAssignment
#...                            dci.dci11.MCS_TB1    data.data
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#
#
#*** Test Cases ***
#CB009531-ET-B006_Verify_DL_new_transmission_or_retransmission_cound_not_on_the_pusch_slot_which_is_send_csi_report
#    [Documentation]
#    ...    Precondition:
#    ...    1.2FDD+3TDD configuration
#    ...    CA_n41A-n66(2A)-n77(2A) or CA_n66(2A)-n71A-n77(2A)
#    ...    TDD cell. FDD 20M as pcell  TDD with  1208  frame structure,beam=6   and refine beam is enable with 8*4 mimo
#    ...    2..NRBTS.sCellActivationMethod=blind
#    ...    3.sCellAdditionMethod = blind
#    ...    4. RREL sCellOperationalMode =1(dlAndUl)
#    ...    NRDU.carrierAggregationSupportList=210
#    ...    5.sCellDeactivationTimerGNB=infinity
#    ...    6. actConnectedModeMobilityCA = true
#    ...    7.actInterNumerologyCa=true
#    ...    8.NRBTS/NRDU.flexibleCAMode is set to “2:ConfigurationIndependent”​
#    ...    9.NRBTS/actFdmScheduling = TRUE      NBTS/NRCELL.actIncreasedFdmUsersPerSlot = TRUE
#    ...    10.NRBTS/NRDRB_RLC_AM/ulTReassemblyIBCA=40ms
#    ...    11.NRBTS/NRCELL.timingAdvanceOffset = n25600
#    ...    12.NRBTS/NRCELL.maxNumSCellsDlFr1 = 4
#    ...    13.  NRCELL.actDrxRetransTimerSupport=ture
#    ...    14. NRCELL.drxProfile1/drxHarqRttTimerDl=28
#    ...    15.  NRCELL.drxProfile1/drxHarqRttTimerUl=0
#    ...    16. NRCELL.drxProfile1/drxInactivityTimer=1ms
#    ...    17. NRCELL.drxProfile1/drxLongCycle=40ms
#    ...    18. NRCELL.drxProfile1/drxOnDurationTimer=2ms
#    ...    19.NRCELL.drxProfile1/drxRetransTimerDl=4slot
#    ...    20.NRCELL.drxProfile1/drxRetransTimerUl=6slot
#    ...    21.NRBTS.NRCELLGRP.maxDlHarqTx=4
#    ...    22.NRBTS.NRCELLGRP.maxUlHarqTx=4
#    ...    23.maxCsirsNumber=4
#    ...    24.csiReportPeriodicity=slot20
#    [Tags]     case_B06    Mannual_yalsun    TA_yalsun   CLOUD_5G_I_BOO_AP_LOO
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_B06}
#    ...        AND    Suite Setup Update GNB   scf_file=${scf_B06}    iphy_file=${iphy_CB009531_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Start WTS And Check OnAir
#    Sleep    3s
#    SA Single UE Attach    ${UE3_ID}
#    Sleep    3s
#    Run Keyword And Continue On Failure    Check Egate Log For DRX Configuration    ms2    ms6    28    0    sl4    sl6    ms80
#    #Step2,3
#    Set AP L2rt Debug Level
#    ${CMD_TRAFFIC_UL}    Set Variable    trf_data_start ue=3 pdu=1 dir=ul burst=1 trf_id=1 period_ms=160 size=42
#    ${CMD_TRAFFIC_DL}    Set Variable    trf_data_start ue=3 pdu=1 dir=dl burst=1 trf_id=1 period_ms=160 size=42
#    ute_wtssim.Execute Egate Command    cmd=${CMD_TRAFFIC_UL}
#    ute_wtssim.Execute Egate Command    cmd=${CMD_TRAFFIC_DL}
#	Set Value For BLER Testmode    profile_id=31    dl_bler=1000,1000,1000,0
#    CUDU L2 Send Action To GNB    ue_id=${UE3_ID}    testmode=bler    action=activate    profile_id=31
#    CUDU_L2 Capture And Decode TTitrace    log_id=1    duration=3
#    Run Keyword And Continue On Failure    Check RetxTimerStatus In TTitrace
#    Run Keyword And Continue On Failure    Check ULchannel On Specific Scell    1    54    PUSCH
#
#*** Keywords ***
#
#Start WTS And Check OnAir
#    [Documentation]    This keyword is to start WTS, wait for onAir
#    Start UTE WTS
#    UE SIB Decoding
#    Check All Cells Received SIB2
#
#Check ULchannel On Specific Scell
#    [Arguments]    ${log_id}    ${physcellid}    ${expectulchannel}
#    Log To Console    Check ulchannel
#    @{ulchannel}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_dl.csv
#    ...    csiSrReportData.ulChannel    physCellId    ["0", "", "PUCCH"]
#    ...    except    ${physcellid}    include    csiSrReportData.ulChannel    no
#    Should Be True    "@{ulchannel}[0]"=="${expectulchannel}"
#
#Check RetxTimerStatus In TTitrace
#    Log To Console    drxRetransmissionTimer.retxTimerStatus
#   @{retxTimerStatus}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
#    ...    drxRetransmissionTimer.retxTimerStatus    physCellId    ["0", "", "0.0"]
#    ...    except    53    include    drxRetransmissionTimer.retxTimerStatus    no
#    Should Be True    @{retxTimerStatus}[0]==1
