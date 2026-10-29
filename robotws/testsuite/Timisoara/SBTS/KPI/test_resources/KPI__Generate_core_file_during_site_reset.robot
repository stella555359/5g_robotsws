*** Settings ***
Documentation
    ...  This TC is created to verify if core files are generated when app crashes at start-up.
    ...  0x10079 and 0x100b7 are deleted from swconfig.txt.
    ...  actCoreDumpFileCollection is set to true.
    ...  Site reset is performed.
    ...  While site reset is performed, dummy process is created and then killed.
    ...  All states on SBTS are checked to be back online.
    ...  Snapshot is collected and two types of files are searched in it's archives: coreinfo file and coreutils file.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  10  # Time need to restore BTS after reset, default value 10 min
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}


*** Keywords ***
TC__KPI__Generate_core_file_during_site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-27185
    ...
    ...  ******************
    ...  - 25.03.2024 - https://jira3.int.net.nokia.com/browse/TAT-27185 - Initial creation
    ...  *******************

    Set Tags  CA-KPI  OWNER-oana.badea@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  SW-SBTS24

    Step0: TC Preconditions
    Step1: SBTS Site Reset
    Step2: Create A Dummy Process And Kill It
    Step3: Check SBTS States To Be Restored
    Step4: Collect Snapshot And Verify Existing Files


Step0: TC Preconditions
    Log  \nStep : TC Preconditions.  console=true
    ${bts_id}  Admin Get BTS ID
    Set Test Variable  ${BTS_ID}
    Verify swconfig.Txt File And Delete Flag If Needed  0x10079
    Verify swconfig.Txt File And Delete Flag If Needed  0x100b7
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actCoreDumpFileCollection  operation=update
    ...  value=true  skip_parameter_relation_errors=${True}  should_activate=${True}  timeout=180


