*** Settings ***
Documentation   Tests for ncf
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.fdsw.rc    WITH NAME    fdsw
Library    Collections
Library    XML
Library    String
Library    BuiltIn
Resource    ../resources/ssh_utils.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${STARTUP_TIMEOUT}  20


*** Keywords ***
TC__LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-26442
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies NCF (Network Configuration File)
    ...  it is checked whether the file is created on the 3rd partition after switching to FDSW SW
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26442 - Initial creation
    ...


    Set Tags    CA-LOGS    AUTHOR-jakub.kokoszka@nokia.com    MAINTAINER-jakub.kokoszka@nokia.com
    ...         PHASE-CRT    SW-SBTS24R1    FEATURE-CB009233


    Step 0: Preconditions
    Step 1: Check NCF On ffs/run/config Directory
    Step 2: Configuration Reset
    Step 3: Check NCF On /ffs/fs3/config Directory
    Step 4: Return To The Software That Was Active Before Uploading FDSW SW
    Step 5: Compare NCF Files

Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    Step 0: Preconditions    console=${True}

    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    Run    mkdir ${BTSFiles}/NCF_files
    ssh_utils.Setup SMOD Connection
    ${active_partition}    ssh_utils.Run Command    uboot_env get active_partition
    ${active_partition_numer}    Fetch From Right  ${active_partition}     =
    ${active_partition_nr}  Set Variable  ${active_partition_numer.replace("\r\n", "")}

    Set Test Variable    ${active_partition_nr}

    Set Test Variable  ${FDSW_active}    ${False}


Step 1: Check NCF on ffs/run/config directory
    [Documentation]
    ...   In this step test check NCF on ffs/run/config directory
    ...   NCF file downloaded to local disk

    Log  Step 1: Check NCF On ffs/run/config Directory    console=${True}
    ${file_list}    List Remote Directory    /ffs/run/config/
    Should contain      ${file_list}    NCF.xml
    ssh_utils.Setup SMOD Connection
    ssh.download_file    remote_path=/ffs/run/config/NCF.xml   local_path=${BTSFiles}/NCF_files/NCF_0.xml
    OperatingSystem.File Should Exist    ${BTSFiles}/NCF_files/NCF_0.xml
    ssh.Disconnect


Step 2: Configuration Reset
    [Documentation]
    ...   In this step test perform configuration reset and wait for ping on 192.168.255.129 IP

    Log  Step 2: Configuration Reset    console=${True}
    coam.reset_configuration
    Set Test Variable  ${FDSW_active}    ${True}
    Sleep    120s
    Wait For Target IP To Be Reachable    192.168.255.129    10

Step 3: Check NCF On /ffs/fs3/config Directory
    [Documentation]
    ...   In this step test check NCF on /ffs/fs3/config directory
    ...   NCF file downloaded to local disk

    Log  Step 3: Check NCF On /ffs/fs3/config Directory    console=${True}
    Log to console    Connected to FDSW
    Wait Until Keyword Succeeds    5m    1m    Connected to FDSW
    ${available_reset_options}    fdsw.get_available_reset_options    ${active_partition_nr}
    Log  ${available_reset_options}[0]
    Set Test Variable    ${available_reset_options}
    fdsw.enable_ssh_service

    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login        toor4nsn    oZPS0POrRieRtu
    SSHLibrary.File Should Exist    /ffs/fs3/config/NCF.xml
    SSHLibrary.Get File  /ffs/fs3/config/NCF.xml  ${BTSFiles}/NCF_files/
    OperatingSystem.File Should Exist    ${BTSFiles}/NCF_files/NCF.xml
    SSHLibrary.Close Connection

Step 4: Return To The Software That Was Active Before Uploading FDSW SW
    [Documentation]
    ...   In this step test return to the software that was active before uploading FDSW SW

    Log  Step 4: Return To The Software That Was Active Before Uploading FDSW SW    console=${True}
    fdsw.software_rollback    ${active_partition_nr}
    Set Test Variable  ${FDSW_active}    ${False}
    Sleep    120s
    Wait For Target IP To Be Reachable    192.168.255.129    10
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All SMODs And RMODs States

Step 5: Compare NCF Files
    [Documentation]
    ...   In this step test Compare NCF Files from
    ...   /ffs/fs3/config/NCF.xml and /ffs/run/config/NCF.xml file should be equal

    Log    Step 5: Compare NCF Files    console=${True}

    ${ncf_file0}   Set variable  ${BTSFiles}/NCF_files/NCF.xml
    ${ncf_file1}   Set variable  ${BTSFiles}/NCF_files/NCF_0.xml

    Compare NCF Files   ${ncf_file0}    ${ncf_file1}

Connected to FDSW
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    fdsw.connect to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...    auto_discover=${auto_discover}    secure=${secure}    name=${name}

Compare NCF Files
    [Documentation]
    ...  Check administrativeState
    ...  Compare Files Line By Line Ignoring Spaces and first 6 lines

    [Arguments]    ${file0}    ${file1}
    ${ncf0}=    Parse Xml    ${file0}
    ${ncf1}=    Parse Xml    ${file1}

    ${val0}=    XML.Get Element Text    ${ncf0}    .//managedObject[@class='AUTOCON' and @distName='AUTOCON-1']/p[@name='administrativeState'][1]
    ${val1}=    XML.Get Element Text    ${ncf1}    .//managedObject[@class='AUTOCON' and @distName='AUTOCON-1']/p[@name='administrativeState'][1]

    Should Be Equal As Strings    ${val0}    0
    Should Be Equal As Strings    ${val1}    1

    #Compare Files Line By Line Ignoring Spaces and first 6 lines
    ${F0}   Set variable  ${OUTPUT_DIR}/file1_clean.txt
    ${F1}   Set variable  ${OUTPUT_DIR}/file2_clean.txt

    Run    tail -n +9 ${file0} | sed 's/\r$//;s/^[[:space:]]*//;s/[[:space:]]*$//;/^$/d' > ${F0}
    Run    tail -n +9 ${file1} | sed 's/\r$//;s/^[[:space:]]*//;s/[[:space:]]*$//;/^$/d' > ${F1}

    ${rc}    ${out}=    Run And Return Rc And Output
    ...    diff ${F0} ${F1}
    Run Keyword If    ${rc} != 0    Log    Line NOK:${out}
    Should Be Equal As Integers    ${rc}    0

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If    ${FDSW_active}    Run Keywords
    ...    Log to console    Connected to FDSW
    ...    AND    Wait Until Keyword Succeeds    5m    1m    Connected to FDSW
    ...    AND    Log to console    Return To The Software That Was Active Before Uploading FDSW SW
    ...    AND    fdsw.software_rollback    ${active_partition_nr}
    ...    AND    Sleep    120s
    ...    AND    Wait For Target IP To Be Reachable    192.168.255.129    10
    ...    AND    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States

TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...    interface.Common step trigger
#    ...    AND    Setup Scout And Send Configuration
#    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown