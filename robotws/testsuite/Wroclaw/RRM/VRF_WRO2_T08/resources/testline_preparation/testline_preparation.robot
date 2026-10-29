*** Settings ***
Library     Process
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin       WITH NAME   admin
Library     taf.transport.ssh             WITH NAME   ssh
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/bts_log.py
Library     taf/rfrl/common_resources/python/reset_bts_configuration.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/statuses.py

Documentation  Author: tomasz.sobania@nokia.com
...            The keyword below is used for post-agent preparation of all the base stations of a given testline.
...            - it uploads additional swconfig flags and cp_runtime for debug syslogs;
...            - uploads scf for the branch BTS is on;
...            - if it detects incompatible sw alarms on RMODs - it downloads the SW (if needed)
...              and performs sw update for the RMODs and checks if everything's on Air after it
...            - it can update your testline to a given build without agent as well, just fill out sw_for_update
...              parameter to do that. If you're running a single run and want to use skip_agent option and testline
...              preparation to update the testline instead of agent - use skip_agent parameter then
...
...            DISCLAIMER: Currently the keyword doesn't support downgrades to a branch older than more than 3
...                        compared to your station's current one. (i.e. SBTS22R3 -> SBTS21B won't work, but
...                        SBTS22R3 -> SBTS22R1 should be ok)


*** Variables ***
${SW_FOR_UPDATE}  ${None}
${SKIP_TL_PREP}   ${FALSE}
${CUT_324}        ${FALSE}


