*** Settings ***
Force Tags    PY36     RAN_5G_FDD    SBTS00     CRT_TRUNK      CRT_23R3

Documentation    8941
...              Author:
...              Contact:


Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/wireshark_for_5gClassicalBTS.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables   ${CURDIR}/Configuration/8941_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008680/keywords_8680.robot

Suite Setup    Run Keywords    CI_interface.Common Suite Setup
...    AND    robot_common_operations.Common Suite Setup

Suite Teardown   Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup       robot_common_operations.Common Case Setup
Test Teardown    Run Keywords      robot_common_operations.Common Case Teardown

*** Variables ***
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}            ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}            ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PA1_INFO}                 ${tl.attenuators[0]}
${ALIAS_ASIK}               asik
${ue_type}       samsung
${SWCONFIG_DEFAULT_FILE_PATH}       ${CURDIR}/Configuration/swconfig_base.txt
#${ue_index}   2
${ue_index}   1

${TS_LOG_PATH_BASE}    ${output_dir}

${mrbtsID}      ${tl.gnbs[0].instance_id}
${nrbtsID}      ${tl.gnbs[0].global_bts_id}
${cell_index}        1
${connection}        GNB_OAM

*** Test Cases ***
#[1]CB008941_5G_004_Deactivation_of_Uplink_UP_dynamic_fragmentation_on_eCPRI_TDD_FR1_FD-Beamforming_RU
#   [Tags]  8941_004
#   @{list}=  Create list     0x190297=1   0x600012=1    0x59012C=1    0x190305=0   0x190306=1     0x600018=0   0x600017=1
#   update swconfig    list=${list}    connection=${connection}
#
#   ${add_str}    Convert To String    ${delta_8941_001}
#   ${add_str}   Set Variable   ${add_str.replace("'","\"")}
#   run keyword and ignore error    SCF delta recommission       delta_file=${add_str}
#   ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#   power_ue.Prepare UE    ue_type=${ue_type}
#   ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
#   power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
#   power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100M    duration=1600
#   power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M    duration=1600    iperf_type=via_command
#   sleep   20s
#   #${list_of_cell_ids}    Create List   179568641
#   ${result}    Get NRCellIdentity And Cell Index Mapping    connection=GNB_OAM
#   ${list_of_cell_ids}     Create List    ${result[1]}
#   power_ue.Check throughput    ue_type=${ue_type}       direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
#   power_ue.Check throughput    ue_type=${ue_type}       direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}
#   sleep   300s
#   power_ue.Check throughput    ue_type=${ue_type}        direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
#   power_ue.Check throughput    ue_type=${ue_type}        direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}
#
#   power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#   power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_type=via_command
#   power_ue.UE Detach    ue_type=${ue_type}
#
#   #recover swconfig
#   @{list}=  Create list
#   update swconfig    list=${list}         connection=${connection}
#
#   [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
#   ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
#   ...    power_ue.UE Detach    ue_type=${ue_type}


[1]CB008941_5G_003_FCP_Message_Activation_of_Uplink_UP_dynamic_fragmentation_Beamforming
    [Tags]  8941_003

    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    @{list}=  Create list   0x5901C9=1   0x5901CA=1   0x190297=1   0x600012=1    0x59012C=1   0x190305=1   0x190306=1
    ...    0x10040=1   0x10041=5
	update swconfig    list=${list}    connection=${connection}

    ${add_str}    Convert To String    ${delta_8941_001}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    coam.reset_site   timeout=300  connection=${connection}
    sleep   20s

    @{traces}    create list   condor5gSyslog
    run keyword and continue on failure    DCAP.Start_Collect_Trace   GNBtraces=${traces}    BTStraces=['immediateSnapshot']
    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
    run keyword and continue on failure       Stop_Collect_Trace_and_Get_Result_test
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=syslog
    verify 8941 DCAP syslog
    8941_teardown

    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    coam.reset_site   timeout=300  connection=${connection}
    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
    8941_teardown

    Barred nr cell
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100M    duration=1600
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M    duration=1600   iperf_type=via_command
    sleep   20s
    #1914
    #${list_of_cell_ids}    Create List   179568641
    #1913
#    ${list_of_cell_ids}    Create List   168722433
#    ${list_of_cell_ids}    Create List   316145975
    ${result}    Get NRCellIdentity And Cell Index Mapping    connection=GNB_OAM
    ${list_of_cell_ids}     Create List    ${result[1]}

    power_ue.Check throughput    ue_type=${ue_type}       direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
    power_ue.Check throughput    ue_type=${ue_type}       direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}
    sleep   300s
    power_ue.Check throughput    ue_type=${ue_type}        direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
    power_ue.Check throughput    ue_type=${ue_type}        direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}

    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul      iperf_type=via_command
    power_ue.UE Detach    ue_type=${ue_type}
    Unbarred nr cell

    #recover swconfig
    @{list}=  Create list
    update swconfig    list=${list}         connection=${connection}

    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
#    ...    power_ue.UE Detach    ue_type=${ue_type}



[1]CB008941_5G_002_Activation_of_Uplink_UP_dynamic_fragmentation_Beamforming_CB007449_is_disabled
    [Tags]  8941_002
    @{list}=  Create list   0x5901C9=1   0x5901CA=1   0x190297=1   0x600012=1   0x59012C=1    0x190305=1   0x190306=1
    update swconfig    list=${list}    connection=${connection}

    ${add_str}    Convert To String    ${delta_8941_002}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}
    Barred nr cell
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100M    duration=1600
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M    duration=1600   iperf_type=via_command
    sleep   20s
    #${list_of_cell_ids}    Create List   179568641
    ${result}    Get NRCellIdentity And Cell Index Mapping    connection=GNB_OAM
    ${list_of_cell_ids}     Create List    ${result[1]}
    power_ue.Check throughput    ue_type=${ue_type}       direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
    power_ue.Check throughput    ue_type=${ue_type}       direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}
    sleep   300s
    power_ue.Check throughput    ue_type=${ue_type}        direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
    power_ue.Check throughput    ue_type=${ue_type}        direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}

    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul      iperf_type=via_command
    power_ue.UE Detach    ue_type=${ue_type}
    Unbarred nr cell

    #recover swconfig
    @{list}=  Create list
    update swconfig    list=${list}         connection=${connection}

    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}


#[1]CB008941_5G_001_Activation_of_Uplink_UP_dynamic_fragmentation_on_Ecpri_TDD_FR1_FD-Beamforming_RU
#    [Tags]  8941_001
#    @{list}=  Create list   0x5901C9=1   0x5901CA=1   0x190297=1   0x600012=1    0x59012C=1    0x190305=1   0x190306=1
#    update swconfig    list=${list}    connection=${connection}
#
#    ${add_str}    Convert To String    ${delta_8941_001}
#    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
#    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    power_ue.Prepare UE    ue_type=${ue_type}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
#    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100M    duration=1600
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M    duration=1600    iperf_type=via_command
#    sleep   20s
#    #1914
#    #${list_of_cell_ids}    Create List   179568641
#    #1913
#    #${list_of_cell_ids}    Create List   168722433
#    ${result}    Get NRCellIdentity And Cell Index Mapping    connection=GNB_OAM
#    ${list_of_cell_ids}     Create List    ${result[1]}
#    power_ue.Check throughput    ue_type=${ue_type}       direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
#    power_ue.Check throughput    ue_type=${ue_type}       direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}
#    sleep   300s
#    power_ue.Check throughput    ue_type=${ue_type}        direction=dl    throughput=50   cellid=${list_of_cell_ids[0]}
#    power_ue.Check throughput    ue_type=${ue_type}        direction=ul    throughput=50   cellid=${list_of_cell_ids[0]}
#
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_type=via_command
#    power_ue.UE Detach    ue_type=${ue_type}
#
#    #recover swconfig
#    @{list}=  Create list
#    update swconfig    list=${list}         connection=${connection}
#
#    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
#    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
#    ...    power_ue.UE Detach    ue_type=${ue_type}


[1]CB008941_5G_008_Deactivation_of_DL_UP_dynamic_fragmentation_on_eCPRI_TDD_FR1_FD-Beamforming_RU
    [Tags]  8941_008
    @{list}=  Create list     0x190297=1   0x600012=1    0x190305=1   0x190306=1   0x600018=1   0x600017=0
