*** Settings ***
Documentation
...    Author: zhichao shu
...    Contact: zhichao.shu@nokia-sbell.com
...    squad group:Mmw_SG04
...    Feature Owner: Shu Zhichao
...    Feature: CB012611
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
#Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011092_A_C/Resources/CB011092_TL715_common_keywords.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011092_A_C/Resources/CB011092_TL715_common_keywords.py
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/UUF_LogCollection.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Config/UUF_Vars.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${gnb_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_ssh_name}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_pass}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
@{NR_cell_id_list_1}    600481
@{NR_cell_id_list_2}    600482
@{NR_cell_id_list_3}    600483
@{ru_index_list}        4    5    6
${connection}=          GNB_OAM
@{cell_id_list_3CC}     1    2    3
${PB_IP_GNB}            ${tl.attenuator.addr}
${PB_PORT_GNB}          ${tl.attenuator.port_numbers[4]}
@{cell_list_G}          1    2   3
@{cell_empty_list}
${testline_name}
${eNB_OAM_IP}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_BTS_ID}           7012
${ALIAS_ABIO}           abio

*** Keywords ***
1supercell_6subcells_Single_loki_permanent_failure_at_runtime
    3Supercell with 2subcell change to 1Supercell with 6subcell
   wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    AlarmWatchdog.add_allow_alarms    fault_id=252
    Trigger single loki power failure    loki_type=A    slot_value=2
    Wait until keyword succeeds    60 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Major
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:1
    Verify bbmod Should Be degraded    bbmod_index=2
    ${cell_list}    Create List    1
    Cell status Should Be Degraded    cell_list=${cell_list}
    UE Start Traffic And Check Tp    ul_throughput=34    dl_throughput=300    ul_list=${NR_cell_id_list_1}
    ...    dl_list=${NR_cell_id_list_1}    ue_index=${0}    target_avg_percent=0.5    log_time=60s
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${False}
#    sleep    10s
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${True}
#    AlarmWatchdog.remove_allow_alarms    fault_id=252
#    COAM Wait gnb And Cells ready    timeout=10 min    gnb_type=${gNb_CuType}
    [Teardown]    COAM Teardown gnb connections    connection=GNB_OAM

3supercell_2subcells_Single_loki_permanent_failure_at_runtime
    AlarmWatchdog.add_allow_alarms    fault_id=252
    Trigger single loki power failure    loki_type=A    slot_value=2
    Wait until keyword succeeds    60 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Critical
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:1
    Verify bbmod Should Be degraded    bbmod_index=2
    ${cell_list}    Create List    1
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list}
    ${cell_list}    Create List    2
    Cell status Should Be Degraded    cell_list=${cell_list}
    ${cell_list}    Create List    3
    ${cell_group_idx}    Set Variable    2
    Cell status Should Be enabled    cell_list=${cell_list}    cell_group_idx=${cell_group_idx}
    ${fault_id}    Create List    49    10
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    @{cell_id_list}    create list    ${3}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=34    dl_throughput=300    ul_list=${NR_cell_id_list_2}
    ...    dl_list=${NR_cell_id_list_2}    ue_index=${0}    target_avg_percent=0.5    log_time=60s
    @{cell_id_list}    create list    ${3}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${False}    bts_host=${gnb_ip}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    sleep    10s
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${False}
#    sleep    10s
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${True}
#    AlarmWatchdog.remove_allow_alarms    fault_id=252
#    COAM Wait gnb And Cells ready    timeout=10 min    gnb_type=${gNb_CuType}
#    [Teardown]    COAM Teardown gnb connections    connection=GNB_OAM

1supercell_6subcells_Single_loki_failed_BTS_startup_with_ABIO
    3Supercell with 2subcell change to 1Supercell with 6subcell
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    AlarmWatchdog.add_allow_alarms    fault_id=252
    Trigger single loki power failure    loki_type=B    slot_value=2
    Wait until keyword succeeds    60 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Major
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:1
    Perform BTS Site Reset
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    Wait until keyword succeeds    10 min    20 sec    Expect Fault Should Present    faultId=252    severity=Minor
    ...    alarmId=7115    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:1
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
    ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-1
    ...    supplementary=Not enough DSP or baseband pool resources for cell detected
    ${cell_list}    Create List    1
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list}
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${False}
#    sleep    10s
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${True}
#    AlarmWatchdog.remove_allow_alarms    fault_id=252
#    AlarmWatchdog.remove_allow_alarms    fault_id=1868
#    COAM Wait gnb And Cells ready    timeout=10 min    gnb_type=${gNb_CuType}
    [Teardown]    COAM Teardown gnb connections    connection=GNB_OAM