*** Keywords ***
Prepare Testline
    [Documentation]  Keyword for post-agent reservation configuration preparation (swconfig/cp_runtime, RMOD SW, SCF).
    ...              This keyword will work if you have your TL SCF's named according to the standard we just made up!
    ...              Check custom-config/Wroclaw/7_16_UTE5GCLOUDT196 to see how SCF's should be stored and named for
    ...              their respective branches. Basically it should look like this:
    ...              <tl_name>_<branch >(_<bts_id>(no need for the main Gnb))_<RAT>.xml . So for example:
    ...              main Gnb SCF for trunk:   config/7_16_UTE5GCLOUDT304/trunk/7_16_UTE5GCLOUDT304_trunk_5g.xml
    ...              enb 40824 for branch 21A: config/7_16_UTE5GCLOUDT304/21A/7_16_UTE5GCLOUDT304_21A_40824_4g.xml
    ...
    ...
    ...              Testline's __init__.py should be also properly configured with the test_pcs, enbs and gnbs objects
    ...              containing all the BTS's of the given configuration in order for the 'Prepare Testline' KW to be
    ...              able to prepare them.
    ...              Main Gnb VM object should be named '_lmp_vm_gnb_1' ( with object '_cbts_1' linked in connections
    ...              parameter).
    ...              All the other Stations should have their BTS_ID number in their object ID in init
    ...              (i.e. '_lmp_vm_enb_40824' with '_enb_40824' configured in its connections parameter, or
    ...              '_lmp_vm_gnb_40825' with '_cbts_40825' conenction linked) corresponding to the one in their
    ...              respective SCFs stored in the configuration's custom_config folder.
    ...
    ...              The sw_for_update parameter should normally be left unfilled when used with agent's
    ...              software_uploaded option, but if you want testline preparation to update the BTS SW on your
    ...              main station as well you can fill it with full software build name (use SBTS00 for trunk builds,
    ...              i.e. SBTS00_ENB_9999_220113_000008).
    ...
    ...              You can fill skip_agent parameter with 'True' (${TRUE} or TRUE won't work) if you're running a
    ...              single run with 'skip_agent' option and you want testline preparation to take the reservation's SW
    ...              build from its json and update the testline to the software build it has found there.
    ...              (you fill it in the 'additional options for pybot' window while configuring your single run, i.e.
    ...              like this: -v skip_agent:True)
    ...
    ...              You can fill skip_tl_prep parameter with 'True' if your testline is already prepared for testing
    ...
    ...              CUT_324 parameter is made for TLs 322 and 324 only, don't change it when used on other lines
    ...
    [Arguments]  @{additional_swconfig_flags}
    ...          ${sw_for_update}=${SW_FOR_UPDATE}
    ...          ${skip_tl_prep}=${SKIP_TL_PREP}
    ...          ${cut_324}=${CUT_324}
    Switch Pdu Ports  power_on
    IF  '${sw_for_update}' == '${None}'  Check Agent
    IF  not ${skip_tl_prep}  Testline Preparation  @{additional_swconfig_flags}  sw_for_update=${SW_FOR_UPDATE}  cut_324=${cut_324}

Testline Preparation
    [Arguments]  @{additional_swconfig_flags}  ${sw_for_update}  ${cut_324}
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    Set Global Variable  ${SW_PACKAGE}  ${None}
    IF  not '${sw_for_update}' == '${None}'  Sanity Check On Main Gnb Station  ${sw_for_update}
    Set Variables
    ${gnbs}  ${enbs}  Find Configuration Base Stations
    ${gnbs}=  Cut Gnb For T322  ${gnbs}  ${cut_324}
    Log To Console  Starting Testline Preparation
    Prepare Base Stations  @{additional_swconfig_flags}  gnbs=${gnbs}  enbs=${enbs}
    Log To Console  Testline configuration is now prepared for testing!
    [Teardown]  Run Keyword And Ignore Error    Remove File   ${SW_PACKAGE}

########################################################################
Check Agent
    ${admin_alias}=  Wait Until Keyword Succeeds  10x  60s  admin.Connect To
    ${sw}=  Wait Until Keyword Succeeds  10x  60s  Check Software Version  ${admin_alias}
    ${agent_sw}=  Find Sw In Reservation Json  ${SW_FOR_UPDATE}  ${sw}
    ${agent_successful}=  Check If Agent Updated Software  ${sw}  ${agent_sw}
    IF  not ${agent_successful}  Set Global Variable  ${SW_FOR_UPDATE}  ${agent_sw}
    RETURN    ${agent_successful}
    [Teardown]  admin.Teardown All Aliases For Admin

Find Configuration Base Stations
    ${gnbs}  ${enbs}=  Get Number Of Neighbour Gnbs And Enbs
    RETURN  ${gnbs}  ${enbs}

Prepare Base Stations
    [Arguments]  @{additional_swconfig_flags}  ${gnbs}  ${enbs}
    Remove Software Package If Needed
    IF  ${enbs}  Prepare Lte Stations  @{enbs}
    Remove Software Package If Needed
    Prepare Main Gnb Station  @{additional_swconfig_flags}  is_there_enb=${enbs}
    IF  ${gnbs}  Prepare Neighbour Gnb Stations  @{gnbs}  is_there_enb=${enbs}
    [Teardown]  admin.Teardown All Aliases For Admin

Prepare Lte Stations
    [Arguments]  @{enbs}
    FOR  ${enb}  IN  @{enbs}
        ${ssh}=  Connect to Base Station test PC  ${enb}
        ${remote_admin}=  Wait Until Keyword Succeeds  10x  60s  Connect to Neighbour Bts Admin  ${enb}
        Set Global Variable  ${REMOTE_ADMIN}  ${remote_admin}
        ${status}  ${error}=  Run Keyword And Ignore Error  Prepare Lte Station  ${enb}  ${ssh}
        Stop And Collect Btslog  btslog_${enb}  ${LOG_PATH}/testline_preparation/syslogs
        Run Keyword And Ignore Error  admin.Get Snapshot
        ...  target_file_name=${LOG_PATH}/testline_preparation/snapshot_${enb}.zip  connection=${REMOTE_ADMIN}
        admin.Teardown  connection=${REMOTE_ADMIN}
        IF  not '${status}' == 'PASS'  Fail  Preparation failed on ${enb} : ${error}
    END

Prepare Lte Station
    [Arguments]  ${enb}  ${ssh}
    Log To Console  Preparing ${enb}...
    Prepare Environment On Neighbour Vm  connection=${ssh}
    Start Collecting Syslog on neighbour Vm  ${enb}
    Update Sw On Neighbour Bts If Needed  ${COMPATIBLE_ENB_BUILD}  ${enb}
    ${enb_scf_path}=  Get Node Scf Path  ${enb}  ${SCF_ENB}
    Activate Node Scf  scf_path=${enb_scf_path}  connection=${REMOTE_ADMIN}  vm_ip=${enb}
    Sleep  240s  reason=wait for BTS commissioning and possible RU SW alarms
    Update Sw on Neighbour Rmods If Needed And Wait For OnAir  bts_type=enb  connection=${REMOTE_ADMIN}  bts_id=${enb}
    Check Build On Neighbour Bts  ${COMPATIBLE_ENB_BUILD}  ${REMOTE_ADMIN}

Sanity Check On Main Gnb Station
    [Arguments]  ${sw_for_update}
    ${admin_alias}=  Wait Until Keyword Succeeds  10x  60s  admin.Connect To
    ${sw}=  Wait Until Keyword Succeeds  10x  60s  Check Software Version  ${admin_alias}
    ${is_update_needed}  ${is_conf_reset_needed}=  Check If Update Is Needed  ${sw}  ${sw_for_update}
    IF  ${is_update_needed}  Log To Console  Starting SW Update on Main gNB...
    IF  ${is_update_needed}  Upgrade Sw on Main Gnb  ${sw}  ${sw_for_update}  ${admin_alias}  ${is_conf_reset_needed}
    [Teardown]  Run Keyword And Ignore Error  admin.Teardown  connection=${admin_alias}

Upgrade Sw On Main Gnb
    [Arguments]  ${current_sw}  ${sw_for_update}  ${connection}  ${is_conf_reset_needed}
    Compare Branches  ${current_sw}  ${sw_for_update}
    IF  ${is_conf_reset_needed}  reset_bts_configuration.reset_bts_configuration
    ...  remove_operator_certificates=False  remove_user_account_credentials=False  connection=${connection}
    ${sw_package}=  Wait Until Keyword Succeeds  3x  30s  Download Sw Package  ${sw_for_update}
    Set Global Variable  ${SW_PACKAGE}  ${sw_package}
    admin.Teardown  connection=${connection}
    ${admin_alias}=  admin.Connect To
    Wait Until Keyword Succeeds  400  10  Check Bbmod States  ${admin_alias}
    admin.Update Software  sw_package=${SW_PACKAGE}  connection=${admin_alias}  timeout=2400s
    Sleep  360s  reason=Wait for admin to be available for get_sw_version KW
    admin.Teardown  connection=${admin_alias}
    ${admin_alias}=  admin.Connect To
    Wait Until Keyword Succeeds  400  10  Check Bbmod States  ${admin_alias}
    [Teardown]  admin.Teardown  connection=${admin_alias}

Remove Software Package If Needed
    IF  not '${SW_PACKAGE}' == '${None}' or '${BUILD}' == '${COMPATIBLE_ENB_BUILD}'  Remove File  ${SW_PACKAGE}

Prepare Main Gnb Station
    [Arguments]  @{additional_swconfig_flags}  ${is_there_enb}
    ${status}  ${error}=  Run Keyword And Ignore Error  Main Gnb Preparation  @{additional_swconfig_flags}  is_there_enb=${is_there_enb}
    IF  not '${status}' == 'PASS'  Collect Snapshot And Fail  ${error}

Collect Snapshot And Fail
    [Arguments]   ${error}
    ${admin_alias}=  admin.Connect To
    admin.Get Snapshot
    ...  target_file_name=/${LOG_PATH}/testline_preparation/snapshot_main_gnb.zip  connection=${admin_alias}
    Fail  Preparation failed on main gNB : ${error}
    [Teardown]  admin.Teardown  connection=${admin_alias}

Main Gnb Preparation
    [Arguments]  @{additional_swconfig_flags}  ${is_there_enb}
    Log To Console  Preparing Main Gnb...
    Start Bts Log  btslog_main_gnb
    IF  not '${BRANCH}' == '21A'  Prepare Tools
    Prepare logging on SMOD
    IF  ${additional_swconfig_flags}  Prepare Swconfig Without Reset  @{additional_swconfig_flags}
    Log To Console  Commissioning Main Gnb...
    ${admin_alias}=  admin.Connect To
    Load Scf  ${admin_alias}
    Wait Until Keyword Succeeds  400  10  Check Rmod States  Before Update  ${admin_alias}
    Update Sw On Rmods If Needed  ${admin_alias}
    Log To Console  Waiting for Nrcells to come up online..
    IF  ${is_there_enb}  Wait For NSA Configuration To Get Up  ${admin_alias}
    Wait Until Keyword Succeeds  270  10  Check Bts State  ${admin_alias}  gnb
    ${sw}=  Wait Until Keyword Succeeds  10x  60s  Check Software Version  ${admin_alias}
    ${update_needed}=  Check If Update Is Needed  ${sw}  ${BUILD}
    Should Not Be True  ${update_needed}
    Log To Console  Main Gnb is OnAir!
    [Teardown]  Run Keywords  admin.Get Snapshot  target_file_name=${LOG_PATH}/testline_preparation/snapshot_maingnb.zip
    ...  connection=${admin_alias}  AND  admin.Teardown  connection=${admin_alias}  AND  Stop And Collect Btslog
    ...  btslog_main_gnb  ${LOG_PATH}/testline_preparation/syslogs

Prepare Neighbour Gnb Stations
    [Arguments]  @{gnbs}  ${is_there_enb}
    Get Swconfig and Cpruntime
    FOR  ${gnb}  IN  @{gnbs}
        ${ssh}=  Connect to Base Station test PC  ${gnb}
        ${remote_admin}=  Connect to Neighbour Bts Admin  ${gnb}
        Set Global Variable  ${REMOTE_ADMIN}  ${remote_admin}
        ${status}  ${error}=  Run Keyword And Ignore Error  Prepare Gnb Station  ${gnb}  ${ssh}  ${is_there_enb}
        Stop And Collect Btslog  btslog_${gnb}  ${LOG_PATH}/testline_preparation/syslogs
        Run Keyword And Ignore Error  admin.Get Snapshot
        ...  target_file_name=${LOG_PATH}/testline_preparation/snapshot_${gnb}.zip  connection=${REMOTE_ADMIN}
        admin.Teardown  connection=${REMOTE_ADMIN}
        IF  not '${status}' == 'PASS'  Fail  Preparation failed on ${gnb} : ${error}
    END

Prepare Gnb Station
    [Arguments]  ${gnb}  ${ssh}  ${is_there_enb}
    Log To Console  Preparing ${gnb}...
    Prepare Environment On Neighbour Vm  connection=${ssh}
    Start Collecting Syslog on neighbour Vm  ${gnb}
    Update Sw On Neighbour Bts If Needed  ${BUILD}  ${gnb}
    ${gnb_scf_path}=  Get Node Scf Path  ${gnb}  ${BRANCH_SCF}
    Upload Swconfig And Cpruntime To Neighbour Gnb  proxy=${ssh}
    Activate Node Scf  scf_path=${gnb_scf_path}  connection=${REMOTE_ADMIN}  vm_ip=${gnb}
    Sleep  300s  reason=wait for BTS commissioning and possible RU SW alarms
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  400  10  Check For Rmod Alarm  ${REMOTE_ADMIN}
    Update Sw on Neighbour Rmods If Needed And Wait for OnAir  bts_type=gnb  bts_id=${gnb}
    ...                                                        connection=${REMOTE_ADMIN}  is_there_enb=${is_there_enb}
    Check Build On Neighbour Bts  ${COMPATIBLE_ENB_BUILD}  ${REMOTE_ADMIN}

Prepare Tools
    Run Keyword and Ignore Error  Prepare Main Vm Tools  ${BUILD}

Start Collecting Syslog on neighbour Vm
    [Arguments]  ${node}
    ${index}=  Find Lmp Index In Init  ${node}
    Start Bts Log  log_name=btslog_${node}  host_ip=${tl.test_pcs[${index}].default_ssh_connection_details.addr}

Update Sw On Neighbour Bts If Needed
    [Arguments]  ${compatible_build}  ${vm_ip}
    ${sw_version}=  Wait Until Keyword Succeeds  10x  60s  Check Software Version  ${REMOTE_ADMIN}
    ${update_needed}  ${is_conf_reset_needed}=  Check If Update Is Needed  ${sw_version}  ${compatible_build}
    IF  ${update_needed}  Update Sw On Neighbour Bts
    ...  build=${compatible_build}  vm_ip=${vm_ip}  is_conf_reset_needed=${is_conf_reset_needed}

Update Sw On Neighbour Bts
    [Arguments]  ${build}  ${vm_ip}  ${is_conf_reset_needed}
    ${index}=  Find Lmp Index In Init  ${vm_ip}
    IF  ${is_conf_reset_needed}  reset_bts_configuration.reset_bts_configuration
    ...  remove_operator_certificates=False  remove_user_account_credentials=False
    ...  connection=${REMOTE_ADMIN}
    ...  remote_host=${tl.test_pcs[${index}].default_ssh_connection_details.addr}
    ${sw_package}=  Wait Until Keyword Succeeds  3x  30s  Download Sw Package  ${build}
    Set Global Variable  ${SW_PACKAGE}  ${sw_package}
    Sleep  480s  reason=wait until SMOD's enabled
    admin.Teardown  connection=${REMOTE_ADMIN}
    ${remote_admin}=   Log On Neighbour Admin  ${vm_ip}
    Set Global Variable  ${REMOTE_ADMIN}  ${remote_admin}
    Wait Until Keyword Succeeds  400  10  Check Bbmod States  ${REMOTE_ADMIN}
    ${update_successful}=  Run Keyword And Return Status  admin.Update Software  sw_package=${sw_package}  timeout=2400  connection=${REMOTE_ADMIN}
    IF  not ${update_successful}  Sleep  240s  reason=Let's wait a bit more then!
    IF  not ${update_successful}  admin.Update Software  sw_package=${sw_package}  timeout=2400  connection=${REMOTE_ADMIN}
    Sleep  180s   reason=wait until SMOD's enabled
    admin.Teardown  connection=${REMOTE_ADMIN}
    ${remote_admin}=   Log On Neighbour Admin  ${vm_ip}
    Set Global Variable  ${REMOTE_ADMIN}  ${remote_admin}
    Wait Until Keyword Succeeds  400  10  Check Bbmod States  ${REMOTE_ADMIN}
    Sleep  240s  reason=wait to be able to commission BTS

Log On Neighbour Admin
    [Arguments]  ${vm_ip}
    ${remote_alias}=  Wait Until Keyword Succeeds  600  20  Connect to Neighbour Bts Admin  ${vm_ip}
    RETURN  ${remote_alias}

Remove Users Json
    [Arguments]  ${vm_ip}
    ssh.Execute  sshpass -p oZPS0rRieRtu ssh toor4nsn@192.168.255.129 "rm /ffs/run/config/users.json"  connection=${vm_ip}
    ssh.Execute  sshpass -p oZPS0rRieRtu ssh toor4nsn@192.168.255.129 reboot  connection=${vm_ip}

Prepare Environment On Neighbour Vm
    [Arguments]  ${connection}
    Log to Console  downloading robotws on neighbour vm...
    ssh.Execute  git clone --recursive git@wrgitlab.int.net.nokia.com:RAN/robotws.git   connection=${connection}
    ssh.Execute  pip install --upgrade pip  connection=${connection}
    ssh.Execute  install_ute  connection=${connection}
    Log To Console  updating library requirements on neighbour vm...
    ssh.Execute  pip install -r /home/ute/robotws/requirements.cfg  connection=${connection}

Activate Node Scf
    [Arguments]  ${connection}  ${scf_path}  ${vm_ip}
    ${id}=  Get Bts Id From Scf Name  ${scf_path}
    ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  3x  60s
    ...         admin.Perform Commissioning  bts_id=${id}  scf_file=${scf_path}  timeout=600  connection=${connection}
    IF  not ${passed}  admin.Teardown  connection=${REMOTE_ADMIN}
    ${remote_admin}=  IF  not ${passed}  Log On Neighbour Admin  ${vm_ip}
    IF  not ${passed}  Set Global Variable  ${REMOTE_ADMIN}  ${remote_admin}

Get Swconfig and Cpruntime
    ${local_asik_alias}=  SMOD Connection
    Download Swconfig   local_file_path=${OUTPUT DIR}/swconfig.txt   connection=${local_asik_alias}
    Download Cpruntime  local_file_path=${OUTPUT DIR}/cp_runtime.ini  connection=${local_asik_alias}
    ssh.Disconnect    connection=${local_asik_alias}

Download Cpruntime
    [Arguments]  ${local_file_path}  ${connection}
    ssh.Download File  remote_path=/ffs/run/cp_runtime.ini  local_path=${local_file_path}  connection=${connection}

Download Swconfig
    [Arguments]  ${local_file_path}  ${connection}
    ssh.Download File  remote_path=/ffs/run/swconfig.txt  local_path=${local_file_path}  connection=${connection}

Upload Swconfig And Cpruntime To Neighbour Gnb
    [Arguments]  ${proxy}
    ${neighbour_asik_alias}=  ssh.Connect To  192.168.255.129  toor4nsn  oZPS0POrRieRtu  proxy=${proxy}
    ssh.Upload File  local_path=${OUTPUT_DIR}/swconfig.txt    remote_path=/ffs/run/swconfig.txt
    ...              connection=${neighbour_asik_alias}
    ssh.Upload File  local_path=${OUTPUT_DIR}/cp_runtime.ini  remote_path=/ffs/run/cp_runtime.ini
    ...              connection=${neighbour_asik_alias}
    ssh.Execute      command=crasign /ffs/run/cp_runtime.ini
    ...              connection=${neighbour_asik_alias}
    ssh.Disconnect   connection=${neighbour_asik_alias}

Connect to Base Station test PC
    [Arguments]    ${node}  ${alias}=test_pc
    ${index}=  Find Lmp Index In Init  ${node}
    ssh.Connect To      hostname=${tl.test_pcs[${index}].default_ssh_connection_details.addr}
    ...                 username=${tl.test_pcs[${index}].default_ssh_connection_details.username}
    ...                 password=${tl.test_pcs[${index}].default_ssh_connection_details.password}
    ...                 alias=${alias}
    RETURN    ${alias}

Connect to Neighbour Bts Admin
    [Arguments]  ${node}  ${alias}=remote_admin_alias
    ${index}=  Find Lmp Index In Init  ${node}
    ${alias}=  admin.Setup Admin  remote_host=${tl.test_pcs[${index}].default_ssh_connection_details.addr}
    ...        remote_host_username=${tl.test_pcs[${index}].default_ssh_connection_details.username}
    ...        remote_host_password=${tl.test_pcs[${index}].default_ssh_connection_details.password}
    ...        name=${alias}
    ...        bts_host=192.168.255.129
    RETURN  ${alias}

Update Sw On Rmods If Needed
    [Arguments]  ${connection_alias}
    Sleep  30s  reason=wait for possible Incompatible SW alarm to appear
    ${alarms}=  admin.Get Active Alarms
    ${incompatible_sw_detected}=  Check Alarms for Incompatible Sw On Rmod  ${alarms}
    IF  ${incompatible_sw_detected}  Upload SW to RMODs  ${connection_alias}

Check For Rmod Alarm
    [Arguments]  ${connection_alias}
    ${alarms}=   admin.Get Alarms  ${connection_alias}
    Check Alarms for Incompatible Sw On Rmod  ${alarms}

Update Sw on Neighbour Rmods If Needed And Wait For OnAir
    [Arguments]  ${bts_type}  ${bts_id}  ${connection}  ${is_there_enb}=${None}
    ${bts_number}=  Extract Bts Number  ${bts_id}
    ${alarms}=  admin.Get active alarms  connection=${connection}
    ${incompatible_sw_detected}=  Check Alarms for Incompatible Sw On Rmod  ${alarms}
    IF  ${incompatible_sw_detected}  Log to console  Incompatible SW on RMODs found on ${bts_type} ${bts_number}, updating SW...
    IF  ${incompatible_sw_detected}  Update Rmod Sw  connection=${connection}
    ${alarms}=  admin.Get active alarms  connection=${connection}
    ${incompatible_sw_detected}=  Check Alarms for Incompatible Sw On Rmod  ${alarms}
    Should Be Equal  ${incompatible_sw_detected}  ${False}
    Wait Until Keyword Succeeds  300  20  Check Bts State  ${connection}  ${bts_type}
    IF  ${is_there_enb}  Wait For NSA Configuration To Get Up  ${connection}
    Log To Console  The ${bts_type} ${bts_number} is OnAir!

Check Bts State
    [Arguments]  ${admin_alias}  ${bts_type}
    ${cell_type}=  Set Cell Type  ${bts_type}
    ${cells}=  admin.Get Cells Info  cell_type=${cell_type}  connection=${admin_alias}
    FOR  ${cell}  IN  @{cells}
        ${status}=  Set Variable  &{cell}[status]
        Should Contain  ${STATUSES["operationalState"]["enabled"]}   &{status}[operationalState]
    END

Set Variables
    ${admin_alias}=  Wait Until Keyword Succeeds  10x  60s  admin.Connect To
    ${sw}=  Wait Until Keyword Succeeds  10x  60s  Check Software Version  ${admin_alias}
    Set Global Variable         ${SYSLOG_PATH}             ${LOG_PATH}/testline_preparation/syslogs/
    Run Keyword And Ignore Error  Remove Directory         ${LOG_PATH}/testline_preparation  recursive=${TRUE}
    ${build_fixed}=             Fix Branch                 ${sw}
    Set Global Variable         ${BUILD}                   ${build_fixed}
    ${branch}=                  Get Branch                 ${sw}
    Set Global Variable         ${BRANCH}                  ${branch}
    ${compatible_enb_build}=    Find Compatible Build      ${BRANCH}   ${BUILD}
    Set Global Variable         ${COMPATIBLE_ENB_BUILD}    ${compatible_enb_build}
    ${enb_branch}=              Get Branch                 ${COMPATIBLE_ENB_BUILD}
    ${branch_scf}  ${scf_enb}=  Get Scf Path               ${BRANCH}  ${enb_branch}
    Set Global Variable         ${BRANCH_SCF}              ${branch_scf}
    Set Global Variable         ${SCF_ENB}                 ${scf_enb}
    [Teardown]  admin.Teardown  connection=${admin_alias}

Check Software Version
    [Arguments]  ${admin_alias}
    ${sw}=  admin.Get Sw Version  connection=${admin_alias}
    Should Not Be Empty  ${sw}
    RETURN  ${sw}

Load Scf
    [Arguments]  ${connection_alias}
    ${main_bts_id}=  Get Main Bts Id  ${BRANCH_SCF}
    admin.Perform Commissioning  bts_id=${main_bts_id}  scf_file=${BRANCH_SCF}  timeout=600  connection=${connection_alias}
    Sleep  300s  reason=wait for BTS commissioning

Prepare logging on SMOD
    [Documentation]    This keyword is to set CP debug log on GNB_ASIK with the cmd
    ...     echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ${smod}=  SMOD Connection
    ${cmd_open_cp_debug}    Set Variable    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    SSH.Execute  command=${cmd_open_cp_debug}   connection=${smod}

Upload SW to RMODs
    [Arguments]  ${connection_alias}
    ${sw}=  Wait Until Keyword Succeeds  10x  60s  Check Software Version  ${connection_alias}
    Wait Until Keyword Succeeds  5x     120s  Update Software For Rmods  software=${sw}  connection=${connection_alias}
    Sleep  30s  reason=wait for RMOD's restart trigger
    Wait Until Keyword Succeeds  900  10  Check Rmod States  After Update  ${connection_alias}
    ${alarms}=  admin.Get Active Alarms
    ${incompatible_sw_detected}=  Check Alarms for Incompatible Sw On Rmod  ${alarms}
    Should Be Equal  ${incompatible_sw_detected}   ${False}

Wait For NSA Configuration To Get Up
    [Arguments]  ${admin_alias}
    Wait Until Keyword Succeeds  900  20  testline_preparation.Verify X2 Link Is Available  ${admin_alias}

Check Build On Neighbour Bts
    [Arguments]  ${expected_build}  ${connection}
    ${sw_version}=  Wait Until Keyword Succeeds  10x  60s  Check Software Version  ${connection}
    ${update_needed}=  Check If Update Is Needed  ${sw_version}  ${expected_build}
    Should Not Be True  ${update_needed}

Prepare Swconfig Without Reset
    [Arguments]  @{custom_sw_flags}
    ${smod_alias}=  SMOD Connection
    Add Flags To Swconfig  ${custom_sw_flags}  ${LOGPATH}
    ssh.Upload File    local_path=${LOGPATH}/swconfig.txt    remote_path=/ffs/run/swconfig.txt  connection=${smod_alias}
    ssh.Disconnect     connection=${smod_alias}

SMOD Connection
    [Arguments]   ${alias}=SMOD
    ssh.Connect To   hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...              username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...              password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...              alias=${alias}
    ssh.Force Reconnect   connection=${alias}
    RETURN      ${alias}
