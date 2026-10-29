*** Settings ***
Resource    ./resources/CB007834_5G_A_common_keyword.robot
Variables    ./resources/CB007834_5G_A_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB007834-5G-A

Suite Setup    Run Keywords
...    Common Suite Setup for COAM    AND
#...    Load SCF with different release    AND
...    Adjust gNB_RU Attenuation TL363    cell21_value=${20}    AND
...    Run Keyword And Ignore Error    Locked ALL LTE cell


Suite Teardown    Run Keywords
...    Common Suite Teardown for COAM    AND
...    Run Keyword And Ignore Error    UnLocked ALL LTE cell    AND
...    Adjust gNB_RU Attenuation TL363    AND
...    Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name}    Configuration_scf_GNB1_CB007834
${gnb1_filename}    log_name_8232_002.pcap
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${ul_expect_tput}    79
${dl_expect_tput}    287
${dl_throughput}    350M
${ul_throughput}    100M
${ul_expect_tput_TDD}    235
${dl_expect_tput_TDD}    1415
${dl_throughput_TDD}    1500M
${ul_throughput_TDD}    300M
${inter_rat_target_value}    ${50}
${origin_value}    ${20}
${tput_dl_pcell}    600
${tput_dl_scell}    300
${default_ue_index}    0
${trunk_beamset6_scf}    Configuration_scf_GNB1_CB007834_SBTS23R3_ENB_9999_beamset6.xml
${trunk_beamset2_scf}    Configuration_scf_GNB1_CB007834_SBTS23R3_ENB_9999_beamset2.xml
${expected_tput_dl_T_pcell}    287
${expected_tput_dl_T_scell1}    162
${expected_tput_dl_T_scell2}    1409
${dl_throughput_3CC}    800M
@{LNRCELL_ENB0}    ${1}    ${11}    ${31}    ${2}    ${12}   ${32}    ${3}    ${13}    ${33}    ${21}    ${61}
...    ${22}    ${62}    ${23}    ${63}    ${4}    ${14}    ${34}    ${24}    ${64}
#@{LNRCELL_ENB1}    ${131}    ${141}    ${132}    ${142}    ${133}    ${143}
${file_path}    /opt/workspace/SCF/kpi_report_releated_parameters.yml
${report_name}     kpi_report_releated_parameters_report
${excel_kpi_path}    /opt/workspace/SCF/
${tl_id}    363
@{allow_fault_list}    62003    7311    7307    7107    8000     7331


*** Test Cases ***
[1]CB007834-5G-A_001_UL_DL_peak_Tput_verify_per_release
    [Documentation]    This user scenario to verify peak Tput for UL and DL besed on TMO configuration.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    ##check FDD cell-21 tput
    Modify Parameters for Cases    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_A001_FDD_Lock_other_Cell}
    sleep    30s
    Adjust gNB_RU Attenuation TL363    cell21_value=${20}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    Attach and check DLUL tput    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
    ...    dl_expect_tput=${dl_expect_tput}    ul_expect_tput=${ul_expect_tput}    lcrid=${21}
    ##check TDD cell-303 tput
    Modify Parameters for Cases    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_A001_TDD_Lock_other_Cell}
    sleep    30s
    Adjust gNB_RU Attenuation TL363    cell303_value=${5}
    Attach and check DLUL tput    dl_throughput=${dl_throughput_TDD}    ul_throughput=${ul_throughput_TDD}
    ...    dl_expect_tput=${dl_expect_tput_TDD}    ul_expect_tput=${ul_expect_tput_TDD}    lcrid=${303}
    ...    process_num=${2}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error     ute_ue._stop_using_ue    ue_alias=UE_${ue_index}    AND
    ...    Online Modify Cell Status    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_Unlock_all_cell}    AND
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Common test Teardown for UUF    AND
    ...    Run Keyword And Ignore Error    Tear down the connections

[1]CB007834-5G-A_Verify_3CC_peakTput_for_DL_FDD_N25_PCell_FDD_N71_TDD_N41_Scell
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify Parameters for Cases    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_3CC_${gnb_instance}}
    sleep    30s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    Adjust gNB_RU Attenuation TL363    cell21_value=${20}    cell303_value=${5}    cell3_value=${30}
    Wait until keyword succeeds    5X    10s    Attach and check 3CC tput
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Online Modify Cell Status    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_Unlock_all_cell}    AND
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'     Common test Teardown for UUF    AND
    ...    Run Keyword And Ignore Error    Tear down the connections

