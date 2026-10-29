*** Settings ***
Documentation  This suite contains KWs used by some TCs and resources.

Library  hran_bsc
Library  taf.sw.ping  WITH NAME  ping
Library  python_resources/tools.py
Library  python_resources/extract.py
Resource  sbts_pdu.robot


*** Variables ***
${DF_LOG_PATH}  ${OUTPUT_DIR}/df.log
${HRAN_TA_CONFIG}  /home/ute/btsauto/hran_ta/config


*** Keywords ***
Execute Command On SM Via SSH
    [Documentation]
    ...  Keyword opens connection to host machine via SSH. execute the given command and checks its return code. Command
    ...  can be executed from localhost and from remote host.
    ...
    ...  | Parameter            | Man. | Description                                            |
    ...  | ip_address           | Yes  | IP address of host on which command should be executed |
    ...  | command              | Yes  | Command to execute                                     |
    ...  | remote_host          | No   | Remote host IP address (None as default)               |
    ...  | remote_host_username | No   | Remote host username (None as default)                 |
    ...  | remote_host_password | No   | Remote host password  (None as default)                |
    ...
    ...  *RETURN*
    ...  | Parameters | Description    |
    ...  | output     | Command output |
    ...
    ...  *EXAMPLE*
    ...  | Execute command on SM via SSH | ${OAM_BTS_IP} | rm -rf /flash/config/PersDataFiles/SCFC_* |
    ...
    ...  | ${output} | Execute command on SM via SSH | 192.168.255.5 | ls -la / | 10.42.35.166 | ute | ute |
    [Arguments]  ${ip_address}  ${command}  ${remote_host_username}=${EMPTY}  ${remote_host_password}=${EMPTY}

    Connect To SMOD  ${ip_address}  ${remote_host_username}  ${remote_host_password}
    ${output}  ssh.Execute  ${command}
    ssh.Assert Exit Status  0  msg=${command} operation RC is not equal 0

    [Return]  ${output}


Kill Processes Remained After Files Deletion On VMs /home Partition
    [Documentation]
    ...  Get all processes which are listed in Linux command
    ...  'lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted'' and kill them.
    ...  Command can be run locally or remotely (after giving configuration details).
    ...  Command ommits Chrome processes to let the browser remain untouched, and also processes related to RemoteSwingLibrary.
    ...  Looping is used to provide introspection into which process caused the problem (ps stdout is logged).
    ...
    ...  | Parameter     | Man. | Description                                                                    |
    ...  | alias         | No   | Alias (Master or local in case of local machine or other in case of remote one |
    ...  | configuration | No   | KW arguments consisting with host_ip, ssh_port, ssh_username and ssh_password  |
    ...
    ...  *EXAMPLE*
    ...  | Kill processes remained after files deletion on VMs /home partition | Master |
    ...  | Kill processes remained after files deletion on VMs /home partition | Extension | host_ip=10.42.35.151 | ssh_port=22 |
    ...  | ssh_username=ute | ssh_password=ute |
    [Arguments]  ${alias}=local  &{configuration}

    Log  Kill processes remained after files deletion on /home partition  console=true
    ${pids_cmd}  Set Variable  lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted' | awk '!seen[$2]++ {print $2}'
    ${pids_str}  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Run  ${pids_cmd}
    ...  ELSE
    ...  Execute Remote Command And Return Output  ${pids_cmd}  ${alias}  &{configuration}
    @{pids}  Split String  ${pids_str}
    ${looped_ps_cmd}  Create Dictionary  cmd=ps -o comm= -p  args=@{pids}
    Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command In Loop  ${looped_ps_cmd}
    ...  ELSE
    ...  Execute Remote Command In Loop  ${looped_ps_cmd}  ${alias}  &{configuration}
    ${looped_kill_cmd}  Create Dictionary  cmd=kill -9  args=@{pids}
    ${rc}  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command In Loop  ${looped_kill_cmd}
    ...  ELSE
    ...  Execute Remote Command In Loop  ${looped_kill_cmd}  ${alias}  &{configuration}
    Run Keyword If  ${rc}==${0}
    ...  Log  All processes remained after files deletion have been killed  console=true
    ...  ELSE
    ...  Log  Failed to kill processes remained after files deletion  console=true


Execute Local Command In Loop
    [Documentation]  This keyword is used to execute local command in loop
    [Arguments]  ${looped_command}

    ${terminal_command_rc}  _Execute Command In Loop Via  Run And Return Output And Rc  ${looped_command}

    [Return]  ${terminal_command_rc}


Run And Return Output And Rc
    [Documentation]  This keyword is used to run and return output and rc
    [Arguments]  ${command}

    ${rc}  ${rv}  Run Keyword
    ...  Run And Return Rc And Output  ${command}

    [Return]  ${rv}  ${rc}


Execute Remote Command And Return Output
    [Documentation]  This keyword is used to execute remote command and return output
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}

    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_stdout}  SSHLibrary.Execute Command  ${command}  return_stdout=True  return_rc=False

    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${command_stdout}