#    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
#    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
#    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    update swconfig    list=${list}    connection=${connection}

#    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=ASIK Master
#    log to console    \n ${swconfig_output}
#    coam.reset_site    timeout=360s   connection=${connection}
#    sleep    360s      reason=wait for site reset
#    wait until keyword succeeds    1800      10    COAM Check All Cells Onair    connection=${connection}

    ${add_str}    Convert To String    ${delta_8941}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}
    Barred nr cell
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=50M    duration=1600
    sleep   20s
    #${list_of_cell_ids}    Create List   168722433
    ${result}    Get NRCellIdentity And Cell Index Mapping    connection=GNB_OAM
    ${list_of_cell_ids}     Create List    ${result[1]}
    power_ue.Check throughput    ue_type=${ue_type}       direction=dl    throughput=20   cellid=${list_of_cell_ids[0]}
    sleep   300s
    power_ue.Check throughput    ue_type=${ue_type}        direction=dl    throughput=20   cellid=${list_of_cell_ids[0]}

    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.UE Detach    ue_type=${ue_type}
    Unbarred nr cell

    #recover swconfig
    @{list}=  Create list
#    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
#    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
#    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    update swconfig    list=${list}         connection=${connection}

#    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=ASIK Master
#    log to console    \n ${swconfig_output}
#    coam.reset_site    timeout=360s   connection=${connection}
#    sleep    360s      reason=wait for site reset
#    wait until keyword succeeds    1800      10    COAM Check All Cells Onair    connection=${connection}

    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}


#[1]CB008941_5G_006_Activation_of_DL_UP_dynamic_fragmentation_on_eCPRI_TDD_FR1_FD-Beamforming_RU
#    [Tags]  8941_006
#    @{list}=  Create list   0x5901C9=1   0x5901CA=1   0x190297=1   0x600012=1   0x190305=1   0x190306=1
#    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
#    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
#    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
#    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=ASIK Master
#    log to console    \n ${swconfig_output}
#    coam.reset_site    timeout=360s   connection=${connection}
#    sleep    360s      reason=wait for site reset
#    wait until keyword succeeds    1800      10    COAM Check All Cells Onair    connection=${connection}
#    ${add_str}    Convert To String    ${delta_8941}
#    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
#    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    power_ue.Prepare UE    ue_type=${ue_type}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
#    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=50M    duration=1600
#    sleep   20s
#    #${list_of_cell_ids}    Create List   179568641
#    ${result}    Get NRCellIdentity And Cell Index Mapping    connection=GNB_OAM
#    ${list_of_cell_ids}     Create List    ${result[1]}
#    power_ue.Check throughput    ue_type=${ue_type}       direction=dl    throughput=20   cellid=${list_of_cell_ids[0]}
#    sleep   300s
#    power_ue.Check throughput    ue_type=${ue_type}        direction=dl    throughput=20   cellid=${list_of_cell_ids[0]}
#
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#    power_ue.UE Detach    ue_type=${ue_type}
#    #recover swconfig
#    @{list}=  Create list
#    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
#    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
#    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
#    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=ASIK Master
#    log to console    \n ${swconfig_output}
#    coam.reset_site    timeout=360s   connection=${connection}
#    sleep    360s      reason=wait for site reset
#    wait until keyword succeeds    1800      10    COAM Check All Cells Onair    connection=${connection}
#
#
#    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
#    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
#    ...    power_ue.UE Detach    ue_type=${ue_type}

*** Keywords ***
Preparation with swconfig modification
    [Documentation]  Author: Ding Binmei
    ...              Description: Do modification for swconfig file and scf file.
    ...              ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
    ...                                 ['0x580002=0', '0x580121=0']
    ...              ${SWCONFIG_DEFAULT_FILE_PATH}: refers to the template swconfig file path in test pc,
    ...                                             should be defined before calling this keyword
    [Arguments]    ${swconfig_modify}=${None}   ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    ...            ${is_called_in_test_case_level}=${False}
    ...            ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
    log to console      ${connection}
    COAM Create log directory    is_set_to_test_case_level=${is_called_in_test_case_level}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${local_log_file_folder}/swconfig.txt
    Run keyword if    ${swconfig_modify}!=${None}
    ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    ...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}

