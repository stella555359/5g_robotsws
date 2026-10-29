*** Settings ***
Documentation       copyright : nokia
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library     OperatingSystem
Library    taf.ul.ue.sim.env_setup
Library     ta5g_commissioning
Library     BuiltIn
Library     String
Library     SSHLibrary
Library     Collections
Library     ta_messaging
Library		taf.sw.syslog
#Library     ute_wtssim
#Library		taf.sbts.oam.coam.admin        WITH NAME       SBTS_COAM
#Library      ute_admin_infomodel
Library      XML
Library      ta_uexgate    compress_logs=True
Library     ute_fsmaccess
#Library     ute_admin
#Library      taf.sw.reporting_portal
Library      ta5g_pm_counters
Library     ta5g_admin_operations
Resource   ../../../resources/robot/ConformanceTest_Setup_Env.robot
Variables      ./python/swconfig_flags.py
#Variables      ./python/parametrs.py
Resource         ../../../resources/robot/PM_Counters.robot
*** Variables ***
${gNB_IP} 		  192.168.255.129
${connection}		oam
${egate_port}=          20000
${edaemon_port}=        10000
${nokia_enb}=   1
${ue_id}=  1
${sim_enb}=     4
${egate_host}=     10.0.1.1

${cus_ini}     ${CURDIR}/config/cus/cus.ini
${lua}         ${CURDIR}/config/cus/epc.lua
${ue_db}       ${CURDIR}/config/cus/ue.db
@{SWCONFIG_FLAGS}=      ${MAC_PS_TRACE_DEBUG}    0x1002B=0x37B0   0x1002C=0x382F   0x1002F=1   0x10030=0   0x1005A=1
                        ...   0x100CA=16   0x100CE=0   0x1002A = 2
${yaml}=                              ${CURDIR}/config/cus/coco.yaml

*** Keywords ***
Configure Env for CB011153
   	Add Simulator       sim_type=cus    config=${cus_ini},${ue_db}
    Add Enb Configuration               rad_params=@{SWCONFIG_FLAGS}
    Add Epc                         config=${lua}
    configure_environment
    coam.setup_admin    bts_host=${gNB_IP}     alias=${connection}    admin_api_log_dir=/tmp
    Setup egate  egate_port=${EGATE_PORT}      host_ip=${egate_host}
    Log to console     egate setup successful...
#    Setup egate  egate_port=${EGATE_PORT}     host_ip=${gNB_IP}
    Run keyword and ignore error      Run process       cat /tmp/.egate_proc | xargs kill -9    shell=True
    Create aliases
    ${date} =	get_current_date
    set suite variable          ${TEST_START_TIME}          ${date}
    Execute egate command   cmd=set_log flush    alias=MME_UERelease
    Execute egate command   cmd=echo TEST START ${date}    alias=MME_UERelease
    Open egate terminal
    Start flushing logs in backgorund


Prepare test environment fast
    Setup Emss    enb_id=1
    Setup egate and edaemon
    Create aliases

Create aliases
    Create UE group aliases  alias=UE  start_ue_id=1  stop_ue_id=110  id_type=rtg
    Create MME alias    alias=MME_1    mme_id=1  id_type=wts
    Create enb alias    alias=ENB_1   enb_id=1  id_type=wts
    Create eNB alias  alias=eNB_${nokia_enb}    enb_id=${nokia_enb}     id_type=wts
#    Create eNB alias  alias=eNB_${sim_enb}      enb_id=${sim_enb}       id_type=wts

Setup egate and edaemon
    Setup egate  egate_port=${egate_port}  host_ip=${egate_host}

Teardown egate and edaemon
#    Teardown Edaemon
    Teardown Egate