Execute Remote Command In Loop
    [Documentation]  This keyword is used to execute remote command in loop
    [Arguments]  ${looped_command}  ${index_or_alias}  &{configuration}

    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${terminal_command_rc}  _Execute Command In Loop Via  SSHLibrary.Execute Command  ${looped_command}  return_stdout=True  return_rc=True

    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${terminal_command_rc}


_Execute Command In Loop Via
    [Documentation]  This keyword is used to execute command in loop via
    [Arguments]  ${keyword}  ${looped_command}  @{keyword_args}  &{keyword_kwargs}

    ${terminal_command_rc}  Set Variable  0
    FOR  ${arg}  IN  @{looped_command["args"]}
        ${command}  Catenate  ${looped_command["cmd"]}  ${arg}
        ${command_stdout}  ${command_rc}  Run Keyword
        ...  ${keyword}  ${command}  @{keyword_args}  &{keyword_kwargs}
        Log  ${command_stdout}
        ${terminal_command_rc}  Set Variable If  ${command_rc} != 0  ${command_rc}  ${terminal_command_rc}
    END

    [Return]  ${terminal_command_rc}


Set Cells Count
    [Documentation]  This keyword is used to Set Cells Count
    [Arguments]  ${type}

    ${has_correction}  _Check If Active Software Has Correction For IoT Cells
    Run Keyword And Return If  '${type}'=='LTE' and not ${has_correction}
    ...  Set Test Variable  ${SCF_COUNT_${type}}  -1
    ${cell_types}  Create Dictionary  GSM=GNCEL  WCDMA=WNCEL  LTE=LNCEL  NR=NRCEL
    ${ids}  Get Ids For All  ${cell_types}[${type}]
    ${cells_number}  Get Length  ${ids}
    Set Test Variable  ${SCF_COUNT_${type}}  ${cells_number}


_Check If Active Software Has Correction For IoT Cells
    [Documentation]  This keyword is used to check if active software has correction for IoT cells

    Run Keyword And Return If  '${SW_TYPE}'=='SBTS17A'
    ...  Check If ${ACTIVE_SW_VERSION} Is Newer Than SBTS17A_ENB_2000_000879_000000
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS18A'
    ...  Check If ${ACTIVE_SW_VERSION} Is Newer Than SBTS18A_ENB_0000_000422_000034
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS18SP'
    ...  Check If ${ACTIVE_SW_VERSION} Is Newer Than SBTS18SP_ENB_0000_000027_000000
    Return From Keyword If  '${SW_TYPE}'=='SBTS18'  ${False}

    [Return]  ${True}


Check If ${software} Is Newer Than ${given_software}
    [Documentation]  This keyword is used to check if a specific software is newwer then another software

    ${software}  _Get Software Version Number  ${software}
    ${given_software}  _Get Software Version Number  ${given_software}
    ${is_newer}  Evaluate  '${software}'>'${given_software}'

    [Return]  ${is_newer}


_Get Software Version Number
    [Documentation]  This keyword is used to get software version number
    [Arguments]  ${software}

    ${version_number}  Evaluate  '${software}'.split('_', 2).pop()

    [Return]  ${version_number}


Set SCF System Modules Count And Verify Product Numbers
    [Documentation]
    ...  Keyword for checking system modules amount and validating its runtime product numbers against these in SCF

    ${scf_smods}  hran_file_operations.Get System Modules
    ${scf_count_smod}  Get Length  ${scf_smods}
    Set Test Variable  ${SCF_COUNT_SMOD}
    Set Test Variable  ${SCF_SMODS}

    ${check_status}  ${runtime_mods}  ${all_mods}  Get Objects With Expected States  ${SMOD_EXPECTED_STATES}  SMOD
    Run Keyword If  '${check_status}'=='PASS'
    ...  Validate Runtime Modules Product Numbers Against Scf  ${runtime_mods}  ${SCF_SMODS}


