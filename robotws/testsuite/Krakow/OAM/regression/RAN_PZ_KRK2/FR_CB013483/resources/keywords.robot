*** Settings ***
Documentation
...    Author: Przemyslaw Kusa, przemyslaw.kusa@nokia.com
...    Maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com

Library      OperatingSystem
Library      String
Library      BuiltIn
Library      re
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME    AsirOperations
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning             WITH NAME    du
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations              WITH NAME    GnbDuOp
Library      taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations          WITH NAME    RuOp
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations          WITH NAME    GnbCellOp
Library      taf.rfrl.bts.devices.generic_bts.GenericBts                        WITH NAME    GenericBts
Library      taf.rfrl.bts.devices.du.sw_update.GnbSwUpdate                      WITH NAME    GenericSwUp
Library      taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    DuAlarms
Library      ./CustomKeywords.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/resources/robot/SwUpdate.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./delta.py

*** Variables ***
${bts_id}=                   ${tl.gnbs[0].global_bts_id}
${25R1_BUILD}=               SBTS25R1_ENB_0000_001178_000000
${SW_YAFT_DOWNLOAD_PATH}=    /home/ute/.ute-ca/cache/bts
${SW_YAFT_PATH}=             /home/ute/.ute-ca/cache/bts/${25R1_BUILD}_release_BTSSM_downloadable_A54.zip
${ADDITIONAL_PARAM}=         --clean_to_default
${SW_PATH}=                  /home/ute/UUF_SW
${TIMEOUT}=                  1800
${SW_TARGET}=                basic_sw
@{ALARMS_LIST}=              WiFi Configuration Issue
${FIRST_SW}=                 ${None}
${CURRENT_SW}=               ${None}
${AsirIncompatibleSW}=       ${None}
${SCF_PATH}=                 ${None}
${SCF_NAME}=                 ${None}
${ASIR_SCF_PATH}=            ${None}
${SKIP_YAFT}=                ${None}
${ASIR_RELEASE}=             ${None}
${RELEASE}=                  ${None}

*** Keywords ***
ASIR Commissioning
    [Arguments]    ${scf_path}
    ${result}    Run Keyword And Ignore Error    AsirOperations.perform_asir_commissioning    scf_path=${scf_path}
    ${status}    Set Variable    ${result}[0]
    ${return_value}    Set Variable    ${result}[1]
    [Return]    ${return_value}

ASIR Perform Recomissioning
    [Arguments]    ${delta}    ${delta_file_name}    ${download_dir}
    ${output}    Run Keyword And Ignore Error    AsirOperations.perform_asir_recommissioning    delta=${delta}
    ...    save_delta_plan=True
    ...    delta_file_name=${delta_file_name}
    ...    download_dir=${download_dir}
    ${ASIR_Recomissioning_Output}    Set Variable    ${output}[0]
    Set Suite Variable    ${ASIR_Recomissioning_Output}

ASIR Get Current SCF File
    [Arguments]    ${local_dir_path}    ${file_name}
    AsirOperations.get_current_scf_file
    ...    local_dir_path=${local_dir_path}
    ...    file_name=${file_name}

Get All Parameters Under Class Name
    [Arguments]    ${scf_file_path}    ${class_name}
    ${class_parameters}    AsirOperations.get_all_params_under_class_name
    ...    scf_file_path=${scf_file_path}
    ...    class_name=${class_name}
    Set Suite Variable    ${class_parameters}

Verify If Parameter Is Set To Proper Value
    [Arguments]    ${local_dir_path}    ${file_name}    ${scf_file_path}    ${class_name}    ${dn_param}    ${param_value}
    ASIR Get Current SCF File
    ...    local_dir_path=${local_dir_path}
    ...    file_name=${file_name}
    Get All Parameters Under Class Name
    ...    scf_file_path=${scf_file_path}
    ...    class_name=${class_name}
    ${isMatching}    compareValue
    ...    dn=${class_parameters}
    ...    dn_param=${dn_param}
    ...    param_value=${param_value}

    [Return]    ${isMatching}

Perform BTS Commissioning
    [Arguments]    ${bts_scf_file}
    du.perform_bts_full_commissioning    scf_file=${bts_scf_file}    timeout=360

GNB Get Param Value
    [Arguments]    ${param_name}
    ${GNB_Param}    GnbDuOp.get_param_value    param_name=${param_name}
    Set Suite Variable    ${GNB_Param}
    Log To Console    ${param_name} parameter value is: ${GNB_Param}

Wait For Cells On Air
    Log To Console    Waiting for all cells to be onAir
    GnbDuOp.wait_for_site_to_be_onair    timeout=360    interval=30
    Wait Until Keyword Succeeds    300 sec    30 sec
    ...    GnbCellOp.verify_all_cells_statuses    cell_type=all
    ...                                           operational_state=enabled

Verify If ASIRMOD Is Enabled
    [Arguments]    ${flag_check_sw_ver}
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting for ASIRMOD(s) to be enabled
    TRY
        Wait Until Keyword Succeeds    360 sec    30 sec    RuOp.verify_radio_unit_is_online    radio_type=asirmod
        Set Suite Variable    ${AsirIsOnAir}    ${True}
    EXCEPT    AS    ${error}
        Log To Console    ${error}
        Set Suite Variable    ${AsirIsOnAir}    ${False}
    END

    IF    ${flag_check_sw_ver} == "True"
        TRY
            Get And Set Current Time
            Log To Console    [${timestamp}] Verifying if Incompatible SW Version alarm is raised
            Verify If Incompatible SW Version Detected Alarm Is Raised
            Set Suite Variable    ${AsirIncompatibleSW}    ${True}
        EXCEPT    AS    ${error}
            Log To Console    ${error}
            Set Suite Variable    ${AsirIncompatibleSW}    ${False}
        END
    END
    Get And Set Current Time
    IF    "${AsirIsOnAir}" == "False" and "${AsirIncompatibleSW}" == "True"
        Check SW Version
        IF    "${CURRENT_SW}" != "${25R1_BUILD}"
            Log To Console    [${timestamp}] Downloading SW: ${CURRENT_SW}
            GenericSwUp.download_sw_package
        ...    sw_version=${CURRENT_SW}
        ...    target_dir=${SW_YAFT_DOWNLOAD_PATH}
        END
        Get And Set Current Time
        Log To Console    [${timestamp}] Starting update SW!
        Update SW    sw_version=${CURRENT_SW}    path=${SW_YAFT_DOWNLOAD_PATH}    expected_sw=${CURRENT_SW}
    ELSE IF    "${AsirIsOnAir}" == "True"
        Log To Console    [${timestamp}] ASIRMOD(s) enabled!
    ELSE
        Fail    Asirmod(s) not enabled!
    END

Prepare Testline
    [Arguments]    ${bts_scf_file}    ${scf_path}    ${flag}
    Log To Console    Performing BTS Commissioning!
    TRY
        Perform BTS Commissioning    bts_scf_file=${bts_scf_file}
    EXCEPT    AS    ${error}
        Log To Console    ${error}
    END
    Disconnect from BTS
    Verify If ASIRMOD Is Enabled    flag_check_sw_ver=${flag}
    Log To Console    Performing ASIR Commissioning!
    ASIR Commissioning    scf_path=${scf_path}
    Sleep    45 sec    reason=Time until reset will trigger
    Wait For Cells On Air
    Log To Console    Site is on Air!

Disconnect from BTS
    GenericBts.disconnect

