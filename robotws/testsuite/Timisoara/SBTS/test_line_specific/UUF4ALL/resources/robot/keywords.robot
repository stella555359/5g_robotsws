*** Settings ***
Documentation
  ...  UUF4ALL Keywords
  ...
  ...  Author Szymon Kramczynski
  ...  szymon.kramczynski@nokia.com
  ...
  ...  Keywords for UUF4ALL Upgrade/Reset in loop
  ...  for single/multi node tesltines

Library  ../python/python_keywords.py
Library  ../python/wftdownloader.py
Library  ../python/uuf_reporting_portal.py

Library  OperatingSystem
Library  Process
Library  String
Library  DateTime
Library  Collections
Library  ute_async
Library  ute_fsmaccess
Library  ute_syslog
Library  ute_reporting_portal
Library  taf.sbts.oam.coam.admin  WITH NAME  admin


*** Variables ***
${ENB_LMP_IP}=    192.168.255.1
${ENB_TRS_IP}=    192.168.255.129
${ENB_RFS_IP}=    192.168.255.127

${ENB_ROOT_USER}=  toor4nsn
${ENB_ROOT_PASS}=  oZPS0POrRieRtu
${ENB_USER}=       Nemuadmin
${ENB_PASS}=       nemuuser
${VM_USER}=  ute

${sw_cache}=       /home/ute/.ute-ca/cache/bts
${config_dir}=   /home/ute/testline_configuration


${LOG_DIR}=  /home/ute/test_results
${ADMIN_LOG_DIR}=  ${LOG_DIR}
@{blackbox_prints}=  Recovery \\(Execute reset.\\)  Spurious reset  Spurious BTS reset  Unknown \\(Execute reset.\\)  Spurious warm reset


${RESERVED_BUILD}=         ${EMPTY}
${KW_FAULT_MESSAGE}=       ${EMPTY}
${LABEL}=                  ${EMPTY}
${RESET_TIME}=             ${EMPTY}
${DOWNTIME}=               ${Empty}
${AMOUNT_OF_CELLS}=        ${Empty}
${TEST_PHASE}=             ${Empty}
*** Keywords ***


Get reserved sw build
    [Documentation]  Keyword return sw build on which TL was reserved.
    [Timeout]  2min
    set suite variable  ${KEYWORD_NAME}  Get reserved sw build
    ${reserved_sw_build_cmd}=
    ...  convert to string  cat /opt/ute/reservation.json | grep -o -P '"enb_build": (".+")' | awk -F '"' '{print $4}'
    ${reserved_sw_build}=  Run process  ${reserved_sw_build_cmd}  shell=True  cwd=${CURDIR}  timeout=3min
    Log  ${reserved_sw_build.stdout}  console=False
    set suite variable  ${RESERVED_BUILD}  ${reserved_sw_build.stdout}

Set Candidate
    [Documentation]  Keyword for setting build to which testline will be upgraded.
    ...  Candidate should be passed in testrun command --variable CANDIDATE_SW:build_to_which_we_upgrade
    ...  If not Upgrade will be performed to UTE build on which testline was reserved from(/opt/ute/reservation.json)
    set suite variable  ${KEYWORD_NAME}  Set Candidate
    ${status}=  run keyword and return status  Variable Should Exist  ${CANDIDATE_SW}
    run keyword unless  ${status}  Get reserved sw build
    run keyword if  ${status}  set suite variable  ${CANDIDATE}  ${CANDIDATE_SW}
    ...  ELSE  set suite variable  ${CANDIDATE}  ${RESERVED_BUILD}


Get Hostname
    [Documentation]  Keyword Gets Hostname of Vm on which test is running and cut suffix with vm index.
    ...  Used to Map VM hostname for dictionary key in tl_config.py
    set suite variable  ${KEYWORD_NAME}  Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${can_split}=     Evaluate  str("""-""") in str("""${hostname_tmp}""")
    ${hostname_s}=   run keyword if  ${can_split}  Replace String  ${hostname_tmp}  -  _
    ${hostname_s}=   run keyword if  ${can_split}  convert to string  ${hostname_s}
    ${hostname_part}=  run keyword if  ${can_split}  split string  ${hostname_s}  _
    ${hostname_combined}=  run keyword if  ${can_split}  catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}

    ${set_hostname}=  run keyword if  ${can_split}  set variable  ${hostname_combined}
    ...  ELSE  set variable  ${hostname_tmp}
    set suite variable  ${HOSTNAME}  ${set_hostname}

Get Label
    [Documentation]  Currently not Usec but can be added to report of UTE Testlines
    set suite variable  ${KEYWORD_NAME}  Get Label
    ${label_cmd}=  convert to string  cat /opt/ute/reservation.json | grep -o -P '"testline_type": (".+")' | awk -F '"' '{print $4}'
    ${label}=  Run process  ${label_cmd}  shell=True  cwd=${CURDIR}
    ${label}=  convert to string  ${label.stdout}
    log to console with time  ${label}
    Set Suite Variable  ${LABEL}  ${label}

Get Vm Password
   [Documentation]  Get Current Vm password (also in singe run) needed to run syslog on remote nodes.
   set suite variable  ${KEYWORD_NAME}  Get VM Password
   ${password}=  run process  sudo cat /etc/ute/vncpasswd  shell=True
   set suite variable  ${VM_PASSWORD}  ${password.stdout}

Get Vm IP
    [Documentation]  Keyword for geting VM IP on which test runs. Log are sent to this vm.
    set suite variable  ${KEYWORD_NAME}  Get VM IP
    ${vm_ip_command}=  convert to string  /sbin/ifconfig eth0 | grep 'inet' | cut -d: -f2 | awk '{ print $2}' | tr -s '\n'
    ${rc}  ${vm_ip}=  Run And Return Rc And Output  ${vm_ip_command}
    ${vm_ip}=  convert to string  ${vm_ip}
    set suite variable  ${TEST_VM_IP}  ${vm_ip}



Map Variables
    [Documentation]  Keyword that maps variables form tl_config.py so they can be used easier than a dictionary.
    [Arguments]  ${tl_config_path_and_name}=${TL_CONFIG_PATH_AND_NAME}
    set suite variable  ${KEYWORD_NAME}  Map Variables
    Import Variables  ${tl_config_path_and_name}
    ${tmp_var}=  set variable  ${config['${HOSTNAME}']}

     run keyword and ignore error  Set Suite Variable  ${NUMBER_OF_RESET_LOOPS}  ${tmp_var['NUMBER_OF_RESET_LOOPS']}
     run keyword and ignore error  Set Suite Variable  ${NUMBER_OF_UPGRADE_LOOPS}  ${tmp_var['NUMBER_OF_UPGRADE_LOOPS']}
     run keyword and ignore error  Set Suite Variable  ${STOP_TEST_AFTER_FAIL}  ${tmp_var['STOP_TEST_AFTER_FAIL']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_CELLS}  ${tmp_var['CHECK_CELLS']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_FAULTS}  ${tmp_var['CHECK_FAULTS']}
     run keyword and ignore error  Set Suite Variable  ${PERFORM_UPGRADE}  ${tmp_var['PERFORM_UPGRADE']}
     run keyword and ignore error  Set Suite Variable  ${PERFORM_ROLLBACK}  ${tmp_var['PERFORM_ROLLBACK']}
     run keyword and ignore error  Set Suite Variable  ${PERFORM_RESET}  ${tmp_var['PERFORM_RESET']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_VALIDATION}  ${tmp_var['CHECK_VALIDATION']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_BLACKBOX}  ${tmp_var['CHECK_BLACKBOX']}
#     run keyword and ignore error  Set Suite Variable  ${CHECK_SCF}  ${tmp_var['CHECK_SCF']}
#     run keyword and ignore error  Set Suite Variable  ${CHECK_ERR_WRN}  ${tmp_var['CHECK_ERR_WRN']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_SYSLOG}  ${tmp_var['CHECK_SYSLOG']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_ALD}  ${tmp_var['CHECK_ALD']}
     run keyword and ignore error  Set Suite Variable  ${UBOOT_DOWNGRADE}  ${tmp_var['UBOOT_DOWNGRADE']}
     run keyword and ignore error  Set Suite Variable  ${ADD_SWCONFIG_FLAGS}  ${tmp_var['ADD_SWCONFIG_FLAGS']}
     run keyword and ignore error  Set Suite Variable  ${SAVE_LOGS_AFTER_TEST_PASS}  ${tmp_var['SAVE_LOGS_AFTER_TEST_PASS']}
     run keyword and ignore error  Set Suite Variable  ${SAVE_LOGS_AFTER_TEST_FAIL}  ${tmp_var['SAVE_LOGS_AFTER_TEST_FAIL']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_CELL_COUNT}  ${tmp_var['CHECK_CELL_COUNT']}
     run keyword and ignore error  Set Suite Variable  ${CHECK_FAULT_COUNT}  ${tmp_var['CHECK_FAULT_COUNT']}
     run keyword and ignore error  Set Suite Variable  ${COLLECT_SYSLOG}  ${tmp_var['COLLECT_SYSLOG']}
     run keyword and ignore error  Set Suite Variable  ${COLLECT_SNAPSHOT}  ${tmp_var['COLLECT_SNAPSHOT']}
     run keyword and ignore error  Set Suite Variable  ${SERIAL_CONSOLE_ON}  ${tmp_var['SERIAL_CONSOLE_ON']}
     run keyword and ignore error  Set Suite Variable  ${RECOVER_TESTLINE}  ${tmp_var['RECOVER_TESTLINE']}
     run keyword and ignore error  Set Suite Variable  ${RECOVERY_RESET_COUNT}  ${tmp_var['RECOVERY_RESET_COUNT']}
     run keyword and ignore error  Set Suite Variable  ${RP_REPORT}  ${tmp_var['RP_REPORT']}
     run keyword and ignore error  Set Suite Variable  ${COMPASS_REPORT}  ${tmp_var['COMPASS_REPORT']}
     run keyword and ignore error  Set Suite Variable  &{TL_CONFIG}  &{tmp_var['TL_CONFIG']}
     run keyword and ignore error  Set Suite Variable  &{REPORT}  &{tmp_var['REPORT']}


Generate Random String
    [Documentation]  Keyword generates random string for loging purpose.
    [Arguments]  ${string_length}
    set suite variable  ${KEYWORD_NAME}  Generate Random String
    ${UUF_rand} =  String.Generate Random String  ${string_length}  [UPPER]
    run keyword if  ${DEBUG}  set suite variable  ${UUF_RAND}  DEBUG
    ...  ELSE  set suite variable  ${UUF_RAND}  ${UUF_rand}
    [Return]  ${UUF_RAND}


Get File From Directory
    [Documentation]  Checks if file exist in directory and returns full filename.
    [Arguments]  ${path}  ${name}
    set suite variable  ${KEYWORD_NAME}  Get File From Directory
    @{file_name}=  create list
    ${rc}  ${file_name}=  run keyword and ignore error  OperatingSystem.List Files In Directory  ${path}  ${name}
    ${status}=  run keyword and return status   Should Not Be Empty  ${file_name}
    @{result}=  run keyword If  ${status} and "${rc}"=="PASS"  create list  ${True}  ${file_name[0]}
    ...  ELSE  create list  ${False}  ${EMPTY}
    [Return]  ${result[0]}  ${result[1]}

Setup Admin For Alias
    [Documentation]  Setups admin library on given alias.
    [Arguments]    ${alias}  ${lmp_ip}=${ENB_LMP_IP}
    set suite variable  ${KEYWORD_NAME}  Setup Admin For Alias
    log to console with time  Setting up admin on alias: ${alias}
    ${setup_status}=  run keyword and return status  admin.setup admin
        ...  bts_host=${lmp_ip}
        ...  bts_port=443
        ...  admin_api_log_dir=${ADMIN_LOG_DIR}/node${THIS_NODE}/admin_logs/
        ...  name=${alias}
    log to console with time  Admin Setup Status: ${setup_status}
    run keyword unless  ${setup_status}  Fail  Setup Admin Failed
    [Return]  ${setup_status}
    [Teardown]  run keyword and ignore error
    ...  run keyword if  '${KEYWORD STATUS}'=='FAIL'
    ...  run keyword and ignore error  admin.Teardown Admin  connection=${alias}

