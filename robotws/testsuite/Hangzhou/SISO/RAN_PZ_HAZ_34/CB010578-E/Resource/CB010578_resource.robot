*** Settings ***
Documentation
...    author: zhang lusha
...    contact: lusha.zhang@nokia-sbell.com
...    squad group: MN_RAN_RD_VRF_HAZ3_02

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/Manual_SiSo_SM_BTS_Block_Site.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/snapshot_check.robot


Library    BuiltIn
Library    Collections


*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ue_type}    ${tl.ues[0].capabilities[2]}
${BASIC_PATH_5G}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
${core_name}     fct-4a
${bb_position}     1
${core_alias}     core_alias
${snapshot_file_list}      ${EMPTY}
@{obsai_list}     4    5
${is_get_snapshot_via_selenium}     False
*** Keywords ***
# General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_CB010578_US8
#     [Arguments]    ${is_get_snapshot_via_selenium}=${False}
#     log to console    Wait 10 s before Collect Snapshot
#     sleep    10s
#     Connect to Common Unit Master
#     ${ru_index_list}  Get All RU Index
#     log to console    \n*** ru_index_list before is ${ru_index_list} ***
#     remove from list    ${ru_index_list}    ${3}
#     remove from list    ${ru_index_list}    ${3}
#     log to console    \n*** ru_index_list after is ${ru_index_list} ***
#     log    ${ru_index_list}
#     FOR  ${ru_index}  IN  @{ru_index_list}
#         log to console    \n*** check snapshot of RU${ru_index} ***
#         Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
#         Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
#         ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
#         Check startup runtime and soap file in ru log    ru_log=${rfsw_log_path_on_testPC}    ru_index=${ru_index}
#         csn.Disconnect  connection=RU_${ru_index}
#     END
#     [Teardown]  csn.Disconnect  connection=ASIK Master


SISO Coam Suite Setup With Specify SCF
    [Arguments]    ${enb_flag}=${True}    ${scf_suffix}=0    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** SISO Coam Suite Setup With Specify SCF  scf_suffix:${scf_suffix} ***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path_Temp}    Get Golden SCF Path    gnb_index=${gnb_index}
    ${Golden_SCF_Path}=    Replace String    ${Golden_SCF_Path_Temp}    .xml    ${scf_suffix}.xml
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' and '${enb_flag}'=='${True}' or '${gNb_CuType}'=='SA+NSA' and '${enb_flag}'=='${True}'
    ...    Run Keyword And Ignore Error    get eNB active version
    run keyword if     ${if_commissioning} and '${testline_name}' != 'null'
    ...    bts_coam.Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    set suite variable    ${suite_setup_fail_flag}    ${False}



Step1:Prepare UE
    [Arguments]    ${ue_index}=${0}        ${power_reset}=true
    log to console      step1: Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=${power_reset}    get_spark_license=false

Step2:UE Attach
    [Arguments]     ${ue_index}=${0}    ${pci}=${pci}
    log to console      Step2: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog    power_reset=True    pci=${pci}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic and Check TP
    [Arguments]    ${list_of_cell_ids}=${list_of_cell_ids}    ${ue_index}=${0}    ${ultarget_throughput}=${0}    ${dltarget_throughput}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    apn_address=dxdata2
    ...    throughput=1600MKbits/sec    duration=600
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul     apn_address=dxdata2
    ...    throughput=120MKbits/sec    duration=600
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1min    ue_index=${ue_index}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput= ${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}    target_avg_percent=0.5
    ...    min_percent=0.5   ue_index=${ue_index}

SigSpark_UE detach
    [Arguments]    ${ue_index}=${ue_index}    ${power_reset}=True
    Run Keyword And Ignore Error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    Run Keyword And Ignore Error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}


