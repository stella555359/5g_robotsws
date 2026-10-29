*** Settings ***
Documentation
  ...  Testline Reset Test UUF4ALL
  ...
  ...  Author Szymon Kramczynski
  ...  szymon.kramczynski@nokia.com
  ...  Modified by samraj.easterraj@nokia.com
  ...  Basic reset test in loops
  ...  Check cell status, fault list, ALD status and syslog messages in every iteration.
  ...  Gathers syslog, snapshot and IM log after fail
  ...  Recovers testline after test fails.

Force Tags          UUF   5G_RAN   RAN_5G   RAN_ST  5G_RAN_TDD   SISO   UUF
...                 SBTS00   STATE_SKIP_AGENT
...                 CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1B2B3_3xAEWD

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    testsuite/Paris/UUF/ST/AEWD/UUF_Software_upgrade.robot
Library     taf.rfrl.utilities.tl_config
Library     taf.rfrl.bts.commissioning
Library  Collections
Library  DateTime
Library  OperatingSystem
Library  Process
Library  String
Library  ute_admin
Library  ute_fsmaccess
Library  ute_reporting_portal
Library  ute_syslog

#Suite Setup      Full Commissioning Upgrade and OnAir Check

*** Variables ***
# declaration of variables so they exist if something go wrong retriving them in test
${UUF_RAND}=  XXXX
${LABEL}=
${HOSTNAME}=
# =========
${LOG_DIR}=  ${OUTPUTDIR}/RESET_TEST
${ENB_LMP_IP}=    192.168.255.1
${ENB_TRS_IP}=    192.168.255.129

${NUMBER_OF_LOOPS}=  10
${CHECK_CELL_COUNT}=  25     # *1 minute intervals
${CHECK_FAULT_COUNT}=  20    # *1 minutes intervals
${CHECK_ALD}=  True
${CHECK_SYSLOG}=  True
@{ALLOWED_FAULTS}=  61649  61652  61524  61510  4459  6455  4657  4655  4654
# Allowed Fault's Definition
#  "61649" - LMP access via port xx
#  "61652" - R&D Service Port enabled
#  "61524" - SSH enabled
#  "61510" - Automatic BTS Operator Certificate retrieval unsuccessful  /ipsec
#  "4459" - User Account has Default Password
#  "6455" - Service account root access is enabled
#  "4657"  - unsupported SFP
#  "4655" - Service account root access is enabled (from 21B)
#  "4654" - Ethernet port security is disabled (from 21B)
#  "4389" -  OTDOA PRS transmission disabled


${SAVE_LOGS_AFTER_TEST_PASS}=  False
${SAVE_LOGS_AFTER_TEST_FAIL}=  True

@{SWCONFIG_FLAGS}=  0x4F0214=0
${ADD_SWCONFIG_FLAGS}=  True

${RECOVER_TESTLINE_AFTER_FAIL}=  True
${RECOVERY_RESET_COUNT}=   3

*** Test Cases ***
#    run test with command
#    robot /home/ute/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/UUF/for_other_teams/RESET.robot

#    link to report (there can be deley due to RP parsing reports (~ 1h max)
#    https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?end_db=30&testRun=UUF4ALL
[1]5GC001423_SC_50_UUF_SWupgrade_in_loop
    UUF_Software_upgrade.PreConditions
    Update gNB Software To Current Build Candidate
    Wait For Site To Be Onair
    #Additional gNB Verification     run_tpt=${False}

#[1]UUF4ALL Reset of eNB without HWF in loop
#    Get reserved sw build
#    Get Label
#    Get Hostname
#    run keyword if  ${ADD_SWCONFIG_FLAGS}==${True}  Add Swconfig Flags  ${SWCONFIG_FLAGS}
#    Testline Precheck
#    : FOR  ${loop_nr}  IN RANGE  0  ${NUMBER_OF_LOOPS}
#    \  Log to console with time  ----------------------- RESET ${loop_nr+1}-----------------------
#    \  Generate Random Key
#    \  Perform Reset  ${RESERVED_BUILD}
#    [Teardown]  Run Keywords
#    ...       Run Keyword If Test Failed  run keyword if  ${SAVE_LOGS_AFTER_TEST_FAIL}  Log Collector  ${RESERVED_BUILD}
#    ...  AND  Run Keyword If Test Passed  run keyword if  ${SAVE_LOGS_AFTER_TEST_PASS}  Log Collector  ${RESERVED_BUILD}
#    ...  AND  Run Keyword If Test Failed  run keyword if  ${RECOVER_TESTLINE_AFTER_FAIL}  Recover Testline After Fail


*** Keywords ***
Update gNB Software To Current Build Candidate
    # When dealing with cloud, set flag by_nominal to True
    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Update gNB Software     sw_package_dir=${sw_package_path}

Perform Reset
    [Arguments]  ${initial_build}
    setup ute_syslog   ${initial_build}
    Wait Until Keyword Succeeds  5x  1m  Setup Admin For Alias    reset_testline
    log to console with time  Performing reset
    ${reset_status}=  run keyword and return status
        ...  ute_Admin.Reset  reset_coverage=Site  wait_for_reconnection=True  timeout=300  alias=reset_testline
    Wait Until Keyword Succeeds  20m  30s  Address Is Pingable  ${ENB_LMP_IP}
    log to console with time  eNB is pingable
    Wait Until Keyword Succeeds  ${CHECK_CELL_COUNT}x  1m  Check Cells  admin_alias=reset_testline
    Wait Until Keyword Succeeds  ${CHECK_FAULT_COUNT}x  1m  Check Faults  ${ALLOWED_FAULTS}  alias=reset_testline
    run keyword if  ${CHECK_ALD}  Wait Until Keyword Succeeds  20x  1m  Check ALD  alias=reset_testline
    run keyword if  ${CHECK_SYSLOG}  Syslog Parser  ${initial_build}

    [Teardown]  run keywords
    ...       run keyword and ignore error  ute_admin.Teardown Admin  alias=reset_testline
    ...  AND  run keyword and ignore error  Teardown All Aliases For Syslog
    ...  AND  run keyword if  '${KEYWORD STATUS}'=='PASS'  Report To Reporting Portal  passed
    ...  AND  run keyword if  '${KEYWORD STATUS}'=='FAIL'  Report To Reporting Portal  failed
    ...  AND  run keyword if  '${KEYWORD STATUS}'=='PASS' and '${SAVE_LOGS_AFTER_TEST_PASS}'=='False'
              ...  Run process  sudo rm -rfv ${LOG_DIR}/${RESERVED_BUILD}/${UUF_RAND}/  shell=True

Reset Testline
    [Arguments]  ${ip}=${ENB_LMP_IP}
    ${admin_status}=  run keyword and return status
    ...  Wait Until Keyword Succeeds  5x  1m  Setup Admin For Alias   reset_bts
    ${reset_status}=  run keyword if  ${admin_status}  run keyword and return status  ute_Admin.Reset  timeout=300  alias=reset_bts
    log to console with time  Admin reset status: ${reset_status}
    log to console with time  Reset completed. Waiting for eNB to be pingable...
    Wait Until Keyword Succeeds  20m  30s  Address Is Pingable  ${ip}
    log to console with time  eNB is pingable
    [Teardown]  run keyword
    ...       ute_Admin.teardown_admin  alias=reset_bts


Testline Precheck
    [Documentation]  Checks if testline is in correct state before reset test.
    Wait Until Keyword Succeeds  5x  1m  Setup Admin For Alias   testline_precheck
    Wait Until Keyword Succeeds  ${CHECK_CELL_COUNT}x  1m  Check Cells  admin_alias=testline_precheck
    Wait Until Keyword Succeeds  ${CHECK_FAULT_COUNT}x  1m  Check Faults  ${ALLOWED_FAULTS}  alias=testline_precheck
    [Teardown]  run keyword and ignore error  ute_admin.Teardown Admin  alias=testline_precheck

Get reserved sw build
    [Documentation]  Keyword return sw build on which TL was reserved.
    [Timeout]  2min
    ${reserved_sw_build_cmd}=
    ...  convert to string  cat /opt/ute/reservation.json | grep -o -P '"enb_build": (".+")' | awk -F '"' '{print $4}'
    ${reserved_sw_build}=  Run process  ${reserved_sw_build_cmd}  shell=True  cwd=${CURDIR}  timeout=3min
    Log  ${reserved_sw_build.stdout}  console=False
    set suite variable  ${RESERVED_BUILD}  ${reserved_sw_build.stdout}

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  convert to string  ${hostname_tmp}
    ${hostname_part}=  split string  ${hostname_tmp}  _
    ${hostname_combined}=  catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    set suite variable  ${HOSTNAME}  ${hostname_combined}