Attach UE and Start Data Traffic

      [Arguments]    ${start_ue}     ${end_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${end_ue}
        Run UEx Command  ue_attach    id=${ue_id}  cell=1
        Run UEx Command  trf_data_start  ue=${ue_id}  dir=dl  Mbps=${50}  protocol=udp  size=1400    stats=true
        Run UEx Command  trf_data_start  ue=${ue_id}  dir=ul  Mbps=${10}  protocol=udp  size=1400    stats=true

    END
    Sleep    5s

Detach All UEs
    Run UEx Command  ue_detach  all

Perform data traffic for "${Equipment_ID}"
    [Documentation]    Traffic value should be greater than expected throughput by a margin.
    [Tags]    DESIGNSTEP
    ${ue_id}=    Evaluate    $Equipment_ID.partition('_')[-1]
    Run UEx command    trf_data_start    ue=${ue_id}    dir=dl    protocol=${PROTOCOL}
    ...    Mbps=${${Equipment_ID}_DATA_TRAFFIC_VOLUME_MBITS}    size=64000    trf_id=1
    Run UEx command    trf_data_start    ue=${ue_id}    dir=dl    protocol=${PROTOCOL}
    ...    Mbps=${${Equipment_ID}_DATA_TRAFFIC_VOLUME_MBITS}    size=64000    trf_id=2
    Run UEx command    trf_data_start    ue=${ue_id}    dir=dl    protocol=${PROTOCOL}
    ...    Mbps=${${Equipment_ID}_DATA_TRAFFIC_VOLUME_MBITS}    size=64000    trf_id=3
    Run UEx command    ue_stats    clear    id=${ue_id}
    Verify tput is ongoing    dir=dl    id=${ue_id}

Verify tput is ongoing
    [Arguments]    ${dir}    ${id}
    ${trf_stats}=    Run UEx command    get_ue_stats    id=${id}    type=${dir}_rlc    unit=Mbps
    ${tputs_ue}=    Get From Dictionary    ${trf_stats}    UE
    ${tputs_all}=    Get From Dictionary    ${tputs_ue}    Overall
    ${throughput_mbps}=    Get From Dictionary    ${tputs_all}    avg
    Should Be True    ${throughput_mbps}>0    msg=Throughput is not ongoing

Make connection
     SBTS_COAM.setup_admin    bts_host=${gNB_IP}     alias=${connection}    admin_api_log_dir=/tmp

#Collect PM Counters
#    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
#    Set Suite variable  ${pm_counters_dir}

Attach "${Equipment_ID}"
    [Documentation]    Attach is checked in runtime based on Egate console output.
    [Tags]    DESIGNSTEP
    ${ue_id}=    Evaluate    $Equipment_ID.partition('_')[-1]
    Run UEx command    ue_attach    id=${ue_id}    cell=1
    Sleep    3


Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    Log To console     ${moc}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}

Get Total value of counter and compare
    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
#    ${rc}       get_total_cmp      ${PM_report_dict_list}     ${expected_value}
#    Should Contain  ${rc}  PASS
    Should Contain     ${expected_value}     PASS

Verify Counters
    [Arguments]  ${counters}
     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     ${counter_ids}=   Get Dictionary Keys    ${counters}
     FOR   ${counter_id}  IN  @{counter_ids}
        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
        Validate PM Counters_pcell_scell   ${PM_dir_1}   ${counter_id}  ${e_value}>=0   LNCELL-1
     END

Get Throughput counters and validate
    [Arguments]     ${PM_counter}
    ...          ${value_expected}      ${cellid}=1
    Collect PM Counters
    PM_Counters.Check PM counter value equal    expected_value=${value_expected}   pm_files_location=${pm_counters_dir}
    ...  pi_id=${PM_counter}      moc=LNCEL-${cellid}
    Log To Console      Counter Value Verified


#Detach "${Equipment_ID}"
#    [Documentation]    Detach is checked in runtime based on Egate console output.
#    [Tags]    DESIGNSTEP
#    ${ue_id}=    Evaluate    $Equipment_ID.partition('_')[-1]
#    Run UEx command    ue_detach    id=${ue_id}




Should be equal but we accept 5% delta
    [Arguments]   ${first}  ${second}
    ${tolerance}=  Set variable  ${0.05}
    ${rel_diff}=  evaluate  abs(${first} - ${second})/float(${first})
    Should be true  ${rel_diff} < ${tolerance}


Should be equal but we accept 7% delta
    [Arguments]   ${first}  ${second}
    ${tolerance}=  Set variable  ${0.07}
    ${rel_diff}=  evaluate  abs(${first} - ${second})/float(${first})
    Should be true  ${rel_diff} < ${tolerance}

Start egate collection
    run keyword and ignore error      Run process       cat /tmp/.egate_proc | xargs kill -9    shell=True
    Run keyword and ignore error      setup egate    20000      alias=MME_UERelease     save_egate=${True}
    ${date} =	get_current_date
    set suite variable          ${TEST_START_TIME}          ${date}
    Execute egate command   cmd=set_log flush    alias=MME_UERelease
    Execute egate command   cmd=echo TEST START ${date}    alias=MME_UERelease
    Open egate terminal
    Start flushing logs in backgorund

Stop egate collection
    Execute egate command   cmd=set_log flush    alias=MME_UERelease
    sleep     1
#    Teardown egate   alias=log_collector
    Run process     cp /opt/iphy/latest/egate_console.log ${OUTPUT DIR}/egate_console_full.log    shell=True
