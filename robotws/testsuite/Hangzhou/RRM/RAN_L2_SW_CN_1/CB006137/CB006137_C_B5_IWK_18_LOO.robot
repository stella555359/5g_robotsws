*** Settings ***
Documentation    ...
#Resource    ./CB006137_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_TDD    CRT    CN1_SG09_SM3
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}               ${CURDIR}
#${SCF_DIR}                     ${CURDIR}/config
#${LOCAL_IPHY_DIR}              ${CURDIR}/config
#${SCF_PATH}    ${CURDIR}/config
#${6137_C_1801_SCF}           SCF_C1801.xml
#${WTS_CFG_C}              basic_setup_1801.cfg
#${iphy_2T3F_C}     iphy_2T3F_LOO_1801.xml
#
#*** Test Cases ***
#CB006137-ET-C-IWK1801_Verify_IWK_with_PRB_Blanking_up_to_26_PRB_are_blanked_in_FDD_10MHz
#    [Documentation]
#    ...   Precondition:  sCellActivationMethod = bufferBased configured
#    ...   Test Steps:
#    ...   # Step1: Enable PRB blanking feature, by changing actPRBBlanking to true
#    ...   # Step2: Attach UE to the FDD NR cell
#    ...   # Step3: RRCReconfiguration message with sCellToAddModList containing SCellConfig is sent to UE to add the selected SCell candidate
#    ...   # Step4:capture ttilog, Check FDD cell PRB num
#    ...    Check point  1.UE can attach to the PCell successfully and gNB can obtain UE capabilities successfully
#    ...                 2.UE is successfully configured with FDD+FR1 TDD 2CC joint UL+DL CA with FDD cell acts as PCell
#    ...                 3.PRB blanking functionality is enabled successfully
#    ...                 3.traffic is normal both on Pcell and Scell
#    ...                 4.check tti trace numofPRB of FDD scell is right due to pusch Configuration
#    [Tags]    caseC1801    alicchen    CRT
#    [Setup]    Setup TL For Each Case    ${6137_C_1801_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C}
#    #Check Syslog For PrbBlanking functionality is enabled
#    Attach SA UE
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1
#    A1 triggered Scell Addition    ${UE_ID}   meas_id=${measIdA1}
#    Start SA UE Big DL Traffic Internal    ue_id=1    pdu_id=1    mbps=1024    trf_id=1
#	Start SA UE Big UL Traffic Internal    ue_id=1    pdu_id=1    mbps=1024    trf_id=1
#	Check Scell Activation
#    ${log_dir}=    Capture And Decode TTitrace    C1801
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/CIWK_18/ttitrace_ul_prb.ini    ${log_dir}/format_output_ul.csv    ${log_dir}
#
#*** Keywords ***
#Attach SA UE Do UL Traffic
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    Sleep    10s
#    ${TDDpcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}    skip_reboot=${True}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Configure UTE ETH For GNB3
#
#Configure UTE ETH For GNB3
#    [Documentation]    This keyword is to configure VM interfaces.
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4
#
#Save Egate Log
#    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${log_path}
#
#Get MeasID A1
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA1}
#
#A1 triggered Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=110 phycell_id=50
#    ...    pass_regexp=rrcReconfigurationComplete
#
#Check Scell Activation
#    Log To Console    SCellIndex 1 activated successfully
#    Sleep    5s
#
#Check Syslog For PrbBlanking functionality is enabled
#    ${syslog_file}=    set variable    ${CURDIR}/SYSLOG_88.LOG
#    Run    grep "\\[MSG\\] Sent to L2PS itf::l2::ps::cell::CellSetupReq_t" ${syslog_file}>${OUTPUT_DIR}/cell_setupReq.txt
#    ${content}=    Get File    ${OUTPUT_DIR}/cell_setupReq.txt
#    Should Contain    ${content}    "actPrbBlanking":true    msg=actPrbBlanking failure!
#    Should Contain    ${content}    "nbrOfBlankedPRBsLowEdgeDL":0    msg=actPrbBlanking failure!
#    Should Contain    ${content}    "nbrOfBlankedPRBsHighEdgeDL":26    msg=actPrbBlanking failure!
#
#Attach SA UE
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#Check NumOfPRB On TDD Cell
#    [Arguments]    ${case_id}    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/C1602/ttitrace_pcsi.ini    output_ul.csv    ${csv_file_path}
#
#Capture And Decode TTitrace
#    [Arguments]    ${log_id}=1    ${duration}=1
#    Log To Console     start ttitrace...
#    Start Ttitrace With Streaming Mode
#    Sleep    ${duration}s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    [Return]    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