Set SCF Radio Modules Count And Verify Product Numbers
    [Documentation]
    ...  Keyword for checking radio modules amount and validating its runtime product numbers against these in SCF

    ${scf_rmods}  hran_file_operations.Get Radios
    ${scf_count_rmod}  Get Length  ${scf_rmods}
    Set Test Variable  ${SCF_COUNT_RMOD}

    ${check_status}  ${runtime_mods}  ${all_mods}  Get Objects With Expected States  ${RMOD_EXPECTED_STATES}  RMOD
    Run Keyword If  '${check_status}'=='PASS'
    ...  Validate Runtime Modules Product Numbers Against Scf  ${runtime_mods}  ${scf_rmods}


Check SCF Count
    [Documentation]  This keyword is used to check SCF count
    ...
    ...  | Parameter       | Mandatory | Description                    |
    ...  | class_name      | Yes       | [LTE, WCDMA, GSM, SMOD, RMOD]  |
    ...  | runtime_objects | Yes       | List of runtime objects        |
    [Arguments]  ${class_name}  ${runtime_objects}

    Run Keyword If  ${SCF_COUNT_${class_name}}==0
    ...  Run Keywords
    ...  Log  ${class_name} not found in SCF  console=true
    ...  AND
    ...  Return From Keyword  ${True}

    Run Keyword If  ${SCF_COUNT_${class_name}}==-1
    ...  Run Keywords
    ...  Log  ${class_name} will be ignored for active software  console=true
    ...  AND
    ...  Return From Keyword  ${True}

    ${final_status}  Evaluate  ${SCF_COUNT_${class_name}}==len(${runtime_objects})

    [Return]  ${final_status}


Validate Runtime Modules Product Numbers Against Scf
    [Documentation]  This keyword is used to Validate Runtime Modules Product Numbers Against scf
    [Arguments]  ${runtime_modules}  ${scf_modules}

    ${runtime_mods_mapping}  _Extract Modules Product Codes  ${runtime_modules}  productCode  id
    ${scf_mods_mapping}  _Extract Modules Product Codes  ${scf_modules}  prodCodePlanned  distName

    ${runtime_mods_product_codes}  Get Dictionary Values  ${runtime_mods_mapping}
    ${scf_mods_product_codes}  Get Dictionary Values  ${scf_mods_mapping}
    Sort List  ${runtime_mods_product_codes}
    Sort List  ${scf_mods_product_codes}

    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${runtime_mods_product_codes}  ${scf_mods_product_codes}
    Run Keyword If  ${status} == ${FALSE}
    ...  Log  Modules product codes differs between runtime(${runtime_mods_mapping}) and scf(${scf_mods_mapping})  console=true

    [Return]  ${status}


_Extract Modules Product Codes
    [Documentation]  This keyword is used to Extract Modules Product Codes
    [Arguments]  ${modules_obj_list}  ${product_code_key}  ${dist_name_key}

    ${mods_mapping}  Create Dictionary
    FOR  ${mod}  IN  @{modules_obj_list}
        ${raw_product_code}  Get From Dictionary  ${mod}  ${product_code_key}
        ${stripped_product_code}  Strip String  ${raw_product_code}
        @{product_code}  Split String  ${stripped_product_code}  .
        ${stripped_product_code}  Get From List  ${product_code}  0
        ${dist_name}  Get From Dictionary  ${mod}  ${dist_name_key}
        Set To Dictionary  ${mods_mapping}  ${dist_name}  ${stripped_product_code}
    END

    [Return]  ${mods_mapping}


Get Commissioning Path
    [Documentation]
    ...
    ...  Find commissioning in testline configuration directory which match given sw_version
    ...  You can set your own COMMISSIONING_PATH to ommit searching commissioning in config directory
    ...  You can set your own SCF_ID to find scf for technology with exact scf_id value
    ...
    ...  *Example*
    ...  For sw_version=WN18_FL18_GF18_SBTS18SP_ENB_1000_000609_000000 KW will try to find
    ...  SCF_01_SBTS18SP or SCF_01_SBTS18 or SCF_01_TRUNK
    ...
    ...  For sw_version=WN18_FL18_GF18_SBTS17A_ENB_1000_000609_000000 and SCF_ID=02 KW will try to find
    ...  SCF_02_SBTS18SP or SCF_02_SBTS18 or SCF_02_TRUNK
    [Arguments]  ${sw_version}

    ${regex}  Set Variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
    ${result}  Get Regexp Matches  ${sw_version}  ${regex}  product  postfix
    ${product}  ${postfix}  Set Variable  ${result[0]}
    ${product}  Convert To Uppercase  ${product}
    ${postfix}  Convert To Uppercase  ${postfix}
    Set Test Variable  ${SW_TYPE}  ${product}${postfix}

    ${scf_id}  Get Variable Value  ${SCF_ID}  01

    ${product_list}  Create List  ${product}${postfix}  ${product}  TRUNK
    FOR  ${product}  IN  @{product_list}
        ${filename}  Set Variable  SCF_${scf_id}_${product}
        Log To Console  Trying to find scf for ${product} (${filename})
        ${commissioning}  Find Commissioning With Filename  ${filename}
        ${is_not_empty}  Run Keyword And Return Status
        ...  Should Not Be Empty  ${commissioning}
        Run Keyword If  ${is_not_empty}
        ...  Return From Keyword  ${commissioning}
    END

    [Return]  ${None}


Find Commissioning With Filename
    [Documentation]
    ...  Find commissioning in testline configuration directory
    ...  HW_LOCATION_CODE and TESTLINE_NAME will be provided by hran_frame_sbts
    [Arguments]  ${filename}  ${root}=${HRAN_TA_CONFIG}  ${scf_dir}=commissioning

    ${path}  Set Variable  ${root}/${HW_LOCATION_CODE}/${TESTLINE_NAME}/${scf_dir}/${filename}.xml
    ${is_existing}  Run Keyword And Return Status
    ...  Should Exist  ${path}
    Return From Keyword If  ${is_existing}  ${path}

    [Return]  ${None}


Find Path To SW Package
    [Documentation]  This keyword is used to find path to SW package

    ${target_sw_path}  Get SW File For SWDL  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Run Keyword If  '${target_sw_path}'== ${None}
    ...  Fail  msg=
    Set Test Variable  ${TARGET_SW_PATH}
    Log  Chosen software package is: ${TARGET_SW_PATH}  console=true


Install IPSec Certificates
    [Documentation]
    ...  KW for IPSec certificates installation. In default certificates should be stored under
    ...  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates
    ...  For now only .p12 and .pem files extensions are supported
    ...  | Parameter | Mandatory | Description |
    ...  | cert_path | No        | BTS IP      |
    [Arguments]  ${cert_path}=${HRAN_TA_CONFIG}/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates

    Log  Install IPSec certificates from ${cert_path}  console=true
    @{p12_files}  OperatingSystem.List Files In Directory  ${cert_path}  pattern=*.p12  absolute=${TRUE}
    FOR  ${p12_cert}  IN  @{p12_files}
        Install Certificate  ${p12_cert}  BtsTrustChain  P12  Cwirhau
        Log  Certificate ${p12_cert} installed  console=true
    END
    @{pem_files}  OperatingSystem.List Files In Directory  ${cert_path}  pattern=*.pem  absolute=${TRUE}
    FOR  ${pem_cert}  IN  @{pem_files}
        Install Certificate  ${pem_cert}  AdditionalCa  PEM  Cwirhau
        Log  Certificate ${pem_cert} installed  console=true
    END


Enable SSH In Independent Execution Context On SBTS SOAM TAF
    [Documentation]
    ...  Check parameters systemAcctPermEnable and actServiceAccountSsh to enable ssh connection
    ...  via default credentials
    [Arguments]  ${bts_host}=${OAM_BTS_IP}  ${bts_port}=443  ${use_ssl}=${TRUE}  ${alias}=ssh

    ${admin_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 times  5 sec
    ...  Setup Admin  admin_api_log_dir=${BTS_FILES}  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=${use_ssl}  alias=${alias}
    Run Keyword If  ${admin_status} == ${FALSE}
    ...  Return From Keyword  ${False}

    Run Keyword And Ignore Error
    ...  Enable Ssh Access  alias=${alias}
    ${is_ssh_enabled}  Check If SSH Is Enabled
    Return From Keyword If  ${is_ssh_enabled}  ${True}

    ${bts_state}  coam.Get Mrbts State  timeout=30  alias=${alias}
    Run Keyword If  '${bts_state}'=='NotCommissioned'
    ...  Return From Keyword  ${False}

    Setup Infomodel  address=${bts_host}  port=${bts_port}  use_ssl=${use_ssl}  admin_api_log_dir=${BTS_FILES}/  timeout=300  alias=${alias}
    ${infomodel_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  15 sec
    ...  Connect Infomodel  alias=${alias}
    Run Keyword If  ${infomodel_status} == ${FALSE}
    ...  Return From Keyword  ${False}

    Run Keyword And Ignore Error
    ...  __check SystemAcctPermEnable Parameter And Recommissioning If Needed  ${alias}
    Run Keyword And Ignore Error
    ...  __check ActServiceAccountSsh Parameter And Recommissioning If Needed  ${alias}

    ${is_ssh_enabled}  Check If SSH Is Enabled
    Return From Keyword If  ${is_ssh_enabled}  ${True}

    [Teardown]  Run Keywords
    ...  Teardown Admin  alias=${alias}
    ...  AND
    ...  Teardown Infomodel  alias=${alias}
    [Return]  ${False}


__check SystemAcctPermEnable Parameter And Recommissioning If Needed
    [Documentation]  This keyword is used to check systemAcctPermEnable parameter and recommissioning if needed.
    [Arguments]  ${alias}=ssh

    ${featcadm}  Query Infomodel  get object //MNL_A-*/MNLENT_A-*/FEATCADM_A-*  alias=${alias}
    ${object_dist_name}  Evaluate  "${featcadm["dist_name"]}".rsplit('MRBTS_A-')[1].replace('_A','')
    Run Keyword If  "${featcadm["systemAcctPermEnable"]}"=="True"
    ...  Run Keywords
    ...  Log  Parameter systemAcctPermEnable==True, perform recommissioning  console=true
    ...  AND
    ...  Perform Parameter Recommissioning  MRBTS-${object_dist_name}
    ...  systemAcctPermEnable
    ...  update
    ...  false
    ...  skip_parameter_relation_errors=${True}
    ...  alias=${alias}


__check ActServiceAccountSsh Parameter And Recommissioning If Needed
    [Documentation]  This keyword is used to check actServiceAccountSsh parameter and recommissioning if needed.
    [Arguments]  ${alias}=ssh

    ${secadm}  Query Infomodel  get object //MNL_A-*/MNLENT_A-*/SECADM_A-*  alias=${alias}
    ${object_dist_name}  Evaluate  "${secadm["dist_name"]}".rsplit('MRBTS_A-')[1].replace('_A','')
    Run Keyword If  "${secadm["actServiceAccountSsh"]}"=="False"
    ...  Run Keywords
    ...  Log  Parameter actServiceAccountSsh==False, perform recommissioning  console=true
    ...  AND
    ...  Perform Parameter Recommissioning  MRBTS-${object_dist_name}
    ...  actServiceAccountSsh
    ...  update
    ...  true
    ...  skip_parameter_relation_errors=${True}
    ...  alias=${alias}


Get BCF IPs From SCF
    [Documentation]
    ...  Gather BCF IPs from downloaded SCF
    ...  | **Full description:**
    ...  | KW for obtaining all IPs connected to GSM RAT from SCF. It returns list of all IPs connected to distName from
    ...  | under 'mPlaneLocalIpAddressDN'. SCF file is downloaded inside this KW.

    Collect SCF  ${TEST_FILES}/SCF_for_BCF_IPs_check.xml
    ${scf_xml}  Parse Xml  ${TEST_FILES}/SCF_for_BCF_IPs_check.xml
    ${bcf_mplane_dist_name}  Get Element Text  ${scf_xml}  .//*[@name='mPlaneLocalIpAddressDN']
    ${common_dist}  Fetch From Left  ${bcf_mplane_dist_name}  IPADDRESSV4
    ${bcf_ips}  Get Elements Texts  ${scf_xml}  .//*[contains(@distName, "${common_dist}")]/*[@name='localIpAddr']

    [Return]  ${bcf_ips}


Check If All RMs Detected
    [Documentation]
    ...  Check if all Radio Modules are detected.
    ...  Please be aware that in case of two System Modules configuration (3+3, 4+4, 4+3) there is a need to SMs be synchronized

    Get SCF Count Of RMODs
    ${modules_status}  Verify Modules  RMOD
    Run Keyword If  ${modules_status}
    ...  Log  RMODs are detected!
    ...  ELSE
    ...  Fail


Get SCF Count Of RMODs
    [Documentation]
    ...  Counts number of Radio Modules in SCFC and saves this value to test variable 'SCF_COUNT_RMOD'

    ${scf_rmods}  hran_file_operations.Get Radios
    ${scf_rmods_count}  Get Length  ${scf_rmods}
    Set Test Variable  ${SCF_COUNT_RMOD}  ${scf_rmods_count}


Remove And Send New SSH Key
    [Documentation]  This keyword is used to remove and send new SSH key.

    Log  Remove SSH key  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  Run  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R ${SMOD1['TRS_IP']}
    Log  Send new SSH key  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  Run  sshpass -p ${SMOD1['PASSWORD']} ssh-copy-id -i ~/.ssh/toor4nsn/id_rsa.pub toor4nsn@${SMOD1['TRS_IP']}


Connect To BSC Setup
    [Documentation]  This keyword is used to connect to BSC setup.

    hran_bsc.Bsc Ssh Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    hran_bsc.Set Timeout  240s


Modify Resource Search Order
    [Documentation]  Adjust Robot's library search order for the Robot-based (as opposed to JSON-based)
    ...  test sets. The KW adds a new entry at the end of the search order list (to retain search order defined
    ...  in TC Setup). To be used in [Setup] section as follows (presented here in a convenient tabular form):
    ...
    ...  [Setup] | Run Keywords | res_name.TC Setup | AND | Modify Resource Search Order | res_name
    ...
    ...  in pair with `Restore Resource Search Order` in [Teardown]:
    ...
    ...  [Teardown] | Run Keywords | res_name.TC Teardown | AND | Restore Resource Search Order
    ...
    ...  Non-existing resurces (`dummy_resource_name`) are ignored.
    [Tags]  robot:no-dry-run
    [Arguments]  ${resource_name}

    ${dummy_search_order}  Create List  dummy_resource_name
    ${search_order}  Set Library Search Order
    ${original_search_order}  Set Variable If  len(${search_order})  ${search_order}  ${dummy_search_order}
    Set Test Variable  ${ORIGINAL_SEARCH_ORDER}
    Set Library Search Order  ${resource_name}  @{search_order}


Restore Resource Search Order
    [Documentation]  To be used in pair with `Modify Resource Search Order`
    [Tags]  robot:no-dry-run

    ${search_order}  Create List  @{ORIGINAL_SEARCH_ORDER}
    Remove Values From List  ${search_order}  dummy_resource_name
    Set Library Search Order  @{search_order}


Get SW File For SWDL
    [Documentation]
    ...  Verify given directory and return a path to the SW file (with given name or the newest in directory)
    [Arguments]  ${sw_dir}  ${sw_name}

    OperatingSystem.Directory Should Exist  ${sw_dir}
    OperatingSystem.Directory Should Not Be Empty  ${sw_dir}
    Run Keyword And Return If  '${sw_name}'=='None'
    ...  hran_file_operations.Get Newest File From Directory  ${sw_dir}  *.zip
    ${sw_path}  Join Path  ${sw_dir}  ${sw_name}.zip
    OperatingSystem.File Should Exist  ${sw_path}

    [Return]  ${sw_path}


Check If SW Already Exists On BTS
    [Documentation]
    ...  pass_if_exists=False or omitted: Fail if given SW already exists on BTS (active)
    ...  pass_if_exists=True: Immediately ends the test as passed if given SW already exists on BTS (active)
    [Arguments]  ${target_sw}  ${active_sw}  ${passive_sw}  ${pass_if_exists}=${False}

    ${target_is_passive}  Run Keyword And Return Status
    ...  Should Match Regexp  ${target_sw}  (?i).*${passive_sw}(?!T[12]).*
    Run Keyword If  ${target_is_passive}
    ...  Log  Target SW is the same as the passive
    ${target_is_active}  Run Keyword And Return Status
    ...  Should Match Regexp  ${target_sw}  (?i).*${active_sw}(?!T[12]).*
    Run Keyword If  ${target_is_active} and ${pass_if_exists}
    ...  Pass Execution  Target SW is the same as the active
    Run Keyword If  ${target_is_active}
    ...  Fail  Target SW is the same as the active


Create '${dir_name}' In '${root_dir}' And Set Test Variable
    [Documentation]
    ...   Log directories are created: BTSFiles, TestFiles, UDPLogs, Temp Logs Dir

    ${dir_path}  OperatingSystem.Join Path  ${root_dir}  ${dir_name}
    Create Directory  ${dir_path}
    Set Test Variable  ${${dir_name}}  ${dir_path}
    Log  '${dir_name}' created: ${dir_path}  level=DEBUG


Kill Process By Name
    [Documentation]
    ...  Keyword killing group of process specified by name (case insensitive).
    ...
    ...  | Parameter   | Man. | Description                                                    |
    ...  | process_name       | Yes  | string       |
    ...  | local | Yes  | boolean |
    ...  | configuration | Yes  | if local==false host_ip=<remote_host_ip>, ssh_port=<port>, ssh_username=<usenrame>, ssh_passsword=<password> |
    [Arguments]  ${process_name}  ${local}=${TRUE}  &{configuration}

    ${kill_cmd}  Set Variable  kill -KILL $(ps -ef | grep -i ${process_name} | awk '{print $2}')
    Run Keyword If  ${local}
    ...  Process.Run Process  ${kill_cmd}  shell=${TRUE}
    ...  ELSE
    ...  Run Keywords
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    ...  AND
    ...  _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}
    ...  AND
    ...  SSHLibrary.Execute Command  ${kill_cmd}  return_stdout=${FALSE}
    ...  AND
    ...  SSHLibrary.Close Connection

    [Return]  ${TRUE}


Clean Up Directory
    [Documentation]
    ...  KW for removing files older than certain time
    ...
    ...  | Parameter       | Man. | Description                                                      |
    ...  | clean_directory | Yes  | Absolute path to directory that needs to be  cleaned             |
    ...  | older_than_min  | Yes  | Time from where file needs to be deleted                         |
    ...  | alias           | Yes  | Alias used via taf.sbts.oam.coam.admin library (Slave or Master) |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description             |
    ...  | result        | Folder cleanup resul    |
    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}

    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}  level=INFO  console=true
    ${command}  Set Variable
    ...  if [ "$(ls -A ${clean_directory})" ]; then find ${clean_directory}/* -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${cleaning_rc}  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Run And Return Rc  ${command}
    ...  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}  Run Keyword And Return Status
    ...  Should Be Equal  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    Run Keyword If  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=true
    ...  ELSE
    ...  Log  Failed to clean "${clean_directory}" on ${alias}  level=INFO  console=true

    [Return]  ${result}


Execute Remote Command
    [Documentation]
    ...   Executing command via ssh on remote host
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}

    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_rc}  SSHLibrary.Execute Command  ${command}  return_stdout=False  return_rc=True

    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${command_rc}


_Remote Command Setup
    [Documentation]
    ...   Ssh conection opening and login
    [Arguments]  ${index_or_alias}  &{configuration}

    ${check_connection}  SSHLibrary.Get Connection  ${index_or_alias}
    Run Keyword If  ${check_connection.index}
    ...  SSHLibrary.Switch Connection  ${index_or_alias}
    ...  ELSE
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}


_SSHLibrary_Login_multiway
    [Documentation]
    ...   KW allows ssh login via user & pass and via public key
    [Arguments]  ${username}  ${password}

    ${status}  Run Keyword And Return Status
    ...  SSHLibrary.Login  ${username}  ${password}
    Return From Keyword If  ${status}
    ${status}  Run Keyword And Return Status
    ...  SSHLibrary.Login With Public Key  ${username}  /home/${username}/.ssh/id_rsa
    Run Keyword If  ${status} == ${FALSE}
    ...  Fail  Remote connection unavailable


Close All BSC Sessions
    [Documentation]
    ...  Close all connections to BSC and clear connection cache

    hran_bsc.Close All Connections
    Log  All sessions to BSC closed  console=true


Create 'Test Results Dir' And Set Test Variable
    [Documentation]  Test Results directories are created

    ${test_timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${has_extradisk}  Check If Extradisk Disk Is Available On VM
    ${test_results_path}  Run Keyword If  ${has_extradisk}
    ...  OperatingSystem.Join Path  /home/ute/logs  ${test_timestamp}_TEST-${TEST_NAME}
    ...  ELSE
    ...  OperatingSystem.Join Path  ${OUTPUT_DIR}  ${test_timestamp}_TEST-${TEST_NAME}
    Create Directory  ${test_results_path}
    Set Test Variable  ${TEST_RESULTS_DIR}  ${test_results_path}
    Log  'Test Results Dir' created: ${TEST_RESULTS_DIR}  level=DEBUG  console=true


Check If Extradisk Disk Is Available On VM
    [Documentation]  Extra Disk can be created using procedure found at:
    ...  https://confluence.ext.net.nokia.com/display/UTE/05.+VM+Customization

    ${output}  OperatingSystem.Run  df -h
    ${extra_disk}  Set Variable If  'vg_extradisk-lv_home--ute--logs' in '''${output}'''  ${TRUE}  ${FALSE}

    [Return]  ${extra_disk}


Create Dirs For Logs
    [Documentation]  This keyword is used to create dirs for logs

    ${test_name}  Replace String Using Regexp  ${TEST_NAME}  \\[|\\]|\\.  _
    Create 'Test Results Dir' And Set Test Variable
    Create 'BTSFiles' In '${TEST_RESULTS_DIR}' And Set Test Variable
    Create 'TestFiles' In '${TEST_RESULTS_DIR}' And Set Test Variable
    Create 'UDPLogs' In '${TEST_RESULTS_DIR}' And Set Test Variable
    Create Temp Logs Dir And Set Test Variable


Create Temp Logs Dir And Set Test Variable
    [Documentation]
    ...   Log directories are created during Common Test Setup

    ${test_timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${test_name_without_brackets}  Replace String  ${TEST_NAME}  [1]  _1_
    ${joined_path}  OperatingSystem.Join Path  ${TEMP_LOGS_DIR}  ${test_timestamp}_TEST-${test_name_without_brackets}
    Set Test Variable  ${TEMP_LOGS_DIR}  ${joined_path}
    Log  Temp logs Dir created: ${TEMP_LOGS_DIR}  level=DEBUG


There Should Be At Least ${this_much} MB Of Disk Space Available In ${directory}
    [Documentation]
    ...  Checks if there is a minimal required available disk space in given directory, sets test as norun if not
    ...  and skips to test teardown. Also dumps `df` output as log from test for future reference.
    ...
    ...  *INPUT*
    ...  | Parameter        | Mandatory | Description                                   |
    ...  | this much        | Yes       | Minimum expected free space in MB             |
    ...  | directory        | Yes       | Directory (or file) path to verify            |
    ...
    ...  *RETURN*  None

    Run  echo "[$(date -u)] - ${TEST_NAME} \n $(df -h) \n" >> ${DF_LOG_PATH}
    ${exists}  ${message}  Run Keyword And Ignore Error
    ...  Should Exist  ${directory}
    Run Keyword If  "${exists}" == "FAIL"
    ...  Run Keywords
    ...  Log  ${message}  level=WARN
    ...  AND
    ...  Return From Keyword
    ${available_space}  Run  df -BM --output=avail ${directory} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${available_space} < ${this_much}
    ...  Set Test Norun  ${available_space}MB available in ${directory} is less than required ${this_much}MB


Check If Remote Host Directory Has Enough Space
    [Documentation]
    ...  Copy of KW 'There should be at least ${this_much} MB of disk space available in ${directory}' adapted to run on
    ...  remote machine via SSH protocol.
    ...
    ...  *INPUT*
    ...  | Parameter     | Mandatory | Description                         |
    ...  | space_amount  | Yes       | Minimum expected free space in MB   |
    ...  | dir_path      | Yes       | Directory (or file) path to verify  |
    ...  | host_ip       | Yes       | IP address of host machine          |
    ...  | ssh_port      | Yes       | Port for SSH connection             |
    ...  | ssh_username  | Yes       | Username for log in to host via SSH |
    ...  | ssh_password  | Yes       | Password for log in to host via SSH |
    [Arguments]  ${dir_path}  ${space_amount}  ${host_ip}  ${ssh_port}  ${ssh_username}  ${ssh_password}

    SSHLibrary.Open Connection  host=${host_ip}  port=${ssh_port}
    _SSHLibrary_Login_multiway  ${ssh_username}  ${ssh_password}
    SSHLibrary.Execute Command  echo "[$(date -u)] - ${TEST_NAME} \n $(df -h) \n" >> ${DF_LOG_PATH}  return_stdout=False  return_rc=True
    ${exists}  ${message}  Run Keyword And Ignore Error
    ...  SSHLibrary.Directory Should Exist  ${dir_path}
    Run Keyword If  "${exists}" == "FAIL"
    ...  Run Keywords
    ...  Log  ${message}  level=WARN
    ...  AND
    ...  Return From Keyword
    ${available_space}  SSHLibrary.Execute Command  df -BM --output=avail ${dir_path} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${available_space} < ${space_amount}
    ...  Set Test Norun  ${available_space}MB available in ${dir_path} is less than required ${space_amount}MB

    [Teardown]  SSHLibrary.Close Connection


Get PDU Optical Interface Info List
    [Documentation]
    ...  Helper KW providing list of PDU items based on devices connected on its ports
    ...
    ...  | Parameter | Man. | Description                |
    ...  | port_1    | Yes  | Device connected on port 1 |
    ...  | port_2    | Yes  | Device connected on port 2 |
    ...
    ...  *RETURN*
    ...  | PDU_items  | PDU items |
    [Arguments]  ${port_1}  ${port_2}

    ${keys}  Get Dictionary Keys  ${INTERFACES}
    ${values}  Get Dictionary Values  ${INTERFACES}
    ${pdu_items}  Create List  @{EMPTY}
    FOR  ${pdu_item}  ${pdu_info}  IN ZIP  ${keys}  ${values}
        ${var1}  Run Keyword And Return Status
        ...  Variable Should Exist  ${pdu_info['PORT_1']}
        ${var2}  Run Keyword And Return Status
        ...  Variable Should Exist  ${pdu_info['PORT_2']}
        Run Keyword If  ${var1} and ${var2}
        ...  Run Keyword If  '${port_1}' in '${pdu_info['PORT_1']}' and '${port_2}' in '${pdu_info['PORT_2']}'
        ...  Append To List  ${pdu_items}  ${pdu_item}
    END

    [Return]  ${pdu_items}