2supercell_3subcells_Single_loki_failed_BTS_startup_with_ABIO
    3Supercell with 2subcell change to 2Supercell with 3subcell
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    AlarmWatchdog.add_allow_alarms    fault_id=252
    Trigger single loki power failure    loki_type=A    slot_value=2
    Wait until keyword succeeds    60 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Critical
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:1
    Perform BTS Site Reset
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    Wait until keyword succeeds    10 min    20 sec    Expect Fault Should Present    faultId=252    severity=Minor
    ...    alarmId=7115    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:1
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
    ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-1
    ...    supplementary=Not enough DSP or baseband pool resources for cell detected
    ${cell_list}    Create List    1
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list}
    ${cell_list}    Create List    2
    Wait until keyword succeeds    5 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list}
    FOR    ${ru_index}    IN    @{ru_index_list}
        RU Should Be Online    ${ru_index}    ${connection}
    END
    UE Start Traffic And Check Tp    ul_throughput=34    dl_throughput=300    ul_list=${NR_cell_id_list_2}
    ...    dl_list=${NR_cell_id_list_2}    ue_index=${0}    target_avg_percent=0.5    log_time=60s
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${False}
#    sleep    10s
#    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${True}
#    AlarmWatchdog.remove_allow_alarms    fault_id=252
#    AlarmWatchdog.remove_allow_alarms    fault_id=1868
#    COAM Wait gnb And Cells ready    timeout=10 min    gnb_type=${gNb_CuType}
    [Teardown]    COAM Teardown gnb connections    connection=GNB_OAM

Trigger single loki power failure
    [Arguments]    ${loki_type}=A    ${slot_value}=1
    Connect to Common Unit Master
    log to console     \n trigger single loki ${loki_type} power failure and fault 252 report on BBMOD
    ${loki_value}    Run Keyword If    '${loki_type}' == 'A'    Set Variable    0
    ...    ELSE IF    '${loki_type}' == 'B'    Set Variable    1
    ${slot_value}    Run Keyword If    ${slot_value} == 1    Set Variable    1
    ...    ELSE IF    ${slot_value} == 2    Set Variable    2
    ${cmd_LOKI_Power_Failure}    Set variable    bmutool -s ${slot_value} -r 0x1${loki_value} 0xA0
    ssh.execute    command=${cmd_LOKI_Power_Failure}    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

Trigger recover loki power failure
    Connect to Common Unit Master
    log to console     \n Trigger recover loki power failure
    ${cmd_recover_LOKI_Power_Failure}    Set variable    bmutool -s 2 -r 0x1F 1
    ssh.execute    command=${cmd_recover_LOKI_Power_Failure}    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

Execute recover commands on ABIN/ABIO
    [Arguments]    ${slot_value}=1
    Wait Until Keyword Succeeds    5min    30s    Connect to Common Unit Master
    ${SOCA_HW_ISSUE}    Set Variable
    ...    ddal -s ddal_reset_control DDAL_RESET_CONTROL_SET DDAL_RESET_CONTROL_L1SOCA_HW_ISSUE DDAL_RESET_CONTROL_NO_DEFECT
    ${SOCB_HW_ISSUE}    Set Variable
    ...    ddal -s ddal_reset_control DDAL_RESET_CONTROL_SET DDAL_RESET_CONTROL_L1SOCB_HW_ISSUE DDAL_RESET_CONTROL_NO_DEFECT
    ${L1SOCA_HW_ISSUE}    Set Variable
    ...    ddal -s ddal_reset_control DDAL_RESET_CONTROL_SET DDAL_RESET_CONTROL_L1SOCA_HW_ISSUE_PRESERVE DDAL_RESET_CONTROL_PRESERVE_ON
    ${L1SOCB_HW_ISSUE}    Set Variable
    ...    ddal -s ddal_reset_control DDAL_RESET_CONTROL_SET DDAL_RESET_CONTROL_L1SOCB_HW_ISSUE_PRESERVE DDAL_RESET_CONTROL_PRESERVE_ON
    ssh.Connect to    hostname=fsp${slot_value}s0icom   username=${gNB_ssh_name}    password=${gNB_ssh_pass}   alias=${ALIAS_ABIO}
    ...    proxy=ASIK Master
    ssh.execute
    ...    command=${SOCA_HW_ISSUE}
    ...    connection=${ALIAS_ABIO}
    sleep    1 s
    ssh.execute
    ...    command=${SOCB_HW_ISSUE}
    ...    connection=${ALIAS_ABIO}
    sleep    1 s
    ssh.execute
    ...    command=${L1SOCA_HW_ISSUE}
    ...    connection=${ALIAS_ABIO}
    sleep    1 s
    ssh.execute
    ...    command=${L1SOCB_HW_ISSUE}
    ...    connection=${ALIAS_ABIO}
    log to console     \n recover commands done
    csn.disconnect    connection=${ALIAS_ABIO}
    [Teardown]    csn.disconnect    connection=ASIK Master