[1]CB007834-5G-A_8232_002_RRC_Connection_Reject_with_ESTcause=MPS_and_applyPriorityAccess=HPA
    [Documentation]    This case describes RRC connection setup will be rejected with priority access cause is different
     ...               to applyPriorityAccess when only numOfRadioResReservForPa resource are available
     ...               add RFM Reset  BB Rest  EDA  Check Cell with beamset6 and beamset2 can on air
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    5 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Set Test Variable    ${test_result}    ${False}
    Common Case TestLine Setup     connection=${gnb_conn}
    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_8232}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    Adjust gNB_RU Attenuation TL363    cell21_value=${20}
    Start capture gNB log on master    filename=${gnb1_filename}   gNB_index=${0}
    Attach and check power UE    ue_type=${ue_type}
    Stop and download the Logs    filename=${gnb1_filename}    gNB_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}
    Run Keyword And Ignore Error     ute_ue._stop_using_ue    ue_alias=UE_${ue_index}
    Check wireshark log for mps   logname=${gnb1_filename}
    Run Keyword And Ignore Error    Common Case TestLine Setup     connection=${gnb_conn}
    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_8232_Restore}
#    Modify parameters online for cases    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_PowerSave}    WEBUI_COAM=${WEBUI_COAM}
    Modify Parameters for Cases    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_PowerSave}
    sleep    30s
#    Set Test Variable    ${reset_round}    3
#    FOR    ${count}    IN RANGE    ${reset_round}
#        reset RMOD action    reset_type=Soft    gnb_index=${0}
#    END
    Get SCF file name for beamset6 and beamset2
    Check Cell with beamset6 and beamset2 can on air
    Set Test Variable    ${test_result}    ${True}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error     ute_ue._stop_using_ue    ue_alias=UE_${ue_index}    AND
    ...    run keyword if  not ${test_result}     Common test Teardown for UUF       AND
    ...    Run Keyword And Ignore Error
    ...    Modify Parameters for Cases    Modify_Para_Online==${PARAMETERS_TO_ONLINE_MODIFY_8232_Restore}    AND
#    ...    Run Keyword And Ignore Error    Modify parameters online for cases
#    ...    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_PowerSave_Restore}    WEBUI_COAM=${WEBUI_COAM}    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Tear down the connections

##[1]CB007834-5G-A_1354_C_004_DelayThresh1and2Enabled_Retransmission_of_PDCP_PDUs_over_X2-U_due_to_RLO_with_CA_enabled_with_NSA
##    [Documentation]    This test case describes the gNB behavior for the retransmission of PDCP PDUs over_X2-U when the
##    ...                Threshold monitoring exceeds the configured value NRDRB_PDCP.pdcpPduRetxThreshold1 and
##    ...                NRDRB_PDCP.pdcpPduRetxThreshold2 with NSA classicalFR1 nokiaENB FDD non GBR DRB UDP due to Radio
##    ...                link outage (RLO) for NSA non GBR DRB when Carrier aggregation (CA) is enabled.
##    ...                Cell lock unlock/ block unblock /delta commissioniong
##    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
##    [Timeout]    10 hour
##    [Setup]    robot_common_operations.Common Case Setup
##    Set Test Variable    ${test_result}    ${False}
##    Modify parameters online for cases    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_PowerSave}    WEBUI_COAM=${WEBUI_COAM}
##    Adjust gNB_RU Attenuation TL363    cell103_value=${20}
##    Set Test Variable    ${reset_round}    3
##    FOR    ${count}    IN RANGE    ${reset_round}
##        Modify Pmax of Cell Parameter via WebUI    cell_id=103
##        sleep    30s
##    END
##    Set Test Variable    ${test_result}    ${True}
##    [Teardown]    Run Keywords
##    ...    Run Keyword Unless    ${test_result}     Common test Teardown for UUF       AND
##    ...    Run Keyword And Ignore Error    Modify parameters online for cases
####    ...    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_PowerSave_Restore}    WEBUI_COAM=${WEBUI_COAM}    AND
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error    Tear down the connections
#


[1]CB007835_5G_A_002_SA_intergnb_interfre_FDD_HO_TDD_706_stability
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_003_SA_intragnb_interfre_FDD_HO_TDD_706_stability
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_004_SA_intergnb_intrafre_TDD_HO_TDD_704_stability
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_005_SA_intergnb_interfre_FDD_HO_TDD_NG_705_stability
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_007_SA_intragnb_intrafre_FDD_HO_FDD_6112_VoNR
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_007_SA_intragnb_intrafre_FDD_HO_FDD_784_EC_call
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_008_NSA_intergnb_interfre_FDD_HO_TDD_1095_stability
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_009_NSA_intragnb_interfre_FDD_HO_TDD_1095_stability
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_010_NSA_intergnb_intrafre_TDD_HO_TDD_573_stability
    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    sleep    10s
    [Teardown]    robot_common_operations.Common Case Teardown





