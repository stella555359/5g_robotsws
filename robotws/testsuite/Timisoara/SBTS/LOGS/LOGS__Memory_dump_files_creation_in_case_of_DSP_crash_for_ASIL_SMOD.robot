*** Settings ***
Documentation  Test Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/infomodel.robot
Library    hran_file_operations
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Library    taf.transport.ssh  WITH NAME  ssh

*** Variables ***
${DSP_ID}                   ${Empty}
# DSP to be crashed; First number is SM number (1,2), second is BBU (2-4), third is DSP (3-8), fourth is core (1-4); Example: 0x1231
${SITE_RESET}               False
# If set to True, BTS site reset will be triggered at the beginning of a TC; if set False (default), site reset will not be triggered
${STARTUP_TIMEOUT}          10        # Timeout for BTS to startup after reset, default value 10 [min]
${FAULT_TIMEOUT}            15        # Timeout for alarm to be reported, default value 15 [min]
${VERIFICATION_TIMEOUT}     3         # Timeout for verification to check if BTS is onAir after DSP crash
${MEMDUMP_PATTERN}          (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
${DSP_RUNTIME_PATTERN}      [1-2]011_crash_{}00_RT\\.log\\.zip$
${DSP_MEMDUMP_PATTERN}         {}00\\w+MEMDUMP\\.bin.*
${SRIO_DIO_INTERFACE_PATERN}   riomemfs-logdump  #other memdump fetching scenario
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${FSP_ID}           fsp-3a
${SSH_COMMAND_BBMOD}      ssh -tt ${BTS_login}@${FSP_ID}
${KNOWN_WARNING}    Are you sure you want to continue connecting
${PASSWORD_PROMPT}  password:
${DSP_CRASH_CMD}    rioboot -c read -a 0x10800000 -n 0x1000000

*** Keywords ***
TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21069
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test is to verify that memory dump files are created in case of DSP crash and if those files are
    ...  saved into snapshot once triggered. Test is created for only ASIL SM type verification.
    ...  In case of other SM types, please refer to TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.06.2021 - TAT-21069 - initial test case creation
    ...  - 06.12.2021 - TAT-22312 - bug fix
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 28.04.2023 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-21069.png#


    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-iuliia.taupeka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS21
    ...    FEATURE-RP001145_CNI7858    FEATURE-RP002324

    Run keyword if  ${SITE_RESET}  BTS site reset on demand
    Step 0: TC preconditions
    Step 1: Trigger DSP crash
    Step 2: Verify presence of DSP memory dumps
    Step 3: Collect snapshot
    Step 4: Check All Required State


BTS site reset on demand
    [Documentation]
    ...     Within this KW BTS site reset is performed if user had set site_reset variable to True.

    Log  Perform BTS site reset  console=yes
    coam.Reset Site  600
    Sleep  5s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  Verify all BTS states
    Log  All cells and modules reached working state  console=yes
    bts_states.Check Active Alarms

Step 0: TC preconditions
    [Documentation]
    ...         Within TC preconditions rel4 ASIL SM recognition is done first and then
    ...         keyword connects to BTS via SSH and checks if folder ${MEM_DUMPS_PATH} is empty or not.
    ...         If entry parameter ${DSP_ID} is empty in testsuite, crash will be performed for the lowest DSP ID
    ...         available on BTS.
    ...         If folder is not empty - local copy of this folder is created in TC logs in BTSFiles and
    ...         variable prev_fsp_id is set.

    Log  Step 0: Preconditions  console=yes
    ${bts_connection}=  coam.connect_to
    ${DSP_ID}  Run Keyword If  '${DSP_ID}'=='${Empty}'
    ...  Return Core Id With Lowest Number
    ...  ELSE  Set Variable  ${DSP_ID}
    Set Test Variable  ${DSP_ID}
    Log  DSP_ID value: ${DSP_ID}  console=${True}

    ${active_alarms}  coam.Get Alarms
    FOR  ${fault}  IN  @{active_alarms}
      Run Keyword If  '${fault['faultId']}'=='6450'  Run Keywords
      ...  Log  Alarm with fault 6450 is visible. Snapshot will be collected.  console=${True}
      ...  AND  coam.Collect Snapshot  ${BTS_Files}/snapshot_preconditions  timeout=1200
    END

    ${SMOD_IP_with_tested_DSP}=    Return SMOD IP With Tested DSP
    Log  SMOD IP of tested DSP: ${SMOD_IP_with_tested_DSP}  console=${True}
    Set test variable    ${SMOD_IP_with_tested_DSP}

    Create 'MemoryDumpFiles' in '${Test Results Dir}' and set test variable

    ${dsp_id_str}=  hran_file_operations.Dsp id strip  ${DSP_ID}
    Set test variable  ${dsp_id_str}

    Log  TC preconditions: Check SM variant (could be only ASIL or ASIL+ASIL)  console=yes
    ${sm_variant}=  Get New SM variant
    ${sm_variant}=  Verify SMOD variant  ${sm_variant}   ${dsp_id_str}
    Set test variable  ${sm_variant}
    ${enb_release}  coam.get sw release name
    ${MEM_DUMPS_PATH}=  Run keyword if  '${enb_release}'=='SBTS23R1' or '${enb_release}'=='SBTS22R4'  Build diagn path for rel4  ${dsp_id_str}
    ...     ELSE  set variable  /ffs/run/logs/dspdumps/3/A
    Set test variable  ${MEM_DUMPS_PATH}

    ${prev_fsp_id_list}=  Create list
    Set test variable  ${prev_fsp_id_list}

    Log  Check if folder (${MEM_DUMPS_PATH}) for dsp memory dumps exists on BTS and if is empty  console=yes
    ${dir_exists}=  ssh_utils.Check if directory exists    ${MEM_DUMPS_PATH}  ${SMOD_IP_with_tested_DSP}
    Run keyword unless  ${dir_exists}  Return from keyword
    ${diagn_content}=  Collect list of files in 'Step_0'
    ${diagn_content_size}=  Get length  ${diagn_content}

    ${prev_fsp_id_list}=  Run keyword if  ${diagn_content_size} > 0
    ...  hran_file_operations.Get bbu id on which dsp crashed  ${diagn_content}  ${MEMDUMP_PATTERN}
    ...  ELSE  Set variable  @{EMPTY}

Verify SMOD variant
    [Documentation]
    ...         Return SMOD variant for crashed DSP
    [Arguments]  ${sm_variant}  ${dsp_id_str}
    Return From Keyword If    len(${sm_variant})==1   ${sm_variant[0]}
    ${tmp_sm_variant}=    Evaluate    '${sm_variant[0]}' if '${sm_variant[0]}'=='${sm_variant[1]}' else '${EMPTY}'
    ${sm_variant}=    Evaluate    '${sm_variant[0]}' if '${tmp_sm_variant}'=='${EMPTY}' and '${dsp_id_str[0]}'=='1' else '${sm_variant[1]}'
    Return From Keyword   ${sm_variant}

Return Ip Sysmod With Tested DSP For Dual Core
    [Arguments]  ${obj}
    ${hex_map}=  Decode Hex  ${obj.nodeIdMaster}  ${obj.nodeIdOwn}
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.extension[2]}  fct-4a
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.master[2]}  ${SMOD1['IP']}

