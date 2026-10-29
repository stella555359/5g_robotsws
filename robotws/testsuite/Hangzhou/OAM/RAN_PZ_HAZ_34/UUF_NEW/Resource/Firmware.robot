*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Variables ***
@{uboot_scripts}   prepare-firmware.sh   prepare-firmware-manager.sh   prepare-firmware-common.sh   prepare-firmware-core-manager.sh


*** Keywords ***
UUF Downgrade Firmware
    [Arguments]   ${downgrade_sequence}=${UPGRADE_SEQUENCE}
    Log To Console   //TODO: UUF Downgrade Firmware
    ${firmware_result_success}   UUF Check Downgrade Firmware Result
    Return From Keyword If   ${firmware_result_success} and "${TESTLINE_IDENTITY}" not in ${DOWNGRADE_FIRMWARE_REPEAT_TL}

    ${scripts_exist}   Set Variable   ${True}
    FOR   ${script}   IN   @{uboot_scripts}
        ${script_exist}   Run Keyword And Return Status   File Should Exist   ${UBOOT_SCRIPTS_DIR}/${script}
        Exit For Loop If   not ${script_exist}
    END
    Return From Keyword If   not ${script_exist}

    &{needResetDict}   Create Dictionary
    FOR   ${testline}   IN   @{downgrade_sequence}
        ${needReset}   Single Testline Downgrade Firmware   testline=${testline}
        Set To Dictionary   ${needResetDict}   ${testline}=${needReset}
    END

    FOR   ${testline}   IN   @{downgrade_sequence}
        Continue For Loop If   not ${needResetDict["${testline}"]}
        ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
        ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
        ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
        COAM Login
        ...   bts_host=${webem_addr}
        ...   username=${webem_username}
        ...   password=${webem_password}
        ...   alias=${testline}
        Log To Console   Reset Site: ${testline}
        COAM Reset Site   wait_for_reconnection=${False}   connection=${testline}
    END

    Sleep   30s
    ${all_downgrade_status}   Set Variable   ${True}
    FOR   ${testline}   IN   @{downgrade_sequence}
        Continue For Loop If   not ${needResetDict["${testline}"]}
        UUF Wait Times For Cell OnAir   testline=${testline}
        ${single_downgrade_status}   Single Testline Check Firmware   testline=${testline}
        ${all_downgrade_status}   Evaluate   ${all_downgrade_status} and ${single_downgrade_status}
    END

    IF   ${all_downgrade_status}
        Log To Console   Downgrade Firmware Success.
        UUF Save Downgrade Firmware Result
    ELSE IF   not ${all_downgrade_status}
        Log To Console   [ERROR] Downgrade Firmware ERROR.
    END

    [Teardown]   Run Keyword And Ignore Error   COAM Logout ALL Testline   testline_list=${downgrade_sequence}


