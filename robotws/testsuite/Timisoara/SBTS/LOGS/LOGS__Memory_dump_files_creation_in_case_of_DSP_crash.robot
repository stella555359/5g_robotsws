*** Settings ***
Documentation   Resource for Memory dump TC
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

*** Variables ***
${DSP_ID}                   ${Empty}
# DSP to be crashed; First number is SM number (1,2), second is BBU (2-4), third is DSP (3-8), fourth is core (1-4); Example: 0x1231
${SITE_RESET}               False
# If set to True, BTS site reset will be triggered at the beginning of a TC; if set False (default), site reset will not be triggered
${STARTUP_TIMEOUT}          10        # Timeout for BTS to startup after reset, default value 10 [min]
${FAULT_TIMEOUT}            15        # Timeout for alarm to be reported, default value 15 [min]
${VERIFICATION_TIMEOUT}     3         # Timeout for verification to check if BTS is onAir after DSP crash
${SNAPSHOT_COLLECTION_TIMEOUT}  1200s  # Timeout for Snapshot Collection
${MEMDUMP_PATTERN}          (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
${DSP_RUNTIME_PATTERN}      [1-2]011_crash_{}00_RT\\.log\\.zip$
${DSP_MEMDUMP_PATTERN}         {}00\\w+MEMDUMP\\.bin.*
${SRIO_DIO_INTERFACE_PATERN}   riomemfs-logdump  #other memdump fetching scenario


*** Keywords ***
TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5963
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test is to verify that memory dump files are created in case of DSP crash and if those files are
    ...  saved into snapshot once triggered.
    ...
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
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-16-05 - TAT-23139 - add to Check All Modules And All Cells Working States before start to collect Snapshot
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2022-08-05 - TAT-23532 - add dummy file delete from /ffs/run/logs/diagn
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5963.png#


    Set Tags    CA-SWM    OWNER-lukasz.targonski@nokia.com    AUTHOR-joanna.bielawska@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CIT    SW-SBTS17    SW-SBTS18
    ...    SW-SBTS19    FEATURE-RP001145_CNI7858    FEATURE-RP001486_CNI7858

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
    ...         Within TC preconditions rel3/rel4 recognition is done first and then
    ...         keyword connects to BTS via SSH and checks if folder ${MEM_DUMPS_PATH} is empty or not.
    ...         If folder is not empty - local copy of this folder is created in TC logs in BTSFiles and
    ...         variable prev_fsp_id is set.
    ${bts_connection}=  coam.connect_to
    ${sm_variant}=  infomodel.Get SM variant
    ${sm_variant_secondary}    Run keyword if    len(${sm_variant})==2    Set Variable    ${sm_variant[1]}
    ${DSP_ID}  Run Keyword If  '${sm_variant_secondary}'=='FSMF'    Return Core Id With Highest Number
    ...  ELSE IF     '${DSP_ID}'=='${Empty}'
    ...  Return Core Id With Lowest Number
    ...  ELSE  Set Variable  ${DSP_ID}
    Set Test Variable  ${DSP_ID}

    ${active_alarms}  coam.Get Alarms
    FOR  ${fault}  IN  @{active_alarms}
      Run Keyword If  '${fault['faultId']}'=='6450'  Run Keywords
      ...  Log  Alarm with fault 6450 is visible. Snapshot will be collected.  console=${True}
      ...  AND  coam.Collect Snapshot  ${BTS_Files}/snapshot_preconditions  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}
    END

    ${SMOD_IP_with_tested_DSP}=    Return SMOD IP With Tested DSP
    Set test variable    ${SMOD_IP_with_tested_DSP}

    Create 'MemoryDumpFiles' in '${Test Results Dir}' and set test variable

    ${dsp_id_str}=  hran_file_operations.Dsp id strip  ${DSP_ID}
    Set test variable  ${dsp_id_str}

    Log  TC preconditions: Check SM variant (FSMF, ASIA, ASIB, FSMF+FSMF, ASIA+ASIA, ASIA+FSMF)  console=yes
#    ${sm_variant}=  infomodel.Get SM variant
#    ${sm_variant_secondary}    Set Variable    ${sm_variant[1]}
    ${sm_variant}=  Verify SMOD variant  ${sm_variant}   ${dsp_id_str}
    Set test variable  ${sm_variant}
    ${enb_release}  coam.get sw release name
    ${MEM_DUMPS_PATH}=  Run keyword if  '${sm_variant}'=='FSMF'  Set variable  /ffs/run/logs/diagn
    ...     ELSE IF  '${enb_release}'=='SBTS23R4' or '${enb_release}'=='SBTS23R3' or '${enb_release}'=='SBTS24R1' and '${sm_variant}'=='ASIA'
    ...     set variable     /ffs/run/logs/dspdumps/5/A
    ...     ELSE IF  '${enb_release}'=='SBTS24R2' and '${sm_variant}'=='ASIA'
    ...     set variable     /ffs/run/logs/dspdumps/5/A
    ...     ELSE IF  '${enb_release}'=='SBTS23R1' or '${enb_release}'=='SBTS22R4' and '${sm_variant}'=='ASIA' or '${sm_variant}'=='ASIB'
    ...     Build diagn path for rel4  ${dsp_id_str}
    ...     ELSE IF     '${sm_variant_secondary}'=='FSMF'    set variable  /ffs/run/logs/dspdumps/6/D
    ...     ELSE  set variable  /ffs/run/logs/dspdumps/1/A
    Set test variable  ${MEM_DUMPS_PATH}
    Run Keyword If    '${MEM_DUMPS_PATH}'=='/ffs/run/logs/diagn'    Delete dummy file

    ${prev_fsp_id_list}=  Create list
    Set test variable  ${prev_fsp_id_list}

    Log  Check if folder for dsp memory dumps exists on BTS and if is empty  console=yes
    ${dir_exists}=  ssh_utils.Check if directory exists  ${MEM_DUMPS_PATH}  ${SMOD_IP_with_tested_DSP}
    Run keyword unless  ${dir_exists}  Return from keyword
    ${diagn_content}=  Collect list of files in 'Step_0'
    ${diagn_content_size}=  Get length  ${diagn_content}

    ${prev_fsp_id_list}=  Run keyword if  ${diagn_content_size} > 0
    ...  hran_file_operations.Get bbu id on which dsp crashed  ${diagn_content}  ${MEMDUMP_PATTERN}
    ...  ELSE  Set variable  @{EMPTY}

