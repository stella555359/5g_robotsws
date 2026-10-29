*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_syve.robot
#Library           hran_tools
#Library    hran_extract
#Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/extract.py
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py


*** Variables ***
${TARGET_SW_NAME}                                   ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/    # Directory for sw package. '/home/ute/btsauto/TARGET_SW' is used in default
${TARGET_SW_DIR_TMP}                                /home/ute/btsauto/
${UPDATE_TIMEOUT}                                   1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}                              1800
${SW Activation Timeout}                            150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}                                420  # Timeout for ping loss during reset
${Ping regain timeout}                              600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                                15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                     30  # Test timeout (in minutes)


*** Keywords ***
TC_RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to verified unsingned package update
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    100 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-CB007335
    Step 1: Check active sw
    Step 2: Find Full path of package
    Step 3: Modify Hash value and repackage
    Step 4: do upgrade
    Step 5: Check fault 4266 after upgrade
    Step 6: Delete the dedicated line for RMOD in TargetBD file and repackage
    Step 7: do upgrade
    Step 8: Check fault 4267 after upgrade
    Trigger and check snapshot swupdateLog
    Step 9: Recover BTS

Get RRU Name
    [Documentation]    Short description.
    ${rmod}  taf.sbts.oam.coam.admin.Get ids for all  RMOD
    set test variable  ${rmod_distname}  ${rmod[0]}
    ${rmod_info}  Query infomodel  get object ${rmod_distname}
    set test variable  ${RRU_TYPE}  ${rmod_info['productName']}

Step ${index}: Check active sw
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: check active and passive SW version
    ${software_info}    taf.sbts.oam.coam.admin.Get Software Info
    Log    Active SW: ${software_info['Active SW version']}    console=${TRUE}
    Log    Passive SW: ${software_info['Passive SW version']}    console=${TRUE}

Step ${index}: Find Full path of package
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ${target_sw_path}  Get sw package from directory  ${Target SW dir}  ${TARGET_SW_NAME}
    Set test variable  ${TARGET_SW_PATH}  ${target_sw_path}
#    Set test variable  ${TARGET_SW_PATH}  /home/ute/btsauto/TARGET_SW_T2/SBTS00_ENB_9999_220223_000019_release_BTSSM_downloadable_A54.zip

Step ${index}: Modify Hash value and repackage
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step ${index}: Modify Hash-sig file and repackage
    Log  Unzipping file to ${TARGET_SW_DIR_TMP}/SW  console=${TRUE}
    ${path}  ${filename}  Split path  ${TARGET_SW_PATH}
    Set test variable  ${FILENAME}  ${filename}
    extract.Unzip  ${TARGET_SW_PATH}  ${TARGET_SW_DIR_TMP}/SW
    Log  Modifying value of admin version parameter in admin-version_hash file  console=${TRUE}
	${File_Path}    Run Local Linux Command  find ${TARGET_SW_DIR_TMP}/SW/bts_sw/ -name HashContainerSignature_SBTS*.sig
    log    ${File_Path}
    ${CMD_hash}    set variable  sed -i '1i SSSS' ${File_Path}
	Run Local Linux Command  ${CMD_hash}
    Log  Copying modified hash file to ${TARGET_SW_DIR_TMP}/backup/  console=${TRUE}
	Copy File  ${File_Path}  ${TARGET_SW_DIR_TMP}/backup/
    Log  Compressing file to ${TARGET_SW_DIR_TMP}/  console=${TRUE}
    Run Keyword  Run  cd ${TARGET_SW_DIR_TMP}/SW && zip -r ${TARGET_SW_DIR_TMP}/${FILENAME} .
    [Teardown]  Run keyword and ignore error  OperatingSystem.Remove Directory  path=${TARGET_SW_DIR_TMP}/SW  recursive=${TRUE}

