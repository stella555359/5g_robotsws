*** Settings ***
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
@{ALL_REL5.1}   AHEB   AZNA   AHEGA   AHPMDA   AHPDA   AHCA   AHCA-B   AZHA   AHFB   AHIB   AHLB   AHCE
...   AHBB   AHBC   AZQC   AZQD   AZQR   AZRA   AHED   AHFIA   AHFIB   AHFIC   AHBCA   AHBCC   AHBCD   AHLOA
...   AHLBA   AHPB   AHEC   AHGC   AHGA   AHDB   AHDA   AHEGB   AZNC   AZNB   AZND   AZHE   AZNE   AZQF   AZRB
...   AZFGA   AHHB   AHEE   AHMA   ANEGA   AHHA    AAFIA   AREA   AHEH   AAIB   AAFB   AHPC   AAIC   AHLJA
...   AZQE   AHFIE   AHFIF   ARCA   ARGA   ARPA   ARHA   ARMA   AZRC   AHAA   AHPD   AHSA   AHCC   ARDB   AHEGC
...   AHFIG   AHBCB   AHPE   AHCF   AHPCA   AHBOA   AHLBBA   AHPCDB   AHPMDB   ARDA   AHAB   AHGE   AHRA   AHPMD
...   AHGD   AHNA   AHCG   AHGD   AHEGF   FZQM
${pwd_sec_VM}    uteUTE!    # NOT VALID FOR VMS AFTER REINSTALL AND OUTSIDE CLOUD. This is password to secondary VM, valid for VMs in cloud.

*** Keywords ***
TC__LOGS__Number_of_failure_logs_reported_in_snapshot_per_each_RUs_of_configuration
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21147
    ...  ******************
    ...  Author: Mateusz Jelen
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-05-12 - https://jira3.ext.net.nokia.com/browse/TAT-21147
    ...  - 2021-06-21 - https://jira3.ext.net.nokia.com/browse/TAT-21465
    ...  - 2021-08-13 - https://jira3.ext.net.nokia.com/browse/TAT-21699
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-01-04 - TAT-22173-2  - Check RMOD Availability Status KW moved to resources -> Check RMOD States
    ...  - 2022-02-14 - TAT-22652 - test refactor
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 20.04.2023 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test verifies if fault logs from radio unit are present in snapshot. To simulate such situation in test
    ...  fault is generated on radio and after cancellation, snapshot is collected.
    ...
    Set Tags    CA-LOGS    OWNER-mateusz.jelen@nokia.com   AUTHOR-mateusz.jelen@nokia.com
    ...    MAINTAINER-justyna.durak@nokia.com   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT

    Step1: Preparation
    Step2: Fault Generation    ${list_of_rmods}
    Step3: Fault Cancellation    ${list_of_rmods}
    Step4: Check Results In Snapshot    ${list_of_rmods}


Step1: Preparation
    [Documentation]
    ...   Makes list of all RMODs rel5.1 present in tested configuration and reads content of snapshot_status.txt
    ...   before fault is forced

    Log  \nStep1: Preparation    console=${True}
    ${list_of_rmods}=    Get Rel5.1 RMODs List
    Set Test Variable    ${list_of_rmods}
    ${snap_status_txt_before_fault}   Create Dictionary
    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${snapshot_status_txt}    Check snapshot_status.txt On Radio Unit   ${radio_module}
        Set To Dictionary    ${snap_status_txt_before_fault}    ${radio_module['serial_number']}    ${snapshot_status_txt}
    END
    Set Test Variable    ${snap_status_txt_before_fault}

Step2: Fault Generation
    [Documentation]
    ...    Generates critical fault 1901 on all 5.1 RMODS by renaming critical files
    ...    Disclaimer: Failure log collection interval is limited and this depends on specified radio, common is 1h
    [Arguments]    ${list_of_rmods}

    Log  \nStep2: Fault Generation  console=${True}
    ${rename_critical_file}    Set Variable    mv /mnt/factory/configs/unit/calibration_dlpath1.bin \\
    ${rename_critical_file_line2}   Set Variable    /mnt/factory/configs/unit/dummy_system_test.bin
    FOR  ${radio_module}  IN  @{list_of_rmods}
        Execute Commands For Radio And Reset   ${radio_module}   ${rename_critical_file}   ${rename_critical_file_line2}
        Log  Waiting for fault 1901 on ${radio_module['product_name']} ${radio_module['serial_number']}  console=${True}
        Wait Until Keyword Succeeds  60min  10s  coam.Assert alarm active  faultId=1901, severity=Critical, serialNo=${radio_module['serial_number']}
        Log  Waiting for new timestamp in snapshot_status.txt on ${radio_module['product_name']} ${radio_module['serial_number']}  console=${True}
    END
    Log  Wait Until Keyword Check Results On Radio Succeeds  console=${True}
    Wait Until Keyword Succeeds    30min    10s    Check Results On Radio    ${list_of_rmods}