Address Is Pingable
    [Documentation]  Check if given IP is pingable.
    [Arguments]  ${lmp_ip}=${ENB_LMP_IP}
    set suite variable  ${KEYWORD_NAME}  Address Is Pingable
    log to console with time  Pinging ${lmp_ip}
    ${rc}=  Run And Return Rc  ping -c 1 ${lmp_ip}
    should be equal as integers  ${rc}  0

eNB Should Be Unavailable
    [Documentation]  Waits untill given IP is not pingable.
    [Arguments]  ${lmp_ip}=${ENB_LMP_IP}  ${timeout}=300
    log to console with time  Waiting Until eNB not pingable...
    set suite variable  ${KEYWORD_NAME}  eNB Should Be Unavailable
    wait until keyword succeeds  ${timeout}x  1 sec  Run keyword and expect error  *  Address Is Pingable  ${lmp_ip}
    log to console with time  eNB Not Pingable


Admin Upgrade
    [Documentation]  Upgrade Software on eNB/gNB by taf admin library.
    [Arguments]  ${candidate}  ${admin_alias}  ${wait_for_unavailable}=${True}
    set suite variable  ${KEYWORD_NAME}  Admin Upgrade
    Log to console with time  ${EMPTY}
    Log to console with time  --== Admin Upgrade Ongoing to ${candidate} ==-
    ${rc}  ${file_name}=  Get file from directory
    ...  ${sw_cache}/${candidate}/  *${candidate}_release_BTSSM_downloadable*.zip
    admin.wait_sw_update_possible  connection=${admin_alias}  timeout=15m
    run keyword if  ${rc}  admin.Update Software
    ...  sw_package=${sw_cache}/${candidate}/${file_name}
    ...  should_activate=True
    ...  timeout=2000
    ...  connection=${admin_alias}
    ...  ELSE  Fail  Software Not Found ${candidate}
    [Teardown]  run keyword
    ...       run keyword if  '${KEYWORD STATUS}'=='PASS'  set suite variable  ${TEST_PHASE}  after_upgrade

Rollback
    [Documentation]  Rollback software with taf admin library.
    [Arguments]  ${admin_alias}  ${timeout}=500
    set suite variable  ${KEYWORD_NAME}  Rollback
    Log to console with time  ${EMPTY}
    Log to console with time  --== Admin Rollback Ongoing ==-
    ${status}=  admin.rollback_software  timeout=${timeout}  connection=${admin_alias}
    log to console with time  ${status}
    Log to console with time  eNB Is Unavailable
    Log to console with time  Rollback Finished, Waiting For eNB To Be Pingable
    [Teardown]  run keyword
    ...       run keyword if  '${KEYWORD STATUS}'=='PASS'  set suite variable  ${TEST_PHASE}  before_upgrade

Setup admin And Get Active Software
    [Documentation]  Setups Admin on alias and returns sets variables for active and passive software.
    [Arguments]  ${alias}  ${lmp_ip}=${ENB_LMP_IP}
    set suite variable  ${KEYWORD_NAME}  Setup admin And Get Active Software
    ${setup_status}=  Setup Admin For Alias  alias=${alias}  lmp_ip=${lmp_ip}
    run keyword unless  ${setup_status}  Fail  Setup Admin Failed
    &{bts_info}=  admin.get_bts_info  connection=${alias}  timeout=60
    # not commissioned  'swInfo': {u'swVersion': u'SBTS20A_ENB_0000_001446_000000'}
    #    commissioned   'swInfo': {u'swVersion': u'', u'lteRatVersion': u'SBTS20A_ENB_0000_001446_000000'}
    # 5G commissioned   'swInfo': {u'swVersion': u'5G20A_GNB_0009_001800_000185'},

    ${sw_info}=  get from dictionary    ${bts_info}   swInfo
    ${sw_info_string}=  convert to string  ${sw_info}
    ${active_sw_regex}=  get regexp matches  ${sw_info_string}  'swVersion': (u){0,1}'([a-z,A-Z,0-9,.,_]{0,40})'  2
    ${sw_info_test}=   admin.Get Software Info  connection=${alias}
    ${active_sw}=  set variable  ${active_sw_regex[0]}
    run keyword if  '${active_sw}'==''  fail  Active Software entry not found

    run keyword and ignore error  log to console with time  Active SW: ${active_sw}
    run keyword and ignore error  log to console with time  Passive SW: ${sw_info_test['Passive SW version']}
    set suite variable  ${ACTIVE_SW}  ${active_sw}
    set suite variable  ${PASSIVE_SW}  ${sw_info_test['Passive SW version']}

    [Return]  ${setup_status}  ${active_sw}
    [Teardown]  run keyword
    ...       Run keyword if  '${KEYWORD STATUS}'=='FAIL'  run keyword and ignore error  admin.teardown_admin  connection=${alias}


Wait for software change
    [Documentation]  Due to "small update" feature which triggers upgrade on active partition keyword need to check
    ...  active and passive software.
    [Arguments]    ${expected_active_sw}  ${expected_passive_sw}  ${wait_for_unavailable}=${True}  ${check_passive_sw}=${True}
    set suite variable  ${KEYWORD_NAME}  Wait for software change

    ${unavailable_status}=  run keyword and return status
    ...  run keyword if  ${wait_for_unavailable}   eNB Should Be Unavailable  ${TL_CONFIG['${THIS_NODE}']['LMP_IP']}  60
    ${setup_status}  ${active_SW}=  run keyword unless  ${unavailable_status}  Wait Until Keyword Succeeds  10x  1m
    ...  Setup admin And Get Active Software  alias=sw_change_check
    ${sw_status}=  run keyword unless  ${unavailable_status}  Check if sw is correct  ${active_SW}  ${expected_active_sw}
    Run Keyword If  ${sw_status} or ${unavailable_status}
        ...  log to console with time  SW Changed status: ${sw_status}, Not Pingable Status: ${unavailable_status}
    ...  ELSE  Fail  Enb was available and sw didn't change

    ${passive_sw_status}=   run keyword if  '${unavailable_status}'=='${False}' and ${check_passive_sw}
    ...  Check if sw is correct  ${PASSIVE_SW}  ${expected_passive_sw}

    run keyword if  '${unavailable_status}'=='${False}' and ${check_passive_sw}
    ...  run keyword if  ${sw_status} and "${passive_sw_status}"=="False"   set suite variable  ${NO_REBOOT_UPGRADE}  ${True}


Download Build
    [Documentation]  Downloads given build from WFT.
    [Arguments]  ${build}  ${path}  ${soft_build}=${True}  ${btssm}=${False}  ${puttibatti}=${False}
    set suite variable  ${KEYWORD_NAME}  Download Build
    run process  mkdir -p ${path}  shell=True
    ${rc_file_exists}  ${filename}=  Get file from directory
    ...  ${path}/${build}/  ${build}_release_BTSSM_downloadable*.zip


    run keyword unless  ${rc_file_exists}  Log to console with time  Downloading ${build}
    ${command}=  run keyword unless  ${rc_file_exists}  convert to string  sudo mkdir -p ${build};sudo chown -R ute:ute *
    ${rc}=       run keyword unless  ${rc_file_exists}  Run process  ${command}  shell=True  cwd=${path}
    @{status}=   run keyword unless  ${rc_file_exists}  download_software
    ...  software_table=${build}
    ...  download_path=${path}/${build}
#    ...  api_key=${WFT_API_KEY}
    ...  soft_build=${soft_build}
    ...  btssm=${btssm}
    ...  puttibatti=${puttibatti}
    run keyword unless  ${rc_file_exists}
    ...  log to console with time  ${build} result Soft: ${status[0]}, BTSSM: ${status[1]}, Puttibatti: ${status[2]}

Check if sw is correct
    [Documentation]  Check if active software it expected one.
    [Arguments]  ${active_sw}  ${expected_sw}
    set suite variable  ${KEYWORD_NAME}  Check if sw is correct

    # expected
    # 5G20B_GNB_0010_       001800_000683
    # 0.                    1800.683
    # 11.                   800.1959-26qsc
    # active
    # SBTS20C_ENB_0000_     001623_000000
    # SBTS00_ENB_0000_      001623_000000
    # 5G21A_GNB_0011_       000800_001959_26qsc  # knife

    ${active_splited}=      split string  ${active_sw}    _

    # check if 5g or 5g knife
    ${5G_check}=     Evaluate  str(""".""") in str("""${expected_sw}""")
    ${knife_build}=  Evaluate  str("""-""") in str("""${expected_sw}""")
    ${expected_knife_no_suffix}=  run keyword if  ${5G_check} and ${knife_build}  split string  ${expected_sw}  -
    ${expected_sw}=  run keyword if  ${5G_check} and ${knife_build}  set variable  ${expected_knife_no_suffix[0]}
    ...  ELSE  set variable  ${expected_sw}
    ${expected_splited}=    run keyword if  ${5G_check}  split string  ${expected_sw}  .
    ...  ELSE  split string  ${expected_sw}  _

    # compare last 2 so delete 2 for 5g and 3 for lte
    remove from list  ${active_splited}  0
    remove from list  ${active_splited}  0
    remove from list  ${active_splited}  0

    remove from list  ${expected_splited}  0
    run keyword unless  ${5G_check}  remove from list  ${expected_splited}  0
    run keyword unless  ${5G_check}  remove from list  ${expected_splited}  0

    ${status_1}=  Evaluate  str("""${expected_splited[0]}""") in str("""${active_splited[0]}""")
    ${status_2}=  Evaluate  str("""${expected_splited[1]}""") in str("""${active_splited[1]}""")
    ${status_3_knife_5G}=   run keyword if  ${5G_check} and ${knife_build}
    ...   Evaluate  str("""${expected_knife_no_suffix[1]}""") in str("""${active_splited[2]}""")

    ${correct_status}=  run keyword if
    ...  ${5G_check} and ${knife_build} and ${status_1} and ${status_2} and ${status_3_knife_5G}  set variable  ${True}
    ...  ELSE IF  ${status_1} and ${status_2}  set variable  ${True}
    ...  ELSE  set variable  ${False}
    [Return]  ${correct_status}

setup ute_syslog on nodes
    [Documentation]  Setting up ute_syslog on given nodes as remote.
    [Arguments]  ${node_list}  ${syslog_backup_dir}=/home/${VM_USER}/syslog_backups  ${log_name}=syslog
    set suite variable  ${KEYWORD_NAME}  setup ute_syslog on nodes
    # alias cleanup
    log to console with time  ${node_list}
    :FOR  ${node}  IN  @{node_list}
    \  run keyword and ignore error  collect Syslog Results
    ...  destination=${syslog_backup_dir}/teardown.tar.gz
    ...  unzip=${False}
    ...  alias=syslog_node_${node}

    run keyword and ignore error  Teardown All Aliases For Syslog
    run keyword and ignore error  Run process  sudo rm -rfv ${syslog_backup_dir}  shell=True

    :FOR  ${node}  IN  @{node_list}
    \  log to console with time  Starting Syslog from node:${node}
    \  Wait Until Keyword Succeeds  1m  30s  ute_syslog.start syslog
    ...       log_dir=${syslog_backup_dir}
    ...       log_name=${log_name}_backup_node_${node}.log
    ...       host_ip=${TL_CONFIG['${node}']['VM_IP']}
    ...       ssh_username=${VM_USER}
    ...       ssh_password='${VM_PASSWORD}'  # workaround because SR passwords can have / and library treat it as path
    ...       file_limit=209715200  # 200MB
    ...       add_line_number=True
    ...       alias=syslog_node_${node}

    &{start_of_loop_dict}=  Create Dictionary
    :FOR  ${node}  IN  @{node_list}
    \  log to console with time  savepoint from node:${node}
    \  ${start_of_loop}=  ute_syslog.Capture Savepoint    alias=syslog_node_${node}
    \  ${node_as_string}=  convert to string  ${node}
    \  Set To Dictionary   ${start_of_loop_dict}    ${node_as_string}=${start_of_loop}
    set suite variable  ${START_OF_LOOP}  ${start_of_loop_dict}


