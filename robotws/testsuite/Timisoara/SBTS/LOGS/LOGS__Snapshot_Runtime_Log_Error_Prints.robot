*** Settings ***
Documentation  LOGS__Snapshot_Runtime_Log_Error_Prints
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      2400                      #timeout for collect snapshot via Admin (in sec)

${USERNAME}=     toor4nsn
${PASSWORD}=    oZPS0POrRieRtu

*** Keywords ***
LOGS__Snapshot_Runtime_Log_Error_Prints
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18725
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to check if runtime_SYSTEM.log file contains ERR/ and VIP/ prints.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 22.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18725 - Initial creation
    ...  - 04.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18964
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2022-08-24 - https://jiradc.ext.net.nokia.com/browse/TAT-23590 - enhancement: perform DSP crash on ASIL SMOD
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Snapshot_Runtime_Log_Error.png#
    ...

    Set Tags      CA-LOGS  OWNER-lukasz.targonski@nokia.com  AUTHOR-lukasz.targonski@nokia.com  MAINTAINER-iuliia.taupeka@nokia.com
    ...           GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT  SW-SBTS17  SW-SBTS18  SW-SBTS19    FEATURE-CNI-42395

    Step 1: Perform Dsp Crash
    Step 2: Collect Snapshot
    Step 3: Check ERR/VIP Prints In Runtime Logs

Step 1: Perform Dsp Crash
    ${sm_variant}=  pm_logs_general.Get SMOD variant
    ${DSP_ID}=  Run Keyword if   '${sm_variant[0]}'=='ASIA' and '${sm_variant[1]}'=='FSMF'    Return Core Id With Highest Number
    ...         ELSE   Return Core Id With Lowest Number
    Set Test Variable  ${DSP_ID}
    Log  \nStep 1: Trigger crash of DSP ${DSP_ID}  console=${True}
    Log  Run 'rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}'  console=${TRUE}
    ${SMOD_IP_with_tested_DSP}=    Return SMOD IP With Tested DSP
    ${sm_variant}=  Set variable  ${sm_variant[0]}

    Run Keyword If  '${sm_variant}'=='FSMF' or '${sm_variant}'=='ASIA' or '${sm_variant}'=='ASIB'  Run Keywords
    ...  Log  DSP crash will be performed on ${sm_variant} SMOD  console=${TRUE}
    ...  AND  ssh_utils.Perform Dsp Crash  ${DSP_ID}  ${SMOD_IP_with_tested_DSP}
    ...  ELSE IF  '${sm_variant}'=='ASIL' or '${sm_variant}'=='ASIM'  Run Keywords
    ...  Log  DSP crash will be performed on ASIL SMOD  console=${TRUE}
    ...  AND  Perform Dsp Crash Via ASIL    ${SMOD_IP_with_tested_DSP}    ${DSP_ID}
    ...  ELSE  verdicts.Set Test Failed  DSP crash will not be performed. Unknown SMOD type= ${sm_variant}.  ${TRUE}

    Log  Wait around 15 min for recovery action and for check if alarm 6450 raised.  console=${TRUE}
    ${expected_fault}=  Create Dictionary  faultId=6450
    ${expected_fault}=  Create List  ${expected_fault}
    ${ignored_fault}=  Create Dictionary  faultId=6707
    ${ignored_fault}=  Create List  ${ignored_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  15 min  30 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}  ignored_patterns=${ignored_fault}
    Run keyword unless  ${status}  Fail  Fault 6450 was not received.
    Log  Fault 6450 is reported  console=${TRUE}
    Wait Until Keyword Succeeds  10m  1m  Check All Modules And All Cells Working States


Step 2: Collect Snapshot
    Log  \nStep 2: Collect Snapshot  console=${True}
    @{time}=    Get Time    year month day hour min
    Set Test Variable  ${SNAPSHOT_LOCATION}  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${SNAPSHOT_LOCATION}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

Step 3: Check ERR/VIP Prints In Runtime Logs
    Log  \nStep 3: Check ERR/VIP Prints In Runtime Logs  console=${True}
    ${log_file_location}  Extract System Log File
    ${error_prints}  OperatingSystem.Grep File  ${log_file_location}/runtime_SYSTEM.log  ERR/
    ${vip_prints}  OperatingSystem.Grep File  ${log_file_location}/runtime_SYSTEM.log  VIP/
    ${error_prints_len}  Get Length  ${error_prints}
    ${vip_prints_len}  Get Length  ${vip_prints}
    Run Keyword If  ${error_prints_len} == 0  Fail  No ERR/ prints in runtime_SYSTEM.log file
    ...  ELSE  Log  ERR/ prints found in runtime_SYSTEM.log file  console=${TRUE}
    Run Keyword If  ${vip_prints_len} == 0  Fail  No VIP/ prints in runtime_SYSTEM.log file
    ...  ELSE  Log  VIP/ prints found in runtime_SYSTEM.log file  console=${TRUE}

