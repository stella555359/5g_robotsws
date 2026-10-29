*** Settings ***
Documentation  This resource contains all common keywords from SBTS.

Library  Collections
Library  DateTime
Library  OperatingSystem
Library  Process
Library  String
#Library  ../../../../resources/python_resources/admin_cli.py
#Library  ../../../common_resources/python_resources/snapshot_check.py
#Library  ../../../common_resources/python_resources/syslog_resource.py
#Library  ../../../../resources/python_resources/radio_modules.py
Library  SSHLibrary
Library  hran_bsc
Library  taf.ul.verify_snapshot  WITH NAME  snapshot
Resource  L3_call.robot
#Resource  hran_frame_sbts_taf.robot


*** Variables ***
${SITE_RESET_PROCEDURE}  600


*** Keywords ***
Recover Test Line By Power Reset
    [Documentation]  If test Fail performs power reset all TL modules and waits for BTS OnAir.

    Run Keyword If Test Failed
    ...  _BTS_Power_Reset


_BTS_Power_Reset
    [Documentation]  This KW perform power reset.

    Log  Recovery Power Reset  console=true
    Setup Admin  bts_host=${SMOD1}[IP]
    ${interfaces_module_list}  Admin Get Modules For Interfaces TAF
    FOR  ${module_distname}  IN  @{interfaces_module_list}
        ${off_status}  Run Keyword And Return Status
        ...  Pdu BTS Interface Off  ${module_distname}
        Run Keyword If  ${off_status}
        ...  Log  Power on ${module_distname} is OFF.  console=true
        ...  ELSE
        ...  Log  ${module_distname} is not defined in config (yaml/taf).  console=true
        Sleep  1s
    END
    Wait For Target To Be Not Reachable  ${SMOD1['IP']}
    Sleep  3s
    FOR  ${module_distname}  IN  @{interfaces_module_list}
        ${on_status}  Run Keyword And Return Status
        ...  Pdu BTS Interface On  ${module_distname}
        Run Keyword If  ${on_status}
        ...  Log  Power on ${module_distname} is ON.  console=true
        ...  ELSE
        ...  Log  ${module_distname} is not defined in config (yaml/taf).  console=true
    END
    Log  Waiting for ping to BTS  console=true
    Wait For Target To Be Reachable  ${SMOD1['IP']}  300
    Log  Waiting for SMODs  console=true
    coam.Assert Every  SMOD  ${SMOD_EXPECTED_STATES}  timeout=600
    Log  Waiting for RMODs  console=true
    coam.Assert Every  RMOD  ${RMOD_EXPECTED_STATES}  timeout=600
    ${is_nr}  Get Ids For All  NRCEL
    ${is_lte}  Get Ids For All  LNCEL
    ${is_gsm}  Get Ids For All  GNCEL
    ${is_wcdma}  Get Ids For All  WNCEL
    Log  Waiting for NR cells  console=true
    Run Keyword If  ${is_nr}
    ...  coam.Assert Every  NRCEL  ${CELLS_NR_EXPECTED_STATES}  timeout=600
    Log  Waiting for LTE cells  console=true
    Run Keyword If  ${is_lte}
    ...  coam.Assert Every  LNCEL  ${CELLS_LTE_EXPECTED_STATES}  timeout=600
    Log  Waiting for WCDMA cells  console=true
    Run Keyword If  ${is_wcdma}
    ...  coam.Assert Every  WNCEL  ${CELLS_WCDMA_EXPECTED_STATES}  timeout=600
    Log  Waiting for GSM cells  console=true
    Run Keyword If  ${is_gsm}
    ...  coam.Assert Every  GNCEL  ${CELLS_GSM_EXPECTED_STATES}  timeout=600

    FOR  ${module_distname}  IN  @{interfaces_module_list}
        ${on_status}  Run Keyword And Return Status
        ...  Pdu BTS Interface On  ${module_distname}
    END
    Teardown Admin


Sleep Until New 15 Minutes Cycle
    [Documentation]  This keyword calculates the minutes it needs to sleep until new 15 minutes cycle.

    @{time}  Get Time  min sec
    ${minutes}  Set Variable  00:15:00
    FOR  ${index}  IN RANGE  0  4
        ${minutes}  Run Keyword If  '00:${time}[0]:${time}[1]' < '${minutes}'
        ...  Exit For Loop
        ...  ELSE
        ...  Add Time To Time  ${minutes}  15:00  timer  exclude_millis=yes
    END
    ${minutes}  Subtract Time From Time  ${minutes}  00:${time}[0]:${time}[1]  timer  exclude_millis=yes
    Log  Sleep for ${minutes} minutes until new 15 min cycle  console=true
    Sleep  ${minutes}

    [Return]  ${minutes}


Log Step Header
    [Documentation]  This keyword is used to log step header.
    [Arguments]  ${message}

    Log  ${\n}==========================================================================================  console=true
    Log  ${message}  console=true
    Log  ==========================================================================================  console=true


Admin Check All Required State
    [Documentation]  This keyword check all required state for cells and modules.

    Run Keyword If  ${SCF_COUNT_NR}
    ...  Run Keywords
    ...  coam.Assert Every  NRCEL  operationalState=${ENABLED}
    ...  AND
    ...  Admin Check Cells Number  NRCEL  ${SCF_COUNT_NR}
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Run Keywords
    ...  coam.Assert Every  LNCEL  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    ...  AND
    ...  Admin Check Cells Number  LNCEL  ${SCF_COUNT_LTE}
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Run Keywords
    ...  coam.Assert Every  GNCEL  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    ...  AND
    ...  Admin Check Cells Number  GNCEL  ${SCF_COUNT_GSM}
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Run Keywords
    ...  coam.Assert Every  WNCEL  blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    ...  AND
    ...  Admin Check Cells Number  WNCEL  ${SCF_COUNT_WCDMA}
    ${cell_types}  Create List  GNCEL  WNCEL  LNCEL  NRCEL
    FOR  ${cell_type}  IN  @{cell_types}
        Check If Cells Are Not Degraded  ${cell_type}
    END
    coam.Assert Every  SMOD  operationalState=${ENABLED}
    coam.Assert Every  RMOD  operationalState=${ENABLED}


Check If Cells Are Not Degraded
    [Documentation]  This KW check if all cells from a specific technology are not degraded.
    [Arguments]  ${cell_type}

    ${status}  Run Keyword And Return Status
    ...  coam.Assert Any  ${cell_type}  availabilityStatus=${DEGRADED}
    Run Keyword If  ${status}
    ...  Fail


Check All Cells
    [Documentation]  This KW check all cells.

    ${all_rats}  Create List  NR  LTE  WCDMA  GSM
    ${working_dict}  Create Dictionary
    FOR  ${rat}  IN  @{all_rats}
        IF  ${SCF_COUNT_${rat}}
            ${cells_working}  Verify Cells TAF  technology=${rat}  scf_check=${FALSE}
            Set To Dictionary  ${working_dict}  ${rat}_working  ${cells_working}
        END
    END
    ${condition}  Set Variable  ${EMPTY}
    FOR  ${working_rat}  IN  @{working_dict.keys()}
        IF  '${condition}' != '${EMPTY}'
            ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}  ${working_dict}[${working_rat}]  ${condition}
        ELSE
            ${condition}  Set Variable  ${working_dict}[${working_rat}]
        END
    END
    IF  ${condition}
        Log  All cells are in expected state.  console=true
    ELSE
        Fail  Not all cell are in expected state.
    END


Check NR Status To Be Working
    [Documentation]  To check X2 link and NR cell status are working.

    Wait Until Keyword Succeeds  10 min  15 s
    ...  _Check All NR Cells To Be Enabled
    Check X2 And NG Links To Be Working


Check X2 And NG Links To Be Working
    [Documentation]  Check if X2 and NG links are working.

    ${nrbts_type}  _Get NR Type
    Log  NR BTS type is ${nrbts_type}.  console=true
    Run Keyword If  '${nrbts_type}'=='NSA'
    ...  Check NSA NR  Available
    ...  ELSE IF  '${nrbts_type}'=='SA'
    ...  Check SA NR  Active
    ...  ELSE
    ...  Run Keywords
    ...  Check NSA NR  Available
    ...  AND
    ...  Check SA NR  Active


_Get NR Type
    [Documentation]  To get NR cells type.

    ${nrbts_a}  Query Infomodel  get object //NRBTS_A-*

    [Return]  ${nrbts_a}[gNbCuType]


_Check All NR Cells To Be Enabled
    [Documentation]  To check all NR cells to be enabled.

    coam.Assert Every  NRCEL  administrativeState=${UNLOCKED}, operationalState=${ENABLED}  timeout=1s


Check NSA NR
    [Documentation]  To check X2 LTEENB link has given status.
    [Arguments]  ${link_status}

    ${link_status_lower}  Convert To Lowercase  ${link_status}
    ${lteenb}  Query Infomodel  get list //LTEENB_R-*
    FOR  ${element}  IN  @{lteenb}
        Should Be True  '${element.x2LinkStatus}'=='${link_status_lower}'  Status of X2 link is not correctly set to: ${element.x2LinkStatus}.
    END


Check SA NR
    [Documentation]  To check ngLink has given status.
    [Arguments]  ${ng_link_status}

    ${servedamf_r}  Query Infomodel  get object //SERVEDAMF_R-*
    Should Be True  '${servedamf_r}[ngLinkStatus]'=='${ng_link_status}'
    ...  Status of AMF ngLinkStatus is not correctly set to: ${servedamf_r}[ngLinkStatus].


Get Bts Name
    [Documentation]  This KW is getting the bts name.

    ${bts_info}  Get Bts Info

    [Return]  ${bts_info['name']}


