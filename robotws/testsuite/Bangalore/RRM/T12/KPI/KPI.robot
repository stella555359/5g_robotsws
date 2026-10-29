*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 KPI Script.

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
Library     Process

Library         ${CURDIR}/../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../resources/Keywords/common_keywords.robot
#Resource        ${CURDIR}/../Upgrade/gNBupgrade.robot
Resource        ${CURDIR}/KPI_RJIO_realUE.robot

Suite Setup       Updated Suite Setup

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
${KPI_RUN1}   RUN1
${KPI_RUN2}   RUN2
${lua_file}   commands.lua
${cfg_filename}    rjio_latestmod_singlecell_tm.lua entry=run_configuration
${TOPOLOGY}             CLOUD_5G_O_E_AP_LOO

*** Test cases ***
[1][1.0] KPI tests on HybridTL
    [Documentation]      This Script does KPI run on latest builds.
        Start Btslogs from Local machine      ${BTSLOG}
        gNB upgrade   ${gNB_SWBuild1}
        AP upgrade    ${AP_build}
        Sleep   60s
        Log to Console       CONNECTING REAL UEs...
        Connect calls on realUE
        Log to Console       "\n KPIRUN1 STARTING MUE script"
        Trigger MUE script in Airphone    ${KPI_RUN1}
        Sleep    12800s
        Log to Console       "\n KPIRUN1 MUE script completed"
        Check throughput for realUE
        Copy PM Files from gNB   ${LOG_DIR}/KPI/${KPI_RUN1}
        Snapshot Collection     ${LOG_DIR}     Snapshot_AE_run1.zip
        gNB upgrade   ${gNB_SWBuild2}
        Sleep   60s
        Connect calls on realUE
        Log to Console       "\n KPIRUN2 STARTING MUE script"
        Trigger MUE script in Airphone    ${KPI_RUN2}
        Sleep    12800s
        Log to Console       "\n KPIRUN2 MUE script completed"
        Copy PM Files from gNB   ${LOG_DIR}/KPI/${KPI_RUN2}
        Snapshot Collection     ${LOG_DIR}     Snapshot_AE_run2.zip
        Start Btslogs from Local machine      ${BTSLOG}

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

#    OperatingSystem.Run    sudo wget ${WFT_link}/${gNB_SWBuild}/${gNB_SWBuild}_release_BTSSM_downloadable_A54.zip \
#    ...    --user=${usr} --password=${PW} -P ${SW_PATH}
    admin.setup admin
    admin.Update Software    sw_package=${SW_PATH}/${gNB_SWBuild}_release_BTSSM_downloadable_A54.zip    timeout=1500
    Wait Until Keyword Succeeds    500sec    30sec    Verify Coam BTS Is Configured
    admin.teardown admin
    Log to Console     gNB upgrade is completed

Upgrade GNB software
    [Documentation]       This keyword downloads and upgrade GNB SW
    [Arguments]         ${gNB_SWBuild}
    ${Current_SWBuild}=    Convert to String    ${gNB_SWBuild}
    IF    "${fullSWactive}" == "${new_sw_build}"
        Log to Console     Setup is already at Latest Build, skipping Upgrade
    ELSE IF    "${fullSWpassive}" == "${new_sw_build}"
        RollbackSW
    ELSE
         Download GNB softwarebuild and Upgrade    ${WFT_link}    ${gNB_SWBuild}
    END

Compare SW Build
    [Arguments]         ${gNB_SWBuild}
    [Documentation]       This keyword checks if the SW build is trunk or not
    ${sw_parts}    Split String    ${gNB_SWBuild}    _
    ${first_part}    Get From List    ${sw_parts}    0
    Should Be Equal As Strings    ${first_part}    ${SBTS}
    ${new_sw_build}    Replace String    ${gNB_SWBuild}    ${SBTS}    ${trunk}
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
    OperatingSystem.Run    airphone-install install --ap_build ${AP_build}
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
    ${install1}=    OperatingSystem.Run    ls ${AP_logfile}
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
    [Arguments]         ${gNB_SWBuild}
    Log to Console       \nstarting gNB upgrade......
    ${LOG_PATH}     Create Log Directory       gNBupgrade
    Set Test Variable        ${LOG_PATH}
    Backup of SCF and SWconfig     ${LOG_PATH}    ${scf_backup_name}
    Compare SW Build   ${gNB_SWBuild}
    GetSWversion
    Upgrade GNB software   ${gNB_SWBuild}

Trigger MUE script in Airphone
    [Arguments]         ${KPI_RUN}
    ${LOG_PATH}     Create Log Directory       KPI/${KPI_RUN}
    Set Test Variable        ${LOG_PATH}
    Create Basic Interface On UTE
#    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_Feature_Enable.json
#    Add RD Parameters Directly On GNB     ${rad_parameter}
    Sleep   10s
#    GNB Reboot
#    Sleep   600s
    Wait Coam Site To Be Ready
    Start UTE WTS with lua      ${cfg_filename}
    Sleep    600s
    Basic Bring Up for rjio
    Pass Lua File_cell1      ${lua_file}

Pass Lua File_cell1
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}   entry=RJIO4
    Sleep    120s

Basic Bring Up for rjio
    [Documentation]       This keyword is for basic Ng and AP cell setup
    NG Link Should Be UP
    Sleep   60s

Copy PM Files from gNB
    [Arguments]    ${PM_dir}
    OperatingSystem.Run    sshpass -p ${GNB_PASSWORD} scp ${GNB_USERNAME}@${GNB_IP}:/tmp/PM* ${PM_dir}/
    Log    SCP copy completed successfully.

