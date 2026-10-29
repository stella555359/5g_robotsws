*** Settings ***
Suite Setup    Common Suite Setup And Setup BTS Env for LMI
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Power on and Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      dandan Chen
...   contact:     dandan.chen@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     None

Force Tags    5G_RRM
...   PY39

Resource    ./resource/Common.robot
Resource    ./resource/Stability_TestCase_keywords.robot

*** Variables ***
${GNB_SYSLOG_FLAG}             ${True}
${RU_SYSLOG_FLAG}              ${False}
${ENB_SYSLOG_FLAG}             ${False}
@{FAULTS_EXCLUDED_CHECKING}    8000
${LOOP}    2
${power_num}    2
${lock_num}    3
${tl_info}    7_5_UTE5G402T2477
${TLSCF_path}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T2452/SBTS00/
${LMI_DEBUG}    ${False}
${test_pc_addr}        ${tl.test_pc.default_ssh_connection_details.addr}
${test_pc_username}    ${tl.test_pc.default_ssh_connection_details.username}
${test_pc_password}    ${tl.test_pc.default_ssh_connection_details.password}

${gnb_addr}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_username}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_password}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${gnb_host}          asc-0a
${container_id}      0x1018    #For gNB in the left and 0x1018 for the right

${ru_type}    AEQY
${ru_username}    serviceuser
${ru_password}    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=

@{ru_command_list}
...    rm -rf /rom/swconfig.txt
...    rm -rf /rom/swconfig_local.txt
...    ccsShell.sh rad -mpw 0x10041 2
...    ccsShell.sh rad -mpw 0x10042 3232261320
...    ccsShell.sh rad -mpw 0x10043 51000
...    mv /mnt/runtime/swconfig_local.txt /mnt/runtime/swconfig.txt
...    sync
...    reboot

@{ru_command_enable_LMI}
...    lmi-eth on
@{DELTA_PARAS_RMOD-1_Lock}
...    RMOD-1:administrativeState=Locked
@{DELTA_PARAS_RMOD-1_unlock}
...    RMOD-1:administrativeState=Unlocked
*** Test Cases ***
GNB_reset_and_RMOD_lockunlock_and_huawei_call_setup
    [Documentation]
    ...    1. The purpose of this test case is for stability test
    ...    2. Test Case Steps:
    ...      case step:
    ...         a. cell onair, create UE and send traffic
    ...         b. GNB site reset, waiting cell onair, create UE and send traffic
    ...         d. lock unlock rmod-1for multi times, create UE and send traffic
    ...      case result:
    ...         a. UE attaches successfully, traffic normal.
    ...         b. after reset, UE attaches successfully, traffic normal
    ...         c. after unlock, UE attaches successfully, traffic normal
    [Tags]        QC_
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    UUF Truck Roll Check
    UE attach and send traffic
    FOR    ${id}    IN RANGE    1    ${LOOP}
        GNB site reset and wait for 50s
        wait until keyword succeeds    1200    20s    Cells Should Be OnAir
#        BBmode reset and cell onair
        UE attach and send traffic
#        Power off and Power on for multi times
#        UE attach and send traffic
        Lock and Unlock for multi times
        wait until keyword succeeds    1200    20s    Cells Should Be OnAir
        UE attach and send traffic
    END

*** Keywords ***
Lock and Unlock for multi times
    ${bts_port}  ${use_ssl}  Define Admin Port
    Setup Admin  bts_port=${bts_port}  use_ssl=${use_ssl}  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs
    ...  timeout=120  bts_host=${FTM_IP}    alias=mky
    FOR    ${id}    IN RANGE    1    ${lock_num}
        Lock RMOD-1
        sleep    20s
        Unlock RMOD-1 and cell onair
    END
    Collect Snapshot self    tag=1

Lock RMOD-1
    Delta Commission Parameters    ${DELTA_PARAS_RMOD-1_Lock}
    sleep    2s

Unlock RMOD-1 and cell onair
    Delta Commission Parameters    ${DELTA_PARAS_RMOD-1_unlock}
    sleep    20s
    Cells Should Be OnAir

Common Suite Setup And Setup BTS Env for LMI
    Setup BTS env and set keyword prority
    Get UUF Related Info

Power on and Common Test Teardown And Stop Capture Logs
   Run Keyword If Test Failed    Power on the GNB
