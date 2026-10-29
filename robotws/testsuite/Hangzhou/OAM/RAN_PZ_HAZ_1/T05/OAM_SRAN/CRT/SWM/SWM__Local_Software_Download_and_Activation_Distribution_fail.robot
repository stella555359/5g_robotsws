*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Library           taf.sbts.oam.coam.admin
Library           ute_async


*** Variables ***
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW    # Direct path to directory where desired sw update is stored
${TARGET_SW_NAME}    ${None}    # Specify Target_SW_name if needed, otherwise newest will be chosen
${SW_DOWNLOAD_TIMEOUT}    1800    # Timeout for sw download (in seconds)
${TIMEOUT_FOR_SW_FAILED}    1200    # Timeout for fail in sw update after start
${FAULT_30_CHECK_TIMEOUT}    300    # Filtering time to trigger fault 30
${UPDATE_TIMEOUT}    1500    # Timeout for Download and Activation [sec]


*** Keywords ***
TC__SWM__Local_Software_Download_and_Activation_Distribution_fail
    [Documentation]    Short description.
    step0: Check and enable SSH if needed
    step1: Existence of SW package
    step2: Check current active and passive SW version
    Step3: Start SW download
    step4: Trigger fault 30
    step5: Fault 30 raised

step0: Check and enable SSH if needed
    [Documentation]    Short description.
    Log Step Header    Step0: Check and enable SSH if needed
    Setup hran compa    ssh_user=${SMOD1['USERNAME']}    ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Set Connection Parameters    ip=${SMOD1['TRS_IP']}    user=${SMOD1['USERNAME']}    password=${SMOD1['PASSWORD']}

step1: Existence of SW package
    [Documentation]    Search for newest SBTS software package in dedicated directory
    Log Step Header    Download T1 package for verify downloading
    Download SW T1
    Log Step Header    step1: Existence of SW package
    ${target_sw_path}    Get sw package from directory    ${SW_path_Download_T1}    ${TARGET_SW_NAME}
    Set test variable    ${TARGET_SW_PATH}    ${target_sw_path}

step2: Check current active and passive SW version
    [Documentation]    Short description.
    Log Step Header    step2: Check current active and passive SW version
    ${software_info}    taf.sbts.oam.coam.admin.Get Software Info
    ${active_sw_before}    Set variable    ${software_info['Active SW version']}
    ${passive_sw_before}    Set variable    ${software_info['Passive SW version']}
    Log    Active SW: ${active_sw_before}    console=${TRUE}
    Log    Passive SW: ${passive_sw_before}    console=${TRUE}
    ${passive_sw_before_list}    Get Regexp Matches    ${passive_sw_before}    SBTS([09]{0,2}).+
    ${active_sw_before_list}    Get Regexp Matches    ${active_sw_before}    SBTS([09]{0,2}).+
    Set Test Variable    ${active_sw_before}    ${active_sw_before_list[0]}
    Set Test Variable    ${passive_sw_before}    ${passive_sw_before_list[0]}
    Check if sw build already present on active partition    ${TARGET_SW_PATH}
    Log    SW not present on active partition    console=${TRUE}
    Check if sw build already present on passive partition    ${TARGET_SW_PATH}
    Log    SW not present on passive partition    console=${TRUE}

Step3: Start SW download
    [Documentation]    Short description.
    Log Step Header    Step3: Start SW update
    Log    Send main SW download and activation request    console=${TRUE}
    ${sw_update_result}    ${sw_update_msg}=    Run keyword and ignore error    taf.sbts.oam.coam.admin.Update Software    ${Target SW path}
    ...  False    ${SW Download Timeout}
    Run keyword if    '${sw_update_result}'=='FAIL'    Set Test Failed    Software download failed: ${sw_update_msg}

step4: Trigger fault 30
    [Documentation]    Depends on System Module hardware run action to fail sw update and to trigger fault 30
    Log Step Header    step4: Trigger fault 30 action
    Run keyword if    ("ASIA" in "${SMOD1}") or ("ASIB" in "${SMOD1}" ) or ("ASIL" in "${SMOD1}" ) or ("ASIM" in "${SMOD1}" )
    ...  Trigger fault 30 of Rel4
    ...    ELSE    Trigger fault 30 for Rel3
    ${sw_update_result}    ${sw_update_msg}    Run keyword and ignore error    taf.sbts.oam.coam.admin.Update Software    sw_package=${Target SW path}
    ...  should_activate=${TRUE}    timeout=${SW Download Timeout}
    Run keyword if    '${sw_update_result}'!='FAIL'    Run keywords    Log    SW update did not fail: ${sw_update_msg}    console=${TRUE}
    ...    AND    Fail    SW update did not fail: ${sw_update_msg}
    Log    Sw update fails with message: ${sw_update_msg}    console=${TRUE}

step5: Fault 30 raised
    [Documentation]    Short description.
    Log Step Header    Step5: Fault reported
    Log    Check if fault 30 appeared    console=${TRUE}
    ${alarm_30_present}    Run keyword and return status    Wait until keyword succeeds    10 m    30 s    Check if fault 30 present
    Run keyword if    ${alarm_30_present}    Log Important Message    Fault 30 is present.
    ...    ELSE    Run keywords    Log    Fault 30 is not present.    console=${TRUE}
    ...    AND    Fail    Fault 30 is not present.

Wait for sw download success
    [Documentation]    Every one second swDownload.result will be check if success for 15 minutes. Fail if success not reached in given timeout.
    [Timeout]    ${SW_DOWNLOAD_TIMEOUT}
    FOR    ${i}    IN RANGE    99999
    ${status}=    Run keyword and return status    ute_admin_infomodel.query_infomodel
    ...  check /MRBTS-1/RAT-1/SWM-* is [swDownloadInfo.result=Success]
    Log    SwDownloadInfo result Success: ${status}    level=DEBUG
    Exit For Loop if    ${status}
    Sleep    100s
    END
    Run keyword if    ${status}    Log    SW Download Success    console=${TRUE}

Trigger fault 30 for Rel3
    [Documentation]    Remove uImage_XXX.initramfs files in /ffs/stb/planned/boot to trigger fault 30
    Log    Checking if uImage_XXX.initramfs files exist in /ffs/stb/planned/boot    console=${TRUE}
    ${find_stdout}    Run remote Linux Command    find /ffs/stb/planned/boot/uImage_*.initramfs* && echo "Files found" || echo "Files not found"
    ${are_files_in_directory}    Run keyword and return status    Should contain    ${find_stdout}    Files found
    Log    Removing uImage_XXX.initramfs files in /ffs/stb/planned/boot to trigger fault 30    console=${TRUE}
    Run Remote Linux Command    rm /ffs/stb/planned/boot/uImage_*.initramfs*
    Log    Checking if uImage_XXX.initramfs files were deleted from /ffs/stb/planned/boot    console=${TRUE}
    ${find_stdout}    Run remote Linux Command    find /ffs/stb/planned/boot/uImage_*.initramfs* && echo "Files found" || echo "Files not found"
    ${are_files_in_directory}    Run keyword and return status    Should contain    ${find_stdout}    Files not found
    Log    Files uImage_XXX.initramfs were deleted from /ffs/stb/planned/boot    console=${TRUE}

Trigger fault 30 of Rel4
    [Documentation]    block directory of /ffs/stb/planned to trigger fault 30.
    Log    blocking /ffs/stb/planned to trigger fault 30    console=${True}
    Run remote Linux Command    chattr -R +i /ffs/stb/planned
    #Log    Rename folder output: ${output}    level=DEBUG

step6: Recovery the BTS
    [Documentation]    Depends on System Module hardware run action to fail sw update and to trigger fault 30
    Log step header    step: Recovery actions
    Log    Will now continue with recovery to remove fault 30    console=${TRUE}
    Log Step Header    Cancel fault 30
    Run keyword if    ("ASIA" in "${SMOD1}") or ("ASIB" in "${SMOD1}" ) or ("ASIL" in "${SMOD1}" ) or ("ASIM" in "${SMOD1}" )
    ...  Cancel fault 30 of Rel4

    Log    Site reset will now be performed...    console=${TRUE}
    Start async    taf.sbts.oam.coam.admin    Reset Site    600
    ${ping_check}    Run keyword and return status    Ping check after SWM operation
    Run keyword if    not ${ping_check}    Set test restriction    Site reset was nor performed correctly. Check logs...
    Wait until keyword succeeds    15 min    30 sec    Check SBTS SOAM cells and modules
    Wait until keyword succeeds    5 min    20 sec    Check SOAM Active Alarms
    Log Important Message    Fault 30 is cleared
    Log    Software rollback to remove fault    console=${True}
    run keyword and ignore error    taf.sbts.oam.coam.admin.Rollback software
    #    Run keyword if    not ${rollback_status}    FAIL    Software rollback was not performed.
    #    Log    Software rollback ended successfully.    console=${True}
    sleep    300s
    Check components states
    Log Step Header    Check path to SW package
    ${target_sw_path}    Get sw package from directory    ${Target SW dir}    ${TARGET_SW_NAME}
    Set test variable    ${TARGET_SW_PATH}    ${target_sw_path}
    ${sw_update_result}    ${sw_update_msg}    Run keyword and ignore error    taf.sbts.oam.coam.admin.Update Software
    ...  sw_package=${TARGET_SW_PATH}    should_activate=${TRUE}    timeout=2000s
    Run keyword if    '${sw_update_result}'=='FAIL'    Set Test Failed    Software activation failed: ${sw_update_msg}
    sleep    300s
    Check components states
    [Teardown]    Stop async

Custom Test Teardown
    [Documentation]    Short description.
    step6: Recovery the BTS
    Common Test Teardown

Check if fault 30 present
    [Documentation]    Short description.
    ${active_alarms}    taf.sbts.oam.coam.admin.Get Active Alarms
    Run Keyword If    not ${active_alarms}    Fail    No active alarms found
    ${alarm_30}    Set variable    ${FALSE}
    FOR    ${alarm}    IN    @{active_alarms}
    ${alarm_30}    Set variable if    '${alarm}[faultId]'=='30'    ${TRUE}    ${alarm_30}
    END
    Run keyword if    not ${alarm_30}    Fail    Fault 30 is not present

Cancel fault 30 of Rel4
    [Documentation]    unblock directory of /ffs/stb/planned to trigger fault 30.
    Log    unblocking /ffs/stb/planned to cancel fault 30    console=${True}
    ${output}    Run remote Linux Command    chattr -R -i /ffs/stb/planned

Fault 30 check
    [Documentation]    Short description.
    ${EXPECTED_ALARM}=    Create Dictionary    faultId=30
    ${EXPECTED}=    Create List    ${EXPECTED_ALARM}
    Admin Check Active Alarms    expected_patterns=${EXPECTED}

Check components states
    [Documentation]    Short description.
    Log Step Header    Step11: Check components states
    ${components_operational}    Run Keyword And Return Status    Wait until keyword succeeds    15 min    30 sec
    ...  Check SBTS SOAM cells and modules
    Run keyword if    not ${components_operational}    Set Test Failed    Components states check after BTS reset failed
    Check SOAM Active Alarms
