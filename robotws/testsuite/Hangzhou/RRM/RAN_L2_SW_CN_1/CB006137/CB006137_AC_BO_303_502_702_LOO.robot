*** Settings ***
Documentation    ...
#Resource           ./CB006137_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        Common Suite Setup
#Test Setup         Common Test Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM3    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}                    1
#${PROFILE_ID}               1
#${GNB_ID}                   2
#${CELL_ID}                  1
#${BEARER_ID}                2
#${Egatelog_path}            ${CURDIR}
#${SCF_DIR}                  ${CURDIR}/config
#${LOCAL_IPHY_DIR}           ${CURDIR}/config
#${LOCAL_WTS_DIR}            ${CURDIR}/config
#${WTS_DIR}                  /opt/iphy/latest
#${WTS_CFG_AC_702}           basci_setup_BOO_5cell.cfg
#${6137_AC_702_SCF}          SCF_BO_5cell_AC702.xml
#${IPHY}                     iphy_2T3F_LOO.xml
#${6137_AC_DRXVoNR_SCF}      SCF_AC_DRXVoNR.xml
#${WTS_CFG_AC_DRXVoNR}       wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_AC_DRXVoNR.cfg
#${4CC_SCELLS}               ('1', '51', '25'), ('2', '60', '77'), ('3', '61', '41')
#
#*** Test Cases ***
#CB006137-ET-AC303_Verify_Single_UE_with_DRX_inactivity_timer_always_on_with_full_buffer_in_F+T(A1_Add_buffer_Act)_2CC_UL_CA
#    [Tags]     caseAC303    YueRong    Owner_krihu
#    [Setup]    Setup TL For Each Case    ${6137_AC_DRXVoNR_SCF}    ${IPHY}    ${WTS_CFG_AC_DRXVoNR}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_AC_DRXVoNR}
#    Sleep    20s
#    Attach SA UE
#    A1 triggered Scell Addition
#    SA Start NonGBR Traffic and Check
#    Check Egate Log For CA And DRX Configuration for AC303
#    Capture And Decode TTitrace
#    SA 5G Detach    ue_id=${UE_ID}
#    Check DrxInactivityTimerOn in TTitrace    ${TEST_LOG_DIRECTORY}/ttitrace/1
#
#CB006137-ET-AC502_Verify_Single_UE_with_cDRXVoNR_VoNR_traffic_+_Normal_traffic_in_F+T(blind_Add_blind_Act)_2CC_UL_CA
#    [Tags]     caseAC502    MaMike    Owner_krihu
#    [Setup]    Setup TL For Each Case    ${6137_AC_DRXVoNR_SCF}    ${IPHY}    ${WTS_CFG_AC_DRXVoNR}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_AC_DRXVoNR}
#    Sleep    20s
#    Attach SA UE
#    A1 triggered Scell Addition
#    Get And Check Scell Infos    ${4CC_SCELLS}
#    Sleep    5s    reason=Wait for traffic
#    Modify PDU Session with VONR    ${UE_ID}    vonr_drx=${True}
#    SA Start GBR Traffic and Check
#    SA Start NonGBR Traffic and Check
#    Check Egate Log For CA And DRX Configuration for AC502
#    SA 5G Detach    ue_id=${UE_ID}
#
#CB006137-ET-AC702_Verify_Single_UE_Data_scheduling_behavior_is_correct_when_MG_is_configed_in_F+T(blind_Add_blind_Act)_2CC_UL_CA
#    [Tags]     caseAC702    DongLili
#    [Setup]    Setup TL For Each Case    ${6137_AC_702_SCF}    ${IPHY}    ${WTS_CFG_AC_702}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_AC_702}
#    Sleep    20s
#    Attach SA UE
#    SA Start NonGBR Traffic and Check For AC702
#    Trigger A2 for MG and Check
#    Trigger A3 for HO and Check
#    CNI-108576 trigger and check
#    SA 5G Detach    ue_id=${UE_ID}
#
#*** Keywords ***
#CNI-108576 trigger and check
#    [Documentation]    This keyword is for CNI-108576
#    ...                Check the numofMsg3 in UlLoadControl.
#    ...                The value of CQI fill with 255(invalid value) for the csi reports marked as DTX.
#    Start Ttitrace With Streaming Mode
#    ute_wtssim.Execute Egate Command    cmd=forced_dtx_testmode_nr profile_id=2 force_dtx_pusch=100:0 force_dtx_pucch=100:0
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} scell=0,1 testmode=forced_dtx profile_id=2 action=activate
#    SA 5G Attach    ue_id=2
#    SA Set Traffic Type To Internal    ue_id=2    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=2
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_DTX_Csi.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/
#    SA 5G Detach    ue_id=2
#
#Trigger A2 for MG and Check
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2 scell=2 scell_rsrp=50
#    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#    Sleep    20s    reason=wait Traffic stable
#    ${pcell_dl_tp}=     Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${scell2_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
#    ${scell3_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=3
#    ${pcell_ul_tp}=     Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=     Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=2
#    Should Be True    "${pcell_dl_tp}">"0"
#    Should Be True    "${scell1_dl_tp}">"0"
#    Should Be True    "${scell2_dl_tp}">"0"
#    Should Be True    "${scell3_dl_tp}">"0"
#    Should Be True    "${pcell_ul_tp}">"0"
#    Should Be True    "${scell_ul_tp}">"0"
#
#Trigger A3 for HO and Check
#    ${command}    Set Variable    ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=10 phycell_id=50 nrsrp_nr=40
#    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#    Sleep    20s    reason=wait Traffic stable
#    ${pcell_dl_tp}=     Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#  	${scell2_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
#  	${scell3_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=3
#    ${pcell_ul_tp}=     Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=     Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=2
#    Should Be True    "${pcell_dl_tp}">"0"
#    Should Be True    "${scell1_dl_tp}">"0"
#    Should Be True    "${scell2_dl_tp}">"0"
#    Should Be True    "${scell3_dl_tp}">"0"
#    Should Be True    "${pcell_ul_tp}">"0"
#    Should Be True    "${scell_ul_tp}">"0"
#
#Check DrxInactivityTimerOn in TTitrace
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_AC303.ini    output_ul.csv    ${csv_file_path}
#
#Capture And Decode TTitrace
#    [Arguments]    ${log_id}=1    ${duration}=2
#    Start Ttitrace With Streaming Mode
#    Sleep    ${duration}s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#
#A1 triggered Scell Addition
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=2 event=A1 srsrp_nr=120
#    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#
#SA Start GBR Traffic and Check
#    [Arguments]    ${UE_ID}=1
#    Log To Console    Start GBR Traffic and Check
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=3 trf_id=1 mbps=10 dir=dl protocol=udp
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=3 trf_id=1 mbps=10 dir=ul protocol=udp
#    Sleep    20s    reason=wait GBR Traffic stable
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${scell2_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
#    ${scell3_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=3
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=2
#    Should Be True    "${pcell_ul_tp}">"0"
#    Should Be True    "${pcell_dl_tp}">"0"
#    Should Be True    "${scell_ul_tp}"=="0"
#    Should Be True    "${scell1_dl_tp}"=="0"
#    Should Be True    "${scell2_dl_tp}"=="0"
#    Should Be True    "${scell3_dl_tp}"=="0"
#
#SA Start NonGBR Traffic and Check
#    [Arguments]    ${UE_ID}=1    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
#    Log To Console    Start NonGBR Traffic and Check
#    SA Start DL and UL Traffic    ul_tp=80
#    Sleep    20s    reason=wait NonGBR Traffic stable
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${scell2_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
#    ${scell3_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=3
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=2
#    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    Should Be True    ${scell1_dl_tp}>${dl_tp_threshold}
#  	Should Be True    ${scell2_dl_tp}>${dl_tp_threshold}
#  	Should Be True    ${scell3_dl_tp}>${dl_tp_threshold}
#  	Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
#  	Should Be True    ${scell_ul_tp}>${ul_tp_threshold}
#
#SA Start NonGBR Traffic and Check For AC702
#    [Arguments]    ${UE_ID}=1    ${dl_tp_threshold}=10    ${ul_tp_threshold}=10
#    Log To Console    Start NonGBR Traffic and Check
#    Log To Console    Start DL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=3 mbps=175 dir=dl
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=4 mbps=175 dir=dl
#    Log To Console    Start UL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=5 mbps=175 dir=ul
#    Sleep    20s    reason=wait NonGBR Traffic stable
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${scell2_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
#    ${scell3_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=3
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=2
#    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    Should Be True    ${scell1_dl_tp}>${dl_tp_threshold}
#  	Should Be True    ${scell2_dl_tp}>${dl_tp_threshold}
#  	Should Be True    ${scell3_dl_tp}>${dl_tp_threshold}
#  	Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
#  	Should Be True    ${scell_ul_tp}>${ul_tp_threshold}
#
#Check Egate Log For CA And DRX Configuration for AC502
#    Save Egate Log    ${OUTPUT_DIR}
#    OperatingSystem.Run    mv ${OUTPUT_DIR}/egate_console.log ${OUTPUT_DIR}/egate_console-AC502.log
#    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console-AC502.log
#    ${content_1}=    Grep File    ${egate_console_file}    SCellIndex 1 activated successfully
#    Should Contain    ${content_1}    SCellIndex 1 activated successfully at airphone
#    ${content_2}=    Grep File    ${egate_console_file}    drx-InactivityTimer ms
#    Should Contain    ${content_2}    drx-InactivityTimer ms80,
#    Should Contain    ${content_2}    drx-InactivityTimer ms8,
#    ${content_3}=    Grep File    ${egate_console_file}    drx-LongCycleStartOffset
#    Should Contain    ${content_3}    drx-LongCycleStartOffset ms160
#    Should Contain    ${content_3}    drx-LongCycleStartOffset ms40
#
#Check Egate Log For CA And DRX Configuration for AC303
#    Save Egate Log    ${OUTPUT_DIR}
#    OperatingSystem.Run    mv ${OUTPUT_DIR}/egate_console.log ${OUTPUT_DIR}/egate_console-AC303.log
#    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console-AC303.log
#    ${content_1}=    Grep File    ${egate_console_file}    SCellIndex 1 activated successfully
#    Should Contain    ${content_1}    SCellIndex 1 activated successfully at airphone
#    ${content_2}=    Grep File    ${egate_console_file}    drx-InactivityTimer ms
#    Should Contain    ${content_2}    drx-InactivityTimer ms80
#    ${content_3}=    Grep File    ${egate_console_file}    drx-LongCycleStartOffset
#    Should Contain    ${content_3}    drx-LongCycleStartOffset ms160
#    ${content_4}=    Grep File    ${egate_console_file}    drx-onDurationTimer milliSeconds
#    Should Contain    ${content_4}    drx-onDurationTimer milliSeconds : ms10
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Add RD Parameters To GNB Swconfig File    0x58056B=0;0x58062d=1;0x580307=0x5fe
