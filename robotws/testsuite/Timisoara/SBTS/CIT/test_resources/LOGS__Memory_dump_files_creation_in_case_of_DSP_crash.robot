*** Settings ***
Documentation
    ...  Test is to verify that memory dump files are created in case of DSP crash and if those files are
    ...  saved into snapshot once triggered.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${DSP_ID}  ${EMPTY}  # DSP to be crashed;
# First number is SM number (1,2), second is BBU (2-4), third is DSP (3-8), fourth is core (1-4); Example: 0x1231
${SITE_RESET}  False  # If set to True, BTS site reset will be triggered at the beginning of a TC;
# If set False (default), site reset will not be triggered
${STARTUP_TIMEOUT}  10  # Timeout for BTS to startup after reset, default value 10 [min]
${FAULT_TIMEOUT}  15  # Timeout for alarm to be reported, default value 15 [min]
${VERIFICATION_TIMEOUT}  3  # Timeout for verification to check if BTS is onAir after DSP crash
${SNAPSHOT_COLLECTION_TIMEOUT}  1200s  # Timeout for Snapshot Collection
${MEMDUMP_PATTERN}  (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
${DSP_MEMDUMPER_PATTERN}  memdumper_{}.+\\.log\\.xz$
${DSP_RUNTIME_PATTERN}  [1-2]011_crash_{}00_RT\\.log\\.zip$
${DSP_MEMDUMP_PATTERN}  {}00\\w+MEMDUMP\\.bin.*
${SRIO_DIO_INTERFACE_PATERN}  riomemfs-logdump  # other memdump fetching scenario
${CHECK_FILES_ON_SBTS}  True
${MEM_DUMPS_PATH}  ${EMPTY}


*** Keywords ***
TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5963
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.08.2017 - TAT-7414 - increase Site Reset Timeout
    ...  - 18.08.2017 - TAT-7433
    ...  - 14.09.2017 - TAT-7518 - Step 3 updated (to check if fault is cleared after snapshot is collected)
    ...  - 27.10.2017 - TAT-8008 - Memory dump TC fails as no prev_fsp_id_list variable is found
    ...  - 09.11.2017 - TAT-7964 - LOGS__Memory_dump_files_creation_in_case_of_DSP_crash: handling of Rel4
    ...  - 09.01.2018 - TAT-7809 - Replace references to LNBTS with MRBTS in SBTS17 TCs
    ...  - 09.01.2018 - TAT-7596 - Migration from ute_infomodel to ADMIN Abstraction Layer
    ...  - 10.01.2018 - TAT-8837 - Changes in TCs related to responsibilities handover
    ...  - 25.04.2018 - TAT-9562 - Add verification of files starting from parent forlder of dspdumps location
    ...  - 04.06.2018 - TAT-10281 - Get BTS ID from admin
    ...  - 06.06.2018 - TAT-10398 - Increase Timeout for ute_admin.Collect Snapshot to 600 sec
    ...  - 11.06.2018 - TAT-10476 - Increase timeout for alarm 6450
    ...  - 12.07.2018 - TAT-10652 - KW Build Diagn Path For Rel4 support for DualCore
    ...  - 31.07.2018 - TAT-11079 - Increase Timeout for ute_admin.Collect Snapshot to 1200 sec
    ...  - 24.12.2018 - TAT-13680 - Add verification to check if BTS is onAir after DSP crash
    ...  - 27.02.2019 - TAT-14330 - Support for ASIA+FSMF
    ...  - 28.02.2019 - TAT-13942 - Support backup memdump fetching feature
    ...  - 14.03.2019 - TAT-15188 - Support for SM ASIB
    ...  - 04.04.2019 - TAT-15661 - Change DSP_MEMDUMP_PATTERN
    ...  - 2019-05-22 - TAT-16256 - Change MAINTAINER and GROUP_IN_CHARGE
    ...  - 30.12.2019 - TAT-18656 - Add verification of fault 6450 presence before test execution
    ...  - 02.01.2020 - TAT-18684 - Add selection of core id to crash if no core id is provided
    ...  - 23.01.2020 - TAT-18802 - Add support for Rel4 default core selection
    ...  - 23.01.2020 - TAT-21996 - Turn snaphot timeout into variable
    ...  - 14.11.2022 - TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 13.10.2023 - TAT-25916 - Fix unccessary file check on SBTS
    ...  - 21.12.2023 - TAT-26619 - Add MEM_DUMP_PATH as test variable
    ...  - 12.01.2023 - TAT-26320 - Add Verify presence of DSP memory dumps
    ...  - 19.01.2024 - TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5963.png#

    Set Tags  CA-SWM  OWNER-lukasz.targonski@nokia.com  AUTHOR-joanna.bielawska@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001145_CNI7858  FEATURE-RP001486_CNI7858

    Run Keyword If  ${SITE_RESET}
    ...  BTS Site Reset On Demand
    Step 0: TC Preconditions
    Step 1: Trigger DSP Crash
    Step 2: Verify Presence Of DSP Memory Dumps
    Step 3: Collect Snapshot
    Step 4: Check All Required State


BTS Site Reset On Demand
    [Documentation]
    ...   Within this KW BTS site reset is performed if user had set site_reset variable to True.

    Log  Perform BTS site reset  console=true
    Reset Site  600
    Sleep  5s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m
    ...  Verify BTS States
    Log  All cells and modules reached working state  console=true
    Admin Check Active Alarms TAF


Step 0: TC Preconditions
    [Documentation]
    ...   Within TC preconditions rel3/rel4 recognition is done first and then
    ...   keyword connects to BTS via SSH and checks if folder ${MEM_DUMPS_PATH} is empty or not.
    ...   If folder is not empty - local copy of this folder is created in TC logs in BTSFiles and
    ...   variable prev_fsp_id is set.

    ${dsp_id}  Run Keyword If  '${DSP_ID}'=='${EMPTY}'
    ...  Return Core Id With Lowest Number
    ...  ELSE
    ...  Set Variable  ${DSP_ID}
    Set Test Variable  ${DSP_ID}

    ${active_alarms}  coam.Get Alarms
    FOR  ${fault}  IN  @{active_alarms}
        Run Keyword If  '${fault['faultId']}'=='${FAULT_6450}[fault_id]'
        ...  Run Keywords
        ...  Log  Alarm with fault 6450 is visible. Snapshot will be collected.  console=true
        ...  AND
        ...  Collect Snapshot  ${BTS_FILES}/snapshot_preconditions  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}
    END

    ${smod_ip_with_tested_dsp}  Return SMOD IP With Tested DSP
    Set Test Variable  ${SMOD_IP_WITH_TESTED_DSP}

    Create 'MemoryDumpFiles' In '${TEST_RESULTS_DIR}' And Set Test Variable

    ${dsp_id_str}  hran_file_operations.Dsp Id Strip  ${DSP_ID}
    Set Test Variable  ${DSP_ID_STR}

    Log  TC preconditions: Check SM variant (FSMF, ASIA, ASIB, FSMF+FSMF, ASIA+ASIA, ASIA+FSMF)  console=true
    ${sm_variant}  Get SM Variant
    ${sm_variant}  Verify SMOD Variant  ${sm_variant}  ${DSP_ID_STR}
    Set Test Variable  ${SM_VARIANT}
    Run Keyword If  '${MEM_DUMPS_PATH}'=='${EMPTY}'
    ...  Set Mem_dumps_path
    Run Keyword If  '${MEM_DUMPS_PATH}'=='/ffs/run/logs/diagn'
    ...  Delete Dummy File

    ${prev_fsp_id_list}  Create List
    Set Test Variable  ${PREV_FSP_ID_LIST}

    Log  Check if folder for dsp memory dumps exists on BTS and if is empty  console=true
    Connect To SMOD  ${SMOD_IP_WITH_TESTED_DSP}
    ${dir_exists}  ssh.File Exists  ${MEM_DUMPS_PATH}
    Run Keyword If  ${dir_exists}
    ...  Log  File exists!  console=true
    ...  ELSE
    ...  Return From Keyword
    ${diagn_content}  Collect List Of Files In 'Step_0'
    ${diagn_content_size}  Get Length  ${diagn_content}

    ${prev_fsp_id_list}  Run Keyword If  ${diagn_content_size} > 0
    ...  hran_file_operations.Get Bbu Id On Which Dsp Crashed  ${diagn_content}  ${MEMDUMP_PATTERN}
    ...  ELSE
    ...  Set Variable  @{EMPTY}
    Log  Collecting snapshot to clear logs before DSP crash  console==true
    Collect Snapshot  ${BTS_FILES}/snapshot_before_test  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}