Step3: Fault Cancellation
    [Documentation]
    ...    Cancell critical fault 1901 on all 5.1 RMODS by renaming critical files back
    [Arguments]    ${list_of_rmods}

    Log  \nStep3: Fault Cancellation  console=${True}
    ${rename_critical_file_back}    Set Variable    mv /mnt/factory/configs/unit/dummy_system_test.bin \\
    ${rename_critical_file_back_line2}   Set Variable    /mnt/factory/configs/unit/calibration_dlpath1.bin
    FOR  ${r_module}  IN  @{list_of_rmods}
        Log  Fault Cancellation for ${r_module['product_name']} ${r_module['serial_number']}  console=${True}
        Execute Commands For Radio And Reset   ${r_module}   ${rename_critical_file_back}   ${rename_critical_file_back_line2}
        Wait Until Keyword Succeeds  20min  10s  coam.Assert alarm inactive  faultId=1901, severity=Critical, serialNo=${r_module['serial_number']}
        Wait Until Keyword Succeeds    20min    10s    pm_logs_general.Check RMOD States  ${r_module['rmod_id']}  (?i)Unlocked  (?i)Enabled
    END

Step4: Check Results In Snapshot
    [Documentation]
    ...    Collect snapshot and verifies if file BTS_${radio_module['serial_number']}_RMOD_*_*_faultLogs.zip
    ...    can be found in snapshot
    [Arguments]     ${list_of_rmods}

    Log  \nStep4: Check Results In Snapshot  console=${True}
    @{time}    Get Time    year month day hour min
    Set Test Variable  ${SNAPSHOT_LOCATION}  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}
    coam.Collect Snapshot    ${SNAPSHOT_LOCATION}.zip   coverage=Minor    timeout=1200
    ${snapshot_content}    snapshot.Get Data From Snapshot   ${SNAPSHOT_LOCATION}.zip
    Set Test Variable    ${snapshot_content}

    ${snapshot_paths}    Create Dictionary
    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${result}     Check Files In Snapshot   *BTS_${radio_module['serial_number']}_RMOD_*_*_faultLogs.zip
        Should Not Be Empty   ${result}     msg=faultLogs.zip should be present for ${radio_module['product_name']} ${radio_module['serial_number']}
        Set To Dictionary    ${snapshot_paths}   ${radio_module['serial_number']}   ${result[0]}
    END
    Set Test Variable   ${snapshot_paths}
    Log    ${snapshot_paths}

    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}.zip  ${SNAPSHOT_LOCATION}

    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${FaultLogs_in_BTS_part}   Run Keyword And Return Status
        ...   Should Contain   ${snapshot_paths['${radio_module['serial_number']}']}   BTS_part
        Run Keyword If   ${FaultLogs_in_BTS_part}
        ...   Unzip BTS_part And FaultLogs   ${radio_module}
        ...   ELSE   Unzip FaultLogs   ${radio_module}
    END

Unzip BTS_part And FaultLogs
    [Arguments]    ${radio_module}
    ${part_name}    Fetch From Left    ${snapshot_paths['${radio_module['serial_number']}']}   .zip
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/${part_name}.zip   ${SNAPSHOT_LOCATION}/${part_name}
    ${faultLog_zip_name}    Fetch From Right    ${snapshot_paths['${radio_module['serial_number']}']}   /
    ${faultLog_name}    Fetch From Left    ${faultLog_zip_name}   .zip
    unpacking.Unpack Archive Content To Directory  
    ...    ${SNAPSHOT_LOCATION}/${part_name}/${faultLog_zip_name}    ${SNAPSHOT_LOCATION}/${part_name}/${faultLog_name}
    Directory Should Not Be Empty   ${SNAPSHOT_LOCATION}/${part_name}/${faultLog_name}/1
    ${run_output}   Run   cat ${SNAPSHOT_LOCATION}/${part_name}/${faultLog_name}/snapshot_status.txt
    ${radio_output}    Fetch From Left    ${snap_status_txt_after_fault['${radio_module['serial_number']}']}    root
    Should Be Equal As Strings    ${run_output}   ${radio_output}