Verify bbmod Should Be degraded
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM
    ${result}    get release flag    connection=${connection}
    ${operationalState}   set variable if      ${result}    Enabled    enabled
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['operationalState']}       ${operationalState}
                                  ...  msg=Current BBmod operationalStatus is not in Disabled status
    ${availabilityStatus}   set variable if      ${result}    Degraded    degraded
    Should be equal as strings    ${bbmod_status['status']['availabilityStatus']}     ${availabilityStatus}
                                  ...  msg=Current BBmod availabilityStatus is not in degraded status
#    [Teardown]    COAM Teardown gnb connections    connection=GNB_OAM

Reset BBMOD
    [Arguments]      ${connection}=GNB_OAM
    Log To Console    Reset BBMOD
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    reset_type=Warm    force_radio_reset=${True}
    ...    timeout=600s    connection=${connection}
    sleep    3s

Reset ABIO
    Log To Console    Reset ABIO
    #Selenium Login And Disable Screen Lock
    WEB Login
    selenium_coam.reset_abil    abil_index=2
    [Teardown]    WEB Logout

Cell status Should Be Disabled and AvailabilityStatus Failed
    [Arguments]  ${cell_list}  ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    log to console  \n**Cell status Should Be Disabled***
    ${result}    get release flag    connection=${connection}
    ${operationalState}   set variable if      ${result}    Disabled    disabled
    ${availabilityStatus}   set variable if      ${result}    Failed    failed
    FOR  ${cell_idx}  IN  @{cell_list}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_idx}
        ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
        ...                                      cell_group_idx=${cell_group_idx}
        ...                                      timeout=${timeout}
        ...                                      connection=${connection}
        Should Be Equal As Strings   ${subcell_status["operationalState"]}    ${operationalState}
        Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}    ${availabilityStatus}
    END

3Supercell with 2subcell change to 2Supercell with 3subcell
    [Arguments]    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    \n change supercell
    WEB Login
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-3
        ...    include_subobject=${TRUE}    id_value=${3}
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-5
        ...    include_subobject=${TRUE}    id_value=${5}
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-6
        ...    include_subobject=${TRUE}    id_value=${6}
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-3
    Remove single NRCELL    cell_id=${cell_id_list_3CC}[2]    node_index=2
    ${error}    selenium_sbts.validate_plan
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEB Logout


3Supercell with 2subcell change to 1Supercell with 6subcell
    [Arguments]    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    \n change supercell
    WEB Login
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-3
        ...    include_subobject=${TRUE}    id_value=${3}
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-4
        ...    include_subobject=${TRUE}    id_value=${4}
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-5
        ...    include_subobject=${TRUE}    id_value=${5}
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-6
        ...    include_subobject=${TRUE}    id_value=${6}
    Remove single NRCELL    cell_id=${cell_id_list_3CC}[2]    node_index=2
    Remove single NRCELL    cell_id=${cell_id_list_3CC}[1]    node_index=1
    ${error}    selenium_sbts.validate_plan
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEB Logout


3Supercell with 2subcell change to 1Supercell with 3subcell
    [Arguments]    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    \n change supercell
    WEB Login
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-3
        ...    include_subobject=${TRUE}    id_value=${3}
    Remove single NRCELL    cell_id=${cell_id_list_3CC}[2]    node_index=2
    Remove single NRCELL    cell_id=${cell_id_list_3CC}[1]    node_index=1
    ${error}    selenium_sbts.validate_plan
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEB Logout

