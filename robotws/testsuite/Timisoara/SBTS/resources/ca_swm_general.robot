*** Settings ***
Documentation     [PURPOSE] SWM General keywords from HZ
...               CA-SWM/COMPA    OWNER-jacek.mnich@nokia.com  AUTHOR-jacek.mnich@nokia.com
Library                 Collections
Library                 ute_admin_infomodel
Library                 DateTime
Library                 OperatingSystem
Library                 String
Library                 ../resources/lib/extract.py
Library                 XML  use_lxml=${TRUE}
Resource                hran_frame_sbts.robot
Resource                hran_infomodel.robot
Resource                hran_admin.robot
Resource                hran_general.robot
Resource                ca_swm_rescue_console.robot


*** Keywords ***
Log to console with time
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${message}: <description>
    [Arguments]  ${message}
    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  ${time[0]}  ${time[1]}  ${time[2]}
    Log  [${time_now}] | ${message}  console=${TRUE}

Log Step Header
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${message}: <description>
    [Arguments]  ${message}
    Log  ${\n}==========================================================================================  console=${TRUE}
    Log  ${message}  console=${TRUE}
    Log  ==========================================================================================  console=${TRUE}

Log Important Message
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${message}: <description>
    ...        ${level}: <description>
    [Arguments]  ${message}  ${level}=INFO
    ${frame_len}  Get length  ${message}
    ${frame}  Evaluate  str('+')*${frame_len}
    Log  ${\n}${\n}${frame}${\n}${\n}${message}${\n}${\n}${frame}${\n}${\n}  console=${TRUE}  level=${level}

Check SOAM Active Alarms
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${critical_alarms_severity}: <description>
    ...        ${ignored_fault}: <description>
    ...        ${expected_fault}: <description>
    ...        ${notifier}: <description>
    [Arguments]  ${critical_alarms_severity}=Major|Critical  ${ignored_fault}=None  ${expected_fault}=None  ${notifier}=.*
    Log  ------------------------------------------------------------------------------------------  console=${TRUE}
    ${expected_alarms}=     Create Dictionary  faultId=${expected_fault}  notifier=${notifier}
    ${expected_patterns}=   Create List        ${expected_alarms}
    ${critical_alarms}=     Create Dictionary  severity=${critical_alarms_severity}  faultId=^((?!${ignored_fault}).)*$
    ${critical_patterns}=   Create List        ${critical_alarms}
    ${ignored_alarms}=      Create Dictionary  faultId=${ignored_fault}
    ${ignored_patterns}=    Create List        ${ignored_alarms}

    ${alarms_status}  ${alarms_return}=  Run Keyword If  '${expected_fault}'!='None'  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms
    ...  expected_patterns=${expected_patterns}  critical_patterns=${critical_patterns}
    ...  ignored_patterns=${ignored_patterns}
    ...  ELSE  Run Keyword And Ignore Error  Admin Check Active Alarms  critical_patterns=${critical_patterns}
    ...  ignored_patterns=${ignored_patterns}
    Run keyword if   '${alarms_status}'=='FAIL'  Fail
    ...  Failed at expected alarms:${expected_alarms} critical alarms: ${critical_alarms}
    ...  ignored alarms:${ignored_alarms}
    Run keyword if    ${alarms_return}           Set Test Restriction  Minor alarm found.