Extract System Log File
    ${bts_id}  bts_states.Get BTS ID
    ${log_name_prefix}  Set Variable  BTS${bts_id}_${DSP_ID[2]}
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${SNAPSHOT_LOCATION}.zip
    ${part_number_with_runtime_zip}  Set variable  ${False}
    FOR  ${log_file}  IN  @{found_file_dict.keys()}
      ${runtime_zip_file}  Get Regexp Matches  ${log_file}  ${log_name_prefix}011_runtime.zip
      ${part_number_with_runtime_zip}  Run Keyword If  ${runtime_zip_file}  Get Regexp Matches  ${found_file_dict["${log_file}"][0]}  part_(\\d+)  1
      ...  ELSE  Set Variable  ${False}
      Exit For Loop If  ${part_number_with_runtime_zip}
    END

    ${bts_id}  bts_states.Get BTS ID
    ${runtime_zip_name}  Set Variable  ${log_name_prefix}011_part_${part_number_with_runtime_zip[0]}
    unpacking.Unpack Archive Content To Directory
    ...  ${SNAPSHOT_LOCATION}.zip
    ...  ${SNAPSHOT_LOCATION}
    unpacking.Unpack Archive Content To Directory
    ...  ${SNAPSHOT_LOCATION}/${runtime_zip_name}.zip
    ...  ${SNAPSHOT_LOCATION}/${runtime_zip_name}
    unpacking.Unpack Archive Content To Directory
    ...  ${SNAPSHOT_LOCATION}/${runtime_zip_name}/${log_name_prefix}011_runtime.zip
    ...  ${SNAPSHOT_LOCATION}/${runtime_zip_name}/${log_name_prefix}011_runtime
    unpacking.Unpack Archive Content To Directory
    ...  ${SNAPSHOT_LOCATION}/${runtime_zip_name}/${log_name_prefix}011_runtime/runtime_SYSTEM.log.xz
    ...  ${SNAPSHOT_LOCATION}/${runtime_zip_name}/${log_name_prefix}011_runtime/runtime_SYSTEM_log

    [Return]  ${SNAPSHOT_LOCATION}/${log_name_prefix}011_part_${part_number_with_runtime_zip[0]}/${log_name_prefix}011_runtime/runtime_SYSTEM_log

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded    console=${TRUE}
    Set Test Variable    ${path_to_snapshot}    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip

Return Core Id With Lowest Number
    ${all_core_ids_objects}=  Query Infomodel  get list //CORE_L-* is [type=DSP]
    ${all_core_ids}  Create List
    FOR  ${core_id}  IN  @{all_core_ids_objects}
      ${core_id_in_hex}=  Evaluate  hex(${core_id.nodeId})
      Append To List  ${all_core_ids}  ${core_id_in_hex}
    END
    Sort List  ${all_core_ids}
    [Return]  ${all_core_ids[0]}

Return Core Id With Highest Number
    ${all_core_ids_objects}=  Query Infomodel  get list //CORE_L-* is [type=DSP]
    ${all_core_ids}  Create List
    FOR  ${core_id}  IN  @{all_core_ids_objects}
      ${core_id_in_hex}=  Evaluate  hex(${core_id.nodeId})
      Append To List  ${all_core_ids}  ${core_id_in_hex}
    END
    Sort List  ${all_core_ids}
    [Return]  ${all_core_ids[-1]}

Return SMOD IP With Tested DSP
    ${smods_obj}=  Query Infomodel  get list //SMOD_L-*
    Return From Keyword If  len(${smods_obj}) == 1
    ...  ${SMOD1['IP']}
    FOR  ${obj}  IN  @{smods_obj}
        ${smod_ip}=  Return Ip Sysmod With Tested DSP For Dual Core  ${obj}
        Return From Keyword If  ${obj.nodeIdMaster} != ${obj.nodeIdOwn}
        ...  ${smod_ip}
    END

Return Ip Sysmod With Tested DSP For Dual Core
    [Arguments]  ${obj}
    ${hex_map}=  Decode Hex  ${obj.nodeIdMaster}  ${obj.nodeIdOwn}
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.extension[2]}  192.168.255.7
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.master[2]}  ${SMOD1['IP']}