Delete Ru config
    WEB Login
    FOR    ${item}    IN RANGE    ${3}
        ${Rmod_id}    Evaluate    ${item}+4
        ${CABLINK_id}    Evaluate    ${item}+7
        selenium_sbts.remove_object    object_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${Rmod_id}
        selenium_sbts.remove_object    object_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-${CABLINK_id}
    END
    ${error}    selenium_sbts.validate_plan
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEB Logout


2supercell_3subcells_Reset_of_ABIO_with_single_failed_Loki
    3Supercell with 2subcell change to 1Supercell with 3subcell
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    Delete Ru config
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    Sleep    5min
    AlarmWatchdog.add_allow_alarms    fault_id=252
    Trigger single loki power failure    loki_type=B    slot_value=2
    Wait until keyword succeeds    60 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Minor
    ...    alarmId=7115    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:1
    Verify bbmod Should Be degraded    bbmod_index=2
    Cell status Should Be enabled    cell_list=${cell_list_G[0:1]}
    Reset BBMOD 5 times B-07
    UE Start Traffic And Check Tp    ul_throughput=34    dl_throughput=300    ul_list=${NR_cell_id_list_1}
    ...    dl_list=${NR_cell_id_list_1}    ue_index=${0}    target_avg_percent=0.5    log_time=60s
    [Teardown]    COAM Teardown gnb connections    connection=GNB_OAM

Reset BBMOD 5 times B-07
    FOR    ${item}    IN RANGE    ${3}
        Reset BBMOD
        Wait until keyword succeeds    60 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Minor
        ...    alarmId=7115    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:1
        Wait until keyword succeeds    8 min    5 sec    Cell status Should Be enabled    cell_list=${cell_list_G[0:1]}
    END


########### [1]CB012611-SR-G-08/02/09_01 case step#################
default SCF 3supercell change to 2supercell
    3Supercell with 2subcell change to 2Supercell with 3subcell
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G

trigger loki-B HW failure by OIP I2C failure
    [Arguments]   ${cell_list_disable}=${cell_list_G[1:2]}    ${cell_list_enable}=${cell_list_G[0:1]}    ${loki_type}=B
    ...    ${supplementary}=SoC_C:3    ${slot_value}=1
    log to console     OIP I2C failure
    Trigger OIP I2C failure    loki_type=${loki_type}    slot_value=${slot_value}
    Wait until keyword succeeds    180 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Critical
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=${supplementary}
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_disable}
    Wait until keyword succeeds    5 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_enable}
    [Teardown]    coam.teardown    connection=GNB_OAM


Reset BBMOD-1 5 times
   [Arguments]   ${cell_list_disable}=${cell_list_G[1:2]}    ${cell_list_enable}=${cell_list_G[0:1]}
   ...    ${connection}=GNB_OAM
   coam.connect_to    bts_host=${gnb_ip}   name=${connection}
   FOR    ${time}    IN RANGE   ${5}
        Reset BBMOD    connection=${connection}
        Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_disable}
        Wait until keyword succeeds    5 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_enable}
   END
   [Teardown]    coam.teardown    connection=${connection}

Reset BBMOD-1 1 time
   [Arguments]   ${cell_list_disable}=${cell_list_G[0:1]}
    coam.connect_to    bts_host=${gnb_ip}   name=${connection}
    Reset BBMOD    connection=${connection}
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_disable}
   [Teardown]    coam.teardown    connection=${connection}

########### [1]CB012611-SR-G-05/02 case step#################
Reset BTS And check cell status
    [Arguments]    ${BTS_IP}=${gnb_ip}    ${connection}=GNB_OAM
    coam.connect_to    bts_host=${BTS_IP}   name=${connection}
    coam.reset_site    connection=GNB_OAM
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=252    severity=Minor
    ...    alarmId=7115    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:3
    Wait until keyword succeeds    15 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_G[2:3]}
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_G[0:2]}
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
    ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-1
    ...    supplementary=Not enough DSP or baseband pool resources for cell detected
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
    ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-2
    ...    supplementary=Not enough DSP or baseband pool resources for cell detected
    [Teardown]    coam.teardown    connection=${connection}