Check SBTS SOAM cells and modules
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${gsm_states}: <description>
    ...        ${wcdma_states}: <description>
    ...        ${lte_states}: <description>
    ...        ${nr_states}: <description>
    ...        ${smod_states_local}: <description>
    ...        ${rmod_states_local}: <description>
    [Arguments]
    ...  ${gsm_states}=${gsm_states_verification}
    ...  ${wcdma_states}=operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active
    ...  ${lte_states}=administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked
    ...  ${nr_states}=administrativeState=Unlocked, operationalState=${_Enabled}, blockingState=Unblocked
    ...  ${smod_states_local}=administrativeState=${_Unlocked}, operationalState=${_Enabled}
    ...  ${rmod_states_local}=administrativeState=${_Unlocked}, operationalState=${_Enabled}
    Log  ------------------------------------------------------------------------------------------  console=${TRUE}
    ${gsm_cells_on}    Verify cells    GSM    expected_states=${gsm_states}         scf_check=${FALSE}
    ${wcdma_cells_on}  Verify cells    WCDMA  expected_states=${wcdma_states}       scf_check=${FALSE}
    ${lte_cells_on}    Verify cells    LTE    expected_states=${lte_states}         scf_check=${FALSE}
    ${NR_cells_on}=    Verify cells    NR    expected_states=${nr_states}         scf_check=${FALSE}
    ${smods_on}        Verify modules  SMOD   expected_states=${smod_states_local}  scf_check=${FALSE}
    ${rmods_cells_on}  Verify modules  RMOD   expected_states=${rmod_states_local}  scf_check=${FALSE}
    Set Test Variable     ${status_temp}    ${gsm_cells_on} and ${wcdma_cells_on} and ${lte_cells_on}
    Should be true    ${status_temp} and ${NR_cells_on} and ${smods_on} and ${rmods_cells_on}

Get sw package from directory
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${target_sw_dir}: <description>
    ...        ${target_sw_name}: <description>
    ...
    ...    Returns:
    ...        ${target_sw_path}: <description>
    [Arguments]  ${target_sw_dir}  ${target_sw_name}
    ${target_sw_path}  Get SW file for SWDL  ${target_sw_dir}  ${target_sw_name}
    Run Keyword If  '${target_sw_path}'== ${None}  Fail  No proper build in ${target_sw_dir}
    Log  Chosen software package is: ${target_sw_path}  console=${TRUE}
    [Return]  ${target_sw_path}