Set Allowed Alarms
    Set Suite Variable    @{allowed_alarms}    SSH enabled
    ...                                        R&D Service Port enabled
    ...                                        Service account root access is enabled
    ...                                        Ethernet port security is disabled
    ...                                        LMP access via port 443
    ...                                        Setup of X2 connectivity to gNB failed
    ...                                        LMP connectivity detected
    ...                                        Diagnostic Check Error
    ...                                        Sanity Check Error
    ...                                        Unit power reset
    ...                                        BTS Reset Cause

Check SW Version
    GenericBts.connect
    ${SWVER}    Get Software Version
    Set Suite Variable    ${CURRENT_SW}    ${SWVER}

Check Release
    ${package_items}    Split String    ${CURRENT_SW}
    ...                                 separator=_
    ...                                 max_split=2
    ${RELEASE}    Set Variable    ${package_items}[0]
    Set Suite Variable    ${RELEASE}

Check And Verify SW Version
    Log To Console    Verifying SW version...
    Check SW Version
    Check Release
    ${match}    Evaluate    re.match(r"^SBTS2[6-7]R[1-3]$", "${RELEASE}") is not None
    IF    "${match}" != "False" or "${RELEASE}" == "SBTS25R3" or "${RELEASE}" == "SBTS00"
        Log To Console    Current SW: ${CURRENT_SW}
    ELSE
        Fail    Incorrect SW activated!
    END

Get And Set Current Time
    ${timestamp}    BuiltIn.Get Time    result_format=%d-%m-%Y %H:%M:%S
    Set Suite Variable    ${timestamp}

Prepare Proper SW Version
    Get And Set Current Time
    Log To Console    [${timestamp}] Downloading yaft...
    GenericSwUp.download_yaft
    Get And Set Current Time
    Log To Console    [${timestamp}] Downloading SW: ${25R1_BUILD}
    GenericSwUp.download_sw_package
    ...               sw_version=${25R1_BUILD}
    ...               target_dir=${SW_YAFT_DOWNLOAD_PATH}
    Get And Set Current Time
    Log To Console    [${timestamp}] SW downloaded to: ${SW_YAFT_DOWNLOAD_PATH}
    Get And Set Current Time
    Log To Console    [${timestamp}] Starting update SW via yaft!
    GenericSwUp.update_software_via_yaft
    ...               sw_package_path=${SW_YAFT_PATH}
    ...               additional_options=${ADDITIONAL_PARAM}
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting 10 minutes to SW apply and reset...
    Sleep             600 sec    reason=Time for SW to apply
    Disconnect from BTS
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting for site to be operational...
    Wait Until Keyword Succeeds    300 sec    60 sec
    ...               GnbDuOp.verify_bts_is_not_commissioned
    Get And Set Current Time
    Log To Console    [${timestamp}] SW: ${25R1_BUILD} is activated!
    Log To Console    [${timestamp}] Removing yaft_image files...
    Run               sudo rm -rf /home/ute/yaft_latest/YAFT_IMAGE
    Disconnect from BTS

Verify If Yaft Is Required
    Set Suite Variable    ${isYafted}    ${None}
    Set Suite Variable    ${isCommissionned}    ${None}
    Get And Set Current Time
    Log To Console    [${timestamp}] Veryfing if site is operational...
    TRY
        Wait Until Keyword Succeeds    180 sec    30 sec
        ...        GnbDuOp.verify_bts_is_not_commissioned
    EXCEPT    AS    ${error}
        Log To Console    ${error}
    END
    Check SW Version
    Check Release
    Get And Set Current Time
    Log To Console    [${timestamp}] Checking if SW change is necessary...
    IF    "${RELEASE}" != "SBTS25R1"
        Log To Console    Wrong SW detected! Preparing for yaft...
        Prepare Proper SW Version
        Set Suite Variable  ${isYafted}  ${True}
    ELSE
        Log To Console    Proper build is already installed! Skipping SW change...
        Set Suite Variable    ${isYafted}    ${False}
    END

