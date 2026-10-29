*** Settings ***
Documentation
...   This is for  TA common keywords
...   squad group: MMW_SG1
Resource    ./5GC001349_Variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
#Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library    ./pdml_enumerate.py     WITH NAME   pdml

*** Keywords ***
Suite preparation for 1349
    [Documentation]    Author: fang ludan
                ...    modify and commission SCF
    [Timeout]    20 min
    [Arguments]     ${modify_scf}   ${scf_default_file_path}
    ${is_enb_status_check_needed}  set variable  ${True}
    ${is_x2_check_from_enb_needed}  set variable  ${True}
    ${4G_check}  set variable  ${True}
    ${gnb_CU_type}   Get gNB CU type
    log to console   ${gnb_CU_type}
    ${is_enb_status_check_needed}  set variable if  '${gnb_CU_type}'=='SA'  ${False}   ${True}
    ${is_x2_check_from_enb_needed}  set variable if  '${gnb_CU_type}'=='SA'   ${False}   ${True}
    ${4G_check}  set variable if  '${gnb_CU_type}'=='SA'   ${False}   ${True}
    Set suite variable    ${gnb_CU_type}
    Set suite variable    ${is_enb_status_check_needed}
    Set suite variable    ${is_x2_check_from_enb_needed}
    Set suite variable    ${4G_check}
    Suite common setup preparation    swconfig_modify=${None}
    ...    scf_modify_parameters=${modify_scf}   is_called_in_test_case_level=${False}
    ...    is_pdl_checking_needed=${False}   prepare_ue=${True}
    ...    scf_template_path=${scf_default_file_path}    swconfig_template_path=${SWCONFIG_DEFAULT_FILE_PATH}
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    ${luashark_true_path}   set variable if   '${cur_program}'=='21A'   ${luashark_21A}    ${luashark_trunk}
    Set suite variable    ${luashark_true_path}

    ${detach_time}    set suite variable    ${0}

    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${TDD_CELL_ID}
    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_1349}


modify gnb index_UI
     [Documentation]    Author: fang ludan
                ...   online modify SCF on GNB
     [Arguments]        ${online_modify_parameters}
     Connect to gnb coam via ssl
     coam_selenium.COAM Update Several Parameters Via WebUI
    ...    parameters_to_update_via_webui=${online_modify_parameters}
    ...    download_dir=${TS_CASE_LOG_PATH}
    ...    is_need_to_check_validation_errors=${True}


modify gnb index
     [Documentation]    Author: fang ludan
                ...   online modify SCF on GNB
     [Arguments]        ${online_modify_parameters}
     Connect to gnb coam via ssl
     run keyword if    ${online_modify_parameters}!=${NONE}
     ...    coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${online_modify_parameters}
     ...    timeout=${360}


Check index in X2log
    [Documentation]    author: Fang ludan
    ...     Description:check index in X2log
    [Arguments]    ${x2ap_log}     ${index_exp}   ${RSI_exp}
    ${filtered_packets}   pcap.load_pcap_file    pcap_file=${x2ap_log}     command_template=${X2AP_COMMAND_NSA}
    ${request}      pcap.filter_packets_by_expression
    ...  filter_expression=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)
    ${index}    pcap.Get field value by_xpath    ${request}     ${X2_COMMANPATH}
    ${RSI}    pcap.Get field value by_xpath    ${request}     ${X2_COMMANPATH_RSI}       attribute_name=showname
    should be equal as integers    ${index[0]}    ${index_exp}
    ${RSI}   set variable   ${RSI[0]}
    should be equal as strings    ${RSI}      ${RSI_exp}


Case teardown
    [Documentation]    case teardown
    Common case teardown  detach_ue=${True}



Get gNB CU type
    [Documentation]    author: Fang ludan
    ...     Description:Get gNB CU type
    ...     [return]  SA /NSA/both
    [Arguments]   ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${get_managed_objects}    coam.get_managed_objects    class_name=NRBTS_A    connection=${connection}
    ${btsname_current}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=gNbCuType    connection=GNB_OAM
    [Return]    ${btsname_current['gNbCuType']}
    [Teardown]   COAM Teardown gnb connections


Retry commercial ue attach if failed for bip
    [Timeout]    10 min
    [Documentation]    Author: fang ludan
    ...   Description: try attach via airplane mode.
    ...   ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    [Arguments]    ${ue_type}=${UE_TYPE}   ${is_bip_log_needed}=${false}  ${retry_time}=5    ${ue_index}=${0}
    ...   ${prepare_ue_needed}=${False}    ${4G_check}=${False}
    ${bip_list}      create list
    run keyword if    ${prepare_ue_needed}==${True}     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
         ${5Grach_ed}    UE Attach for bip    ue_type=${ue_type}    ue_index=${ue_index}    is_bip_log_needed=${is_bip_log_needed}
         append to list  ${bip_list}   ${5Grach_ed[6]}
         ${attach_status}    run keyword and return status    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
         ...    4G_check=${4G_check}    ue_index=${ue_index}
         Exit for loop if    ${attach_status}
         power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
         ${detach_time}    Evaluate    ${detach_time}+1
         Log to console   UE_${ue_index} attached failed, retry detach time ${detach_time}
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE_${ue_index} attach with ${retry_time} times and still failed
    [Return]   ${bip_list}

