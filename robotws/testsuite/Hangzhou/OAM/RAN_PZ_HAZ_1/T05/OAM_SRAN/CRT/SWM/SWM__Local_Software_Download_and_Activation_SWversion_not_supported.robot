*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Library    hran_extract
#Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/extract.py


*** Variables ***
${TARGET_SW_NAME}       ${None}                         # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}        /home/ute/btsauto/TARGET_SW     # Directory for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}       900                            # Timeout for Download and Activation [sec]


*** Keywords ***
TC__SWM__Local_Software_Download_and_Activation_SWversion_not_supported
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-14749
    ...
    ...  ***********************************************************
    ...  2. Description
    ...  ***********************************************************
    ...  The purpose of this test case is to verify if SW update will fail in case not supported SW package.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-14749 - Initial creation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/TAT-14749-SWM__Local_Software_Download_and_Activation_SWversion_not_supported.png

    #[Timeout]    45 minutes
    Set Tags    CA-SWM    PHASE-CRT    OWNER-kamil.osak@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS17    SW-SBTS18    SW-SBTS19    SW-SBTS20    FEATURE-RP000938
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    Step1: Check path to SW package
    Step2: Get active and passive SW version
    Step3: Modification of target SW
    Step4: Start SW update with activation
    Step5: Fault reported

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

Step3: Modification of target SW
    [Documentation]    Short description.
    Log Step Header  Step3: Modification of target SW
    Set test variable    ${TempTestFiles}    /home/ute/btsauto
    Log  Unzipping file to ${TempTestFiles}/SW  console=${TRUE}
    ${path}  ${filename}  Split path  ${TARGET_SW_PATH}
    Set test variable  ${FILENAME}  ${filename}
    extract.Unzip  ${TARGET_SW_PATH}  ${TempTestFiles}/SW
    Log  Modifying value of softwareReleaseVersion parameter in TargetBD file  console=${TRUE}
    Run Local Linux Command
    ...  sed -i -re 's/softwareReleaseVersion="\\w+"/softwareReleaseVersion="SW_not_supported"/' ${TempTestFiles}/SW/bts_sw/TargetBD_*.xml
    Log  Copying modified TargetBD file to ${TempTestFiles}/backup/  console=${TRUE}
    Copy File  ${TempTestFiles}/SW/bts_sw/TargetBD_*.xml  ${TempTestFiles}/backup/
    Log  Compressing file to ${TempTestFiles}/  console=${TRUE}
    Run Keyword  Run  cd ${TempTestFiles}/SW && zip -r ${TempTestFiles}/${FILENAME} .
    [Teardown]  Run keyword and ignore error  OperatingSystem.Remove Directory  path=${TempTestFiles}/SW  recursive=${TRUE}

Step4: Start SW update with activation
    [Documentation]    Short description.
    Log Step Header  Step4: Start SW update with activation
    Log  Send SW download and activation request  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.Update Software  sw_package=${TempTestFiles}/${FILENAME}
    ...  should_activate=${TRUE}  timeout=${UPDATE_TIMEOUT}
    Run keyword if  '${sw_update_result}'!='FAIL'  Run keywords
    ...  Log  SW update did not fail: ${sw_update_msg}  console=${TRUE}
    ...  AND
    ...  Fail  SW update did not fail: ${sw_update_msg}
    Log  Sw update fails with message: ${sw_update_msg}  console=${TRUE}
    [Teardown]  Run keyword and ignore error  OperatingSystem.Remove File  path=${TempTestFiles}/${FILENAME}

Step5: Fault reported
    [Documentation]    Short description.
    Log Step Header  Step5: Fault reported
    Log  Check if fault 24 appeared  console=${TRUE}
    ${active_alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    Run Keyword If  not ${active_alarms}  Log  No active alarms have been found.  console=${TRUE}
    ${alarm_24_present}  Set variable  ${FALSE}
    FOR  ${alarm}  IN  @{active_alarms}
        ${alarm_24_present}  Set variable if  '${alarm}[faultId]'=='24'  ${TRUE}  ${alarm_24_present}
    END
    Run keyword if  ${alarm_24_present}  Log Important Message  Fault 24 is present.
    ...  ELSE  Run keywords
    ...  Log  Fault 24 is not present.  console=${TRUE}
    ...  AND
    ...  Fail  Fault 24 is not present.