Set Mem_dumps_path
    ${mem_dumps_path}  Run Keyword If  '${SM_VARIANT}'=='FSMF'
    ...  Set Variable  /ffs/run/logs/diagn
    ...  ELSE IF  '${SM_VARIANT}'=='ASIA' or '${SM_VARIANT}'=='ASIB'
    ...  Build Diagn Path For Rel4  ${DSP_ID_STR}
    Set Test Variable  ${MEM_DUMPS_PATH}


Verify SMOD Variant
    [Documentation]
    ...   Return SMOD variant for crashed DSP
    [Arguments]  ${sm_variant}  ${dsp_id_str}

    Return From Keyword If  len(${sm_variant})==1  ${sm_variant[0]}
    ${tmp_sm_variant}  Evaluate  '${sm_variant[0]}' if '${sm_variant[0]}'=='${sm_variant[1]}' else '${EMPTY}'
    ${sm_variant}  Evaluate  '${sm_variant[0]}' if '${tmp_sm_variant}'=='${EMPTY}' and '${dsp_id_str[0]}'=='1' else '${sm_variant[1]}'
    Return From Keyword  ${sm_variant}


Return Ip Sysmod With Tested DSP For Dual Core
    [Arguments]  ${obj}

    ${hex_map}  Decode Hex  ${obj.nodeIdMaster}  ${obj.nodeIdOwn}
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.extension[2]}  192.168.255.7
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.master[2]}  ${SMOD1['IP']}


Delete Dummy File
    [Documentation]
    ...   This KW delete bbtrace_snapshot_dummy from /ffs/run/logs/diagn

    ${dummy_file_name}  Set Variable  bbtrace_snapshot_dummy
    SSHLibrary.Open Connection  ${SMOD1['IP']}
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${file_list}  SSHLibrary.Execute Command  ls ${MEM_DUMPS_PATH}
    Run Keyword If  '''${file_list}'''=='''${dummy_file_name}'''
    ...  SSHLibrary.Execute Command  rm ${MEM_DUMPS_PATH}/${dummy_file_name}  AND  Log  ${dummy_file_name} was delete from ${MEM_DUMPS_PATH}
    ...  ELSE
    ...  Log  There are more files in ${MEM_DUMPS_PATH} directory, ${dummy_file_name} wasn't delete.
    SSHLibrary.Close Connection


Decode Hex
    [Arguments]  ${master}  ${extension}

    ${m_hex}  Evaluate  hex(${master})
    ${e_hex}  Evaluate  hex(${extension})
    ${hex_map}  Create Dictionary  master=${m_hex}  extension=${e_hex}
    [Return]  ${hex_map}


Return SMOD IP With Tested DSP
    ${smods_obj}  Query Infomodel  get list //SMOD_L-*
    Return From Keyword If  len(${smods_obj}) == 1  ${SMOD1['IP']}
    FOR  ${obj}  IN  @{smods_obj}
        ${smod_ip}  Return Ip Sysmod With Tested DSP For Dual Core  ${obj}
        Return From Keyword If  ${obj.nodeIdMaster} != ${obj.nodeIdOwn}  ${smod_ip}
    END
    Fail  Unable map dsp to smod.


Download File From SYSMOD
    [Arguments]  ${destination_place}

    ${downloaded_directory}  Download Directory  ${SMOD_IP_WITH_TESTED_DSP}  ${MEM_DUMPS_PATH}  ${destination_place}
    Untar Archive  ${downloaded_directory}  ${destination_place}


Return Core Id With Lowest Number
    ${all_core_ids_objects}  Query Infomodel  get list //CORE_L-* is [type=DSP]
    ${all_core_ids}  Create List
    FOR  ${core_id}  IN  @{all_core_ids_objects}
        ${core_id_in_hex}  Evaluate  hex(${core_id.nodeId})
        Append To List  ${all_core_ids}  ${core_id_in_hex}
    END
    Sort List  ${all_core_ids}

    [Return]  ${all_core_ids[0]}


Check Files On SBTS
    Log  Check if all mandatory files are stored in diagn directory  console=true
    ${mand_files_exist}  hran_file_operations.Verify Mandatory Files  ${DIAGN_CONTENT}  ${DSP_ID_STR}  ${DSP_RUNTIME_PATTERN}
    ...  ${DSP_MEMDUMP_PATTERN}
    Run Keyword If  ${mand_files_exist}
    ...  Log  All mandatory files was found!  console=true
    ...  ELSE
    ...  Fail  Not all mandatory files found!


Step 1: Trigger DSP Crash
    [Documentation]
    ...   DSP provided by user is crashed using shell rioboot cmd.
    ...   Active alarms on SBTS are checked for fault 6450

    Log  Step 1: Trigger crash of DSP ${DSP_ID}  console=true
    Log  Run 'rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}'  console=true
    Perform Dsp Crash  ${SMOD_IP_WITH_TESTED_DSP}  ${DSP_ID}
    Log  Wait for recovery action  console=true
    Log  Wait ${FAULT_TIMEOUT} min to check if alarm 6450 raised.  console=true
    ${expected_fault}  Create Dictionary  faultId=${FAULT_6450}[fault_id]
    ${expected_fault}  Create List  ${expected_fault}
    ${ignored_fault}  Create Dictionary  faultId=${FAULT_6707_RAT_AUTO_RST}[fault_id]
    ${ignored_fault}  Create List  ${ignored_fault}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FAULT_TIMEOUT} min  30 sec
    ...  Admin Check Active Alarms TAF  print_alarms=${False}  expected_patterns=${expected_fault}  ignored_patterns=${ignored_fault}
    Run Keyword If  ${status}==${FALSE}
    ...  Fail  Fault 6450 was not received.
    Log  Fault 6450 is reported  console=true


Step 2: Verify Presence Of DSP Memory Dumps
    [Documentation]
    ...   Content of /ffs/run/logs/diagn directory is checked for
    ...   mandatory files: memory dumps and runtime files.

    Log  Step 2: Verify presence of DSP memory dumps  console=true
    ${new_fsp_id}  hran_file_operations.Get Bbu Id From Dsp Id  ${DSP_ID_STR}
    ${status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${PREV_FSP_ID_LIST}  ${new_fsp_id}
    Run Keyword If  ${status}==${FALSE}
    ...  Run Keywords
    ...  Set Test Restriction  Memory dumps for the affected DSP already exist. New dumps won't be fetched.
    ...  AND
    ...  Return From Keyword
    Log  Check if diagn directory on BTS exists and if is empty  console=true
    Connect To SMOD  ${SMOD_IP_WITH_TESTED_DSP}
    ${files}  ssh.Execute  ls ${MEM_DUMPS_PATH}
    Should Not Be Empty  ${files}  msg=Directory diagn is empty; memory dumps not collected successfully!
    ${diagn_content}  Collect List Of Files In 'Step_2'
    Set Test Variable  ${DIAGN_CONTENT}
    ${bts_id}  sbts_admin.Admin Get BTS ID
    Create Mandatory Files Dict  ${DIAGN_CONTENT}  ${bts_id}
    ${additional_files_exist}  hran_file_operations.Verify Additional Files  ${DIAGN_CONTENT}  ${DSP_ID_STR}  ${DSP_MEMDUMPER_PATTERN}
    Run Keyword If  ${additional_files_exist}
    ...  Log  All additional files was found!  console=true
    ...  ELSE
    ...  Set Test Restriction  Not all additional files found!


Create Mandatory Files Dict
    [Arguments]  ${diagn_content}  ${bts_id}

    ${status}  Run Keyword And Return Status
    ...  Should Contain Match  ${diagn_content}  regexp=.*${SRIO_DIO_INTERFACE_PATERN}.*
    ${mandatory_files_dict}  Run Keyword If  ${status}
    ...  hran_file_operations.Create Dictionary Of Mandatory Files  ${diagn_content}
    ...  ${DSP_ID_STR}
    ...  ${DSP_RUNTIME_PATTERN}
    ...  ${DSP_MEMDUMP_PATTERN}
    ...  ${bts_id}
    ...  ${SM_VARIANT}
    ...  add_prefix=False
    ...  ELSE
    ...  hran_file_operations.Create Dictionary Of Mandatory Files  ${diagn_content}
    ...  ${DSP_ID_STR}
    ...  ${DSP_RUNTIME_PATTERN}
    ...  ${DSP_MEMDUMP_PATTERN}
    ...  ${bts_id}
    ...  ${SM_VARIANT}
    Set Test Variable  ${MANDATORY_FILES_DICT}


Step 3: Collect Snapshot
    Log  Step 3: Start snapshot collection  console=true
    ${timestamp}  Get Time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    Sleep  2m
    Collect Snapshot  ${BTS_FILES}/snapshot_${timestamp}  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}
    Sleep  10s
    Log  Check if diagn directory on BTS is empty  console=true
    Connect To SMOD  ${SMOD_IP_WITH_TESTED_DSP}
    ${files}  ssh.Execute  ls ${MEM_DUMPS_PATH}
    Run Keyword If  """${files}"""
    ...  Fail  msg=Directory diagn is not empty!
    ...  ELSE
    ...  Log  Directory diagn is empty.  console=true
    Set Global Variable  ${PATH_TO_SNAPSHOT}  ${BTS_FILES}/snapshot_${timestamp}
    ${found_file_dict}  Get Data From Snapshot  ${PATH_TO_SNAPSHOT}
    ${bts_id}  sbts_admin.Admin Get BTS ID
    Create Mandatory Files Dict  ${DIAGN_CONTENT}  ${bts_id}
    Validate Snapshot Using Custom Data  ${found_file_dict}  ${MANDATORY_FILES_DICT}
    Log  Check if fault 6450 is cleared  console=true
    ${critical_fault}  Create Dictionary  faultId=${FAULT_6450}[fault_id]
    ${critical_fault}  Create List  ${critical_fault}
    Admin Check Active Alarms TAF  critical_patterns=${critical_fault}


Collect List Of Files In '${dirname}'
    Create '${dirname}' In '${MEMORY_DUMP_FILES}' And Set Test Variable
    Download File From SYSMOD  ${${dirname}}
    ${diagn_content}  hran_file_operations.Get All Files From Dir  ${${dirname}}  subdir=${True}
    ${status}  Run Keyword And Return Status
    ...  Should Contain Match  ${diagn_content}  regexp=.*${SRIO_DIO_INTERFACE_PATERN}.*
    Return From Keyword If  not ${status}  ${diagn_content}
    ${diagn_content_of_tar}  snapshot.Get Files List From Tar  ${${dirname}}/dspdumps/riomemfs-logdump-${DSP_ID_STR}-dump.tar
    ${diagn_content}  Combine Lists  ${diagn_content_of_tar}  ${diagn_content}
    Return From Keyword  ${diagn_content}


Step 4: Check All Required State
    Log  Step 4: Check All Required State  console=true
    Wait Until Keyword Succeeds  ${VERIFICATION_TIMEOUT}m  2m
    ...  Admin Check All Required State
    Log  All cells and modules reached working state  console=true
    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup  tc_name=LOGS__Memory_dump_files_creation_in_case_of_DSP_crash


TC Teardown
    Common Test Teardown