Single Testline Downgrade Firmware
    [Arguments]   ${testline}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}
    ${primary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_host']}
    ${secondary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_host']}


    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    ${PrimaryReset}   Update Fimrware Shell   connection=${testline}

    Return From Keyword If   not ${isDualCore}   ${PrimaryReset}

    # Secondary Core
    Run Keyword If   ${isDualCore}
    ...   csn.Connect to  hostname=${secondary_host}  username=${ssh_username}  password=${ssh_password}  proxy=${testline}  alias=${testline}_dual
    ${SecondaryReset}   Update Fimrware Shell   connection=${testline}_dual

    ${needReset}   Evaluate   ${PrimaryReset} or ${SecondaryReset}
    Return From Keyword   ${needReset}

    [Return]   ${False}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${testline}_dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}


Update Fimrware Shell
    [Arguments]   ${connection}
    FOR   ${script}   IN   @{uboot_scripts}
        csn.Upload File
        ...   local_path=${UBOOT_SCRIPTS_DIR}/${script}
        ...   remote_path=/ffs/run/${script}
        ...   connection=${connection}
    END
    csn.Execute   command=chmod +x /ffs/run/prepare-firmware*   connection=${connection}
    csn.Execute   command=rm /user/toor4nsn/.ssh/known_hosts   connection=${connection}
    ${downgrade_status}   csn.Execute   command=/ffs/run/prepare-firmware-core-manager.sh -p oZPS0POrRieRtu -v   connection=${connection}

    IF   "FW downgraded successfully" in $downgrade_status
        Return From Keyword   ${False}
    ELSE IF   "FW not downgraded" in $downgrade_status
        ${downgrade_result}   csn.Execute   /ffs/run/prepare-firmware-core-manager.sh -p oZPS0POrRieRtu -u   connection=${connection}
        IF   "Performed update at least on one core" in $downgrade_result
            Return From Keyword   ${True}
        ELSE IF   "downgrade/update failed on SoC" in $downgrade_result
            Log To Console   [ERROR] Uboot Downgrade Error
        ELSE
            Log To Console   [WARN] Unexpected status from uboot downgrade
        END
    ELSE
        Log To Console   [WARN] Unexpected status from uboot check
    END

    [Return]   ${False}


Single Testline Check Firmware
    [Arguments]   ${testline}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}
    ${primary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_host']}
    ${secondary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_host']}


    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    ${primary_status}   Check Firmware Shell   connection=${testline}

    Return From Keyword If   not ${isDualCore}   ${primary_status}

    # Secondary Core
    Run Keyword If   ${isDualCore}
    ...   csn.Connect to  hostname=${secondary_host}  username=${ssh_username}  password=${ssh_password}  proxy=${testline}  alias=${testline}_dual
    ${secondary_status}   Check Firmware Shell   connection=${testline}_dual

    ${downgrade_status}   Evaluate   ${primary_status} or ${secondary_status}
    Return From Keyword   ${downgrade_status}

    [Return]   ${False}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${testline}_dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}


Check Firmware Shell
    [Arguments]   ${connection}
    FOR   ${script}   IN   @{uboot_scripts}
        csn.Upload File
        ...   local_path=${UBOOT_SCRIPTS_DIR}/${script}
        ...   remote_path=/ffs/run/${script}
        ...   connection=${connection}
    END
    csn.Execute   command=chmod +x /ffs/run/prepare-firmware*   connection=${connection}
    csn.Execute   command=rm /user/toor4nsn/.ssh/known_hosts   connection=${connection}
    ${downgrade_status}   csn.Execute   command=/ffs/run/prepare-firmware-core-manager.sh -p oZPS0POrRieRtu -v   connection=${connection}

    IF   "FW downgraded successfully" in $downgrade_status
        Return From Keyword   ${True}
    ELSE
        Return From Keyword   ${False}
    END


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
Download UBOOT Scripts
    Log To Console   Download Golden SCF Project...
    ${scf_link}   Set Variable   git@gitlabe1.ext.net.nokia.com:swmgmt_team/prepare-bts-firmware-before-tests.git
    ${UBOOT_SCRIPTS_DIR}   OperatingSystem.Join Path   ${OUTPUT_DIR}   ..   prepare-bts-firmware-before-tests
    Set Suite Variable   ${UBOOT_SCRIPTS_DIR}

    ${uboot_scripts_dir_not_empty}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Be Empty   path=${UBOOT_SCRIPTS_DIR}
    Run Keyword If   ${uboot_scripts_dir_not_empty}   Log To Console   UBOOT Scripts Project Exist, Skip Downloading.
    Return From Keyword If   ${uboot_scripts_dir_not_empty} and "${SUITE_NAME}"!="UUF_Precheck"

    OperatingSystem.Run    sudo rm -rf ${UBOOT_SCRIPTS_DIR}
    ${output}    OperatingSystem.Run   git clone --depth 1 ${scf_link} ${UBOOT_SCRIPTS_DIR} --progress --verbose
    Should Contain   ${output}   Receiving objects: 100%
    # Should Contain   ${output}   Resolving deltas: 100%
    Log To Console   Download UBOOT Scripts Project Finished.


UUF Save Downgrade Firmware Result
    ${FIRMWARE_RESULT_PATH}   OperatingSystem.Join Path   ${OUTPUT_DIR}   ..   FIRMWARE_RESULT.json
    ${file_not_exist}   Run Keyword And Return Status   OperatingSystem.File Should Not Exist   ${FIRMWARE_RESULT_PATH}
    Run Keyword If   ${file_not_exist}   OperatingSystem.Create File   ${FIRMWARE_RESULT_PATH}   success


UUF Check Downgrade Firmware Result
    ${FIRMWARE_RESULT_PATH}   OperatingSystem.Join Path   ${OUTPUT_DIR}   ..   FIRMWARE_RESULT.json
    ${file_exist}   Run Keyword And Return Status   OperatingSystem.File Should Exist   ${FIRMWARE_RESULT_PATH}
    [Return]   ${file_exist}