Step1: SBTS Site Reset
    Log  \nStep1: SBTS Site reset  console=true
    Admin Check All Required State
    Admin Check Active Alarms TAF  collect_snapshot=${True}
    Log  BTS is resetting now.  console=true
    IF  ${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
        coam.Reset Site  timeout=600  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
    ELSE
        coam.Reset Site  timeout=600
    END
    Log  Site reset has been performed.  console=true


Step2: Create A Dummy Process And Kill It
    Log  \nStep2: Create a dummy process and kill it.  console=true
    Open Connection To Primary Core
    SSHLibrary.Write  rm -rf /ffs/run/logs/ccsdumps/0/A/dumps/node_0x1011 tree /ffs/run/logs/ccsdumps/0/A/dumps
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  date; bash -c "exec -a DummyProcesForCNI sleep 10000 &"
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ps aux | grep DummyProcesForCNI
    ${ps_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${ps_output}  DummyProcesForCNI 10000  Dummy process didn't start. [NOK]
    SSHLibrary.Write  date; pkill -f -6 DummyProcesForCNI
    SSHLibrary.Read Until Prompt
    Sleep  10s  Sleep for process to be killed.
    SSHLibrary.Write  ps aux | grep DummyProcesForCNI
    ${ps_output}  SSHLibrary.Read Until Prompt
    Should Not Contain  ${ps_output}  DummyProcesForCNI 10000  Dummy process didn't stop. [NOK]
    SSHLibrary.Write  tree /ffs/run/logs/ccsdumps/0/A/dumps
    ${tree_output}  SSHLibrary.Read Until Prompt
    Set Files To Search In Snapshot  ${tree_output}


Step3: Check SBTS States To Be Restored
    Log  \nStep3: Check SBTS states to be restored.  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  30 s  Admin Check All Required State
    IF  ${SCF_COUNT_NR}  Check NR Status To Be Working
    ${list_of_active_alarms}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    ${length}  Get Length  ${list_of_active_alarms}
    IF  ${length}>0  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}


Step4: Collect Snapshot And Verify Existing Files
    Log  \nStep4: Collect snapshot and verify existing files.  console=true
    Create Directory  ${BTS_FILES}/Snapshot
    Collect Snapshot  ${BTS_FILES}/Snapshot.zip
    ${return_code}  OperatingSystem.Run And Return Rc  unzip ${BTS_FILES}/Snapshot.zip -d ${BTS_FILES}/Snapshot
    IF  ${return_code} != 0  Fail  Not able to unzip snapshot file.
    ${snapshot_file_status}  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${BTS_FILES}/Snapshot/snapshot_file_list.txt
    IF  ${snapshot_file_status} == ${FALSE}  Fail  snapshot_file_list.txt does not exist in Snapshot directory.
    ${file_content}  OperatingSystem.Run  cat ${BTS_FILES}/Snapshot/snapshot_file_list.txt
    ${all_matches}  Get Regexp Matches  ${file_content}  (?s)BTS${BTS_ID}_[0-9]*_part_.*crashdumps_[0-9a-z]*_[0-9]_[A-Z].tar
    ${part_files_matches}  Get Regexp Matches  ${all_matches}[0]  BTS${BTS_ID}_[0-9]*_part_[0-9]*.zip
    ${part_file_archive}  Get From List  ${part_files_matches}  -1
    ${crashdumps_file_match}  Get Regexp Matches  ${all_matches}[0]  BTS${BTS_ID}_[0-9]*_crashdumps_.*tar
    ${crashdumps_archive}  Set Variable  ${crashdumps_file_match}[0]
    Unzip Directory And Search For Crashdumps Archive  ${BTS_FILES}/Snapshot/${part_file_archive}  .zip  ${crashdumps_archive}
    Log  All files were found in corect folder. [OK]  console=true


Set Files To Search In Snapshot
    [Arguments]  ${command_output}

    ${coreinfo_file}  Get Lines Containing String  ${command_output}  coreinfo
    Should Not Be Empty  ${coreinfo_file}  coreinfo file not found in ffs tree. [NOK]
    ${coreinfo_file}  Fetch From Right  ${coreinfo_file}  ${SPACE}
    ${coreutils_file}  Get Lines Containing String  ${command_output}  coreutils
    Should Not Be Empty  ${coreutils_file}  coreutils file not found in ffs tree. [NOK]
    ${coreutils_file}  Fetch From Right  ${coreutils_file}  ${SPACE}
    Set Test Variable  ${COREINFO_FILE}
    Set Test Variable  ${COREUTILS_FILE}


Unzip Directory And Search For Crashdumps Archive
    [Arguments]  ${full_archive_name}  ${extension}  ${file_to_find}

    ${directory_name}  Fetch From Left  ${full_archive_name}  ${extension}
    Create Directory  ${directory_name}
    OperatingSystem.Run  unzip ${full_archive_name} -d ${directory_name}
    Search For File Or Directory In Given Directory  ${file_to_find}  ${directory_name}
    Unzip Tar File And Find Core Files  ${directory_name}/${file_to_find}  .tar


Unzip Tar File And Find Core Files
    [Arguments]  ${full_archive_name}  ${extension}

    ${directory_name}  Fetch From Left  ${full_archive_name}  ${extension}
    Create Directory  ${directory_name}
    OperatingSystem.Run  tar -xf ${full_archive_name} -C ${directory_name}
    Search For File Or Directory In Given Directory  ${COREINFO_FILE}  ${directory_name}/.
    Search For File Or Directory In Given Directory  ${COREUTILS_FILE}  ${directory_name}/.


Search For File Or Directory In Given Directory
    [Arguments]  ${file_to_find}  ${given_directory}

    ${files}  OperatingSystem.List Files In Directory  ${given_directory}
    FOR  ${current_file}  IN  @{files}
        ${file_status}  Run Keyword And Return Status
        ...  Should Contain  ${current_file}  ${file_to_find}
        IF  ${file_status}  RETURN
    END
    Fail  No file found in "${given_directory}" that matches "${file_to_find}". [NOK]


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__Generate_core_file_during_site_reset


TC Teardown
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    Common Test Teardown
    ${kpi1a}  Calculate Kpi1a  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    Log Delta In Seconds  ${kpi1a}[kpi1a][-1][delta]  kpi1a
    Save Delta Results  kpi1a
    ${kpi1b}  Calculate Kpi1b  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    Log Delta In Seconds  ${kpi1b}[kpi1b][-1][delta]  kpi1b
    Save Delta Results  kpi1b
    Set Log Level  TRACE