Change ActCli Parameter
    [Documentation]  This KW is changing actCli parameter to a specific value.
    [Arguments]  ${value}  ${skip_parameter_relation_errors}=True

    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  actCli
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Run Keyword If  ${status}
    ...  Log  Parameter actCli is set to ${value}![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter actCli is not set to ${value}![NOK]


Admin CLI Send Request
    [Documentation]  Send command via Admin CLI, and return request status, error code and request message.
    [Arguments]  ${cli_message}  ${output_file}=${None}  ${return_value}=${None}  ${input_file}=${None}

    ${response}  Send Admin CLI Request  ${cli_message}  output_file=${output_file}  return_value=${return_value}  input_file=${input_file}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage

    [Return]  ${request_status}  ${error_code}  ${request_message}


Get Target BD Attribute Value From Active Partition
    [Documentation]
    ...  This keyword returns target BD attribute value
    ...  Argument example: swReleaseVersionPackageName
    ...  Return example: SBTS00_ENB_9999_221012_000004_release_BTSSM_downloadable_A54
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${attribute_name}

    Connect To SMOD  ${OAM_BTS_IP}
    ${ls_output}  ssh.Execute  ls /ffs/run
    ${target_bd}  Get Regexp Matches  ${ls_output}  TargetBD.*xml
    ${cat_output}  ssh.Execute  cat /ffs/run/${target_bd}[0] | grep ${attribute_name}
    ${sw_package_name}  Get Regexp Matches  ${cat_output}  ${attribute_name}="SBTS.*"
    ${sw_package_name}  Fetch From Left  ${sw_package_name}[0]  ${SPACE}
    ${sw_package_name}  Fetch From Right  ${sw_package_name}  ${attribute_name}="
    ${sw_package_name}  Fetch From Left  ${sw_package_name}  "

    [Return]  ${sw_package_name}


Collect Snapshot Via SSH
    [Documentation]
    ...  This keyword downloads snapshot via master or slave into ${BTS_FILES}
    ...  Argument example: ${BTS_FILES}  ${OAM_BTS_IP} / ${BTS_FILES}  192.168.255.119
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${download_location}  ${sm_ip}=${OAM_BTS_IP}

    Connect To SMOD  ${sm_ip}
    ${date_time}  Get Current Date  result_format=%Y_%m_%d_%H_%M
    ${name_snapshot}  Catenate  ${date_time}_snapshot.zip
    Log  Collecting snapshot started, from ${sm_ip}  console=true
    ssh.Send Command  nc localhost 15007 <<<"log -a -z /ffs/run/trs_data/db/${name_snapshot}" 2>/dev/null
    Log  Sent snapshot command to BTS  console=true
    Set Test Variable  ${CURRENT_ZIP_SIZE}  "1.0"
    Wait Until Keyword Succeeds  42min  6min
    ...  Check If SSH Snapshot Collection Is Over
    Log  Downloading snapshot from ${sm_ip}  console=true
    Wait Until Keyword Succeeds  40min  5min
    ...  ssh.Download File  /ffs/run/trs_data/db/${name_snapshot}  ${download_location}/${name_snapshot}
    ${ls_output}  ssh.Execute  ls /ffs/run/trs_data/db
    ${snapshot_files}  Get Regexp Matches  ${ls_output}  [0-9_]*snapshot.zip
    FOR  ${file}  IN  @{snapshot_files}
        ssh.Execute  rm -f /ffs/run/trs_data/db/${file}
    END
    ${ls_output}  ssh.Execute  ls /ffs/run/trs_data/db
    ${snapshot_files}  Get Regexp Matches  ${ls_output}  [0-9_]*snapshot.zip
    ${zip_number}  Get Length  ${snapshot_files}
    Run Keyword If  ${zip_number}==0
    ...  Log  Snapshot zips are deleted!  console=true
    ...  ELSE
    ...  Fail  Snapshot zips were not correctly deleted! Retrying to delete!


Check If SSH Snapshot Collection Is Over
    [Documentation]
    ...  This keyword checks repeatedly if the size of the zip file is still increasing
    ...  by comparing the current file size with the previous cycle's size, or, if it's
    ...  the first cycle, with the default value of 1.0

    ${prev_zip_size}  Set Variable  ${CURRENT_ZIP_SIZE}
    FOR  ${i}  IN RANGE  5
        ${output}  ssh.Execute  ls /ffs/run/trs_data/db -lh
        ${zip_size}  Get Regexp Matches  ${output}  ( [0-9.]*[A-Z] {1})
        ${zip_size}  Get Regexp Matches  ${zip_size}[-1]  [0-9.]+
        ${status}  Run Keyword And Return Status
        ...  Should Not Be Equal As Strings  ${zip_size}[-1]  ${CURRENT_ZIP_SIZE}
        Run Keyword If  ${status}
        ...  Set Test Variable  ${CURRENT_ZIP_SIZE}  ${zip_size}[-1]
        Sleep  60  Wait to check if zip size increased
    END
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Equal As Strings  ${prev_zip_size}  ${CURRENT_ZIP_SIZE}
    Run Keyword If  ${status}
    ...  Fail  Zip file is still increasing in size!
    ...  ELSE
    ...  Log  Snapshot collection done!  console=true


Download Directory
    [Documentation]  This keyword is used to download a specific directory.
    [Arguments]  ${sm_ip}  ${source_path}  ${dest_path}

    Connect To SMOD  ${sm_ip}
    ${directory}  Fetch From Right  ${source_path}  /
    ssh.Execute  tar cf ${directory}.tar -C ${source_path} .
    ssh.Download File  ${directory}.tar  ${dest_path}/${directory}.tar

    [Return]  ${dest_path}/${directory}.tar


Untar Archive
    [Documentation]  This keyword is used to untar archive.
    [Arguments]  ${tar_file}  ${dest_path}

    ${untarred_file}  Fetch From Left  ${tar_file}  .
    ${untarred_file}  Fetch From Right  ${untarred_file}  /
    ${status}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${dest_path}/${untarred_file}
    Run Keyword If  ${status}==${FALSE}
    ...  Run  mkdir ${dest_path}/${untarred_file}
    Run  tar -xvf ${tar_file} -C ${dest_path}/${untarred_file} .
    Run  rm -r ${tar_file}


Perform Dsp Crash
    [Documentation]  This keyword is used to perform dsp crash.
    [Arguments]  ${sm_ip}  ${dsp_id}

    Connect To SMOD  ${sm_ip}
    ssh.Execute  rioboot -c read -a 0x11800000 -n 0x1000000 ${dsp_id}
    Log  DSP with dsp_id ${dsp_id} crashed.  console=true


Verify Files From Given Path
    [Documentation]  This keyword is used verify files from given path.
    [Arguments]  ${sm_ip}  ${path}  ${obligatory_files}  ${optional_files}=${None}

    Connect To SMOD  ${sm_ip}
    ${ls_output}  ssh.Execute  ls ${path}
    ${files}  Split String  ${ls_output}  \r\n
    ${obligatory_files_not_exist}  Create List
    ${optional_files_not_exist}  Create List
    FOR  ${obligatory_file}  IN  @{obligatory_files}
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${files}  ${obligatory_file}
        Run Keyword If  ${status}==${FALSE}
        ...  Append To List  ${obligatory_files_not_exist}  ${obligatory_file}
    END
    Run Keyword If  ${obligatory_files_not_exist}
    ...  Run Keywords
    ...  Log  Obligatory files, which were not found: ${obligatory_files_not_exist}.  console=true
    ...  AND
    ...  Return From Keyword  ${FALSE}
    Run Keyword If  ${optional_files} is ${None}
    ...  Return From Keyword  ${TRUE}
    FOR  ${optional_file}  IN  @{optional_files}
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${files}  ${optional_file}
        Run Keyword If  ${status}==${FALSE}
        ...  Append To List  ${optional_files_not_exist}  ${optional_file}
    END
    Run Keyword If  ${optional_files_not_exist}
    ...  Log  Optional files, which were not found: ${optional_files_not_exist}.  console=true
    ...  ELSE
    ...  Log  All files were found.  console=true

    [Return]  ${TRUE}


Crash Container
    [Documentation]  This keyword is used to crash container.
    [Arguments]  ${fsp_ip}  ${node_id}  ${sm_ip}

    ${proxy}  Connect To SMOD  ${sm_ip}
    ${ps_aux}  Collect Pids  ${fsp_ip}  ${node_id}  ${proxy}
    ${process_id}  Get Pid  ${ps_aux}
    ssh.Execute  lxc-attach -n 0x${node_id} -- kill -9 ${process_id}
    ssh.Disconnect


Collect Pids
    [Documentation]  This keyword is used to collect pids.
    [Arguments]  ${fsp_ip}  ${node_id}  ${proxy}

    ${fsp_conn_output}  ssh.Connect To  ${fsp_ip}  toor4nsn  oZPS0POrRieRtu  proxy=${proxy}
    ${btssw_output}  ssh.Execute  lxc-attach -n 0x${node_id} ps aux | grep btssw

    [Return]  ${btssw_output}


Get Pid
    [Documentation]  This keyword is used to get pid.
    [Arguments]  ${output}

    ${btssw_matches}  Get Regexp Matches  ${output}  btssw\\s*\\d*
    ${length}  Get Length  ${btssw_matches}
    ${process_line}  Run Keyword If  ${length}>0
    ...  Split String  ${btssw_matches}[0]  ${SPACE}
    ...  ELSE
    ...  Set Variable  ${EMPTY}
    ${process_line_length}  Get Length  ${process_line}
    Run Keyword If  ${process_line_length}==0
    ...  Fail  PID of btssw was not obtained correctly.

    [Return]  ${process_line}[-1]


Connect To SMOD
    [Documentation]  This KW is connecting to MSM or ESM via taf.transport.ssh
    [Arguments]  ${sm_ip}  ${username}=toor4nsn  ${password}=oZPS0POrRieRtu

    ${proxy_connection}  Run Keyword If  '${sm_ip}'=='192.168.255.1' or '${sm_ip}'=='${OAM_BTS_IP}'
    ...  ssh.Connect To  hostname=${sm_ip}  username=${username}  password=${password}
    ...  ELSE
    ...  Connect To ESM  ${sm_ip}  ${username}  ${password}

    [Return]  ${proxy_connection}


Connect To ESM
    [Documentation]  If ESM is ASIL or ASIM the ssh connection will be performed through fct address.
    ...  Otherwise, 192.168.255.119 address is used.
    [Arguments]  ${sm_ip}  ${username}  ${password}

    ${harware_type}  ${fct}  Get Hardware Type And Fct Position For MSM
    ${msm_proxy}  ssh.Connect To  hostname=${OAM_BTS_IP}  username=${username}  password=${password}
    ${proxy_connection}  Run Keyword If  '${harware_type}'=='Flexi'
    ...  ssh.Connect To  ${sm_ip}  ${username}  ${password}  proxy=${msm_proxy}
    ...  ELSE
    ...  ssh.Connect To  ${fct}  ${username}  ${password}  proxy=${msm_proxy}

    [Return]  ${proxy_connection}


Get Hardware Type And Fct Position For MSM
    [Documentation]  This keyword is used to get hardware type and fct position for MSM.

    ${smods}  Get Ids For All  SMOD
    FOR  ${smod_dn}  IN  @{smods}
        ${parameters}  coam.Get Parameters  ${smod_dn}
        Run Keyword If  '${parameters}[activeRole]'!='Primary'
        ...  Exit For Loop
    END
    ${hardware_type}  Fetch From Left  ${parameters}[productName]  ${SPACE}
    ${fct}  Set Variable If  ${parameters}[horizontalPosition]==2  fct-4a  fct-0a

    [Return]  ${hardware_type}  ${fct}


Get StoredRole From MODULE_L
    [Documentation]  This keyword is used to get storedRole from MODULE_L.
    [Arguments]  ${module_l_dn}

    ${smod_dn_matches}  Get Regexp Matches  ${module_l_dn}  .*BTS_L-\\d
    ${smod_object}  coam.Get Parameters  ${smod_dn_matches}[0]

    [Return]  ${smod_object}[storedRole]


Get SMOD_R Dist_name From SMOD_L
    [Documentation]
    ...  This kewyord returns SMOD_R dist_name from SMOD_L object.
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${smod_l_dn}

    ${smod_l_parameters}  Get Parameters For  SMOD  ${smod_l_dn}
    ${smod_l_serial_number}  Set Variable  ${smod_l_parameters}[serialNumber]
    ${smods_list}  Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
        Run Keyword If  '${smod}[serialNumber]'=='${smod_l_serial_number}'
        ...  Return From Keyword  ${smod}[id][internal]
    END


Open Connection To Primary Core
    [Documentation]
    ...  This keyword opens ssh connection to primary core.

    Log  \nOpening connection to primary core.  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=primary_ssh  width=200
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]


Open Connection To Secondary Core
    [Documentation]
    ...  In this keyword SMOD type is verified in order to connect to secondary core.
    ...  If SMOD is other than ASIL/ASIM, connection to secondary core is opened with 192.168.255.119
    ...  If SMOD is ASIL/ASIM, connection to secondary core is opened with fct-0a or fct-4a address
    ...  *AUTHOR* andrada.baleti@nokia.com

    Log  Opening connection to secondary core.  console=true
    ${fsm_info_list}  Get Fsm Info
    FOR  ${fsm_info}  IN  @{fsm_info_list}
        Run Keyword If  '${fsm_info}[activeRole]'=='Secondary' and ('FSMF' in '${fsm_info}[productName]')
        ...  Connect To Secondary Core FSMF
        ...  ELSE IF  '${fsm_info}[activeRole]'=='Secondary'
        ...  Connect To Secondary  ${fsm_info}[positionInSubrack]
    END


Connect To Secondary Core FSMF
    [Documentation]  This keyword is used to connect to secondary core FSMF.

    SSHLibrary.Open Connection  192.168.255.7  prompt=:~ >  alias=secondary_ssh
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]  jumphost_index_or_alias=primary_ssh


Connect To Secondary
    [Documentation]  This keyword is used to connect to secondary.
    [Arguments]  ${fct_position}

    ${positions}  Create Dictionary  LeftSide=0  RightSide=4
    SSHLibrary.Open Connection  fct-${positions}[${fct_position}]a  prompt=:~ >  alias=secondary_ssh  width=200
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]  jumphost_index_or_alias=primary_ssh