bip_log_get_AllbeamID_Allmsg3
    [Documentation]    Author:fang ludan
    ...                This keyword is used to get beamID of msg2 and get num of msg3 form bip log
    ...                ${file_path} should include dir name and file name and file extension(if any), eg: /home/ute/CPRT_trace.pcap
    [Arguments]        ${file_path}   ${command_template}  ${luashark_true_path}   ${lua_script}=${LUA_SCRIPT_PATH}
    ${msg3_sum}    set variable   ${0}
    ${beamID_list_sum}     create list
    FOR  ${i}   IN   @{file_path}
         ${pdml_packets}       Convert Pcap to pdml format      file_path=${i[0]}    command_template=${command_template}
         ...   luashark_path=${luashark_true_path}
         ${pdml_log_path}      Get pdml log       tcpdump_log=${i[0]}
         ${beamID_list}        pdml.get_beamID    ${pdml_log_path}
         Run keyword if   ${beamID_list}=={}  continue for loop
         ${msg2_num}           pdml.get_msg2      ${pdml_log_path}
         ${msg2_num_true}      pdml.get_msg2_true      ${pdml_log_path}
         ${msg3_num}           pdml.get_msg3      ${pdml_log_path}
         ${beamID_list_sum}    get_beam_ID_sum    ${beamID_list_sum}     ${beamID_list}
         ${msg3_sum}           evaluate           ${msg3_num}+${msg3_sum}
    END
    [Teardown]   Run Keyword And Ignore Error    Remove File    ${pdml_log_path}
    [Return]     ${beamID_list_sum}     ${msg3_sum}    ${msg2_num}   ${msg2_num_true}

check counter
    [Documentation]    Author:fang ludan
    ...                This keyword is used to check counter
    [Arguments]    ${beamID_list}   ${msg3_num}   ${beamID_counter_list}   ${msg3_attach_counter_list}  ${local_counter_file_path}
    ...   ${msg2_num}   ${msg2_num_true}
    ${BeamID_counter}      get_total_counter_from_multiple_files   list_file_path=${local_counter_file_path}
    ...  list_measurement_ids=${beamID_counter_list}
    ${msg3_attach_counter}      get_total_counter_from_multiple_files   list_file_path=${local_counter_file_path}
    ...  list_measurement_ids=${msg3_attach_counter_list}
    ${beamstatus}     beamID_check     ${beamID_list}   ${BeamID_counter}
    Run keyword and continue on failure  should be equal as numbers  ${msg3_num}   ${msg3_attach_counter['M55306C06001']}
    Run keyword and continue on failure  should be equal as numbers  ${msg2_num}   ${msg3_attach_counter['M55306C03001']}
    Run keyword and continue on failure  should be true  ${beamstatus}
    Run keyword and continue on failure  should be equal as numbers  ${msg2_num_true}    ${msg2_num}


UE Attach for bip
    [Arguments]    ${ue_type}  ${is_bip_log_needed}=${false}  ${attach_mode}=5G_SA   ${ue_index}=${0}
     ...   ${gnb_index}=${0}    ${du_index}=0    ${hwcheck_index}=${1}
    ...    ${ue_alias}=UE_${ue_index}   ${abil_index}=${1}    ${log_type}=Aasyslog    ${interval}=${1}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  ue_alias: <str> store ue by ue_alias
    ${attach_use}    set variable    ${True}
    set suite variable    ${attach_use}
    run keyword and ignore error    power_ue.Logging keyword usage
    ${output}    run keyword    ${ue_type}.UE Attach for bip    ue_index=${ue_index}
    ...                                                 is_bip_log_needed=${is_bip_log_needed}
    ...                                                 gnb_index=${gnb_index}
    ...                                                 hwcheck_index=${hwcheck_index}
    ...                                                 ue_alias=${ue_alias}
    ...                                                 abil_index=${abil_index}
    ...                                                 du_index=${du_index}
    ...                                                 log_type=${log_type}
    ...                                                 attach_mode=${attach_mode}
    ...                                                 interval=${interval}
    [Return]    ${output}

