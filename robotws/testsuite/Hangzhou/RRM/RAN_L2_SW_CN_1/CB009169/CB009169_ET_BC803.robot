*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_qiaren    CN1_SG6    SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/Config/
#${FULL_SCFC}                 CB009169_ET_BC803_SCF.xml
#${IPHY_XML}                  ${CURDIR}/Resources/wts/iphy_2F_2T.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/Resources/wts/
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG}                   CB009169_ET_BC803.cfg
#${EGATE_FILE}                /opt/iphy/latest/egate_console.log
#&{pcell_symbol1}                counter_id=M55335C05006    counter_path=CELLS/NRCELL-12/PDCCH    min_value=10000
#&{pcell_symbol2}                counter_id=M55335C05007    counter_path=CELLS/NRCELL-12/PDCCH    min_value=10000
#&{pcell_symbol3}                counter_id=M55335C05008    counter_path=CELLS/NRCELL-12/PDCCH    max_value=1
#&{scell_symbol1}                counter_id=M55335C05006    counter_path=CELLS/NRCELL-1/PDCCH    max_value=1
#&{scell_symbol2}                counter_id=M55335C05007    counter_path=CELLS/NRCELL-1/PDCCH    min_value=10000
#&{scell_symbol3}                counter_id=M55335C05008    counter_path=CELLS/NRCELL-1/PDCCH    min_value=10000
#@{COUNTER_ID_LIST_PCELL}    &{pcell_symbol1}    &{pcell_symbol2}     &{pcell_symbol3}
#@{COUNTER_ID_LIST_SCELL}    &{scell_symbol1}    &{scell_symbol2}     &{scell_symbol3}
#
#
#*** Test Cases ***
#CB009169_ET_BC803_2TDD_2FDD_DL4CC_UL2CC_A1_ScellAdd_BufferBaseScellAct_AlSelection_Dynamic
#    Two CA UE Attach
#	Start DLUL Traffic For All CA UEs
#    Wait Until Keyword Succeeds    2min    30s    Check Tput For All CA UEs
#	UE1 Report Low CQI
#    Additional UEs Attach
#    Start DLUL Traffic For All NonCA UEs
#	Wait Until Keyword Succeeds    2min    30s    Check Tput For All NonCA UEs
#    GET BIP Log And Check Symbols Increased    BIP_1
#	Detach All Additional UEs
#    Wait Until PM Counter Update    5min    0
#    Wait Until Keyword Succeeds    5min    1min    Check Multi PM Counters Latest Value From Admin    ${COUNTER_ID_LIST_PCELL}
#    Wait Until PM Counter Update    5min    2
#    Wait Until Keyword Succeeds    10min    1min    Check Multi PM Counters Latest Value From Admin    ${COUNTER_ID_LIST_SCELL}
#
#
#
#
#
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=0x580692=1
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#Two CA UE Attach
#    SA Single UE Attach     ue_id=1
#	Trigger A1 Scell Addition    ue_id=1    srsrp_nr=120    phycell_id=61
#    SA Single UE Attach     ue_id=2
#	Trigger A1 Scell Addition    ue_id=2    srsrp_nr=120    phycell_id=61
#
#Additional UEs Attach
## 2 UE for cell 50 tdd,4CA UE for cell 61
#    SA Single UE Attach     ue_id=7
#    SA Single UE Attach     ue_id=8
#    SA Single UE Attach     ue_id=3
#	Trigger A1 Scell Addition    ue_id=3    srsrp_nr=120    phycell_id=61
#	SA Start UL Traffic Internal    ue_id=3    mbps=100    pdu_id=1
#	SA Start DL Traffic Internal    ue_id=3    mbps=800    pdu_id=1
#
#	SA Single UE Attach     ue_id=4
#	Trigger A1 Scell Addition    ue_id=4    srsrp_nr=120    phycell_id=61
#	SA Start UL Traffic Internal    ue_id=4    mbps=100    pdu_id=1
#	SA Start DL Traffic Internal    ue_id=4    mbps=800    pdu_id=1
#
#	SA Single UE Attach     ue_id=5
#	Trigger A1 Scell Addition    ue_id=5    srsrp_nr=120    phycell_id=61
#    SA Start UL Traffic Internal    ue_id=5    mbps=100    pdu_id=1
#	SA Start DL Traffic Internal    ue_id=5    mbps=800    pdu_id=1
#
#	SA Single UE Attach     ue_id=6
#	Trigger A1 Scell Addition    ue_id=6    srsrp_nr=120    phycell_id=61
#    SA Start UL Traffic Internal    ue_id=6    mbps=100    pdu_id=1
#	SA Start DL Traffic Internal    ue_id=6    mbps=1000    pdu_id=1
#
#
#Detach All Additional UEs
#    SA 5G Detach    ue_id=3
#    SA 5G Detach    ue_id=4
#    SA 5G Detach    ue_id=5
#    SA 5G Detach    ue_id=6
#	SA 5G Detach    ue_id=7
#    SA 5G Detach    ue_id=8
#
#Start DLUL Traffic For All CA UEs
#    SA Start UL Traffic Internal    ue_id=1    mbps=100    pdu_id=1
#    SA Start DL Traffic Internal    ue_id=1    mbps=1000    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=2    mbps=100    pdu_id=1
#    SA Start DL Traffic Internal    ue_id=2    mbps=1000    pdu_id=1
#
#Start DLUL Traffic For All NonCA UEs
#    SA Start DL Traffic Internal    ue_id=7    mbps=100    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=7    mbps=50    pdu_id=1
#    SA Start DL Traffic Internal    ue_id=8    mbps=100    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=8    mbps=50    pdu_id=1
#
#
#Check Tput For All CA UEs
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=10
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=5
#	Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=2    target_tp=5
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=ul    cell_type=pcell    scell_index=0    target_tp=2
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=10
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=1    target_tp=5
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=2    target_tp=5
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=pcell    scell_index=0    target_tp=2
#
#Check Tput For All NonCA UEs
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=7    dir=dl    cell_type=pcell    scell_index=0    target_tp=5
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=7    dir=ul    cell_type=pcell    scell_index=0    target_tp=1
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=8    dir=dl    cell_type=pcell    scell_index=0    target_tp=5
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=8    dir=ul    cell_type=pcell    scell_index=0    target_tp=1
#
#UE1 Report Low CQI
#    Set Value For CQI Testmode    profile_id=3    cqi=0
#    Send Action To GNB    ue_id=1    testmode=csi_override    action=activate    profile_id=3    scell=0
#
#Set Value For CQI Testmode
#    [Arguments]    ${profile_id}=3    ${cqi}=15    ${cqi_mode}=fixed    ${cqi_min}=1    ${cqi_max}=15    ${ri}=0
#    Log To Console    Set Value For CQI Testmode...
#    ${cmd}    Catenate    csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi} cqi_mode=${cqi_mode}
#    ...    cqi_min=${cqi_min} cqi_max=${cqi_max} ri=${ri}
#    ute_wtssim.Execute Egate Command    ${cmd}
#
#
#Send Action To GNB
#    [Arguments]    ${ue_id}    ${testmode}    ${action}    ${profile_id}    ${scell}
#    Log To Console    set action=${action} to gnb...
#    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=${testmode} action=${action}
#    ...     profile_id=${profile_id} scell=${scell}
#    ute_wtssim.Execute Egate Command    ${cmd}
#
#
#GET BIP Log And Check Symbols Increased
#    [Arguments]    ${log_id}
#    Capture BIP Log    BIP_1
#	Convert BIP To CSV By MCShark For DlData_PdcchSendReq    BIP_1
#    A2A_Check_CSV_Table_WITHOUTBLANK    ${CURDIR}/A2A/CB009169_BC/pdcch.ini    ${TEST_LOG_DIRECTORY}/${log_id}/pdcch.csv
#    ...    ${TEST_LOG_DIRECTORY}/${log_id}
#
#A2A_Check_CSV_Table_WITHOUTBLANK
#    [Arguments]    ${ini_file}    ${check_csv_file}    ${log_path}=${OUTPUT_DIR}
#    [Documentation]    This keyword is used to check ttitrace csv log, or bip csv log.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${ini_file} | Yes | The A2A's ini file. It is related with A2A csv file that shows the checkpoints.|
#    ...    | ${check_csv_file} | Yes | In fact ,this keyword don't need this parameter,but it still needed fo the cases based on previous usage.|
#    ...    | ${log_path} | Yes | Directory where to put the generated csv logs.|
#    ...
#    ...    Examples:
#    ...    | A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_sinr.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/0/ |
#    ${path_name}	${file_name}=    OperatingSystem.Split Path    ${check_csv_file}
#    ${backup_file}=    OperatingSystem.Join Path    ${path_name}    backup_${file_name}
#    OperatingSystem.Copy File    ${check_csv_file}    ${backup_file}
#    ta_a2a.Check Log With Au2anlysis    ${ini_file}    i    save_log_directory=${log_path}
#
#
#Capture BIP Log
#    [Arguments]    ${log_id}    ${timer}=2
#    Start Gnb BIP Log
#    Sleep    ${timer}s
#    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/${log_id}
#
#
#Convert BIP To CSV By MCShark For DlData_PdcchSendReq
#    [Arguments]       ${log_id}
#    ${filter}=    Set Variable    dldata_pdcchsendreq && !(3gpp.rnti == 65535)
#    @{csv_title_list}=    Create List   3gpp.slot    DlData_DciInfo.startSymbolNumber    DlData_DciInfo.numOfSymbols
#    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off.pcap    ${True}
#	Convert BIP To CSV By MCShark    @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/pdcch.csv    ${filter}    ${csv_title_list}
#	OperatingSystem.Run
#    ...    cp ${TEST_LOG_DIRECTORY}/${log_id}/pdcch.csv ${TEST_LOG_DIRECTORY}/${log_id}/pdcch_bk.csv
#
#