Update SW
    [Arguments]    ${sw_version}    ${path}    ${expected_sw}
    Get And Set Current Time
    Log To Console    [${timestamp}] SW is updating!
    Download And Update SW
    ...           sw_version=${sw_version}
    ...           sw_target=${SW_TARGET}
    ...           timeout=${TIMEOUT}
    ...           path=${path}
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting few minutes to SW apply and reset...
    Sleep    300 sec    reason=Time for SW to apply
    Disconnect from BTS
    Wait Until Keyword Succeeds    10 min    30 sec    GnbCellOp.verify_all_cells_are_onair
    Check SW Version
    IF    "${CURRENT_SW}" != "${expected_sw}"
        Fail    Unexpected SW is activated!
    END
    Get And Set Current Time
    Log To Console    [${timestamp}] Update is completed! Site is onAir! Current SW: ${CURRENT_SW}

Rollback SW
    [Arguments]    ${expected_sw}
    Get And Set Current Time
    Log To Console    [${timestamp}] Performing SW Rollback!
    GnbDuOp.rollback_software
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting a few minutes until the reset is complete and site will be onAir
    Sleep    120 sec    reason=Time for rollback complete
    Disconnect from BTS
    Wait Until Keyword Succeeds    10 min    30 sec    GnbCellOp.verify_all_cells_are_onair
    Check SW Version
    IF    "${CURRENT_SW}" != "${expected_sw}"
        Fail    Unexpected SW is activated!
    END
    Get And Set Current Time
    Log To Console    [${timestamp}] Rollback is completed and site is onAir! Current SW: ${CURRENT_SW}

Verify If Non-ITSAR Values Are Set
    [Arguments]    @{params}
    ${results}=    Create List
    FOR    ${param}    IN    @{params}
        ${dn_param}=    Set Variable    ${param.split('=')[0]}
        ${param_value}=    Set Variable    ${param.split('=')[1]}
        ${result}=    Verify If Parameter Is Set To Proper Value
        ...    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
        ...    file_name=ASIR_FULLSCF.xml
        ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
        ...    class_name=com.nokia.asi:SECPRM
        ...    dn_param=${dn_param}
        ...    param_value=${param_value}
        Append To List    ${results}    ${result}
    END
    ${is_any_true}=    Evaluate    any([r == True for r in ${results}])
    Set Suite Variable    ${isSetToNotItsar}    ${is_any_true}

Check Non-ITSAR Parameters
    @{params}=    Create List
    ...    allowASiLocalUserDefaultPassword=true
    ...    passwdHistoryLength=1
    ...    localPasswdExpiryPeriod=0
    ...    webEMSessionLoginDelay=1
    [Return]    @{params}

Verify If ITSAR Values Are Set
    [Arguments]    @{params}
    ${results}=    Create List
    FOR    ${param}    IN    @{params}
        ${dn_param}=    Set Variable    ${param.split('=')[0]}
        ${param_value}=    Set Variable    ${param.split('=')[1]}
        ${result}=    Verify If Parameter Is Set To Proper Value
        ...    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
        ...    file_name=ASIR_FULLSCF.xml
        ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
        ...    class_name=com.nokia.asi:SECPRM
        ...    dn_param=${dn_param}
        ...    param_value=${param_value}
        Append To List    ${results}    ${result}
    END
    ${is_all_true}=    Evaluate    all([r == True for r in ${results}])
    Set Suite Variable    ${isSetToItsar}    ${is_all_true}

Check ITSAR Parameters
    @{params}=    Create List
    ...    allowASiLocalUserDefaultPassword=false
    ...    passwdHistoryLength=3
    ...    localPasswdExpiryPeriod=30
    ...    webEMSessionLoginDelay=5
    [Return]    @{params}

Set Additional Allowed Alarms
    Set Suite Variable    @{additional_allowed_alarms}    @{ALARMS_LIST}

Remove SW Package
    [Arguments]    ${build}    ${path}
    Get And Set Current Time
    Log To Console    [${timestamp}] Removing SW: ${build} from ${path}
    Run               sudo rm -f ${path}/${build}_release_BTSSM_downloadable_A54.zip

Suite Setup Custom
    Check SW Version
    IF    "${FIRST_SW}" == "${None}"
        Set Suite Variable    ${FIRST_SW}    ${CURRENT_SW}
    END
    Check Testline ID
    Verify If SW Is Applicable For Yaft
    IF    "${SKIP_YAFT}" == "${True}" or "${Can_Be_Yafted}" == "${False}"
        Log To Console    Flag is set to true or SW is not eligible for YAFT, skipping YAFT
    ELSE
        Verify If Yaft is required
    END
    Check SW Version
    Check Release
    Set Additional Allowed Alarms
    Common Suite Setup With OnAir Test Line Preparation
    ...    swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT11SK100/default_swconfig.txt
    ...    prefix_tag=CB013483
    ...    increase_timeout_for_update_sw=900
    ...    incompatible_error_timer=900
    ...    scfs_path=commissionings/Krakow/7_7_UTE5GCLOUDT11SK100/${RELEASE}
    ...    list_of_additional_allowed_alarms=@{ALARMS_LIST}
    Set Allowed Alarms
    Remove SW Package
    ...    build=${25R1_BUILD}
    ...    path=${SW_YAFT_DOWNLOAD_PATH}

Change MCC Value To 1 On BTS And ASIR
    Check Testline ID
    Check SW Version
    Check Release
    IF    "${RELEASE}" == "SBTS25R3"
        ${SCF_NAME}    Set Variable    25R3_MCC_1_MRBTS.xml
    ELSE
        ${SCF_NAME}    Set Variable    26R1_MCC_1_MRBTS.xml
    END
    Set ASIR SCF Path
    GNB Get Param Value    param_name=mcc
    Run Keyword If    ${GNB_Param} == 1 or ${GNB_Param} == 244
    ...    Log To Console    MCC parameter is set to 1, skipping recomissioning
    ...    ELSE    Prepare Testline    bts_scf_file=${CURDIR}/../scfs/${SCF_PATH}/${SCF_NAME}
    ...    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_1_ASIR.xml
    ...    flag=${False}

Check Passive SW
    GnbDuOp.check_bts_sw_version    sw_version=${25R1_BUILD}    partition=passive

Suite Teardown Custom
    Change MCC Value To 1 On BTS And ASIR
    Common Suite Teardown

Verify If Incompatible SW Version Detected Alarm Is Raised
    Wait Until Keyword Succeeds    3 min    30 sec     DuAlarms.verify_alarm_is_active
    ...                                                fault_name=Incompatible SW version detected
    ...                                                fault_id=23

Check Testline ID
    IF    "${bts_id}" == "76076"
       Set Suite Variable    ${SCF_PATH}    TL76
    ELSE IF    "${bts_id}" == "81100"
       Set Suite Variable    ${SCF_PATH}    TL100
    END

Create UUF_SW Directory
    ${run_output}    Run    mkdir ${SW_PATH}
    IF    "${run_output}" == "${EMPTY}"
        Log To Console    Directory ${SW_PATH} created successfully!
    ELSE
        Log To Console    Directory already exist!
    END

Verify Parameters After Rollback
    [Arguments]    @{params}
    ${results}=    Create List
    FOR    ${param}    IN    @{params}
        ${dn_param}=    Set Variable    ${param.split('=')[0]}
        ${param_value}=    Set Variable    ${param.split('=')[1]}
        ${result}=    Verify If Parameter Is Set To Proper Value
        ...    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
        ...    file_name=ASIR_FULLSCF.xml
        ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
        ...    class_name=com.nokia.asi:SECPRM
        ...    dn_param=${dn_param}
        ...    param_value=${param_value}
        Append To List    ${results}    ${result}
    END
    ${is_any_true}=    Evaluate    any([r == True for r in ${results}])
    Set Suite Variable    ${isSetToWrongValues}    ${is_any_true}