#    Run Keyword When Not In UTE         Close egate terminal
    ${sed1}=    catenate
    ...    sed -n '/^TEST START ${TEST_START_TIME}$/,$p' ${OUTPUT DIR}/egate_console_full.log
    ...    > ${OUTPUT DIR}/egate_console_suite_${TEST_START_TIME}.log
    Run process    ${sed1}
    ...            shell=True
    ${sed2}=     catenate
    ...     sed s"/\\[session.*/\\n\x1b[31m&\x1b[0m\\n\\n/g" ${OUTPUT DIR}/egate_console_suite_${TEST_START_TIME}.log
    ...     > ${OUTPUT DIR}/egate_console_suite_color_${TEST_START_TIME}.log
    Run process    ${sed2}
    ...            shell=True
#    Open xterm with log from last run

Open egate terminal

    ${cmd}=     catenate
    ...         xterm -T 'EPCSIM LOG ${TEST_START_TIME}' -geometry 200x30  -hold -e
    ...         'tail -f /opt/iphy/latest/egate_console.log | sed --unbuffered s"/\\[session.*/\\n\x1b[31m&\x1b[0m\\n\\n/g"'
    ${proc}=      Start process
    ...   ${cmd}
    ...   shell=True
    set suite variable     ${EGATE_CMD_PROCESS}         ${proc}


Close egate terminal
    run keyword and ignore error     Terminate process    ${EGATE_CMD_PROCESS}

Start flushing logs in backgorund
    no operation

Trigger E-RAB releases due to RLF
    [Arguments]    ${ue_id}
    Log to console     ${ue_id}
    Log to console    Triggering RLF HO...
    Execute Egate Command    cmd=enb_param on_rlf_indication=rlf_triggered_ho id=2
#    Run Executor Command    cmd=enb_param on_rlf_indication=rlf_triggered_ho id=2
#    Run Executor Command    enb_param    on_rlf_indication=rlf_triggered_ho id=2
    Sleep    2
    Expect Message Flow    MME_1:S1AP_UEContextReleaseRequest contains ((procedureCode eq 18) and (radioNetwork eq 21))
    ...    alias=MME_UERelease    overall_timeout=40
    log to console    Verify if UEContextReleaseRequest with radio connection with UE lost cause is send from ENB to MME
    Execute Egate Command    cmd=ue_rrc_reestablish enb=2 cell=1 id=${ue_id}
    Flow Occurred as Expected    alias=MME_UERelease
#    Verify if UEContextReleaseRequest with UE lost cause is send from ENB to MME

Verify if UEContextReleaseRequest with UE lost cause is send from ENB to MME
    Expect Message Flow    MME_1:S1AP_UEContextReleaseRequest contains ((procedureCode eq 18) and (radioNetwork eq 21))
    ...    alias=MME_UERelease    overall_timeout=40
    log to console    Verify if UEContextReleaseRequest with radio connection with UE lost cause is send from ENB to MME
    Run Executor Command    cmd=ue_rrc_reestablish enb=2 cell=1 id=1
    Flow Occurred as Expected    alias=MME_UERelease


Start aatrace '${filename}'
    run_keyword_and_ignore_error    start_aatrace    filename=${TEST LOG DIRECTORY()}${filename}    config_file=aatrace_filter.txt
    ...     alias=fsmf

Verify that PM Counters are incremented
     ${pm_counters_filepath}=    Get Next Unpacked Raw Pm Counters File
     ${M8013C10}=  Get Latest Pm Counter Value  counter_id=M8013C10    local_moid=${local_cell_id_1}    filepath=${pm_counters_filepath}
#     ${M8011C230}=  Get Latest Pm Counter Value  counter_id=M8011C230    local_moid=${local_cell_id_1}    filepath=${pm_counters_filepath}
#     ${M8051C119}=  Get Latest Pm Counter Value  counter_id=M8051C119    local_moid=${local_cell_id_2}    filepath=${pm_counters_filepath}
#     ${M8011C230}=  Get Latest Pm Counter Value  counter_id=M8011C230   local_moid=${local_cell_id_2}    filepath=${pm_counters_filepath}
     Run Keyword And Continue On Failure    Should Be True  ${M8013C10} => 0

Verify Counters CB011153
     wait_for_next_full_pm_interval
     ${COUNTER_FILE}=    Get Latest Unpacked Raw Pm Counters File
     Log to console     ${COUNTER_FILE}
     Run Keyword And Continue On Failure    Verify Last Counters In File
     ...    M8013C10    >0    EPC_INIT_TO_IDLE_DETACH
#     ...    M8011C230    >0    SGNB_SA_DU_RAC_REJ_DUE_RRC
#     ...    M8051C119    <0    SGNB_SA_DU_RAC_REJ_DUE_NGBR
#     ...    M55138C00006    \=0    SGNB_SA_RAC_REJ_DUE_TO_RRC
#     ...    M55138C00002    !\=0    SGNB_SA_ADMISSION_SUCC
     ...    local_moid=PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-1/MCC-244/MNC-08
     ...    file_path=${COUNTER_FILE}

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
