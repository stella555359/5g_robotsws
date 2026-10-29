*** Settings ***
Documentation  This suite contains KWs used by CIT and COMPA TCs

Library  XML  use_lxml=true
Library  taf.fdsw.rc
Library  taf.rnc.oms.nwi3
Library  ute_admin_infomodel
Library  ute_async
Library  hran_compa
Library  hran_radio
Library  taf.rfrl.common_resources.python.reset_bts_configuration  WITH NAME  rfrl_rc
Resource  ca_PM_general.robot
Resource  sbts_pdu.robot
Resource  ca_SBTS_general.robot


*** Variables ***
${STATES_ONAIR_LG}  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}
${STATES_ONAIR_WCDMA}  blockingState=${UNBLOCKED}, operationalState=${ENABLED}
${STATES_ONAIR_TRX}  [administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}]
${STATES_ON_BLOCK_TRX}  [administrativeState=${UNLOCKED}, blockingState=${BLOCKED}, operationalState=${DISABLED}]
${STATES_ON_BLOCK_WCDMA}  blockingState=${BLOCKED}, operationalState=${DISABLED}
${STATES_ON_LOCK_LG}  administrativeState=${LOCKED}, blockingState=${UNBLOCKED}, operationalState=${DISABLED}
${STATES_ONAIR_RMOD}  administrativeState=${UNLOCKED}, operationalState=${ENABLED}
${STATES_ON_LOCK_LNMME}  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${DISABLED}
${DEGRADED_CELL_REGEX}  availabilityStatus=${DEGRADED}
${DEGRADED_TRX_REGEX}  [availabilityStatus=${DEGRADED}]
${GNCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked", usageState=regex"(?i)Active"
${WNCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", usageState=regex"(?i)Active"
${LNCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
${NRCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
${DEGRADED_CELL_REGEX_2}  availabilityStatus(.*)[Dd]egraded
${YAFT_LINK}  gerrit.ext.net.nokia.com/gerrit/MN/RPSW/LFS/build/yaft
${BUILDSHARE_LINK}  /media/BuildShareTimi01


*** Keywords ***
Assert All Cells Are In Expected State
    [Documentation]  This keyword check if all cells are in expected state.
    [Arguments]  ${check_gsm}=${TRUE}  ${check_wcdma}=${TRUE}  ${check_lte}=${TRUE}  ${check_nr}=${TRUE}

    ${cells_gsm_onair}  Run Keyword If  ${check_gsm}
    ...  Verify GSM Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${cells_wcdma_onair}  Run Keyword If  ${check_wcdma}
    ...  Verify WCDMA Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${cells_lte_onair}  Run Keyword If  ${check_lte}
    ...  Verify LTE Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${cells_nr_onair}  Run Keyword If  ${check_nr}
    ...  Verify NR Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    Run Keyword If  ${cells_gsm_onair} and ${cells_wcdma_onair} and ${cells_lte_onair} and ${cells_nr_onair}
    ...  Log  All cells are in expected states!  console=true
    ...  ELSE
    ...  Fail  At least one cell indicates a faulty state!


Check If Admin CLI Feature Check Is Enabled
    [Documentation]  This keyword check if Admin CLI feature is enabled if no, this keyword enable this feature.
    ...  Feature is enabled via set to true parameter actCli under FEATCADM.
    ...  Check If Admin CLI Feature Check Is Enabled  True
    [Arguments]  ${skip_parameter_relation_errors}=False

    ${act_cli}  Infomodel Get Objects Parameter  //MNL_A-*/MNLENT_A-*/FEATCADM_A-*  actCli  allow_negative_result=true
    Run Keyword If  ${act_cli}[0]
    ...  Log  Parameter actCli is set as ${act_cli}[0]  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Log  Setting parameter actCli to "True"  console=true
    ...  AND
    ...  _Change ActCli To True  ${skip_parameter_relation_errors}


_Change ActCli To True
    [Documentation]  This keyword change actCli parameter to be true.
    [Arguments]  ${skip_parameter_relation_errors}

    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actCli  update  true
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}


CLI Send Request And Return Status And Error Code
    [Documentation]  Send command via Admin CLI, and rerturn request status and error code.
    ...  **Input Parameters:**
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                                         |
    ...  +===============================+======+=====================================================================+
    ...  | cli_message                   | Yes  | Admin CLI Command                                                   |
    ...  | output_file                   | No   | File path to redirect response to                                   |
    ...  | return_value                  | No   | Return only value of given key                                      |
    ...  | input_file                    | No   | File path with input data                                           |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    [Arguments]  ${cli_message}  ${output_file}=${None}  ${return_value}=${None}  ${input_file}=${None}

    Log  Sending command via Admin CLI...  console=true
    ${response}  Send Admin CLI Request  ${cli_message}  output_file=${output_file}  return_value=${return_value}  input_file=${input_file}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode

    [Return]  ${request_status}  ${error_code}


Verify Cli Response Error
    [Documentation]
    ...  Check if output file is right json format and check response error
    ...  This keyword check if Admin CLI feature is right json format.
    ...  and verify error codes in json response
    ...  KW sets test variable  ${CLI_ERROR_CODE}
    ...  Verify if output is right json format  ${cli_file_content}
    [Arguments]  ${cli_file_content}

    ${cli_file_content}  Last Root JSON Part  ${cli_file_content}
    &{cli_error_dict}  Create Dictionary  1=Miscellaneous problems  2=Invalid operation  3=Invalid parameters  4=Site unreachable  5=Site reserved
    ...  6=Login failed  7=Unexpected error  8=Timeout  9=License not available  69=Operation Rejected  140=Failed to generate SFP information

    Should Not Be Empty  ${cli_file_content}  CLI SFP output file is empty

    ${json_content}  Evaluate  json.loads("""${cli_file_content}""")  json
    ${error_num}  Convert To String  ${json_content}[errorCode]
    Set Test Variable  ${CLI_ERROR_CODE}  ${json_content}[errorCode]
    Run Keyword If  ${json_content}[errorCode]!=0
    ...  Run Keywords
    ...  Dictionary Should Contain Key  ${cli_error_dict}  ${error_num}  CLI request fail with unknown error
    ...  AND
    ...  Fail  CLI request fail with error: &{cli_error_dict}[${error_num}]


Last Root JSON Part
    [Documentation]
    ...  If JSON contine more then one root part return last part
    ...  This keyword check if Admin CLI feature is right json format.
    ...  and verify error codes in json response
    ...  ${cli_file_content}  Last Root JSON Part  ${cli_file_content}
    [Arguments]  ${cli_file_content}

    Should Not Be Empty  ${cli_file_content}  CLI SFP output file is empty
    ${is_more_then_one_root}  Evaluate  str.find("""${cli_file_content}""", '}\\n{')  string
    ${cli_response}  Fetch From Right  ${cli_file_content}  }\n{
    ${cli_response_after_correction}  Catenate  {  ${cli_response}
    Run Keyword If  ${is_more_then_one_root}>0
    ...  Set Test Variable  ${NEW}  ${cli_response_after_correction}
    Run Keyword If  ${is_more_then_one_root}==-1
    ...  Set Test Variable  ${NEW}  ${cli_file_content}

    [Return]  ${NEW}


Log To Console With Time
    [Documentation]  This keyword logs a specific message with time.
    [Arguments]  ${message}

    @{time}  Get Time  hour min sec  NOW
    ${time_now}  Catenate  SEPARATOR=:  ${time}[0]  ${time}[1]  ${time}[2]
    Log  [${time_now}] | ${message}  console=true


Log Important Message
    [Documentation]  This keyword logs a specific message with a specific log level.
    [Arguments]  ${message}  ${level}=INFO

    ${frame_len}  Get Length  ${message}
    ${frame}  Evaluate  str('+')*${frame_len}
    Log  ${\n}${\n}${frame}${\n}${\n}${message}${\n}${\n}${frame}${\n}${\n}  level=${level}


Recovery Power Hardware
    [Documentation]  This keyword perform power reset for all hardware.

    Log  Power reset all HW  console=true
    Power Off BTS
    Power On BTS
    Log  Check If ${SMOD1['TRS_IP']} Is Stable  console=true
    ${ping_status_after_pr}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=300  timeout=1200
    Run Keyword If  ${ping_status_after_pr} != ${TRUE}
    ...  Fail  BTS is not stable after recovery power reset ${SOFTWARE_PATTERN}.


Power Off BTS
    [Documentation]  This keyword perform power off for BTS.

    Log  Power off BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface Off  ${distname}
        Log  Interface ${distname} turned off  console=true
        Sleep  1
    END


Power On BTS
    [Documentation]  This keyword perform power on for BTS.

    Log  Power on BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface On  ${distname}
        Log  Interface ${distname} turned on  console=true
        Sleep  1
    END


Run Local Linux Command
    [Documentation]  This keyword run and return output for a specific command with a specific error code.
    [Arguments]  ${command}  ${expected_return_code}=0

    ${command_status}  ${msg}  Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  ${command}
    Run Keyword If  '${msg}[0]'!='${expected_return_code}'
    ...  Fail  ${command} failed

    [Return]  ${msg}[1]


Run Remote Linux Command
    [Documentation]
    ...  Keyword for running linux commands on remote machine
    ...  Before keyword is used setting up connection is mandatory:
    ...  ssh.Connect to  hostname=...  username=...  password=...
    [Arguments]  ${command}  ${expected_return_code}=0

    ${command_status}  ${output}  Run Keyword And Ignore Error
    ...  ssh.Execute  ${command}
    Assert Exit Status  ${expected_return_code}  msg=${command} | failed with ${output}.

    [Return]  ${output}


Check If Metas Versions On Passive And Active Are The Same
    [Documentation]
    ...  KW Check meta version on passive and active partition and return True if metas are the same and False if not
    ...  Should be used before DC fallback from SBTS_SOAM to determine if CONS or INCONS fallback should be performed

    Remove And Send New SSH Key
    Log  ${\n}Will now check METAs revisions in SW builds on active and passive partition  console=true
    Run Keyword
    ...  Run  mkdir ${TEST_FILES}/meta
    Set Test Variable  ${ACTIVE_SW_META_PATH}  ${TEST_FILES}/meta/meta_active.zip
    Set Test Variable  ${PASSIVE_SW_META_PATH}  ${TEST_FILES}/meta/meta_passive.zip
    ${sm_variant}  Get SM Variant
    Set Test Variable  ${SM_VARIANT}
    Run Keyword If  '${SM_VARIANT}[0]'=='FSMF'
    ...  _Copy Meta From BTS
    ...  ELSE
    ...  _Copy Meta From BTS  swpool/OAM/
    extract.Unzip  ${ACTIVE_SW_META_PATH}  ${TEST_FILES}/meta/meta_active
    extract.Unzip  ${PASSIVE_SW_META_PATH}  ${TEST_FILES}/meta/meta_passive
    ${return_meta_active}  Run Keyword
    ...  Run  cat ${TEST_FILES}/meta/meta_active/lte/meta.xml | grep -Po '(?<=revision=\")[0-9]*'
    ${return_meta_passive}  Run Keyword
    ...  Run  cat ${TEST_FILES}/meta/meta_passive/lte/meta.xml | grep -Po '(?<=revision=\")[0-9]*'
    ${return_meta_release_active}  Run Keyword
    ...  Run  cat ${TEST_FILES}/meta/meta_active/lte/meta.xml | grep -Po '(?<=release=\").*?(?=\" )'
    ${return_meta_release_passive}  Run Keyword
    ...  Run  cat ${TEST_FILES}/meta/meta_passive/lte/meta.xml | grep -Po '(?<=release=\").*?(?=\" )'
    Log  METAs:${\n}Active SW meta revision=${return_meta_active}${\n}Active SW meta release=${return_meta_release_active}  console=true
    Log  Passive SW meta revision=${return_meta_passive}${\n}Passive SW meta release=${return_meta_release_passive}  console=true
    Run Keyword If  '${return_meta_active}'=='${return_meta_passive}' and """${return_meta_release_active}"""=="""${return_meta_release_passive}"""
    ...  Return From Keyword  ${TRUE}
    ...  ELSE
    ...  Return From Keyword  ${FALSE}


_Copy Meta From BTS
    [Documentation]  This keyword copy the meta from BTS.
    [Arguments]  ${meta_copy_command}=${EMPTY}

    ${ffs_run_command}  Catenate  sshpass -p ${SMOD1['PASSWORD']}
    ...  scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/${meta_copy_command}meta_*.zip' '${ACTIVE_SW_META_PATH}'
    ${ffs_stb_command}  Catenate  sshpass -p ${SMOD1['PASSWORD']}
    ...  scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/stb/${meta_copy_command}meta_*.zip' '${PASSIVE_SW_META_PATH}'
    Run Keyword
    ...  Run  ${ffs_run_command}
    Run Keyword
    ...  Run  ${ffs_stb_command}


Check BM Release
    [Documentation]
    ...  KW Check BM meta version on passive and active partition and return True if BM meta are the same and False if not
    ...  Should be used after KW: 'Check if metas versions on passive and active are the same' since it uses the same files

    Log  ${\n}Will now check BM releases in SW builds on active and passive partition  console=true
    ${return_bm_active}  Run  cat ${TEST_FILES}/meta/meta_active/bm/meta.xml | grep -Po '(?<=release=\")[0-9A-Z]*'
    ${return_bm_passive}  Run  cat ${TEST_FILES}/meta/meta_passive/bm/meta.xml | grep -Po '(?<=release=\")[0-9A-Z]*'
    Log  BM:${\n}Active SW BM release=${return_bm_active}${\n}Passive SW BM release=${return_bm_passive}  console=true
    ${is_bm_active_empty}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${return_bm_active}  'release=' in ~/bm/meta.xml is empty on active partition - please check logs
    ${is_bm_passive_empty}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${return_bm_passive}  'release=' in ~/bm/meta.xml is empty on passive partition - please check logs
    Run Keyword If  ${is_bm_active_empty} == ${FALSE} and ${is_bm_passive_empty} == ${FALSE}
    ...  Return From Keyword  release_is_empty
    Run Keyword If  '${return_bm_active}'=='${return_bm_passive}'
    ...  Return From Keyword  ${TRUE}
    ...  ELSE
    ...  Return From Keyword  ${FALSE}


Ping Check After SWM Operation
    [Documentation]  This keyword check ping to be loss and later stable after SWM operation.
    [Arguments]
    ...  ${ping_loss_timeout}=300
    ...  ${ping_regain_timeout}=300
    ...  ${stability_min_up}=300
    ...  ${stability_max_down}=100
    ...  ${ping_address}=${SMOD1['TRS_IP']}

    ${ping_stability_timeout}  Evaluate  ${stability_min_up}+${stability_max_down}+${stability_max_down}
    Log  Waiting for target to be not reachable...  console=true
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${ping_address}  timeout=${ping_loss_timeout}
    Run Keyword If  ${ping_loss_status}==${FALSE}
    ...  Set Test Failed  BTS RESET DID NOT OCCUR or was not caught by KW
    ...  ELSE
    ...  Log  BTS is resetting  console=true
    Log  Waiting for target to be reachable...  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${ping_address}  timeout=${ping_regain_timeout}
    Run Keyword If  ${ping_regain_status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout.
    ...  ELSE
    ...  Log  BTS ping regained  console=true
    Log  Waiting ${stability_min_up}s for stable ping...  console=true
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Check If Target Is Stable  ${ping_address}
    ...  min_uptime=${stability_min_up}
    ...  max_downtime=${stability_max_down}
    ...  timeout=${ping_stability_timeout}
    Run Keyword If  ${ping_stable_status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for ${stability_min_up}seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=true


Setup SSH Keys On Extension
    [Documentation]
    ...  Keyword for resetting ssh keys on extension VM
    ...  Before keyword is used setting up connection is mandatory:
    ...  ssh.Connect to  hostname=...  username=...  password=...
    [Arguments]  ${esm_ip}

    Log  Setup SSH keys on extension  console=true
    Log  Remove SSH key  console=true
    Run Remote Linux Command  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R ${esm_ip}
    Log  Send new SSH key  console=true
    Run Remote Linux Command  sshpass -p ${SMOD1['PASSWORD']} ssh-copy-id -i ~/.ssh/${SMOD1['USERNAME']}/id_rsa.pub ${SMOD1['USERNAME']}@${esm_ip}


Yaft Lock Check
    [Documentation]  This keyword check if yaft.lock file exists.
    [Arguments]  ${msm_ip}=${SMOD1['TRS_IP']}

    Log  \nLog to ${msm_ip} and check if directory /tmp/YAFT.lock exist  console=true
    ssh.Connect To  ${msm_ip}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${yaft_lock_status}  ssh.File Exists  /tmp/YAFT.lock
    ssh.Disconnect
    Log  YAFT.lock directory exists: ${yaft_lock_status}  console=true

    [Return]  ${yaft_lock_status}


Yaft Lock Remove
    [Documentation]  This keyword remove yaft.lock file.

    Set Test Restriction  YAFT.lock was present at the beggining of the test
    Run Keyword And Ignore Error
    ...  Connect To SMOD  ${SMOD1['TRS_IP']}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    Run Remote Linux Command  rm -r /tmp/YAFT.lock
    Log  YAFT.lock removing...  console=true
    Yaft Lock Check


Check If All Radio Modules Are Available
    [Documentation]  This keyword check if all radio modules are available.

    ${rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods}
        ${is_availability_status}  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${rmod}  availabilityStatus
        Continue For Loop If  not ${is_availability_status}
        ${is_not_installed}  Run Keyword And Return Status
        ...  Should Match Regexp  ${rmod["availabilityStatus"]}  (?i)not.?installed
        Run Keyword If  ${is_not_installed}
        ...  Fail  At least one RMOD is not available!
    END
    ${scf_rmods}  hran_file_operations.Get Radios
    ${scf_count_rmods}  Get Length  ${scf_rmods}
    ${runtime_rmods}  Get Ids For All  RMOD
    ${final_status}  Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run Keyword If  ${final_status}
    ...  Log  All radio modules are available!  console=true
    ...  ELSE
    ...  Fail  Not all radio modules are available


Checking MNL_R Status
    [Documentation]  This keyword check MNL_R to exist.

    Log To Console With Time  Waiting 5 min for MNL_R object
    ${mnl_r_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  5 sec
    ...  ute_admin_infomodel.Query Infomodel  check /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNL_R-*
    Run Keyword If  ${mnl_r_status}
    ...  Run Keywords
    ...  Log  MNL_R exist, now will check SW Version  console=true
    ...  AND
    ...  Sleep  5
    ...  ELSE
    ...  Fail  MNL_R doesn't exist. SW check will be not possible


Save BTS SCF ${when} Delta Recommissioning
    [Documentation]  KW saves current commissioning file.
    [Timeout]  15 min

    Log  Save BTS SCF ${when} delta recommissioning  console=True
    Collect SCF  ${TEST_FILES}/SCF_${when}_recommissioning.xml
    Log  SCF has been saved under ${TEST_FILES}/SCF_${when}_recommissioning.xml  console=True
    ${scf_xml}  Parse Xml  ${TEST_FILES}/SCF_${when}_recommissioning.xml

    [Return]  ${scf_xml}


Validate If Delta Is Not Included Into SCF Before Delta Recommissioning
    [Documentation]  This keyword validate if delta is not included into SCF before delta recommissioning.
    [Arguments]  ${delta_json}  ${scf_xml}
    [Timeout]  15 min

    Log  Validate if delta is not included into SCF before delta recommissioning  console=True
    FOR  ${scf_object}  IN  @{delta_json}
        Log  Checking delta object with distName ${scf_object['distName']}  console=True
        Run Keyword And Expect Error  Value inside SCF is not equal value from delta JSON
        ...  Verify Parameters Values In SCF Object  ${scf_xml}  ${scf_object['distName']}  ${scf_object['parameters']}
    END
    Log  All parameters in delta JSON have different values than parameters in SCF  console=True


Verify Parameters Values In SCF Object
    [Documentation]  KW for simple check if parameter from given BTS SCF has proper value in text field.
    [Arguments]  ${scf_xml}  ${object_dist_name}  ${object_parameters}

    FOR  ${parameter}  IN  @{object_parameters}
        Log  Checking ${parameter['parameterName']} parameter value in SCF  console=True
        XML.Element Text Should Be  ${scf_xml}  ${parameter['value']}
        ...  //*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]
        ...  message=Value inside SCF is not equal value from delta JSON
        Log  Parameter ${parameter['parameterName']}=${parameter['value']}
    END


Check If All Cells Are OnAir
    [Documentation]  KW checks if all cells on BTS are onAir.
    ...  Default timeout is set to 10 second
    ...  Check If All Cells Are onAir  timeout=20
    [Arguments]  ${alias}=default  ${timeout}=10

    ${gncel_list}  Get Ids For All  GNCEL  alias=${alias}
    ${wncel_list}  Get Ids For All  WNCEL  alias=${alias}
    ${lncel_list}  Get Ids For All  LNCEL  alias=${alias}
    ${nrcel_list}  Get Ids For All  NRCEL  alias=${alias}
    Run Keyword If  len(${lncel_list})!=0
    ...  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  LTE  ${timeout}  ${alias}
    Run Keyword If  len(${nrcel_list})!=0
    ...  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  NR  ${timeout}  ${alias}
    Run Keyword If  len(${wncel_list})!=0
    ...  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  WCDMA  ${timeout}  ${alias}
    Run Keyword If  len(${gncel_list})!=0
    ...  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  GSM  ${timeout}  ${alias}


Check If Cell Is OnAir
    [Documentation]  KW checks if cell with runtime_id on BTS are onAir.
    ...  Default timeout is set to 10 second
    [Arguments]  ${rat}  ${id}  ${timeout}=10  ${alias}=default

    Run Keyword If  '${rat}'=='GSM'
    ...  Run Keywords
    ...  Assert  GNCEL  ${id}  ${GNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No For Specified Cell  GNCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}
    ...  ELSE IF  '${rat}'=='WCDMA'
    ...  Run Keywords
    ...  Assert  WNCEL  ${id}  ${WNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No For Specified Cell  WNCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}
    ...  ELSE IF  '${rat}'=='LTE'
    ...  Run Keywords
    ...  Assert  LNCEL  ${id}  ${LNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No For Specified Cell  LNCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}
    ...  ELSE IF  '${rat}'=='NR'
    ...  Run Keywords
    ...  Assert  NRCEL  ${id}  ${NRCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No For Specified Cell  NRCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}


Assert No For Specified Cell
    [Documentation]  KW checks if specified cell doesn't contain a parameter with value given by regex.
    ...  KW passes if parameters dict doesn't match regex
    [Arguments]  ${rat}  ${id}  ${regex}  ${alias}

    ${params}  Get Parameters For  ${rat}  ${id}  alias=${alias}
    Should Not Match Regexp  str(${params})  ${regex}


Check If All Cells For RAT Are OnAir
    [Documentation]  KW checks if cells for RAT are onAir.
    ...  Default timeout is set to 10 second
    [Arguments]  ${rat}  ${timeout}=10  ${alias}=default

    Run Keyword If  '${rat}'=='GSM'
    ...  Run Keywords
    ...  Assert Every  GNCEL  ${GNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No  GNCEL  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}
    ...  ELSE IF  '${rat}'=='WCDMA'
    ...  Run Keywords
    ...  Assert Every  WNCEL  ${WNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No  WNCEL  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}
    ...  ELSE IF  '${rat}'=='LTE'
    ...  Run Keywords
    ...  Assert Every  LNCEL  ${LNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No  LNCEL  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}
    ...  ELSE IF  '${rat}'=='NR'
    ...  Run Keywords
    ...  Assert Every  NRCEL  ${NRCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND
    ...  Assert No  NRCEL  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}


Get Cells Mapping By RMOD Id
    [Documentation]
    ...  KW returns all cells for technology deployed on given RMOD.
    ...  KW returns correctly cells deployed on RMOD in chaining configuration, unlike Get Cell Mapping By Module ID
    ...  **Input Parameters:**
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | rat              | Yes  | GSM/WCDMA/LTE/NR                                                 |
    ...  | radio_id         | Yes  | Radio ID from runtime                                            |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  **Example of simple usage:**
    ...  Get Cells Mapping By RMOD Id  rat=NR  radio_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-3
    [Arguments]  ${rat}  ${radio_id}

    ${whole_list}  Get Cell List
    ${rat_cells}  Evaluate  (${whole_list}\['cells']['${rat.lower()}'])
    ${ids_list}  Create List
    FOR  ${rat_cell}  IN  @{rat_cells}
        ${carriers_list}  Evaluate  (${rat_cell}\['carrierList'])
        ${status}  _Carrier List Iterator For Cells Mapping  ${carriers_list}  ${radio_id}
        Continue For Loop If  '${status}'=='False'
        ${cell_id}  Evaluate  (${rat_cell}\['id']['internal'])
        Append To List  ${ids_list}  ${cell_id}
    END
    ${list_of_cell}  Remove Duplicates  ${ids_list}

    [Return]  ${list_of_cell}


_Carrier List Iterator For Cells Mapping
    [Documentation]  This KW return status of radio id matching.
    [Arguments]  ${carrier_list}  ${radio_id}

    FOR  ${carrier}  IN  @{carrier_list}
        ${antenna_line}  Get From Dictionary  ${carrier}  antennaLineId
        ${rmod_id}  Evaluate  (${antenna_line}\['internal'][0:-9])
        ${status}  Set Variable If  '${rmod_id}'=='${radio_id}'  True  False
        Return From Keyword If  '${status}'=='True'  ${status}
    END

    [Return]  ${status}


Perform ActRfChaining Recommissioning
    [Documentation]  This KW perform actRfChaining recommissioning.
    [Arguments]  ${flag}

    ${bts_obj}  Get Parameters For All  BTS
    ${bts_id}  Convert To String  ${bts_obj[0].btsId}
    ${dist_name}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Log To Console  Now will perform parameter recommissioning: actRfChaining--> ${flag}${\n}
    Perform Parameter Recommissioning  ${dist_name}  actRfChaining  update  ${flag}  skip_parameter_relation_errors=true
    Log To Console  Recommissioning was done successful !${\n}


Verify Number Of FaultId 4084
    [Documentation]  This KW verify number of fault id 4084.
    [Arguments]  ${should_be_raised}  ${len_of_rmods_to_check_fault}

    ${found_rmods_with_fault}  Create List
    ${dict_of_alarms}  Admin Check Active Alarms TAF  print_alarms=${FALSE}
    FOR  ${alarm}  IN  @{dict_of_alarms}
        Continue For Loop If  '4084' not in '${alarm['faultId']}'
        ${rmod_with_fault}  Evaluate  '${alarm['configObjectName']}'.split('/')[-1]
        Append To List  ${found_rmods_with_fault}  ${rmod_with_fault}
    END
    ${len_of_found_rmods_with_fault}  Evaluate  len(${found_rmods_with_fault})
    Run Keyword If  ${len_of_found_rmods_with_fault}!=0
    ...  Log To Console  Found ${len_of_found_rmods_with_fault} fault(s) 4084 !${\n}
    ...  ELSE
    ...  Log To Console  No fault 4084 was found !${\n}
    Run Keyword If  '${len_of_rmods_to_check_fault}'=='${len_of_found_rmods_with_fault}' and '${should_be_raised}'=='true'
    ...  Log To Console  Number of Fault ID 4084 is correct, chaining deactivation successful !${\n}
    ...  ELSE IF  '${len_of_rmods_to_check_fault}'=='${len_of_found_rmods_with_fault}' and '${should_be_raised}'=='false'
    ...  Log To Console  Chaining activation successful !${\n}
    ...  ELSE
    ...  Run Keywords
    ...  Fail  Number of Fault ID is incorrect, should be ${len_of_rmods_to_check_fault}, found ${len_of_found_rmods_with_fault}
    ...  AND
    ...  Perform ActRfChaining Recommissioning  true
    Run Keyword If  '${should_be_raised}'=='true'
    ...  Print And Verify RMOD(s) With FaultId And FaultName  ${dict_of_alarms}  ${found_rmods_with_fault}


Print And Verify RMOD(s) With FaultId And FaultName
    [Documentation]  This KW print and verify RMOD(s) with faultId and faultName.
    [Arguments]  ${dict_of_alarms}  ${found_rmods_with_fault}

    Log To Console  Found Fault ID 4084 for the following RMOD:${\n}
    ${count}  Set Variable  ${0}
    FOR  ${alarm}  IN  @{dict_of_alarms}
        Continue For Loop If  '4084' not in '${alarm['faultId']}'
        Log To Console  ${found_rmods_with_fault}[${count}]: Fault ID 4084 --> "${alarm['faultName']}"
        ${count}  Set Variable  ${count+1}
    END
    ${compare_lists}  Evaluate  sorted(${LIST_OF_RMODS_TO_CHECK_FAULT})==sorted(${found_rmods_with_fault})
    Run Keyword If  ${compare_lists}
    ...  Log To Console  ${\n}Fault 4084 is raised on proper RMOD(s) !
    ...  ELSE
    ...  Run Keywords
    ...  Fail  Found incorrect RMOD(s) for which fault ID 4084 should be rasied, but number of fault(s) is correct, Set Test Failed !
    ...  AND
    ...  Perform ActRfChaining Recommissioning  false


Find A Master RMOD In Chain
    [Documentation]  This KW find a master rmod in chain and set as a test variable master distname.
    [Arguments]  ${rmod_name}

    FOR  ${link}  IN  @{SFP_LINKS}
        ${link_ports_condition}  Catenate  (('${rmod_name}' not in '${link['data']['linkPorts']['source']}')
        ...  or (('SMOD' not in '${link['data']['linkPorts']['destination']}')  and ('BBMOD' not in '${link['data']['linkPorts']['destination']}')))
        Continue For Loop If  ${link_ports_condition}
        ${master_rmod_name}  Set Variable  ${link['data']['linkPorts']['source']}
        ${smod_name}  Set Variable  ${link['data']['linkPorts']['destination']}
        ${link_type}  Set Variable  ${link['data']['linkType']}
        ${master_distname}  Evaluate  '${link['source']}'.rsplit('/', 1)[0]
        Append To List  ${MASTER_RMOD_IN_CHAIN}  ${master_rmod_name}
        Append To List  ${SMOD_FOR_MASTER}  ${smod_name}
        Append To List  ${LINKS_TYPE}  ${link_type}
        Append To List  ${MASTER_DISTNAMES}  ${master_distname}
    END
    Set Test Variable  ${MASTER_DISTNAMES}  ${MASTER_DISTNAMES}


Find A Second RMOD In Chain
    [Documentation]  This KW find a second rmod in chain and return it.
    [Arguments]  ${master}

    FOR  ${link}  IN  @{SFP_LINKS}
        Continue For Loop If  '${master}' not in '${link['data']['linkPorts']['destination']}'
        ${rmod_name}  Set Variable  ${link['data']['linkPorts']['source']}
        ${second_rmod_in_chain}  Evaluate  '${rmod_name}'.split('/')[:-1]
    END

    [Return]  ${second_rmod_in_chain}


Find A Next RMOD In Chain
    [Documentation]  This KW find a next rmod in chain.
    [Arguments]  ${list}

    ${rmods_in_configuration}  Get Parameters For All  RMOD
    ${count_of_rmods}  Evaluate  len(${rmods_in_configuration})
    FOR  ${i}  IN RANGE  ${count_of_rmods}
        ${next_rmod_name}  SFP Links Iterator  ${list}[${i}]
        Run Keyword If  '${STATUS_OF_NEXT_RMOD}'=='True'
        ...  Append To List  ${list}  ${next_rmod_name}
        ...  ELSE
        ...  Exit For Loop
    END


SFP Links Iterator
    [Documentation]  SFP Links Iterator.
    [Arguments]  ${previous_rmod_name}

    FOR  ${link}  IN  @{SFP_LINKS}
        Continue For Loop If  '${previous_rmod_name}' not in '${link['data']['linkPorts']['destination']}'
        ${next_rmod_name}  Set Variable  ${link['data']['linkPorts']['source']}
        ${next_rmod_name}  Evaluate  '${next_rmod_name}'.split('/')[:-1]
    END
    ${status_of_next_rmod}  Run Keyword And Return Status
    ...  Variable Should Exist  ${next_rmod_name}
    Set Test Variable  ${STATUS_OF_NEXT_RMOD}  ${status_of_next_rmod}
    Return From Keyword If  ${STATUS_OF_NEXT_RMOD}==True  ${next_rmod_name}[0]


Check If Cells On First RMOD Are OnAir
    [Documentation]  This KW check if cells on first rmod are onAir.
    [Arguments]  ${master_distname}  ${master_name}  ${master_rmod_id}

    ${nrcell}  Get Cells Mapping By RMOD ID  NR  ${master_distname}
    ${lncell}  Get Cells Mapping By RMOD ID  LTE  ${master_distname}
    ${wncell}  Get Cells Mapping By RMOD ID  WCDMA  ${master_distname}
    ${gncell}  Get Cells Mapping By RMOD ID  GSM  ${master_rmod_id}
    ${cells_list}  Evaluate  ${nrcell}+${lncell}+${wncell}+${gncell}
    Log To Console  ${\n}Waiting for onAir status on cells deployed on ${master_name} , please wait !${\n}
    FOR  ${cell}  IN  @{cells_list}
        ${cell_status}  Run Keyword And Return Status
        ...  Run Keyword If  'GNCEL' in '${cell}'
        ...  Wait Until Keyword Succeeds  30x  5s
        ...  Check If Cell Is OnAir  GSM  ${cell}
        ...  ELSE IF  'WNCEL' in '${cell}'
        ...  Wait Until Keyword Succeeds  30x  5s
        ...  Check If Cell Is OnAir  WCDMA  ${cell}
        ...  ELSE IF  'LNCEL' in '${cell}'
        ...  Wait Until Keyword Succeeds  30x  5s
        ...  Check If Cell Is OnAir  LTE  ${cell}
        ...  ELSE IF  'NRCEL' in '${cell}'
        ...  Wait Until Keyword Succeeds  30x  5s
        ...  Check If Cell Is OnAir  NR  ${cell}
        ${cell}  Evaluate  ('${cell}'.split('/')[-1])
        Run Keyword If  ${cell_status}==False
        ...  Run Keywords
        ...  Log To Console  ${cell} is NOT onAir but should be ! parameters restoring !
        ...  AND
        ...  Perform ActRfChaining Recommissioning  true
        ...  AND
        ...  Fail  One of cells doesn't meet conditions after parameters change, Set Test Failed !
        Run Keyword If  ${cell_status}==True
        ...  Log To Console  ${cell} is onAir
    END


Catch First Ping After Reset And Create Timestamp
    [Documentation]
    ...  Keyword checks of ping is succesful and creates test variable ping_regained_time.
    ...  Value of the variable will be ${False} if ping fails and timestamp if it is succesful.
    ...  Keyword also returns ${True} / ${False}, depending on ping outcome.
    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}

    Log  Will now check if bts ping is restored  console=True
    ${ping_regained_check}  ${ping_regained_output}  Run Keyword And Ignore Error
    ...  Wait For Target To Be Reachable  hostname=${bts_host}  timeout=3
    Run Keyword If  '${ping_regained_check}'=='FAIL'
    ...  Run Keywords
    ...  Set Test Variable  ${PING_REGAINED_TIME}  ${False}
    ...  AND
    ...  Return From Keyword  ${False}
    ${ping_regained_time_local}  Get Time
    Run Keyword If  '${PING_REGAINED_TIME}'=='${False}'
    ...  Set Test Variable  ${PING_REGAINED_TIME}  ${ping_regained_time_local}

    [Return]  ${True}


Setup Admin And Create Timestamp
    [Documentation]
    ...  Keyword performs Admin setup. If action possible, test variable 'admin_started' is being set to ${True},
    ...  and 'admin_setup_time' is created with a timestamp value
    ...  Keyword also returns ${True} / ${False}, depending on setup outcome
    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}  ${bts_port}=443

    Log  Trying to connect to admin (max 5 min)  level=INFO  console=true
    ${admin_setup_status}  ${admin_setup_response}  Run Keyword And Ignore Error
    ...  Setup Admin  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=True  admin_api_log_dir=${BTS_FILES}/  timeout=300
    Return From Keyword If  '${admin_setup_status}'=='FAIL'  ${False}
    ${admin_setup_time}  Get Time
    Set Test Variable  ${ADMIN_SETUP_TIME}
    Set Test Variable  ${ADMIN_STARTED}  ${True}

    [Return]  ${True}


BTS Up Check
    [Documentation]
    ...  Keyword checks if BTS is up after reset, where by 'up' it is meant:
    ...   1. Ping is regained
    ...   2. Admin Setup is possible
    ...   3. Stable ping of 360 s is acchieved
    ...   4. admin_infomodel connection is also created, but its failure has no bearing on the keyword result
    ...
    ...   Keyword also returns ${True} / ${False}, depending on the outcome

    ${first_ping_status}  Catch First Ping After Reset And Create Timestamp
    IF  ${first_ping_status} != ${TRUE}  RETURN  ${False}
    ${admin_connection_status}  Setup Admin And Create Timestamp
    IF  ${admin_connection_status} != ${TRUE}  RETURN  ${False}
    Start Infomodel Connection
    ${continous_ping_status}  Stable Ping Check
    IF  ${continous_ping_status} != ${TRUE}  RETURN  ${False}

    RETURN  ${True}
    [Teardown]  Run Keyword If  (${continous_ping_status} != ${TRUE}) or (${admin_connection_status} != ${TRUE})  Teardown admin


Stable Ping Check
    [Documentation]
    ...  Keyword checks if BTS ping is stable.
    ...  Keyword also returns ${True} / ${False}, depending on the outcome.

    Log  Will now check if BTS ping is stable  console=true
    ${ping_stable_check}  Run Keyword And Return Status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=420
    IF  '${ping_stable_check}'=='True'  RETURN  ${True}

    RETURN  ${False}

Start Infomodel Connection
    [Documentation]
    ...  Keyword performs Infomodel setup and connect. If action possible, test variable 'infomodel_started' is being set to ${True}.
    ...  Keyword also returns ${True} / ${False}, depending on setup outcome
    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}

    Log  Trying to connect to infomodel (max 5 min)  level=INFO  console=true
    ${im_setup_status}  ${im_setup_response}  Run Keyword And Ignore Error
    ...  Setup Infomodel  address=${bts_host}  port=443  use_ssl=True  admin_api_log_dir=${BTS_FILES}/  timeout=300
    Return From Keyword If  '${im_setup_status}'=='FAIL'  ${False}
    ${im_connect_status}  ${im_connect_response}  Run Keyword And Ignore Error
    ...  Wait Until Keyword Succeeds  5 min  15 sec
    ...  Connect Infomodel
    Return From Keyword If  '${im_connect_status}'=='FAIL'  ${False}
    Set Test Variable  ${INFOMODEL_STARTED}  ${True}

    [Return]  ${True}


Verify SSH Connection And Enable If Necessary
    [Documentation]
    ...  Verify and enable ssh connection on Master and Slave SMOD

    Log  Verify SSH connection and enable if necessary  console=true
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    SSH Check and Enable If Necessary
    IF  ${SMOD2_EXISTS}
        Setup Hran Compa  ssh_user=${SMOD2['USERNAME']}  ssh_password=${SMOD2['PASSWORD']}
        SSH Check and Enable If Necessary
    ELSE
        Log  SMOD is single core and SSH is enabled only on Master.  console=true
    END


SSH Check and Enable If Necessary
    [Documentation]
    ...  Verify if ssh connection is enabled
    ...  If not, try enable ssh via TRS or Admin
    ...  Test will be blocked if ssh connection will be still disabled

    ${is_ssh_enabled}  Check If SSH Is Enabled
    IF  ${is_ssh_enabled}
        Log  SSH is enabled  console=true
        RETURN
    END
    ${rc_status}  Run Keyword And Return Status  Connect To Rescue Console
    IF  ${rc_status}
        Teardown Rescue Console
        ${is_ssh_enabled}  Enable SSH Via Rescue Console
    ELSE
        ${is_ssh_enabled}  Enable SSH In Independent Execution Context On SBTS SOAM TAF
    END
    IF  ${is_ssh_enabled}
        Log  SSH is enabled  console=true
        RETURN
    END
    ${is_ssh_enabled}  Enable Ssh By Trs
    IF  ${is_ssh_enabled}
        Log  SSH is enabled  console=true
        RETURN
    END
    Set Test Blocked  SSH is not enabled


Install Software Using Yaft
    [Documentation]
    ...  Find in software_directory software matching software_pattern and install using yaft
    ...  Used in test cases COMPA__*_installing_using_YAFT
    ...
    ...  | Parameter            | Man. | Default | Description                                          |
    ...  | software_pattern     | Yes  | -       | Pattern for software, which should be installed.     |
    ...  | software_directory   | Yes  | -       | Directory with software packages                     |
    ...  | swconfig_path        | Yes  | -       | Path to swconfig which should be copied to BTS       |
    ...  | sign_dirs            | No   | None    | Optional directories with files to sign ex."foo|bar" |
    ...
    ...  Keyword is using global variables from env_config files (${SMOD1['USERNAME']}, ${SMOD1['PASSWORD']})
    [Arguments]  ${software_pattern}  ${software_directory}  ${swconfig_path}  ${sign_dirs}=${None}  ${msm_ip}=${SMOD1['TRS_IP']}

    ${yaft_status}  Install Software From Directory Using Yaft  software_pattern=${software_pattern}  ssh_user=${SMOD1['USERNAME']}
    ...  ssh_password=${SMOD1['PASSWORD']}  msm_ip=${msm_ip}  packages_directory=${software_directory}  swconfig_path=${swconfig_path}
    ...  log_directory=${TEST_FILES}  sign_dirs=${sign_dirs}  ignore_fsps=${TRUE}
    Run Keyword If  ${yaft_status}
    ...  Log  Install with yaft ended successfully.  console=true
    ...  ELSE
    ...  Fail  YAFT error. Check log for more information.


Set Tags For Software
    [Documentation]
    ...  Active and passive software will be visible in log file, in tag section.
    ...
    ...  | Parameter            | Man. | Description        |
    ...  | operation_type       | Yes  | Operation type     |
    ...  | active_sw_version    | Yes  | Active software    |
    ...  | passive_sw_version   | Yes  | Passive software   |
    [Arguments]  ${operation_type}  ${active_sw_version}  ${passive_sw_version}

    Set Tags  ${operation_type}_active-${active_sw_version}
    Set Tags  ${operation_type}_passive-${passive_sw_version}


Check If Software Match Software Pattern
    [Documentation]
    ...  Verify sw with given patterns with "Should match regexp" keyword
    ...  Set test failed if active sw does not match sw pattern
    ...
    ...  | Parameter        | Man. | Default    | Description                                                        |
    ...  | sw               | Yes  | -          | Software version                                                   |
    ...  | sw_pattern       | Yes  | -          | Pattern in regex format to verify active_sw                        |
    ...  | set_test_status  | No   | Failed     | If sw does not match pattern, kw 'Set test (var)' will be executed |
    [Arguments]  ${sw}  ${sw_pattern}  ${set_test_status}=Failed

    ${active_status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${sw}  (?i)${sw_pattern}
    Run Keyword If  ${active_status} == ${FALSE}
    ...  Set Test ${set_test_status}  ${sw} doesn't match ${sw_pattern} pattern.
    Log  Software ${sw} match software pattern.  console=true


Software Fallback
    [Documentation]
    ...  Run fallback_command for given sm_variand and reboot on BTS, then wait for target to be not reachable
    ...  Set test failed if reboot will be not perform
    ...
    ...  | Parameter    | Man. | Description                 |
    ...  | sm_variant   | Yes  | System module variant       |
    ...  | reset_method | Yes  | Method for triggering reset |
    [Arguments]  ${sm_variant}  ${reset_method}=process_kill

    Connect To SMOD  ${SMOD1['TRS_IP']}
    Set Reset Loop Counter  sm_variant=${sm_variant}  rlc_number=3
    Run Keyword If  '${reset_method}'=='process_kill'
    ...  Trigger Autonomic Reset By Killing Process  process_name=opt/DEM/DEM$
    ...  ELSE IF  '${reset_method}'=='reset_command'
    ...  Trigger Reset By Command  sm_variant=${sm_variant}
    ...  ELSE
    ...  Set Test Norun  Unknown reset_method:${reset_method} chosen
    Check If SBTS Lost Ping After Reset


Set Reset Loop Counter
    [Documentation]
    ...  Set Reset Loop Counter
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    [Arguments]  ${sm_variant}  ${rlc_number}=3

    ${set_rlc_command}  Run Keyword
    ...  Get Command For Setting Reset Loop Counter  rlc_number=${rlc_number}  sm_variant=${sm_variant}
    ${get_rlc_command}  Run Keyword
    ...  Get Command For Getting Reset Loop Counter  sm_variant=${sm_variant}
    ${rlc_before}  Run Remote Linux Command  ${get_rlc_command}
    Log  Reset loop counter before: ${rlc_before}  console=true
    Log  Setting reset loop counter to ${rlc_number}: ${set_rlc_command}  console=true
    Run Remote Linux Command  ${set_rlc_command}
    ${rlc_after}  Run Remote Linux Command  ${get_rlc_command}
    Log  Reset loop counter after: ${rlc_after}  console=true


Trigger Autonomic Reset By Killing Process
    [Documentation]
    ...  Trigger autonomic reset by killing process
    ...
    ...  | Parameter    | Man. | Description               |
    ...  | process_name | Yes  | Process name to be killed |
    [Arguments]  ${process_name}

    Log  Killing key process: ${process_name} to triger autonomic reset  console=true
    ${processes_matching_pattern}  Run Remote Linux Command  ps aux | grep ${process_name}
    Log  Process to be killed: ${processes_matching_pattern}  console=true
    ${process_id}  Run Remote Linux Command  pgrep -f ${process_name}
    ${process_id}  Strip String  ${process_id}
    Log  Process id: ${process_id}  console=true
    ${process_id}  Run Remote Linux Command  kill -9 ${process_id}
    Run Remote Linux Command  pgrep -f ${process_name}  expected_return_code=1
    Log  Process: ${process_name} killed  console=true


Trigger Reset By Command
    [Documentation]
    ...  Trigger reset by command
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    [Arguments]  ${sm_variant}

    ${reset_command}  Get Reset Command  ${sm_variant}
    Log  Running command: ${reset_command}  console=true
    Run Remote Linux Command  ${reset_command}


Get Reset Command
    [Documentation]
    ...  Return reset command for given system module variant
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    [Arguments]  ${sm_variant}

    Run Keyword If  'FSMF' in '${sm_variant}'
    ...  Return From Keyword  reboot
    ...  ELSE IF  'FSIH' in '${sm_variant}'
    ...  Return From Keyword  reboot
    ...  ELSE IF  'ASIA' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...  ELSE IF  'ASIB' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...  ELSE IF  'ASIAB' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN


Get Command For Setting Reset Loop Counter
    [Documentation]
    ...  Return fallback command for given system module variant
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    [Arguments]  ${rlc_number}  ${sm_variant}

    Run Keyword If  'FSMF' in '${sm_variant}'
    ...  Return From Keyword  uboot_env -r set reset_counter=${rlc_number}
    ...  ELSE IF  'FSIH' in '${sm_variant}'
    ...  Return From Keyword  uboot_env -r set reset_counter=${rlc_number}
    ...  ELSE IF  'ASIA' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF  'ASIB' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF  'ASIAB' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF  'ASIL' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE
    ...  Log  Wrong SM vartiant given  level=ERROR


Get Command For Getting Reset Loop Counter
    [Documentation]
    ...  Return fallback command for given system module variant
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    [Arguments]  ${sm_variant}

    Run Keyword If  'FSMF' in '${sm_variant}'
    ...  Return From Keyword  uboot_env -r get reset_counter
    ...  ELSE IF  'FSIH' in '${sm_variant}'
    ...  Return From Keyword  uboot_env -r get reset_counter
    ...  ELSE IF  'ASIA' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF  'ASIB' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF  'ASIAB' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF  'ASIL' in '${sm_variant}'
    ...  Return From Keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE
    ...  Log  Wrong SM vartiant given  level=ERROR


Check If SBTS Lost Ping After Reset
    [Documentation]
    ...  Fail if BTS doesn't lose ping
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |

    Log  Waiting for target to be not reachable  console=true
    ${reboot_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  ${SMOD1['TRS_IP']}
    Run Keyword If  ${reboot_status} == ${FALSE}
    ...  Fail  BTS didn't loose ping, reset not perfomed.
    Log  Software fallback triggered.  console=true


Connect To Rescue Console
    [Documentation]
    ...  Connect and authorize to FDSW Rescue Console
    ...
    ...  Parameters:
    ...  Parameter_name |TYPE  |
    ...  -----------------------------------------------------------------------------------------------
    ...  ip_address     |(str) | ie. 192.168.255.129
    ...  port           |(int) | ie. 443
    ...  username       |(str) | Username to authenticate to Rescue Console
    ...  password       |(str) | Password to authenticate to Rescue Console
    ...  fdsw_version   |(str) | Default: fdsw18sp .Specific FDSW version that you want to connect to
    ...                    needs to be in line with what is running on Node B NOTE: To use specific
    ...                    version, you need to disable auto_discover by setting it to False
    ...  auto_discover  |(bool)| Default: True, Enable auto-discovery of FDSW version that is running on
    ...                    Node B. Auto discover will try all supported FDSW versions from latest to oldest,
    ...                    and connect to first compliant version.
    ...  secure         |(bool)| Default: True, Enable secure connection to Node B (ie., https for http client)
    ...  name           |(str) | Name of returned connection. If not provided, this connection becomes default.
    [Arguments]
    ...  ${ip_address}=${SMOD1['TRS_IP']}
    ...  ${port}=443
    ...  ${username}=${OAM_BTS_USER}
    ...  ${password}=${OAM_BTS_PASSWORD}
    ...  ${fdsw_version}="fdsw18sp"
    ...  ${auto_discover}=${TRUE}
    ...  ${secure}=${TRUE}
    ...  ${name}=rc_connection

    ${aliases_check}  _Compare RC Connection Aliases  ${name}
    Run Keyword If  ${aliases_check}
    ...  Run Keywords
    ...  Log To Console With Time  Connection to RC already established using alias: ${name}
    ...  AND
    ...  Return From Keyword
    Log  Trying to connect to FDSW Rescue Console (max 5 min)...  console=true
    ${rc_started}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec
    ...  taf.fdsw.rc.Connect To  ip_address=${ip_address}
    ...  port=${port}
    ...  username=${username}
    ...  password=${password}
    ...  fdsw_version=${fdsw_version}
    ...  auto_discover=${auto_discover}
    ...  secure=${secure}
    ...  name=${name}
    Run Keyword If  ${rc_started} == ${FALSE}
    ...  Fail  Rescue Console connection did not start
    Set Test Variable  ${RC_STARTED}  ${TRUE}
    Set Test Variable  ${RC_ALIAS}  ${name}
    Log To Console With Time  Connection to Rescue Console successfully established!


_Compare RC Connection Aliases
    [Documentation]
    ...  Compare RC connection aliases
    ...  Return $TRUE if the same; $FALSE if different
    [Arguments]  ${alias_to_compare}

    ${status}  Run Keyword And Ignore Error
    ...  Run Keyword If  not ${RC_STARTED}
    ...  Run Keywords
    ...  Set Variable  ${FALSE}
    ...  AND
    ...  Return From Keyword  ${FALSE}
    ${status}  Run Keyword And Return Status
    ...  Should Be Equal  ${alias_to_compare}  ${RC_ALIAS}

    [Return]  ${status}


Teardown Rescue Console
    [Documentation]
    ...  Disconnects from RC and destroys node.js daemon
    [Arguments]  ${alias}=None

    Run Keyword And Ignore Error
    ...  Run Keyword If  ${RC_STARTED}
    ...  Log To Console With Time  Teardown connection to RC using alias: ${alias}
    ...  ELSE
    ...  Run Keywords
    ...  Log To Console With Time  Connection to RC already closed
    ...  AND
    ...  Return From Keyword
    ${teardown_status}  Run Keyword And Return Status
    ...  taf.fdsw.rc.Teardown  ${alias}
    Run Keyword If  ${teardown_status}
    ...  Run Keywords
    ...  Log To Console With Time  FDSW Rescue console teardown - successful
    ...  AND
    ...  Set Test Variable  ${RC_STARTED}  ${FALSE}
    ...  ELSE
    ...  Log To Console With Time  FDSW Rescue console teardown FAILED!


Enable SSH Via Rescue Console
    [Documentation]
    ...  Enables SSH via Rescue Console using library taf.fdsw.rc
    [Arguments]  ${timeout}=10  ${alias}=ssh_enabler  ${ip_address}=${SMOD1['TRS_IP']}
    ...  ${port}=443  ${username}=${OAM_BTS_USER}  ${password}=${OAM_BTS_PASSWORD}

    Log  Enable SSH using FDSW Rescue Console  console=true
    ${rc_status}  Run Keyword And Return Status
    ...  Connect To Rescue Console  ip_address=${ip_address}  port=${port}  username=${username}  password=${password}  name=${alias}
    ${ssh_status}  Run Keyword And Return Status
    ...  taf.fdsw.rc.Enable Ssh Service  timeout=${timeout}  connection=${alias}

    [Teardown]  Teardown Rescue Console  ${alias}
    [Return]  ${ssh_status}


Get Active And Passive SW Version From Rescue Console
    [Documentation]  This keyword gets active and passive SW version from Rescue Console.
    [Arguments]  ${ip_address}=${SMOD1['TRS_IP']}  ${port}=443  ${username}=${OAM_BTS_USER}  ${password}=${OAM_BTS_PASSWORD}  ${alias}=sw_version

    Connect To SMOD  ${SMOD1['TRS_IP']}
    Log  Get active and passive SW version from Rescue Console  console=true
    ${aliases_check}  _Compare RC Connection Aliases  ${alias}
    ${rc_status}  Run Keyword If  ${aliases_check}
    ...  Log To Console With Time  Connection to RC already established using alias: ${alias}
    ...  ELSE
    ...  Run Keyword And Return Status
    ...  Connect To Rescue Console  ip_address=${ip_address}  port=${port}  username=${username}  password=${password}  name=${alias}
    ${running_sw_version}  taf.fdsw.rc.Get Running Sw Version Name  connection=${alias}
    ${sw_version_1}  taf.fdsw.rc.Get Sw Version Name  sw_slot_id=1  connection=${alias}
    ${sw_version_2}  taf.fdsw.rc.Get Sw Version Name  sw_slot_id=2  connection=${alias}
    ${active_sw_version}  Set Variable If  '${sw_version_1}'=='${running_sw_version}'  ${sw_version_1}  '${sw_version_2}'=='${running_sw_version}'
    ...  ${sw_version_2}  ${None}
    ${passive_sw_version}  Set Variable If  '${sw_version_1}'=='${active_sw_version}'  ${sw_version_2}  ${sw_version_1}
    Log Important Message  Active SW: ${active_sw_version}${\n}Passive SW: ${passive_sw_version}

    [Teardown]  Teardown Rescue Console  ${alias}
    [Return]  ${active_sw_version}  ${passive_sw_version}


Is Cell With Inband IoT
    [Documentation]
    ...  Is Cell With Inband IoT
    ...
    ...  **Input Parameters:**
    ...  +--------------------+--------+-------------------------------------+
    ...  | Input Parameters   | Man.   | Description                         |
    ...  +====================+========+=====================================+
    ...  | host_cell_id       | Yes    |  Id of LTE cell (type: Number)      |
    ...  +--------------------+--------+-------------------------------------+
    ...  **Output Parameters:**
    ...  +-------------------+---------+--------------------------------------+
    ...  | Output Parameters | Type.   | Description                          |
    ...  +===================+=========+======================================+
    ...  | iot_is_in_cell    | boolean | True if LTE cell has inband IoT cell |
    ...  +-------------------+---------+--------------------------------------+
    [Arguments]  ${host_cell_id}

    ${host_cell_object}  Query Infomodel  get object //SCF-*//LNCEL_A-${host_cell_id}
    ${iot_is_in_cell}  Run Keyword And Return Status
    ...  Should Be Equal  ${host_cell_object.nbIoTMode}  inband

    [Return]  ${iot_is_in_cell}


Verify If Inband Cell Is In LTE Cell
    [Documentation]
    ...  Verify If Inband Cell Is In LTE Cell the same like "Check If Inband Cell Is In Host LTE Cell"
    ...  but with previous "Is Cell With Inband IoT" checking
    ...
    ...  **Input Parameters:**
    ...  +--------------------+--------+--------------------------------------+
    ...  | Input Parameters   | Man.   | Description                          |
    ...  +====================+========+======================================+
    ...  | host_cell_id       | Yes    |  Id of LTE cell (type: Number)       |
    ...  +--------------------+--------+--------------------------------------+
    ...  | inband_cell_id     | Yes    |  Id of inband IoT cell (type: Number)|
    ...  +--------------------+--------+--------------------------------------+
    ...
    ...  **Output Parameters:**
    ...  +-------------------+---------+--------------------------------------+
    ...  | Output Parameters | Type.   | Description                          |
    ...  +===================+=========+======================================+
    ...  | iot_is_in_cell    | boolean | True if LTE cell has inband IoT cell |
    ...  +-------------------+---------+--------------------------------------+
    [Arguments]  ${host_cell_id}  ${inband_cell_id}

    ${iot_is_in_cell}  Is Cell With Inband IoT  ${host_cell_id}
    ${inband_cell_id_is_in_cell}  Run Keyword And Return If  ${iot_is_in_cell}
    ...  Check If Inband Cell Is In Host LTE Cell  ${host_cell_id}  ${inband_cell_id}

    [Return]  ${inband_cell_id_is_in_cell}


Check If Inband Cell Is In Host LTE Cell
    [Documentation]
    ...  Check If specified Inband Cell Is In Host LTE Cell
    ...
    ...  **Input Parameters:**
    ...  +--------------------+--------+--------------------------------------+
    ...  | Input Parameters   | Man.   | Description                          |
    ...  +====================+========+======================================+
    ...  | host_cell_id       | Yes    |  Id of LTE cell (type: Number)       |
    ...  +--------------------+--------+--------------------------------------+
    ...  | inband_cell_id     | Yes    |  Id of inband IoT cell (type: Number)|
    ...  +--------------------+--------+--------------------------------------+
    ...
    ...  **Output Parameters:**
    ...  +-------------------+---------+--------------------------------------+
    ...  | Output Parameters | Type.   | Description                          |
    ...  +===================+=========+======================================+
    ...  | iot_is_in_cell    | boolean | True if LTE cell has inband IoT cell |
    ...  +-------------------+---------+--------------------------------------+
    [Arguments]  ${host_cell_id}  ${inband_cell_id}

    ${cell_dn}  Get Inband IoT Cell By LTE Cell Id  ${host_cell_id}
    ${iot_is_in_cell}  Run Keyword And Return Status
    ...  Should Be Equal  ${cell_dn}  ${inband_cell_id}

    [Return]  ${iot_is_in_cell}


Get Inband IoT Cell By LTE Cell Id
    [Documentation]
    ...  Get Inband IoT Cell Id By LTE Cell Id
    ...
    ...  **Input Parameters:**
    ...  +--------------------+--------+-------------------------------------+
    ...  | Input Parameters   | Man.   | Description                         |
    ...  +====================+========+=====================================+
    ...  | host_cell_id       | Yes    |  Id of LTE cell (type: Number)      |
    ...  +--------------------+--------+-------------------------------------+
    ...  **Output Parameters:**
    ...  +-------------------+--------+--------------------------------------+
    ...  | Output Parameters | Type.  | Description                          |
    ...  +===================+========+======================================+
    ...  | iot_cell_id       | Number |  Id of inband IoT cell               |
    ...  +-------------------+--------+--------------------------------------+
    [Arguments]  ${host_cell_id}

    ${host_cell_object}  Query Infomodel  get object //SCF-*//LNCEL_A-${host_cell_id}
    ${iot_cell_object}  Query Infomodel  get object //SCF-*//LNCEL_A-* is [lcrId=${host_cell_object.nbIotLinkedCellId}]
    ${iot_cell_id}  Remove String Using Regexp  ${iot_cell_object.dist_name}  .*/LNCEL_A-

    [Return]  ${iot_cell_id}


Start SCF Parser Or Set Restriction
    [Documentation]  This keyword start SCF Parser or set restriction.
    [Arguments]  ${parser_tech}=SBTS

    Find SCF File
    Log  SCF which will be used to verify BTS (${COMMISSIONING_PATH})  console=true
    ${scf_parser_started}  hran_file_operations.Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=${parser_tech}
    Set Test Variable  ${SCF_PARSER_STARTED}
    Run Keyword If  ${SCF_PARSER_STARTED}
    ...  Log  SCF Parser started!  console=true
    ...  ELSE
    ...  Set Test Restriction  SCF Parser did not start. RMODs verification is not possible.


Remove Unzipped Sw Folder After Installation
    [Documentation]  This keyword remove unzipped sw folder after installation.
    [Arguments]  ${path}

    ${list_dir}  OperatingSystem.List Directories In Directory  ${path}
    ${dir}  Catenate  SEPARATOR=/  ${path}  ${list_dir}[0]
    OperatingSystem.Remove Directory  ${dir}  True


Log In Frame
    [Documentation]  This keyword log a specific message in frame.
    [Arguments]  ${message}

    Log To Console  ************************************************
    Log  ${message}  console=True
    Log To Console  ************************************************


Download Needed Software For COMPA
    [Documentation]  This keyword download needed software for COMPA.
    [Arguments]  ${sbts_base_sw_build}  ${sbts_target_sw_build}  ${sbts_cleaning_sw_build}

    Log  \nBase software is: ${sbts_base_sw_build}.  console=true
    Log  \nTarget software is: ${sbts_target_sw_build}.  console=true
    Log  \nCleaning software is: ${sbts_cleaning_sw_build}.  console=true
    Get Build To VM  ${sbts_base_sw_build}  /home/ute/BASE_SW
    Get Build To VM  ${sbts_target_sw_build}  /home/ute/TARGET_SW
    Get Build To VM  ${sbts_cleaning_sw_build}  /home/ute/CLEANING_SW


Setup COMPA Environment
    [Documentation]  This keyword is for COMPA environment setup.

    Get YAFT
    Download Needed Software For COMPA  ${BASE_SW}  ${TARGET_SW}  ${CLEANING_SW}
    TRY
        Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=${OAM_BTS_PORT}  use_ssl=true  alias=enable_ssh
        Enable Ssh Access    timeout=60  alias=enable_ssh
    EXCEPT
        taf.fdsw.rc.Connect To  ip_address=${OAM_BTS_IP}  port=${OAM_BTS_PORT}  username=${OAM_BTS_USER}  password=${OAM_BTS_PASSWORD}
        ...  name=bts_ssh_session  auto_discover=${TRUE}
        taf.fdsw.rc.Enable Ssh Service  connection=bts_ssh_session
    FINALLY
        Run Keyword And Ignore Error  Teardown Admin  alias=enable_ssh
        Run Keyword And Ignore Error  taf.fdsw.rc.Teardown  bts_ssh_session
    END
    Check NetBoot Variable


Get Software Name And Type
    [Documentation]  This keyword return software name and type.
    [Arguments]  ${sbts_sw_build}

    ${sw_name}  Fetch From Left  ${sbts_sw_build}  -
    ${sw_type}  Run Keyword If  '${sw_name}'=='${sbts_sw_build}'
    ...  Set Variable  A54
    ...  ELSE
    ...  Fetch From Right  ${sbts_sw_build}  -

    [Return]  ${sw_name}  ${sw_type}


Get Build To VM
    [Documentation]  This keyword gets build to VM.
    [Arguments]  ${build}  ${destination}

    Run  mkdir ${destination}
    ${build_share_path}  Check Build On BuildShare  ${build}
    Run Keyword If  '${build_share_path}'!='False'
    ...  Copy SW From Build Share To VM  ${build_share_path}  ${destination}
    ...  ELSE
    ...  Download Build From Repository  ${build}  ${destination}


Check Build On BuildShare
    [Documentation]  This keyword check build on BuildShare.
    [Arguments]  ${build}

    ${status}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${BUILDSHARE_LINK}
    Run Keyword If  not ${status}
    ...  Map BuildShare
    ${is_fdsw}  Set Variable If  'FDSW' in '${build}'  FDSW  ${None}
    ${path}  Run Keyword If  '${is_fdsw}'=='FDSW'
    ...  Get FDSW Build  ${build}
    ...  ELSE
    ...  Get SBTS Build  ${build}

    [Return]  ${path}


Get SBTS Build
    [Documentation]  This keyword get sbts build.
    [Arguments]  ${build}

    ${build}  ${type}  Get Software Name And Type  ${build}
    ${release_name}  Fetch From Left  ${build}  _
    ${release}  Strip String  ${release_name}  characters=SBTS
    ${release}  Set Variable If  '${release}'=='00'  Trunk  ${release}
    ${is_fsm3}  Set Variable If  'FSM3' in '${build}'  _FSM3  ${EMPTY}
    ${path}  Join Path  ${BUILDSHARE_LINK}/SBTS  ${release}${is_fsm3}
    ${files}  OperatingSystem.List Files In Directory  ${path}
    Run Keyword If  '${build}_release_BTSSM_downloadable_${type}.zip' in ${files}
    ...  Return From Keyword  ${path}/${build}_release_BTSSM_downloadable_${type}.zip
    ...  ELSE
    ...  Return From Keyword  ${FALSE}


Copy SW From Build Share To VM
    [Documentation]  This keyword copy SW from Build Share to VM.
    [Arguments]  ${source}  ${destination}

    Log  Start copy build from ${source} to ${destination}.  console=true
    Copy File  ${source}  ${destination}


Get FDSW Build
    [Documentation]  This keyword get FDSW build
    [Arguments]  ${build}

    ${path}  Join Path  ${BUILDSHARE_LINK}/SBTS  FDSW
    ${files}  OperatingSystem.List Files In Directory  ${path}
    Run Keyword If  '${build}_release_BTSSM_downloadable.zip' in ${files}
    ...  Return From Keyword  ${path}/${build}_release_BTSSM_downloadable.zip
    ...  ELSE
    ...  Return From Keyword  ${FALSE}


Download Build From Repository
    [Documentation]  This keyword download build from repository
    [Arguments]  ${build}  ${destination}

    Log  Build ${build} not found on Build Share. Trying to download from repository.  console=true
    ${build_name}  ${build_type}  Get Software Name And Type  ${build}
    Download And Check Software Package  ${build_name}  ${destination}  ${build_type}
    Log  ${build} was downloaded to ${destination}.  console=true


Get YAFT
    [Documentation]  This keyword get the YAFT

    Get YAFT On Primary VM
    Get YAFT On Secondary VM


Get YAFT On Primary VM
    [Documentation]  This keyword get YAFT on primary VM
    [Arguments]  ${destination}=/opt/yaft

    Log  Download yaft to ${destination} for primary VM.  console=true
    OperatingSystem.Run
    ...  sudo git clone https://${COMMON_USER}:${COMMON_PASSWORD}@${YAFT_LINK} ${destination}
    OperatingSystem.File Should Exist  ${destination}/yaft.py  msg=Could not find yaft.py in ${destination} for primary VM.
    Log  YAFT available in ${destination}.  console=true


Get YAFT On Secondary VM
    [Documentation]  This keyword get YAFT on secondary VM

    ${status_scondary_vm}  Run Keyword And Return Status
    ...  Variable Should Exist  ${TL.test_pcs[1].default_ssh_connection_details}
    Run Keyword If  ${status_scondary_vm}
    ...  Connect And Clone Yaft On VM  ${TL.test_pcs[1].default_ssh_connection_details.addr}
    ...  ELSE
    ...  Log  No secondary VM detected. YAFT will not be installed.  console=true


Connect And Clone Yaft On VM
    [Documentation]  This keyword connect and clone yaft on VM
    [Arguments]  ${ip}  ${user}=ute  ${destination}=/opt/yaft

    Log  Connecting to ${ip}.  console=true
    ssh.Connect To  ${ip}  ${user}  alias=yaft_connection
    Log  Download yaft to ${destination}.  console=true
    ssh.Execute  sudo git clone https://${COMMON_USER}:${COMMON_PASSWORD}@${YAFT_LINK} ${destination}
    ...  connection=yaft_connection
    ssh.Assert File Exists  ${destination}/yaft.py  msg=YAFT not found in ${destination}.  connection=yaft_connection
    Log  YAFT available in ${destination} on ${ip}.  console=true
    __Check Yaft Dependencies

    [Teardown]  ssh.Disconnect  yaft_connection


__Check Yaft Dependencies
    [Documentation]  Check python version and paramiko on VM
    ...  KW to be used in COMPA setup
    ...  ssh connection should be made with alias yaft_connection

    Log  Check Python version and Paramiko install.  console=true
    ${output}  ssh.Execute  python --version  connection=yaft_connection
    ${version}  Fetch From Right  ${output}  ${SPACE}
    ${version}  Strip String  ${version}
    Run Keyword If  '${version}'<'3.9.14'
    ...  ssh.Execute  pyenv local 3.9.14  connection=yaft_connection
    ${output}  ssh.Execute  pip install paramiko  connection=yaft_connection
    Should Contain  ${output}  Successfully installed  Unable to install Paramiko.


Common Test Setup Without Initial SBTS Check
    [Documentation]
    ...  Set of actions which will be launched before each SBTS SOAM test (starting from SBTS17).
    ...  List of actions:
    ...  -> Creates log directories
    ...  -> Deletes content of /tmp and /home/ute/btsauto/logs in order to free up space, to ensure Robot test can run
    ...  -> Starts Admin connection
    ...  -> Starts Syslogs collecting
    ...  -> Starts BTSSM on all sites
    ...
    ...  | Parameter            | Default         | Description                                                         |
    ...  | admin_launch         | TRUE            | Whether to initialise/or not Admin connection |
    ...  | syslog_launch        | TRUE            | Whether to collect/or not syslog during TC execution |
    ...  | btssm_launch         | TRUE            | Whether to initialise/or not btssm library |
    ...  | bts_host             | 192.168.255.129 | IP address to connect with BTS |
    [Arguments]
    ...  ${admin_launch}=${TRUE}
    [Timeout]  20 minutes

    Set Test Variable  ${BTSSM_STARTED}  ${FALSE}
    Set Test Variable  ${SMOD1_SYSLOG_STARTED}  ${FALSE}
    Set Test Variable  ${SMOD2_SYSLOG_STARTED}  ${FALSE}
    Set Test Variable  ${ADMIN_STARTED}  ${FALSE}
    Set Test Variable  ${SCF_PARSER_STARTED}  ${FALSE}
    Set Test Variable  ${BTS_VERIFICATION_STATUS}  run
    Set Test Variable  ${ADMIN_STARTED}  ${FALSE}
    Set Test Variable  ${INFOMODEL_STARTED}  ${FALSE}
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Set Test Verdic Variables

    ${additional_variables_exist}  Run Keyword And Return Status
    ...  Variable Should Exist  ${ADDITIONAL_VARIABLES_PATH}
    Run Keyword If  ${additional_variables_exist}
    ...  Run Keyword And Ignore Error
    ...  Import Variables  ${ADDITIONAL_VARIABLES_PATH}

    ${taf_config_model}  Run Keyword And Return Status
    ...  Variable Should Exist  ${TL}
    Set Test Variable  ${TAF_CONFIG_MODEL}  ${taf_config_model}
    Run Keyword If  ${TAF_CONFIG_MODEL}
    ...  Taf Config Adapter
    ...  ELSE
    ...  Run Keywords
    ...  Import Library  hran_testline_configuration  ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
    ...  AND
    ...  hran_testline_configuration.Set Config Variables  @{TESTLINE_CONFIG_VARIABLES}
    Run Keyword If  ${TAF_CONFIG_MODEL} == ${FALSE}
    ...  Clean VM Disk Space  Master
    There Should Be At Least 2048 MB Of Disk Space Available In /home/ute

    Setup SMOD2  ${ADMIN_STARTED}  ${INFOMODEL_STARTED}
    Log  Common Test Setup Without Initial SBTS Check  level=INFO  console=true
    Create Dirs For Logs
    Setup Mumin
    Log  TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}  level=INFO  console=true
    Set Tags  ${HW_LOCATION_CODE}\\${TESTLINE_NAME}
    Log Variables  level=DEBUG
    Run Keyword If  ${admin_launch}
    ...  Run Keyword And Continue On Failure
    ...  Start Admin  bts_host=${SMOD1['TRS_IP']}
    Log  End of Common Test Setup Without Initial SBTS Check  level=INFO  console=true