SCF delta recommission
    [Arguments]    ${delta_file}
    coam_gnb_classical.Connect to gnb coam via ssl
    run keyword and ignore error     csn.disconnect    connection=ASIK Master
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...                                   skip_parameter_relation_errors=${true}
    ...                                   should_activate=${true}
    ...                                   timeout=${600}
    ...                                   connection=GNB_OAM
    wait until keyword succeeds    1200      10    COAM Check All Cells Onair     connection=GNB_OAM
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM


update swconfig
    [Arguments]    ${list}   ${connection}=GNB_OAM   ${reset_sleep}=360s
    log to console          ${reset_sleep}
    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=ASIK Master
    log to console    \n ${swconfig_output}
    coam.reset_site    timeout=360s   connection=${connection}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}


Stop_Collect_Trace_and_Get_Result_test
    [Arguments]   ${timeout}=3min
    [Documentation]  Stop tracing, delete to traces to save server space, then remove the bts from the dcapserver.
    ...     return: path of downloaded trace file in zip format, and the content in the zip file.
    Log to console   Stop collecting dcap log.
    rd.stop_trace
    sleep    ${timeout}
    ${trace_file_path}    rd.get_results  target_dir=${LOG_PATH}
    ${trace_content}    rd.get_result_file_contents
    ${trace_r_content}  Convert To String  ${trace_content}
    set test variable   ${trace_file_path}
    Create File  ${LOG_PATH}/tmp.txt  ${trace_r_content}
    ${trace_result}  OperatingSystem.Run    sed "s/\'/\\"/g" ${LOG_PATH}/tmp.txt
    ${trace_result1}  Convert To String  ${trace_result}
    Create File  ${LOG_PATH}/content.txt  ${trace_result1}
    set test variable   ${trace_result_content}    ${LOG_PATH}/content.txt
    rd.delete_trace
    rd.delete_bts
    [Return]  ${trace_file_path}  ${trace_result_content}


8941_teardown
    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
#    ...    power_ue.UE Detach    ue_type=${ue_type}


verify 8941 DCAP syslog
    [Arguments]  ${log_files}=${all_log_file_paths}  ${log_path}=${extract_log_path}  ${Fragmentation_enabled_Ul_exp}=${2}
	...          ${Fragmentation_enabled_Dl_exp}=${2}
    ${ulSum}    Set Variable      ${0}
    ${dlSum}    Set Variable      ${0}
    FOR    ${item}    IN     @{log_files}
        ${ultmp}     run    command=cat ${log_path}/${item} |grep "Fragmentation enabled \\[Ul\\] = 1"|wc -l
        ${dltmp}     run    command=cat ${log_path}/${item} |grep "Fragmentation enabled \\[Dl\\] = 1"|wc -l
        ${ulSum}                Evaluate             ${ulSum}+${ultmp}
        ${dlSum}                Evaluate             ${dlSum}+${dltmp}
    END
    ${check_result}  Set Variable If  '${ulSum}'=='${Fragmentation_enabled_Ul_exp}' and '${dlSum}'=='${Fragmentation_enabled_Dl_exp}' True  False
    Run Keyword If    ${check_result} == ${False}    FAIL


Get NRCellIdentity And Cell Index Mapping
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               ${result} : e.g. {1: {'nrCellIdentity': 1249, 'cell_group_id': 0, 'physicalCellId': 60},
    ...                                 2: {'nrCellIdentity': 1250, 'cell_group_id': 1, 'physicalCellId': 61}}
    ...               Return ${nrCellIdentity_mapping}: e.g. {1:1249,2:1250}
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${result}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${keys}     Get Dictionary Keys    ${result}
    ${nrCellIdentity_mapping}    Create Dictionary
    FOR   ${key}   IN    @{keys}
        ${item}    Set Variable    ${result}[${key}]
        Set To Dictionary    ${nrCellIdentity_mapping}     ${key}   ${item['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity_mapping}
    [Teardown]    coam.teardown    connection=${connection}