collect ute_syslog on nodes
    [Documentation]  Collects ute_syslog from all nodes.
    [Arguments]  ${node_list}  ${destination}=${LOG_DIR}  ${syslog_name}=syslog
    set suite variable  ${KEYWORD_NAME}  collect ute_syslog on nodes
    :FOR  ${node}  IN  @{node_list}
    \  log to console with time  Collecting Syslog from node:${node}
    \  run keyword and ignore error  collect Syslog Results
    ...  destination=${destination}/node${node}/${syslog_name}_node_${node}.tar.gz
    ...  unzip=${False}
    ...  alias=syslog_node_${node}


collect ute_syslog from savepoint on nodes
    [Documentation]  Collects ute_syslog from on all nodes from savepoint.
    ...  Used for check syslog keyword.
    [Arguments]  ${node_list}  ${savepoint_dict}  ${destination}=${LOG_DIR}  ${syslog_name}=syslog_from_savepoint
    set suite variable  ${KEYWORD_NAME}  collect ute_syslog from savepoint on nodes
    log to console with time  ${savepoint_dict}
    :FOR  ${node}  IN  @{node_list}
    \  ${node_as_string}=  convert to string  ${node}
    \  log to console with time  Collecting Syslog from savepoint on node:${node}
    \  log to console with time  ${savepoint_dict['${node_as_string}']}
    # due to bug of library destination on remote node have to be created manually
    \  run process  ssh ute@${TL_CONFIG['${node}']['VM_IP']} mkdir -p ${destination}/node${node}  shell=True
    \  log to console with time  ${destination}/node${node}/${syslog_name}_node_${node}.txt
    \  ${status}=  Collect from Savepoint
    ...  savepoint=${savepoint_dict['${node_as_string}']}
    ...  destination_file=${destination}/node${node}/${syslog_name}_node_${node}
    ...  compress=True
    ...  alias=syslog_node_${node}



Log Collector
    [Documentation]  Wrapper for collecting snapshot and syslog from all nodes.
    [Arguments]  ${log_path}=${LOG_DIR}
    log to console with time  Collecting Logs
#   snapshot
    Run On Nodes  Get Snapshot and IM Snapshot
    ...  variables=--variable TEST_VM_IP:${TEST_VM_IP}
    ...  node_list=${COLLECT_SNAPSHOT}

#   syslog
    log to console with time  Collecting ute_syslog from all nodes...
    collect ute_syslog on nodes  node_list=${CHECK_SYSLOG}

    # to be adjusted for fid 10 and undetected radio modules.
#    [Teardown]  run keyword
#    ...       run keyword if  ${TEST_PHASE}=='after_upgrade'  Get Snapshot After Reboot  ${sw_build}

Get Snapshot and IM Snapshot
    [Documentation]  Download full snapshot for node.
    [Arguments]  ${test_vm_ip}  ${admin_alias}  ${destination}=${LOG_DIR}/node${THIS_NODE}
    ...  ${file_name}=snapshot_node_${THIS_NODE}  ${timeout}=1200
    run keyword and ignore error
    ...  admin.Collect Im Snapshot
    ...  target_file_name=${destination}/IMS_${file_name}.ims2
    ...  connection=${admin_alias}
    Send File To Test VM  test_vm_ip=${test_vm_ip}  source_path=${destination}  destination_path=${destination}  file_name=IMS_${file_name}.ims2

    run keyword and ignore error  Wait Until Keyword Succeeds  3x  30s
    ...  admin.Collect Snapshot
    ...  target_file_name=${destination}/${file_name}.zip
    ...  timeout=${timeout}
    ...  connection=${admin_alias}

Send File To Test VM
    [Documentation]  Sends give file to remote VM, used to download logs from remote VM's
    [Arguments]  ${test_vm_ip}  ${source_path}  ${destination_path}  ${file_name}
    log to console with time  Sending ${file_name} to ${test_vm_ip}${destination_path}

    ${create_dir}=  convert to string  ssh ${VM_USER}@${test_vm_ip} "mkdir -p ${destination_path}"
    ${get_file}=  convert to string  scp -rp ${source_path}/${file_name} ${VM_USER}@${test_vm_ip}:${destination_path}
    run process  ${create_dir}  shell=True
    run process  ${get_file}  shell=True




#Get Snapshot After Reboot
#    [Documentation]  Downloads snapshot after SM reboot for FID 10  and undetected RMODS.
#    [Arguments]  ${sw_build}
#    setup admin and get active software  alias=reboot_logs
#    ${rm_detected}=  run keyword and return status  Wait Until Keyword Succeeds  1x  1m
#     ...  Wait For Radio Modules   admin_alias=reboot_logs  rm_count=3
#    run keyword if  '${rm_detected}'!='True'  admin.reset  reset_coverage=Bts  wait_for_reconnection=True  connection=reboot_logs
#    Wait Until Keyword Succeeds  5m  10s  Address Is Pingable  ${ENB_LMP_IP}
#    Wait Until Keyword Succeeds  3x  60s  setup admin for alias  alias=setup_after_reboot
#    # because there was a case that setup from before reset was not working after reset we need new one
#    ${rm_status}=  run keyword and return status  run keyword if  '${rm_detected}'!='True'
#    ...  Wait Until Keyword Succeeds  15x  1m  Wait For Radio Modules   admin_alias=setup_after_reboot  rm_count=3
#    run keyword if  '${rm_detected}'!='True' and ${rm_status}  log to console with time  Gathering Snapshot After Recovery Reset
#    run keyword if  '${rm_detected}'!='True' and ${rm_status}  run keyword and ignore error
#    ...  Wait Until Keyword Succeeds  3x  30s  admin.Collect Snapshot
#    ...  target_file_name=${LOG_DIR}/snapshot_after_recovery_reset_${sw_build}_${UUF_RAND}_3600.zip
#    ...  timeout=1200
#    ...  connection=setup_after_reboot
#    [Teardown]  run keywords
#    ...       admin.Teardown Admin  connection=reboot_logs
#    ...  AND  admin.Teardown Admin  connection=setup_after_reboot


Wait For Radio Modules
    [Documentation]  Waiting until number of radio modules in configuration file and detected on testline are the same.
    [Arguments]  ${admin_alias}  ${rm_count}
    set suite variable  ${KEYWORD_NAME}  Wait For Radio Modules
    log to console with time  ========================
    log to console with time  Checking RMOD Status:
    ${bts_info}=  admin.get_bts_info   connection=${admin_alias}
    ${rmod_detected_count}=  get length  ${bts_info['radioModules']['rmod']}
    : FOR  ${rmod}  IN   @{bts_info['radioModules']['rmod']}
    \  @{required_keys}=  create list  proceduralState
    \  ${unified_rmod_dict}=  Unify Dictionary Keys And Values  ${rmod}  ${required_keys}  nested_key=['status']
    \  run keyword and ignore error  log to console with time  [ ${unified_rmod_dict['status']['proceduralStatus']}]
    : FOR  ${rmod}  IN   @{bts_info['radioModules']['rmod']}
    \  @{required_keys}=  create list  proceduralState
    \  ${unified_rmod_dict}=  Unify Dictionary Keys And Values  ${rmod}  ${required_keys}  nested_key=['status']
    \  run keyword if
    ...  '${unified_rmod_dict['status']['proceduralStatus']}'!='configured' and '${unified_rmod_dict['status']['proceduralStatus']}'!='initializing'
        ...  Fail  [${unified_rmod_dict['status']['proceduralStatus']}]
    log to console with time  RM in Config: ${rm_count} Detected: ${rmod_detected_count}
    should be equal as integers  ${rm_count}  ${rmod_detected_count}
    log to console with time  -====== All RMods Detected ======-


Check Cells
    [Documentation]    This keyword return status of all cells and check if all are in onAir state
    [Arguments]    ${admin_alias}
    [Timeout]    10min
    set suite variable  ${KEYWORD_NAME}  Check Cells
    log to console with time  -== Checking Cell Status ==-
    ${rc_l}  ${lncel_list}=  run keyword and ignore error  admin.get_parameters_for_all  class_name=LNCEL  connection=${admin_alias}  timeout=60
    ${rc_w}  ${wncel_list}=  run keyword and ignore error  admin.get_parameters_for_all  class_name=WNCEL  connection=${admin_alias}  timeout=60
    ${rc_g}  ${gncel_list}=  run keyword and ignore error  admin.get_parameters_for_all  class_name=GNCEL  connection=${admin_alias}  timeout=60
    ${rc_n}  ${nrcel_list}=  run keyword and ignore error  admin.get_parameters_for_all  class_name=NRCEL  connection=${admin_alias}  timeout=60


    # there is no such structure in FL18A so it have to be handled like this because FOR won't find variable
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

    # somethmes list returned by testline is empty in uncommissioned state or other issues
    run keyword if  '${lncel_list_length}'=='0' and '${wncel_list_length}'=='0' and '${gncel_list_length}'=='0' and '${nrcel_list_length}'=='0'
    ...  Fail  cell_list_length==0 waiting for correct cell list

    set suite variable  ${AMOUNT_OF_CELLS}  ${lncel_list_length}

    # test can be run with serial console on (for pronto reproduction) when uboot_env console_uart variable is not -1
    ${availability_status_text}=  run keyword if  ${THIS_NODE} in ${SERIAL_CONSOLE_ON}  set variable  degraded
    ...  ELSE  set variable  online

    # print
    log to console with time  -= Checking LTE Cells=-
    : FOR  ${cell}  IN  @{lncel_list}
    \  @{required_keys}=  create list  proceduralState  availabilityStatus  operationalState  administrativeState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}
    \  ${print_status}=  catenate  SEPARATOR=${space}
    ...  [${unified_cell_dict['proceduralState']},
    ...  ${unified_cell_dict['availabilityStatus']},
    ...  ${unified_cell_dict['operationalState']},
    ...  ${unified_cell_dict['administrativeState']}]
    \  run keyword and ignore error  log to console with time  ${print_status}

    log to console with time  -=Checking WCDMA Cells=-
    : FOR  ${cell}  IN  @{wncel_list}
    \  @{required_keys}=  create list  availabilityStatus  operationalState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}
    \  run keyword and ignore error
    ...  log to console with time
        ...  [${unified_cell_dict['availabilityStatus']}, ${unified_cell_dict['operationalState']}]
    log to console with time  -=Checking GSM Cells=-
    : FOR  ${cell}  IN  @{gncel_list}
    \  @{required_keys}=  create list  availabilityStatus  operationalState  administrativeState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}
    \  run keyword and ignore error
    ...  log to console with time
       ...  [${unified_cell_dict['availabilityStatus']}, ${unified_cell_dict['operationalState']}, ${unified_cell_dict['administrativeState']}]
    log to console with time  -=Checking 5G Cells=-
    : FOR  ${cell}  IN  @{nrcel_list}
    \  @{required_keys}=  create list  availabilityStatus  operationalState  administrativeState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}
    \  run keyword and ignore error
    ...  log to console with time
       ...  [${unified_cell_dict['availabilityStatus']}, ${unified_cell_dict['operationalState']}, ${unified_cell_dict['administrativeState']}]

    # LNCEL (LTE)
    : FOR  ${cell}  IN  @{lncel_list}
#    \  log to console with time  >>${cell}
    \  @{required_keys}=  create list  proceduralState  availabilityStatus  operationalState  administrativeState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}

    \  run keyword if
    ...           '${unified_cell_dict['proceduralState']}'!='onairdone'  Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['availabilityStatus']}'!='${availability_status_text}'  Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['operationalState']}'!='enabled'  Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['administrativeState']}'!='unlocked'  Fail  Incorrect cell status

    # WNCEL (WCDMA)
    : FOR  ${cell}  IN  @{wncel_list}
    \  @{required_keys}=  create list  availabilityStatus  operationalState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}
    \  run keyword if
    ...           '${unified_cell_dict['availabilityStatus']}'!='${availability_status_text}'  Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['operationalState']}'!='enabled'  Fail  Incorrect cell status
    # GNCEL (GSM)
    : FOR  ${cell}  IN  @{gncel_list}
    \  @{required_keys}=  create list  availabilityStatus  operationalState  administrativeState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}
    \  run keyword if
    ...           '${unified_cell_dict['availabilityStatus']}'!='${availability_status_text}'  Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['operationalState']}'!='enabled'  Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['administrativeState']}'!='unlocked'  Fail  Incorrect cell status
    # NRCEL (5G)
    : FOR  ${cell}  IN  @{nrcel_list}
    \  @{required_keys}=  create list  availabilityStatus  operationalState  administrativeState
    \  ${unified_cell_dict}=  Unify Dictionary Keys And Values  ${cell}  ${required_keys}
    \  run keyword if
    ...           '${unified_cell_dict['availabilityStatus']}'!='${availability_status_text}'   Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['operationalState']}'!='enabled'  Fail  Incorrect cell status
    ...  ELSE IF  '${unified_cell_dict['administrativeState']}'!='unlocked'  Fail  Incorrect cell status


    [Teardown]  Run Keywords
    ...       run keyword if  '${KEYWORD STATUS}'=='PASS'  Log to console with time  Cells looks OK
    ...  AND  run keyword if  '${KEYWORD STATUS}'=='FAIL'  Log to console with time  Incorrect cell status