Step ${index}: do upgrade
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step${index}: do upgrade
    Log  Send SW download and activation request  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.Update Software  sw_package=${TARGET_SW_DIR_TMP}/${FILENAME}
    ...  should_activate=${TRUE}  timeout=${UPDATE_TIMEOUT}
    Run keyword if  '${sw_update_result}'!='FAIL'  Run keywords
    ...  Log  SW update did not fail: ${sw_update_msg}  console=${TRUE}
    ...  AND
    ...  Fail  SW update did not fail: ${sw_update_msg}
    Log  Sw update fails with message: ${sw_update_msg}  console=${TRUE}
    [Teardown]  Run keyword and ignore error  OperatingSystem.Remove File  path=${TARGET_SW_DIR_TMP}/${FILENAME}

Step ${index}: Check fault 4266 after upgrade
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    wait until keyword succeeds   10min  30s  Check fualts on admin   4266  Minor

Step ${index}: Check fault 4267 after upgrade
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    wait until keyword succeeds   10min  30s  Check fualts on admin   4267  Minor

Step ${index}: Recover BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Reset testline

Step ${index}: Delete the dedicated line for RMOD in TargetBD file and repackage
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step ${index}: Delete the dedicated line for RMOD in TargetBD file and repackage
    Log  Unzipping file to ${TARGET_SW_DIR_TMP}/SW  console=${TRUE}
    ${path}  ${filename}  Split path  ${TARGET_SW_PATH}
    Set test variable  ${FILENAME}  ${filename}
    extract.Unzip  ${TARGET_SW_PATH}  ${TARGET_SW_DIR_TMP}/SW
    Log  Modifying value of admin version parameter in admin-version_hash file  console=${TRUE}
	${File_Path}    Run Local Linux Command  find ${TARGET_SW_DIR_TMP}/SW/bts_sw/ -name TargetBD*.xml
    log    ${File_Path}
    Get RRU Name
    set test variable  ${cmd_del}  sed --in-place '/swFileKeyName="LTX_${RRU_TYPE}/d' ${File_Path}
	Run Local Linux Command  ${cmd_del}
    Log  Copying modified hash file to ${TARGET_SW_DIR_TMP}/backup/  console=${TRUE}
	Copy File  ${File_Path}  ${TARGET_SW_DIR_TMP}/backup/
    Log  Compressing file to ${TARGET_SW_DIR_TMP}/  console=${TRUE}
    Run Keyword  Run  cd ${TARGET_SW_DIR_TMP}/SW && zip -r ${TARGET_SW_DIR_TMP}/${FILENAME} .
    [Teardown]  Run keyword and ignore error  OperatingSystem.Remove Directory  path=${TARGET_SW_DIR_TMP}/SW  recursive=${TRUE}

Check fualts on admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${faultId}: <description>
    ...        ${severity}: <description>
    [Arguments]   ${faultId}   ${severity}
    ${EXPECTED_ALARM1}     Create Dictionary  faultId=${faultId}  severity=${severity}
    ${EXPECTED_ALARMs}            Create List  ${EXPECTED_ALARM1}
    Admin Check Active Alarms  expected_patterns=${EXPECTED_ALARMs}

Reset testline
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.run keyword in background    Reset  timeout=300
    log to console with time  Check if reset is performed
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for reset  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after Reset
    Log  BTS is stable after Reset.  console=${TRUE}

Trigger and check snapshot swupdateLog
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Collect Snapshot     snapshot.zip
    Run     mv snapshot.zip ${TestFiles}/Snapshot.zip
    Run     unzip -o ${TestFiles}/Snapshot.zip -d ${TARGET_SW_DIR_TMP}${/}Snapshot
    ${string}=  Run   grep 'swupdate.log.zip' ${TARGET_SW_DIR_TMP}${/}Snapshot${/}snapshot_file_list.txt
    Run keyword and ignore error    Run     rm -r ${TARGET_SW_DIR_TMP}${/}Snapshot/
