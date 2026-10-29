*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
#Library    hran_extract
#Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/extract.py
Library           taf.sbts.oam.coam.admin
#Library           hran_file_operations
Library           String
#Library           hran_webui
##Library           hran_compa
#Library           hran_tools
##Library           hran_ssh
Library           DateTime
Library           OperatingSystem

Library           ute_async


*** Variables ***
#${sw_package_path}    /home/ute/btsauto/BASE_SW
${sw_package_path}    /home/ute/btsauto/TARGET_SW
#${SW Update Timeout}    1800    # Given in seconds; That is a timeout for SW download and activation (without reset)
${ping_loss_timeout}    240    # Timeout for ping loss during reset
${ping_regain_timeout}    900    # Timeout for ping regain during reset
${restore_timeout}    240    # Timeout for cells to go OnAir after last update
${esm_ip}         192.168.255.119    # ESM trs ip
${FAULT_4001_TIMEOUT}    15    # How long should KW wait for fault 4001 [in minutes]
${PC_IP2}                         10.108.152.142  # Secondy PC IP
${remote_ip}         		   10.41.146.248  # Bangalore server IP
${remote_usr}				    root  # Bangalore server username
${remote_pwd}  		     	       Nokia_150  # Bangalore server password


*** Keywords ***
LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883
    ...
    ...    *****************
    ...    Basic information
    ...    ********************
    ...    **Request ID:** TAT-9883
    ...    *****************
    ...    Main purpose of TC is checking fallback functionality of SBTS SW in dual core configuration:
    ...    fallback from SBTS_SOAM to SBTS_SOAM
    ...
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.05.2018 - TC file created, implementation started
    ...    - 10.09.2018 - TAT-12126 Set test norun changed to Set test blocked in META check
    ...    - 24.12.2018 - TAT-13071 Info about active Fault 4082 added when minor faults present on BTS
    ...    - 27.12.2018 - TAT-13802
    ...    - 19.03.2019 - TAT-14934
    ...    - 18.04.2019 - TAT-15093 COMPA - DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC failed with MSM is not stable after update on ESM.
    ...    - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...    - 15.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-15468 - Adds checking BM release for DC fallbacks SBTS
    ...    - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17980 - Changes timeout for fault 4001 and adds this timeout to Variables
    ...    - 08.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18645 - Adds reset connection to admin and infomodel after fallback
    ...    - 27.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18888 - Fix problem with duplicated KW names
    ...    - 06.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-18664 - Adds support for reset due to fault 4001
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-9883.png
    Set Tags    PHASE-COMPA    CA-SWM    OWNER-dominik.jesariew@nokia.com
    ...    SW-SBTS18SP    SW-SBTS18A    SW-SBTS19    FEATURE-RP000938    FEATURE-RP001498    FEATURE-RP001621
    Change parameter to connect netact with BTS
    Step 1: Check active and passive sw version
    Step 2: SW rollback on MSM
    Step 3: Check BTS is onair after rollback

Step 1: Check active and passive sw version
    [Documentation]    Short description.
    Log step header    Step 1: Check active and passive sw version
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM
    ${release_NUM}=    should match regexp    ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}

Step 2: SW rollback on MSM
    [Documentation]    Short description.
    Log step header  Step 6: SW rollback on MSM
    ${rollback_status}=  Run keyword and return status  taf.sbts.oam.coam.admin.Rollback software
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.
    Log  Software rollback triggered successfully.  console=${TRUE}
    Log  Wait till BTS is stable and ensure admin connectivity  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=1200
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after rollback.
    Log  BTS is stable after rollback.  console=${TRUE}
    ${admin_working_state}  Reset admin and infomodel connection if broken
    Run keyword if    not ${admin_working_state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}

Step 3: Check BTS is onair after rollback
    [Documentation]    Short description.
    Log step header    Step 7: Check BTS is onair after rollback
    check BTS is onair after update to tested software

_check SW version after provision
    [Documentation]    Short description.
    Setup eNB Fsm Access    alias=enb1
    ${active_version_after}=    Get Enb Sw Version    active    alias=enb1
    set test variable    ${active_version_after}
    Teardown Enb Fsm Access    alias=enb1
    ${release_name}    Get Substring    ${package_release_changed}    12
    Should Contain    ${active_version_after}    ${release_name}