########### Trigger failure keywords#################
Trigger OIP I2C failure
    [Arguments]    ${loki_type}=B    ${slot_value}=1
    Connect to Common Unit Master
    log to console  \n trigger loki OIP I2C failure
    ${loki_value}    Run Keyword If    '${loki_type}' == 'A'    Set Variable    1
    ...    ELSE IF    '${loki_type}' == 'B'    Set Variable    4
    ...    ELSE IF    '${loki_type}' == 'A_HB'    Set Variable    2
    ${slot_value}    Run Keyword If    ${slot_value} == 1    Set Variable    1
    ...    ELSE IF    ${slot_value} == 2    Set Variable    2
    ssh.Connect to    hostname=fsp${slot_value}s0icom   username=${gNB_ssh_name}    password=${gNB_ssh_pass}   alias=${ALIAS_ABIO}
    ...    proxy=ASIK Master
    ssh.execute    command=cd /sys/kernel/debug/oip-3-0054;echo 0x17 > addr
    ...    connection=${ALIAS_ABIO}
    sleep    2s
    ssh.execute    command=cd /sys/kernel/debug/oip-2-0054;echo 0x17 > addr
    ...    connection=${ALIAS_ABIO}
    sleep    3s
    ssh.execute    command=cd /sys/kernel/debug/oip-3-0054;echo ${loki_value} > data
    ...    connection=${ALIAS_ABIO}
    sleep    2s
    ssh.execute    command=cd /sys/kernel/debug/oip-2-0054;echo ${loki_value} > data
    ...    connection=${ALIAS_ABIO}
    csn.disconnect    connection=${ALIAS_ABIO}
    [Teardown]     csn.disconnect    connection=ASIK Master


recovery loki-B HW failure
    Trigger recover loki power failure
    sleep    65s
    Execute recover commands on ABIN/ABIO
    Perform BTS Site Reset
    sleep     60s
    AlarmWatchdog.remove_allow_alarms    fault_id=252
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    COAM Wait gnb And Cells ready    timeout=10 min    gnb_type=${gNb_CuType}


Trigger clock failure
    [Arguments]    ${loki_type}=A    ${slot_value}=1
    Connect to Common Unit Master
    log to console     \n trigger single loki ${loki_type} power failure and fault 252 report on BBMOD
    ${slot_value}    Run Keyword If    ${slot_value} == 1    Set Variable    1
    ...    ELSE IF    ${slot_value} == 2    Set Variable    2
    ${loki_value}    Run Keyword If    '${loki_type}' == 'A'    Set Variable    1
    ...    ELSE IF    '${loki_type}' == 'B'    Set Variable    2
    ssh.Connect to    hostname=fsp${slot_value}s${loki_value}icom    username=${gNB_ssh_name}
    ...    password=${gNB_ssh_pass}   alias=${ALIAS_ABIO}    proxy=ASIK Master
    ssh.execute    command=uboot_env set clktest_soc_sclk=1    connection=${ALIAS_ABIO}
    sleep    5s
    csn.disconnect    connection=${ALIAS_ABIO}
    [Teardown]    csn.disconnect    connection=ASIK Master


Trigger clock failure and check alarm
    [Arguments]    ${cell_list_disable}=${cell_list_G[0:1]}    ${cell_list_enable}=${cell_list_G[1:2]}    ${loki_type}=A
    ...    ${slot_value}=1
    Trigger clock failure    loki_type=${loki_type}    slot_value=${slot_value}
    Reset ABIO
    Wait until keyword succeeds    180 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Critical
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:4
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_disable}
    Wait until keyword succeeds    5 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_enable}

Trigger LOKI B boot failure
    [Arguments]    ${alarmId}=7100    ${severity}=Critical    ${slot_value}=1   ${loki_value}=2
    Connect to Common Unit Master
    log to console     \n trigger single loki power failure and fault 252 report on BBMOD
#    ${loki_value}    Run Keyword If    '${loki_type}' == 'A'    Set Variable    1:1
#    ...    ELSE IF    '${loki_type}' == 'B'    Set Variable    1:2
    ssh.execute    command=bmutool -s ${slot_value} -r 0x3D 0x${loki_value}    connection=ASIK Master
    sleep    1s
    Expect Fault Should Present    faultId=252    severity=${severity}
    ...    alarmId=${alarmId}   configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:2
    [Teardown]    csn.disconnect    connection=ASIK Master