Check Faults
    [Documentation]
    ...  Keyword check whether unallowed alarms are present on testline.
    ...  Allowed alarms could be declared in eNB configuration file for every node.
    [Arguments]  ${allowed_fault_list}  ${alias}  ${email_check}=${False}
    [Timeout]  120s
    set suite variable  ${KEYWORD_NAME}  Check Faults
    # add alarm 4334 serial console activated into allowed if test is with serial console.
    run keyword if  ${THIS_NODE} in ${SERIAL_CONSOLE_ON}  insert into list  ${allowed_fault_list}  0  4334
    log to console with time  ALLOWED FAULTS: ${allowed_fault_list}
    log to console with time  -== Checking Faults ==-
    ${alarm_list}=  admin.get_alarms  connection=${alias}
    @{last_faults_list}=  create list
    ${email_faults_list}=  set variable  ${EMPTY}
    : FOR  ${alarm}  IN  @{alarm_list}
    \  append to list  ${last_faults_list}  ${alarm['faultId']}
    \  ${alarm_string}=  convert to string  ${alarm}
    \  ${alarm_id_matches}=  get regexp matches  ${alarm_string}  (alarmId|alarmNumber)':\\s(\\d+)  2
    \  ${fault_id_matches}=  get regexp matches  ${alarm_string}  faultId':\\s(\\d+)  1
    \  ${fault_description}=
    ...  get regexp matches  ${alarm_string}  (faultDescription|alarmDetail)': u{0,1}'([a-z,A-Z,0-9&!@#$%^*()+-_:; ]{0,100})'  2
    \  Append To List  ${fault_description}  Unable to find fault Description probably unsupported sign in string.
    \  log to console with time   Alarm: ${alarm_id_matches[0]} Fault: ${fault_id_matches[0]} ${fault_description[0]}
    \  ${email_faults_list}=  catenate  ${email_faults_list} ${alarm['faultId']} - ${fault_description[0]},\n

    set suite variable  ${LAST_FAULTS}  ${last_faults_list}

    : FOR  ${alarm}  IN  @{alarm_list}
    \  ${alarm_string}=  convert to string  ${alarm}
    \  ${fault_id_matches}=  get regexp matches  ${alarm_string}  faultId':\\s(\\d+)  1
    \  ${status}=   Evaluate  str("""${fault_id_matches[0]}""") in @{allowed_fault_list}
    \  Should Be True  ${status}  msg=Alarm ${fault_id_matches[0]} Not In Allowed List ${allowed_fault_list}
    [Teardown]    run keyword
    ...  log  REMOTE_NODE_RETURN_${email_faults_list}_REMOTE_NODE_RETURN  console=False



Unify Dictionary Keys And Values
    [Documentation]  Keyword creating missing keys in dictionary due to CNI-61110
    ...  and assigning default values for nonexistant keys.
    [Arguments]  ${dict}  ${required_key_list}  ${nested_key}=
    set suite variable  ${KEYWORD_NAME}  Unify Dictionary Keys And Values
    :FOR  ${key}  IN  @{required_key_list}
    \  ${required_key_in_dict}=  run keyword and return status  Dictionary Should Contain Key  ${dict${nested_key}}  ${key}
    \  run keyword unless   ${required_key_in_dict}  log  NO KEY  console=False
    \  run keyword if   '${required_key_in_dict}'=='False' and '${key}'=='availabilityStatus'
    ...  Set To Dictionary   ${dict${nested_key}}    ${key}=Online  # if it's in correct state no key in dict so we add it with correct value
    ...  ELSE IF  '${required_key_in_dict}'=='False' and '${key}'!='availabilityStatus'
    ...  Set To Dictionary   ${dict${nested_key}}    ${key}=${EMPTY}
    :FOR    ${key}     ${value}    IN ZIP    ${dict${nested_key}.keys()}    ${dict${nested_key}.values()}
    \  ${required_key}=  Evaluate  str('${key}') in @{required_key_list}
    \                    run keyword if  ${required_key}  log  ${key}: ${value}  console=False
    \  ${new_value}=     run keyword if  ${required_key}  Evaluate  str('${value}').lower().replace(' ','')
    \                    run keyword if  ${required_key}  log  ${key}: ${new_value}    console=False
    \                    run keyword if  ${required_key}  Set To Dictionary   ${dict}    ${key}=${new_value}
    [Return]  ${dict}


Check Validation
    [Timeout]  10m
    [Documentation]  Keywords for checking ADMIN validation of SCF file after upgrade.
    [Arguments]  ${admin_alias}  ${scf_path}=${LOG_DIR}/node${THIS_NODE}
    set suite variable  ${KEYWORD_NAME}  Check Validation
    log to console with time  Checking Validation for SBTS
    ${val_result}=  Create Dictionary
    Get SCF From eNB  scope=configuration  name=validation_SCF.xml  alias=${admin_alias}  save_path=${scf_path}

    ${val_result}=  run keyword and ignore error  admin.Validate Scf   ${scf_path}/validation_SCF.xml   connection=${admin_alias}  timeout=300
    run keyword and ignore error  log to console with time  ${val_result[1]}

#    ${niddVal}=  Get Dictionary Values  ${val_result.niddValidationResult.logs}
#    ${none_list}=  create list  ${None}  ${None}  ${None}  ${None}
#    Lists Should Be Equal  ${niddVal}  ${none_list}
#    ${pdlVal}=  Get Dictionary Values  ${val_result.pdlValidationResult.logs}
#    ${empty_list}  create list
#    ${list_of_empty_lists}  create list  ${empty_list}  ${empty_list}
#    Lists Should Be Equal  ${pdlVal}  ${list_of_empty_lists}

    run keyword if  '${val_result[0]}'=='PASS'  log to console with time  Validation OK
    ...  ELSE  FAIL  Validation Failed

    [Return]  ${val_result[0]}

Get SCF From eNB
    [Documentation]  Downloads SCF fle from node
    [Arguments]  ${scope}  ${name}  ${alias}  ${save_path}=${LOG_DIR}/node${THIS_NODE}
    set suite variable  ${KEYWORD_NAME}  Get SCF From eNB
    log to console with time  Downloading SCF from ENB with admin
    admin.get_current_scf_file    local_dir_path=${save_path}  file_name=${name}  export_type=${scope}   connection=${alias}


Check Syslog
    [Documentation]  Checks syslog for unexpected crashes that are not triggering any faults.
    [Arguments]   ${file_path}=${LOG_DIR}  ${file_name}=syslog_from_savepoint_start_of_loop  ${timestamp_dict}=${START_OF_UPGRADE}
    set suite variable  ${KEYWORD_NAME}  Check Syslog
    log to console with time  Checking Syslog For Crashes
    ${crash_prints}=  create list
        ...  \\-\\=\\-\\=
        ...  Please contact the owner
        ...  CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold
        ...  FaultId: 4329
        ...  FaultId: 4330
        ...  Detector 4329
        ...  Detector 4330
        ...  active 4329
        ...  active 4330
        ...  4230 Radio memory consumption exceeds critical threshold
#        ...  sendNewSiShare  # for test purpose
    ${joined_prints}=  Evaluate  "\\|".join(${crash_prints})

    collect ute_syslog from savepoint on nodes
    ...  node_list=${CHECK_SYSLOG}
    ...  savepoint_dict=${timestamp_dict}
    ...  destination=${file_path}
    ...  syslog_name=${file_name}

    &{syslog_check_status}=  Create Dictionary
    &{syslog_check_messages}=  Create Dictionary
    :FOR  ${node}  IN  @{CHECK_SYSLOG}
    # niekoniecznie dziala trzeba poszukac w pliku txt nie tar.gz pozniej sprawdizc czy zwroci tak znalezione message
    \   ${status}  ${messages}=  run keyword and ignore error
        ...  python_keywords.check_syslog_for_crashes
        ...  crash_prints=${joined_prints}
        ...  syslog_file=${file_path}/node${node}/syslog_from_savepoint_start_of_loop_node_${node}.tar.gz
    \  ${node_as_string}=  convert to string  ${node}
    \  Set To Dictionary   ${syslog_check_status}    ${node_as_string}=${status}
    \  Set To Dictionary   ${syslog_check_messages}    ${node_as_string}=${messages}
    \  log to console with time  node_${node}:${status} ${messages}

    dictionary should not contain value  dictionary=${syslog_check_status}  value=FAIL  msg=Crash Prints Found in Syslog
    [Teardown]  run keywords
    ...       log to console with time  Check syslog Status ${syslog_check_status}
    ...  AND  log to console with time  Messages ${syslog_check_messages}


Check ALD
    [Documentation]  This keyword will check status of ALDs modules(pass = enabled, fail = other than enabled)
    [Arguments]  ${admin_alias}
    set suite variable  ${KEYWORD_NAME}  Check ALD
    log to console with time  -== Checking ALDs ==-
    ${ald_dict}=  admin.get_parameters_for_all  class_name=ALD  timeout=60s  connection=${admin_alias}
    Log to console with time  ${EMPTY}
    : FOR  ${ald}  IN  @{ald_dict}
    \  @{required_keys}=  create list  availabilityStatus  operationalState
    \  ${unified_ald_dict}=  Unify Dictionary Keys And Values  ${ald}  ${required_keys}
    \  log to console with time  [${unified_ald_dict['availabilityStatus']}, ${unified_ald_dict['operationalState']}]
    : FOR  ${ald}  IN  @{ald_dict}
    \  @{required_keys}=  create list  availabilityStatus  operationalState
    \  ${unified_ald_dict}=  Unify Dictionary Keys And Values  ${ald}  ${required_keys}
    \  run keyword if  '${unified_ald_dict['operationalState']}'!='enabled' and '${unified_ald_dict['availabilityStatus']}'!='online'
    ...  Fail  log to console with time  [${unified_ald_dict['availabilityStatus']}, ${unified_ald_dict['operationalState']}]
    log to console with time  -====== All ALDs Detected ======-



Download Blackbox File
    [Documentation]  Downloads Blackbox files from node.
    [Arguments]  ${file_name}  ${lmp_ip}=${ENB_LMP_IP}
    set suite variable  ${KEYWORD_NAME}  Download Blackbox File
    log to console with time  \n
    log to console with time  Download BlackBox File
    Setup Enb Fsm Access  host=${lmp_ip}
    ${Blackbox}=  Get Enb File  source=/ffs/run/config/lifedata/blackbox  destination=${LOG_DIR}/node${THIS_NODE}/${file_name}
    [Teardown]  run keyword
    ...       Teardown Enb Fsm Access


Check Blackbox
    [Documentation]  Compare of blackbox files before and after upgrade.
    [Arguments]  ${before_upgrade_filename}  ${after_upgrade_filename}
    set suite variable  ${KEYWORD_NAME}  Check Blackbox
    ${before_upgrade_prints}  ${before_upgrade_counts}=  run keyword  Get Blackbox Prints  ${before_upgrade_filename}
    ${after_upgrade_prints}  ${after_upgrade_counts}=  run keyword  Get Blackbox Prints  ${after_upgrade_filename}
    Check If Prints Rolled Over  ${before_upgrade_prints}  ${after_upgrade_prints}  ${before_upgrade_counts}  ${after_upgrade_counts}

    log to console with time  Before Upgrade Prints: ${before_upgrade_counts} ${before_upgrade_prints}
    log to console with time  After Upgrade Prints: ${after_upgrade_counts} ${after_upgrade_prints}

    :FOR  ${index}  ${print}  IN ENUMERATE  @{blackbox_prints}
    \  ${status}=  run keyword and return status
    ...  should be equal as integers  ${before_upgrade_counts[${index}]}  ${after_upgrade_counts[${index}]}
    \  run keyword unless  ${status}  log to console with time  Blackbox Failed because ${blackbox_prints[${index}]} found after upgrade
    \  run keyword unless  ${status}  Fail  Blackbox Failed because ${blackbox_prints[${index}]} found after upgrade



Get Blackbox Prints
    [Documentation]  Gets blackbox prints and counts occurrences.
    [Arguments]  ${filename}
    set suite variable  ${KEYWORD_NAME}  Get Blackbox Prints
    ${Blackbox_output}=  OperatingSystem.Get file  path=${LOG_DIR}/node${THIS_NODE}/${filename}
    ${extract_reset_info}=  split string  ${Blackbox_output}  RESET COUNTER:
    ${blackbox_info}=  split string  ${extract_reset_info[1]}  SW VERSION: active:
    @{lines}=  split to lines  ${blackbox_info[0]}
    remove from list  ${lines}  0
    remove from list  ${lines}  0
    @{prints}=  create list

    :FOR  ${line}  IN  @{lines}
    \  ${list}=  split string  ${line}  ${SPACE}  max_split=1
    \  ${list_length}=  get length  ${list}
    \  ${status}  ${index}=  run keyword if  ${list_length}>1   Check if contain  ${list[1]}  ${blackbox_prints}
    \  @{return_list}=  create list  ${list[0]}  ${index}
    \  run keyword if  ${status} and ${list_length}>1  append to list  ${prints}  ${return_list}

    @{print_count}=  create list
    :FOR  ${index}  ${element}  IN ENUMERATE  @{blackbox_prints}
    \  ${matches}=  get regexp matches  ${Blackbox_output}  ${element}
    \  ${length}=  get length  ${matches}
    \  insert into list  ${print_count}  ${index}  ${length}
    log to console with time  Blackbox print count: ${filename}: ${print_count}

    [Return]    ${prints}  ${print_count}


Check If Prints Rolled Over
    [Documentation]  Check if prints still exist in blackbox file after upgrade
     ...  or they dissappeared due to limited number of lines in file (20)
    [Arguments]  ${before_up_prints}  ${after_up_prints}  ${before_up_counts}  ${after_up_counts}
    set suite variable  ${KEYWORD_NAME}  Check If Prints Rolled Over
    ${after_as_string}=  convert to string   ${after_up_prints}
    :FOR  ${item}  IN  @{before_up_prints}
    \  ${status}=  run keyword and return status  should contain  ${after_as_string}  ${item[0]}
    \  ${temp_var}=  run keyword unless  ${status}  Evaluate  ${before_up_counts[${item[1]}]} -1
    \  run keyword unless  ${status}  log to console with time
    ...  timestamp: ${item[0]} - ${blackbox_prints[${item[1]}]} no longer in blackbox - deleting entry(because blackbox contain only 20 messages)
    \  run keyword unless  ${status}  set list value  ${before_up_counts}  ${item[1]}  ${temp_var}

Split To Prefix and Suffix
    [Documentation]  Splits build number for Branch prefix and the rest.
    ...  Used to compare trunk software because filename is SBTS00 and on tesltine is real branch name ie. SBTS22R3
    [Arguments]  ${build}
    set suite variable  ${KEYWORD_NAME}  Split To Prefix and Suffix
    ${release_prefix}  ${build_number}=  Split String  ${build}  _  1
    [Return]  ${release_prefix}  ${build_number}


Check if contain
    [Arguments]  ${source}  ${prints}
    set suite variable  ${KEYWORD_NAME}  Check if contain
    :FOR  ${index}  ${print}  IN ENUMERATE  @{prints}
    \  ${matches}=  get regexp matches  ${source}  ${print}
    \  ${matches_length}=  get length  ${matches}
    \   return from keyword if  ${matches_length}>0  ${True}  ${index}
    [Return]  ${False}  ${-1}


Add Swconfig Flags
    [Documentation]  Adds swconfig flags from passed list, and performs reset.
    [Arguments]  ${flag_list}  ${admin_alias}  ${lmp_ip}=${ENB_LMP_IP}  ${no_hwf}=False

    @{NO_HWF_SWCONFIG_FLAGS}=  create list  0x190030=0  0x4F0214=0

#    ${flag_list_combined}=  run keyword if  ${no_hwf}  Combine Lists   ${flag_list}  ${NO_HWF_SWCONFIG_FLAGS}
    ${add_flags_for_this_node}=  Evaluate  ${THIS_NODE} in @{ADD_SWCONFIG_FLAGS}
    ${flag_list}=
    ...  run keyword if  ${no_hwf} and ${add_flags_for_this_node}
        ...  Combine Lists   ${flag_list}  ${NO_HWF_SWCONFIG_FLAGS}
    ...  ELSE IF  ${no_hwf} and '${add_flags_for_this_node}'=='False'
        ...  set variable  ${NO_HWF_SWCONFIG_FLAGS}
    ...  ELSE IF  '${no_hwf}'=='False' and ${add_flags_for_this_node}
        ...  set variable  ${flag_list}
    ...  ELSE  create list

    log to console with time  ${flag_list}





    set suite variable  ${KEYWORD_NAME}  Add Swconfig Flags
    Setup Enb Fsm Access  host=${lmp_ip}
    log to console with time  Adding flags to swconfig...
    ${reset_needed}=  set variable  ${False}
    Wait Until Keyword Succeeds  10m  30s  Address Is Pingable  ${lmp_ip}
    Execute Command On Enb  echo ' ' >> /ffs/run/swconfig.txt
    :FOR  ${FLAG}  IN  @{flag_list}
   \  ${removed_comments}=  split string  ${FLAG}  \#
   \  ${check_flag}=  Execute Command On Enb  cat /ffs/run/swconfig.txt
   \  ${status}=  Evaluate  """${removed_comments[0]}""" in """${check_flag}"""
   \  run keyword unless  ${status}  Execute Command On Enb  echo ${removed_comments[0]} >> /ffs/run/swconfig.txt
   \  run keyword if  ${status}  log to console with time  Flag: ${removed_comments[0]} already in swconfig
        ...  ELSE  log to console with time  Added flag:${removed_comments[0]}
   \  ${reset_needed}=  run keyword if  '${status}'=='False'  set variable  ${True}
   ...  ELSE  set variable  ${reset_needed}
    run keyword if  ${reset_needed}  log to console with time  Adding flags completed, Performing Reset Of Bts
    ...  ELSE  log to console with time  All flags already in swconfig, nothing to do.
    run keyword if  ${reset_needed}  Reset Testline  admin_alias=${admin_alias}  lmp_ip=${lmp_ip}
    [Teardown]  Teardown Enb Fsm Access

Remove Swconfig Flags
    [Documentation]  Adds swconfig flags from passed list, and performs reset.
    [Arguments]  ${flag_list}  ${admin_alias}  ${lmp_ip}=${ENB_LMP_IP}  ${no_hwf}=False

    @{NO_HWF_SWCONFIG_FLAGS}=  create list  0x190030=0  0x4F0214=0

#    ${flag_list_combined}=  run keyword if  ${no_hwf}  Combine Lists   ${flag_list}  ${NO_HWF_SWCONFIG_FLAGS}
    ${add_flags_for_this_node}=  Evaluate  ${THIS_NODE} in @{ADD_SWCONFIG_FLAGS}
    ${flag_list}=
    ...  run keyword if  ${no_hwf} and ${add_flags_for_this_node}
        ...  Combine Lists   ${flag_list}  ${NO_HWF_SWCONFIG_FLAGS}
    ...  ELSE IF  ${no_hwf} and '${add_flags_for_this_node}'=='False'
        ...  set variable  ${NO_HWF_SWCONFIG_FLAGS}
    ...  ELSE IF  '${no_hwf}'=='False' and ${add_flags_for_this_node}
        ...  set variable  ${flag_list}
    ...  ELSE  create list

    log to console with time  ${flag_list}

    set suite variable  ${KEYWORD_NAME}  Remove Swconfig Flags
    Setup Enb Fsm Access  host=${lmp_ip}
    log to console with time  Removing flags to swconfig...
    Wait Until Keyword Succeeds  10m  30s  Address Is Pingable  ${lmp_ip}
    ${check_flag}=  Execute Command On Enb  cat /ffs/run/swconfig.txt
    :FOR  ${FLAG}  IN  @{flag_list}
   \  ${check_flag}  Remove String  ${check_flag}  ${FLAG}
    Execute Command On Enb  echo """${check_flag}""" > /ffs/run/swconfig.txt
    log to console with time  Removing flags completed, Performing Reset Of Bts
    Reset Testline  admin_alias=${admin_alias}  lmp_ip=${lmp_ip}
    [Teardown]  Teardown Enb Fsm Access

Log to console with time
    [Documentation]  Keyword display,log output with time.
    [Arguments]  ${output}
    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  @{time}[0]  @{time}[1]  @{time}[2]
    Log  (${time_now}) ${output}  console=True

Reset Testline
    [Documentation]  Reset Testline with TAF admin.
    [Arguments]  ${admin_alias}  ${lmp_ip}=${ENB_LMP_IP}  ${coverage}=Site
    set suite variable  ${KEYWORD_NAME}  Reset Testline
    ${reset_status}=  run keyword and return status  admin.Reset  reset_coverage=${coverage}  timeout=300  alias=${admin_alias}
    log to console with time  Admin reset status: ${reset_status}
    log to console with time  Reset completed. Waiting for eNB to be pingable...
    Wait Until Keyword Succeeds  20m  30s  Address Is Pingable  ${lmp_ip}
    log to console with time  eNB is pingable

No Admin Reboot
    [Arguments]  ${lmp_ip}=${ENB_LMP_IP}
    ${command}=
    ...  convert to string  sshpass -p '${ENB_ROOT_PASS}' ssh -f ${ENB_ROOT_USER}@${lmp_ip} -q 'nohup system-module-reboot > /dev/null 2>&1 &'
    log to console with time  Rebooting SM with ${command}
    ${rc}=  Run process
    ...  command=${command}
    ...  shell=True
    ...  cwd=${CURDIR}



    log to console with time  Reboot Completed ${rc}
    run keyword and return status  eNB Should Be Unavailable  lmp_ip=${lmp_ip}
    Wait Until Keyword Succeeds  10m  10s  Address Is Pingable  lmp_ip=${lmp_ip}

Recover Testline After Fail
    [Documentation]  Keyword performs reset in order to recover testline after fail
    [Arguments]  ${node_list}
    set suite variable  ${KEYWORD_NAME}  Recover Testline After Fail
    log to console with time  --== Recovering Testline After Fail ==--
    #  check if rollback on upgrade/rollback node is needed
    Run On Nodes  Rollback If Needed
    ...  variables=--variable CANDIDATE:${CANDIDATE}
    ...  node_list=${node_list}


    :FOR  ${reset_count}  IN RANGE  ${RECOVERY_RESET_COUNT}
    \  log to console with time  -= Recovering Testline attempt: ${reset_count+1} =-
    \  Run On Nodes  Cancel 6450 If Needed
    ...  node_list=${node_list}
    \  ${pre_status}=  run keyword and return status  Check Testline Status
    ...  cell_check_count=${CHECK_CELL_COUNT}
    ...  fault_check_count=${CHECK_FAULT_COUNT}
    \  Exit For Loop If  ${pre_status}
    \  run on nodes  Reset Testline
    ...  node_list=${node_list}
    \  ${status}=  run keyword and return status  Check Testline Status
    ...  cell_check_count=${CHECK_CELL_COUNT}
    ...  fault_check_count=${CHECK_FAULT_COUNT}
    \  Exit For Loop If  ${status}
    run keyword unless  ${pre_status}  run keyword unless  ${status}  Fail
    ...  Unable to Recover Testline after ${RECOVERY_RESET_COUNT} resets.
    run keyword unless  ${pre_status}  run keyword if  ${status}
    ...  Log to console with time  Testline Recovered Successfully.
    run keyword if  ${pre_status}  log to console with time  RECOVER - All cells are OnAir and no Unallowed Faults detected.

Check Testline Status
    [Documentation]  Check Cells and Faults for recovery purpose.
    [Arguments]  ${cell_check_count}  ${fault_check_count}
    set suite variable  ${KEYWORD_NAME}  Check Testline Status
    wait until keyword succeeds  ${cell_check_count}x  1m  Run On Nodes  Check Cells
    ...  node_list=${CHECK_CELLS}

    wait until keyword succeeds  ${fault_check_count}x  1m  Run On Nodes  Check Faults
    ...  variables=--variable TEST_PHASE:before_upgrade
    ...  node_list=${CHECK_FAULTS}

Cancel 6450 If Needed
    [Arguments]  ${fault_list}  ${admin_alias}
    run keyword and ignore error  Check Faults  ${fault_list}  ${admin_alias}
    ${status}=  Evaluate  str("""6450""") in str("""${LAST_FAULTS}""")
    run keyword if  ${status}  log to console with time  Canceling 6450 On This Node
    run keyword if  ${status}  run keyword and ignore error
    ...  admin.Collect Snapshot
        ...  target_file_name=/tmp/canceled_6450_snapshot.zip
        ...  timeout=1200
        ...  connection=${admin_alias}

Run Keyword On Remote Node
    [Documentation]  Runs keyword on given remote node and retrieve remote test output.
    [Arguments]  ${node_ip}  ${testcase}  ${node_number}  ${variables}  ${log_path}=${LOG_DIR}
    ${rand_console}=  String.Generate Random String  5  [UPPER]

    ${rand_console}=  run keyword if  ${DEBUG}  set variable  DEBUG
    ...  ELSE  set variable  ${rand_console}



    ${testcase_no_space}=  replace string  ${testcase}  ${SPACE}  _
    ${test_name}=  convert to string  remote_node_keywords.robot

    ${command}=  catenate  SEPARATOR=${SPACE}
    ...  ${VIRTUAL_ENV_ACT_CMD}
    ...  timeout 15h robot -L TRACE ${variables}
    ...  -b '${log_path}/ROBOT_LOGS/debug.log'
    ...  --log '${log_path}/ROBOT_LOGS/${testcase_no_space}_${rand_console}.html'
    ...  -d '${log_path}/ROBOT_LOGS/' -t '${testcase}' ${TEST_PATH}/resources/robot/${test_name}|
    ...  tee -ia --output-error=warn '${log_path}/ROBOT_LOGS/${testcase_no_space}_${rand_console}.txt'

    log   ${command}  console=False
    ${status}  ${output}=  python_keywords.run_test_on_remote_node
    ...  host=${node_ip}
    ...  user=ute
    ...  command=${command}
    ...  ssh_key=/home/ute/.ssh/id_rsa
#    ...  local_path=${log_path}/node${node_number}/ROBOT_LOGS/${testcase_no_space}_${rand_console}
#    ...  remote_path=${log_path}/ROBOT_LOGS/${testcase_no_space}_${rand_console}*
    ${output_length}=  get length  ${output}
    :FOR  ${line}  IN RANGE  3  ${output_length}-9
    \  log to console with time  ${output[${line}]}

    ${sync_files}=  convert to string  rsync -r -v ${VM_USER}@${node_ip}:/${log_path}/ ${log_path}/
    run process  ${sync_files}  shell=True

    run keyword if  ${status}  log to console with time  ${testcase} Remote Node ${node_ip}: | PASSED |
    ...  ELSE  log to console with time  ${testcase} Remote Node ${node_ip}: | FAILED |
    run keyword unless  ${status}  Fail  Remote Node ${testcase} Failed
    [Return]  ${status}
    [Teardown]  run keyword if  '${KEYWORD STATUS}'=='FAIL'  set suite variable  ${KW_FAULT_MESSAGE}  ${testcase} - Failed On NODE: ${node_number}

Run On Nodes
    [Documentation]  Run keyword on give remote nodes.
    [Arguments]   ${keyword}  ${node_list}  ${variables}=${EMPTY}
    log to console with time  ${node_list}

    :FOR  ${node}  IN  @{node_list}
    \  log to console with time  Executing - ${keyword} on node: ${node}
    \  ${const_variables}=  catenate  SEPARATOR=${SPACE}
    ...  ${variables}
    ...  --variable THIS_NODE:${node}
    ...  --variable LOG_DIR:${LOG_DIR}
    ...  --variable TL_CONFIG_PATH:${TL_CONFIG_PATH_AND_NAME}
    ...  --variable TEST_PATH:${TEST_PATH}
    ...  --variable HOSTNAME:${HOSTNAME}

    \  Run Keyword On Remote Node
    ...  node_ip=${TL_CONFIG['${node}']['VM_IP']}
    ...  testcase=${keyword}
    ...  node_number=${node}
    ...  variables=${const_variables}
    ...  log_path=${LOG_DIR}/node${node}




Downgrade Uboot
    [Arguments]  ${lmp_ip}
    set suite variable  ${KEYWORD_NAME}  Downgrade Uboot
    log to console with time  Downgrading Uboot
    Wait Until Keyword Succeeds  10m  30s  Address Is Pingable  ${lmp_ip}

    Setup Enb Fsm Access  host=${lmp_ip}  alias=uboot_downgrade

    Put Enb File  ${TEST_PATH}/resources/other/prepare-firmware.sh  destination=/ffs/run  alias=uboot_downgrade
    Execute Command On Enb   cmd=chmod +x /ffs/run/prepare-firmware.sh  alias=uboot_downgrade

   set suite variable  ${REBOOT_NEEDED}  ${False}


    # BB
     :FOR   ${index}  ${bb_ip_addr}  IN ENUMERATE  @{TL_CONFIG['${THIS_NODE}']['BB_NODES']}
     \  log to console with time  Setting SSH Tunnel to BBMOD
     \  set ssh tunnel
     ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
     ...  uboot_fsp_ip=${bb_ip_addr}
     ...  uboot_port_suffix=${index}
     \  ${bbmod_type}=  check module type  uboot_port_suffix=${index}
     \  log to console with time  ========== [START] UBOOT LOOG ${bbmod_type}:${index} IP=${bb_ip_addr} ==========
     \  ${return}=  run keyword if
     ...           '${bbmod_type}'=='ABIA'   Perform Uboot Downgrade On BB     card_index=${index}
     ...  ELSE IF  '${bbmod_type}'=='ABIAL'  Perform Uboot Downgrade On BB     card_index=${index}
     ...  ELSE IF  '${bbmod_type}'=='ABIC'   Perform Uboot Downgrade On ABIC   card_index=${index}  fsm_alias=uboot_downgrade
     ...  ELSE IF  '${bbmod_type}'=='ABIO'   Perform Bios Update on ABIO or ABIN  card_index=${index}  fsm_alias=uboot_downgrade
     ...  ELSE IF  '${bbmod_type}'=='ABIN'   Perform Bios Update on ABIO or ABIN  card_index=${index}  fsm_alias=uboot_downgrade
#     ...  ELSE IF  '${bbmod_type}'=='ABIL'   Not Yet Supported



     \  log to console with time  ${return}
     \  log to console with time  ---------- [END] CARD ${index} ----------



    # SM
    ${get_sm_type}=  convert to string  sysinfo 2>&1| head -n10 | grep "ID_00_MODULE_ID_\\[0\\]" | awk -F "'" '{print $2}'
    ${system_module}=   Execute Command On Enb  ${get_sm_type}  alias=uboot_downgrade

    run keyword if  '${system_module}'=='ASIA'   Perform UBoot Downgrade on SM  lmp_ip=${lmp_ip}  fsm_alias=uboot_downgrade
    ...  ELSE IF    '${system_module}'=='ASIAA'  Perform UBoot Downgrade on SM  lmp_ip=${lmp_ip}  fsm_alias=uboot_downgrade
    ...  ELSE IF    '${system_module}'=='ASIB'   Perform UBoot Downgrade on SM  lmp_ip=${lmp_ip}  fsm_alias=uboot_downgrade
    ...  ELSE IF    '${system_module}'=='ASIBA'  Perform UBoot Downgrade on SM  lmp_ip=${lmp_ip}  fsm_alias=uboot_downgrade
    ...  ELSE IF    '${system_module}'=='ASIAL'  Perform UBoot Downgrade on SM  lmp_ip=${lmp_ip}  fsm_alias=uboot_downgrade
    ...  ELSE IF    '${system_module}'=='ASIL'   Perform Bios Downgrade on ASIL  lmp_ip=${lmp_ip}  fsm_alias=uboot_downgrade
#    ...  ELSE IF    '${system_module}'=='ASIK'   Not Yet Supported

    [Return]  ${REBOOT_NEEDED}

    [Teardown]  run keywords
    ...       run keyword and ignore error  Execute Command On Enb   cmd=rm /ffs/run/prepare-firmware.sh  alias=uboot_downgrade
    ...  AND  Teardown Enb Fsm Access  alias=uboot_downgrade

Perform UBoot Downgrade on SM
    [Arguments]  ${lmp_ip}  ${fsm_alias}
    # check is verssions are the same
    log to console with time  ---------- [START] Uboot Downgrade SM ----------
    ${check_version}=  Execute Command On Enb   cmd=/ffs/run/prepare-firmware.sh -v    alias=${fsm_alias}
    ${downgrade_needed}=  Evaluate  str("""U-boot versions are different""") in str("""${check_version}""")

    run keyword if  ${downgrade_needed}  Log  UBoot Downgrade on SM: Needed [DOWNGRADING]  level=WARN  console=True
    ...  ELSE  Log  UBoot Downgrade on SM: Not Needed  level=WARN  console=True

    # perform downgrade
    ${downgrade_output}=  run keyword if  ${downgrade_needed}  Execute Command On Enb   cmd=/ffs/run/prepare-firmware.sh    alias=${fsm_alias}
    log  ${downgrade_output}  console=False

    ${recheck_version}=  run keyword if  ${downgrade_needed}  Execute Command On Enb   cmd=/ffs/run/prepare-firmware.sh -v    alias=${fsm_alias}
    ${downgrade_successful}=  run keyword if  ${downgrade_needed}
    ...  Evaluate  str("""u-boot versions are the same""") in str("""${recheck_version}""")


    run keyword if  ${downgrade_needed} and '${downgrade_successful}'=='False'  Log  UBoot Downgrade on SM Unsuccessfull  level=WARN  console=True
    run keyword if  ${downgrade_needed} and ${downgrade_successful}  Log  UBoot Downgrade on SM Successfull  level=WARN  console=True
    log to console with time  ---------- [END] Uboot Downgrade SM ----------
    run keyword if  ${downgrade_needed}  set suite variable  ${REBOOT_NEEDED}  ${True}

Perform Bios Downgrade on ASIL
    [Arguments]  ${lmp_ip}  ${fsm_alias}

    ${file_name_path}=  Execute Command On Enb
    ...  cmd=find /ffs/run/swpool/LFS -iname FCT-SNFB1-MC-BW*.bin
    ...  alias=${fsm_alias}


    ${bios_version_in_load}=
    ...  Execute Command On Enb
        ...  cmd=strings ${file_name_path} | grep BIOS | awk '{print $NF}'
        ...  alias=${fsm_alias}

    ${current_bios_ver}=
    ...  Execute Command On Enb
        ...  cmd=chk ver | grep BIOS | awk -F "= " '{print $2}' | awk -F " " '{print $1}'
        ...  alias=${fsm_alias}

    ${cpu_type}=
    ...  Execute Command On Enb
        ...  cmd=cat /proc/cpuinfo | grep ste | head -n 1 | awk -F " " '{print $3}'
        ...  alias=${fsm_alias}

    ${cpu_type}=  Evaluate  str("""${cpu_type}""").rstrip()
#    4 => B0  - Downgrade not possible
#    5 => B1  - Downgrade Possible
#    7 => C0  - Downgrade Possible

    log to console with time  >>${cpu_type}<<
    ${downgrade_supported}=  run keyword if  '${cpu_type}'=='5' or '${cpu_type}'=='7'  set variable  ${True}
    ...  ELSE  set variable  ${False}

    ${downgrade_needed}=  Evaluate  str("""${current_bios_ver}""").rstrip() not in str("""${bios_version_in_load}""").rstrip()

    run keyword if  ${downgrade_needed} and ${downgrade_supported}
        ...  Log  UBoot Downgrade on SM: ASIL Needed [DOWNGRADING]  level=WARN  console=True
    ...  ELSE IF  ${downgrade_needed} and '${downgrade_supported}'!='True'
        ...  Log  UBoot Downgrade on SM: ASIL Downgrade Of Module Not Supported  level=WARN  console=True
    ...  ELSE IF  '${downgrade_needed}'!='True'
        ...  Log  UBoot Downgrade on SM: ASIL Downgrade Not Needed  level=WARN  console=True

    ${downgrade_output}=  run keyword if  ${downgrade_needed} and ${downgrade_supported}
    ...  Execute Command On Enb
        ...  cmd=update_bios.sh -F -D ${file_name_path}
        ...  alias=${fsm_alias}



    ${downgrade_successful}=  run keyword if  ${downgrade_needed} and ${downgrade_supported}
    ...  Evaluate  str("""Successfully updated bios on bootflash""") in str("""${downgrade_output}""")

    run keyword if  ${downgrade_needed} and ${downgrade_successful}
        ...  Log  UBoot Downgrade on SM: ASIL Successfull  level=WARN  console=True
    ...  ELSE IF  ${downgrade_needed} and '${downgrade_successful}'!='True'
        ...  Log  UBoot Downgrade on SM: ASIL Unsuccessfull  level=WARN  console=True

     run keyword if  ${downgrade_needed}  set suite variable  ${REBOOT_NEEDED}  ${True}







Perform Uboot Downgrade On BB
    [Arguments]  ${card_index}

    ${output}=  run_command_on_card  uboot_port_suffix=${card_index}  command=/ffs/run/prepare-firmware.sh -v  timeout=300s
    ${downgrade_needed}=  Evaluate  str("""U-boot versions are different""") in str("""${output}""")

    run keyword if  ${downgrade_needed}
        ...        Log  UBoot Downgrade on BB:${card_index} Needed [DOWNGRADING]  level=WARN  console=True
        ...  ELSE  Log  UBoot Downgrade on BB:${card_index} Not Needed  level=WARN  console=True

    ${downgrade_output}=  run keyword if  ${downgrade_needed}
        ...  run_command_on_card   uboot_port_suffix=${card_index}  command=/ffs/run/prepare-firmware.sh  timeout=300s
    run keyword if  ${downgrade_needed}  log to console with time  ${downgrade_output}
    ${downgrade_successful}=  run keyword if  ${downgrade_needed}
    ...  Evaluate  str("""U-boot downgrade/upgrade is succesfull""") in str("""${downgrade_output}""")


    ${double_check}=  run_command_on_card  uboot_port_suffix=${card_index}  command=/ffs/run/prepare-firmware.sh -v  timeout=300s
    ${downgrade_successful_double_check}=  Evaluate  str("""u-boot versions are the same""") in str("""${double_check}""")

    run keyword if  ${downgrade_needed} and '${downgrade_successful}'=='False'
    ...  run keyword if  '${downgrade_successful_double_check}'=='False'
        ...  Log  UBoot Downgrade on BB:${card_index} Unsuccessfull  level=WARN  console=True
    run keyword if  ${downgrade_needed} and ${downgrade_successful} and ${downgrade_successful_double_check}
        ...  Log  UBoot Downgrade on BB:${card_index} Successfull  level=WARN  console=True
    run keyword if  ${downgrade_needed}  set suite variable  ${REBOOT_NEEDED}  ${True}

Perform Uboot Downgrade On ABIC
    [Arguments]  ${card_index}  ${fsm_alias}

    ${uboot_version}=
    ...  run_command_on_card
        ...  uboot_port_suffix=${card_index}
        ...  command=sysinfo 2>&1| head -n40 | grep "ID_00_UBOOT_VERSION_\\[0\\]" | awk -F "'" '{print $2}'
        ...  timeout=300s


    ${uboot_version}=  Evaluate  str("""${uboot_version}""").rstrip()

    ${file_name}=  Execute Command On Enb
    ...  cmd=find /ffs/run/swpool/LFS -iname ASPB-MC-BW*.bin
    ...  alias=${fsm_alias}

    ${downgrade_needed}=  Evaluate  str("""${uboot_version}""") not in str("""${file_name}""")
    run keyword if  ${downgrade_needed}
    ...        Log  UBoot Downgrade on BB:${card_index} Needed [DOWNGRADING]  level=WARN  console=True
    ...  ELSE  Log  UBoot Downgrade on BB:${card_index} Not Needed  level=WARN  console=True

    ${filename_path_incorrect}=  run keyword if  ${downgrade_needed}
    ...  Evaluate  str("""/ffs/run/swpool/LFS/boot""") not in str("""${file_name}""")

    run keyword if  ${downgrade_needed} and ${filename_path_incorrect}
    ...  Execute Command On Enb
        ...  cmd=cp ${file_name} /ffs/run/swpool/LFS/boot
        ...  alias=${fsm_alias}

    ${downgrade_output}=  run keyword if  ${downgrade_needed}
    ...  run_command_on_card
        ...  uboot_port_suffix=${card_index}
        ...  command=/ffs/run/prepare-firmware.sh
        ...  timeout=300s

    ${downgrade_successful}=  run keyword if  ${downgrade_needed}
    ...  Evaluate  str("""U-boot downgrade/upgrade is succesfull""") in str("""${downgrade_output}""")


    ${double_check}=  run keyword if  ${downgrade_needed}
    ...  run_command_on_card  uboot_port_suffix=${card_index}  command=/ffs/run/prepare-firmware.sh -v  timeout=300s
    ${downgrade_successful_double_check}=  run keyword if  ${downgrade_needed}
    ...  Evaluate  str("""u-boot versions are the same""") in str("""${double_check}""")

    run keyword if  ${downgrade_needed} and '${downgrade_successful}'=='False'
    ...  run keyword if  '${downgrade_successful_double_check}'=='False'
        ...  Log  UBoot Downgrade on BB:${card_index} Unsuccessfull  level=WARN  console=True
    run keyword if  ${downgrade_needed} and ${downgrade_successful} and ${downgrade_successful_double_check}
        ...  Log  UBoot Downgrade on BB:${card_index} Successfull  level=WARN  console=True
    run keyword if  ${downgrade_needed}  set suite variable  ${REBOOT_NEEDED}  ${True}

#    ${output_delete_timestamp}=  run keyword if  ${downgrade_needed}
#    ...  run_command_on_card
#        ...  uboot_port_suffix=${card_index}
#        ...  command=uboot_env del previous_uboot_timestamp
#        ...  timeout=300s
#    ${output_downgrade}=  run keyword if  ${downgrade_needed}
#    ...  run_command_on_card
#        ...  uboot_port_suffix=${card_index}
#        ...  command=update_u-boot.sh -f ${file_name}
#        ...  timeout=300s


#     uboot verssion is changing after reboot so it impossible to check it here
#    ${recheck_uboot_version}=  run keyword if  ${downgrade_needed}
#    ...  run_command_on_card
#        ...  uboot_port_suffix=${card_index}
#        ...  command=sysinfo 2>&1| head -n40 | grep "ID_00_UBOOT_VERSION_\\[0\\]" | awk -F "'" '{print $2}'
#        ...  timeout=300s
#
#    ${recheck_uboot_version}=  Evaluate  str("""${recheck_uboot_version}""").rstrip()
#    ${downgrade_successful}=  run keyword if  ${downgrade_needed}
#    ...  Evaluate  str("""${recheck_uboot_version}""") in str("""${file_name}""")
#
#    run keyword if  ${downgrade_needed} and '${downgrade_successful}'=='False'
#        ...  Log  UBoot Downgrade on BB:${card_index} Unsuccessfull  level=WARN  console=True
#    run keyword if  ${downgrade_needed} and ${downgrade_successful}
#        ...  Log  UBoot Downgrade on BB:${card_index} Successfull  level=WARN  console=True
#    run keyword if  ${downgrade_needed}  set suite variable  ${REBOOT_NEEDED}  ${True}


Perform Bios Update on ABIO or ABIN
    [Arguments]  ${card_index}  ${fsm_alias}

    ${file_name_path}=  Execute Command On Enb
    ...  cmd=find /ffs/run/swpool/LFS -iname ASP-SNFB1-MC-BW_*.bin
    ...  alias=${fsm_alias}

    ${bios_version_in_load}=
    ...  run_command_on_card
        ...  uboot_port_suffix=${card_index}
        ...  command=strings ${file_name_path} | grep BIOS | awk '{print $NF}'
        ...  timeout=300s

    ${current_bios_ver}=
    ...  run_command_on_card
        ...  uboot_port_suffix=${card_index}
        ...  command=chk ver | grep BIOS | awk -F "= " '{print $2}' | awk -F " " '{print $1}'
        ...  timeout=300s
#    ${uboot_version}=  Evaluate  str("""${uboot_version}""").rstrip()

    ${cpu_type}=
    ...  run_command_on_card
        ...  uboot_port_suffix=${card_index}
        ...  command=cat /proc/cpuinfo | grep ste | head -n 1 | awk -F " " '{print $3}'
        ...  timeout=300s
    ${cpu_type}=  Evaluate  str("""${cpu_type}""").rstrip()
#    4 => B0  - Downgrade not possible
#    5 => B1  - Downgrade Possible
#    7 => C0  - Downgrade Possible

    log to console with time  >>${cpu_type}<<
    ${downgrade_supported}=  run keyword if  '${cpu_type}'=='5' or '${cpu_type}'=='7'  set variable  ${True}
    ...  ELSE  set variable  ${False}

    ${downgrade_needed}=  Evaluate  str("""${current_bios_ver}""").rstrip() not in str("""${bios_version_in_load}""").rstrip()

    run keyword if  ${downgrade_needed} and ${downgrade_supported}
        ...  Log  UBoot Downgrade on BB:${card_index} Needed [DOWNGRADING]  level=WARN  console=True
    ...  ELSE IF  ${downgrade_needed} and '${downgrade_supported}'!='True'
        ...  Log  UBoot Downgrade on BB:${card_index} Downgrade Of Module Not Supported  level=WARN  console=True
    ...  ELSE IF  '${downgrade_needed}'!='True'
        ...  Log  UBoot Downgrade on BB:${card_index} Downgrade Not Needed  level=WARN  console=True

    ${downgrade_output}=  run keyword if  ${downgrade_needed} and ${downgrade_supported}
    ...  run_command_on_card
        ...  uboot_port_suffix=${card_index}
        ...  command=update_bios.sh -F -D ${file_name_path}
        ...  timeout=300

    ${downgrade_successful}=  Evaluate  str("""Successfully updated bios on bootflash""") in str("""${downgrade_output}""")

    run keyword if  ${downgrade_needed} and ${downgrade_successful}
        ...  Log  UBoot Downgrade on BB:${card_index} Successfull  level=WARN  console=True
    ...  ELSE IF  ${downgrade_needed} and '${downgrade_successful}'!='True'
        ...  Log  UBoot Downgrade on BB:${card_index} Unsuccessfull  level=WARN  console=True

     run keyword if  ${downgrade_needed}  set suite variable  ${REBOOT_NEEDED}  ${True}



Check BBU Status
    [Arguments]  ${admin_alias}
    #  brakuje warunku na FBBC jesli FSMF nie posiada zadnych BBU to 0 failuje *** test cases ***
    #  jesli bedzie potrzebne to trzeba jakos dorobic
    log to console with time  ========================
    log to console with time  Checking BBUnit status on node${THIS_NODE}
    ${bts_info}=  admin.get_bts_info  connection=${admin_alias}  timeout=60s
    #sprawdzic czy jest 6450 bo nie enabluje sie SM
    Check If BTS Is Ready  ${bts_info['systemModules']}
    ${bb_info_string}=  Evaluate  str("""${bts_info['basebandModules']}""")
    run keyword if  "${bb_info_string}"==""  Fail
    ${bbunit_count}=  Wait Until Keyword Succeeds  5x  10s  get length  ${bts_info['basebandModules']}
    run keyword if  "${bbunit_count}"=="0"  Fail
    : FOR  ${bb_unit}  IN  @{bts_info['basebandModules']}
    \  @{required_keys}=  create list  operationalState  availabilityStatus  proceduralState
    \  ${unified_bb_unit_dict}=  Unify Dictionary Keys And Values  ${bb_unit}  ${required_keys}  nested_key=['status']
    \  ${print_status}=  catenate  SEPARATOR=${SPACE}
    ...  [${unified_bb_unit_dict['status']['operationalState']},
    ...  ${unified_bb_unit_dict['status']['availabilityStatus']},
    ...  ${unified_bb_unit_dict['status']['proceduralStatus']}]

    \  log to console with time  ${print_status}
    : FOR  ${bb_unit}  IN  @{bts_info['basebandModules']}
    \  @{required_keys}=  create list  operationalState  availabilityStatus  proceduralState
    \  ${unified_bb_unit_dict}=  Unify Dictionary Keys And Values  ${bb_unit}  ${required_keys}  nested_key=['status']
    \  ${print_status}=  catenate  SEPARATOR=${SPACE}
    ...  [${unified_bb_unit_dict['status']['operationalState']},
    ...  ${unified_bb_unit_dict['status']['availabilityStatus']},
    ...  ${unified_bb_unit_dict['status']['proceduralStatus']}]

    \  run keyword if  '${unified_bb_unit_dict['status']['operationalState']}'!='enabled'
       ...  run keyword if  '${unified_bb_unit_dict['status']['availabilityStatus']}'!='online'
            ...  run keyword if  '${unified_bb_unit_dict['status']['proceduralStatus']}'!='configured'
                ...  Fail  ${print_status}
    log to console with time  -====== All BB_Units Detected ======-


Check If BTS Is Ready
    [Arguments]  ${bts_info}
    run keyword if  '${bts_info[0]['status']['proceduralStatus']}'!='configured'  Fail
    log to console with time  BTS Status: ${bts_info[0]['status']['proceduralStatus']}

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

Count Downtime
    ${downtime_dict}=  create dictionary

   :FOR  ${node}  IN  @{PERFORM_UPGRADE}
   \  ${node_as_string}=  convert to string  ${node}
   \  ${start_frame}=  Syslog Parser Time
   ...  node=${node}
   ...  message=has been changed from OnAirDone to Validated
   ...  timestamp=${START_OF_UPGRADE['${node_as_string}']}
   ...  syslog_name=syslog_savepoint_start_of_upgrade
   \  ${start}=   get_first_cell_downtime    ${start_frame}
   \  ${stop_frame}=  Syslog Parser Time
   ...  node=${node}
   ...  message=has been changed from Validated to OnAirDone
   ...  timestamp=${START_OF_UPGRADE['${node_as_string}']}
   ...  syslog_name=syslog_savepoint_start_of_upgrade
   \  ${stop}=   get_last_cell   ${stop_frame}
   \  ${diff_downtime}=   get_delta_time_in_seconds    ${start}    ${stop}
   \  ${diff_downtime_str}=  convert to string  ${diff_downtime}
   \  Set To Dictionary   ${downtime_dict}    ${node_as_string}=${diff_downtime_str}
   set suite variable  ${DOWNTIME_DICT}  ${downtime_dict}


Reset time Report
    ${reset_time_dict}=  create dictionary

   :FOR  ${node}  IN  @{PERFORM_UPGRADE}
   \  ${node_as_string}=  convert to string  ${node}
   \  ${start_frame}=  Syslog Parser Time
   ...  node=${node}
   ...  message=has been changed from OnAirDone to Validated
   ...  timestamp=${START_OF_RESET['${node_as_string}']}
   ...  syslog_name=syslog_savepoint_start_of_reset

   \  ${stop_frame}=  Syslog Parser Time
   ...  node=${node}
   ...  message=has been changed from Validated to OnAirDone
   ...  timestamp=${START_OF_RESET['${node_as_string}']}
   ...  syslog_name=syslog_savepoint_start_of_reset

   \  ${start}=   get_first_cell  ${start_frame}
#   \  ${start}=   get_first_cell  ${start_frame}  ${AMOUNT_OF_CELLS}
   \  ${stop}=   get_last_cell   ${stop_frame}


   \  ${diff_downtime}=   get_delta_time_in_seconds    ${start}    ${stop}
   \  ${diff_downtime_str}=  convert to string  ${diff_downtime}
   \  Set To Dictionary   ${reset_time_dict}    ${node_as_string}=${diff_downtime_str}
   set suite variable  ${RESET_TIME_DICT}  ${reset_time_dict}




#   ${start_frame}=   Syslog Parser Time  has been changed from Validated to OnAirDone
#   ${stop_frame}=  Syslog Parser Time  has been changed from OnAirDone to Validated
#   ${stop}=   get_first_cell   ${start_frame}   ${AMOUNT_OF_CHECK_CELLS}
#   ${start}=   get_last_cell_activation   ${stop_frame}
#   ${diff_reset}=   get_delta_time_in_seconds   ${start}    ${stop}
#   ${diff_reset_str}=  convert to string  ${diff_reset}
#   Log to console with time  Reset time: ${diff_reset}
##   set suite variable  ${DIFF_RESET}    ${diff_reset}
#   set suite variable  ${RESET_TIME}    ${diff_reset_str}

Syslog Parser Time
    [Arguments]   ${node}  ${message}  ${timestamp}  ${syslog_name}
    log to console with time  Searching For message In Syslog
#    Collect from Savepoint   savepoint=${timestamp}   destination_file=${LOG_DIR}/syslog_parser  compress=True  alias=syslog_node_${node}

    ${status}=  Collect from Savepoint
    ...  savepoint=${timestamp}
    ...  destination_file=${LOG_DIR}/node${node}/${syslog_name}_node_${node}
    ...  compress=True
    ...  alias=syslog_node_${node}

    ${items} =  run keyword   Message should exist in syslog file   regexp=${message}  savepoint=${timestamp}   alias=syslog_node_${node}
    Log  ${items}  console=False
    [Return]  ${items}


Get Active Software On Remotes
    &{initial_sw_dict}=  Create Dictionary

    :FOR  ${node}  IN  @{PERFORM_UPGRADE}
    \  ${status}=  run keyword and return status
        ...  Wait Until Keyword Succeeds  4x  1m
            ...  admin.setup_admin
                ...  bts_host=${TL_CONFIG['${node}']['LMP_IP']}
                ...  remote_host=${TL_CONFIG['${node}']['VM_IP']}
                ...  remote_host_username=${VM_USER}
                ...  remote_host_password=${VM_PASSWORD}
                ...  alias=remote_node_sw_check_${node}
    \  run keyword unless  ${status}  Fail  Unable to setup admin
    \  &{bts_info}=  run keyword if  ${status}  admin.get_bts_info  connection=remote_node_sw_check_${node}  timeout=60
    \  run keyword if  ${status}  admin.teardown_admin  alias=remote_node_sw_check_${node}
    \  ${sw_info}=  get from dictionary    ${bts_info}   swInfo
    \  ${sw_info_string}=  convert to string  ${sw_info}
    \  ${active_sw_regex}=  get regexp matches  ${sw_info_string}  'swVersion': (u){0,1}'([a-z,A-Z,0-9,.,_]{0,40})'  2
    \  ${active_sw}=  set variable  ${active_sw_regex[0]}
    \  run keyword and ignore error  log to console with time  Active SW node_${node}: ${active_sw}
    \  ${node_as_string}=  convert to string  ${node}
    \  Set To Dictionary   ${initial_sw_dict}    ${node_as_string}=${active_sw}
    set suite variable  ${INITIAL_SW_DICT}  ${initial_sw_dict}

Set Reported Software
    &{initial_sw_dict}=  Create Dictionary
    FOR  ${node}  IN  @{PERFORM_UPGRADE}
      ${node_as_string}=  convert to string  ${node}
      Set To Dictionary   ${initial_sw_dict}    ${node_as_string}=${CANDIDATE}
    END
    set suite variable  ${INITIAL_SW_DICT}  ${initial_sw_dict}

Report To Reporting Portal
    [Documentation]  Keyword send report to reporting portal and return link
    [Arguments]  ${status}=passed  ${initial_build}=${INITIAL_SW_DICT}  ${candidate}=${CANDIDATE}  ${case_type}=Upgrade
    ...  ${loop_number}=default

    log to console with time  Reporting execution to Reporting Portal
    End time

    # create dummy to succesfully report empty value if something go wrong before upgrade/variables/other issues
    # report only node1 from upgrade

    ${node_as_string}=  convert to string  ${PERFORM_UPGRADE[0]}
    ${initial_build}=  set variable  ${initial_build['${node_as_string}']}
    ${key_exist_upgrade}=  run keyword and return status  dictionary should contain key  ${DOWNTIME_DICT}  key=${node_as_string}
    ${key_exist_reset}=  run keyword and return status  dictionary should contain key  ${RESET_TIME_DICT}  key=${node_as_string}

    ${report_downtime}=  run keyword if  '${case_type}'=='Upgrade' and ${key_exist_upgrade}
    ...  set variable  ${DOWNTIME_DICT['${node_as_string}']}
        ...  ELSE  set variable  ${EMPTY}

    ${reset_time}=  run keyword if  '${case_type}'=='Reset' and ${key_exist_reset}
    ...  set variable  ${RESET_TIME_DICT['${node_as_string}']}
        ...  ELSE  set variable  ${EMPTY}

    ${NAME_TO_REPORT}=  convert to string  UUF4ALL_${REPORT['CA']}_${case_type}
    ${starttime}=  Replace String  ${START_TIME}  -  ${EMPTY}
    ${endtime}=  Replace String  ${STOP_TIME}  -  ${EMPTY}
    ${hardware}=  convert to string  ${REPORT['SMOD']}+${REPORT['RUS_IDINAHUI']}
    ${uuf_test}=  Set Variable  True
    &{empty_dict}=  Create Dictionary

   ${link_to_reporting_portal}=
   ...  run keyword if  '${case_type}'=='Upgrade'
        ...  uuf_report to rp
            ...  name=${NAME_TO_REPORT}
            ...  result=${status}
            ...  ca=${REPORT['CA']}
            ...  testline=${HOSTNAME}
            ...  build=${candidate}
            ...  qc_domain=${REPORT['QC_DOMAIN']}
            ...  qc_project=${REPORT['QC_PROJECT']}
            ...  qc_id=${REPORT['QC_ID']}
            ...  links=&{empty_dict}
            ...  uuf_test=${uuf_test}
            ...  parameter_1=${initial_build}
            ...  label=${LABEL}
            ...  starttime=${starttime}.000
            ...  endtime=${endtime}.000
            ...  ru_type=${REPORT['RUS_IDINAHUI']}
            ...  sa/nsa_variant=${REPORT['SA_NSA']}
            ...  tdd/fdd_variant=${REPORT['TDD_FDD']}
            ...  upgrade_downtime=${report_downtime}  # currently only 1st node is reported
            ...  case_type=${case_type}
            ...  hw_id=${hardware}
            ...  tool=WebEM
            ...  customers=${REPORT['CUSTOMERS']}
            ...  log_path=${LOG_DIR}
    ...  ELSE IF  '${case_type}'=='Reset'
        ...  uuf_report to rp
            ...  name=${NAME_TO_REPORT}
            ...  result=${status}
            ...  ca=${REPORT['CA']}
            ...  testline=${HOSTNAME}
            ...  build=${initial_build}
            ...  qc_domain=${REPORT['QC_DOMAIN']}
            ...  qc_project=${REPORT['QC_PROJECT']}
            ...  qc_id=${REPORT['QC_ID']}
            ...  links=&{empty_dict}
            ...  uuf_test=${uuf_test}
            ...  parameter_1=${initial_build}
            ...  label=${LABEL}
            ...  starttime=${starttime}.000
            ...  endtime=${endtime}.000
            ...  ru_type=${REPORT['RUS_IDINAHUI']}
            ...  sa/nsa_variant=${REPORT['SA_NSA']}
            ...  tdd/fdd_variant=${REPORT['TDD_FDD']}
            ...  reset_downtime=${reset_time}  # only first node
            ...  case_type=${case_type}
            ...  hw_id=${hardware}
            ...  tool=WebEM
            ...  customers=${REPORT['CUSTOMERS']}
            ...  log_path=${LOG_DIR}

    Create File  /home/ute/reporting_portal_report/UUF4ALL_${case_type}_${status}_${loop_number}.txt  ${link_to_reporting_portal}


    set suite variable  ${LINK_TO_RP}  ${link_to_reporting_portal}
    log to console with time  ${LINK_TO_RP}