Decode Hex
    [Arguments]    ${master}    ${extension}
    ${m_hex}=  Evaluate  hex(${master})
    ${e_hex}=  Evaluate  hex(${extension})
    ${hex_map}=  Create Dictionary  master=${m_hex}  extension=${e_hex}
    [Return]  ${hex_map}

Return SMOD IP With Tested DSP
    ${smods_obj}=  Query Infomodel  get list //SMOD_L-*
    Return From Keyword If  len(${smods_obj}) == 1
    ...  ${SMOD1['IP']}
    FOR  ${obj}  IN  @{smods_obj}
        ${smod_ip}=  Return Ip Sysmod With Tested DSP For Dual Core  ${obj}
        Return From Keyword If  ${obj.nodeIdMaster} != ${obj.nodeIdOwn}
        ...  ${smod_ip}
    END
    Fail  Unable map dsp to smod.

Download File From SYSMOD
    [Arguments]    ${Destination_place}
    Run Keyword If    '${SMOD_IP_with_tested_DSP}' == 'fct-4a'
    ...  ssh_utils.Download Directory From ESM Via VM  ${PC_IP2}  ${MEM_DUMPS_PATH}  ${Destination_place}
    ...  ELSE
    ...  ssh_utils.Download Directory  ${MEM_DUMPS_PATH}  ${Destination_place}  ${SMOD1['IP']}