Trigger LOKI B boot failure and check alarm
    [Arguments]    ${cell_list_disable}=${cell_list_G[1:3]}    ${cell_list_enable}=${cell_list_G[0:1]}
    Wait until keyword succeeds    15 min    3 sec    Trigger LOKI B boot failure    alarmId=7100     severity=Critical
    ...    slot_value=2
    Connect to Common Unit Master
    Wait until keyword succeeds    5 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_enable}
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_disable}
#    FOR  ${cell_idx}  IN  @{cell_list_disable}
#        Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
#        ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell_idx}
#        ...    supplementary=Not enough DSP or baseband pool resources for cell detected
#    END
    [Teardown]    csn.disconnect    connection=ASIK Master

Reset loki
    [Arguments]    ${loki_type}=A
    Connect to Common Unit Master
    log to console     \n trigger single loki ${loki_type} power failure and fault 252 report on BBMOD
    ${loki_value}    Run Keyword If    '${loki_type}' == 'A'    Set Variable    1:1
    ...    ELSE IF    '${loki_type}' == 'B'    Set Variable    1:2
#    ssh.execute    command=bsh ${loki_value} uboot_env set clktest_soc_sclk=1    connection=ASIK Master
    sleep    3s
    ssh.execute    command=bsh ${loki_value} resetsoc    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

########### common keywords#################
CB012611-G Suite Setup
    robot_common_operations.Common Suite Setup
    Modify Default gNBCellid TL728    Actual_value=${10}    LNCEL_idx=${54726}    connection=eNB
    Setup the Commission SCF
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G

CB012611-ute_cloud Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf1
#    Setup the Commission SCF
#    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G

CB012611-G Suite Teardown
    robot_common_operations.Common Suite Teardown

CB012611-G Case Setup
    robot_common_operations.Common case Setup    allowed_faults_ids=7316

Capture LMI Log
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    UUF Catch RU Log From LMI    testline=gnb_${gnb_index}    ru_list=${RU_serial_pc_info}

CB012611-G Case Teardown
    robot_common_operations.Common case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save the Snapshot
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    ru_serial_list=${ru_serial_list}    gnb_index=${0}
    recovery failure
    Setup the Commission SCF
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    ${status}    Run Keyword And Return Status    Check the GNB on air CB012611_G
    Run Keyword if    ${status} == ${false}    collect Snapshot
    Run Keyword if    ${status} == ${false}    Capture LMI Log    ru_serial_list=${ru_serial_list}    gnb_index=${0}
    CI_interface.Common Case Teardown


CB012611-G Case09/04 Teardown
    [Arguments]    ${slot_value}=1    ${loki_value}=1    ${bbmod_index}=1
    robot_common_operations.Common case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save the Snapshot
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    ru_serial_list=${ru_serial_list}    gnb_index=${0}
    recovery clock failure    slot_value=${slot_value}    loki_value=${loki_value}    bbmod_index=${bbmod_index}
    Setup the Commission SCF
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    ${status}    Run Keyword And Return Status    Check the GNB on air CB012611_G
    Run Keyword if    ${status} == ${false}    collect Snapshot
    Run Keyword if    ${status} == ${false}    Capture LMI Log    ru_serial_list=${ru_serial_list}    gnb_index=${0}
    CI_interface.Common Case Teardown

Collect Snapshot
    [Arguments]    ${connection}=cOAM
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.collect_snapshot    target_file_name=${output_dir}/snapshot/Collect_Snapshot.zip   connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

recovery failure
    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${False}
    sleep    10s
    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${True}
    wait until keyword succeeds    10 min    20 sec    Check the GNB on air CB012611_G
    @{fault_6450}    create list    ${6450}
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS_debug    bts_host=${gnb_ip}    connection=GNB_OAM
    ${status}    Run Keyword And Return Status    Check List1 content in List2    list1=${fault_6450}    list2=${actual_fault_id_list}
    ${status_1}    Run Keyword And Return Status    Check List1 content in List2    list1=${fault_6450}    list2=${history_id_list}
    Run Keyword if    ${status} == ${True} or ${status_1} == ${True}    Save the Snapshot
    [Teardown]    coam.teardown    connection=GNB_OAM


