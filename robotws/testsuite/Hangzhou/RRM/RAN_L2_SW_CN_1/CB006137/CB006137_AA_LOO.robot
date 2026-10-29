*** Settings ***
Documentation    ...
#Resource          ./CB006137_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup 2
#Test Teardown     Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM3    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}       ${CURDIR}
#${SCF_PATH}            ${CURDIR}/config
#${LOCAL_IPHY_DIR}      ${CURDIR}/config
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${6137_scf}            ${LOCAL_WTS_DIR}/SCF_5cell_BOO_AA.xml
##${WTS_CFG}            basic_setup_UL_ul1Layer_v16.cfg
#${WTS_CFG}             basic_setup_UL_ul1Layer_v16_multi_ue_BOO.cfg
#${WTS_DIR}             /opt/iphy/latest
#${iphy}                iphy_2T3F_LOO.xml
#
#*** Test Cases ***
#CB006137-ET-AA901_Verify_single_FDDTDD_UL_CA_UE_with_PDU_session_setup_not_together_with_ICS_A1_scell_addition_and_A2_scell_release_with_non-BF
#    [Tags]    caseAA901    Manual_Fangping    TA_MaYue
#    [Documentation]    scf: 5cell,3F2T,50,51,52,60,61
#    ...    pcell:fdd:lcrId 1:physCellId 50    scell:tdd:lcrId 12:physCellId 61
#    [Setup]    Setup TL For Each Case    ${6137_scf}    ${iphy}    ${WTS_CFG}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    Attach Single SA 2CC UE and Get Throughput and Detach UE
#    ...    UE_ID=1    dl_tp_set=175    ul_tp_set=175    A1_add=${True}    A2_rel=${True}
#    Check Scell UL Config And A1 And A2 Config Exist In RRC Log
#
#CB006137-ET-AA302_Verify_single_FDDTDD_UL_CA_UE_new_DRB_setup_and_old_DRB_release_behavior_after_blind_scell_addition_and_BF_
#    [Tags]    caseAA302    Manual_Yulei    TA_HuKai
#    [Setup]    Setup TL For Each Case    ${6137_scf}    ${iphy}    ${WTS_CFG}
#    Modify SCF for caseAA302
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    Attach Single SA CA UE    UE_ID=${UE_ID}    A1_add=${False}
#    SA 5G PDU Session Setup for NewDRB    ue_id=${UE_ID}
#    Make L3 CALL And Check Throughput for caseAA302 With NewDRB
#    SA 5G PDU Session release for NewDRB    ue_id=${UE_ID}
#    Check Throughput for caseAA302 After NewDRB Release
#    Check NewDRB Config Exist In RRC Log
#
#CB006137-ET-AA201_Verify_successful_operation_of_CB006137_deactivation_by_removing_carrierAggregationSupportList_ca_Fdd_Fr1Tdd_Sa_WithUl
#    [Tags]    caseAA201    Manual_Johny    TA_MaYue
#    [Documentation]    sCellAdditionMethod=blind, sCellOperationalMode=dlAndUl, sCellActivationMethod=blind
#    ...    1.Attach UE-1 to the FDD NR cell. gNB configures UE-1 with FDD cell as PCell and with carrier aggregation (TDD FR1 Cell as SCell),
#    ...      and DL/UL carrier aggregation is configured to UE-1.
#    ...      UL data transfer is only via FDD PCell
#    ...    2.Detach UE-1 from the network
#    ...    3.Deactivate feature CB006137 by removing carrierAggregationSupportList enumeration parameter 210 (ca_Fdd_Fr1Tdd_Sa_WithUl).
#    ...      Existing CA relation defined in NRREL object for FDD cell pointing to the corresponding TDD FR1 cell is not removed.
#    ...      Parameter sCellAdditionMethod within NRREL object remain set to 0 (blind).
#    ...    4.Attach new UE-2 to the FDD NR cell and initiate UE context setup.
#    ...    5.Attach UE-1 to the NG cell and initiate UE context setup again.
#    [Setup]    Setup TL For Each Case    ${6137_scf}    ${iphy}    ${WTS_CFG}
#    Open UL CA Button
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    ${tp}=    Attach Single SA 2CC UE and Get Throughput and Without Detach UE
#    ...    UE_ID=1    dl_tp_set=175    ul_tp_set=175    A1_add=${True}    A2_rel=${True}
#    ${record}=    Catenate    6137 button open:pcell_dl_tp=${tp.pcell_dl_tp};scell_dl_tp=${tp.scell_dl_tp};
#    ...    pcell_ul_tp=${tp.pcell_ul_tp};scell_ul_tp=${tp.scell_ul_tp}
#    Log    ${record}    level=WARN
#    Check CA UE Context
#    Detach Single SA CA UE    UE_ID=1    A2_rel=${True}
#    Close UL CA Button
#    Verify BTS Is OnAir
#    sleep    20s
#    ${tp}=    Attach Single SA 2CC Only DL No UL UE and Get Throughput and Detach UE
#    ...    UE_ID=2    dl_tp_set=175    ul_tp_set=175    A1_add=${False}    A2_rel=${False}
#    ${record}=    Catenate    6137 button close:pcell_dl_tp=${tp.pcell_dl_tp};scell_dl_tp=${tp.scell_dl_tp};
#    ...    pcell_ul_tp=${tp.pcell_ul_tp}
#    Log    ${record}    level=WARN
#    Attach Single SA 2CC Only DL No UL UE and Get Throughput and Detach UE
#    ...    UE_ID=1    dl_tp_set=175    ul_tp_set=175    A1_add=${False}    A2_rel=${False}
#
#*** Keywords ***
#Check NewDRB Config Exist In RRC Log
#    Save Egate Log    ${OUTPUT_DIR}
#    OperatingSystem.Run    mv ${OUTPUT_DIR}/egate_console.log ${OUTPUT_DIR}/egate_console-AA302.log
#    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console-AA302.log
#    A2A_Check_RRC_Log    ${CURDIR}${/}A2A/CB006137_AA_302.ini    save_log_directory=${OUTPUT_DIR}
#
#Make L3 CALL And Check Throughput for caseAA302 With NewDRB
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=175    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=175    trf_id=2
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=2    mbps=175    trf_id=3
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=2    mbps=175    trf_id=4
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    PDU1 DL Troughput is ${dl_tp}    console=True
#    log    PDU1 UL Troughput is ${ul_tp}    console=True
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=2    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=2    dir=ul
#    log    PDU2 DL Troughput is ${dl_tp}    console=True
#    log    PDU2 UL Troughput is ${ul_tp}    console=True
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
#
#Check Throughput for caseAA302 After NewDRB Release
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    PDU1 DL Troughput is ${dl_tp}    console=True
#    log    PDU1 UL Troughput is ${ul_tp}    console=True
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
#
#Modify SCF for caseAA302
#    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_AA302.xml
#    Delta Commission With SCF File    ${json_file}
#
#Check Btslog for caseAA302
#    ${ULCAscelladdregex}=    Grep File    ${btslog}    nonUlCaToUlCa
#    Should Contain    ${ULCAscelladdregex}    timerReassembly:40
#    Should Contain    ${ULCAscelladdregex}    rlcAmUlTReassemblyIBCA:40
#    ${NewDRBaddregex}=    Grep File    ${btslog}    Recv HiUser_BearerSetupResp with OK status
#    Should Contain    ${NewDRBaddregex}    logicalChannelId:5
#    ${NewDRBreleaseregex}=    Grep File    ${btslog}    Received from L2HI itf::l2::hi::du::user::BearerDeleteResp_t
#    Should Contain    ${NewDRBreleaseregex}    logicalChannelId":5
#
#SA 5G PDU Session Setup for NewDRB
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session Setup for NewDRB...
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=2
#    ${command}    Set Variable    ue_pdu_session_setup pdu=2 ue=${ue_id} nwslice=1 gw=2
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Established PDU session ID=2 using PDU Gateway    timeout=3minutes
#    Log To Console    ${output}
#
#SA 5G PDU Session release for NewDRB
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session release for NewDRB...
#    ${command}    Set Variable    ue_pdu_session_release ue=${ue_id} pdu=2 by=ue
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Successfully released PDU Session with ID 2    timeout=3minutes
#    Log To Console    ${output}
#    sleep    20s
#
#Stop And Collect Syslog
#    [Arguments]    ${log_dir}
#    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${log_dir}/Gnb_syslog.tar.gz
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${log_dir}/Gnb_syslog.tar.gz -C ${log_dir}/
#    Set Test Variable    ${btslog}    ${log_dir}/${output}
#
#Open UL CA Button
#    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_AA201_recover.xml
#    Delta Commission With SCF File    ${json_file}
#
#Close UL CA Button
#    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_AA201.xml
#    Delta Commission With SCF File    ${json_file}
#
#Check Scell UL Config And A1 And A2 Config Exist In RRC Log
#    Save Egate Log    ${OUTPUT_DIR}
#    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console.log
#    ${content}=    Grep File    ${egate_console_file}    SCellIndex 1 activated
#    Should Contain    ${content}    SCellIndex 1 activated successfully
#    A2A_Check_RRC_Log    ${CURDIR}${/}A2A/CB006137_AA_901.ini    save_log_directory=${OUTPUT_DIR}
#
#Check CA UE Context
#    Log    check rrc log or emil log
#
#Set WTS UE To Pcell
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 cell=[0-9]
#    @{new_params_list}    Create List    enb=2 cell=1
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Set WTS UE To Single Cell
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 cell=[0-9]
#    @{new_params_list}    Create List    enb=2 cell=3
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Save Egate Log
#    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${log_path}
#
#Trigger A1 Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=95
#    #...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=95 phycell_id=50
#    ...    pass_regexp=SCellIndex 1 activated successfully
#
#Trigger A2 Scell Release
#    [Arguments]    ${ue_id}    ${scell_id}=1    ${scell_rsrp}=36    ${phycell_id}=51
#    [Documentation]    This keyword is to trigger A2 scell release
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | yes | the id of ue |
#    ...    | scell_id | yes | the id of scell |
#    ...    | scell_rsrp | yes | the value of scell_rsrp |
#    ...    | phycell_id | yes | phycell id for scell |
#    ...
#    ...    Examples:
#    ...    | Trigger A2 Scell Release | 1 | 1 | 1 | 51 |
#    ...
#    ${reportconfigidregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportconfigidregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[-1]
#    ${measidregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measid_list}=    String.Get Regexp Matches    ${content}    ${measidregex}    measId
#    ${measida2}=    Set Variable    @{measid_list}[-1]
#    ${cmd}    Catenate    SEPARATOR=${SPACE}    ue_measurement_send_nr id=${ue_id} meas_id=${measida2} event=A2
#    ...    scell=${scell_id} scell_rsrp=${scell_rsrp}
#    ${ret1}=    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=rrc(Connection)?ReconfigurationComplete
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Add RD Parameters To GNB Swconfig File    0x580591=1;0x58056B=0