Open Connection To SOC
    [Documentation]
    ...  This keyword opens connection to SOC
    ...  SSH connection primary/secondary core must be established before.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${bbmod_position}  ${soc_position}  ${prompt}=REGEXP:(#|>)  ${device_name}=${EMPTY}

    SSHLibrary.Set Client Configuration  prompt=${prompt}
    SSHLibrary.Write  chk sysbshtopo
    Sleep  10  Needed to load the output.
    ${bbmod_access_points}  SSHLibrary.Read Until Prompt
    IF  '${device_name}' == '${EMPTY}'
        ${bbmod}  Get Lines Containing String  ${bbmod_access_points}  ${bbmod_position}:${soc_position}
        ${address}  Get Regexp Matches  ${bbmod}  fsp(-..|.{4}com)
    ELSE
        ${matched_line}  Get Regexp Matches  ${bbmod_access_points}  ${bbmod_position}:${soc_position}\\s\\s\\(fsp(-.${device_name}|.{4}com)\\)
        ${address}  Get Regexp Matches  ${matched_line}[0]  fsp(-.${device_name}|.{4}com)
    END
    SSHLibrary.Write  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null toor4nsn@${address}[0]
    # -o StrictHostKeyChecking=no       do not check host key
    # -o UserKnownHostsFile=/dev/null   do not save host key
    SSHLibrary.Read Until Regexp  (P|p)assword:
    SSHLibrary.Write  oZPS0POrRieRtu
    SSHLibrary.Read Until Prompt


Check Alarm Status In WebEM
    [Documentation]  This keyword is used to check alarm status in WebEM.
    [Arguments]  ${alarm_status}  ${fault_id}  ${fault_name}  ${alarm_id}  ${alarm_name}  ${severity}  ${timeout}=60  ${fail_operation}=Fail

    ${alarm_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=${fault_id},  faultName="${fault_name}",  alarmId=${alarm_id},
    ...  alarmName="${alarm_name}",  severity=${severity}
    ${status}  Run Keyword And Return Status
    ...  Assert Alarm ${alarm_status}  parameters=${alarm_parameters}  timeout=${timeout}
    Run Keyword If  ${status}
    ...  Log  Alarm ${alarm_id} with fault id ${fault_id} with severity ${severity} is ${alarm_status} WebEM.  console=true
    ...  ELSE
    ...  ${fail_operation}  Alarm is not ${alarm_status} in WebEM.


Check If Target Is Stable
    [Documentation]  This keyword is used to check if target is stable.
    [Arguments]
    ...  ${ip}
    ...  ${min_uptime}=300
    ...  ${max_downtime}=300
    ...  ${timeout}=900
    ...  ${remote_host}=None
    ...  ${remote_host_username}=ute
    ...  ${remote_host_password}=ute

    ${ip_addresses}  Create List  ${ip}
    ${initial_time}  BuiltIn.Get Time  UTC
    ping.Wait For Ping  ip_addresses=${ip_addresses}  timeout=${max_downtime}  remote_host_ip=${remote_host}
    ...  remote_host_username=${remote_host_username}  remote_host_password=${remote_host_password}
    ${ping_down_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_addresses}
    ...  timeout=${min_uptime}
    ...  remote_host_ip=${remote_host}
    ...  remote_host_username=${remote_host_username}
    ...  remote_host_password=${remote_host_password}
    Run Keyword If  ${ping_down_status}
    ...  Fail  Target is not stable. Ping is down [NOK]
    ${end_time}  BuiltIn.Get Time  UTC
    ${time}  Subtract Date From Date  ${end_time}  ${initial_time}
    Run Keyword If  ${time}>${timeout}
    ...  Fail  Check if target is stable didn't pass in ${timeout}s! [NOK]

    [Return]  ${TRUE}


Get Value Of Restart Counter
    [Documentation]  This KW gets value of restart counter.

    ${smod_object}  coam.Get Parameters  /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1  timeout=60
    ${counter}  Get From Dictionary  ${smod_object}  restartCounter

    [Return]  ${counter}


Wait For Target To Be Reachable
    [Documentation]
    ...  Waits for target IP to be reachable by ping
    ...
    ...  *INPUT*
    ...  | Parameter              | Mandatory | Description                                        |
    ...  | hostname               | Yes       | Target IP, if more items separated by comma        |
    ...  | timeout                | No        | Time in seconds to wait for target to be reachable |
    ...  | remote_host            | No        | Remote host IP if ping should be proceeded from it |
    ...  | remote_host_username   | No        | Username for remote host authentication            |
    ...  | remote_host_password   | No        | Password for remote host authentication            |
    [Arguments]  ${hostname}  ${timeout}=200  ${remote_host}=None  ${remote_host_username}=ute  ${remote_host_password}=ute

    ${ip_addresses}  Create List  ${hostname}
    ${ping_status}  ${ping_response}  Run Keyword And Ignore Error
    ...  ping.Wait For Ping  ip_addresses=${ip_addresses}
    ...  timeout=${timeout}
    ...  remote_host_ip=${remote_host}
    ...  remote_host_username=${remote_host_username}
    ...  remote_host_password=${remote_host_password}
    Should Be Equal  ${ping_status}  PASS  ${ping_response}


Wait For Target To Be Not Reachable
    [Documentation]
    ...  Waits for target IP to be not reachable by ping
    ...
    ...  *INPUT*
    ...  | Parameter              | Mandatory | Description                                            |
    ...  | hostname               | Yes       | Target IP, if more items separated by comma            |
    ...  | timeout                | No        | Time in seconds to wait for target to be not reachable |
    ...  | remote_host            | No        | Remote host IP if ping should be proceeded from it     |
    ...  | remote_host_username   | No        | Username for remote host authentication                |
    ...  | remote_host_password   | No        | Password for remote host authentication                |
    [Arguments]  ${hostname}  ${timeout}=200  ${remote_host}=None  ${remote_host_username}=ute  ${remote_host_password}=ute

    ${ip_addresses}  Create List  ${hostname}
    ${no_ping_status}  ${no_ping_response}  Run Keyword And Ignore Error
    ...  ping.Wait For No Ping  ip_addresses=${ip_addresses}
    ...  timeout=${timeout}
    ...  remote_host_ip=${remote_host}
    ...  remote_host_username=${remote_host_username}
    ...  remote_host_password=${remote_host_password}
    Should Be Equal  ${no_ping_status}  PASS  ${no_ping_response}


Verify Alarm In RawAlarmHistory File
    [Documentation]
    ...  This keyword verifies a specific fault to appear in RawAlarmHistory file.
    ...  current_date_time can be obtained with "Get current date" keyword before using this keyword
    ...  and it's format must be: %Y-%b-%d %H:%M:%S
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${fault_number}  ${current_date_time}  ${module_r_dn}=${None}  ${alarm_status}=active  ${additional_fault_name}=${None}

    Log  Verifying alarm with fault ${fault_number} to appear in RawAlarmHistory file - ${alarm_status}.  console=true
    Sleep  60s  Waiting one minute for alarm to appear in RawAlarmHistory.
    ${status}  ${file_content}  Run Keyword And Ignore Error  Get Raw Alarm History File  timeout=60
    IF  '${status}'=='FAIL'
      Collect Raw Alarm History File  target_file_name=${BTS_FILES}/RawAlarmHistory.txt
      ${file_content}  OperatingSystem.Get File  ${BTS_FILES}/RawAlarmHistory.txt
    END
    IF  '${alarm_status}' == 'active'
      ${faults_content}  Fetch From Left  ${file_content}  Inactive faults
    ELSE IF  '${alarm_status}' == 'inactive'
      ${faults_content}  Fetch From Right  ${file_content}  Inactive faults
    ELSE IF  '${alarm_status}' == 'all'
      ${faults_content}  Set Variable  ${file_content}
    ELSE
        Fail  Undefined alarm_status, options are: active, inactive, all.
    END
    ${file_content_fault}  Get Lines Containing String  ${faults_content}  ${fault_number}
    Should Not Be Empty  ${file_content_fault}  Alarm did not appear in RawAlarmHistory file - [NOK].
    ${date_time_matches}  Get Regexp Matches  ${file_content_fault}  [0-9]+-[a-zA-Z]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+
    ${alarm_counter}  Set Variable  0
    ${found_alarms}  Create List
    FOR  ${fault_time}  IN  @{date_time_matches}
        ${line_regex}  Get Lines Containing String  ${file_content_fault}  ${fault_time}
        ${module_status}  IF  $module_r_dn is $None  Set Variable  ${TRUE}
        ...  ELSE  Run Keyword And Return Status  Should Contain  ${line_regex}  ${module_r_dn}
        ${additional_fault_name_status}  IF  $additional_fault_name is $None  Set Variable  ${TRUE}
        ...  ELSE  Run Keyword And Return Status  Should Contain  ${line_regex}  ${additional_fault_name}
        IF  '''${fault_time}'''>'''${current_date_time}''' and ${module_status} and ${additional_fault_name_status}
          ${alarm_counter}  Evaluate  ${alarm_counter} + 1
          Append To List  ${found_alarms}  ${line_regex}
        END
    END
    IF  ${alarm_counter}!=0
      Log  Alarm with fault ${fault_number} is present in RawAlarmHistory file.  console=true
      Log  Alarms found:\n  console=true
      FOR  ${alarm}  IN  @{found_alarms}
          Log  \t${alarm}  console=true
      END
    ELSE
      Fail  Alarm with fault ${fault_number} did not appear in RawAlarmHistory file.
    END

    RETURN  ${found_alarms}


Verify Output Of Get Suppressed Alarms
    [Documentation]
    ...  This keyword verifies output of Get Suppressed Alarms from WemEM.
    ...  This keyword will search for a specific fault to be in active suppresed alarms.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_number}  ${module_r_dn}=${None}

    Log  Verifying alarm with fault ${fault_number} is in curentlly suprressed alarm from Get Suppressed Alarms output.  console=true
    Collect Suppressed Alarm History File  ${BTS_FILES}/SuppressedAlarm.txt  timeout=240
    File Should Not Be Empty  ${BTS_FILES}/SuppressedAlarm.txt
    ${file_content}  OperatingSystem.Get File  ${BTS_FILES}/SuppressedAlarm.txt
    ${file_content_fault}  Get Lines Containing String  ${file_content}  ${fault_number}
    ${status_fault}  Run Keyword And Return Status  Should Not Be Empty  ${file_content_fault}
    IF  ${status_fault}==${FALSE}
      Fail  Alarm with fault ${fault_number} did not appear in curentlly suprressed alarm from Get Suppressed Alarms output - [NOK].
    ELSE
      Log  Alarm with fault ${fault_number} is present in curentlly suprressed alarm from Get Suppressed Alarms output. [OK]  console=true
    END
    IF  ${module_r_dn} is not $None  Should Contain  ${file_content_fault}  ${module_r_dn}


Verify Alarm In RawSuppressedAlarmHistory File
    [Documentation]
    ...  This keyword verifies a specific fault to appear in RawSuppressedAlarmHistory file.
    ...  current_date_time can be obtained with "Get current date" keyword and the format must be: %Y-%m-%d %H:%M:%S
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_number}  ${current_date_time}  ${module_r_dn}=${None}  ${alarm_status}=active

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  encoding=unicode_escape
    SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Get File  /ram/RawSuppressedAlarmHistory.txt  ${BTS_FILES}/RawSuppressedAlarmHistory.txt
    ${file_content}  OperatingSystem.Get File  ${BTS_FILES}/RawSuppressedAlarmHistory.txt
    IF  '${alarm_status}'=='active'
      Log  Verifying alarm with fault ${fault_number} to appear in RawSuppressedAlarmHistory file - active.  console=true
    ELSE IF  '${alarm_status}'=='inactive'
      Log  Verifying alarm with fault ${fault_number} to appear in RawSuppressedAlarmHistory file - inactive.  console=true
    ELSE
      Fail  Invalid alarm_status for keyword.
    END
    ${faults_content}  IF  '${alarm_status}'=='active'  Fetch From Left  ${file_content}  Cancelled alarms
    ...  ELSE  Fetch From Right  ${file_content}  Cancelled alarms
    ${file_content_fault}  Get Lines Containing String  ${faults_content}  ${fault_number}
    ${status_fault}  Run Keyword And Return Status  Should Not Be Empty  ${file_content_fault}
    IF  ${status_fault}==${FALSE}  Fail  Alarm did not appear in RawSuppressedAlarmHistory file - [NOK].
    ${date_time_matches}  Get Regexp Matches  ${file_content_fault}  [0-9]+-[0-9]+-[0-9]+[a-zA-Z]+[0-9]+:[0-9]+:[0-9]+
    ${alarm_counter}  Set Variable  0
    ${found_alarms}  Create List
    FOR  ${match}  IN  @{date_time_matches}
        ${line_regex}  Get Lines Containing String  ${file_content_fault}  ${match}
        ${fault_time}  Replace String  ${match}  T  ${SPACE}
        ${module_status}  IF  $module_r_dn is $None  Set Variable  ${TRUE}
        ...  ELSE  Run Keyword And Return Status  Should Contain  ${line_regex}  ${module_r_dn}
        IF  '''${fault_time}'''>'''${current_date_time}''' and '${module_status}'!='False'
          ${alarm_counter}  Evaluate  ${alarm_counter} + 1
          Append To List  ${found_alarms}  ${line_regex}
        ELSE
          ${alarm_counter}  Evaluate  ${alarm_counter} + 0
        END
    END
    IF  ${alarm_counter}!=0
      Log  Alarm with fault ${fault_number} is present in RawSuppressedAlarmHistory file - [OK]  console=true
      Log  Alarms found:\n  console=true
      FOR  ${alarm}  IN  @{found_alarms}
          Log  \t${alarm}  console=true
      END
    ELSE
      Fail  Alarm did not appear in RawSuppressedAlarmHistory file - [NOK].
    END

    [Teardown]  SSHLibrary.Close Connection