Modify Gnb Swconfig
    Connect to Common Unit Master
    csn.Execute    command=echo "0x2018D=1">>/ffs/run/swconfig.txt    connection=ASIK Master
    csn.Execute    command=crasign /ffs/run/swconfig.txt    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master


Backup Gnb Swconfig
    Connect to Common Unit Master
    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
    csn.Execute    command=${cmd}    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master


Recover Gnb Swconfig
    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${gNB_ssh_pass} ssh ${gNB_ssh_name}@${gnb_ip} '${cmd}'


recovery clock failure
    [Arguments]    ${slot_value}=1    ${loki_value}=1    ${bbmod_index}=1
    Backup Gnb Swconfig
    Modify Gnb Swconfig
    Perform BTS Site Reset
    sleep     60s
    Wait until keyword succeeds    10 min    10 sec    Connect to Common Unit Master
    csn.disconnect    connection=ASIK Master
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait until keyword succeeds    10 min    10 sec    Verify bbmod Should Be degraded    bbmod_index=${bbmod_index}
    Execute recover commands on ABIN/ABIO    slot_value=${slot_value}
    sleep     60s
    Wait Until Keyword Succeeds    5min    30s    Connect to Common Unit Master
    ssh.Connect to    hostname=fsp${slot_value}s${loki_value}icom   username=${gNB_ssh_name}    password=${gNB_ssh_pass}   alias=${ALIAS_ABIO}
    ...    proxy=ASIK Master
    ssh.execute    command=uboot_env del clktest_soc_sclk    connection=${ALIAS_ABIO}
    csn.disconnect    connection=${ALIAS_ABIO}
    csn.disconnect    connection=ASIK Master
    Recover Gnb Swconfig



start the power ue traffic ul and dl UDP
    [Arguments]    ${ue_index_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}    ${ue_type}=samsung
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=${ue_type}    iperf_type=via_command
        ...    iperf_port=${Ul_power_port_list}[${item}]    process_num=${process_num}
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    172 IP UE Start DL traffic UDP    ue_index=${item}
        ...    throughput=${dl_throughput}    time=${dl_duration}
        ...    DL_port=${dl_power_port_list}[${item}]    process_num=${process_num}
    END

UE Start Traffic And Check Tp 12611
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${ue_index}=${0}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.2    ${min_percent}=0    ${log_time}=60s    ${ue_type}=samsung
    ...    ${target_avg_percent_peak}=0.98    ${min_percent_peak}=0.85    ${if_peak}=${False}
    ...    ${expect_ul_tp}=0    ${expect_dl_tp}=0    ${ignore_time}=20s    ${process_num}=3
    @{ue_index_list}    create list    ${ue_index}
    attach the power ue    ue_index_list=${ue_index_list}
    sleep    5s
    start the power ue traffic ul and dl UDP    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M
    ...    dl_throughput=${dl_throughput}M    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${process_num}    ue_type=${ue_type}
    run keyword if    ${if_peak}==${False}    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}
    ...    dl_tp=${dl_throughput}    if_ul=${if_ul}    if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    log_time=${log_time}
    run keyword if    ${if_peak}==${True}    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${expect_ul_tp}
    ...    dl_tp=${expect_dl_tp}    if_ul=${if_ul}    if_dl=${if_dl}   target_avg_percent=${target_avg_percent_peak}
    ...    min_percent=${min_percent_peak}    log_time=${log_time}    ignore_time=${ignore_time}
    stop the power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}
    [Teardown]    detach the power ue    ue_index_list=${ue_index_list}

172 IP UE Start DL traffic UDP
    [Arguments]    ${DL_port}    ${throughput}    ${ue_index}=${2}    ${time}=6000   ${interval}=${1}    ${process_num}=${1}
    ...    ${connection}=cygwin
    #get ue ip
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    log to console    UE IP :${UE_IP}
    #send DL command
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  3s
    ssh.send_command   command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep  3s
    ssh.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${throughput} -l 1400B -T 64&
    ...    connection=EPCAPP
    sleep  3s
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

Check the GNB on air CB012611_G
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Check GNB cell on air    connection=${connection}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Trigger LOKI A boot failure
    [Arguments]    ${alarmId}=7100    ${severity}=Critical    ${loki_value}=1    ${slot_value}=1
    Connect to Common Unit Master
    log to console     \n trigger single loki Boot failure and fault 252 report on BBMOD
    ssh.execute    command=bmutool -s ${slot_value} -r 0x3D 0x${loki_value}    connection=ASIK Master
    sleep    1s
    Expect Fault Should Present    faultId=252    severity=${severity}
    ...    alarmId=${alarmId}   configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:2
    [Teardown]    csn.disconnect    connection=ASIK Master

