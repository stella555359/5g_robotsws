*** Settings ***
Documentation
...    Author:    Wu Amy;Zhou Qiang;Ding Lisa
...    Maintainer:    Wu Amy;Zhou Qiang;Ding Lisa

Library  OperatingSystem
Library  Process
Library  String
Library  DateTime
Library  Collections
Library  ute_async
Library  ute_fsmaccess
Library  ute_syslog
Library  kpiReporter.py
Library  ute_reporting_portal

*** Keywords ***


Get reserved sw build
    [Documentation]  Keyword return sw build on which TL was reserved.
    [Timeout]  2min
    ${reserved_sw_build_cmd}=
    ...  convert to string  cat /opt/ute/reservation.json | grep -o -P '"enb_build": (".+")' | awk -F '"' '{print $4}'
    ${reserved_sw_build}=  Run process  ${reserved_sw_build_cmd}  shell=True  cwd=${CURDIR}  timeout=3min
    Log  ${reserved_sw_build.stdout}  console=False
    set suite variable  ${RESERVED_BUILD}  ${reserved_sw_build.stdout}

Set Candidate
    [Documentation]  Keyword for setting build to which testline will be upgraded.
    ...  Candidate should be passed in testrun command --variable CANDIDATE_SW:build_to_which_we_upgrade
    ...  If not Upgrade will be performed to UTE build on which testline was reserved from(/opt/ute/reservation.json)
    ${status}=  run keyword and return status  Variable Should Exist  ${CANDIDATE_SW}
    run keyword if  '${status}' =='False'  Get reserved sw build
    run keyword if  ${status}  set suite variable  ${CANDIDATE}  ${CANDIDATE_SW}
    ...  ELSE  set suite variable  ${CANDIDATE}  ${RESERVED_BUILD}

Get Hostname
    [Documentation]  Keyword Gets Hostname of Vm on which test is running and cut suffix with vm index.
    ...  Used to Map VM hostname for dictionary key in tl_config.py
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  convert to string  ${hostname_tmp}
    ${hostname_part}=  split string  ${hostname_tmp}  _
    ${hostname_combined}=  catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    set suite variable  ${HOSTNAME}  ${hostname_combined}

Get Testcase QcId
    FOR    ${tag}    IN    @{TEST TAGS}
        ${split}    split string    ${tag}    _
        ${status1}    ${return}    Run Keyword And Ignore Error    Should Contain    ${tag}    QC_
        Run Keyword IF    '${status1}'=='PASS'    Set Test Variable  ${QC_ID}    ${split[1]}
        Exit For Loop If    '${status1}'=='PASS'
    END

Log to console with time
    [Documentation]  Keyword display,log output with time.
    [Arguments]  ${output}
    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  ${time}[0]  ${time}[1]  ${time}[2]
    Log  (${time_now}) ${output}  console=True

Get Label
    [Documentation]  Currently not Usec but can be added to report of UTE Testlines
    ${label_cmd}=  convert to string  cat /opt/ute/reservation.json | grep -o -P '"testline_type": (".+")' | awk -F '"' '{print $4}'
    ${label}=  Run process  ${label_cmd}  shell=True  cwd=${CURDIR}
    ${label}=  convert to string  ${label.stdout}
    log to console with time  ${label}
    Set Suite Variable  ${LABEL}  ${label}

Start time
    ${start_time}   ${start_time_delta}   time_now
    Log to console  ${start_time}
    set suite variable   ${START_TIME_DELTA}    ${start_time_delta}
    set suite variable   ${START_TIME}          ${start_time}

End time
    ${stop_time}   ${stop_time_delta}   time_now
    Log to console    ${stop_time}
    set suite variable    ${STOP_TIME_DELTA}     ${stop_time_delta}
    set suite variable    ${STOP_TIME}           ${stop_time}

setup ute_syslog on bts
    [Arguments]    ${syslog_backup_dir}=/home/ute/Downloads/syslog_backups  ${log_name}=syslog
    ${btsIds}    Create List
    ${btsIds}    Get Dictionary Keys    ${NODE_CFG}