Check if sw build already present on active partition
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${target_sw_path}: <description>
    [Arguments]  ${target_sw_path}
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    Run Keyword If  '${target_sw_path}'== ${None}   Fail  Target SW dir is empty ${target_sw_dir}
    ${sw_release_name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${target_sw_path}
    Log  SW Release Name: ${sw_release_name}  console=${TRUE}
    ${sw_number}  Should match regexp  ${sw_release_name}  [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    ${active_sw_number}  Should match regexp  ${software_info['Active SW version']}  [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    Should not be equal  '${active_sw_number}'  '${sw_number}'

Check if sw build already present on passive partition
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${target_sw_path}: <description>
    [Arguments]  ${target_sw_path}
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    Run Keyword If  '${target_sw_path}'== ${None}   Fail  Target SW dir is empty ${target_sw_dir}
    ${sw_release_name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${target_sw_path}
    Log  SW Release Name: ${sw_release_name}  console=${TRUE}
    ${sw_number}  Should match regexp  ${sw_release_name}  [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    ${passive_sw_number}  Should match regexp  ${software_info['Passive SW version']}
    ...   [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    Should not be equal  '${passive_sw_number}'  '${sw_number}'

Recovery power hardware
    [Documentation]    Short description.
    Log   Power reset all HW  console=${TRUE}
    Power Off BTS
    Power On BTS
    Log   Check If ${SMOD1['TRS_IP']} Is Stable  console=${TRUE}
    ${ping_status_after_pr}=  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=300
    ...  timeout=1200
    Run keyword if    not ${ping_status_after_pr}  FAIL  BTS is not stable after recovery power reset ${SOFTWARE_PATTERN}.

Power Off BTS
    [Documentation]    Short description.
    Log  Power off BTS  console=${TRUE}
    FOR  ${distname}  IN  @{INTERFACES}
      Pdu BTS Interface Off  ${distname}
      Log  Interface ${distname} turned off  console=${TRUE}
      Sleep  1
    END

Power On BTS
    [Documentation]    Short description.
    Log  Power on BTS  console=${TRUE}
    FOR  ${distname}  IN  @{INTERFACES}
      Pdu BTS Interface On  ${distname}
      Log  Interface ${distname} turned on  console=${TRUE}
      Sleep  1
    END

Run Local Linux Command
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...        ${expected_return_code}: <description>
    ...
    ...    Returns:
    ...        ${msg[1]}: <description>
    [Arguments]  ${command}  ${expected_return_code}=0
    ${command_status}  ${msg}  Run Keyword And Ignore Error  Run And Return Rc And Output  ${command}
    Run keyword if    not '${msg[0]}'=='${expected_return_code}'  FAIL   ${command} failed
    [Return]  ${msg[1]}

Run Remote Linux Command
    [Documentation]
    ...  Keyword for running linux commands on remote machine
    ...  Before keyword is used setting up connection is mandatory:
    ...  Set Connection Parameters  ip=...   user=...  password=...
    [Arguments]  ${command}  ${expected_return_code}=0
    ${command_status}  ${msg}  Run Keyword And Ignore Error  Run_Command  ${command}
    Run keyword if    not '${msg.return_code}'=='${expected_return_code}'  FAIL   ${command}
    [Return]  ${msg.stdout}

Get variant from siteconf
    [Documentation]
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    [Arguments]  ${siteconf path}
    ${sm_variant}=  Get Elements Texts  ${siteconf path}  .//Cabinet/BTS.Platform
    Run keyword if  '${sm_variant[0]}'=='AirScale'  Set test variable  ${sm_variant}  ASIA
    ...  ELSE
    ...  Set test variable  ${sm_variant}  FSMF

Check if metas versions on passive and active are the same
    [Documentation]
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    ...  KW Check meta version on passive and active partition and return True if metas are the same and False if not
    ...  Should be used before DC fallback from SBTS_SOAM to determine if CONS or INCONS fallback should be performed
    Remove and send new SSH key

    Log  ${\n}Will now check METAs revisions in SW builds on active and passive partition  console=${TRUE}
    Run keyword  Run  mkdir ${TestFiles}/meta
    Set test variable  ${active_sw_meta_path}  ${TestFiles}/meta/meta_active.zip
    Set test variable  ${passive_sw_meta_path}  ${TestFiles}/meta/meta_passive.zip
    ${sm_variant}=  Get SM variant
    Set test variable  ${sm_variant}

    Run keyword if  '${sm_variant[0]}'=='FSMF'  _Copy meta from BTS
    ...  ELSE  _Copy meta from BTS  swpool/OAM/

    extract.Unzip  ${active_sw_meta_path}  ${TestFiles}/meta/meta_active
    extract.Unzip  ${passive_sw_meta_path}  ${TestFiles}/meta/meta_passive
    ${return_meta_active}  Run keyword
    ...  Run  cat ${TestFiles}/meta/meta_active/lte/meta.xml | grep -Po '(?<=revision=\")[0-9]*'
    ${return_meta_passive}
    ...  Run keyword  Run  cat ${TestFiles}/meta/meta_passive/lte/meta.xml | grep -Po '(?<=revision=\")[0-9]*'
    ${return_meta_release_active}  Run keyword
    ...  Run  cat ${TestFiles}/meta/meta_active/lte/meta.xml | grep -Po '(?<=release=\").*?(?=\" )'
    ${return_meta_release_passive}  Run keyword
    ...  Run  cat ${TestFiles}/meta/meta_passive/lte/meta.xml | grep -Po '(?<=release=\").*?(?=\" )'
    Log  METAs:${\n}Active SW meta revision=${return_meta_active}${\n}    console=${TRUE}
    Log   Active SW meta release=${return_meta_release_active}  console=${TRUE}
    Log   Passive SW meta revision=${return_meta_passive}${\n}    console=${TRUE}
    Log   Passive SW meta release=${return_meta_release_passive}  console=${TRUE}
    Run keyword if
    ...  '${return_meta_active}'=='${return_meta_passive}' and
    ...  '${return_meta_release_active}'=='${return_meta_release_passive}'
    ...  Return from keyword  ${TRUE}
    ...  ELSE
    ...  Return from keyword  ${FALSE}

_Copy meta from BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${meta_copy_command}: <description>
    [Arguments]  ${meta_copy_command}=${empty}
    Run keyword  Run  sshpass -p ${SMOD1['PASSWORD']}
    ...  scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/${meta_copy_command}meta_*.zip' '${active_sw_meta_path}'
    Run keyword  Run  sshpass -p ${SMOD1['PASSWORD']}
    ...  scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/stb/${meta_copy_command}meta_*.zip' '${passive_sw_meta_path}'

Check BM release
    [Documentation]
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    ...  KW Check BM meta version on passive and active partition and return True if BM meta are the same and False if not
    ...  Should be used after KW: 'Check if metas versions on passive and active are the same' since it uses the same files
    Log  ${\n}Will now check BM releases in SW builds on active and passive partition  console=${TRUE}
    ${return_bm_active}  Run  cat ${TestFiles}/meta/meta_active/bm/meta.xml | grep -Po '(?<=release=\")[0-9A-Z]*'
    ${return_bm_passive}  Run  cat ${TestFiles}/meta/meta_passive/bm/meta.xml | grep -Po '(?<=release=\")[0-9A-Z]*'
    Log  BM:${\n}Active SW BM release=${return_bm_active}${\n}Passive SW BM release=${return_bm_passive}  console=${TRUE}
    ${is_bm_active_empty}  Run keyword and return status  Should not be empty  ${return_bm_active}
    ...  'release=' in ~/bm/meta.xml is empty on active partition - please check logs
    ${is_bm_passive_empty}  Run keyword and return status  Should not be empty  ${return_bm_passive}
    ...'release=' in ~/bm/meta.xml is empty on passive partition - please check logs
    Run keyword if    not ${is_bm_active_empty} and ${is_bm_passive_empty}  Return from keyword  release_is_empty
    Run keyword if  '${return_bm_active}'=='${return_bm_passive}'  Return from keyword  ${TRUE}
    ...  ELSE
    ...  Return from keyword  ${FALSE}

Check if target FL19 or newer
    [Documentation]
    ...  Verify if sw in ${sw_path} is FL19/TL19 or newer with "Should match regexp" keyword
    ...  Return ${TRUE} if SW is FL19/TL19 or newer else return ${FALSE}
    ...  Fail if SW is not FL.
    ...
    ...  | Parameter        | Man. | Default    | Description                                                        |
    ...  | sw_path          | Yes  | -          | Path to Software package                                           |
    ...
    ...     *AUTHOR*   tomasz.zadworny@nokia.com
    [Arguments]  ${sw_path}
    ${admin_fl}  Set variable  ${FALSE}
    ${sw}  Get TargetBD Node Attribute Value  buildDescriptorId  ${sw_path}
    ${is_fl}=  Run keyword and return status  Should Match Regexp  ${sw}  (?i)[FT]L|SBTS(19[A,B]|2[0-9])
    Run keyword if    not ${is_fl}  Fail  This is not FL SW!
    ${admin_fl}=  Run keyword and return status  Should Match Regexp  ${sw}  (?i)[FT]L(19|2[0-9])|SBTS(19[A,B]|2[0-9])
    [Return]  ${admin_fl}

Check if active FDSW build is supporting Rescue Console
    [Documentation]
    ...  KW verify if active SW is FDSW18SP or newer
    ...  Return ${TRUE} if  >=FDSW18SP else return ${FALSE}
    ...
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    sshLibrary.Open Connection  ${SMOD1['TRS_IP']}
    sshLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${target_bd}  sshLibrary.List Files In Directory  /ffs/run  TargetBD*.xml
    Should not be empty  ${target_bd}  TargetBD not found under /ffs/run!
    ${FDSW_rc}  Run keyword and return status  Should match regexp  ${target_bd[0]}  (FDSW18SP|FDSW18A|FDSW19)

    [Return]  ${FDSW_rc}
    [Teardown]  sshLibrary.Close Connection

Disable ethernet port security via Admin
    [Documentation]
    ...  Disable BTS port security via Admin
    ...  Set test restriction if Port Security is still enabled
    ...
    ...     *PRODUCT*  LTE
    ...     *AUTHOR*   tomasz.zadworny@nokia.com
    [Arguments]  ${alias}=default
    ${disable_status}  Run Keyword And Return Status
    ...  Disable Ethernet Port Security  alias=${alias}
    Run keyword if  ${disable_status}
    ...  Log  Disabling Ethernet Port Security status: ${disable_status}  console=${TRUE}
    ...  ELSE
    ...  Set test restriction  Disabling Ethernet Port Security status: ${disable_status}

Get Active and Passive SW from Infomodel
    [Documentation]
    ...  Return active and passive sw version as a two separate variables
    ...  This TC should be used when BTS is uncommissioned.
    ...
    ...     *PRODUCT*  LTE19 or newer, SBTS
    ...     *AUTHOR*   tomasz.zadworny@nokia.com
    [Arguments]  ${module}=MSM  ${alias}=default
    ${sw_active}  Infomodel Get Active SW Version  module=${module}  alias=${alias}
    ${sw_passive}  Infomodel Get Passive SW Version  module=${module}  alias=${alias}
    Log  ${module} active SW: ${sw_active}  console=${TRUE}
    Log  ${module} passive SW: ${sw_passive}  console=${TRUE}
    [Return]  ${sw_active}  ${sw_passive}

Test setup for Admin
    [Documentation]
    ...  Setup admin and infomodel connection. Set ${admin_started} and ${infomodel_started} test variables.
    ...
    ...     *PRODUCT*  LTE19 or newer, SBTS
    ...     *AUTHOR*   tomasz.zadworny@nokia.com
    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}  ${run_setup_SMOD2}=${TRUE}  ${remote_host}=${None}  ${alias}=default
    Log    Trying to connect to admin with alias '${alias}' (max 5 min)  console=${TRUE}
    ${admin_started}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  15 sec
    ...  taf.sbts.oam.coam.admin.Setup Admin  admin_api_log_dir=${BTS Files}  bts_host=${bts_host}
    ...    remote_host=${remote_host}  alias=${alias}
    Set Test Variable  ${admin_started}
    Run keyword if    not ${admin_started}  Fail  Admin connection did not start
    Log    Connection to admin with alias '${alias}' successfully established!  console=${TRUE}
    ${infomodel_started}  Run keyword and return status  Wait Until Keyword Succeeds  5 min  15 sec
    ...  Connect to Infomodel  bts_host=${bts_host}  remote_host=${remote_host}  alias=${alias}
    Set test variable  ${infomodel_started}
    Run keyword if    not ${infomodel_started}  Fail  Fail. Connection to infomodel can't be established.
    Log  Connection to infomodel with alias '${alias}' successfully established!  console=${TRUE}
    Run keyword if  ${run_setup_SMOD2}  Setup SMOD2    ${admin_started}  ${infomodel_started}   syslog_launch=${TRUE}

Connect to Infomodel
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    ...        ${remote_host}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}  ${remote_host}=${None}  ${alias}=default
    Setup Infomodel  address=${bts_host}  port=443  use_ssl=True  remote_host=${remote_host}
    ...  admin_api_log_dir=${BTS Files}/  alias=${alias}
    Connect Infomodel  alias=${alias}

Start SCF Parser or set restriction
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${parser_tech}: <description>
    [Arguments]  ${parser_tech}=SBTS
    Find SCF file
    Log  SCF which will be used to verify BTS (${COMMISSIONING_PATH})  console=${TRUE}
    ${scf_parser_started}  Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=${parser_tech}
    Set test variable   ${scf_parser_started}
    Run keyword if    not ${scf_parser_started}
    ...  Set test restriction  SCF Parser did not start. RMODs verification is not possible.

Check RMODs states via Admin
    [Documentation]
    ...  Check if RMODs have expected state
    ...
    ...  | Parameter         | Man. | Default    | Description
    ...  | detection_timeout | Yes  | -          | timeout for RM detection
    ...  | scf_check         | No   | ${TRUE}    | Path to Software package
    ...
    ...     *AUTHOR*   tomasz.zadworny@nokia.com
    [Arguments]  ${detection_timeout}  ${scf_check}=${TRUE}
    Log  Check RMODs states after Sw update  console=${TRUE}
    Run keyword If
    ...  ${admin_started} and ${scf_check} and not ${scf_parser_started}  Start SCF Parser or set restriction  LTE
    ${rmods_detected}  Run keyword if  ${scf_parser_started}  Run keyword and return status
    ...  Run keywords  Log  Will now verify that all expected RMODs detected  console=${TRUE}
    ...  AND
    ...  Wait Until Keyword Succeeds  ${detection_timeout}  20 sec  Check if all radio modules are available
    ...  ELSE
    ...  Run keywords  Log  Check if all RMODs have expected states.
    ...  AND
    ...  Verify modules  RMOD  scf_check=${FALSE}
    [Return]  ${rmods_detected}

Check RMODs states via siteconf
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${detection_timeout}: <description>
    ...        ${operational_state_value}: <description>
    ...        ${working_state_value}: <description>
    ...        ${scf_check}: <description>
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${rmods_detected}: <description>
    [Arguments]  ${detection_timeout}  ${operational_state_value}=enabled  ${working_state_value}=working
    ...  ${scf_check}=${TRUE}  ${alias}=MSM
    Log    ${alias}
    Log  Check if all RMODs detected  console=${TRUE}
    Run keyword If
    ...  ${btssm_started} and ${scf_check} and not ${scf_parser_started}  Start SCF Parser or set restriction  LTE
    ${rmods_detected}  Run keyword if  ${scf_parser_started}  Run keyword and return status
    ...  Run keywords  Log  Will now verify that all expected RMODs detected  console=${TRUE}
    ...  AND
    ...  Wait Until Keyword Succeeds  ${detection_timeout}  20 sec  Check via siteconf if all RMs detected
    Log  Check if all RMODs have expected states.  console=${TRUE}
    Check RMODs operational and working states  ${operational_state_value}  ${working_state_value}
    [Return]  ${rmods_detected}

Sw update via Admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_path}: <description>
    ...        ${timeout}: <description>
    [Arguments]  ${sw_path}  ${timeout}=300
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  update Software  sw_package=${sw_path}  should_activate=${TRUE}  timeout=${timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  SW update failed. Reason: ${sw_update_msg}

Sw update via BTSSM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_path}: <description>
    [Arguments]  ${sw_path}
    ${sw_update_logs}=  Perform Swupdate With Activation  ${sw_path}  alias=MSM
    Copy files  ${sw_update_logs[0]}  ${sw_update_logs[-1]}  ${Test Files}/
    Log  Software update logs from SEM CLI has been copied to 'TestFiles' directory  console=${TRUE}

Check FL version
    [Documentation]    Short description.
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Set Connection Parameters  ip=${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ${run_output}  Run Remote Linux Command  ls /ffs/run/ | grep TargetBD
    ${is_fl}=  Run keyword and return status  Should Match Regexp  ${run_output}  (?i)[FT]L|SBTS(19[A,B]|2[0-9])
    Run keyword if    not ${is_fl}  Fail  This is not FL SW!
    ${ADMIN_FL}=
    ...  Run keyword and return status  Should Match Regexp  ${run_output}  (?i)[FT]L(19|2[0-9])|SBTS(19[A,B]|2[0-9])
    Set test variable  ${ADMIN_FL}

Ping check after SWM operation
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ping_loss_timeout}: <description>
    ...        ${ping_regain_timeout}: <description>
    ...        ${stability_min_up}: <description>
    ...        ${stability_max_down}: <description>
    ...        ${ping_address}: <description>
    [Arguments]  ${ping_loss_timeout}=300  ${ping_regain_timeout}=300  ${stability_min_up}=300  ${stability_max_down}=100
    ...          ${ping_address}=${SMOD1['TRS_IP']}
    ${ping_stability_timeout}  Evaluate  ${stability_min_up}+${stability_max_down}+${stability_max_down}
    Log  Waiting for target to be not reachable...  console=${TRUE}
    ${ping_loss_status}  Run keyword and return status  Wait for target to be not reachable  hostname=${ping_address}
    ...  timeout=${ping_loss_timeout}
    Run keyword if  ${ping_loss_status}==${FALSE}  Set test failed  BTS RESET DID NOT OCCUR or was not caught by KW
    ...  ELSE
    ...  Log  BTS is resetting  console=${TRUE}
    Log  Waiting for target to be reachable...  console=${TRUE}
    ${ping_regain_status}  Run keyword and return status  Wait for target to be reachable  hostname=${ping_address}
    ...  timeout=${ping_regain_timeout}
    Run keyword if  ${ping_regain_status}==${FALSE}  Set test failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting ${stability_min_up}s for stable ping...  console=${TRUE}
    ${ping_stable_status}  Run keyword and return status  Check If Target Is Stable
    ...  ${ping_address}  min_uptime=${stability_min_up}
    ...  max_downtime=${stability_max_down}  timeout=${ping_stability_timeout}
    Run keyword if  ${ping_stable_status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for ${stability_min_up}seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}

Setup SSH keys on extension
    [Documentation]
    ...  Keyword for resetting ssh keys on extension VM
    ...  Before keyword is used setting up connection is mandatory:
    ...  Set Connection Parameters  ip=...   user=...  password=...
    [Arguments]  ${esm_ip}
    Log  Setup SSH keys on extension  console=${TRUE}
    Log  Remove SSH key  console=${TRUE}
    Run Remote Linux Command  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R ${esm_ip}
    Log  Send new SSH key  console=${TRUE}
    Run Remote Linux Command
    ...  sshpass -p ${SMOD1['PASSWORD']} ssh-copy-id -i ~/.ssh/${SMOD1['USERNAME']}/id_rsa.pub
    ...  ${SMOD1['USERNAME']}@${esm_ip}

Remove FCT elements from TargetBD
    [Documentation]
    ...  Keyword for removing FCT elements from XML files with given atributes
    ...  KW will change XML file from given location and save it to given location
    ...
    ...  | Parameter        | Man. | Default | Description                                               |
    ...  |------------------|------|---------|-----------------------------------------------------------|
    ...  | xml_path         | Yes  | -       | absolute path to TargetBD*.xml file on VM                 |
    ...  | xml_changed_path | Yes  | -       | absolute path for saving changed TargetBD*.xml file on VM |
    ...
    ...  *AUTHOR*   wojciech.sikora@nokia.com
    ...
    [Arguments]  ${xml_path}  ${xml_changed_path}  ${hw_variant}
    ${parsed_xml}=  Parse XML  ${xml_path}
    ${xpath_combine}=     Set Variable      .//buildElement[@targetPath="/rom/swpool/LFS/boot/"
    ${xpath_combine_1}=     Set Variable     @targetPath="/rom/devicecfg/boot/"][contains(@name, "FCT-")]
    ${changed_xml}  Run keyword if  '${hw_variant}'=='FSMF'
    ...  Remove Elements  ${parsed_xml}  xpath=.//buildElement[@targetPath="/rom/boot/"][contains(@name, "FCT-")]
    ...  ELSE
    ...  Remove Elements  ${parsed_xml}   xpath=${xpath_combine} or ${xpath_combine_1}
    Save XML  ${changed_xml}  ${xml_changed_path}

Setup Second Admin Thread
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${update_interval}: <description>
    [Arguments]  ${update_interval}=1000
    Log    Connecting to admin with second alias (max 5 min)  console=${TRUE}
    ${second_admin_started}  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  15 sec
    ...  taf.sbts.oam.coam.admin.Setup Admin
    ...    admin_api_log_dir=${BTS Files}  bts_host=${SMOD1['TRS_IP']}
    ...  bts_port=443  alias="second"  update_interval=${update_interval}
    Run keyword if    not ${second_admin_started}  Fail  Admin connection did not start
    Log  Connection to admin successfully established!  level=INFO  console=${TRUE}
    Set test variable  ${SECOND_ADMIN_STARTED}  ${second_admin_started}

Check For Faults
    [Documentation]
    ...  AUTHOR-jacek.mnich@nokia.com
    [Arguments]  ${alarm_pattern_id}  ${fault_pattern_id}
    Log  Checking for fault with id:${fault_pattern_id} and alarm:${alarm_pattern_id}.  console=${TRUE}
    @{alarms}  Evaluate  [['${alarm_pattern_id}', '${fault_pattern_id}']]
    ${alarm_check_status}  Run Keyword And Return Status  BTSSM Check Active Alarms  critical_patterns=@{alarms}
    ...  alias=MSM
    Log  Alarm active: not ${alarm_check_status}.  console=${TRUE}
    Return From Keyword If  ${alarm_check_status}  ${FALSE}
    [Return]  ${TRUE}

Check For Faults for LTE
    [Documentation]
    ...  AUTHOR-jacek.mnich@nokia.com
    [Arguments]  ${alarm_pattern_id}  ${fault_pattern_id}
    Log  Checking for fault with id:${fault_pattern_id} and alarm:${alarm_pattern_id}  console=${TRUE}
    ${alarm_dict}  Run keyword if  ${ADMIN_FL}  Create Dictionary  faultId=${fault_pattern_id}
    @{alarms}  Run keyword if  ${ADMIN_FL}  Create List  ${alarm_dict}
    ...  ELSE  Evaluate  [['${alarm_pattern_id}', '${fault_pattern_id}']]
    ${alarm_check_status}  Run keyword if  ${ADMIN_FL}
    ...  Run Keyword And Return Status  Admin Check Active Alarms  critical_patterns=@{alarms}
    ...  ELSE  Run Keyword And Return Status  BTSSM Check Active Alarms  critical_patterns=@{alarms}  alias=MSM
    ${alarm_status}  Set variable if  ${alarm_check_status}  ${FALSE}  ${TRUE}
    Log  Alarm active: ${alarm_status}  console=${TRUE}
    [Return]  ${alarm_status}

Perform IPSec certificates installation using BTSSM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cert_path}: <description>
    ...        ${timeout}: <description>
    [Arguments]  ${cert_path}  ${timeout}
    Log  IPSec certificates will be installed now  console=${TRUE}
    ${cert_install_msg}  ute_btssm.Add certificate  certificate_file=${cert_path}
    ...  certificate_password=Cwirhau  timeout=${timeout}  alias=MSM
    Log  Certificates installation status: ${cert_install_msg}  console=${TRUE}
    Log  All certificates installed. Wait ${timeout} for clear state  console=${TRUE}
    Sleep  ${timeout}  Wait for clear state after certificates installation

Yaft lock check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${msm_ip}: <description>
    ...
    ...    Returns:
    ...        ${yaft_lock_status}: <description>
    [Arguments]  ${msm_ip}=${SMOD1['TRS_IP']}
    ${yaft_lock_status}  Check if directory exists  ${msm_ip}  /tmp/YAFT.lock
    Log  YAFT.lock directory exists: ${yaft_lock_status}  console=${TRUE}
    [Return]  ${yaft_lock_status}

Yaft lock remove
    [Documentation]    Short description.
    Set test restriction  YAFT.lock was present at the beggining of the test
    Run keyword and ignore error
    ...  Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    Run remote Linux Command  rm -r /tmp/YAFT.lock
    Log  YAFT.lock removing...  console=${TRUE}
    Yaft lock check

Check if all radio modules are available
    [Documentation]    Short description.
    ${rmods}  taf.sbts.oam.coam.admin.Get parameters for all  RMOD
    FOR  ${rmod}  IN  @{rmods}
        ${is_availabilityStatus}  Run keyword and return status
        ...  Dictionary should contain key  ${rmod}  availabilityStatus
        Continue for loop if  not ${is_availabilityStatus}
        ${is_not_installed}  Run keyword and return status
        ...  Should match regexp  ${rmod["availabilityStatus"]}  (?i)not.?installed
        Run keyword if  ${is_not_installed}  Fail  At least one RMOD is not available!
    END
    ${scf_rmods}            Get Radios
    ${scf_count_rmods}      Get length  ${scf_rmods}
    ${runtime_rmods}        taf.sbts.oam.coam.admin.Get ids for all  RMOD
    ${final_status}         Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run keyword if    not ${final_status}  Fail  Not all radio modules are available

Get active and passive partitions ids
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${active_partition_id}: <description>
    ...        ${passive_partition_id}: <description>
    Set Connection Parameters  ${SMOD1['TRS_IP']}
    ${command_status}  ${msg}  Run Keyword And Ignore Error  Run Command  uboot_env get active_partition
    ${active_partition_id}  Should match regexp  ${msg.stdout}  (?<=active_partition=)[1-2]*
    ${passive_partition_id}  Run keyword if  "${active_partition_id}"=="1"  Set variable  2  ELSE  Set variable  1
    [Return]  ${active_partition_id}  ${passive_partition_id}

Checking MNL_R status
    [Documentation]    Short description.
    Log to console with time  Waiting 5 min for MNL_R object
    ${MNL_R_status}  Run keyword and return status  Wait until keyword succeeds  5 min  5 sec
    ...  ute_admin_infomodel.Query Infomodel  check /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNL_R-*
    Run keyword if  ${MNL_R_status}  Run keywords
    ...  Log  MNL_R exist, now will check SW Version  console=${TRUE}
    ...  AND
    ...  Sleep  5
    ...  ELSE
    ...  Set Test Failed  MNL_R doesn't exist. SW check will be not possible  fail_fast=${TRUE}
