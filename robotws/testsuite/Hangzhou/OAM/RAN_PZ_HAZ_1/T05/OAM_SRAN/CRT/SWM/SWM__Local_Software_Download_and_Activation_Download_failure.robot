*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot


*** Variables ***
${TARGET_SW_NAME}       ${None}
# SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}        /home/ute/btsauto/TARGET_SW/
# Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}       900
# Timeout for Download and Activation [sec]


*** Keywords ***
TC__SWM__Local_Software_Download_and_Activation_Download_failure
    [Documentation]    Short description.
    [Timeout]    45 minutes
    Set Tags    CA-SWM    PHASE-CRT    OWNER-dominik.tredota@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS17    SW-SBTS18    SW-SBTS19    SW-SBTS20    FEATURE-RP000938
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    Step1: Check path to SW package
    Step2: Get active and passive SW version
    Step3: Start SW update
    Step4: Remove the target SW
    Step5: Fault reported
    Step6: Recovery the ENV

Step1: Check path to SW package
    [Documentation]    Short description.
    Log Step Header  Step1: Check path to SW package
    ${target_sw_path}  Get sw package from directory  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Set test variable  ${TARGET_SW_PATH}  ${target_sw_path}

Step2: Get active and passive SW version
    [Documentation]    Short description.
    Log Step Header  Step2: Get active and passive SW version
    Check if sw build already present on active partition  ${TARGET_SW_PATH}
    Log  SW not present on active partition  console=${TRUE}
    Check if sw build already present on passive partition  ${TARGET_SW_PATH}
    Log  SW not present on passive partition  console=${TRUE}

Step3: Start SW update
    [Documentation]    Short description.
    Log Step Header  Step3: Start SW update
    Log  Send main SW download and activation request  console=${TRUE}
    ${main_update_thread}  taf.sbts.oam.coam.admin.Run keyword in background
    ...    Update Software  sw_package=${TARGET_SW_PATH}  timeout=${UPDATE_TIMEOUT}
    Set test variable  ${MAIN_UPDATE_THREAD}  ${main_update_thread}
    Sleep  10

Step4: Remove the target SW
    [Documentation]    Short description.
    Log Step Header  Step3: Move target SW
    Run Local Linux Command  rm ${TARGET_SW_PATH}

Step5: Fault reported
    [Documentation]    Short description.
    Log Step Header  Step5: Fault reported
    Log  Check if fault 27 appeared  console=${TRUE}
    ${alarm_27_present}  Run keyword and return status  Wait until keyword succeeds  15 m  13s  Check if fault 27 present
    Run keyword if  ${alarm_27_present}  Log Important Message  Fault 27 is present.
    ...  ELSE  Run keywords
    ...  Log  Fault 27 is not present.  console=${TRUE}
    ...  AND
    ...  Fail  Fault 27 is not present.

Check if fault 27 present
    [Documentation]    Short description.
    ${active_alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    Run Keyword If  not ${active_alarms}  Fail  No active alarms found
    ${alarm_27}  Set variable  ${FALSE}
    FOR  ${alarm}  IN  @{active_alarms}
        ${alarm_27}  Set variable if  '${alarm}[faultId]'=='27'  ${TRUE}  ${alarm_27}
    END
    Run keyword if  not ${alarm_27}  Fail  Fault 27 is not present

Step6: Recovery the ENV
    [Documentation]    Short description.
    #${release_list}=    get_enb    ${target_release}
	${recover_build}    run keyword if  '${release_list_1}' in '${TARGET_SW_PATH}'  set variable    ${release_list_1}   ELSE IF
	...  '${release_list_2}' in '${TARGET_SW_PATH}'  set variable    ${release_list_2}   ELSE    set variable    ${release_list_3}
    ${TARGET_SW_DIR}    Download_Specify_Build_By_Aria    ${recover_build}    Basic    ${TARGET_SW_DIR}
    set suite variable    ${release_list}
    Log Step Header  Step4: BTS reset triggering
    Log  Send BTS reset request  console=${TRUE}
    ${reset_site_result}  ${reset_site_msg}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Reset Site  timeout=300