Find release version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${package name}: <description>
    ...        ${release_1}: <description>
    ...        ${release_2}: <description>
    ...        ${release_3}: <description>
    ...
    ...    Returns:
    ...        ${release}: <description>
    [Arguments]    ${package name}    ${release_1}    ${release_2}    ${release_3}
    ${release}=    set variable if    '${release_1}' in '${package name}'
    ...    ${release_1}    '${release_2}' in '${package name}'    ${release_2}    '${release_3}' in '${package name}'
    ...    ${release_3}
    [Return]    ${release}

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}    OperatingSystem.List files in directory    ${SW_PATH}
    should not be empty    ${package name}    Required package not present in ${SW_PATH}
    ${SW_PATH_package}=    Join Path    ${SW_PATH}    ${package name[0]}
    OperatingSystem.File should exist    ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}    Run keyword and return status    Wait For Target To Be Not Reachable    hostname=${SMOD1['TRS_IP']}    timeout=900
    Run keyword if    ${ping loss status}==${FALSE}    Log    BTS RESET after successful SW activation DID NOT OCCUR    console=${TRUE}
    ...    ELSE    Log    BTS is resetting after successful SW activation...    console=${TRUE}
    ${ping regain status}    Run keyword and return status    Wait For Target To Be Reachable    hostname=${SMOD1['TRS_IP']}    timeout=300
    Run keyword if    ${ping regain status}==${FALSE}    Set Test Failed    Ping has not been regained within timeout
    ...    ELSE    Log    BTS ping regained    console=${TRUE}
    Log    Waiting for stable ping...    console=${TRUE}
    ${ping stable status}    Run keyword and return status    Check If Target Is Stable    ${SMOD1['TRS_IP']}
    ...    min_uptime=360    max_downtime=0    timeout=361
    Run keyword if    ${ping stable status}==${FALSE}    Set Test Failed    Ping has not been available for 60 seconds
    ...    ELSE    Log    Ping is stable after SWM operation    console=${TRUE}
    #Wait Until Keyword Succeeds    5 min    10 sec    Fail if connection with admin is not available
    #Wait until keyword succeeds    5 min    10 sec    Fail if connection to infomodel is not available
    #Log    Will now check if BTS is OnAir, timeout=15min, interval=10sec    console=${TRUE}
    #Wait until keyword succeeds    15min    10 sec    Admin Check BTS Procedural and Blocking states    OnAir    alias=default
    Wait until keyword succeeds  15 min  30 sec  Check SBTS SOAM cells and modules
    #Log Important Message    BTS is OnAir, all cells and modules are in expected states

Check if modules states ok after sw updates
    [Documentation]    Short description.
    Log    Will now check if modules states are correct, for maximum of 60 times with 10s interval...    console=True
    FOR    ${run}    IN RANGE    1    60
    ${modules_status}=    Verify modules    RMOD    scf_check=${FALSE}
    run keyword if    '${modules_status}' == 'True'    Run Keywords    Log    Modules states are correct. Check attempt: ${run}    console=true
    ...    AND    Return from keyword    ${modules_status}
    Sleep    10
    END
    Set Test Failed    Modules states not correct within timeout

Verify cells states
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${cells_state}: <description>
    ${cells_state}=    Run keyword and return status    Wait Until Keyword Succeeds    ${restore_timeout}
    ...    5s    Fail if not all cells are on air
    [Return]    ${cells_state}

Check If Fault 23 present on ESM
    [Documentation]    If active alarm exist and is Major return True otherwise return False
    @{active_alarms} =    taf.sbts.oam.coam.admin.Get Active Alarms
    FOR    ${alarm}    IN    @{active_alarms}
    Log    FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}    console=yes
    ${notifier_is_smod}    run keyword and return status    should contain    ${alarm.notifier}    SMOD_R
    Run Keyword If    '${alarm.faultId}'=='23' and '${alarm.severity}'=='Critical' and ${notifier_is_smod}    Return From Keyword    ${TRUE}
    END
    Log    Out of loop false    console=yes
    [Return]    ${FALSE}

Check If Fault 23 cleared on SMOD
    [Documentation]    If fault 23 on SMOD is not cleared return FALSE
    @{active_alarms} =    taf.sbts.oam.coam.admin.Get Active Alarms
    Log    ${\n}Active alarms on BTS:    console=${TRUE}
    FOR    ${alarm}    IN    @{active_alarms}
    Log    FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}    console=yes
    ${notifier_is_smod}    run keyword and return status    should contain    ${alarm.notifier}    SMOD_R
    Run Keyword If    '${alarm.faultId}'=='23' and ${notifier_is_smod}    Fail    Alarm with fault 23 on ESM active
    END
    Log    ${\n}Fault23 cleared on ESM    console=yes

Check If Fault 23 present after update
    [Documentation]    Short description.
    Check if modules states ok after sw updates
    ${EXPECTED_ALARM1}=    Create Dictionary    faultId=4082
    ${EXPECTED}=    Create List    ${EXPECTED_ALARM1}
    ${CRITICAL_ALARM1}=    Create Dictionary    faultId=23
    ${CRITICAL}=    Create List    ${CRITICAL_ALARM1}
    Admin Check Active Alarms    expected_patterns=${EXPECTED}    critical_patterns=${CRITICAL}

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup
    Delete_uboot_parameters

TC_Custom Teardown
    [Documentation]    Short description.
    Common Test Teardown
    Add_uboot_parameters