Unzip FaultLogs
    [Arguments]    ${radio_module}
    ${faultLog_name}    Fetch From Left    ${snapshot_paths['${radio_module['serial_number']}']}   .zip
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/${faultLog_name}.zip    ${SNAPSHOT_LOCATION}/${faultLog_name}
    Directory Should Not Be Empty   ${SNAPSHOT_LOCATION}/${faultLog_name}/1
    ${run_output}   Run   cat ${SNAPSHOT_LOCATION}/${faultLog_name}/snapshot_status.txt
    ${radio_output}    Fetch From Left    ${snap_status_txt_after_fault['${radio_module['serial_number']}']}    root
    Should Be Equal As Strings    ${run_output}   ${radio_output}

Check Files In Snapshot
    [Arguments]   ${match}
    FOR  ${snapshot_value}  IN  @{snapshot_content.values()}
        ${result}   Get Matches   ${snapshot_value}   ${match}
        ${result_len}    Get Length    ${result}
        Exit For Loop If   ${result_len}>0
    END
    [Return]   ${result}

Check Results On Radio
    [Documentation]
    ...    Verifies if content of snapshot_status.txt was overwritten after fault 1901 occured during test
    [Arguments]     ${list_of_rmods}
    ${snap_status_txt_after_fault}   Create Dictionary
    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${snapshot_status_txt}    Check snapshot_status.txt On Radio Unit   ${radio_module}
        Set To Dictionary    ${snap_status_txt_after_fault}    ${radio_module['serial_number']}    ${snapshot_status_txt}
        Should Not Be Equal As Strings
        ...    ${snap_status_txt_before_fault['${radio_module['serial_number']}']}
        ...    ${snap_status_txt_after_fault['${radio_module['serial_number']}']}
    END
    Set Test Variable   ${snap_status_txt_after_fault}

Get Rel5.1 RMODs List
    ${list_of_radio_modules}    coam.Get Parameters For All    RMOD
    ${rel5.1_radios}    Create List
    ${bts_id}  bts_states.Get BTS ID
    FOR    ${radio_module}  IN  @{list_of_radio_modules}
        ${dist_name}    Fetch From Right    ${radio_module['id']}    RUNTIME_VIEW-1/
        ${mrbts_r_id}   Fetch From left    ${dist_name}    /
        ${dist_name}    Remove String    ${dist_name}    ${mrbts_r_id}
        ${dist_name}    Set Variable    MRBTS-${bts_id}${dist_name}
        ${radio_module_dict}    Create Dictionary  serial_number=${radio_module['serialNumber']}   product_name=${radio_module['productName']}
        ...    dist_name=${dist_name}    ip_address=${radio_module['ipAddress']}    rmod_id=${radio_module['id']}
        ${found}    Get Match Count    ${ALL_REL5.1}    ${radio_module['productName']}
        Run Keyword If    ${found}>=1     Append To List    ${rel5.1_radios}    ${radio_module_dict}
    END
    [Return]    @{rel5.1_radios}

Execute Commands For Radio And Reset
    [Arguments]   ${radio_module}   ${command}   ${command2}
    SSHLibrary.Open Connection    ${SMOD1['IP']}
    SSHLibrary.Login        ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    SSHLibrary.Read
    Connect To RMOD Via Ssh    ${radio_module['ip_address']}    ${radio_module['product_name']}
    SSHLibrary.Read
    Sleep    3s
    SSHLibrary.Write   ${command}
    SSHLibrary.Write   ${command2}
    Sleep    3s
    SSHLibrary.Read
    Sleep    3s
    SSHLibrary.Write    exit
    Sleep    1s
    SSHLibrary.Write    exit
    Sleep    1s
    SSHLibrary.Write    exit
    Run Keyword And Ignore Error    coam.Unit Reset Cp    ${radio_module['dist_name']}    soft
    [Teardown]   SSHLibrary.Close All Connections

Check snapshot_status.txt On Radio Unit
    [Documentation]    This KW logs directly to given radio unit and reads content of snapshot_status.txt file
    [Arguments]  ${radio_module}
    ${cat_command}    Set Variable    cat /mnt/runtime/fault-log/snapshot_status.txt
    SSHLibrary.Open Connection    ${SMOD1['IP']}
    SSHLibrary.Login        ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    SSHLibrary.Read
    Connect To RMOD Via Ssh    ${radio_module['ip_address']}    ${radio_module['product_name']}
    SSHLibrary.Write    ${cat_command}
    Sleep    3s
    ${terminal_output}    SSHLibrary.Read
    Sleep    1s
    SSHLibrary.Write    exit
    Sleep    1s
    SSHLibrary.Write    exit
    Sleep    1s
    SSHLibrary.Write    exit
    ${snapshot_status_txt}   Fetch From Right   ${terminal_output}   /mnt/runtime/fault-log/snapshot_status.txt\r\n
    [Teardown]   SSHLibrary.Close All Connections
    [Return]    ${snapshot_status_txt}

Connect To RMOD Via Ssh
    [Documentation]   This KW establishes connection with radio.
    ...   At first it tries to connect to RMOD after attach with primary core
    ...   and checks if communicate "Network is unreachable" will occur - if yes,
    ...   then it tries with secondary core.
    [Arguments]    ${ip_address}    ${product_name}
    Sleep    3s
    SSHLibrary.Write    lxc-attach -n 0x1018
    Sleep    3s
    SSHLibrary.Write    ssh ${ip_address}
    Sleep    3s
    ${connection_status}    SSHLibrary.Read
    ${fingerprint}    Get Count    ${connection_status}    (yes/no/[fingerprint])?
    ${network_status}    Get Count    ${connection_status}    Network is unreachable
    Sleep    1s
    Run Keyword If    ${fingerprint}==1    SSHLibrary.Write    yes
    Run Keyword If    ${network_status}==1    Connect To RMOD Linked To Secondary Core    ${ip_address}    ${product_name}    ${pwd_sec_VM}
    Sleep    1s

Connect To RMOD Linked To Secondary Core
    [Documentation]   This KW establishes connection with radio,
    ...   in steps: connect to secondary VM, log to BTS and attach to secondary core.
    [Arguments]    ${ip_address}    ${product_name}    ${pwd_sec_VM}
    SSHLibrary.Write    exit
    SSHLibrary.Read
    Sleep    1s
    SSHLibrary.Write    exit
    SSHLibrary.Read
    Sleep    1s
    SSHLibrary.Open Connection    ${PC_IP2}
    SSHLibrary.Login    username=ute    password=${pwd_sec_VM}
    SSHLibrary.Read
    Sleep    1s
    SSHLibrary.Write    ssh 192.168.255.119
    Sleep    1s
    SSHLibrary.Write    oZPS0POrRieRtu
    Sleep    1s
    ${connection_status_ext}   SSHLibrary.Read
    ${connection_ext}   Get Count   ${connection_status_ext}   WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
    Run Keyword If    ${connection_ext}==1    Run Keywords
    ...    SSHLibrary.Close All Connections
    ...    AND    verdicts.Set Test Failed  Cannot log to secondary core, try log manually to diagnose issue.  ${TRUE}
    Sleep    1s
    SSHLibrary.Write    lxc-attach -n 0x2018
    SSHLibrary.Read
    Sleep    1s
    SSHLibrary.Write    ssh ${ip_address}
    Sleep    1s
    ${connection_status}    SSHLibrary.Read
    Sleep    1s
    ${fingerprint}    Get Count    ${connection_status}    (yes/no/[fingerprint])?
    ${network_status}    Get Count    ${connection_status}    Network is unreachable
    Run Keyword If    ${fingerprint}==1    SSHLibrary.Write    yes
    Sleep    1s
    Run Keyword If    ${network_status}==1    Run Keywords
    ...    SSHLibrary.Close All Connections
    ...    AND    verdicts.Set Test Failed  RMOD is unreachable on both nodes.  ${TRUE}

Ensure Fault 1901 Is Inactive And Radio Is Enabled
    [Documentation]
    ...    Checks if critical fault was cancelled and if not tries again to cancel fault
    ...    and waits until radio unit will be enabled
    [Arguments]  ${radio_module}
    Log  Ensuring ${radio_module['product_name']} is online  console=${True}
    ${fault_status}  Run Keyword And Return Status  coam.Assert alarm inactive
    ...   faultId=1901, severity=Critical, serialNo=${radio_module['serial_number']}
    ${rename_critical_file_back}    Set Variable    mv /mnt/factory/configs/unit/dummy_system_test.bin  \\
    ${rename_critical_file_back_line2}    Set Variable    /mnt/factory/configs/unit/calibration_dlpath1.bin
    Run Keyword Unless   ${fault_status}
    ...   Execute Commands For Radio And Reset   ${radio_module}   ${rename_critical_file_back}   ${rename_critical_file_back_line2}
    Wait Until Keyword Succeeds    15min   10s    pm_logs_general.Check RMOD States  ${radio_module['rmod_id']}  (?i)Unlocked  (?i)Enabled

Custom Test Teardown
    [Documentation]   KW Get Parameters For RMOD is placed here in order to make debugging easier in case od fail
    Log  Custom Test Teardown  console=${True}
    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${radio_params}    Get Parameters For    RMOD    ${radio_module['rmod_id']}
        Wait Until Keyword Succeeds    60min   10s   Ensure Fault 1901 Is Inactive And Radio Is Enabled    ${radio_module}
    END
    Wait Until Keyword Succeeds    10min   10s   pm_logs_general.Check If There Are No Critical Alarms

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
