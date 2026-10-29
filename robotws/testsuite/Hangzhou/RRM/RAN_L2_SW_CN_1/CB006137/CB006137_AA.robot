*** Settings ***
Documentation    ...
#Resource    ./CB006137_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Run Keywords    Common Suite Setup
#...            AND    Start WTS And Check OnAir
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2    egate=false
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM3
#...                RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}    ${CURDIR}
#${SCF_PATH}    ${CURDIR}/config
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${6137_scf}    ${LOCAL_WTS_DIR}/SCF_5cell_BOO_AA.xml
##${WTS_CFG}    basic_setup_UL_ul1Layer_v16.cfg
#${WTS_CFG}    basic_setup_UL_ul1Layer_v16_multi_ue_BOO.cfg
#${WTS_DIR}    /opt/iphy/latest
#${iphy}    ${LOCAL_WTS_DIR}/iphy_10M_N66_60M_N77.xml
#
#*** Test Cases ***
#CB006137-ET-AA901_Verify_single_FDDTDD_UL_CA_UE_with_PDU_session_setup_not_together_with_ICS_A1_scell_addition_and_A2_scell_release_with_non-BF
#    [Tags]    caseAA901    Manual_Fangping    TA_MaYue
#    [Documentation]    scf: 5cell,3F2T,50,51,52,60,61
#    ...    pcell:fdd:lcrId 1:physCellId 50    scell:tdd:lcrId 12:physCellId 61
#    #Run     echo "sleep 5s; ue_deregister id=1 ue_deregister_type=switch_off"|telnet 0 20000
#    #CB006137_resource.Start WTS And Check OnAir
#    Attach Single SA 2CC UE and Get Throughput and Detach UE
#    ...    UE_ID=1    dl_tp_set=175    ul_tp_set=175    A1_add=${True}    A2_rel=${True}
#    Check Scell UL Config And A1 And A2 Config Exist In RRC Log
#
#CB006137-ET-AA201_Verify_successful_operation_of_CB006137_deactivation_by_removing_carrierAggregationSupportList_ca_Fdd_Fr1Tdd_Sa_WithUl
#    [Tags]    caseAA201    Manual_Johny    TA_MaYue
#    [Documentation]    sCellAdditionMethod=blind, sCellOperationalMode=dlAndUl, sCellActivationMethod=blind
#    ...    1.Attach UE-1 to the FDD NR cell. gNB configures UE-1 with FDD cell as PCell and with carrier aggregation (TDD FR1 Cell as SCell),
#    ...      and DL/UL carrier aggregation is configured to UE-1.
#    ...      UL data transfer is only via FDD PCell
#    ...    2.Deactivate feature CB006137 by removing carrierAggregationSupportList enumeration parameter 210 (ca_Fdd_Fr1Tdd_Sa_WithUl).
#    ...      Existing CA relation defined in NRREL object for FDD cell pointing to the corresponding TDD FR1 cell is not removed.
#    ...      Parameter sCellAdditionMethod within NRREL object remain set to 0 (blind).
#    ...    3.Attach new UE-2 to the FDD NR cell and initiate UE context setup.
#    ...    4.Detach UE-1 from the network
#    ...    5.Attach UE-1 to the NG cell and initiate UE context setup again.
#    Open UL CA Button
#    #CB006137_resource.Start WTS And Check OnAir
#    ${tp}=    Attach Single SA 2CC UE and Get Throughput and Without Detach UE
#    ...    UE_ID=1    dl_tp_set=175    ul_tp_set=175    A1_add=${True}    A2_rel=${True}
#    ${record}=    Catenate    6137 button open:pcell_dl_tp=${tp.pcell_dl_tp};scell_dl_tp=${tp.scell_dl_tp};
#    ...    pcell_ul_tp=${tp.pcell_ul_tp};scell_ul_tp=${tp.scell_ul_tp}
#    Log    ${record}    level=WARN
#    Check CA UE Context
#    Close UL CA Button
#    Verify BTS Is OnAir
#    ${tp}=    Attach Single SA 2CC Only DL No UL UE and Get Throughput and Detach UE
#    ...    UE_ID=2    dl_tp_set=175    ul_tp_set=175    A1_add=${False}    A2_rel=${False}
#    ${record}=    Catenate    6137 button close:pcell_dl_tp=${tp.pcell_dl_tp};scell_dl_tp=${tp.scell_dl_tp};
#    ...    pcell_ul_tp=${tp.pcell_ul_tp}
#    Log    ${record}    level=WARN
#    Detach Single SA CA UE    UE_ID=1    A2_rel=${True}
#    Attach Single SA 2CC Only DL No UL UE and Get Throughput and Detach UE
#    ...    UE_ID=1    dl_tp_set=175    ul_tp_set=175    A1_add=${False}    A2_rel=${False}
#
#CB006137-ET-AA302_Verify_single_FDDTDD_UL_CA_UE_new_DRB_setup_and_old_DRB_release_behavior_after_blind_scell_addition_and_BF_
#    [Tags]    caseAA302    Manual_Yulei    TA_HuKai
#    Modify SCF for caseAA302
#    #CB006137_resource.Start WTS And Check OnAir
#    Attach Single SA CA UE    UE_ID=${UE_ID}    A1_add=${False}
#    SA 5G PDU Session Setup for NewDRB    ue_id=${UE_ID}
#    Make L3 CALL And Check Throughput for caseAA302 With NewDRB
#    SA 5G PDU Session release for NewDRB    ue_id=${UE_ID}
#    Check Throughput for caseAA302 After NewDRB Release
#    Check NewDRB Config Exist In RRC Log
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
#    [Return]    ${output}
#    Log To Console    ${output}
#
#SA 5G PDU Session release for NewDRB
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session release for NewDRB...
#    ${command}    Set Variable    ue_pdu_session_release ue=${ue_id} pdu=2 by=ue
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Successfully released PDU Session with ID 2    timeout=3minutes
#    [Return]    ${output}
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
#    ${content}=    Grep File    ${egate_console_file}    SCellIndex 1 activated successfully
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
#Attach SA UE Do HOoutcoming and Get Throughput
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measId}=    Get MeasID A3 After A2
#    Trigger Intra A3 HO Outcoming    ${UE_ID}    meas_id=${measId}
#    Sleep    3s
#    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    should be true    ${pcell_tp}>${dl_tp_threshold}
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#Attach SA UE Do HOincoming and Get Throughput
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measId}=    Get MeasID A3 After A2
#    Trigger Intra A3 HO Incoming    ${UE_ID}    meas_id=${measId}
#    Sleep    3s
#    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    should be true    ${pcell_tp}>${dl_tp_threshold}
#    should be true    ${scell_tp}>${dl_tp_threshold}
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#Attach SA UE Do HO MG and Get Throughput
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    ${measIdA1}=    Get MeasID A1
#    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA3}=    Get MeasID A3 After A2
#    Trigger A3 MG Release    ${UE_ID}    meas_id=${measIdA3}
#    Sleep    3s
#    Get CA Cell Average Throughput    1    dl    pcell    0
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#Save Egate Log
#    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${log_path}
#
#SA 5G PDU Session Setup CA
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session Setup CA...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=SCellIndex 1 activated successfully    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#Get MeasID A3
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA3
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measId}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measId}
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
#Get MeasID A2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA2}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA2}
#
#Get MeasID A3 After A2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA3
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[1]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measId}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measId}
#
#Trigger Intra A3 HO Outcoming
#    [Arguments]    ${UE_ID}=1    ${meas_id}=1
#    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5 ssinr_nr=10
#    ...    phycell_id=52 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed
#
#Trigger Intra A3 HO Incoming
#    [Arguments]    ${UE_ID}=1    ${meas_id}=1
#    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5 ssinr_nr=10
#    ...    phycell_id=50 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=SCellIndex 1 activated successfully
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
#Trigger A2 MG Setup
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=gapUE setup
#    Sleep    5s
#
#Trigger A3 MG Release
#    [Arguments]    ${UE_ID}    ${meas_id}=1
#    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5 ssinr_nr=10
#    ...    phycell_id=52 nrsrp_nr=60 nrsrq_nr=60 rs_type=ssb index=0 nrs_result=30:30:30
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=gapUE release
#
#Common Suite Setup
#    Suite Setup Update GNB    swconfig_param=0x580591=1;0x58056B=0    scf_file=${6137_scf}    log=${False}    iphy_file=${iphy}
#    #Send All Config For Testline
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    #Modify IPHY File And Send to Airphone    ${iphy}
#    #Full Commission With SCF File    ${6137_scf}
#    Reboot TL And Check Configured
#    #Get All Testline Information And Set Suite Variable
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
#Attach SA UE and Check pCSI multiplexing
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    ${output}=    SA 5G PDU Session Setup CA pCSI  ue_id=${UE_ID}
#    Check pCSI multiplexing    ${output}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#SA 5G PDU Session Setup CA pCSI
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session Setup CA...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
#    [Return]    ${output}
#    Log To Console    ${output}
#
#Check pCSI multiplexing
#    [Arguments]    ${content}
#    ${slot_320_regex}=    Set Variable    reportSlotConfig slots320 : (?P<slot_320>\\d+)
#    ${slot_320_list}=    String.Get Regexp Matches    ${content}    ${slot_320_regex}    slot_320
#    ${slot_320_1}=    Set Variable    @{slot_320_list}[0]
#    ${slot_320_2}=    Set Variable    @{slot_320_list}[1]
#    Should Be True    "${slot_320_1}"=="${slot_320_2}"
#
#SA Start DL Traffic
#    Log To Console    Start DL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
#    Sleep    5s
#
#Check Scell Activation
#    ta5g_egate.Wait For Egate Console Output    expected_message=SCellIndex 1 activated successfully    timeout=300s
#    Log To Console    SCellIndex 1 activated successfully
#    Sleep    5s
#
#Get and Check PM Counter After SCELL Activation
#    [Documentation]    scell throughput pm counter: M55310C01006
#    #<p name="reportingIntervalPm">5min</p>
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    20s    wait pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    ${pcell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=1
#    Should Be True    "${pcell_dl_tp}">"0"
#    ${scell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=2
#    Should Be True    "${scell_dl_tp}">"0"
#    ${pcell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=1
#    Should Be True    "${pcell_ul_tp}">"0"
#    ${scell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=2
#    Should Be True    "${scell_ul_tp}"=="0"
#    ${scell_activations}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=2
#    Should Be True    "${scell_activations}"=="1"
#    ${scell_deact_buffer}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=2
#    Should Be True    "${scell_deact_buffer}"=="0"
#
#Get and Check PM Counter After SCELL Deactivation
#    [Documentation]    scell throughput pm counter: M55310C01006
#    #<p name="reportingIntervalPm">5min</p>
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    20s    wait pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    ${pcell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=1
#    Should Be True    "${pcell_dl_tp}">"0"
#    ${pcell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=1
#    Should Be True    "${pcell_ul_tp}">"0"
#    ${scell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=2
#    Should Be True    "${scell_ul_tp}"=="0"
#    ${scell_activations}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=2
#    Should Be True    "${scell_activations}"=="0"
#    ${scell_deact_buffer}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=2
#    Should Be True    "${scell_deact_buffer}"=="1"
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    20s    wait pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    ${scell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=2
#    Should Be True    "${scell_dl_tp}"=="0"
#
#Moving UE to SCell bad coverage area
#    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=0 num_dl_pkts=10000
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} scell=1 testmode=bler action=activate profile_id=1
#
#SA Start DL and UL Traffic
#    Log To Console    Start DL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
#    Log To Console    Start UL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=3 mbps=175 dir=ul
#
#Attach SA UE
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#A1 triggered Scell Addition ABB3001
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A1 srsrp_nr=90 phycell_id=50
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