#    ${btsIds}    Create List    6500
    FOR    ${btsId}    IN    @{btsIds}
        run keyword and ignore error  collect Syslog Results
        ...  destination=${syslog_backup_dir}/teardown.tar.gz
        ...  unzip=${False}
        ...  alias=syslog_node_${btsId}
    END

    run keyword and ignore error  Teardown All Aliases For Syslog
    run keyword and ignore error  Run process  sudo rm -rfv ${syslog_backup_dir}  shell=True

    FOR    ${btsId}    IN    @{btsIds}
        log to console with time  Starting Syslog from bts:${btsId}
        Wait Until Keyword Succeeds  1m  30s  ute_syslog.start syslog
        ...       log_dir=${syslog_backup_dir}
        ...       log_name=${log_name}_backup_node_${btsId}.log
        ...       host_ip=10.108.151.224    #host_ip=${BTS_CONFIG["HOST_IP"]}
        ...       ssh_username=ute
        ...       ssh_password=/home/ute/.ssh/id_rsa  # workaround because SR passwords can have / and library treat it as path
        ...       file_limit=209715200  # 200MB
        ...       add_line_number=True
        ...       alias=syslog_node_${btsId}
    END


start_time_stamp
    ${start_of_dict}=  Create Dictionary
    ${btsIds}    Create List
    ${btsIds}    Get Dictionary Keys    ${NODE_CFG}
#    ${btsIds}    Create List    6500
    FOR    ${btsId}    IN    @{btsIds}
        log to console with time  savepoint from bts:${btsId}
        ${start_of_time}=  ute_syslog.Capture Savepoint    alias=syslog_node_${btsId}
        Set To Dictionary   ${start_of_dict}    ${btsId}=${start_of_time}
    END
    set suite variable  ${START_OF_TIME_DICT}  ${start_of_dict}


Syslog Parser Time
    [Arguments]   ${btsId}  ${message}  ${timestamp}  ${syslog_name}
    log to console with time  Searching For message In Syslog
#    Collect from Savepoint   savepoint=${timestamp}   destination_file=${LOG_DIR}/syslog_parser  compress=True  alias=syslog_node_${node}

    ${status}=  Collect from Savepoint
    ...  savepoint=${timestamp}
    ...  destination_file=/home/ute/Downloads/${syslog_name}
    ...  compress=True
    ...  alias=syslog_node_${btsId}

    ${items} =  run keyword   Message should exist in syslog file   regexp=${message}
    ...    savepoint=${timestamp}   alias=syslog_node_${btsId}
    Log  ${items}  console=False
    [Return]  ${items}


Count Time From First Cell Down To Last Cell On
    ${downtime_dict}=  create dictionary
    ${btsIds}    Create List
    ${btsIds}    Get Dictionary Keys    ${NODE_CFG}
#    ${btsIds}    Create List    6500
    FOR  ${btsId}  IN  @{btsIds}
        ${start_frame}=  Syslog Parser Time
        ...  btsId=${btsId}
        ...  message=has been changed from OnAirDone to Validated
        ...  timestamp=${START_OF_TIME_DICT['${btsId}']}
        ...  syslog_name=syslog_savepoint_start_of_upgrade
        ${start}=   get_first_cell_downtime    ${start_frame}
        ${stop_frame}=  Syslog Parser Time
        ...  btsId=${btsId}
        ...  message=has been changed from Validated to OnAirDone
        ...  timestamp=${START_OF_TIME_DICT['${btsId}']}
        ...  syslog_name=syslog_savepoint_start_of_upgrade
        ${stop}=   get_last_cell   ${stop_frame}
        ${diff_downtime}=   get_delta_time_in_seconds    ${start}    ${stop}
        ${diff_downtime_str}=  convert to string  ${diff_downtime}
        Set To Dictionary   ${downtime_dict}    ${btsId}=${diff_downtime_str}
    END
    set suite variable  ${DOWNTIME_FL_DICT}  ${downtime_dict}

Count Time From Last Cell Down To First Cell On
    ${downtime_dict}=  create dictionary
    ${btsIds}    Create List
    ${btsIds}    Get Dictionary Keys    ${NODE_CFG}
