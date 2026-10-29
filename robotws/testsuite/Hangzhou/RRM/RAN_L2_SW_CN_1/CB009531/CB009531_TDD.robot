*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Common Suite Setup 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_TDD    SBTS00
#...                RAN_5G    RAN_5G_FDD
#Library           Resources/A002_check_drx.py
#Library           Resources/check_ap_syslog.py
#Library           Resources/check_tti.py
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./CB009531_resource.robot
#
#*** Variables ***
#${SCF_PATH}                    ${CURDIR}/config/SCF
#${WTS_DIR}                     /opt/iphy/latest
#
#${IPHY_FILE_A18}               ${CURDIR}/config/IPHY/AEQE_2S_1CC_iphy.xml
#${IPHY_FILE_A12}               ${CURDIR}/config/IPHY/TDD_iphy.xml
#${LOG_PATH}                    ${OUTPUT DIR}
#${LOCAL_WTS_DIR}               ${CURDIR}/config/WTS
#${WTS_DIR}                     /opt/iphy/latest
#${scf_vonr}                    ${SCF_PATH}/SCF_CB009531_TDD_VONR.xml
#${SCF_A18}                    ${SCF_PATH}/CB009531_SCF_A18.xml
#
#${WTS_CFG_vonr}                wts_cfg_ASIL_ABIO_TDD_DRX.cfg
#${WTS_CFG_A18}                 CB009531_basic_setup_A18.cfg
#
#${SWCONFIG_A_002}              0x4B000F=1;0x58057f=0x8000000;0x58057a=3;0x58075A=1;
#${UE1_ID}                      1
#${BIP_CSV_NAME}                5GBipL2L1_filtering_off.csv
#${FILTER_A002}                 dldata_pdcchsendreq ||uldata_pucchreceiverespharqd
#@{COLUMN_NAME}                 frame.time    3gpp.sfn    3gpp.slot    DlData_DciInfo.dciSize    dci.dci11.HARQ_ProcessNumber
#...                            dci.dci11.FrequencyDomainResourceAssignment    dci.dci11.TimeDomainResourceAssignment
#...                            dci.dci11.MCS_TB1    data.data
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009531-ET-A012_On-line_change_actDrxRetransTimerSupport
#    [Documentation]
#    ...    Precondition:
#    ...      TDD VONR
#    ...    Test Steps:
#    ...      Step1:UE1 attach to TDD cell.
#    ...      Step2:PDU session setup for 5QI-5 and 5QI1
#    ...      Step3:start DL and UL Voice data for 5QI1.
#    ...      Step4:online modifyactDrxRetransTimerSupport=true, drxInactivityTimer=2ms and drxHarqRttTimerUL=28symbol for both DL and UL.
#    ...      Step5:UE2 attach to TDD cell
#    ...      Step6:PDU session setup for 5QI-5 and 5QI1.
#    ...      Step7:Using AP test mode to trigger UL PUSCH CRC failure at the end of drx-InactivityTimer.
#    ...      Step8:Using AP test mode to trigger UL PUSCH OK during DRX-retransmissionUL timer.
#    ...    Check Points:
#    ...      1)Verify DRX profile2 configuration will send to UE1 by RRC reconfiguration after 5QI1 seutp.
#	...      2)Verify DRX profile2 configuration will send to UE2 by RRC reconfiguration after 5QI1 seutp.
#    ...      3)For the UL retransmission data the same TBS , PRB is used as for the initial transmission
#    ...      4)After step11,Verify new ul data can transfer when UL re-transimssion PUSCH recieved during DRX-retransimission timer successfully
#    [Tags]    caseA012    Manual_dguan    TA_dguan
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_VONR}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_vonr}    swconfig_param=${SWCONFIG_A_002}    iphy_file=${IPHY_FILE_A12}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Suite Setup Start WTS And Check OnAir
#    #Step1&2&3
#    SA Single UE Attach    ue_id=2
#    Trigger VONR Establishment And Traffic    ue_id=2
#    #Checkpoint1
#    Check Egate Log For DRX Configuration    ms2    ms10    0    0    sl0    sl0    ms40
#    SA 5G Detach    ue_id=2
#    #Step4
#    Online Modify NIDD    ${SCF_PATH}/delta_A012.xml
#    #Step5&6
#    SA Single UE Attach    ue_id=3
#    Trigger VONR Establishment And Traffic    ue_id=3
#    #Checkpoint2
#    Check Egate Log For DRX Configuration    ms2    ms10    0    28    sl4    sl8    ms40
#    #Step7&8
#    Set BLER Testmode    profile_id=31    ul_bler=1000,1000,1000,1000,0,0,0,0
#    CUDU L2 Send Action To GNB    ue_id=3    testmode=bler    action=activate    profile_id=31
#    CUDU_L2 Capture And Decode TTitrace    log_id=1    duration=3
#    #Checkpoint3&4
#    Check EXITULACKRETXTIMER in TTI    1
#    Check Ulretrans And Uldata During RetransTimer
#    [Teardown]    Case Teardown    ue_id=3
#
#CB009531-ET-A018_ANR_CGI_measurement_reporting_for_inter-frequency_HO__at_the_end_of_DRX_retransmission_timers
#    [Documentation]
#    ...    Precondition:
#    ...      TDD ANR CGI
#    ...    Test Steps:
#    ...      Step1:UE1 attach to TDD cell.
#    ...      Step2:start small DL and UL data to trigger UE enter to DRX inactive.
#    ...      Step3:trigger UL HARQ NACK in UlData_PuschReceiveRespHarqU CRC fialure at the end of drx-InactivityTimer
#    ...      Step4:UE report A2 to trigger A3 measurement report
#    ...      Step5:After MG start with RRC reconfiguration send to UE with inter-Frequency measurement.
#    ...      Step6:UE send A5 report to trigger HO.
#    ...      Check Points:
#    ...      1)Verify DRX profile1 configuration will send to UE by RRC reconfiguration.
#    ...      2)After step5, DRX will release and MG cofnigure to UE
#    ...      3)After step7, Verify GNB will send UL PDCCH with same NDI value in the DCI for UL data retransmission
#    ...      in drx-RetransmissionTimerUL after drx-InactivityTimer expire
#    ...      4)After CGI report re-transimmision complete, HO to targer cell successfully.
#    [Tags]    caseA018    Manual_yalsun    TA_yalsun
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_A18}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_A18}    swconfig_param=${SWCONFIG_A_002}    iphy_file=${IPHY_FILE_A18}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_A018.xml
#    Delta Commission With SCF File    ${json_file}
#    Configure UTE ETH3 For A18
#    Suite Setup Start WTS And Check OnAir
#    SA Single UE Attach    ${UE1_ID}
#    #Checkpoint1
#    Check Egate Log For DRX Configuration    ms4    ms40    28    28    sl6    sl4    ms640
#    ${CMD_TRAFFIC_UL}    Set Variable    trf_data_start ue=1 pdu=1 dir=ul burst=1 trf_id=1 period_ms=320 size=42
#    ${CMD_TRAFFIC_DL}    Set Variable    trf_data_start ue=1 pdu=1 dir=dl burst=1 trf_id=1 period_ms=320 size=42
#    ute_wtssim.Execute Egate Command    cmd=${CMD_TRAFFIC_UL}
#    ute_wtssim.Execute Egate Command    cmd=${CMD_TRAFFIC_DL}
#    Set BLER Testmode    profile_id=31    ul_bler=1000,1000,0,0,0,0,0,0
#    CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=activate    profile_id=31
#    ${CMD_A2}    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=30
#    ute_wtssim.Execute Egate Command    cmd=${CMD_A2}
#    common_Log_capture.Start Ttitrace With Streaming Mode
#    ${CMD_A5}    Set Variable    ue_measurement_send_nr id=1 meas_id=4 event=A5 srsrp_nr=19 phycell_id=51 nrsrp_nr=68
#    ute_wtssim.Execute Egate Command    cmd=${CMD_A5}
#    Sleep   6s
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Decode Ttitrace Log   log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Log To Console    Please Find ttitrace log in ${TEST_LOG_DIRECTORY}/ttitrace/1
#	#Checkpoint2
#    Check Egate Log For DRX Configuration    ms4    ms6    28    28    sl8    sl6    ms160
#	#Checkpoint3
#    Check RetxTimerStatus In TTitrace
#	#Checkpoint4
#    Check HO To Target Cell Success
#    [Teardown]    Case Teardown    ue_id=1
#
#
#
#*** Keywords ***
