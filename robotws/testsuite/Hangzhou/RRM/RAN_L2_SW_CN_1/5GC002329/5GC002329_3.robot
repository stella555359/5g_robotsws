*** Settings ***
Documentation    ...
#Resource          ./5GC002329_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup 2
#Test Teardown     Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4    shen_yulei
#...               RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}             1
#${PROFILE_ID}        1
#${GNB_ID}            2
#${CELL_ID}           1
#${BEARER_ID}         2
#${Egatelog_path}     ${CURDIR}
#${SCF_PATH}          ${CURDIR}/config
#${LOCAL_WTS_DIR}     ${CURDIR}/config
#${2329_scf}          ${LOCAL_WTS_DIR}/SCF_3cell.xml
#${WTS_AP_XML}        Airphone_3cell.xml
#${WTS_CFG}           basic_l1bypass_sa_call_tdd_cmwv_multi_ue.cfg
#${WTS_DIR}           /opt/iphy/latest
#${iphy}              ${LOCAL_WTS_DIR}/iphy_3cell.xml
#
#*** Test Cases ***
#5GC002329-ET-AEB3001-Verify single T+F CA UE moving out of FR1 TDD cell coverage with A3 and intra-gnb HO to other TDD cell
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case1
#    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_3001.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Set WTS UE To Pcell
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE Do HOoutcoming and Get Throughput   UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#
#5GC002329-ET-AEB4001-Verify UE intra-gnb moving into FR1 TDD cell from TDD cell with Blind Scell addition
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case1
#    Reboot TL And Check Configured
#    Set WTS UE To Single Cell
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE Do HOincoming and Get Throughput   UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#
#5GC002329-ET-AEB2001-Verify MG release for TDD FR1 and FDD CA UE with A3 intra-gnb
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case1
#    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_2001.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Set WTS UE To Pcell
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE Do HO MG and Get Throughput   UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#
#5GC002329-ET-DB1001-Verify pCSI multiplexing on single UE traffic with dlMimoMode40 2SSB
#    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_DB1001.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE and Check pCSI multiplexing    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=100    ul_tp_threshold=20
#
#5GC002329-ET-ABB3001-Verify A1 MR based SCell addition and buffer-based Scell activation and RLQ-based SCell deactivation with BF deactivated
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_ABB3001.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE
#    A1 triggered Scell Addition ABB3001
#    SA Start DL and UL Traffic and Check Scell Activation
#    Get and Check TPUT After SCELL Activation
#    Moving UE to SCell bad coverage area
#    Get and Check TPUT After SCELL Deactivation
#
#*** Keywords ***
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
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=95 phycell_id=50
#    ...    pass_regexp=SCellIndex 1 activated successfully
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
#    Suite Setup Update GNB    log=${False}
#    #Send All Config For Testline
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Modify IPHY File And Send to Airphone    ${iphy}
#    Full Commission With SCF File    ${2329_scf}
#    Reboot TL And Check Configured
#    Get All Testline Information And Set Suite Variable
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
#Get and Check TPUT After SCELL Activation
#    [Arguments]    ${dl_p_tp_threshold}=200    ${dl_s_tp_threshold}=50    ${ul_tp_threshold}=50
#    Sleep    30s    wait traffic stable
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    should be true    ${pcell_dl_tp}>${dl_p_tp_threshold}
#    should be true    ${pcell_ul_tp}>${ul_tp_threshold}
#    should be true    ${scell_dl_tp}>${dl_s_tp_threshold}
#
#Get and Check TPUT After SCELL Deactivation
#    [Arguments]    ${dl_tp_threshold}=200    ${ul_tp_threshold}=50
#    Sleep    30s    wait traffic stable
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    should be true    ${pcell_dl_tp}>${dl_tp_threshold}
#    should be true    ${pcell_ul_tp}>${ul_tp_threshold}
#    should be true    "${scell_dl_tp}"=="0"
#
#Moving UE to SCell bad coverage area
#    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=0 num_dl_pkts=10000
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} scell=1 testmode=bler action=activate profile_id=1
#
#SA Start DL and UL Traffic and Check Scell Activation
#    Log To Console    Start UL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=175 dir=ul seconds=9999
#    Log To Console    Start DL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl seconds=9999
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=3 mbps=175 dir=dl seconds=9999
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=4 mbps=175 dir=dl seconds=9999
#    ...    pass_regexp=SCellIndex 1 activated successfully    timeout=3minutes
#
#Attach SA UE
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#A1 triggered Scell Addition ABB3001
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=2 event=A1 srsrp_nr=90 phycell_id=50
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
