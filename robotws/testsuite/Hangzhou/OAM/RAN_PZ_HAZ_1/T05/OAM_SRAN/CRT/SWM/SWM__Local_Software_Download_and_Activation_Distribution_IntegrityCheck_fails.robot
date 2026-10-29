*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot


*** Variables ***
${TARGET_SW_NAME}       ${None}
# SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}        /home/ute/btsauto/TARGET_SW
# Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}       900
# Timeout for Download and Activation [sec]


*** Keywords ***
TC_SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails
    [Documentation]

    #[Timeout]    45 minutes
    Set Tags    CA-SWM    PHASE-CRT    OWNER-dominik.tredota@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS17    SW-SBTS18    SW-SBTS19    SW-SBTS20    FEATURE-RP000938
    ...    GROUP_IN_CHARGE-WRO_7_Vrf
    Step0: Download T1
    Step1: Check path to SW package
    Step2: Get active and passive SW version
    Step3: Modification of target SW
    Step4: Start SW update with activation
    Step5: Fault reported
    Step6: Recover the BTS

Step0: Download T1
    [Documentation]    Short description.
    Download SW T1

Step1: Check path to SW package
    [Documentation]    Short description.
    Log Step Header  Step1: Check path to SW package
    ${target_sw_path}  Get sw package from directory  ${SW_path_Download_T1}  ${TARGET_SW_NAME}
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
     Log Step Header  Step3: Modification of admin version
    Log  Unzipping file to ${TestFiles}/SW  console=${TRUE}
    ${path}  ${filename}  Split path  ${TARGET_SW_PATH}
    Set test variable  ${FILENAME}  ${filename}
    extract.Unzip  ${TARGET_SW_PATH}  ${TestFiles}/SW
    Log  Modifying value of admin version parameter in admin-version_hash file  console=${TRUE}
	${File_Path}    Run Local Linux Command  find ${TestFiles}/SW/ -name admin-version-hash_*.txt
    log    ${File_Path}
    #Run Local Linux Command  sed -i '$a SSSS' ${TestFiles}/SW/bts_sw/admin-version-hash_*.txt
	Run Local Linux Command  sed -i '$a SSSS' ${File_Path}
	${CMD}    set variable  sed -i '/<buildElement swFileKeyName="" name="HashContainer*/d' ${TestFiles}/SW/bts_sw/TargetBD_*.xml
    #run keyword if  '${target_release}'!='SBTS00'    Run Local Linux Command    ${CMD}
	Run Local Linux Command    ${CMD}
    Log  Copying modified TargetBD file to ${TestFiles}/backup/  console=${TRUE}
    #Copy File  ${TestFiles}/SW/bts_sw/admin-version-hash_*.txt  ${TestFiles}/backup/
	Copy File  ${File_Path}  ${TestFiles}/backup/
    Log  Compressing file to ${TestFiles}/  console=${TRUE}
    Run Keyword  Run  cd ${TestFiles}/SW && zip -r ${TestFiles}/${FILENAME} .
    [Teardown]  Run keyword and ignore error  OperatingSystem.Remove Directory  path=${TestFiles}/SW  recursive=${TRUE}

Step4: Start SW update with activation
    [Documentation]    Short description.
    Log Step Header  Step4: Start SW update with activation
    Log  Send SW download and activation request  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Update Software  sw_package=${TestFiles}/${FILENAME}
    ...  should_activate=${TRUE}  timeout=${UPDATE_TIMEOUT}
    Run keyword if  '${sw_update_result}'!='FAIL'  Run keywords
    ...  Log  SW update did not fail: ${sw_update_msg}  console=${TRUE}
    ...  AND
    ...  Fail  SW update did not fail: ${sw_update_msg}
    Log  Sw update fails with message: ${sw_update_msg}  console=${TRUE}
    [Teardown]  Run keyword and ignore error  OperatingSystem.Remove File  path=${TestFiles}/${FILENAME}

Step5: Fault reported
    [Documentation]    Short description.
    Log Step Header  Step5: Fault reported
    Log  Check if fault 28 appeared  console=${TRUE}
    ${alarm_28_present}  Run keyword and return status  Wait until keyword succeeds  10 m  30 s  Check if fault 28 present
    Run keyword if  ${alarm_28_present}  Log Important Message  Fault 28 is present.
    ...  ELSE  Run keywords
    ...  Log  Fault 28 is not present.  console=${TRUE}
    ...  AND
    ...  Fail  Fault 28 is not present.

Check if fault 28 present
    [Documentation]    Short description.
    ${active_alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    Run Keyword If  not ${active_alarms}  Fail  No active alarms found
    ${alarm_28}  Set variable  ${FALSE}
    FOR  ${alarm}  IN  @{active_alarms}
        ${alarm_28}  Set variable if  '${alarm}[faultId]'=='28'  ${TRUE}  ${alarm_28}
    END
    Run keyword if  not ${alarm_28}  Fail  Fault 28 is not present

Step6: Recover the BTS
    [Documentation]    Short description.
    Log Step Header  Step4: BTS reset triggering
    Setup Second Admin Thread
    Log  Send BTS reset request  console=${TRUE}
    ${reset_site_result}  ${reset_site_msg}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Reset Site  timeout=300  alias="second"
    #Run Keyword If  '${reset_site_result}'=='PASS'  Fail  BTS reset request should fail but: ${reset_site_result}
    Log  Correct behaviour - BTS reset request: ${reset_site_result}  console=${TRUE}