Decode Hex
    [Arguments]    ${master}    ${extension}
    ${m_hex}=  Evaluate  hex(${master})
    ${e_hex}=  Evaluate  hex(${extension})
    ${hex_map}=  Create Dictionary  master=${m_hex}  extension=${e_hex}
    [Return]  ${hex_map}

Perform Dsp Crash Via ASIL
    [Documentation]
    ...         ASIL SMOD onwards there is other way to trigger DSP crash. It will be performed using command:
    ...         to be sent to perform crash.
    [Arguments]  ${SMOD_IP_with_tested_DSP}    ${DSP_ID}
    ${dsp_id_str}=  hran_file_operations.Dsp id strip  ${DSP_ID}
    Set test variable  ${dsp_id_str}
#    ${bsh_pattern}=  Prepare BSH Pattern  ${dsp_id_str}
    ${fsp_pattern}=  Prepare FSP_ID Pattern  ${dsp_id_str}   ${SMOD_IP_with_tested_DSP}
#    ssh_utils.Setup SMOD Connection  ${SMOD_IP_with_tested_DSP}
#    ${crash_result}  ssh_utils.Run Command  bsh ${bsh_pattern} 'rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}'
#    Log  Output after crash command sending: ${crash_result}.  console=${True}
    SSHLibrary.Open Connection    ${SMOD_IP_with_tested_DSP}
    SSHLibrary.Login             ${USERNAME}         ${PASSWORD}
    Sleep                        2s
    SSHLibrary.Write    rm -f .ssh/known_hosts
# Start SSH to FSP-id
   SSHLibrary.Write    ssh -tt ${USERNAME}@${fsp_pattern}

    ${output}=    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""    Write    yes

    SSHLibrary.Read Until         Password:
    SSHLibrary.Write              ${PASSWORD}

    SSHLibrary.Write  rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}

#Prepare BSH Pattern
#    [Documentation]
#    ...         Based on entry test parameter (dsp ID) keyword prepares pattern for BSH execute command
#    ...         to be sent to perform crash.
#    [Arguments]    ${dsp_id_str}
#    ${bb_position}  Run Keyword If  '${dsp_id_str[1]}'=='2'
#    ...  Set Variable  1
#    ...  ELSE IF  '${dsp_id_str[1]}'=='3'  Set Variable  2
#    ...  ELSE IF  '${dsp_id_str[1]}'=='4'  Set Variable  3
#    ...  ELSE  Log  Wrong dsp ID.
#    ${dsp_num}  Run Keyword If  '${dsp_id_str[2]}'=='3'
#    ...  Set Variable  0
#    ...  ELSE IF  '${dsp_id_str[1]}'=='4'  Set Variable  1
#    ...  ELSE IF  '${dsp_id_str[1]}'=='5'  Set Variable  2
#    ...  ELSE IF  '${dsp_id_str[1]}'=='6'  Set Variable  3
#    ...  ELSE  Log  Wrong dsp ID.
#    ${bsh_pattern}=	 Catenate	SEPARATOR=:	${bb_position}	${dsp_num}
#    Log   Pattern for BSH command- ${bsh_pattern}  console=${True}
#    [Return]  ${bsh_pattern}

Prepare FSP_ID Pattern
    [Arguments]    ${dsp_id_str}    ${SMOD_IP_with_tested_DSP}
    ${sm_position}  Run Keyword If  '${SMOD_IP_with_tested_DSP}'=='192.168.255.129'
    ...  Set Variable  1
    ...  ELSE IF  '${SMOD_IP_with_tested_DSP}'=='192.168.255.7'  Set Variable  2
    ...  ELSE  Log  Wrong SMOD ID.
    ${bb_position}  Run Keyword If  '${dsp_id_str[1]}'=='2'
    ...  Set Variable  1
    ...  ELSE IF  '${dsp_id_str[1]}'=='3'  Set Variable  2
    ...  ELSE IF  '${dsp_id_str[1]}'=='4'  Set Variable  3
    ...  ELSE  Log  Wrong dsp ID.
    ${dsp_num}  Run Keyword If  '${dsp_id_str[2]}'=='3'
    ...  Set Variable  a
    ...  ELSE IF  '${dsp_id_str[1]}'=='4'  Set Variable  b
    ...  ELSE IF  '${dsp_id_str[1]}'=='5'  Set Variable  c
    ...  ELSE IF  '${dsp_id_str[1]}'=='6'  Set Variable  d
    ...  ELSE  Log  Wrong dsp ID.
    ${fsp_pattern}=	 Set Variable  fsp-${sm_position}-${bb_position}${dsp_num}
    [Return]  ${fsp_pattern}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