Return Core Id With Lowest Number
    ${all_core_ids_objects}=  Query Infomodel  get list //CORE_L-* is [type=DSP]
    ${all_core_ids}  Create List
    FOR  ${core_id}  IN  @{all_core_ids_objects}
      ${core_id_in_hex}=  Evaluate  hex(${core_id.nodeId})
      Append To List  ${all_core_ids}  ${core_id_in_hex}
    END
    Sort List  ${all_core_ids}

    [Return]  ${all_core_ids[0]}

Get New SM variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is primary core, second (if exist) - secondary core
    ...
    ...  | **Author:** iuliia.taupeka@nokia.com
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  infomodel.Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (ASIB|ASIAB|ASIL)
	    Append To List  ${sm_variant}  ${match}
	END
	Log   Short SM variant name: ${sm_variant}  console=yes
	[Return]  ${sm_variant}


Step 1: Trigger DSP crash
    [Documentation]
    ...         DSP provided by user is crashed using shell rioboot cmd.
    ...         Active alarms on SBTS are checked for fault 6450

    Log  Step 1: Trigger crash of DSP ${DSP_ID}  console=yes
    Log  Command 'rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}' will run from apropriate ABIA module.   console=yes

    ${bsh_pattern}=  Prepare BSH Pattern  ${dsp_id_str}
    Run Keyword If  '${SMOD_IP_with_tested_DSP}'=='fct-4a'  Perform DSP Crash From Secondary Core  ${bsh_pattern}
    ...  ELSE  Perform DSP Crash From Primary Core

    Log  Wait for recovery action  console=yes
    Log  Wait ${FAULT_TIMEOUT} min to check if alarm 6450 raised.  console=yes

    ${expected_fault}=  Create Dictionary  faultId=6450
    ${expected_fault}=  Create List  ${expected_fault}
    ${ignored_fault}=  Create Dictionary  faultId=6707
    ${ignored_fault}=  Create List  ${ignored_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  ${FAULT_TIMEOUT} min  30 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}  ignored_patterns=${ignored_fault}
    Run keyword unless  ${status}  Fail  Fault 6450 was not received.
    Log  Fault 6450 is reported  console=yes

Prepare BSH Pattern
    [Documentation]
    ...         Based on entry test parameter (dsp ID) keyword prepares pattern for BSH execute command
    ...         to be sent to perform crash.
    [Arguments]    ${dsp_id_str}
    ${bb_position}  Run Keyword If  '${dsp_id_str[1]}'=='2'
    ...  Set Variable  1
    ...  ELSE IF  '${dsp_id_str[1]}'=='3'  Set Variable  2
    ...  ELSE IF  '${dsp_id_str[1]}'=='4'  Set Variable  3
    ...  ELSE  Log  Wrong dsp ID.
    ${dsp_num}  Run Keyword If  '${dsp_id_str[2]}'=='3'
    ...  Set Variable  0
    ...  ELSE IF  '${dsp_id_str[1]}'=='4'  Set Variable  1
    ...  ELSE IF  '${dsp_id_str[1]}'=='5'  Set Variable  2
    ...  ELSE IF  '${dsp_id_str[1]}'=='6'  Set Variable  3
    ...  ELSE  Log  Wrong dsp ID.
    ${bsh_pattern}=	 Catenate	SEPARATOR=:	${bb_position}	${dsp_num}
    Log   Pattern for BSH command- ${bsh_pattern}  console=${True}
    [Return]  ${bsh_pattern}