Verify Alarm In Blackbox RawSuppressedAlarmHistory File
    [Documentation]
    ...  This keyword verifies a specific fault to appear in blackbox_RawSuppressedAlarmHistory.txt file.
    ...  current_date_time can be obtained with "Get current date" keyword and the format must be: %Y-%m-%d %H:%M:%S
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_number}  ${current_date_time}  ${module_r_dn}=${None}  ${alarm_status}=active

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  encoding=unicode_escape
    SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Get File  /ffs/run/logs/lifetimedata/blackbox_RawSuppressedAlarmHistory.txt  ${BTS_FILES}/blackbox_RawSuppressedAlarmHistory.txt
    ${file_content}  OperatingSystem.Get File  ${BTS_FILES}/blackbox_RawSuppressedAlarmHistory.txt
    IF  '${alarm_status}'=='active'
        Log  Verifying alarm with fault ${fault_number} to appear in blackbox_RawSuppressedAlarmHistory file - active.  console=true
    ELSE IF  '${alarm_status}'=='inactive'
        Log  Verifying alarm with fault ${fault_number} to appear in blackbox_RawSuppressedAlarmHistory file - inactive.  console=true
    ELSE
        Fail  Invalid alarm_status for keyword.
    END
    ${faults_content}  IF  '${alarm_status}'=='active'  Fetch From Left  ${file_content}  Cancelled alarms
    ...  ELSE  Fetch From Right  ${file_content}  Cancelled alarms
    ${file_content_fault}  Get Lines Containing String  ${faults_content}  ${fault_number}
    ${status_fault}  Run Keyword And Return Status  Should Not Be Empty  ${file_content_fault}
    IF  ${status_fault}==${FALSE}  Fail  Alarm did not appear in blackbox_RawSuppressedAlarmHistory file - [NOK].
    ${date_time_matches}  Get Regexp Matches  ${file_content_fault}  [0-9]+-[0-9]+-[0-9]+[a-zA-Z]+[0-9]+:[0-9]+:[0-9]+
    ${alarm_counter}  Set Variable  0
    ${found_alarms}  Create List
    FOR  ${match}  IN  @{date_time_matches}
        ${line_regex}  Get Lines Containing String  ${file_content_fault}  ${match}
        ${fault_time}  Replace String  ${match}  T  ${SPACE}
        ${module_status}  IF  $module_r_dn is $None  Set Variable  ${TRUE}
        ...  ELSE  Run Keyword And Return Status  Should Contain  ${line_regex}  ${module_r_dn}
        IF  '''${fault_time}'''>'''${current_date_time}''' and '${module_status}'!='False'
            ${alarm_counter}  Evaluate  ${alarm_counter} + 1
            Append To List  ${found_alarms}  ${line_regex}
        ELSE
            ${alarm_counter}  Evaluate  ${alarm_counter} + 0
        END
    END
    IF  ${alarm_counter}!=0
        Log  Alarm with fault ${fault_number} is present in blackbox_RawSuppressedAlarmHistory file - [OK]  console=true
        Log  Alarms found:\n  console=true
        FOR  ${alarm}  IN  @{found_alarms}
            Log  \t${alarm}  console=true
        END
    ELSE
        Fail  Alarm did not appear in blackbox_RawSuppressedAlarmHistory file - [NOK].
    END

    [Teardown]  SSHLibrary.Close Connection


Get BTS Time In UTC Format
    [Documentation]
    ...  This keyword returns BTS time in UTC format.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${result_format}

    ssh.Connect To  ${OAM_BTS_IP}  toor4nsn  oZPS0POrRieRtu  alias=get_time
    ${sbts_time}  ssh.Execute  date "+${result_format}"  connection=get_time
    ${time}  Replace String Using Regexp  ${sbts_time}  [\r\n]  ${EMPTY}

    RETURN  ${time}
    [Teardown]  ssh.Disconnect  connection=get_time


Get Module Dist Name By Serial Number And Class
    [Documentation]
    ...  This keyword returns module dist name by module serial number and class.
    ...  E.g. Get module dist name by serial number and class  ${rmod_serial_number}  RMOD
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${module_serial_number}  ${module_class}

    ${modules_parameters}  Get Parameters For All  ${module_class}
    FOR  ${module_parameters}  IN  @{modules_parameters}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${module_parameters}[serialNumber]  ${module_serial_number}
        Run Keyword If  ${status}
        ...  Return From Keyword  ${module_parameters}[id]
    END


Check Parameters Status For Cells
    [Documentation]
    ...  This keyword checks parameters for cells with Assert keyword.
    ...  The cells list must be a list of cell dist names(Get cell mapping by module id is recommended to be used).
    ...  E.g. Check parameters status for cells  ${LTE_CELLS}  operationalState=${DISABLED_}, availabilityStatus=${FAILED_}
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${cells_list}  ${parameters}

    FOR  ${cell_id}  IN  @{cells_list}
        ${cell_class_name}  Get Regexp Matches  ${cell_id}  [A-Z]{2}CEL
        Assert  ${cell_class_name}[0]  id=${cell_id}  parameters=${parameters}  timeout=60s
    END


Get Random RMOD Serial Number By Given RMOD Type
    [Documentation]
    ...  This kw finds the first RMOD that matches the RMOD type or given regex.
    ...  Example of usage:
    ...  Get RMOD serial number by RMOD type  FRGY
    ...  OR
    ...  Get RMOD serial number by RMOD type  ^F[A-Z]{3,4}
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${rmod_type}

    ${rmods_info}  Get Frm
    FOR  ${rmod}  IN  @{rmods_info}
        ${product_name_match}  Get Regexp Matches  ${rmod}[productName]  ${rmod_type}
        ${status}  Run Keyword And Return Status
        ...  Should Not Be Empty  ${product_name_match}
        Run Keyword If  ${status}
        ...  Return From Keyword  ${rmod}[serialNumber]
    END
    Fail  Given RMOD type not found on SBTS. [NOK]


Perform Software Rollback And Check BTS State
    [Documentation]
    ...  This kw performs software rollback and checks if SBTS is up after.
    ...  Example of usage:
    ...  Perform software rollback and check BTS state  30m
    ...                                       10m
    ...                                       10m
    [Arguments]  ${restore_timeout}  ${ping_loss_timeout}  ${ping_regain_timeout}  ${check_cells}=${TRUE}

    Log  Perform software rollback and check BTS state.  console=true
    ${software_info}  Get Software Info
    Log  Active software version before rollback is: ${software_info}[Active SW version]  console=true
    Log  Pasive software version before rollback is: ${software_info}[Passive SW version]  console=true
    ${rollback_status}  Run Keyword And Return Status
    ...  Rollback Software
    Run Keyword If  ${rollback_status}==${FALSE}
    ...  Fail  Software rollback was not performed. [NOK]
    Log  Software rollback performed successfully. [OK]  console=true
    Log  Will wait for ping loss.  console=true
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${ping_loss_timeout}
    Run Keyword If  ${ping_loss_status}
    ...  Log  BTS is resetting after successful rollback. [OK]  console=true
    ...  ELSE
    ...  Fail  BTS RESET after successful rollback DID NOT OCCUR. [NOK]
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${ping_regain_timeout}
    Run Keyword If  ${ping_regain_status}
    ...  Log  Ping regained after successful rollback. [OK]  console=true
    ...  ELSE
    ...  Fail  Ping has not been regained within timeout. [NOK]
    Wait Until Keyword Succeeds  5m  30  Reset Admin
    Teardown Infomodel
    Start Infomodel
    Log  Will wait for modules and cells to be on air.  console=true
    Wait Until Keyword Succeeds  ${restore_timeout}  30s
    ...  Check Modules And Cells  check_cells=${check_cells}
    Log  Modules and cells are up after rollback. [OK]  console=true


Check Active And Pasive Software Versions To Be Set Correctly
    [Documentation]
    ...  This kw checks if there are certain software versions on active and pasive partitions.
    ...  It is mainly used after rollback.
    ...  Example of usage:
    ...  Check active and pasive software versions to be set correctly  SBTS23R4_ENB_0000_000473_000000
    ...                                                       SBTS24R1_ENB_9999_231001_000016
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${sw_version_1}  ${sw_version_2}

    ${software_info}  Get Software Info
    Should Be Equal As Strings  ${software_info}[Active SW version]  ${sw_version_1}  Active software version should be: ${sw_version_1}. [NOK]
    Should Be Equal As Strings  ${software_info}[Passive SW version]  ${sw_version_2}  Pasive software version should be: ${sw_version_2}. [NOK]
    Log  Active and pasive sofware versions were set correctly. [OK]  console=true


Change Parameter EnforcedRecovTimeWindow
    [Documentation]
    ...  This kw changes enforcedRecovTimeWindow parameter value.
    ...  Returns a message if the parameter has already the desired value, or if it was changed successfully.
    ...  Example of usage:
    ...  Change parameter enforcedRecovTimeWindow  10718
    ...                                  Enforced recovery enabled within 0 - 90 minutes
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${bts_id}  ${parameter_value}

    ${featcadm_dn}  Set Variable  /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${bts_id}/MNL_A-1/MNLENT_A-1/FEATCADM_A-1
    ${featcadm_object}  Query Infomodel  get object ${featcadm_dn}
    ${parameter_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${featcadm_object}[enforcedRecovTimeWindow]  ${parameter_value}
    Run Keyword If  ${parameter_status}
    ...  Run Keywords
    ...  Log  Parameter enforcedRecovTimeWindow has alreadly the desired value: "${parameter_value}", no need to change. [OK]  console=true
    ...  AND
    ...  Return From Keyword
    Perform Parameter Recommissioning  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  parameter=enforcedRecovTimeWindow  operation=update
    ...  value=${parameter_value}  skip_parameter_relation_errors=${True}  should_activate=${True}  timeout=180
    ${featcadm_object}  Query Infomodel  get object ${featcadm_dn}
    Should Be Equal As Strings  ${featcadm_object}[enforcedRecovTimeWindow]  ${parameter_value}
    ...  Didn't manage to change enforcedRecovTimeWindow value to: "${parameter_value}". [NOK]
    Log  Parameter enforcedRecovTimeWindow changed to: "${parameter_value}". [OK]  console=true


Get Random RMOD Details By Given RMOD Type, BBMODs List And Accepted Cells List
    [Documentation]
    ...  This kw finds given type RMOD that is mapped on one or two of the given type BBMODs.
    ...  The given cells list indicates that the BBMODs must have only those types of cells mapped on them.
    ...  The kw is used with "Search for BBMODs in CABLINK list and verify them" kw.
    ...  Example of usage:
    ...  Get random RMOD details by given RMOD type, BBMODs list and accepted cells list  FRGY
    ...                                                                         ABIA  ABIO
    ...                                                                         NR  LTE
    ...  It returns serial number and BBMODs dist names.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${rmod_type}  ${bbmod_list}  ${accepted_cells_list}

    ${rmods_info}  Get Frm
    FOR  ${rmod}  IN  @{rmods_info}
        ${product_name_match}  Get Regexp Matches  ${rmod}[productName]  ${rmod_type}
        ${rmod_status}  Run Keyword And Return Status
        ...  Should Not Be Empty  ${product_name_match}
        ${bbmods_status}  ${bbmods_list}  Search For BBMODs In CABLINK List And Verify Them  ${rmod}[id][internal]  ${bbmod_list}
        ...  ${accepted_cells_list}
        Run Keyword If  ${rmod_status} and ${bbmods_status}
        ...  Return From Keyword  ${rmod}[serialNumber]  ${bbmods_list}
    END
    Fail  ${rmod_type} RMOD that is mapped on one of following BBMODs: ${bbmod_list}, not found on SBTS. [NOK]


Search For BBMODs In CABLINK List And Verify Them
    [Documentation]
    ...  This kw finds BBMODs that the RMOD is mapped on.
    ...  The BBMODs must fulfil the following rules: type and cells mapped on them must be from the given lists.
    ...  The rules are verified with "Verify BBMOD type and mapped cells" kw.
    ...  Example of usage:
    ...  Search for BBMODs in CABLINK list and verify them  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...                                           ABIA  ABIO
    ...                                           NR
    ...  It returns the status and BBMODs dist names.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${rmod_dn}  ${bbmod_list}  ${accepted_cells_list}

    ${cablink_r_list}  Query Infomodel  get list //CABLINK_R-*
    ${founded_bbmods_list}  Create List
    FOR  ${cablink}  IN  @{cablink_r_list}
        ${rmod_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${rmod_dn}  ${cablink}[secondEndpointDN]
        Run Keyword If  ${rmod_status}
        ...  Append To List  ${founded_bbmods_list}  ${cablink}[firstEndpointDN]
    END
    FOR  ${bbmod_dn}  IN  @{founded_bbmods_list}
        ${bbmod_status}  Run Keyword And Return Status
        ...  Verify BBMOD Type And Mapped Cells  ${bbmod_dn}  ${bbmod_list}  ${accepted_cells_list}
        Run Keyword If  ${bbmod_status}==${FALSE}
        ...  Return From Keyword  ${FALSE}  ${None}
    END

    [Return]  ${TRUE}  ${founded_bbmods_list}


Verify BBMOD Type And Mapped Cells
    [Documentation]
    ...  This kw verifies if certain BBMOD's type and mapped cells are from given lists.
    ...  Example of usage:
    ...  Verify BBMOD type and mapped cells  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-2
    ...                            ABIA  ABIO
    ...                            NR
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${bbmod_r_dn}  ${bbmod_list}  ${accepted_cells_list}

    ${bbmod_ref}  Query Infomodel  get object ${bbmod_r_dn}/REF-*
    ${bbmod_l_obj}  Query Infomodel  get object ${bbmod_ref}[distName]
    ${bbmod_product_name}  Fetch From Left  ${bbmod_l_obj}[productName]  ${SPACE}
    ${bbmod_type_status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${bbmod_list}  ${bbmod_product_name}
    Run Keyword If  ${bbmod_type_status}==${FALSE}
    ...  Fail  Founded BBMOD type: ${bbmod_product_name}, should be only: ${bbmod_list}. [NOK]
    ${mapped_cells_on_bbmod}  Infomodel Get Cells Deployed On Module  ${bbmod_l_obj}
    FOR  ${cell}  IN  @{mapped_cells_on_bbmod}
        List Should Contain Value  ${accepted_cells_list}  ${cell}[rat]
        ...  Founded cell type: ${cell}[rat], should be only: ${accepted_cells_list}. [NOK]
    END


Check Parameters Status For List Of BBMODs
    [Documentation]
    ...  This keyword checks parameters for BBMODs with Assert keyword.
    ...  The bbmods list must be a list of bbmods dist names from runtime.
    ...  E.g. Check parameters status for list of BBMODs  ${BBMODS_SN_LIST}  operationalState=${DISABLED_}, availabilityStatus=${FAILED_}
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${bbmods_serial_numbers_list}  ${parameters}

    ${bbmod_parameters}  Get Parameters For All  BBMOD
    FOR  ${bbmod}  IN  @{bbmod_parameters}
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${bbmods_serial_numbers_list}  ${bbmod}[serialNumber]
        IF  ${status}  Assert  BBMOD  ${bbmod}[id]  parameters=${parameters}
    END


Check Parameters Status For RMOD
    [Documentation]
    ...  This keyword checks parameters for RMOD with Assert keyword.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${rmod_serial_number}  ${parameters}

    ${rmod_parameters}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_parameters}
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${rmod_serial_number}  ${rmod}[serialNumber]
        IF  ${status}  Assert  RMOD  ${rmod}[id]  parameters=${parameters}
    END


Get String With Alarm Parameters
    [Documentation]  This KW is returning one string obtained from alarm parameters dictionary.
    ...  *AUTHOR* andrada-lavinia.baleti@nokia.com
    [Arguments]  ${alarm_dict}

    ${new_keys}  Create Dictionary  fault_id=faultId  fault_name=faultName  alarm_id=alarmId  alarm_name=alarmName  severity=severity
    ${string}  Set Variable  ${EMPTY}
    FOR  ${param}  IN  @{alarm_dict}
        ${param_value}  Run Keyword If  '${param}'=='fault_name' or '${param}'=='alarm_name'
        ...  Catenate  SEPARATOR=  "  ${alarm_dict}[${param}]  "
        ...  ELSE
        ...  Set Variable  ${alarm_dict}[${param}]
        ${string}  Catenate  ${string}  ${new_keys}[${param}]=${param_value},
    END
    ${string}  Get Substring  ${string}  1  -1

    [Return]  ${string}


Check NetBoot Variable
    [Documentation]
    ...  This keyword is used for tests executions from UTE Cloud.
    ...  It checks if netboot variable is set.
    ...  If netboot variable is found, it is deleted.
    ...  If it's not found, test execution continues.
    ...  *AUTHOR* anna.benzar@nokia.com

    ssh.Connect To  hostname=${OAM_BTS_IP}  username=toor4nsn  password=oZPS0POrRieRtu
    ${command_output}  ssh.Execute  uboot_env get netboot
    ${netboot_not_found}  Run Keyword And Return Status  Should Contain  ${command_output}  not found
    IF  ${netboot_not_found}
        Log  netboot already deleted.  console=true
        RETURN
    END
    ${netboot_exists}  Run Keyword And Return Status  Should Contain  ${command_output}  netboot_first
    ${deletion_output}  IF  ${netboot_exists}  ssh.Execute  uboot_env del netboot
    ${netboot_deleted}  Run Keyword And Return Status  Should Contain  ${deletion_output}  Deleted netboot
    IF  ${netboot_deleted}
        Log  netboot deleted successfully.  console=true
    ELSE
        Set Test Restriction  Didn't manage to delete netboot variable.
    END


Download And Check Software Package
    [Documentation]  This keyword is used to download and check software package.
    [Arguments]  ${software_version}  ${download_location}  ${type}=A54

    ${sw_package}  ${page}  Create Artifactory Links  ${software_version}  ${type}
    ${sw_package_path_on_server}  Catenate  SEPARATOR=  https://artifactory-espoo2.int.net.nokia.com/artifactory/
    ...  mn-cosi-sran-central-public-local/build/${page}/
    ...  ${software_version}/${sw_package}
    ${wget_rc}  Run And Return Rc  wget ${sw_package_path_on_server} -P ${download_location}
    IF  '${wget_rc}' == '0'  RETURN
    ${release_name}  Fetch From Left  ${software_version}  _
    ${sw_package_path_on_server}  Catenate  SEPARATOR=  https://es-si-s3-z2.eecloud.nsn-net.net/lterel/build/  ${release_name}/${sw_package}
    ${wget_rc}  Run And Return Rc  wget ${sw_package_path_on_server} -P ${download_location}
    IF  '${wget_rc}' != '0'
      Fatal Error  ${software_version} was not downloaded in ${download_location}.
    END

Create Artifactory Links
    [Arguments]  ${software_version}  ${type}=A54
    IF  'FDSW' in '${software_version}'
      ${type}  Set Variable  ${EMPTY}
      ${page}  Get Regexp Matches  ${software_version}  FDSW\\d{2}.*_[A-Z]{4}
      ${page}  Set Variable  ${page}[0]
    ELSE
      ${type}  Set Variable  _${type}
      ${release_name}  Fetch From Left  ${software_version}  _
      ${is_fsm3}  Set Variable If  'FSM3' in '${software_version}'  _FSM3  ${EMPTY}
      ${page}  Set Variable  ${release_name}${is_fsm3}
    END
    ${sw_package}  Set Variable  ${software_version}_release_BTSSM_downloadable${type}.zip
    RETURN  ${sw_package}  ${page}


Change FEATCADM Parameter
    [Documentation]  KW to change any FEATCADM parameter
    [Arguments]  ${parameter}  ${value}  ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=300

    Log  FEATCADM Parameter ${parameter} will be changed to ${value}.  console=true
    ${featcadm_object}  Query Infomodel  get object //FEATCADM_CONF_M-*
    ${actual_value}  Convert To String  ${featcadm_object}[${parameter}]
    ${actual_value}  Convert To Lowercase  ${actual_value}
    Run Keyword If  '${actual_value}'=='${value}'
    ...  Run Keywords
    ...  Log  Parameter already has the requested value. Parameter change will be skipped.  console=true
    ...  AND
    ...  Return From Keyword
    Log  Current parameter value ${actual_value}.  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=${parameter}  operation=update  value=${value}
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}  timeout=${timeout}


Verify Swconfig.Txt File And Delete Flag If Needed
    [Documentation]
    ...  This keyword is used to verify if a certain flag exists in swconfig.txt.
    ...  If the flag is present in swconfig.txt, it is deleted.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${flag}

    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=${SPACE}>
    SSHLibrary.Write  cd /ffs/run
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls
    ${ls_output}  SSHLibrary.Read Until Prompt
    ${swconfig_status}  Run Keyword And Return Status
    ...  Should Contain  ${ls_output}  swconfig.txt
    Run Keyword If  ${swconfig_status} == ${FALSE}
    ...  Fail  swconfig.txt not found on SBTS. [NOK]
    SSHLibrary.Write  cat swconfig.txt
    ${swconfig_content}  SSHLibrary.Read Until Prompt
    ${flag_status}  Run Keyword And Return Status
    ...  Should Not Contain  ${swconfig_content}  ${flag}
    Run Keyword If  ${flag_status} == ${FALSE}
    ...  Run Keywords
    ...  SSHLibrary.Write  sed -i '/${flag}/d' swconfig.txt
    ...  AND
    ...  SSHLibrary.Read Until Prompt
    ...  ELSE
    ...  Run Keywords
    ...  SSHLibrary.Close Connection
    ...  AND
    ...  Return From Keyword
    SSHLibrary.Write  cat swconfig.txt
    ${swconfig_content}  SSHLibrary.Read Until Prompt
    Should Not Contain  ${swconfig_content}  ${flag}  Didn't manage to delete ${flag} flag from swconfig.txt file. [NOK]
    Log  Flag: ${flag} deleted successfully from swconfig.txt file. [OK]
    SSHLibrary.Close Connection


Sleep And Log Waiting Time
    [Documentation]  Log sleeping time to console.
    ...  Timeout argument represents the waiting time in minutes.
    [Arguments]  ${timeout}  ${message}=${EMPTY}

    Log  ${message}  console=true
    FOR  ${time}  IN RANGE  ${timeout}
        Log  Waiting time left ${${timeout}-${time}} minutes.  console=true
        Sleep  1m
    END


Set IPIF Interface
    [Documentation]  This keyword is used to set IPIF interface.
    ...  ${MPLANE_IP} must be set first.

    ${ipif_object}  Query Infomodel  get object //IPIF_A-*/IPADDRESSV4_A-* is [localIpAddr=${MPLANE_IP}]
    ${ipif_ipaddr}  Fetch From Right  ${ipif_object}[dist_name]  IPIF_A-
    ${ipif}  ${ipaddr}  Split String  ${ipif_ipaddr}  /
    Set Test Variable  ${INITIAL_IPIF}  ${ipif}
    ${ipaddr}  Fetch From Right  ${ipaddr}  -
    Set Test Variable  ${INITIAL_IPADDR}  ${ipaddr}
    ${test_ipaddr}  Evaluate  ${INITIAL_IPADDR}+1
    Set Test Variable  ${TEST_IPADDR}


Create IPADDRESSV4-2
    [Documentation]
    ...  Set IPIF interface KW must be called first to set ${INITIAL_IPIF} and ${TEST_IPADDR} variables.

    Log  Create IPADDRESSV4-2  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${INITIAL_IPIF}/IPADDRESSV4-${TEST_IPADDR}  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${INITIAL_IPIF}/IPADDRESSV4-${TEST_IPADDR}
    ...  ipAddressAllocationMethod  MANUAL  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${INITIAL_IPIF}/IPADDRESSV4-${TEST_IPADDR}  localIpAddr  1.2.3.9
    ...  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${INITIAL_IPIF}/IPADDRESSV4-${TEST_IPADDR}  localIpPrefixLength  24
    ...  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_RFTHLD.json  delta_id=${delta_id}
    Log  Performing delta recommissioning...  console=true
    ${commissioning_state}  Run Keyword And Return Status
    ...  Perform Delta Recommissioning  ${BTS_FILES}/delta_RFTHLD.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Change Mplane IP
    [Documentation]
    ...  Set IPIF interface KW and Get BTS ID must be called first to set required variables.

    ${delta_id}  Set Variable  2
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1  mPlaneIpv4AddressDN
    ...  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${INITIAL_IPIF}/IPADDRESSV4-${TEST_IPADDR}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Log  Change mplane IP  console=true
    ${commissioning_state}  Run Keyword And Return Status
    ...  Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Restore Mplane
    [Documentation]
    ...  Set IPIF interface KW and Get BTS ID must be called first to set ${BTS_ID}, ${INITIAL_IPIF} and ${INITIAL_IPADDR} variables.

    ${delta_id}  Set Variable  3
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1  mPlaneIpv4AddressDN
    ...  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${INITIAL_IPIF}/IPADDRESSV4-${INITIAL_IPADDR}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Log  Restore mplane address  console=true
    ${commissioning_state}  Run Keyword And Return Status
    ...  Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Remove IPADDRESSV4-2
    [Documentation]
    ...  Set IPIF interface KW and Get BTS ID must be called first to set required variables.

    Log  Remove IPADDRESSV4-2  console=true
    ${delta_id}  Set Variable  4
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${INITIAL_IPIF}/IPADDRESSV4-${TEST_IPADDR}  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning...  console=true
    ${commissioning_state}  Run Keyword And Return Status
    ...  Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Check Equality
    [Documentation]  This keyword will be used to check equality between fault signature value and expected value.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_signature_value}  ${expected_value}  ${fail_message}

    IF  '${expected_value}' != '${EMPTY}'  Should Be Equal  ${fault_signature_value}  ${expected_value}  msg=${fail_message}


Check Regexp
    [Documentation]  This keyword will be used to check regexp between fault signature value and expected value.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_signature_string}  ${expected_string}  ${fail_message}

    IF  '${expected_string}' != '${EMPTY}'  Should Match Regexp  ${fault_signature_string}  ${expected_string}  msg=${fail_message}


Check Contain
    [Documentation]  This keyword will be used to check contain between fault signature value and expected value.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_signature_value}  ${expected_value}  ${fail_message}

    IF  '${expected_value}' != '${EMPTY}'  Should Contain  ${fault_signature_value}  ${expected_value}  msg=${fail_message}


Check Component Field
    [Documentation]
    ...  Keyword was designed to handle various forms for component field filling.
    ...  E.g. in case of radio module power off/on fault signature will have component field as following:
    ...  'component': 'L1190105466' ; in this case ${component} can be used as argument for checking.
    ...  E.g. in case of secondary core power off/on fault signature will have component field as following:
    ...  'inventoryUnitType: FCTJ; serialNumber: L1162513497; vendorUnitTypeNumber: 087338A.101; unitPosition: 4;
    ...  In this case:
    ...  ${full_product_name} of module can be used to check inventoryUnitType. Keyword will check &{COMMON_MODULES} correspondence.
    ...  ${serial_number} of module and ${core_serial_number} can be used to check serialNumber.
    ...  ${vendor_unit_number} of module and ${core_vendor_unit_number} can be used to check vendorUnitTypeNumber.
    ...  ${unit_position} and ${core_unit_position} can be used to check unitPosition.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]
    ...  ${fault_signature_component}=${EMPTY}
    ...  ${component}=${EMPTY}
    ...  ${full_product_name}=${EMPTY}
    ...  ${serial_number}=${EMPTY}
    ...  ${core_serial_number}=${EMPTY}
    ...  ${vendor_unit_number}=${EMPTY}
    ...  ${core_vendor_unit_number}=${EMPTY}
    ...  ${unit_position}=${EMPTY}
    ...  ${core_unit_position}=${EMPTY}

    Check Contain  ${fault_signature_component}  ${component}  Component field did not matched.
    IF  '${full_product_name}' != '${EMPTY}'
    ...  Check InventoryUnitType In Component Field  ${fault_signature_component}  ${full_product_name}
    IF  '${serial_number}' != '${EMPTY}' or '${core_serial_number}' != '${EMPTY}'
    ...  Check SerialNumber In Component Field  ${fault_signature_component}  ${serial_number}  ${core_serial_number}
    IF  '${vendor_unit_number}' != '${EMPTY}' or '${core_vendor_unit_number}' != '${EMPTY}'
    ...  Check VendorUnitTypeNumber In Component Field  ${fault_signature_component}  ${vendor_unit_number}  ${core_vendor_unit_number}
    IF  'Flexi' in '${full_product_name}'  RETURN
    IF  '${unit_position}' != '${EMPTY}' or '${core_unit_position}' != '${EMPTY}'
    ...  Check UnitPosition In Component Field  ${fault_signature_component}  ${unit_position}  ${core_unit_position}


Check InventoryUnitType In Component Field
    [Documentation]
    ...  Keyword was designed to check inventoryUnitType value from component field in fault signature.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_signature_component}  ${full_product_name}

    ${short_product_name}  Fetch From Left  ${full_product_name}  ${SPACE}
    ${flexi_bb_status}  Run Keyword And Return status  Should Contain  ${full_product_name}  Baseband
    ${airscale_bb_status}  Run Keyword And Return status  Should Contain  ${full_product_name}  Capacity
    IF  ${flexi_bb_status} or ${airscale_bb_status}
        ${status_common_modules}  Set Variable  ${FALSE}
        ${status_capacity_modules}  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${CAPACITY_MODULES}
        ...                                 ${short_product_name}
        ...                                 msg=There is no ${short_product_name} in Capacity modules list.
    ELSE
        ${status_capacity_modules}  Set Variable  ${FALSE}
        ${status_common_modules}  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${COMMON_MODULES}
        ...                                 ${short_product_name}
        ...                                 msg=There is no ${short_product_name} in Common modules list.
    END

    ${product_name_list}  Set Variable If  '${status_common_modules}'=='True'  ${COMMON_MODULES}[${short_product_name}]
    ...  '${status_capacity_modules}'=='True'  ${CAPACITY_MODULES}[${short_product_name}]  ${EMPTY}
    IF  '${product_name_list}[0]' == '${EMPTY}'  Fail  msg=Module not in common or capacity modules.
    ${string}  Fetch From Right  ${fault_signature_component}  inventoryUnitType:${SPACE}
    ${inventory_unit_type}  Fetch From Left  ${string}  ;

    ${status_core_inventory_unit_type}  Run Keyword And Return Status  Should Match Regexp  ${inventory_unit_type}  ^(A|F)?(C|S)?(C|P|T)?[A-Z]$

    ${fctx_list}  Get Matches  ${product_name_list}  FCT[A-Z]
    ${fspx_list}  Get Matches  ${product_name_list}  FSP[A-Z]
    ${ascx_list}  Get Matches  ${product_name_list}  ASC[A-Z]
    ${aspx_list}  Get Matches  ${product_name_list}  ASP[A-Z]

    IF  '${ENB_BRANCH}' < 'SBTS25R3' and ${status_core_inventory_unit_type}
        List Should Contain Value  ${product_name_list}  ${inventory_unit_type}  msg=Wrong inventory unit type in component field.
    ELSE IF  '${ENB_BRANCH}' >= 'SBTS25R3' and ${fctx_list}
        Remove Values From List  ${product_name_list}  @{fctx_list}
        List Should Contain Value  ${product_name_list}  ${inventory_unit_type}  msg=Wrong inventory unit type in component field.
    ELSE IF  '${ENB_BRANCH}' >= 'SBTS25R3' and ${fspx_list}
        Remove Values From List  ${product_name_list}  @{fspx_list}
        List Should Contain Value  ${product_name_list}  ${inventory_unit_type}  msg=Wrong inventory unit type in component field.
    ELSE IF  '${ENB_BRANCH}' >= 'SBTS25R3' and ${ascx_list}
        Remove Values From List  ${product_name_list}  @{ascx_list}
        List Should Contain Value  ${product_name_list}  ${inventory_unit_type}  msg=Wrong inventory unit type in component field.
    ELSE IF  '${ENB_BRANCH}' >= 'SBTS25R3' and ${aspx_list}
        Remove Values From List  ${product_name_list}  @{aspx_list}
        List Should Contain Value  ${product_name_list}  ${inventory_unit_type}  msg=Wrong inventory unit type in component field.
    END


Check SerialNumber In Component Field
    [Documentation]
    ...  Keyword was designed to check serialNumber value from component field in fault signature.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_signature_component}  ${serial_number}  ${core_serial_number}

    IF  '${serial_number}' != '${EMPTY}'
      ${status_serial_number}  Run Keyword And Return Status
      ...  Check Contain  ${fault_signature_component}  serialNumber:${SPACE}${serial_number}  Wrong serial number in component field.
    ELSE
      ${status_serial_number}  Set Variable  ${FALSE}
    END
    IF  '${core_serial_number}' != '${EMPTY}'
      ${status_core_serial_number}  Run Keyword And Return Status
      ...   Check Contain  ${fault_signature_component}  serialNumber:${SPACE}${core_serial_number}  Wrong serial number in component field.
    ELSE
      ${status_core_serial_number}  Set Variable  ${FALSE}
    END
    IF  '${status_serial_number}'=='${TRUE}' or '${status_core_serial_number}'=='${TRUE}'
      Log  Correct serial number in component field.
    ELSE
      Fail  Wrong serial number in component field.
    END


Check VendorUnitTypeNumber In Component Field
    [Documentation]
    ...  Keyword was designed to check vendorUnitTypeNumber value from component field in fault signature.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_signature_component}  ${vendor_unit_number}  ${core_vendor_unit_number}

    IF  '${vendor_unit_number}' != '${EMPTY}'
      ${status_vendor_unit_number}  Run Keyword And Return Status
      ...  Check Contain  ${fault_signature_component}  vendorUnitTypeNumber:${SPACE}${vendor_unit_number}
      ...  Wrong vendor unit type number in component field.
    ELSE
      ${status_vendor_unit_number}  Set Variable  ${FALSE}
    END
    IF  '${core_vendor_unit_number}' != '${EMPTY}'
      ${status_core_vendor_unit_number}  Run Keyword And Return Status
      ...  Check Contain  ${fault_signature_component}  vendorUnitTypeNumber:${SPACE}${core_vendor_unit_number}
      ...  Wrong vendor unit type number in component field.
    ELSE
      ${status_core_vendor_unit_number}  Set Variable  ${FALSE}
    END
    IF  '${status_vendor_unit_number}'=='${TRUE}' or '${status_core_vendor_unit_number}'=='${TRUE}'
      Log  Correct vendor unit type number in component field.
    ELSE
      Fail  Wrong vendor unit type number in component field.
    END


Check UnitPosition In Component Field
    [Documentation]
    ...  Keyword was designed to check unitPosition value from component field in fault signature.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_signature_component}  ${unit_position}  ${core_unit_position}

    IF  '${unit_position}' != '${EMPTY}'
      ${status_unit_position}  Run Keyword And Return Status
      ...  Check Contain  ${fault_signature_component}  unitPosition:${SPACE}${unit_position}  Wrong unit position in component field.
    ELSE
      ${status_unit_position}  Set Variable  ${FALSE}
    END
    IF  '${core_unit_position}' != '${EMPTY}'
      ${status_core_unit_position}  Run Keyword And Return Status
      ...  Check Contain  ${fault_signature_component}  unitPosition:${SPACE}${core_unit_position}  Wrong unit position in component field.
    ELSE
      ${status_core_unit_position}  Set Variable  ${FALSE}
    END
    IF  '${status_unit_position}'=='${TRUE}' or '${status_core_unit_position}'=='${TRUE}'
      Log  Correct unit position in component field.
    ELSE
      Fail  Wrong unit position in component field.
    END


Change FMCADM Parameter
    [Documentation]  Keyword to change any parameter under FMCADM
    [Arguments]  ${parameter}  ${value}  ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=120

    Log  FMCADM Parameter ${parameter} will be changed to ${value}.  console=true
    ${list}  Create List  ${parameter}
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${actual_value}  Set Variable  ${object}[0][parameters][${parameter}]
    IF  '${actual_value}' == '${value}'
      Log  Parameter already has the requested value. Parameter change will be skipped.  console=true
      RETURN
    END
    Log  Current parameter value ${actual_value}.  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  parameter=${parameter}  operation=update  value=${value}
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}  timeout=${timeout}
    Log  ${parameter} value changed to ${value}.  console=true


Open Connection To Secondary VM Through Public Key
    [Documentation]
    ...  This keyword opens ssh connection to Secondary VM through public key.
    [Arguments]  ${alias}=secondary_vm_ssh

    SSHLibrary.Open Connection  host=${PC_IP2}  port=${22}  prompt=$  alias=${alias}
    ${key_login_status}  Run Keyword And Return Status  SSHLibrary.Login With Public Key  ute  /home/ute/.ssh/id_rsa
    Run Keyword If  ${key_login_status} == ${FALSE}
    ...  Fail  Secondary VM connection unavailable. [NOK]
    Log  Secondary VM connection established successfully.[OK]  console=true


Get Python Version For Secondary VM
    [Documentation]
    ...  This keyword returns python version on Secondary VM.

    Open Connection To Secondary VM Through Public Key  python_version_ssh
    SSHLibrary.Write  pyenv global
    ${output}  SSHLibrary.Read until Prompt
    ${output}  Get Regexp Matches  ${output}  [0-9]+\.[0-9]+\.[0-9]+
    ${sc_python_version}  Set Variable  ${output}[0]

    [Return]  ${sc_python_version}
    [Teardown]  Run Keywords  SSHLibrary.Switch Connection  python_version_ssh  AND  SSHLibrary.Close Connection


Get Runtime Object Dist_name From Logical Object Dist_name
    [Documentation]
    ...  This keyword returns runtime object dist_name from logical object dist_name.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${module_l_dn}

    ${is_bbmod}  Run Keyword And Return Status
    ...  Should Contain  ${module_l_dn}  BBMOD
    ${type}  Set Variable If  ${is_bbmod}  BBMOD  SMOD
    ${module_l_parameters}  coam.Get Parameters For  ${type}  ${module_l_dn}
    ${module_l_serial_number}  Set Variable  ${module_l_parameters}[serialNumber]
    ${module_list}  Run Keyword If  '${type}' == 'BBMOD'
    ...  Get Fbb Info
    ...  ELSE
    ...  Get Fsm Info
    FOR  ${module}  IN  @{module_list}
        Run Keyword If  '${module}[serialNumber]'=='${module_l_serial_number}'
        ...  Run Keywords
        ...  Set Test Variable  ${MODULE_R_DN}  ${module}[id][internal]
        ...  AND
        ...  Exit For Loop
    END

    [Return]  ${MODULE_R_DN}


Get Module Vertical Position
    [Documentation]
    ...  This keyword returns module vertical position from runtime object dist_name (SMOD_R or BBMOD_R).
    ...  In case of ASOE/ASOF/ASOG/ASOH core unit keyword will return 0.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${module_r_dn}

    ${module_parameters}  coam.Get Parameters  ${module_r_dn}
    ${module_vertical_position}  Run Keyword If  '${module_parameters}[verticalPosition]' != '${None}'
    ...  Evaluate  ${module_parameters}[verticalPosition]-1
    ...  ELSE
    ...  Set Variable  0

    [Return]  ${module_vertical_position}