Delete dummy file
    [Documentation]
    ...         This KW delete bbtrace_snapshot_dummy from /ffs/run/logs/diagn
    ${dummy_file_name}    Set Variable    bbtrace_snapshot_dummy
    SSHLibrary.Open Connection    ${SMOD1['IP']}
    SSHLibrary.Login        ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    ${file_list}    SSHLibrary.Execute command    ls ${MEM_DUMPS_PATH}
    Run Keyword If    '''${file_list}'''=='''${dummy_file_name}'''    SSHLibrary.Execute command    rm ${MEM_DUMPS_PATH}/${dummy_file_name}
    ...  AND  Log  ${dummy_file_name} was delete from ${MEM_DUMPS_PATH}
    ...               ELSE  Log  There are more files in ${MEM_DUMPS_PATH} directory, ${dummy_file_name} wasn't delete.
    SSHLibrary.Close Connection

Verify SMOD variant
    [Documentation]
    ...         Return SMOD variant for crashed DSP
    [Arguments]  ${sm_variant}  ${dsp_id_str}
    Return From Keyword If    len(${sm_variant})==1   ${sm_variant[0]}
    ${tmp_sm_variant}=    Evaluate    '${sm_variant[0]}' if '${sm_variant[0]}'=='${sm_variant[1]}' else '${EMPTY}'
    ${sm_variant}=   Run Keyword If   '${tmp_sm_variant}'=='${EMPTY}' and '${dsp_id_str[0]}'=='1'    Set Variable  ${sm_variant[0]}
    ...              ELSE IF       '${tmp_sm_variant}'=='${EMPTY}' and '${dsp_id_str[0]}'=='2'    Set Variable   ${sm_variant[0]}
    ...              ELSE    Set Variable     ${sm_variant[1]}
    Return From Keyword   ${sm_variant}

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
    Run Keyword If    '${SMOD_IP_with_tested_DSP}' == '192.168.255.7'
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

Return Core Id With Highest Number
    ${all_core_ids_objects}=  Query Infomodel  get list //CORE_L-* is [type=DSP]
    ${all_core_ids}  Create List
    FOR  ${core_id}  IN  @{all_core_ids_objects}
      ${core_id_in_hex}=  Evaluate  hex(${core_id.nodeId})
      Append To List  ${all_core_ids}  ${core_id_in_hex}
    END
    Sort List  ${all_core_ids}
    [Return]  ${all_core_ids[-1]}

Step 1: Trigger DSP crash
    [Documentation]
    ...         DSP provided by user is crashed using shell rioboot cmd.
    ...         Active alarms on SBTS are checked for fault 6450

    Log  Step 1: Trigger crash of DSP ${DSP_ID}  console=yes
    Log  Run 'rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}'  console=yes
    ssh_utils.Perform Dsp Crash    ${DSP_ID}    ${SMOD_IP_with_tested_DSP}
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
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    ${timestamp}=  Get time
    ${timestamp}=  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}

    Sleep  10s
    Log  Check if diagn directory on BTS is empty  console=yes
    ${files}=  ssh_utils.List remote directory  ${MEM_DUMPS_PATH}
    ${diagn_content}=  Run Keyword If  """${files}"""  Collect list of files in 'Step_3'
    Run Keyword If  """${files}"""  Should be empty  ${diagn_content}  msg=Directory diagn is not empty!
    ...         ELSE  Log  Directory diagn is empty.  console=yes

    Set global variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}
    ${found_file_dict}  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    snapshot.Validate Snapshot Using Custom Data  ${found_file_dict}  ${mandatory_files_dict}

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
    [Arguments]  ${expected_BTS_status}=OnAir  ${modules_check}=${TRUE}  ${cells_check}=${TRUE}   #${alarms_check}=${TRUE}
#    ...  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ${BTS_state_correct}=  Verify BTS proceduralState  ${expected_BTS_status}
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

    Run Keyword Unless  ${BTS_state_correct} and ${SMs_working} and ${RMODs_working} and ${GSM_onair} and ${WCDMA_onair} and ${LTE_onair}
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
    ...    AND    Common Test Teardown  #collect_snapshot=never
