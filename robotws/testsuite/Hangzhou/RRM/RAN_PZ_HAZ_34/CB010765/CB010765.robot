*** Settings ***
Documentation    author: Deng Xueqin
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com

Force Tags    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIML_ABIOB1_ABIQB2_AQQL_AQQY    RAN_5G    RAN_5G_TDD    SBTS00
...    PY39

Library    taf.collectors.btslog        WITH NAME    btslog
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource
...    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    10765_suite_setup
Suite Teardown    Run Keyword And Ignore Error     robot_common_operations.Common Suite Teardown

*** Variables ***
${xpath}    Envelope/Body/modifyParameterReq
${attribute_name}    distName
${mrbts_id}    ${tl.gnbs[0].global_bts_id}
${nrbts_id}    ${tl.gnbs[0].instance_id}
${oam_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${oam_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${oam_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

*** Test Cases ***
[1][1.0] CB010765-SR-A_2_gainCorrection_of_UL_scaling_for_prach_scs_30kHz
    [Tags]    CRT_UTE
    Case prepare    pci_used=53    pci_locked=54
    ${Puxh_gain_53}    ${Srs_gain_53}    ${Prach_gain_53}
    ...    get_nr_gain_value_from_btslog    btslog_path=${btslog_path}    cell_id=${pci_used}
    ${soaplog_path_ru1}    Capture soap startup log from ru    ru_index=1
	set suite variable    ${soaplog_path_ru1}
	${puxh_gain_ru_53}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru1}    pci=${pci_used}    attr=puxh
	${srs_gain_ru_53}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru1}    pci=${pci_used}    attr=srs
    ${prach_gain_ru_53}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru1}    pci=${pci_used}    attr=prach
	AlarmWatchdog.add_allow_alarms    fault_id=49
    Block cell with admin    cell_name=${locked_cell_name}
    Peak throughput test    pci=${pci_used}    ue_index=${tput_cell['ue_index']}    dl_tp=${tput_cell['dl_tp']}
    ...    dl_exp=${tput_cell['dl_exp']}    ul_tp=${tput_cell['ul_tp']}    ul_exp=${tput_cell['ul_exp']}
	${gain_btslog_values_53}    create list    ${Puxh_gain_53}    ${Srs_gain_53}    ${Prach_gain_53}
	${gain_rulog_values_53}    create list    ${puxh_gain_ru_53}    ${srs_gain_ru_53}    ${prach_gain_ru_53}
	${gain_btslog_exp_53}    create list    ${l1_gain_exp_cell['puxh']}    ${l1_gain_exp_cell['srs']}    ${l1_gain_exp_cell['prach']}
	${gain_rulog_exp_53}    create list    ${ru_gain_exp_cell['puxh']}    ${ru_gain_exp_cell['srs']}    ${ru_gain_exp_cell['prach']}
	check_gain_value_as_expected    get_values=${gain_btslog_values_53}    exp_values=${gain_btslog_exp_53}
	check_gain_value_as_expected    get_values=${gain_rulog_values_53}    exp_values=${gain_rulog_exp_53}
    [Teardown]    run keywords    Unblock Cell and verify cell onair    cell_name=${locked_cell_name}
	...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=49
    ...    AND    case_common_teardown

[1][1.0] CB010765-SR-A_3_gainCorrection_of_UL_scaling_for_puxch_scs_30kHz
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [1][1.0] CB010765-SR-A_2_gainCorrection_of_UL_scaling_for_prach_scs_30kHz
    [Teardown]    case_common_teardown

[1][1.0] CB010765-SR-A_4_gainCorrection_of_UL_scaling_for_srs_scs_30kHz_with_DFT_beam
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [1][1.0] CB010765-SR-A_2_gainCorrection_of_UL_scaling_for_prach_scs_30kHz
    [Teardown]    case_common_teardown

[1][1.0] CB010765-SR-B_1_gainCorrection_of_UL_scaling_for_prach_scs_1.25kHz
    [Tags]    CRT_UTE
    Case prepare    pci_used=158    pci_locked=159
    ${PuxSrs_gain_158}    ${Prach_gain_158}
    ...    get_lte_gain_value_from_btslog    btslog_path=${btslog_path}    cell_id=${pci_used}
	${puxh_gain_ru_158}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru1}    pci=${pci_used}    attr=puxh
	${srs_gain_ru_158}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru1}    pci=${pci_used}    attr=srs
    ${prach_gain_ru_158}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru1}    pci=${pci_used}    attr=prach
	AlarmWatchdog.add_allow_alarms    fault_id=49
    Block cell with admin    cell_name=${locked_cell_name}
    CPE peak throughput test    pci=${pci_used}    ue_index=${tput_cell['ue_index']}    dl_tp=${tput_cell['dl_tp']}
    ...    dl_exp=${tput_cell['dl_exp']}    ul_tp=${tput_cell['ul_tp']}    ul_exp=${tput_cell['ul_exp']}
	${gain_btslog_values_158}    create list    ${PuxSrs_gain_158}    ${PuxSrs_gain_158}    ${Prach_gain_158}
	${gain_rulog_values_158}    create list    ${puxh_gain_ru_158}    ${srs_gain_ru_158}    ${prach_gain_ru_158}
	${gain_btslog_exp_158}    create list    ${l1_gain_exp_cell['puxh']}    ${l1_gain_exp_cell['srs']}    ${l1_gain_exp_cell['prach']}
	${gain_rulog_exp_158}    create list    ${ru_gain_exp_cell['puxh']}    ${ru_gain_exp_cell['srs']}    ${ru_gain_exp_cell['prach']}
	check_gain_value_as_expected    get_values=${gain_btslog_values_158}    exp_values=${gain_btslog_exp_158}
	check_gain_value_as_expected    get_values=${gain_rulog_values_158}    exp_values=${gain_rulog_exp_158}
    [Teardown]    run keywords    Unblock Cell and verify cell onair    cell_name=${locked_cell_name}
	...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=49
    ...    AND    case_common_teardown

[1][1.0] CB010765-SR-B_2_gainCorrection_of_UL_scaling_for_puxch_scs_15kHz
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [1][1.0] CB010765-SR-B_1_gainCorrection_of_UL_scaling_for_prach_scs_1.25kHz
    [Teardown]    case_common_teardown

[1][1.0] CB010765-SR-B_3_gainCorrection_of_UL_scaling_for_srs_scs_15kHz
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [1][1.0] CB010765-SR-B_1_gainCorrection_of_UL_scaling_for_prach_scs_1.25kHz
    [Teardown]    case_common_teardown

[2][1.0] CB010765-SR-A_2_gainCorrection_of_UL_scaling_for_prach_scs_30kHz
    [Tags]    CRT_UTE
    Case prepare    pci_used=54    pci_locked=53
    ${Puxh_gain_54}    ${Srs_gain_54}    ${Prach_gain_54}
    ...    get_nr_gain_value_from_btslog    btslog_path=${btslog_path}    cell_id=${pci_used}
    ${soaplog_path_ru2}    Capture soap startup log from ru    ru_index=2
	set suite variable    ${soaplog_path_ru2}
	${puxh_gain_ru_54}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru2}    pci=${pci_used}    attr=puxh
	${srs_gain_ru_54}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru2}    pci=${pci_used}    attr=srs
    ${prach_gain_ru_54}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru2}    pci=${pci_used}    attr=prach
	AlarmWatchdog.add_allow_alarms    fault_id=49
    Block cell with admin    cell_name=${locked_cell_name}
    Peak throughput test    pci=${pci_used}    ue_index=${tput_cell['ue_index']}    dl_tp=${tput_cell['dl_tp']}
    ...    dl_exp=${tput_cell['dl_exp']}    ul_tp=${tput_cell['ul_tp']}    ul_exp=${tput_cell['ul_exp']}
	${gain_btslog_values_54}    create list    ${Puxh_gain_54}    ${Srs_gain_54}    ${Prach_gain_54}
	${gain_rulog_values_54}    create list    ${puxh_gain_ru_54}    ${srs_gain_ru_54}    ${prach_gain_ru_54}
	${gain_btslog_exp_54}    create list    ${l1_gain_exp_cell['puxh']}    ${l1_gain_exp_cell['srs']}    ${l1_gain_exp_cell['prach']}
	${gain_rulog_exp_54}    create list    ${ru_gain_exp_cell['puxh']}    ${ru_gain_exp_cell['srs']}    ${ru_gain_exp_cell['prach']}
	check_gain_value_as_expected    get_values=${gain_btslog_values_54}    exp_values=${gain_btslog_exp_54}
	check_gain_value_as_expected    get_values=${gain_rulog_values_54}    exp_values=${gain_rulog_exp_54}
    [Teardown]    run keywords    Unblock Cell and verify cell onair    cell_name=${locked_cell_name}
	...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=49
    ...    AND    case_common_teardown

[2][1.0] CB010765-SR-A_3_gainCorrection_of_UL_scaling_for_puxch_scs_30kHz
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [2][1.0] CB010765-SR-A_2_gainCorrection_of_UL_scaling_for_prach_scs_30kHz
    [Teardown]    case_common_teardown

[2][1.0] CB010765-SR-A_4_gainCorrection_of_UL_scaling_for_srs_scs_30kHz_with_DFT_beam
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [2][1.0] CB010765-SR-A_2_gainCorrection_of_UL_scaling_for_prach_scs_30kHz
    [Teardown]    case_common_teardown

[2][1.0] CB010765-SR-B_1_gainCorrection_of_UL_scaling_for_prach_scs_1.25kHz
    [Tags]    CRT_UTE
    Case prepare    pci_used=159    pci_locked=158
    ${PuxSrs_gain_159}    ${Prach_gain_159}
    ...    get_lte_gain_value_from_btslog    btslog_path=${btslog_path}    cell_id=${pci_used}
	${puxh_gain_ru_159}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru2}    pci=${pci_used}    attr=puxh
	${srs_gain_ru_159}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru2}    pci=${pci_used}    attr=srs
    ${prach_gain_ru_159}    Get gainCorrection from soaplog    soaplog_path=${soaplog_path_ru2}    pci=${pci_used}    attr=prach
	AlarmWatchdog.add_allow_alarms    fault_id=49
    Block cell with admin    cell_name=${locked_cell_name}
    CPE peak throughput test    pci=${pci_used}    ue_index=${tput_cell['ue_index']}    dl_tp=${tput_cell['dl_tp']}
    ...    dl_exp=${tput_cell['dl_exp']}    ul_tp=${tput_cell['ul_tp']}    ul_exp=${tput_cell['ul_exp']}
	${gain_btslog_values_159}    create list    ${PuxSrs_gain_159}    ${PuxSrs_gain_159}    ${Prach_gain_159}
	${gain_rulog_values_159}    create list    ${puxh_gain_ru_159}    ${srs_gain_ru_159}    ${prach_gain_ru_159}
	${gain_btslog_exp_159}    create list    ${l1_gain_exp_cell['puxh']}    ${l1_gain_exp_cell['srs']}    ${l1_gain_exp_cell['prach']}
	${gain_rulog_exp_159}    create list    ${ru_gain_exp_cell['puxh']}    ${ru_gain_exp_cell['srs']}    ${ru_gain_exp_cell['prach']}
	check_gain_value_as_expected    get_values=${gain_btslog_values_159}    exp_values=${gain_btslog_exp_159}
	check_gain_value_as_expected    get_values=${gain_rulog_values_159}    exp_values=${gain_rulog_exp_159}
    [Teardown]    run keywords    Unblock Cell and verify cell onair    cell_name=${locked_cell_name}
	...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=49
    ...    AND    case_common_teardown

[2][1.0] CB010765-SR-B_2_gainCorrection_of_UL_scaling_for_puxch_scs_15kHz
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [2][1.0] CB010765-SR-B_1_gainCorrection_of_UL_scaling_for_prach_scs_1.25kHz
    [Teardown]    case_common_teardown