Get Label
    ${label_cmd}=  convert to string  cat /opt/ute/reservation.json | grep -o -P '"testline_type": (".+")' | awk -F '"' '{print $4}'
    ${label}=  Run process  ${label_cmd}  shell=True  cwd=${CURDIR}
    ${label}=  convert to string  ${label.stdout}
    log to console with time  ${label}
    Set Suite Variable  ${LABEL}  ${label}

Add Swconfig Flags
    [Documentation]  Adds swconfig flags from passed list, and performs reset.
    [Arguments]  ${flag_list}
    Setup Enb Fsm Access  host=${ENB_LMP_IP}
    log to console with time  Adding flags to swconfig...
    ${reset_needed}=  set variable  ${False}
    Execute Command On Enb  echo '' >> /ffs/run/swconfig.txt
    :FOR  ${FLAG}  IN  @{flag_list}
   \  ${removed_comments}=  split string  ${FLAG}  \#
   \  ${check_flag}=  Execute Command On Enb  cat /ffs/run/swconfig.txt
   \  ${status}=  Evaluate  """${removed_comments[0]}""" in """${check_flag}"""
   \  run keyword unless  ${status}  Execute Command On Enb  echo ${removed_comments[0]} >> /ffs/run/swconfig.txt
   \  run keyword if  ${status}  log to console with time  Flag: ${removed_comments[0]} already in swconfig
        ...  ELSE  log to console with time  Added flag:${removed_comments[0]}
   \  ${reset_needed}=  run keyword unless  ${status}  set variable  ${True}
    run keyword if  ${reset_needed}  log to console with time  Adding flags completed, Performing Reset Of Bts
    ...  ELSE  log to console with time  All flags already in swconfig, nothing to do.
    run keyword if  ${reset_needed}  Reset Testline
    [Teardown]  Teardown Enb Fsm Access


Check Cells
    [Documentation]    Check status of all cells configured on testline.
    [Arguments]    ${admin_alias}
    [Timeout]    10min
    set suite variable  ${TEST_PHASE}  Check Cells: ${admin_alias}
    log to console with time  -== Checking Cell Status ==-

    ${rc_l}  ${lncel_list}=  run keyword and ignore error  ute_admin.get_parameters_for_all
        ...  class_name=LNCEL  alias=${admin_alias}  timeout=60
    ${rc_w}  ${wncel_list}=  run keyword and ignore error  ute_admin.get_parameters_for_all
        ...  class_name=WNCEL  alias=${admin_alias}  timeout=60
    ${rc_g}  ${gncel_list}=  run keyword and ignore error  ute_admin.get_parameters_for_all
        ...  class_name=GNCEL  alias=${admin_alias}  timeout=60
    ${rc_n}  ${nrcel_list}=  run keyword and ignore error  ute_admin.get_parameters_for_all
        ...  class_name=NRCEL  alias=${admin_alias}  timeout=60


    # there is no such structure in FL18A/some releases so it have to be handled like this because FOR won't find variable
    # so create empty list because there is error message in (x)ncel_list variable after kw fail
    @{lncel_list}=  run keyword if  '${rc_l}'=='FAIL'   create list
    ...  ELSE  set variable  ${lncel_list}
    @{wncel_list}=  run keyword if  '${rc_w}'=='FAIL'   create list
    ...  ELSE  set variable  ${wncel_list}
    @{gncel_list}=  run keyword if  '${rc_g}'=='FAIL'   create list
    ...  ELSE  set variable  ${gncel_list}
    @{nrcel_list}=  run keyword if  '${rc_n}'=='FAIL'   create list
    ...  ELSE  set variable  ${nrcel_list}

    ${lncel_list_length}=  get length  ${lncel_list}
    ${wncel_list_length}=  get length  ${wncel_list}
    ${gncel_list_length}=  get length  ${gncel_list}
    ${nrcel_list_length}=  get length  ${nrcel_list}

    run keyword if  '${lncel_list_length}'=='0' and '${wncel_list_length}'=='0'
    ...  run keyword if  '${gncel_list_length}'=='0' and '${nrcel_list_length}'=='0'
    ...  Fail  cell_list_length==0 waiting for correct cell list

    # print
    log to console with time  ${SPACE * 5}-= Checking LTE Cells=-
    : FOR  ${cell}  IN  @{lncel_list}
    \  log to console with time
    ...  ${SPACE * 7} [${cell['proceduralState']}, ${cell['operationalState']}, ${cell['administrativeState']}]

    log to console with time  ${SPACE * 5}-=Checking WCDMA Cells=-
    : FOR  ${cell}  IN  @{wncel_list}
    \  log to console with time
    ...  ${SPACE * 7} [${cell['availabilityStatus']}, ${cell['operationalState']}]

    log to console with time  ${SPACE * 5}-=Checking GSM Cells=-
    : FOR  ${cell}  IN  @{gncel_list}
    \  log to console with time
    ...  ${SPACE * 7} [${cell['availabilityStatus']}, ${cell['operationalState']}, ${cell['administrativeState']}]

    log to console with time  ${SPACE * 5}-=Checking 5G Cells=-
    : FOR  ${cell}  IN  @{nrcel_list}
    \  log to console with time
    ...  ${SPACE * 7} [${cell['operationalState']}, ${cell['administrativeState']}]

    # check
    # LNCEL (LTE)
    : FOR  ${cell}  IN  @{lncel_list}
    \  run keyword if
    ...           '${cell['proceduralState']}'!='OnAirDone'  Fail  Incorrect cell status
    ...  ELSE IF  '${cell['availabilityStatus']}'!='Online'  Fail  Incorrect cell status
    ...  ELSE IF  '${cell['operationalState']}'!='Enabled'  Fail  Incorrect cell status
    ...  ELSE IF  '${cell['administrativeState']}'!='Unlocked'  Fail  Incorrect cell status
    # WNCEL (WCDMA)
    : FOR  ${cell}  IN  @{wncel_list}
    \  run keyword if
    ...           '${cell['availabilityStatus']}'!='Online'  Fail  Incorrect cell status
    ...  ELSE IF  '${cell['operationalState']}'!='Enabled'  Fail  Incorrect cell status
    # GNCEL (GSM)
    : FOR  ${cell}  IN  @{gncel_list}
    \  run keyword if
    ...           '${cell['availabilityStatus']}'!='Online'  Fail  Incorrect cell status
    ...  ELSE IF  '${cell['operationalState']}'!='Enabled'  Fail  Incorrect cell status
    ...  ELSE IF  '${cell['administrativeState']}'!='Unlocked'  Fail  Incorrect cell status
    # NRCEL (5G)
    : FOR  ${cell}  IN  @{nrcel_list}
    \  run keyword if
    ...           '${cell['operationalState']}'!='Enabled'  Fail  Incorrect cell status
    ...  ELSE IF  '${cell['administrativeState']}'!='Unlocked'  Fail  Incorrect cell status
    [Teardown]  Run Keywords
    ...       run keyword if  '${KEYWORD STATUS}'=='PASS'  Log to console with time  ->Cells looks OK
    ...  AND  run keyword if  '${KEYWORD STATUS}'=='FAIL'  Log to console with time  ->Incorrect cell status


Check Faults
    [Documentation]
    ...  Check current faults on testline and faills if unexpected alarms apperas.
    [Arguments]  ${allowed_fault_list}  ${alias}
    [Timeout]  120s
    log to console with time  -== Checking Faults ==-
    ${alarm_list}=  ute_admin.get_alarms  alias=${alias}
    @{last_faults_list}=  create list
    : FOR  ${alarm}  IN  @{alarm_list}
    \  append to list  ${last_faults_list}  ${alarm['faultId']}
    \  ${alarm_string}=  convert to string  ${alarm}
    \  ${alarm_id_matches}=  get regexp matches  ${alarm_string}  (alarmId|alarmNumber)':\\s(\\d+)  2
    \  ${fault_id_matches}=  get regexp matches  ${alarm_string}  faultId':\\s(\\d+)  1
    \  ${fault_description}=
    ...  get regexp matches  ${alarm_string}  (faultDescription|alarmDetail)': u{0,1}'([a-z,A-Z,0-9&!@#$%^*()+-_:; ]{0,100})'  2
    \  Append To List  ${fault_description}  Unable to find fault Description probably unsupported sign in string.
    \  log to console with time   ${SPACE * 5}Alarm: ${alarm_id_matches[0]} Fault: ${fault_id_matches[0]} ${fault_description[0]}


    set suite variable  ${LAST_FAULTS}  ${last_faults_list}
    : FOR  ${alarm}  IN  @{alarm_list}
    \  ${alarm_string}=  convert to string  ${alarm}
    \  ${fault_id_matches}=  get regexp matches  ${alarm_string}  faultId':\\s(\\d+)  1
    \  ${status}=   Evaluate  str("""${fault_id_matches[0]}""") in @{allowed_fault_list}
    \  Should Be True  ${status}  msg=Alarm ${fault_id_matches[0]} Not In Allowed List ${allowed_fault_list}


Check ALD
    [Documentation]  This keyword will check status of ALDs modules(pass = enabled, fail = other than enaled).
    [Arguments]  ${alias}=${alias}
    log to console with time  -== Checking ALDs ==-
    ${ald_dict}=  ute_admin.get_parameters_for_all  class_name=ALD  timeout=60s  alias=${alias}
    Log to console with time  ${EMPTY}
    : FOR  ${ald}  IN  @{ald_dict}
    \  log to console with time  [${ald['availabilityStatus']}, ${ald['operationalState']}]
    : FOR  ${ald}  IN  @{ald_dict}
    \  run keyword if  '${ald['operationalState']}'!='Enabled' and '${ald['availabilityStatus']}'!='Online'
        ...  Fail  log to console with time  [${ald['availabilityStatus']}, ${ald['operationalState']}]
    log to console with time  -====== All ALDs Detected ======-


Syslog Parser
    [Documentation]  Keyword search in syslog for 6450/diagnostic files collected 'like' errors but not causing any faults.
    [Arguments]  ${build}
    log to console with time  Parsing Syslog
    @{syslog_messages}=  create list
    ...  -=-=.
    ...  Please contact the owner of

    @{found_messages}=   create list
    Collect from Savepoint   savepoint=${start_of_loop}
        ...  destination_file=${LOG_DIR}/${build}/${UUF_RAND}/syslog_parser
        ...  compress=True
        ...  alias=main_syslog
    :FOR  ${message}  IN  @{syslog_messages}
    \  ${items} =  run keyword and ignore error  Message should exist in syslog file
        ...  regexp=${message}
        ...  savepoint=${SYSLOG_PARSER}
        ...  alias=main_syslog
    \  run keyword if  '${items[0]}'=='PASS'  log to console with time  items: ${items}
    \  run keyword if  '${items[0]}'=='PASS'  append to list  ${found_messages}  ${items}

    ${messages_length}=  get length  ${found_messages}
    run keyword if  ${messages_length}>0  Fail  Syslog Parser Failed due to: ${found_messages}


Setup Admin For Alias
    [Documentation]  Setups ute_admin library on given alias.
    [Arguments]  ${alias}
    log to console with time  Setting UP ute_admin: ${alias}
    ute_admin.setup admin
        ...  bts_host=${ENB_LMP_IP}
        ...  bts_port=3600
        ...  admin_api_log_dir=${LOG_DIR}/admin_logs/
        ...  alias=${alias}
    [Teardown]  run keyword if  '${KEYWORD STATUS}'=='FAIL'  ute_admin.Teardown Admin  alias=${alias}


Log to console with time
    [Documentation]  Keyword display,log output with time.
    [Arguments]  ${output}
    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  @{time}[0]  @{time}[1]  @{time}[2]
    Log  (${time_now}) ${output}  console=True


Address Is Pingable
    [Documentation]  Keyword checks if given ip address is pingable.
    [Arguments]  ${ENB_IP}=${ENB_LMP_IP}
    ${rc}=  Run And Return Rc  ping -c 1 ${ENB_IP}
    should be equal as integers  ${rc}  0


Generate Random Key
    [Documentation]  Generates ramdom string for log name purpose.
    ${UUF_rand} =  String.Generate Random String  5  [UPPER]
    set suite variable  ${UUF_RAND}  ${UUF_rand}
    log to console with time  ${UUF_RAND}


Setup ute_syslog
    [Documentation]  Keyword for setting up ute_syslog library.
    [Arguments]  ${initial_build}
    # cleanup
    run keyword and ignore error  collect Syslog Results
        ...  destination=${LOG_DIR}/teardown.tar.gz
        ...  unzip=${False}
        ...  alias=main_syslog
    run keyword and ignore error  Teardown All Aliases For Syslog

    log to console with time  Setting Up ute_syslog
    Wait Until Keyword Succeeds  5m  30s
        ...  ute_syslog.start syslog
            ...  log_dir=${LOG_DIR}/${initial_build}/${UUF_RAND}/
            ...  log_name=syslog_backup_${UUF_RAND}.log
            ...  file_limit=209715200  # 200MB
            ...  add_line_number=True
            ...  alias=main_syslog

    ${start_of_loop}=  Capture Savepoint    alias=main_syslog
    set suite variable  ${START_OF_LOOP}  ${start_of_loop}


Log Collector
    [Documentation]  Gathers syslog, snapshot and Infomodel log.
    [Arguments]  ${sw_build}
    log to console with time  Gathering Logs
    ${admin_3600_status}=  run keyword and return status
        ...  Wait Until Keyword Succeeds  5x  1m  Setup Admin For Alias  admin_logs_3600

    log to console with time  Gathering ute_admin IMS
    run keyword if  ${admin_3600_status}  run keyword and ignore error
        ...  ute_admin.Collect Im Snapshot
            ...  target_file_name=${LOG_DIR}/${sw_build}/${UUF_RAND}/IMS_admin_${sw_build}_${UUF_RAND}_3600.ims2
            ...  alias=admin_logs_3600

    log to console with time  Gathering ute_admin Snapshot
    run keyword if  ${admin_3600_status}  run keyword and ignore error  Wait Until Keyword Succeeds  3x  30s
    ...  ute_admin.Collect Snapshot
        ...  target_file_name=${LOG_DIR}/${sw_build}/${UUF_RAND}/snapshot_${sw_build}_${UUF_RAND}_3600.zip
        ...  timeout=1200
        ...  alias=admin_logs_3600

    log to console with time  Gathering ute_syslog
    run keyword and ignore error  collect Syslog Results
        ...  destination=${LOG_DIR}/${sw_build}/${UUF_RAND}/syslog_${sw_build}_${UUF_RAND}.tar.gz
        ...  unzip=${False}
        ...  alias=main_syslog
    [Teardown]  run keyword
    ...       run keyword if  ${admin_3600_status}  ute_admin.Teardown Admin  alias=admin_logs_3600

Recover Testline After Fail
    [Documentation]  Keyword performs reset in order to recover testline after fail
    log to console with time  Recovering Testline After Fail
    :FOR  ${reset_count}  IN RANGE  ${RECOVERY_RESET_COUNT}
    \  log to console with time  -= Recovering Testline attempt: ${reset_count+1} =-
    \  Reset Testline
    \  ${status}=  run keyword and return status  Testline Precheck
    \  Exit For Loop If  ${status}
    run keyword unless  ${status}  Fail  Unable to Recover Testline after ${RECOVERY_RESET_COUNT} resets.
    run keyword if  ${status}  Log to console with time  Testline Recovered Successfully.

Full Commissioning Upgrade and OnAir Check
     #Perform Full Commissioning on Classical gNB
     Update gNB Software To Current Build Candidate
     Wait For Site To Be Onair

Report To Reporting Portal
    [Documentation]  Keyword send report to reporting portal and return link
    [Arguments]  ${status}=passed  ${build}=${RESERVED_BUILD}
    ${test_run}=  convert to string  UUF4ALL_RESET_TEST_NPS
    ${ca}=  convert to string  RAN_PZ_NPS

    # testline name check
    # https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-line/?limit=1000
    ${testline}=  convert to string  5G_Paris-SyVe_${HOSTNAME}

    # have to be present in RP report
    ${qc_domain}=  set variable
    ${qc_project}=  set variable
    ${qc_id}=  set variable

    ${comment}=  convert to string  UUF4ALL_${build}
    ${uuf_test}=  convert to string  True
    ${testline_type}=  convert to string  ${LABEL}

    ${link_to_reporting_portal}=
    ...  ute_reporting_portal.report to rp
    ...  name=${test_run}
    ...  result=${status}
    ...  ca=${ca}
    ...  testline=${testline}
    ...  build=${build}
    ...  qc_domain=${qc_domain}
    ...  qc_project=${qc_project}
    ...  qc_id=${qc_id}
    ...  comment=${comment}
    ...  uuf_test=${uuf_test}
    ...  label=${testline_type}
    ...  parameter_1=${build}  # initial build fo UUF view


    set suite variable  ${LINK_TO_RP}  ${link_to_reporting_portal}
    log to console with time  ${LINK_TO_RP}