Perform DSP Crash From Primary Core
    [Documentation]
    ...         Keyword performs DSP crash on ASIL primary core
    ...         if DSP is placed on MSM.

    Log  DSP crash will be performed using bsh command from primary core.  console=${True}

    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login             ${BTS_login}    ${BTS_password}
    Sleep                        2s
    SSHLibrary.Write    rm -f .ssh/known_hosts
    # Start SSH to FSP-id
    SSHLibrary.Write    ${SSH_COMMAND_BBMOD}

    ${output}=    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""    Write    yes

    SSHLibrary.Read Until         assword:
    SSHLibrary.Write         ${BTS_password}

    Sleep                        2s
    log to console     comanda este:${DSP_CRASH_CMD} ${DSP_ID}
    SSHLibrary.Write    ${DSP_CRASH_CMD} ${DSP_ID}

#    SSHLibrary.write  bsh ${bsh_pattern}
#    Sleep    3s
#    SSHLibrary.Read
#    log  execute command to trigger dsp crash: rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}  console=${True}
#    ${crash_result}    SSHLibrary.write    rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}
#    Sleep    3s

Perform DSP Crash From Secondary Core
    [Documentation]
    ...         Keyword performs DSP crash on ASIL secondary core
    ...         if DSP is placed on ESM.
    [Arguments]    ${bsh_pattern}
    Log  DSP crash will be performed using bsh command from secondary core reached from primary core.  console=${True}
    Log  ssh.Connect To: hostname=${PC_IP2}  console=${True}
    ssh.Connect To     hostname=${ESM_VM_ip}    username=ute    password=oZPS0POrRieRtu  alias=slave_vm
    ssh.Connect To     hostname=192.168.255.119   username=toor4nsn    password=oZPS0POrRieRtu     proxy=slave_vm
    Log  run: bsh ${bsh_pattern} 'rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}'  console=${True}
    ssh.Execute        bsh ${bsh_pattern}
    Sleep    3s
    ssh.Execute        rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}
    Sleep    3s

Step 2: Verify presence of DSP memory dumps
    [Documentation]
    ...         Content of /ffs/run/logs/diagn directory is checked for
    ...         mandatory files: memory dumps and runtime files.

    Log  Step 2: Verify presence of DSP memory dumps  console=yes
    ${new_fsp_id}=  hran_file_operations.Get bbu id from dsp id  ${dsp_id_str}
    ${status}=  Run keyword and return status  List Should Not Contain Value  ${prev_fsp_id_list}  ${new_fsp_id}
    Run keyword unless  ${status}  Run keywords
    ...         verdicts.Set Test Restriction  Memory dumps for the affected DSP already exist. New dumps won't be fetched.  AND
    ...         Return from keyword

    Log  Check if diagn directory on BTS exists and if is empty  console=yes
    ${files}=  ssh_utils.List remote directory  ${MEM_DUMPS_PATH}
    Should not be empty  ${files}  msg=Directory diagn is empty; memory dumps not collected successfully!
    ${diagn_content}=  Collect list of files in 'Step_2'

    Log  Check if all mandatory files are stored in diagn directory  console=yes
    ${mand_files_exist}=  hran_file_operations.Verify mandatory files
    ...     ${diagn_content}  ${dsp_id_str}  ${DSP_RUNTIME_PATTERN}  ${DSP_MEMDUMP_PATTERN}
    Run keyword unless  ${mand_files_exist}  Fail  Not all mandatory files found!

    # create dictionary of mandatory files
    ${bts_id}  bts_states.Get BTS ID
    Create Mandatory Files Dict  ${diagn_content}  ${bts_id}

    ${additional_files_exist}=  hran_file_operations.Verify additional files  ${diagn_content}  ${dsp_id_str}  ${DSP_MEMDUMPER_PATTERN}
    Run keyword unless  ${additional_files_exist}  verdicts.Set Test Restriction  Not all additional files found!
    Wait Until Keyword Succeeds  10m  1m  Check All Modules And All Cells Working States