qct_dx50.UE Attach for bip
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0   ${is_bip_log_needed}=${False}
    ...    ${log_type}=Aasyslog    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  With Aasyslog catch normally please confirm the RD parameter 0x1003F=1;0x10040=1 have been setted in swconfig
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  hwcheck_index: The list index with mapping as 0->ASIK 1->ABIL1 2->ABIL2 3ABIL3, it will use the
    ...          mapping HW to check the ue attach status
    ...  add turn mobile data on to make sure the mobile data is turned on.
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu
    ${attach_status}   ${list_log_path_local}   run keyword and ignore error  Ue attach with index for bip      ue_index=${ue_index}
    ...                                                                          is_bip_log_needed=${is_bip_log_needed}
    run keyword and continue on failure    turn mobile data on    alias=UE_${ue_index}
    run keyword if     '${list_log_path_local[1]}'=='False'    run keywords   Ue reattach with index for bip   ue_index=${ue_index}
    ...    AND   run keyword and continue on failure    turn mobile data on    alias=UE_${ue_index}
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    ${list_log_path_local[0]}

Ue attach with index for bip
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...  If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
    [Timeout]   15 min
    [Arguments]  ${ue_index}=${0}   ${is_bip_log_needed}=${False}
    FOR   ${i}   IN RANGE  5
        Connect to Common Unit Master
        run keyword if   ${is_bip_log_needed}==${true}   Start Bip Capture for different program
        ...   bb_slot_1=${bb_slot_1}    bb_slot_2=${bb_slot_2}
        sleep  7s
        ${status}  run keyword and return status    ute_ue.attach_ue    UE_${ue_index}
        Connect to Common Unit Master
        sleep  10s
        ${list_log_path_local}   run keyword if  ${is_bip_log_needed}==${true}
        ...    Stop Bip Capture and Collect logs for different program    asib_interface=eths3
        run keyword if  ${status}==${False}    csn.execute    rm -rf ${list_log_path_local[0]}   connection=ASIK Master
        Exit For Loop If   ${status}
    END
    [Return]   ${list_log_path_local}    ${status}
    [Teardown]   run keyword and ignore error    Stop Bip Log Via Interface Mirroring Collector

Ue reattach with index for bip
    [Documentation]  This keyword's is a WA for ute_ue.ue attach sometimes not connect success and attach fail.
    [Arguments]  ${ue_index}=${0}
    UE soft reboot    ue_index=${ue_index}
    Ue attach with index for bip    ue_index=${ue_index}

attach and check counter
    [Documentation]  This keyword is for check attach and check counters
     ...  counter_M55306C00001-M55306C00008:RA setup attempts for contention based group A preambles corresponding to SSB beam ID
     ...  counter_M55306C03001: RA setup completions for contention based group A preambles
     ...  counter_M55306C06001:RA msg3 receptions. The number of successfully received contention based msg3 for any
     ...  type of contention based RACH procedure
    [Arguments]  ${MODIFY_PRACH_configuration_index}   ${beamID_counter_list}  ${index_exp}   ${prepare_ue_needed}=${False}
    ...   ${RSI_exp}=${RSI_exp_long}
    #prepare
#    Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}
    modify gnb index    online_modify_parameters=${MODIFY_PRACH_configuration_index}
     Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT_cell}   gnb_type='${gnb_CU_type}'
    ...  is_enb_status_check_needed=${False}  is_x2_check_from_enb_needed=${False}
    ${msg3_attach_counter_list}   create list   M55306C03001  M55306C06001

    #prepare for counter log
    Connect to Capacity Unit Master
    Wait for next PM counter file is generated    reporting_interval=5
    &{case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5

    #attach and bip log capture
    ${list_log_path_local}   Retry commercial ue attach if failed for bip  retry_time=${retry_time}  ue_type=${ue_type}
    ...   is_bip_log_needed=True   prepare_ue_needed=${prepare_ue_needed}  4G_check=${False}

    #counter log capture
    log to console    Collect pm files
    Connect to Capacity Unit Master
    &{case_stop_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    sleep    ${case_stop_time_info['wait_time']} min
    @{remote_file_path}    Wait until PM counter file is genereated    timeout=2min
    ...    log_generate_timestamp=${case_start_time_info['log_generator_timestamp']}
    @{local_counter_file_path}    counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_file_path}
    ...    local_file_folder=${TS_CASE_LOG_PATH}

    #check inex
    Check index in biplog       bip_log=${list_log_path_local[0][0]}      index_exp=${index_exp}     RSI_exp=${RSI_exp}
    ...    luashark_true_path=${luashark_true_path}
    #counter check
    ${beamID_list}   ${msg3_num}  ${msg2_num}  ${msg2_num_true}   bip_log_get_AllbeamID_Allmsg3    file_path=${list_log_path_local}
    ...    command_template=${X2AP_COMMAND_counter}   lua_script=${LUA_SCRIPT_PATH}   luashark_true_path=${luashark_true_path}
    check counter      beamID_list=${beamID_list}    msg3_num=${msg3_num}   msg2_num=${msg2_num}  beamID_counter_list=${beamID_counter_list}
    ...  msg3_attach_counter_list=${msg3_attach_counter_list}  local_counter_file_path=@{local_counter_file_path}  msg2_num_true=${msg2_num_true}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

attach and check PRACH configuration index with X2 log
    [Documentation]  This keyword is for check attach and check index
    [Arguments]  ${index_exp}   ${prepare_ue_needed}=${True}  ${RSI_exp}=${RSI_exp_long}
    Start X2 log capture from eNB    log_name=X2_tcpdump
    Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}    prepare_ue_needed=${prepare_ue_needed}
    ...  4G_check=${4G_check}
    ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump
    Check index in X2log       x2ap_log=${X2tcpdump_log}      index_exp=${index_exp}     RSI_exp=${RSI_exp}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    [Teardown]     run keyword and ignore error   Stop trace capturing    log_prefix=X2_tcpdump    connection_alias=ENB