#   UUF Stop Log Collection Process
   Common Test Teardown And Stop Capture Logs

Get UUF Related Info
    UUF Get Variables From Backup SCF
    UUF Get Variables From Others
    UUF Get Testline Type
    UUF Check Env Testline
    Set Suite Variable    ${testline}    ${ALL_GNB_LIST}[0]
    Set other Parameters

Set other Parameters
    Set Suite Variable    ${webem_addr}        ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    Set Suite Variable    ${webem_username}    ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    Set Suite Variable    ${webem_password}    ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    Set Suite Variable    ${ssh_addr}          ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    Set Suite Variable    ${ssh_username}      ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    Set Suite Variable    ${ssh_password}      ${ALL_CONFIG_INIT['${testline}']['ssh_password']}
    Set Suite Variable    ${common_units}      ${ALL_CONFIG_INIT['${testline}']['common_units']}

btslog_start
    Execute Egate Command    sshenb;lxc-attach -n 0x1018;ssh serviceuser@172.22.0.2;sudo lmi-eth on

BBmode reset and wait for 2s
    Reset BBMODs
    sleep    2s

Reset BBMODs
    ${coam_conn}    coam.Connect To
    ${fbb_info}=    coam.Get fbb info    connection=${coam_conn}
    FOR    ${fbb}    IN    @{fbb_info}
        coam.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    coam.Teardown    ${coam_conn}

Power off and Power on for multi times
    ${bts_port}  ${use_ssl}  Define Admin Port
    Setup Admin  bts_port=${bts_port}  use_ssl=${use_ssl}  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs
    ...  timeout=120  bts_host=${FTM_IP}    alias=mky
    FOR    ${id}    IN RANGE    1    ${power_num}
        Power on and power off GNB
    END
    wait until keyword succeeds    10m    20s   COAM Login   bts_host=${webem_addr}
    ...   username=${webem_username}   password=${webem_password}   alias=${testline}
    Login RU And Execute Command    testline=${testline}    cmd_list=${ru_command_list}    cmd_with_sudo=${True}
    sleep    150s
    wait until keyword succeeds    5m    20s   COAM Login   bts_host=${webem_addr}
    ...   username=${webem_username}   password=${webem_password}   alias=${testline}
    Login RU And Execute Command    testline=${testline}    cmd_list=${ru_command_enable_LMI}    cmd_with_sudo=${True}
    UUF Start Log Collection Process
    Wait Until Keyword Succeeds    900s    10s    Cells Should Be OnAir
    Wait For Host Ssh    ${FCT_IP}    timeout=600
    Start To Capture Wireshark Log
    Collect Snapshot self    tag=1

Collect Snapshot self
    [Arguments]  ${tag}=${EMPTY}
    ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs
    ...  ${SAVE LOG DIRECTORY}
    Execute Cmd On Pc    df -h ${OUTPUT_DIR}    # 20G is needed for snapshot capturing according to PR722687
    Wait Until Keyword Succeeds    10x    1min    admin.Collect Snapshot  ${snapshot_dir}/snapshot.zip    connection=mky
    Execute Cmd On Pc    df -h ${OUTPUT_DIR}
    teardown_admin   connection=mky

Power on and power off GNB
   Power off the GNB
   Power on the GNB
   sleep    5
  # Cells Should Be OnAir

Login RU And Execute Command
    [Timeout]   1m
    [Arguments]    ${testline}    ${cmd_list}    ${cmd_with_sudo}=${False}    ${timeout}=${60}
    BuiltIn.Log    Login RU And Execute Command...    console=${True}

    Log To Console   Login gNB
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}

    Run Keyword And Ignore Error    csn.Execute    command=ssh-keygen -R 172.22.0.2 -f ~/.ssh/known_hosts    connection=${testline}
    &{connected_RU}   Get RU Info From Testline   connection=${testline}
    &{testline_detected_ru}   Create Dictionary   &{connected_RU}

    Log To Console   Login RU
    ${container_alias}   Connect To FHNET Container   testline_alias=${testline}   container_id=${container_id}
    FOR   ${ru_info}   IN   @{testline_detected_ru.items()}
        Run Keyword And Ignore Error   Single RU Execute Command
        ...   ru_info=${ru_info}
        ...   command_list=${cmd_list}
        ...   cmd_with_sudo=${cmd_with_sudo}
        ...   container_alias=${container_alias}
        ...   timeout=${timeout}
    END
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${container_alias}    AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}