[2][1.0] CB010765-SR-B_3_gainCorrection_of_UL_scaling_for_srs_scs_15kHz
    [Tags]    CRT_UTE
    robot_common_operations.Common Case Setup
    log to console    case veryfied in [2][1.0] CB010765-SR-B_1_gainCorrection_of_UL_scaling_for_prach_scs_1.25kHz
    [Teardown]    case_common_teardown

*** Keywords ***
check_gain_value_as_expected
    [Arguments]    ${get_values}    ${exp_values}
	FOR    ${id}    IN RANGE    3
	    Should Be Equal    ${get_values}[${id}]    ${exp_values}[${id}]
    END

get_lte_gain_value_from_btslog
    [Arguments]    ${btslog_path}    ${cell_id}=158
	${cell_filter}    set variable    PHY_UL_CELL_SETUP_REQ_MSG.*phyCellId:${cell_id}
    ${out}     run
    ...    command=cat ${btslog_path}/SYSLOG*.LOG | grep ${cell_filter} -A 200 |grep gainCorrection
    ${output_list}    String.Split String    string=${out}    separator=,
    FOR    ${str}    IN    @{output_list}
        ${is_PuxSrs}    run keyword and return status    should contain    ${str}    PuxSrs
        ${PuxSrs}    run keyword if    ${is_PuxSrs}    String.Split String    string=${str}    separator=:
		${PuxSrs_gain}    set variable if    ${is_PuxSrs}    ${PuxSrs}[-1]
        Exit For Loop If    ${is_PuxSrs}
    END
	log to console    PuxSrs_gain: ${PuxSrs_gain}
    FOR    ${str}    IN    @{output_list}
        ${prachcheck}    ${prachrc}    Run Keyword And Ignore Error    Should Match Regexp    ${str}    ^Prach:\\d+\\)\\.
        ${Prach}    run keyword if    '${prachcheck}' == 'PASS'    String.Split String    string=${prachrc}    separator=:
        ${Prach_gain}    run keyword if    '${prachcheck}' == 'PASS'    Remove String    ${Prach}[-1]    )    .
        Exit For Loop If    '${prachcheck}' == 'PASS'
    END
	log to console    Prach_gain:${Prach_gain}
	[Return]    ${PuxSrs_gain}    ${Prach_gain}

get_nr_gain_value_from_btslog
    [Arguments]    ${btslog_path}    ${cell_id}=53
	${cell_filter}    set variable    UlCell_SetupReq.*physCellId:${cell_id}
    ${output}    Run
    ...    command=cat ${btslog_path}/SYSLOG*.LOG | grep ${cell_filter}
    ${output_list}    String.Split String    string=${output}    separator=,
    FOR    ${str}    IN    @{output_list}
        ${is_Puxh}    run keyword and return status    should contain    ${str}    gainCorr:
        ${Puxh}    run keyword if    ${is_Puxh}    String.Split String    string=${str}    separator=:
		${Puxh_gain}    set variable if    ${is_Puxh}    ${Puxh}[-1]
        Exit For Loop If    ${is_Puxh}
    END
	log to console    Puxh_gain: ${Puxh_gain}
    FOR    ${str}    IN    @{output_list}
        ${is_Srs}    run keyword and return status    should contain    ${str}    gainCorrForNdmSrs:
        ${Srs}    run keyword if    ${is_Srs}    String.Split String    string=${str}    separator=:
		${Srs_gain}    set variable if    ${is_Srs}    ${Srs}[-1]
        Exit For Loop If    ${is_Srs}
    END
	log to console    Srs_gain: ${Srs_gain}
    FOR    ${str}    IN    @{output_list}
        ${is_Prach}    run keyword and return status    should contain    ${str}    gainCorrForPrach:
        ${Prach}    run keyword if    ${is_Prach}    String.Split String    string=${str}    separator=:
		${Prach_gain}    set variable if    ${is_Prach}    ${Prach}[-1]
        Exit For Loop If    ${is_Prach}
    END
	log to console    Prach_gain: ${Prach_gain}
    [Return]    ${Puxh_gain}    ${Srs_gain}    ${Prach_gain}