get attach KPI
    [Timeout]    2 hour
    [Documentation]    Author: Fangludan
    ...   Description: attach many times,got kpi of attach
    [Arguments]    ${ue_type}=${UE_TYPE}    ${retry_time}=34.0    ${ue_index}=${0}    ${prepare_ue_needed}=${False}    ${4G_check}=${False}
    ...   ${attach_KPI_exp}=0.03
#    run keyword if    ${prepare_ue_needed}==${True}     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${Attach_fail_time}    Set variable    ${0.0}
    FOR   ${i}    IN RANGE    ${retry_time}
          log   ${Attach_fail_time}
         ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
         ${attach_status}    run keyword and return status    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
         ...    4G_check=${4G_check}    ue_index=${ue_index}
         Run keyword if   ${attach_status}   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
         ${Attach_fail_time}   Run keyword if    ${attach_status}==${false}     Evaluate    ${Attach_fail_time}+1.0
      ...    ELSE      set variable    ${Attach_fail_time}
    END
    ${attach_KPI}   evaluate    ${Attach_fail_time}/${retry_time}
    should be true   ${attach_KPI}<${attach_KPI_exp}


attach and check PRACH configuration index with bip log
    [Documentation]  This keyword is for check attach and check index
    [Arguments]   ${index_exp}   ${prepare_ue_needed}=${False}   ${is_enb_status_check_needed}=${False}  ${RSI_exp}=${RSI_exp_long}
    ${list_log_path_local}   Retry commercial ue attach if failed for bip  retry_time=${retry_time}  ue_type=${ue_type}
    ...   is_bip_log_needed=True   prepare_ue_needed=${prepare_ue_needed}  4G_check=${is_enb_status_check_needed}
#    Check index in biplog       bip_log=${list_log_path_local[0][0]}      index_exp=${index_exp}     RSI_exp=${RSI_exp}
#    ...    luashark_true_path=${luashark_true_path}
    run keyword and ignore error   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}



check index in biplog
    [Documentation]    author: Fang ludan
    ...     Description:check index in X2log
    [Arguments]    ${bip_log}     ${index_exp}   ${RSI_exp}    ${luashark_true_path}    ${filter}=${BIP_FILTER}
    ${pdml_log_path}  Get pdml log   tcpdump_log=${bip_log}    filter=${filter}
    ${ConfigurationIndex}  check_ConfigurationIndex   ${pdml_log_path}
    ${RootSequenceIndex}   check_RootSequenceIndex   ${pdml_log_path}
    Run keyword and continue on failure   should be equal   ${ConfigurationIndex}  ${index_exp}
    Run keyword and continue on failure   should be equal   ${RootSequenceIndex}   ${RSI_exp}
    [Teardown]   Run Keyword And Ignore Error    Remove File    ${pdml_log_path}



attach and check PRACH configuration index
    [Documentation]  This keyword is for check attach and check index
    [Arguments]  ${MODIFY_PRACH_configuration_index}  ${index_exp}  ${RSI_exp}=${RSI_exp_long}   ${prepare_ue_needed}=${False}
    modify gnb index    online_modify_parameters=${MODIFY_PRACH_configuration_index}
    Wait until cluster is on cell on air status   timeout=${RECOVERY_TIMEOUT_cell}    is_x2_check_from_enb_needed=${False}
    ...    is_enb_status_check_needed=${False}
    ...    gnb_type='${gnb_CU_type}'
    log to console   start attach
    attach and check PRACH configuration index with bip log
    ...                                                         index_exp=${index_exp}
    ...                                                         prepare_ue_needed=${False}
    ...                                                         RSI_exp=${RSI_exp}