Check Rollback Parameters
    @{params}=    Create List
    ...    allowASiLocalUserDefaultPassword=true
    ...    passwdHistoryLength=2
    ...    localPasswdExpiryPeriod=0
    ...    webEMSessionLoginDelay=3
    [Return]    @{params}

Test Setup Custom
    IF    "${SCF_PATH}" != "TL76" or "${SCF_PATH}" != "TL100"
        Check Testline ID
    END
    Common Preconditions

Check If Yaft Is Necessary
    IF    "${FIRST_SW}" == "None"
        Fail    No SW version set to update
    END
    Verify If Yaft Is Required
    IF    "${isYafted}" == "True"
        Prepare Testline    bts_scf_file=${CURDIR}/../scfs/${SCF_PATH}/25R1_MCC_404_MRBTS.xml
        ...    scf_path=${CURDIR}/../scfs/${SCF_PATH}/25R1_MCC_404_ASIR.xml
        ...    flag=${True}
        Remove SW Package
        ...    build=${25R1_BUILD}
        ...    path=${SW_YAFT_DOWNLOAD_PATH}
    END

Check Non-ITSAR Values
    Log To Console    Verifying if Non-ITSAR values are set
    @{NonItsarParams}    Check Non-ITSAR Parameters
    Verify If Non-ITSAR Values Are Set    @{NonItsarParams}
    IF    "${isSetToNotItsar}" != "True"
        ASIR Perform Recomissioning    delta=${wrong_itsar_params}
        ...    delta_file_name=ASIR_delta.xml
        ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    END

Check ITSAR Values
    Log To Console    Verifying if ITSAR values are set
    @{ItsarParamsSet}    Check ITSAR Parameters
    Verify If ITSAR Values Are Set    @{ItsarParamsSet}
    IF    "${isSetToItsar}" != "True"
        ASIR Perform Recomissioning    delta=${itsar_params}
        ...    delta_file_name=ASIR_delta.xml
        ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    END

Check Values After Rollback
    Log To Console    Verifying if values after rollback are correct
    @{ParamsAfterRollback}    Check Rollback Parameters
    Verify Parameters After Rollback    @{ParamsAfterRollback}
    IF    "${isSetToWrongValues}" == "True"
        Log To Console    Values are matching with 25R1!
    ELSE
        Fail    The values were not migrated between partitions!
    END

Check MCC And Upload SCF With MCC 404 On BTS And MCC 1 With ITSAR Params On ASIR
    Set ASIR SCF Path
    GNB Get Param Value    param_name=mcc
    Run Keyword If    ${GNB_Param} == 404 or ${GNB_Param} == 405 or ${GNB_Param} == 406
    ...    Log To Console    MCC ${GNB_Param} is correct, skipping BTS recomissioning
    ...    ELSE    Prepare Testline    bts_scf_file=${CURDIR}/../scfs/${SCF_PATH}/25R3_MCC_404_MRBTS.xml
    ...    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_1_ASIR_WITH_ITSAR_PARAM.xml
    ...    flag=${False}

Check If PasswdHistoryLength Is Set To 3
    ${isMatching}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:SECPRM
    ...    dn_param=passwdHistoryLength
    ...    param_value=3
    Run Keyword If    ${isMatching} == False    ASIR Perform Recomissioning    delta=${itsar_params}
    ...    delta_file_name=ASIR_delta.xml
    ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    ...    ELSE    Log To Console    Parameter is matching, skipping recommissioning

Check If MCC Is Set To 404
    ${isMatching}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:BTS
    ...    dn_param=mcc
    ...    param_value=404
    Run Keyword If    ${isMatching} == False    ASIR Perform Recomissioning    delta=${delta_mcc_404}
    ...    delta_file_name=ASIR_delta.xml
    ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    ...    ELSE    Log To Console    Parameter is matching, skipping recommissioning