General_SiSo_Cell_block_and_unblock_for_CB010578_US9
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_normal_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${10}    ${11}    ${12}
    ${cell_ru_chain_list}    Create List    ${7}    ${8}    ${9}
    Block cells and check status    block_list=${cell_normal_list}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}
    Block cells and check status    block_list=${cell_ru_chain_list}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    UnBlock cells and check status    block_list=${cell_ru_chain_list}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}    skip_deepsleep=${True}
    UnBlock cells and check status    block_list=${cell_normal_list}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}
    #L3 call peak for CB009499_H supercell
    #L3 call peak for CB010578
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

General_SiSo_RF_module_reset_from_GUI_CB010578
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ...    ${suite_name}=default    ${test_name}=default
    ${ru_index_list}  Get All RU Index    connection=${connection}
    Reverse List    ${ru_index_list}
    log    ${ru_index_list}
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
        ...    suite_name=${suite_name}    test_name=${test_name}
    END
    Check RF Startup and Gnb Status    ${ru_index_list}    gnb_index=${gnb_index}    connection=${connection}
    verify all cells should be onair    connection=${connection}
    [Teardown]  Selenium Logout And Close Browser

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_CB010578
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}
    ...    ${exclude_RU_index}=${exclude_RU_index}
    log to console    Wait 10 s before Collect Snapshot
    sleep    10s
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    #### here aim to exclude 2 FXED index which is OBSAI ####
    log    ${ru_index_list}
    remove from list    ${ru_index_list}    ${exclude_RU_index}
    remove from list    ${ru_index_list}    ${exclude_RU_index}
    log    ${ru_index_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n*** check snapshot of RU${ru_index} ***
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}   prefix_name=${mrbtsID}
        Check startup runtime and soap file in ru log    ru_log=${rfsw_log_path_on_testPC}    ru_index=${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_CB010578_OBSAI
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}
    #Connect to Common Unit Master
    FOR  ${ru_index}  IN  @{obsai_list}
        # Connect to RU With Allocated IP OBSAI    ru_index=${ru_index}
        Connect to RU With Allocated IP OBSAI and get RU log    ru_index=${ru_index}
        Verify RFSW Log Include In Snapshot obsai    ru_index=${ru_index}    snapshot_path=${SAVE LOG DIRECTORY}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
        Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
        Run Keyword And Ignore Error    csn.Disconnect  connection=ASIK Master
    END
    [Teardown]  Run Keyword And Ignore Error    csn.Disconnect  connection=ASIK Master

Verify RFSW Log Include In Snapshot obsai
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...    is_get_snapshot_via_selenium: if set to ${True} use selenium for collect, if ${False} use rest api
    [Arguments]   ${ru_index}=${1}    ${connection}=GNB_OAM   ${snapshot_path}=${TS_CASE_LOG_PATH}    ${timeout}=900
    ...    ${is_get_snapshot_via_selenium}=${False}
    #${log_on_ru}   Get RFSW Log File List On RU   connection=${ru_alias}    download_dir=${snapshot_path}
    ${log_on_snapshot}   Run keyword if    ${is_get_snapshot_via_selenium}
    ...    Get RFSW Log File List On Snapshot via webUI    ru_index=${ru_index}    snapshot_path=${snapshot_path}    connection=${connection}
    ...    ELSE    Get RFSW Log File List On Snapshot  ru_index=${ru_index}    snapshot_path=${snapshot_path}   prefix_name=${mrbtsID}
    ...    connection=${connection}    timeout=${timeout}
    ${not_include_list}    Create List
    FOR  ${item}  IN  @{log_on_ru}
       ${item_new}=     String.Split String    ${item}    .
       ${status}  Run Keyword And Return Status  Should Contain Match   ${log_on_snapshot}   regexp=.*${item_new}[0].*
       Run Keyword If  ${status}==${False}     Append to List    ${not_include_list}     ${item_new}[0]
    END
    ${length}    Get Length    ${not_include_list}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs

Connect to RU With Allocated IP OBSAI
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]  ${ru_index}=${1}   ${asik_alias}=ASIK Master
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}

    Connect To BTS Csn Via Lmp
    csn.connect_to    hostname=${core_name}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${core_alias}
    ...               proxy=${asik_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}
    ${channel}    Call Method    ${connection_service}    invoke_shell

    # Step 2: get ru list number
    Call Method    ${channel}    send    nl /ffs/run/config/FRIps.txt | grep FXED | awk '{print $1; exit}'| awk '{print$1}'\n
    Sleep    1 sec
    ${ru_number}    Call Method    ${channel}    recv    ${65535}
    ${ru_number}    Get Line    ${ru_number}    -2
    ${ru_number}    Convert To string    ${ru_number}
    Set Test Variable    ${ru_number}
    #Call Method    ${channel}    close

    # Step 3: get ru ip
    ${index}    Evaluate    ${ru_number}+${ru_index}-4
    #${index}    Evaluate    3+1

    Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$3}'\n
    Sleep    1 sec
    ${ru_ip_addr}    Call Method    ${channel}    recv    ${65535}
    ${ru_ip_addr}    Get Line    ${ru_ip_addr}    -2
    ${ru_ip_addr}    Convert To String    ${ru_ip_addr}
    Run Keyword If    '${ru_ip_addr}'=='0.0.0.0'    Exit For Loop

    # Step 3.1: get ru serial number
    Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$4}'\n
    Sleep    1 sec
    ${ru_serial_number}    Call Method    ${channel}    recv    ${65535}
    ${ru_serial_number}    Get Line    ${ru_serial_number}    1
    ${ru_serial_number}    Convert To String    ${ru_serial_number}
    # ${snapshot_ru_file_list}   Get Regexp Matches   ${snapshot_file_list}   BTS\\_${ru_serial_number}\\_.*

    # Step 4: get ru type
    Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$5}'\n
    Sleep    1 sec
    ${ru_type}    Call Method    ${channel}    recv    ${65535}
    ${ru_type}    Get Line    ${ru_type}    1
    ${ru_type}    Convert To String    ${ru_type}

    # Step 5: get ru username&password
    ${ru_username}    ${ru_password}    Get RU Login Info From Config Via RU Type    ${ru_type}

    # Step 6: get ru hw_group and BBmod position which RU connected to  by RU SN
    ${ru_hwGroup}    ${bb_position}    Get FH Protocol And BB Position Via RU SN    ${ru_serial_number}
    ${bb_position}    Convert To String    ${bb_position}

    #Step 7 check RU log
    &{ru_properties}    Create Dictionary    username=${ru_username}
    ...    password=${ru_password}    sn=${ru_serial_number}
    ...    ip=${ru_ip_addr}    type=${ru_type}

    ${log_on_ru}    Check OBSAI RU log
    ...    ru_ip_addr=${ru_ip_addr}    channel=${channel}
    ...    core_name=${core_name}    bb_position=${1}    core_alias=${core_alias}
    # ...    snapshot_file_list=${snapshot_ru_file_list}
    log to console    ${log_on_ru}
    Set Test Variable    ${log_on_ru}

Connect to RU With Allocated IP OBSAI and get RU log
    [Arguments]  ${ru_index}=${1}   ${asik_alias}=ASIK Master
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ...          ${ru_serial_number}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].serial_number}
    ...          ${ru_type}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].radio_type}

    Connect To BTS Csn Via Lmp
    csn.connect_to    hostname=${core_name}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${core_alias}
    ...               proxy=${asik_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}
    ${channel}    Call Method    ${connection_service}    invoke_shell

    # get ru ip
    Call Method    ${channel}    send    nl /ffs/run/config/FRIps.txt | grep ${ru_serial_number} | awk '{print $2; exit}' | awk -F';' '{print$3}'\n
    Sleep    1 sec
    ${ru_ip_addr}    Call Method    ${channel}    recv    ${65535}
    ${ru_ip_addr}    Get Line    ${ru_ip_addr}    -2
    ${ru_ip_addr}    Convert To String    ${ru_ip_addr}
    Run Keyword If    '${ru_ip_addr}'=='0.0.0.0'    Exit For Loop

    # get ru username&password
    ${ru_username}    ${ru_password}    Get RU Login Info From Config Via RU Type    ${ru_type}

    # get ru hw_group and BBmod position which RU connected to  by RU SN
    ${ru_hwGroup}    ${bb_position}    Get FH Protocol And BB Position Via RU SN    ${ru_serial_number}
    ${bb_position}    Convert To String    ${bb_position}

    #check RU log
    &{ru_properties}    Create Dictionary    username=${ru_username}
    ...    password=${ru_password}    sn=${ru_serial_number}
    ...    ip=${ru_ip_addr}    type=${ru_type}

    ${log_on_ru}    Check OBSAI RU log
    ...    ru_ip_addr=${ru_ip_addr}    channel=${channel}
    ...    core_name=${core_name}    bb_position=${1}    core_alias=${core_alias}
    # ...    snapshot_file_list=${snapshot_ru_file_list}
    log to console    ${log_on_ru}
    Set Test Variable    ${log_on_ru}