10765_suite_setup
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    set suite variable    ${swconfig_path}     commissionings/HGZ/${testline}
    Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline}/TLConfiguration.py
    ${btslog_path}    Capture cell setup btslog from local
    set suite variable    ${btslog_path}

Case prepare
    [Arguments]    ${pci_used}    ${pci_locked}
    robot_common_operations.Common Case Setup
	set test variable    ${pci_used}
    set test variable    ${tput_cell}    ${tput_define[${pci_used}]}
    log to console    \ncell ${pci_used} tput info: ${tput_cell}
    ${cell_name}    set variable    ${cell_mapping[${pci_locked}]}
    ${is_lte}    run keyword and return status    should contain    ${cell_name}    LNCEL
    set test variable    ${is_lte}
    ${locked_cell_name}    set variable if    ${is_lte}    MRBTS-${mrbts_id}/LNBTS-${nrbts_id}/${cell_name}
    ...    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/${cell_name}
    set test variable    ${locked_cell_name}
    set test variable    ${l1_gain_exp_cell}    ${l1_gain_exp[${pci_used}]}
    log to console    \ncell ${pci_used} l1 gain exp info: ${l1_gain_exp_cell}
    set test variable    ${ru_gain_exp_cell}    ${ru_gain_exp[${pci_used}]}
    log to console    \ncell ${pci_used} ru gain exp info: ${ru_gain_exp_cell}

Capture soap startup log from ru
    [Arguments]    ${ru_index}
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${soaplog_path}    Wait Until Keyword Succeeds  3x  10s  parse_soap.Getallsoapfiles    connection=RU_${ru_index}
    ...    local_dir=/tmp    subdir=UnitOAM_SOAP_Startup_LBTS*
    [Return]    ${soaplog_path}
    [Teardown]    COAM Teardown gnb connections

Get gainCorrection from soaplog
    [Arguments]    ${soaplog_path}    ${pci}    ${attr}
    ${attribute_cell}    set variable    ${ru_gain[${pci}]}
    ${soap_info}    soap.Parse Soap Log Return Dict    log_path=${soaplog_path}    attribute_name=${attribute_name}
    ...    attribute_value=${attribute_cell}[${attr}]    msg_type_xpath=${xpath}
    ${gain_value}    set variable    ${soap_info}[gainCorrection]
    sleep    10s
    log to console    \n${attr} gain value in soaplog is: ${gain_value}
    [Return]    ${gain_value}

Capture cell setup btslog from local
    [Arguments]    ${btslog_names}=CB10765btslog    ${btslog_target_dir}=/tmp
    Upload swconfig for btslog capture
    Connect to gnb coam via ssl
    log to console    \nreset site
    coam.reset site    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    wait until keyword succeeds    5min    10s    Connect to gnb coam via ssl
    btslog.Start Btslog Collect    btslog_dir=/opt/btslog    names=${btslog_names}
    wait until keyword succeeds    5min    10s    Verify all cells should be onair    cell_type=nr
    wait until keyword succeeds    1min    10s    Verify all cells should be onair    cell_type=lte
    btslog.Stop Btslog Collect    target_dir=${btslog_target_dir}    names=${btslog_names}
    ${btslog_path}       Join Path    ${btslog_target_dir}    ${btslog_names}
    Run    command=tar zxvf ${btslog_path}/syslog_files.tgz -C ${btslog_path}/
    [Return]    ${btslog_path}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Upload swconfig for btslog capture
    csn.connect to    hostname=${oam_ip}    username=${oam_username}    password=${oam_password}    alias=DU
    csn.Upload File  local_path=${swconfig_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=DU
    csn.execute    command=crasign /ffs/run/swconfig.txt    connection=DU
    sleep    5s
    [Teardown]    Run Keyword And Ignore Error    csn.Disconnect    connection=DU

Block cell with admin
    [Arguments]    ${cell_name}
    Log To Console    \nCell ${cell_name} Locked
    Connect to gnb coam via ssl
    coam.Block Cell    dist_name=${cell_name}    connection=GNB_OAM
    Sleep    30s
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Unblock Cell and verify cell onair
    [Arguments]    ${cell_name}
    Log To Console    Cell ${cell_name} Unlocked
    Connect to gnb coam via ssl
    coam.UnBlock Cell    dist_name=${cell_name}    connection=GNB_OAM
    wait until keyword succeeds    5min    10s    Verify all cells should be onair    cell_type=nr
    wait until keyword succeeds    1min    10s    Verify all cells should be onair    cell_type=lte
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

CPE peak throughput test
    [Arguments]    ${pci}    ${ue_index}    ${dl_tp}    ${dl_exp}    ${ul_tp}    ${ul_exp}
    CPE prepare    ue_index=${ue_index}
    CPE attach and verify    pci=${pci}    ue_index=${ue_index}
    CPE start dl ul traffic    ue_index=${ue_index}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    CPE collect tput
    CPE stop dl ul traffic    ue_index=${ue_index}
    CPE verify throughput    ue_index=${ue_index}    dl_exp=${dl_exp}    ul_exp=${ul_exp}
    [Teardown]    Call Teardown    ue_index=${ue_index}

CPE prepare
    [Arguments]  ${ue_index}
    log to console    \nPrepare UE
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}