Check MCC And Upload SCF With MCC 404 On BTS And MCC 1 On ASIR
    Set ASIR SCF Path
    GNB Get Param Value    param_name=mcc
    Run Keyword If    ${GNB_Param} == 404 or ${GNB_Param} == 405 or ${GNB_Param} == 406
    ...    Log To Console    mcc ${GNB_Param} is correct, skipping BTS recomissioning
    ...    ELSE    Prepare Testline    bts_scf_file=${CURDIR}/../scfs/${SCF_PATH}/25R3_MCC_404_MRBTS.xml
    ...    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_1_ASIR.xml
    ...    flag=${False}

Check If AllowASiLocalUserDefaultPassword Is Set To True And MCC Is Set To 1
    ${isMatching1}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:SECPRM
    ...    dn_param=allowASiLocalUserDefaultPassword
    ...    param_value=true
    ${isMatching2}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:BTS
    ...    dn_param=mcc
    ...    param_value=1
    IF    ${isMatching1} == True and ${isMatching2} == True
        ${comissioning_required}    Set Variable    ${False}
    ELSE
        ${comissioning_required}    Set Variable    ${True}
    END
    IF    ${comissioning_required} == True
        Run Keywords
        ...    Set ASIR SCF Path    AND
        ...    ASIR Commissioning    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_1_ASIR.xml    AND
        ...    Sleep    45 sec    reason=Time until reset will trigger    AND
        ...    Wait For Cells On Air
    END

Check MCC And Upload SCF With MCC 404 On BTS And MCC 404 On ASIR
    Set ASIR SCF Path
    GNB Get Param Value    param_name=mcc
    Run Keyword If    ${GNB_Param} == 404 or ${GNB_Param} == 405 or ${GNB_Param} == 406
    ...    Log To Console    mcc ${GNB_Param} is correct, skipping BTS recomissioning
    ...    ELSE    Prepare Testline    bts_scf_file=${CURDIR}/../scfs/${SCF_PATH}/25R3_MCC_404_MRBTS.xml
    ...    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_404_ASIR.xml
    ...    flag=${False}

Check If AllowASiLocalUserDefaultPassword Is Set To False And MCC Is Set To 404
    ${isMatching1}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:SECPRM
    ...    dn_param=allowASiLocalUserDefaultPassword
    ...    param_value=false
    ${isMatching2}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:BTS
    ...    dn_param=mcc
    ...    param_value=404
    IF    ${isMatching1} == True and ${isMatching2} == True
        ${comissioning_required}    Set Variable    ${False}
    ELSE
        ${comissioning_required}    Set Variable    ${True}
    END
    IF    ${comissioning_required} == True
        Run Keywords
        ...    Set ASIR SCF Path    AND
        ...    ASIR Commissioning    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_404_ASIR.xml    AND
        ...    Sleep    45 sec    reason=Time until reset will trigger    AND
        ...    Wait For Cells On Air
    END

Check If MCC Is Set To 404 With Wrong ITSAR Params
    ${isMatching}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:BTS
    ...    dn_param=mcc
    ...    param_value=404
    Run Keyword If    ${isMatching} == True    ASIR Perform Recomissioning    delta=${wrong_itsar_params}
    ...    delta_file_name=ASIR_delta.xml
    ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}

Check If WebEMSessionLogoutTimer Is Set to 120 Seconds
    Set Test Variable  ${isCreated}  ${None}
    TRY
        ${isMatching}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
        ...    file_name=ASIR_FULLSCF.xml
        ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
        ...    class_name=com.nokia.asi:SECPRM
        ...    dn_param=webEMSessionLogoutTimer
        ...    param_value=120
        Set Test Variable    ${isCreated}    ${True}
    EXCEPT    ValueError: webEMSessionLogoutTimer not found in given parameters
        Set Test Variable    ${isCreated}    ${False}
        Set Test Variable    ${isMatching}    ${False}
    END
    IF    "${isCreated}" == "True" and "${isMatching}" == "False"
        ASIR Perform Recomissioning    delta=${webEMSessionLogoutTimer_update}
        ...    delta_file_name=ASIR_delta.xml
        ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    ELSE IF    "${isCreated}" == "False"
        ASIR Perform Recomissioning    delta=${webEMSessionLogoutTimer_create}
        ...    delta_file_name=ASIR_delta.xml
        ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    END