Get Cells On RMODs
    [Documentation]  This kw retruns cells mapping on RMODs
    [Arguments]  ${rmod_list}

    ${cells_on_rmod}  Create List
    FOR  ${rmod}  IN  @{rmod_list}
        ${cells}  Get Cell Mapping By Module Id  ${rmod}
        Append To List  ${cells_on_rmod}  @{cells}
    END
    ${cells_on_rmod}  Remove Duplicates  ${cells_on_rmod}

    [Return]  ${cells_on_rmod}


Get Loki Ports
    [Documentation]  This kw retruns the ports on loki A, or loki B form ABIN, ABIP, ABIO and ASOE.
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${soc_type}  ${soc_dn}

    ${loki_ports}  Create List  1  2  3  4  5  6  7  8  9  10  11  12
    Run Keyword If  '${soc_type}'=='ABIN' or '${soc_type}'=='ABIP'
    ...  Return From Keyword  ${loki_ports}
    ${loki_path}  Get Regexp Matches  ${soc_dn}  POWER_GROUP_L-./SOC_L-.
    ${status_loki_1}  Run Keyword And Return Status
    ...  Should Contain  ${loki_path}  POWER_GROUP_L-1/SOC_L-2
    ${abio_asoe_ports}  Run Keyword If  ${status_loki_1}
    ...  Get Slice From List  ${loki_ports}  0  6
    ...  ELSE
    ...  Get Slice From List  ${loki_ports}  6

    [Return]  ${abio_asoe_ports}


Get All Cells On Bts
    [Documentation]  This keyword is used to get all cells on bts.

    ${list_all_rat}  Create List  NRCEL  LNCEL  WNCEL  GNCEL
    ${cells_list}  Create List
    FOR  ${cell_class_name}  IN  @{list_all_rat}
        ${cell_on_rat}  Get Ids For All  ${cell_class_name}
        Append To List  ${cells_list}  @{cell_on_rat}
    END

    [Return]  ${cells_list}


Get Cells Mapped On SoC And RMODs
    [Documentation]  This kw returns cells mapped on SoC and RMODs.
    ...  If cablink mode between SoC and RMODs is synchronization than returns cells mapped on SoC and RMODs
    ...  else returns cells mapped on SoC.
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${module_r_dn}  ${soc_type}  ${soc_dn}

    ${rmods_on_module}  Get RMODs From Soc  ${module_r_dn}  ${soc_type}  ${soc_dn}
    ${cells_affected_on_rmod}  Get Cells On RMODs  ${rmods_on_module}
    ${cell_on_soc}  Get Cell Mapping By Module Id  ${soc_dn}
    Append To List  ${cells_affected_on_rmod}  @{cell_on_soc}
    ${cells_affected_on_rmod}  Remove Duplicates  ${cells_affected_on_rmod}

    [Return]  ${cells_affected_on_rmod}


Get RMODs From Soc
    [Documentation]  This kw returns RMODs from Soc if cablink mode is synchronization.
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${module_r_dn}  ${soc_type}  ${soc_dn}

    ${cablink_list}  Query Infomodel  get list //CABLINK_R-* is [firstEndpointDN=${module_r_dn}]
    ${ports}  Get Loki Ports  ${soc_type}  ${soc_dn}
    ${rmod_on_soc}  Create List
    FOR  ${link}  IN  @{cablink_list}
        ${port_id}  Convert To String  ${link}[firstEndpointPortId]
        ${status_link_mode_synchronization}  Run Keyword And Return Status
        ...  Should Match Regexp  '${link}[linkModeSynchronization]'  (true|True)
        ${status_first_endpoint_port_id}  Run Keyword And Return Status
        ...  List Should Contain Value  ${ports}  ${port_id}
        Run Keyword If  ${status_link_mode_synchronization} and ${status_first_endpoint_port_id}
        ...  Append To List  ${rmod_on_soc}  ${link}[secondEndpointDN]
    END
    ${rmod_on_soc}  Remove Duplicates  ${rmod_on_soc}

    [Return]  ${rmod_on_soc}


Set Parameter To New Value
    [Documentation]  This KW sets provided parameters to new value.
    [Arguments]  ${parameter_path}  ${parameter_name}  ${new_value}

    ${param_list}  Create List  ${parameter_name}
    ${parameter}  Get Parameter By Distname  ${parameter_path}  ${param_list}
    ${status}  ${current_value}  Run Keyword And Ignore Error  Set Variable  ${parameter}[0][parameters][${parameter_name}]
    ${param_should_be_changed}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${current_value}  ${new_value}  ignore_case=True
    IF  '${status}'=='FAIL' or ${param_should_be_changed}
        Log  ${parameter_name} will be changed to ${new_value}.  console=true
        coam.Perform Parameter Recommissioning  ${parameter_path}  ${parameter_name}  update  ${new_value}  skip_parameter_relation_errors=True
    END


Extract From Path
    [Documentation]  This keyword returns extracted path from zip archive.
    [Arguments]  ${file_path}  ${snapshot_path}

    ${path}  Set Variable  ${snapshot_path}
    ${files_from_path}  Split String  ${file_path}  /
    FOR  ${file}  IN  @{files_from_path}
        Exit For Loop If  '.zip' not in '${file}'
        ${extension}  Fetch From Right  ${file}  .
        ${archive_path}  Set Variable  ${path}/${file}
        ${folder}  Remove String  ${file}  .${extension}
        ${path}  Join Path  ${path}  ${folder}
        ${directory_exists}  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${path}
        Continue For Loop If  ${directory_exists}
        OperatingSystem.Run  mkdir "${path}"
        OperatingSystem.Run  unzip "${archive_path}" -d "${path}"
    END
    ${extension}  Fetch From Right  ${file}  .
    ${path}  Run Keyword If  '${extension}'!='zip'  Join Path  ${path}  ${file}  ELSE  Set Variable  ${path}

    [Return]  ${path}


Verify Cells Technology On RMOD
    [Documentation]  This KW verifies if certian technology is mapped on RMOD.
    [Arguments]  ${rmod_cells}  ${technology}

    ${tech_rmod_cells}  Create List
    FOR  ${cell}  IN  @{rmod_cells}
        ${status_cells}  Run Keyword And Return Status  Should Contain  ${cell}  ${technology}
        IF  ${status_cells}  Append To List  ${tech_rmod_cells}  ${cell}
    END
    ${status_cells_rmod}  Run Keyword And Return Status  Should Not Be Empty  ${tech_rmod_cells}

    RETURN  ${tech_rmod_cells}  ${status_cells_rmod}