Create Mandatory Files Dict
    [Arguments]  ${diagn_content}  ${bts_id}
    ${status}=  Run keyword and return status  Should Contain Match  ${diagn_content}  regexp=.*${SRIO_DIO_INTERFACE_PATERN}.*
    ${mandatory_files_dict}=  Run Keyword If  ${status}
    ...  hran_file_operations.Create dictionary of mandatory files
    ...  ${diagn_content}  ${dsp_id_str}  ${DSP_RUNTIME_PATTERN}  ${DSP_MEMDUMP_PATTERN}  ${bts_id}  ${sm_variant}  add_prefix=False
    ...  ELSE
    ...  hran_file_operations.Create dictionary of mandatory files
    ...  ${diagn_content}  ${dsp_id_str}  ${DSP_RUNTIME_PATTERN}  ${DSP_MEMDUMP_PATTERN}  ${bts_id}  ${sm_variant}
    Set test variable  ${mandatory_files_dict}


Step 3: Collect snapshot
    Log  Step 3: Start snapshot collection  console=yes
    ${timestamp}=  Get time
    ${timestamp}=  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}  timeout=1200

    Sleep  10s
    Log  Check if diagn directory on BTS is empty  console=yes
    ${files}=  ssh_utils.List remote directory  ${MEM_DUMPS_PATH}
    ${diagn_content}=  Run Keyword If  """${files}"""  Collect list of files in 'Step_3'
    Run Keyword If  """${files}"""  Should be empty  ${diagn_content}  msg=Directory diagn is not empty!
    ...         ELSE  Log  Directory diagn is empty.  console=yes

    Set global variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}
    ${found_file_dict}  snapshot.Get data from snapshot  ${path_to_snapshot}
    snapshot.Validate snapshot using custom data  ${found_file_dict}  ${mandatory_files_dict}

    Log  Check if fault 6450 is cleared  console=yes
    ${critical_fault}=  Create Dictionary  fault=6450
    ${critical_fault}=  Create List   ${critical_fault}
    bts_states.Check Active Alarms  critical_patterns=${critical_fault}

Collect list of files in '${dirname}'
    Create '${dirname}' in '${MemoryDumpFiles}' And Set Test Variable
    Download File From SYSMOD  ${${dirname}}
    ${diagn_content}=  hran_file_operations.Get all files from dir  ${${dirname}}  subdir=${True}
    ${status}=  Run keyword and return status  Should Contain Match  ${diagn_content}  regexp=.*${SRIO_DIO_INTERFACE_PATERN}.*
    Return From Keyword If      not ${status}    ${diagn_content}
    ${diagn_content_of_tar}=  snapshot.Get Files List From Tar  ${${dirname}}/dspdumps/riomemfs-logdump-${dsp_id_str}-dump.tar
    ${diagn_content}=  Combine Lists  ${diagn_content_of_tar}  ${diagn_content}
    Return From Keyword     ${diagn_content}

Verify all BTS states
    [Arguments]  ${expected_BTS_status}=OnAir  ${modules_check}=${TRUE}  ${cells_check}=${TRUE}  #${alarms_check}=${TRUE}
    #...  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ${BTS_state_is_correct}=  Verify BTS proceduralState  ${expected_BTS_status}
    ${SMs_working}=  Run Keyword If  ${modules_check}  Verify system modules states
    ...  ELSE  Set Variable  ${TRUE}
    ${RMODs_working}=  Run Keyword If  ${modules_check}  Verify radio modules states
    ...  ELSE  Set Variable  ${TRUE}
    ${GSM_onair}=  Run Keyword If  ${cells_check}  Verify GSM cells states
    ...  ELSE  Set Variable  ${TRUE}
    ${WCDMA_onair}=  Run Keyword If  ${cells_check}  Verify WCDMA cells states
    ...  ELSE  Set Variable  ${TRUE}
    ${LTE_onair}=  Run Keyword If  ${cells_check}  Verify LTE cells states
    ...  ELSE  Set Variable  ${TRUE}

    Run Keyword Unless  ${BTS_state_is_correct} and ${SMs_working} and ${RMODs_working} and ${GSM_onair} and ${WCDMA_onair} and ${LTE_onair}
    ...  Fail  At least one module, cell or BTS proceduralState indicates a faulty state!

Step 4: Check All Required State
    Log  Step 4: Check All Required State  console=yes
    Wait Until Keyword Succeeds  ${VERIFICATION_TIMEOUT}m  2m  Verify all BTS states
    Log  All cells and modules reached working state  console=yes
    bts_states.Check Active Alarms


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown


