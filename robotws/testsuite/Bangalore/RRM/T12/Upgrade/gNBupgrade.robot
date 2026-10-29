*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 This Script does both gNB and AP upgrade.

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     ta5g_iphy
Library     ute_fsmaccess
Library     taf.wts.runner

Library         ${CURDIR}/../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../resources/Keywords/common_keywords.robot

*** Variables ***
${GNB_IP}=          192.168.255.129
${GNB_USERNAME}=          toor4nsn
${GNB_PASSWORD}=     oZPS0POrRieRtu
${LOG_DIR}              /home/ute/logs
${scf_backup_name}      BFR_UPG_BKP_SCF
${WFT_link}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/SBTS00
${usr}=    dheerajn
${PW}=    AP33ZXKC1P9cgS4SsiuoeE23c8C
${trunk}    SBTS26R1
${SBTS}    SBTS00
${AP_logfile}   /home/ute/ap_install_log/*.log
${AP_FLASH_pattern}    Flashing done
${APiphy}    /home/ute/ap_upgrade_backup
${IPHY_FILE_PATH}      /home/ute/ap_upgrade_backup
${IPHY_DIRPATH}        /rom/simmode/
${IPHY_FILE_NAME}      iphy.xml

*** Test cases ***
[1][1.0] Upgrade gNB and AP
    [Documentation]      This Script does upgrade of gNB and AP.
    IF   "${gNB_Upgrade_Flag}" == "YES" and "${AP_Upgrade_Flag}" == "YES"
        gNB upgrade
        AP upgrade    ${AP_build}
        Log to Console       \ngNB is upgraded to ${gNB_SWBuild} and AP upgraded to ${AP_build} successfully...
    ELSE IF    "${gNB_Upgrade_Flag}" == "YES" and "${AP_Upgrade_Flag}" == "NO"
        gNB upgrade
        Log to Console       \ngNB is upgraded to ${gNB_SWBuild} successfully...
    ELSE IF    "${gNB_Upgrade_Flag}" == "NO" and "${AP_Upgrade_Flag}" == "YES"
        AP upgrade    ${AP_build}
        Log to Console       \nAP upgraded to ${AP_build} successfully...
    END

*** Keywords ***
Backup of SCF and SWconfig
    [Documentation]       This keyword takes backup of gNB SCF and swconfig
    [Arguments]         ${LOG_PATH}    ${scf_backup_name}
    Backup Scf    ${LOG_PATH}    ${scf_backup_name}
    Get Swconfig File From GNB    ${LOG_PATH}

Download GNB softwarebuild and Upgrade
    [Documentation]       This keyword downloads and upgrade GNB SW
    [Arguments]         ${WFT_link}    ${gNB_SWBuild}
    ${SW_PATH}     Create Log Directory       Builds
    OperatingSystem.Run
    ...    sudo wget ${WFT_link}/${gNB_SWBuild}/${gNB_SWBuild}_release_BTSSM_downloadable_A54.zip --user=${usr} --password=${PW} -P ${SW_PATH}
    admin.setup admin
    admin.Update Software    sw_package=${SW_PATH}/${gNB_SWBuild}_release_BTSSM_downloadable_A54.zip    timeout=1500
    Wait Until Keyword Succeeds    500sec    30sec    Verify Coam BTS Is Configured
    admin.teardown admin
    Log to Console     gNB upgrade is completed

Upgrade GNB software
    [Documentation]       This keyword downloads and upgrade GNB SW
    ${Current_SWBuild}=    Convert to String    ${gNB_SWBuild}
    IF    "${fullSWactive}" == "${new_sw_build}"
        Log to Console     Setup is already at Latest Build, skipping Upgrade
    ELSE IF    "${fullSWpassive}" == "${new_sw_build}"
        RollbackSW
    ELSE
         Download GNB softwarebuild and Upgrade    ${WFT_link}    ${gNB_SWBuild}
    END

Compare SW Build
    [Documentation]       This keyword checks if the SW build is trunk or not
    ${sw_parts}    Split String    ${gNB_SWbuild}    _
    ${first_part}    Get From List    ${sw_parts}    0
    Should Be Equal As Strings    ${first_part}    ${SBTS}
    ${new_sw_build}    Replace String    ${gNB_SWbuild}    ${SBTS}    ${trunk}
    Log to Console       ${new_sw_build}
    Set Global Variable    ${new_sw_build}
    [RETURN]    ${new_sw_build}

GetSWversion
    [Documentation]    Get Software information from BTS in both partition
    admin.Setup Admin
    ${SOFTWARE_VERSIONS}=    admin.get_software_info    timeout=300    connection=none
    ${fullSWactive}=    Convert to String    ${SOFTWARE_VERSIONS['Active SW version']}
    ${fullSWpassive}=    Convert to String    ${SOFTWARE_VERSIONS['Passive SW version']}
    [Teardown]    admin.Teardown Admin
    Set Global Variable    ${fullSWactive}
    Set Global Variable    ${fullSWpassive}
    [RETURN]    ${fullSWactive}   ${fullSWpassive}

RollbackSW
    [Documentation]    This keyword does software rollback
    admin.setup admin
    admin.rollback_software    timeout=500    detailed_output=True
    Sleep    600s
    Wait Until Keyword Succeeds    500sec    30sec    Verify Coam BTS Is Configured
    admin.teardown admin

AP upgrade
    [Documentation]    This keyword does AP software install
    [Arguments]         ${AP_build}
    Log to Console       \nstarting AP upgrade......
    OperatingSystem.Run     airphone-install install --ap_build ${AP_build}
    Log to Console       \nstarted AP_upgrade
    Sleep    600s
    Check AP flashing done    ${AP_logfile}
    Update And Put Iphy Xml             ${IPHY_FILE_PATH}/iphy.xml
    Sleep    60s
    GNB Reboot
    Sleep   360s
    admin.setup admin
    Wait Until Keyword Succeeds    500sec    30sec    Verify Coam BTS Is Configured
    admin.teardown admin

Check AP flashing done
    [Documentation]    This keyword checks if AP is yafted successfully
    [Arguments]    ${AP_logfile}
    ${install1}=    OperatingSystem.Run   ls ${AP_logfile}
    Log to Console    ${install1}
    ${install}=    OperatingSystem.Get File    ${install1}
    ${is_present}=    Run Keyword And Return Status    Should Contain    ${install}    ${AP_FLASH_pattern}
    IF    ${is_present}
        Log to Console    Pattern found: ${AP_FLASH_pattern}
    ELSE
        AP upgrade    ${AP_build}
    END

gNB upgrade
    [Documentation]    This keyword does gNB software upgrade
    Log to Console       \nstarting gNB upgrade......
    ${LOG_PATH}     Create Log Directory       gNBupgrade
    Set Test Variable        ${LOG_PATH}
    Backup of SCF and SWconfig     ${LOG_PATH}    ${scf_backup_name}
    Compare SW Build
    GetSWversion
    Upgrade GNB software