Check MCC And Upload SCF With MCC 1 On BTS And MCC 1 On ASIR
    Set ASIR SCF Path
    GNB Get Param Value    param_name=mcc
    Run Keyword If    ${GNB_Param} == 1 or ${GNB_Param} == 244
    ...    Log To Console    MCC ${GNB_Param} is correct, skipping recomissioning
    ...    ELSE    Prepare Testline    bts_scf_file=${CURDIR}/../scfs/${SCF_PATH}/25R3_MCC_1_MRBTS.xml
    ...    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_1_ASIR.xml
    ...    flag=${False}

Check If WebEMSessionLogoutTimer Is Successfully Set On India Deployment
    IF    "${ASIR_Recomissioning_Output}" != "PASS"
        Fail    Error during validation
    ELSE
        Log To Console    Parameter webEMSessionLogoutTimer successfully set and activated on India deployment!
    END

Check If Parameter Is Successfully Set On Non-India Deployment
    [Arguments]    ${param}
    IF    "${ASIR_Recomissioning_Output}" != "PASS"
        Fail    Error during validation
    ELSE
        Log To Console    Parameter(s) ${param} successfully set and activated on non-India deployment!
    END

Check If MCC Is Set To 1 And Perform ASIR Commissioning
    ${isMatching}    Verify If Parameter Is Set To Proper Value    local_dir_path=${OUTPUT_DIR}/${TEST_NAME}
    ...    file_name=ASIR_FULLSCF.xml
    ...    scf_file_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_FULLSCF.xml
    ...    class_name=com.nokia.asi:BTS
    ...    dn_param=mcc
    ...    param_value=1
    IF    ${isMatching} != True
        Run Keywords
        ...    Set ASIR SCF Path    AND
        ...    ASIR Commissioning    scf_path=${CURDIR}/../scfs/${SCF_PATH}/${ASIR_SCF_PATH}_MCC_1_ASIR.xml    AND
        ...    Sleep    45 sec    reason=Time until reset will trigger    AND
        ...    Wait For Cells On Air
    END

Set ASIR SCF Path
    Check SW Version
    Check Release
    IF    "${RELEASE}" != "SBTS00"
        ${release_string}    Remove String    ${RELEASE}    SBTS
        ${ASIR_RELEASE}    Set Variable    ${release_string}
        Set Suite Variable    ${ASIR_RELEASE}
        ${ASIR_SCF_PATH}=    Set Variable    ${ASIR_RELEASE}
    ELSE IF    "${RELEASE}" == "SBTS00"
        ${ASIR_SCF_PATH}=    Set Variable    TRUNK
    END
    Set Suite Variable    ${ASIR_SCF_PATH}

Verify If SW Is Applicable For Yaft
    IF    "${FIRST_SW}" != "${CURRENT_SW}"
        Set Suite Variable    ${CURRENT_SW}    ${FIRST_SW}
    END
    IF    "${RELEASE}" == "${None}"
        Check Release
    END
    ${Verification_Result}    Evaluate    re.match(r"^SBTS2[5-6]R[1-2]$", "${RELEASE}") is not None
    IF    "${Verification_Result}" != "False" or "${RELEASE}" == "SBTS25R3"
        ${Can_Be_Yafted}    Set Variable    ${True}
    ELSE
        ${Can_Be_Yafted}    Set Variable    ${False}
    END
    Set Suite Variable    ${Can_Be_Yafted}