Check OBSAI RU log
    [Documentation]    author: yinhua.zhang@nokia-sbell.com
    ...    method of login OBSAI is different from ecpri&cpri. the keyword is for OBSAI ru.
    [Arguments]    ${ru_ip_addr}    ${channel}
    ...    ${core_name}=fct-0a    ${bb_position}=1    ${core_alias}=core_alias

    # login BBMod
    Call Method    ${channel}    send    bsh ${bb_position}:0\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    asp

    # login Rmod
    Call Method    ${channel}    send    telnet ${ru_ip_addr} 2323\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}

    # collect RU log
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_name}    Set Variable    obsai_rfsw_log_${timestamp}.zip
    Call Method    ${channel}    send    log -c full -z ${rfsw_log_name}\n
    Sleep    180 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ls -l\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    ${rfsw_log_name}

    # exit to BBmod
    Call Method    ${channel}    send    exit\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    asp

    # copy RU log from RU to SMOD
    Call Method    ${channel}    send    curl ftp://${ru_ip_addr}/${rfsw_log_name} -o ${rfsw_log_name}\n
    Sleep    5 sec
    Call Method    ${channel}    recv    ${65535}
    ${username}    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ${password}    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Call Method    ${channel}    send    scp ${rfsw_log_name} ${username}@${core_name}:/ffs/run/config/toor4nsn/\n
    Sleep    2 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    # check if need input YES
    ${result}    convert to string    ${result}
    ${status}    Run keyword and return status    should contain    ${result}    yes/no/[fingerprint]
    Run keyword if    ${status}    Establish To Smod    channel=${channel}
    # input password
    Call Method    ${channel}    send    ${password}\n
    Sleep    2 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    Sleep    60 sec
    ${result}    convert to string    ${result}
    Should contain    ${result}    100%

    # download ru log to testPC, then will delete file from smod
    ${ru_file_path}    Set variable    /ffs/run/config/toor4nsn/${rfsw_log_name}
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${ru_file_path}
    ...    download_dir=${SUITE_LOG_PATH}    connection=${core_alias}
    ${log_on_ru}    Get RFSW Log File List On OBASI RU    rfsw_log_path_on_testPC=${rfsw_log_path_on_testPC}
    [Return]    ${log_on_ru}

    #compare RU log with in snapshot
    #Sub_Check_Content_OF_Radio_Unit_Logs_IN_Snapshot    rfsw_log_names_in_snapshot=${snapshot_file_list}
    #...    log_on_ru=${log_on_ru}
    #[Teardown]    Run Keyword And Ignore Error    Remove Ru Logs File from RU and BB    channel=${channel}
    #...    rfsw_log_name=${rfsw_log_name}    ru_ip_addr=${ru_ip_addr}

Establish To Smod
    [Arguments]    ${channel}
    Call Method    ${channel}    send    yes\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    Password:

Get FH Protocol And BB Position Via RU SN
    [Documentation]    Author: yinhua.zhang@nokia-sbell.com
    ...    obtain fronthaul protocol and bbmod position from init file.
    ...    positioner is used to indicate BB position
    [Arguments]    ${ru_sn}
    ${ru_num_in_init}    Get Length    ${tl.gnbs[0].dus[0].rus}
    FOR    ${ru_index}    IN RANGE   ${ru_num_in_init}
        ${ru_hw_group}    Set Variable If
        ...    '${tl.gnbs[0].dus[0].rus[${ru_index}].serial_number}'=='${ru_sn}'
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}].ru_hw_group}
        ${positioner}    Set Variable If
        ...    '${tl.gnbs[0].dus[0].rus[${ru_index}].serial_number}'=='${ru_sn}'
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}].positioner}
    END
    [Return]    ${ru_hw_group}    ${positioner}

Sub_Check_Content_OF_Radio_Unit_Logs_IN_Snapshot
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/10 17:18
    [Arguments]    ${rfsw_log_names_in_snapshot}    ${log_on_ru}
    ${not_include_list}    Create List
    FOR    ${item}    IN    @{log_on_ru}
       ${item_new}    String.Split String    ${item}    .
       ${status}    Run Keyword And Return Status    Should Contain Match    ${rfsw_log_names_in_snapshot}
       ...    regexp=.*${item_new}[0].*
       Run Keyword If    ${status}==${False}    Append to List    ${not_include_list}    ${item_new}[0]
    END
    ${length}    Get Length    ${not_include_list}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs


Get RFSW Log File List On OBASI RU
    [Arguments]    ${rfsw_log_path_on_testPC}
    Set Task Variable      ${rfsw_log_path_on_testPC}
    ${unzip_result}    Run     unzip -l ${rfsw_log_path_on_testPC} |tail -n +2
    ${vaild_lines}      Get Lines Matching Regexp    ${unzip_result}     [A-Z]\\d+_.*    partial_match=true
    ${rfsw_log_names}    Get Regexp Matches      ${vaild_lines}    _[a-zA-Z]?.*
    [Return]    ${rfsw_log_names}


Get RU Login Info From Config Via RU Type
    [Arguments]    ${ru_type}
    ${ru_index_list}    Get All RU Index
    Set Test Variable    ${username}    ${EMPTY}
    Set Test Variable    ${password}    ${EMPTY}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Run Keyword If    '${tl.gnbs[0].dus[0].rus[${ru_index}-1].radio_type}'=='RadioTypes.${ru_type}'
        ...    Set Test Variable    ${username}    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
        Run Keyword If    '${tl.gnbs[0].dus[0].rus[${ru_index}-1].radio_type}'=='RadioTypes.${ru_type}'
        ...    Set Test Variable    ${password}    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    END
    [Return]    ${username}    ${password}

Connect To BTS Csn Via Lmp
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    csn.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

collect snapshot
    [Arguments]    ${gnb_index}=0
    #robot_common_operations.Common Suite Teardown
    #log to console    \n***SISO Coam Suite Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True


UES attach and detach check
    ${pci_list}    Create List    ${21}    ${2}    ${22}    ${11}    ${23}    ${12}    ${1}
    ${list_of_cell_ids}    Create List    ${608731143}    ${608731138}    ${608731144}    ${608731140}    ${608731145}    ${608731141}    ${608731137}

    FOR  ${i}  IN RANGE  7
        Step1:Prepare UE    ue_index=${i}
        log to console    UE${i+1}prepared
    END
    FOR  ${i}  IN RANGE  7
        Step2:UE Attach    ue_index=${i}    pci=${pci_list}[${i}]
        log to console    UE${i+1}attached
    END

    FOR  ${i}  IN RANGE  7
        SigSpark_UE detach    ue_index=${i}
        log to console    UE${i+1}detached
    END


General_SiSo_BTS_startup_with_RF_delayed_startup_US9
    ${ru_index_list}  Get All RU Index
    Perform RAC and RAU Power Off  ${ru_index_list}
    Perform RAC Power On  ${ru_index_list}
    Run Keyword And Ignore Error    Power On RU And Check  ${ru_index_list}
    Perform BTS Site Reset
    [Teardown]    Run Keyword And Ignore Error    Power On RU_and_check RF Delayed Startup  ${ru_index_list}