Reset BTS And check cell status TL728
    [Arguments]    ${BTS_IP}=${gnb_ip}    ${connection}=GNB_OAM    ${cell_list_disable}=${cell_list_728[1:3]}
    ...    ${cell_list_enable}=${cell_list_728[2:3]}
    coam.connect_to    bts_host=${BTS_IP}   name=${connection}
    coam.reset_site    connection=GNB_OAM
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=252    severity=Minor
    ...    alarmId=7115    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:3
    FOR  ${cell_idx}  IN  @{cell_list_disable}
        Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
        ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell_idx}
        ...    supplementary=Not enough DSP or baseband pool resources for cell detected
    END
    Wait until keyword succeeds    15 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_enable}
    [Teardown]    coam.teardown    connection=${connection}

1Supercell with 3subcell change to 1Supercell with 2subcell and normal cell
    [Arguments]    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    \n change supercell
    WEB Login
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3
        ...    include_subobject=${TRUE}    id_value=${4}
    Wait Until Keyword Succeeds    3x    2min    selenium_coam.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2
#    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2
#    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-3
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}  object_class_name=NRCELL
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-3
        ...    include_subobject=${TRUE}    id_value=${4}
    Wait Until Keyword Succeeds    3x    2min    selenium_coam.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-3
    selenium_sbts.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}  object_class_name=NRCELLGRP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELLGRP-3
        ...    include_subobject=${TRUE}    id_value=${4}
    Wait Until Keyword Succeeds    3x    2min    selenium_coam.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
        ...    filter_param=Local cell resource ID   new_value=4    abbr=lcrId
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
        ...    filter_param=Physical cell identifier   new_value=99   abbr=physCellId
    selenium_sbts.set_parameter_value
       ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-4
       ...    filter_param=List of NR cells assigned to cell group    new_value=4    node_index=${0}    abbr=nrCellList
    selenium_sbts.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       Wait Until Keyword Succeeds    3x    2min    selenium_sbts.set_parameter_value
       ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=4  node_index=${4}  abbr=refNrCellGroup
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
        ...    filter_param=Activate super cell   new_value=false   abbr=actSuperCell
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-4
        ...    filter_param=Number of transmitted Synchronization Signal Blocks   new_value=1 beam   abbr=numberOfTransmittedSsBlocks
    ${error}    selenium_sbts.validate_plan
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEB Logout

Single UE Attach TL728
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${attach_mode}=5G_NSA
    Log To Console    Single UE Attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=${attach_mode}    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic And Check Throughput TL728
    [Arguments]    ${tp_ul}    ${tp_dl}    ${target_tp_ul}    ${target_tp_dl}    ${nrcell_id}    ${duration}=600    ${ue_mode}=NSA
    ...    ${ue_index}=${0}    ${gnb_index}=${0}    ${port}=${0}    ${iperf_type_ul}=via_command    ${iperf_type_dl}=via_command
    ...    ${target_avg_percent}=0.95
    Log To Console    Start Traffic And Check Throughput
    Single UE Attach TL728    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${tp_ul}   ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_ul}    process_num=${3}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${tp_dl}    ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_dl}    process_num=${3}
    sleep    30s
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_ul}    target_avg_percent=${target_avg_percent}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}    target_avg_percent=${target_avg_percent}

Stop Traffic And UE Detach TL728
    [Arguments]    ${ue_index}=${0}    ${port}=${0}    ${ue_mode}=NSA
    Log To Console    stop traffic
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    Log To Console    UE Detach
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Modify Default gNBCellid TL728
    [Arguments]    ${Actual_value}    ${LNCEL_idx}=${54726}    ${connection}=default
    Log To Console     Modify Default gNBCellid
    coam.connect_to    bts_host=${eNB_OAM_IP}   name=${connection}
    ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${eNB_BTS_ID}/LNBTS-7012/LNCEL-${LNCEL_idx}    parameter=${list}
    ...    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    sleep    3s
    [Teardown]    coam.teardown    connection=${connection}