#    ${btsIds}    Create List    6500
    FOR  ${btsId}  IN  @{btsIds}
        ${start_frame}=  Syslog Parser Time
        ...  btsId=${btsId}
        ...  message=has been changed from OnAirDone to Validated
        ...  timestamp=${START_OF_TIME_DICT['${btsId}']}
        ...  syslog_name=syslog_savepoint_start_of_upgrade
        ${start}=   get_last_cell_downtime    ${start_frame}
        ${stop_frame}=  Syslog Parser Time
        ...  btsId=${btsId}
        ...  message=has been changed from Validated to OnAirDone
        ...  timestamp=${START_OF_TIME_DICT['${btsId}']}
        ...  syslog_name=syslog_savepoint_start_of_upgrade
        ${stop}=   get_first_cell   ${stop_frame}
        ${diff_downtime}=   get_delta_time_in_seconds    ${start}    ${stop}
        ${diff_downtime_str}=  convert to string  ${diff_downtime}
        Set To Dictionary   ${downtime_dict}    ${btsId}=${diff_downtime_str}
    END
    set suite variable  ${DOWNTIME_LF_DICT}  ${downtime_dict}

Send Configuration Id
    [Arguments]    ${qc_id}    ${scf_id}=${None}    ${bts_id}=${TESTLINE_NAME}
    ...    ${case_name}=${TEST NAME}    ${case_result}=pass    ${sw}=${ACTIVE_SW_VERSION}
    ...    ${pass_number}=${1}    ${run_number}=${1}
    ...    ${testline}=${None}
    ${scout_testline_name}    Get Variable Value    ${GLO_SCOUT_TESTLINE_NAME}    ${TL_NAME}
    ${status}    Run Keyword And Return Status    Should Not End With    ${scout_testline_name}    _1
    ${status2}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${NODE_CFG}    CU_0
    ${scout_testline_name}    Set Variable If    ${status2} and ${NODE_CFG["${MASTER_BTS_ID}"].fullrack} and ${status}
    ...      ${scout_testline_name}_1    ${scout_testline_name}
    Send Scf Id To ReP    ${qc_id}    bts_id=${scout_testline_name}    case_name=${case_name}    case_result=${case_result}
    ...    sw=${sw}    testline=${scout_testline_name}
    Log    ${scf_id}
    Log    ${bts_id}
    Log    ${pass_number}
    Log    ${run_number}
    log    ${testline}

Report To Reporting Portal
    [Documentation]  Keyword send report to reporting portal and return link
    [Arguments]  ${test_run_name}    ${qc_id}=${QC_ID}    ${status}=passed  ${build}=${CANDIDATE}  ${test_case}=RESET    ${customer}=Optus
    ${test_run}=  convert to string  ${test_run_name}
    ${ca}=  convert to string  VRF_SiSo
    ${location}=  convert to string  VRF_HAZ
#     in order to better track / tribes / teams / testlines / please set you own CA - Competence Area
#     also set correct Testline naming for UUF wroclaw it's "SRAN_Wroclaw_"
#     you can check naming convention under below link
#     https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-line/?limit=1000
    ${testline}=  convert to string  ${HOSTNAME}    # 'department' and 'site' have to be correct  ==>  SRAN_Wroclaw
    Set Test Variable    ${qc_project}    RAN_ST
    ${qc_domain}=  convert to string    MN_RAN
    #${qc_project}=  convert to string   RAN_ST
    ${statusRelease}   ${result}   Run Keyword And Ignore Error     Should Contain    ${build}    SBTS00
    Run Keyword IF    '${statusRelease}'=='PASS'     Set Test Variable    ${qc_project}    RAN_VRF
    ${statusRelease}   ${result}   Run Keyword And Ignore Error     Should Contain    ${build}    SBTS25R1
    Run Keyword IF    '${statusRelease}'=='PASS'     Set Test Variable    ${qc_project}    RAN_VRF
#    ${qc_testlab_path}=  convert to string   ${TEST_PATH}
#    ${qc_set_name}=  convert to string   ${TESTSET_NAME}
    Get Testcase QcId
    Set Variable   ${qc_id}     ${QC_ID}
    ${LABEL}=  set variable
    ${comment}=  convert to string  UUF4ALL_${build}
    ${uuf_test}=  convert to string  True
    ${ru_type}=  convert to string  ${RU}
    ${sa/nsa_variant}=  convert to string    ${SA_OR_NSA}
    ${tdd/fdd_variant}=  convert to string    ${TDD_OR_FDD}
    ${hw_ids}=  convert to string    ${HW_ID}
    ${customers}=  create list
    append to list    ${customers}    ${customer}
    ${testline_type}=  convert to string  ${LABEL}
    ${starttime}=  Replace String  ${START_TIME}  -  ${EMPTY}
    ${endtime}=  Replace String  ${STOP_TIME}  -  ${EMPTY}