Get RU Info From Testline
    [Arguments]   ${connection}
    ${connected_RU}   Create Dictionary

    ${detected_RUs}   csn.Execute   command=cat /ffs/run/config/FRIps.txt |grep ${ru_type}   connection=${connection}
    FOR    ${ru}    IN    @{detected_RUs.splitlines()}
        ${check_ru_info}    Run Keyword And Return Status    should contain    ${ru}    ;
        Continue For Loop If    '${check_ru_info}' == '${False}'

        ${ru_sn}   Set Variable   ${ru.split(";")[3]}
        ${ru_ip}   Set Variable   ${ru.split(";")[2]}
        #${ru_type}   Set Variable   ${ru.split(";")[4]}

        ${ru_info}   Create Dictionary
        ...   ru_ip=${ru_ip}
        ...   ru_type=${ru_type}
        ...   testline_alias=${connection}
        ...   container_id=${container_id}
        ...   ru_username=${ru_username}
        ...   ru_password=${ru_password}
        run keyword if  not "${ru_ip}"=="0.0.0.0"    Set to Dictionary    ${connected_RU}    ${ru_sn}=${ru_info}
    END
    [Return]    ${connected_RU}

Power off the GNB
    [Documentation]   GNB power off
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    BuiltIn.Log    GNB Power off start
    ${gnb_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${gnb_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_off    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    Wait Until Keyword Succeeds    240s    5s    ping should as excepted    ip_addr=${FTM_IP}    regrx_string=Destination Host Unreachable
    BuiltIn.Log    GNB Power off done.

ping should as excepted
    [Arguments]    ${ip_addr}=${FTM_IP}    ${regrx_string}=Destination Host Unreachable
    ${result2}    run    command=pwd
    ${result3}    run    command=ls -l
    ${result1}    run    command=ps -ef
    ${result}    run    command=ping ${ip_addr} -c 3
    Should Contain    ${result}    ${regrx_string}

Power on the GNB
    [Documentation]   GNB Power on
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    BuiltIn.Log    GNB Power on start
    ${gnb_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${gnb_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_on    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    Wait Until Keyword Succeeds    600s    5s    ping should as excepted    ip_addr=${FTM_IP}    regrx_string=3 received
    BuiltIn.Log    GNB Power on done.


UE attach and send traffic
    Start UE Attach With Power UE    ue_index=${0}    4G_check=false
    Start L3 Call With Power UE    ue_index=${0}    ul_data_transfer=20Mbits/sec    dl_data_transfer=492Mbits/sec    apn_address=dxdata1
    @{direction_component_list}    Create List   UL_L2LO    DL_L2LO
    log to console    call setup, please check traffic
    sleep    120s
    Check Tput With Power UE    expect_ul_tput=${0}    expect_dl_tput=${0}    duration=10
    ...    direction_component_list=@{direction_component_list}
    Stop Traffic With Power UE     ue_index=${0}    apn_address=dxdata1    is_detach=True

BBmode reset and cell onair
    Reset BBMODs
    Cells Should Be OnAir

Reset RMOD
    ${coam_conn}    coam.Connect To
    Set test variable    ${MRBTS_ID}    ${tl.gnbs[0].instance_id}
    ${ru_index_list}    Get All RU Index    connection=${coam_conn}
    FOR    ${index}    IN    @{ru_index_list}
        log to console    \n***RF Module index ${index} Reset via admin**
        ${RU_index}    Convert To Integer    ${index}
        coam.reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
        ...    force_radio_reset=${True}    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    coam.Teardown    ${coam_conn}

GNB site reset and wait for 50s
    GNB Reset Site
    sleep    50s


GNB Reset Site
    ${coam_conn}    coam.Connect To
    ${smod_info}=    coam.Reset Site    connection=${coam_conn}
    log    ${smod_info}
    #FOR    ${smod}    IN    @{smod_info}
    #    taf.sbts.oam.coam.admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    #END
   [Teardown]    coam.Teardown    ${coam_conn}

Get all Huawei pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1118 425
    Set Suite Variable    ${close_task}    580 2140
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    900 380
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    960 850