Find RMOD Ip By Serial Number
    [Documentation]
    ...  This kw to find the RMOD ip by serial number.
    ...  RMOD ip and SMOD side are returned.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${rmod_sn}

    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_parameters}
        IF  '${rmod}[serialNumber]'=='${rmod_sn}'
            ${rmod_ip}  Set Variable  ${rmod}[ipAddress]
            ${rmod_l_dn_param}  Set Variable  ${EMPTY}
            FOR  ${item}  IN RANGE  1  4
                 ${status}  Run Keyword And Return Status  coam.Get Parameters  ${rmod}[id]/REF-${item}
                 IF  ${status}
                     ${rmod_l_dn_param}  coam.Get Parameters  ${rmod}[id]/REF-${item}
                 ELSE
                     CONTINUE
                 END
            END
            Should Not Be Empty  ${rmod_l_dn_param}  RMOD_L not found for RMOD with serial number: ${rmod_sn}.
            ${rmod_l_dn}  Set Variable  ${rmod_l_dn_param}[distName]
            ${rmod_l_params}  Get Parameters For  RMOD  ${rmod_l_dn}
            ${left_side_string}  Fetch From Left  ${rmod_l_dn}  /EQM_L
            ${rmod_side}  Fetch From Right  ${left_side_string}  /BTS_L-
            ${bts_l_parameters}  coam.Get Parameters  ${left_side_string}
            ${stored_role}  Set Variable  ${bts_l_parameters}[storedRole]
            BREAK
        ELSE
            CONTINUE
        END
    END
    Should Not Be Empty  ${rmod_ip}  RMOD ip not set correctly. [NOK]
    Should Not Be Empty  ${rmod_side}  RMOD side not set correctly. [NOK]
    IF  ${rmod_side}==1
        ${smod_side}  Set Variable  1
    ELSE IF  ${rmod_side}==4
        ${smod_side}  Set Variable  2
    END
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    IF  '${stored_role}' == 'Idle'  Open Connection To Secondary Core
    SSHLibrary.Write  lxc-attach -n 0x${smod_side}018
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ping -c 3 ${rmod_ip}
    SSHLibrary.Set Client Configuration  timeout=20s
    ${ping_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${ping_output}  3 received   RMOD ip not set correctly. [NOK]
    SSHLibrary.Close All Connections
    Log  RMOD with serial number: ${rmod_sn} has the ip: ${rmod_ip}.  console=true

    RETURN  ${smod_side}  ${rmod_ip}  ${stored_role}


Verify That At Least One Cell Is Degraded
    [Documentation]  This keyword is created to verify that at least one cell from the given cells list is degraded.
    [Arguments]  ${cells_list}

    FOR  ${cell_dn}  IN  @{cells_list}
        ${cell_id}  Fetch from right  ${cell_dn}  /
        ${cell_class_name}  Get regexp matches  ${cell_dn}  [A-Z]{2}CEL
        ${cell_is_degraded}  Run keyword and return status  Assert  ${cell_class_name}[0]  ${cell_dn}  availabilityStatus=${DEGRADED}  timeout=20
        IF  ${cell_is_degraded}  RETURN
    END
    Fail  No cell mapped on RMOD is DEGRADED after second fault trigger.


Add Flag To Swconfig File And Perform Site Reset
    [Documentation]  This keyword is created to add given flag to swconfig.txt file
    [Arguments]  ${flag}

    Open Connection To Primary Core
    SSHLibrary.Write  cat /rom/swconfig.txt | grep ${flag}
    ${command_output}  SSHLibrary.Read Until Prompt
    ${flag_status}  Run Keyword And Return Status  Should Contain  ${command_output}  ${flag}
    IF  not ${flag_status}
        Log  Adding swconfig flag: ${flag}  console=true
        SSHLibrary.Write  echo -e ${flag} >> /rom/swconfig.txt
        SSHLibrary.Read Until Prompt
        Perform Site Reset
    ELSE
        Log  \nFlag: ${flag} exists in swconfig file, no need to add it.  console=true
    END

    [Teardown]  SSHLibrary.Close Connection


Remove Swconfig Flag And Perform Site Reset
    [Documentation]  This keyword is created to remove given flag from swconfig.txt file
    [Arguments]  ${flag}

    Open Connection To Primary Core
    SSHLibrary.Write  cat /rom/swconfig.txt | grep ${flag}
    ${command_output}  SSHLibrary.Read Until Prompt
    ${flag_status}  Run Keyword And Return Status  Should Contain  ${command_output}  ${flag}
    IF  not ${flag_status}
        Log  Flag: ${flag} not found in swconfig file.  console=true
        RETURN
    END
    Log  Removing swconfig flag: ${flag}  console=true
    SSHLibrary.Write  sed -i '/^${flag}/d' /ffs/run/swconfig.txt
    SSHLibrary.Read Until Prompt
    Perform Site Reset

    [Teardown]  SSHLibrary.Close Connection


Remove Allowed And Suppressed Parameters From ALARMSUPP
    [Documentation]
    ...  This keyword removes allowedAlarmList and allowedFaultList from ALARMSUPP.
    ...  This keyword removes suppressedAlarmList, suppressedFaultList and suppressAlarmsByMOCList from ALARMSUPP.
    ...  *AUTHOR* laura.craciunel@nokia.com

    Log  Removing allowedAlarmList and allowedFaultList from ALARMSUPP.  console=true
    Log  Removing suppressedAlarmList, suppressedFaultList and suppressAlarmsByMOCList from ALARMSUPP.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  disabled  ${delta_id}
    Append Parameter Delete To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  allowedAlarmList  ${delta_id}
    Append Parameter Delete To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  allowedFaultList  ${delta_id}
    Append Parameter Delete To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  suppressedAlarmList  ${delta_id}
    Append Parameter Delete To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  suppressedFaultList  ${delta_id}
    Append Parameter Delete To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  suppressAlarmsByMOCList  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_remove.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_remove.json  timeout=120
    Remove Delta  ${delta_id}


Add Given Fault And Severity To SuppressedFaultList
    [Documentation]
    ...  This keyword adds given fault structure with fault ids with severity to suppressedFaultList under ALARMSUPP.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${suppress_fault_list}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append List Items To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  suppressedFaultList
    ...  @{suppress_fault_list}  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  suppressAlarms  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_suppress_by_fault_list.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_suppress_by_fault_list.json  timeout=120
    Remove Delta  ${delta_id}
    Log  suppressedFaultList changed to:\n${suppress_fault_list}.  console=true


Add Given Alarm And Severity To SuppressedAlarmList
    [Documentation]
    ...  This keyword adds given alarm structure with alarm ids with severity to suppressedAlarmList under ALARMSUPP.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${suppress_alarm_list}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append List Items To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  suppressedAlarmList
    ...  @{suppress_alarm_list}  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  suppressAlarms  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_suppress_by_alarm_list.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_suppress_by_alarm_list.json  timeout=120
    Remove Delta  ${delta_id}
    Log  suppressedAlarmList changed to:\n${suppress_alarm_list}.  console=true


Add Given Fault And Severity To AllowedFaultList
    [Documentation]
    ...  This keyword adds given fault structure with fault ids with severity to allowedFaultList under ALARMSUPP.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${allowed_fault_list}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append List Items To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  allowedFaultList
    ...  @{allowed_fault_list}  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  allowAlarms  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_allowed_by_fault_list.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_allowed_by_fault_list.json  timeout=120
    Remove Delta  ${delta_id}
    Log  allowedFaultList changed to:\n${allowed_fault_list}.  console=true


Get Cablinks Available By Provided Protocol
    [Documentation]  KW returns list of available cablinks based on provided protocol.
    ...  ${protocol} argument can be one of this options: cpri, ecpri or obsai
    [Arguments]  ${protocol}

    ${regex_mapping}  Create Dictionary  cpri=^Cpri\\d  ecpri=^eCpri\\d{2}  obsai=Obsai\\dGbps
    ${links}  Get Parameters For All  CABLINK
    ${available_links}  Create List
    FOR  ${link}  IN  @{links}
        ${status}  Run Keyword And Return Status  Should Match Regexp  ${link}[linkSpeed]  ${regex_mapping}[${protocol}]
        IF  ${status}
          Append To List  ${available_links}  ${link}
        END
    END

    RETURN  ${available_links}


Get Active And Passive Partitions Ids
    [Documentation]  This keyword get the active and passive partitions ids.

    Connect To SMOD  ${SMOD1['TRS_IP']}
    ${command_status}  ${msg}  Run Keyword And Ignore Error  ssh.Execute  uboot_env get active_partition
    ${active_partition_id}  Should Match Regexp  ${msg}  (?<=active_partition=)[1-2]*
    ${passive_partition_id}  Set Variable If  "${active_partition_id}"=="1"  2  1

    RETURN  ${active_partition_id}  ${passive_partition_id}


Perform Site Reset
    [Documentation]  This keyword is used to perform site reset.

    Log  Site reset will be performed to clear recovery reset counters.  console=true
    coam.Reset Site  timeout=${SITE_RESET_PROCEDURE}
    Log  Site reset has been performed.  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Check Fault 4592 Supplementary Alarm Information  user request
    ${modules_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells
    IF  ${modules_cells_status}
        Log  All modules and cells are onAir after site reset.  console=true
    ELSE
        Fail  Not all modules or cells are onAir after site reset.
    END
    Admin Check Active Alarms Taf

    [Teardown]  coam.Reset Admin


Check Fault 4592 Supplementary Alarm Information
    [Documentation]  KW to check duration and reason for fault 4592.
    ...  Alarm should appear after 5 min after BTS reset and it should be active for the time defined in fault4592CancellationTimer.
    ...  KW will wait for 310s for allarm to appear. 10s are added for margin.
    ...  Alarm active time is checked to be in fault4592CancellationTimer-5s and fault4592CancellationTimer+5s time period.
    ...  /// DO NOT CHANGE those times without notice. ///
    [Arguments]  ${fault_reason}=${None}

    Assert Every  SMOD  operationalState=${ENABLED}  timeout=120
    ${fsm_info}  Get FSM Info  timeout=60
    Assert Every  SMOD  operationalState=${ENABLED}  timeout=120
    ${fsm_info}  Get FSM Info
    FOR  ${fsm}  IN  @{fsm_info}
        ${active_role_status}  Evaluate  ${fsm}.get('activeRole', ${FALSE})
        IF  '${active_role_status}' == 'Secondary'  CONTINUE
        IF  'ASO' in '${fsm}[productName]' or 'ASIK' in '${fsm}[productName]'  RETURN
    END
    ${list}  Create List  fault4592CancellationTimer
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${clear_time}  Set Variable  ${parameter}[0][parameters][fault4592CancellationTimer]
    ${clear_time}  Convert To Integer  ${clear_time}
    ${severity}  Set Variable If  ${clear_time}==30  Warning  Minor

    ${alarm_list}  Assert Alarm Active  parameters=faultId=4592, faultName="BTS Reset Cause", alarmId=7115, severity=${severity}  timeout=310
    ${alarm_appeared_time}  Get Current Date  result_format=%H:%M:%S
    Assert Alarm Inactive  parameters=faultId=4592, faultName="BTS Reset Cause", alarmId=7115, severity=${severity}  timeout=${clear_time+10}
    ${alarm_cleared_time}  Get Current Date  result_format=%H:%M:%S

    ${alarm_duration}  Subtract Time From Time  ${alarm_cleared_time}  ${alarm_appeared_time}
    ${alarm_duration}  Convert To Integer  ${alarm_duration}
    ${alarm}  Get Fault 4592 From Dictonary  ${alarm_list}
    Check Supplementary Alarm Information  ${alarm}  ${fault_reason}
    ${alarm_total_time}  Evaluate  ${clear_time}-5 <= ${alarm_duration} <= ${clear_time}+5
    IF  ${alarm_total_time}
        Log  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value within tolerance defined by fault4592CancellationTimer=${clear_time}.
        ...  console=true
    ELSE
        Log  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value not within tolerance defined by fault4592CancellationTimer=${clear_time}.
        ...  console=true
        ...  level=ERROR
    END


Get Fault 4592 From Dictonary
    [Arguments]  ${dictonary}

    FOR  ${alarm}  IN  @{dictonary}
        IF  ${alarm}[faultId]==4592  RETURN  ${alarm}
    END


Check Supplementary Alarm Information
    [Arguments]  ${alarm}  ${reason}

    ${suplementary_info}  Get From Dictionary  ${alarm}[alarmText][alarmAdditionalInfo]  supplAlarmInfo
    Should Contain  ${suplementary_info}  ${reason}  Reset reason not OK.
    Log  Reset reason OK.  console=true


Check Modules And Cells
    [Documentation]
    ...  This keyword checks if SMODs, BBMODs, RMODs and cells are enabled.
    [Arguments]  ${check_cells}=${TRUE}

    Assert Every  SMOD  operationalState=${ENABLED}
    ${smods}  Get Fsm Info
    ${smods_list}  Create List  ASOE  ASOF  ASOG  ASOH
    ${smod_type}  Fetch From Left  ${smods}[0][productName]  ${SPACE}AirScale
    IF  '${smod_type}' not in ${smods_list}  Assert Every  BBMOD  operationalState=${ENABLED}
    Assert Every  RMOD  operationalState=${ENABLED}
    IF  '${check_cells}'=='${TRUE}'  Check All Cells


Load A Specific SCF
    [Documentation]  This keyword loads a specific SCF.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${scf_path}  ${timeout}=600

    ${commissioning_status}  Run Keyword And Return Status
    ...  coam.Perform Commissioning  bts_id=${BTS_ID}
    ...  scf_file=${scf_path}
    ...  should_activate=${TRUE}
    ...  timeout=${timeout}
    IF  ${commissioning_status}
        Log  Loading SCF is performed successfully.[OK]  console=true
    ELSE
        Fail  Loading SCF is failed.[NOK]
    END
    Log  Wait for all cells to be onAir...  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and units are onAir!  console=true


Set RMOD Parameters By RMOD Type
    [Documentation]
    ...  This keyword returns RMOD details based on its type (product name),
    ...  including: IP, side, stored role, and serial number.
    ...  *AUTHOR* cosmina.rebenciuc@nokia.com
    [Arguments]  ${rmod_type}

    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_parameters}
        IF  '${rmod}[productName]'=='${rmod_type}' and '${rmod}[ipAddress]'!='0.0.0.0'
            ${rmod_ip}  Set Variable  ${rmod}[ipAddress]
            ${rmod_r_dn}  Set Variable  ${rmod}[id]
            ${rmod_sn}  Set Variable  ${rmod}[serialNumber]
            ${rmod_param}  Get Parameters For  RMOD  ${rmod}[id]
            ${rmod_l_dn}  Get Logical Object From Runtime Reference  ${rmod}[id]
            ${rmod_l_param}  Get Parameters For  RMOD  ${rmod_l_dn}[distName]
            ${left_side_string}  Fetch From Left  ${rmod_l_dn}[distName]  /EQM_L
            ${rmod_side}  Fetch From Right  ${left_side_string}  /BTS_L-
            BREAK
        ELSE
            CONTINUE
        END
    END
    Should Not Be Empty  ${rmod_ip}  RMOD ip not set correctly. [NOK]
    Should Not Be Empty  ${rmod_side}  RMOD side is not set correctly. [NOK]
    Should Not Be Empty  ${rmod_r_dn}  RMOD_R dist name is not set correctly. [NOK]
    Should Not Be Empty  ${rmod_sn}  RMOD serial number is not set correctly. [NOK]
    IF  ${rmod_side}==1
        ${rmod_side}  Set Variable  1
    ELSE IF  ${rmod_side}==4
        ${rmod_side}  Set Variable  2
    END
    Log  RMOD with serial number: ${rmod_sn} has the ip: ${rmod_ip}.  console=true
    ${bbmod_l_dn}  Get BBMOD Logical Object From BBMOD Runtime Object Mapped On A Given RMOD  ${rmod_r_dn}
    ${stored_role}  Get StoredRole From MODULE_L  ${bbmod_l_dn}
    ${stored_role}  Set Variable  ${stored_role}

    RETURN  ${rmod_side}  ${rmod_ip}  ${stored_role}  ${rmod_sn}


Get Logical Object From Runtime Reference
    [Arguments]  ${rmod_r_dn}

    FOR  ${index}  IN RANGE  1  4
        ${status_ref}  ${rmod_l_dn}  Run Keyword And Ignore Error  coam.Get Parameters  ${rmod_r_dn}/REF-${index}
        IF  '${status_ref}'=='PASS'  BREAK
    END

    RETURN  ${rmod_l_dn}


Get BBMOD Logical Object From BBMOD Runtime Object Mapped On A Given RMOD
    [Documentation]
    ...  This keyword finds the BBMOD_L distName based on the RMOD_R distName.
    ...  *AUTHOR* cosmina.rebenciuc@nokia.com
    [Arguments]  ${rmod_r_dn}

    ${cablinks}  Get Parameters For All  cablink
    ${cablink_ecpri_list}  Create List
    FOR  ${cablink}  IN  @{cablinks}
        IF  '${rmod_r_dn}'=='${cablink}[secondEndpointDN]' and '${cablink}[linkModeSynchronization]'=='True'
            ${bbmod_r_dn}  Set Variable  ${cablink}[firstEndpointDN]
        END
    END
    Should Not Be Empty  ${bbmod_r_dn}  BBMOD_R dist name is not set correctly. [NOK]
    ${bbmod_parameters}  coam.Get Parameters  ${bbmod_r_dn}
    ${bbmod_product_name}  Fetch From Left  ${bbmod_parameters}[productName]  ${SPACE}
    ${bbmod_product_name}  Set Variable  ${bbmod_product_name}
    ${ref_object}  coam.Get Parameters  ${bbmod_r_dn}/POWERGROUP_R-1/REF-1
    IF  '${bbmod_product_name}' in ['ABIP','ABIQ']
        ${bbmod_l_dn}  Fetch From Left  ${ref_object}[distName]  /BOARD
    ELSE
        ${bbmod_l_dn}  Fetch From Left  ${ref_object}[distName]  /BBU
    END
    Should Not Be Empty  ${bbmod_l_dn}  BBMOD_L dist name is not set correctly. [NOK]

    RETURN  ${bbmod_l_dn}


Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port
    [Documentation]
    ...  This kw connects to RMOD through lxc-attach and telnet.
    ...  If ${smod_side} is 1, only primary core connection is opened.
    ...  If ${smod_side} is 2, secondary core connection is opened too.
    ...  Example of usage:
    ...  Connect to RMOD through lxc-attach and telnet using rmod ip, side and port  172.16.10.128
    ...                                                                      2
    ...                                                                      2323
    ...                                                                      Idle
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${rmod_ip}  ${smod_side}  ${port}  ${smod_stored_role}=Active

    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    IF  '${smod_stored_role}'=='Idle'
        Open Connection To Secondary Core
        SSHLibrary.Set Client Configuration  prompt=>
    END
    SSHLibrary.Write  lxc-attach -n 0x${smod_side}018
    SSHLibrary.Read Until Prompt
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(>|\\$)
    SSHLibrary.Write  telnet ${rmod_ip} ${port}
    SSHLibrary.Read Until Prompt
    Log  RMOD telnet connection opened.  console=true