CPE attach and verify
    [Arguments]  ${ue_index}    ${pci}
    log to console    \nAttach UE
    ${5Grach_ed_0}    power_ue.UE Attach
    ...    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Iperf    pci=${pci}
    sleep    6s

CPE detach
    [Arguments]  ${ue_index}
    log to console    \nDetach UE
    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

CPE start dl ul traffic
    [Arguments]  ${ue_index}    ${dl_tp}=20    ${ul_tp}=10    ${duration}=${3600}    ${protocol}=udp
    log to console    \nUe Start DL UL Traffic
    ${ul_process_num}    set variable if    ${is_lte}   1    5
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}    process_num=${ul_process_num}

CPE stop dl ul traffic
    [Arguments]    ${ue_index}    ${protocol}=udp
    log to console    \nUe Stop DL UL Traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    protocol=${protocol}

CPE collect tput
    [Arguments]    ${duration}=30    ${ignore_time}=10    ${check_source}=Iperf
    log to console    \nCollect Tput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    check_source=${check_source}    duration=${duration}
    ...    ignore_time=${ignore_time}
    [Return]  ${log_path}

CPE verify throughput
    [Arguments]  ${ue_index}    ${dl_exp}=1    ${ul_exp}=1    ${target_avg_percent}=0.80    ${min_percent}=0.60
    ...    ${log}=${TS_CASE_LOG_PATH}    ${check_source}=Iperf
    log to console    \nUE Verify Peak Throughput
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=dl    target_throughput=${dl_exp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=ul    target_throughput=${ul_exp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}

Peak throughput test
    [Arguments]    ${pci}    ${ue_index}    ${dl_tp}    ${dl_exp}    ${ul_tp}    ${ul_exp}
    ${cells}    Create List    ${tput_cell['cell_id']}
    CPE prepare    ue_index=${ue_index}
    CPE attach and verify    pci=${pci}    ue_index=${ue_index}
    CPE start dl ul traffic    ue_index=${ue_index}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=30s    ignore_time=10s    check_source=Aasyslog
    ${all_tp}    power_ue.Check Bi Tput    ue_index=${ue_index}    ue_type=${ue_type}    log=${log}    cells=${cells}
    ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}    check_source=Aasyslog
    [Teardown]    Call Teardown    ue_index=${ue_index}

Call Teardown
    [Arguments]    ${ue_index}
    Run Keyword And Ignore Error    CPE stop dl ul traffic    ue_index=${ue_index}
    Run Keyword And Ignore Error    CPE detach    ue_index=${ue_index}

case_common_teardown
    robot_common_operations.Common Case Teardown
	CI interface.Common Case Teardown