#    ${status1}     ${uptime}    Run Keyword And Ignore Error    get_time_gap_in_seconds    ${starttime}    ${endtime}
    ${RESET_TIME}=  set variable
    ${UPGRADE_TIME}=  set variable
    ${status1}     ${time_list1a}    Run Keyword And Ignore Error    Get Dictionary Values    ${kpi1a}
    ${status1}     ${time_list2a}    Run Keyword And Ignore Error   Get Dictionary Values    ${kpi2a}
    ${status1}     ${TIME1A}    Run Keyword And Ignore Error    Get From List    ${time_list1a}    0
    ${status1}     ${TIME2A}    Run Keyword And Ignore Error    Get From List    ${time_list2a}    0
    ${status1}     ${TIME_1A}    Run Keyword And Ignore Error    convert to string    ${TIME1A}
    ${status1}     ${TIME_2A}    Run Keyword And Ignore Error    convert to string    ${TIME2A}
    Run Keyword IF    '${test_case}'=='RESET'    Set Test Variable      ${RESET_TIME}    ${TIME_1A}
    Run Keyword IF    '${test_case}'=='Upgrade'    Set Test Variable      ${UPGRADE_TIME}    ${TIME_2A}
    ${statusarg}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${kpistatus}
    Run Keyword IF    '${statusarg}'=='FAIL'    Set Test Variable    ${kpistatus}    PASS
    ${statusup}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${uptime}
    Run Keyword IF    '${statusarg}'=='PASS' and '${statusup}'=='PASS' and '${kpistatus}'=='FAIL'
    ...    Set Test Variable      ${UPGRADE_TIME}    ${uptime}
    Get Label
    &{empty_dict}=  Create Dictionary
    Set Test Variable     ${inital_build}    ${build}
    Run Keyword IF    '${test_case}'=='Upgrade'    Set Test Variable     ${inital_build}    ${INITBUILD}

    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  ${time}[0]  ${time}[1]  ${time}[2]
    ${link_to_reporting_portal}=
    ...  ute_reporting_portal.report to rp
    ...  name=${test_run}
    ...  result=${status}
    ...  ca=${ca}
    ...  location=${location}
    ...  testline=${testline}
    ...  build=${build}
    ...  qc_domain=${qc_domain}
    ...  qc_project=${qc_project}
    ...  qc_id=${qc_id}
#    ...  qc_testlab_path=${qc_testlab_path}
#    ...  qc_test_set_name=${qc_set_name}
    ...  comment=${comment}
    ...  uuf_test=${uuf_test}
    ...  label=${EMPTY}
    ...  links=&{empty_dict}  # needs to be there because it is required for QC reports
    ...  parameter_1=${inital_build}  # initial build for UUF view (if True reports won't be matched to QC)
    ...  label=${LABEL}
    ...  starttime=${starttime}.000
    ...  endtime=${endtime}.000
    ...  ru_type=${ru_type}
    ...  sa/nsa_variant=${sa/nsa_variant}
    ...  tdd/fdd_variant=${tdd/fdd_variant}
    ...  upgrade_downtime=${UPGRADE_TIME}
    ...  reset_downtime=${RESET_TIME}
    ...  case_type=${test_case}
    ...  customers=${customers}
    ...  hw_id=${hw_ids}
    ...  tool=WebEM


    set suite variable  ${LINK_TO_RP}  ${link_to_reporting_portal}
    log to console with time  ${LINK_TO_RP}
    set suite variable  ${result_t}  failed
    Run Keyword IF    '${status}'=='passed'    set suite variable    ${result_t}    pass
    Run Keyword And Ignore Error     Wait Until Keyword Succeeds    5mins    10s
    ...    Send Configuration Id
    ...    qc_id=${qc_id}    bts_id=${testline}    case_name=${test_run}
    ...    case_result=${result_t}    sw=${build}    testline=${testline}