*** Keywords ***
Load SCF with different release
    ${release}=    Get sagnb release 7834
    Common Case TestLine Setup    is_commission=True    golden_scf_name=${golden_scf_name}_${release}.xml
    Wait until keyword succeeds    20 min    20s    Check the cells status on air

Online Modify Cell Status
    [Arguments]    ${Modify_Para_Online}=${PARAMETERS_TO_ONLINE_MODIFY_3CC}
    Modify Parameters for Cases    Modify_Para_Online=${Modify_Para_Online}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air

Check counter for 1354
    ${counter_value_list}    Get the all PM counter value    gnb_index=${0}    counter_id=${counter_id_1354}
    ...    dic_path=${counter_dic_path_1354}
    ${Threshold1_value_list}    Get the all PM counter value    gnb_index=${0}    counter_id=${counter_id_1354_Threshold1}
    ...    dic_path=${counter_dic_path_1354_Threshold1}
    ${Threshold2_value_list}    Get the all PM counter value    gnb_index=${0}    counter_id=${counter_id_1354_Threshold2}
    ...    dic_path=${counter_dic_path_1354_Threshold2}
    FOR    ${index}    IN    ${counter_value_list}
       Run keyword If    '${index}'=='0' or '${index}'=='1'        Should be True    ${counter_value_list${index}}==0
       ...    ELSE    Should be True    2000 > ${counter_value_list${index}} > 0
       sleep    1s
    END
    ${M55354C04007_DL_NUM_RETX_F1U_THR1}    Set Variable    ${counter_value_list}[2]
    ${M55355C06007_DL_NUM_RETX_X2U_THR1}    Set Variable    ${counter_value_list}[0]
    ${M55354C06007_DL_NUM_RETX_F1U_THR2}    Set Variable    ${counter_value_list}[6]
    ${M55355C08007_DL_NUM_RETX_X2U_THR2}    Set Variable    ${counter_value_list}[4]
    Evaluate    Sum(${Threshold1_value_list})<${M55354C04007_DL_NUM_RETX_F1U_THR1}+${M55355C06007_DL_NUM_RETX_X2U_THR1}
    Evaluate    Sum(${Threshold2_value_list})<${M55354C06007_DL_NUM_RETX_F1U_THR2}+${M55355C08007_DL_NUM_RETX_X2U_THR2}
    [Teardown]    COAM Teardown gnb connections

Locked ALL LTE cell
    Locked LTE cell    enb_index=${0}    LNRCELL_list=${LNRCELL_ENB0}

UnLocked ALL LTE cell
    UnLocked LTE cell    enb_index=${0}    LNRCELL_list=${LNRCELL_ENB0}

Attach and check 3CC tput
    Attach and check power UE    ue_type=${ue_type}
    Power UE Start DL traffic    dl_throughput=${dl_throughput_3CC}    dl_length=1400B    duration=2400    process_num=${3}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=1800    duration=2400
    sleep    120s
#    Prepare to caculate PM counter    period=start
#    Get record time    label=start
#    sleep    1200s
#    Get record time    label=end
    Check 3CC DLUL tput    ue_type=${ue_type}
    Stop UL DL data transfer
#    sleep    15m
#    Get bts package version
#    generate new report and get report id    file_path=${file_path}    report_name=${package_version}_${report_name}    tl_id=${tl_id}
#    ...    package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
#    download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
    [Teardown]    Run keywords    Stop UL DL data transfer    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}

Check 3CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T_pcell}    ${tput_dl_scell1}=${expected_tput_dl_T_scell1}
    ...    ${tput_dl_scell2}=${expected_tput_dl_T_scell2}
    ...    ${pcellid}=21    ${scellid1}=3    ${scellid2}=303
    ...    ${gnb_prime}=${0}    ${gnb_external}=${0}    ${ue_type}=${ue_type}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell1}    COAM Get nrcellid with lcrid    lcrid=${scellid1}    gnb_index=${gnb_external}
    ${nrcellid_scell2}    COAM Get nrcellid with lcrid    lcrid=${scellid2}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell1}    Create list  ${nrcellid_scell1}
    ${nrcellid_scell2}    Create list  ${nrcellid_scell2}
    ${tput_log_prime}    power_ue.Collect Tput    duration=60s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_prime}
    ${tput_log_external}    power_ue.Collect Tput    duration=60s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_external}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell1}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell1}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell2}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell2}
    Power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${ul_expect_tput}
