*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 KPI Script.

Library     BuiltIn
Library     DateTime
Library     Collections
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     ute_fsmaccess
Library     ta5g_iphy
Library     taf.wts.runner
Library     Process
Library     ta5g_pm_counters
Library    ${CURDIR}/resources/parse_kpi_json.py
Library    ${CURDIR}/resources/email_script.py
Library         ${CURDIR}/../../../../T12/resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../../T12/resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../../T12/resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/common_keywords.robot
#Resource        ${CURDIR}/../Upgrade/gNBupgrade.robot
#Resource        ${CURDIR}/KPI_RJIO_realUE.robot
Resource         ${CURDIR}/resources/scout_wrapper_keywords.robot
Suite Setup       Updated Suite Setup

*** Variables ***
${GNB_IP}=          192.168.255.129
${GNB_USERNAME}=          toor4nsn
${GNB_PASSWORD}=     oZPS0POrRieRtu
${LOG_DIR}              /home/ute/logs
${scf_backup_name}      BFR_UPG_BKP_SCF
${WFT_link}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/SBTS00
#${usr}=    dheerajn
#${PW}=    AP33ZXKC1P9cgS4SsiuoeE23c8C
${usr}=   app1
${PW}=    PA_P0qwe2024#77
${trunk}    SBTS26R2
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
${cfg_filename}    rjio_latestmod_singlecell_tm1.lua entry=run_configuration
${TOPOLOGY}             CLOUD_5G_O_E_AP_LOO
${timeout}    120
${BTSLOG}      btslog
#${TEMPLATE_ID}          1962

*** Test cases ***
[1][1.0] KPI tests
    [Documentation]      This Script does KPI run on latest builds.
    [Setup]    Copy Directory Contents To Opt Iphy Latest    ${CONFIG_DIR}
        Update BSR Package For RJIO
        Sleep    60s
        Configure Scout API    ${api_key}
        Enable Kpi Pm Collection
        ${hostname}    Get Hostname With Underscore
        ${gNB_SWBuild1}    scout.get_active_sw    alias=scoutalias
        Start Btslogs from Local machine      ${BTSLOG}
        ${RUN1_START_TIME_DRAFT}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
        ${RUN1_START_TIME}    ${wait_ms}    Round Time To Next 15 Min With Wait    ${RUN1_START_TIME_DRAFT}
        Sleep    ${wait_ms} milliseconds
        Trigger MUE script in Airphone    ${KPI_RUN1}
        Log to Console    "\n KPIRUN1 MUE script completed"
        ${RUN1_END_TIME_DRAFT}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
        ${RUN1_END_TIME}    ${wait_ms}    Round Time To Next 15 Min With Wait    ${RUN1_END_TIME_DRAFT}
        Sleep    ${wait_ms} milliseconds
        Copy PM Files from gNB    ${LOG_DIR}/KPI/${KPI_RUN1}
        Snapshot Collection    ${LOG_DIR}    Snapshot_AE_run1.zip
        Teardown Edaemon And Egate process
        Log To Console    "\n Logcollection completed for run1"

        gNB upgrade    ${gNB_SWBuild2}
        GNB Reboot
        Sleep    300s
        Wait Coam Site to Be Ready
        ${RUN2_START_TIME_DRAFT}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
        ${RUN2_START_TIME}    ${wait_ms}    Round Time To Next 15 Min With Wait    ${RUN2_START_TIME_DRAFT}
        Sleep    ${wait_ms} milliseconds
        Log To Console    "\n KPIRUN2 started"
        Trigger MUE script in Airphone    ${KPI_RUN2}
        Log To Console    "\n KPIRUN2 MUE script completed"
        ${RUN2_END_TIME_DRAFT}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
        ${RUN2_END_TIME}    ${wait_ms}    Round Time To Next 15 Min With Wait    ${RUN2_END_TIME_DRAFT}
   	    Sleep    ${wait_ms} milliseconds
        Copy PM Files from gNB   ${LOG_DIR}/KPI/${KPI_RUN2}
        Snapshot Collection    ${LOG_DIR}    Snapshot_AE_run2.zip
        Teardown Edaemon And Egate process
        Log To Console    "\n Logcollection completed for run2"
        Sleep    1200s
        ${KPI_REPORT1}=  Generate Scout Kpi Report   kpi_report1.json     ${TEMPLATE_ID}  ${RUN1_START_TIME}  ${RUN1_END_TIME}
        ${KPI_REPORT2}=  Generate Scout Kpi Report   kpi_report2.json     ${TEMPLATE_ID}  ${RUN2_START_TIME}  ${RUN2_END_TIME}
        Sleep    60s
        ${RESULT}    ${TOP_5_LIST}    ${Report1_id}    ${Report2_id} =    compare_kpi_trend    kpi_report1.json
        ...    kpi_report2.json    ${gNB_SWBuild1}    ${gNB_SWBuild2}
        Teardown Scout Connection

        ${files} =    Create List    kpi_comparison_report1.xlsx
        ${mail_config} =     Create Dictionary
        ...    source_build=${gNB_SWBuild1}
        ...    target_build=${gNB_SWBuild2}
        ...    recipients=${recipients_list}
        ...    hostname=${hostname}
        ...    top_kpis=${TOP_5_LIST}
        ...    template_id=${TEMPLATE_ID}
        ...    report1_id=${Report1_id}
        ...    report2_id=${Report2_id}
        send_email_with_attachments    ${files}    ${mail_config}

*** Keywords ***
Round Time To Next 15 Min With Wait
    [Arguments]    ${timestamp}
    ${dt}=    Evaluate    datetime.datetime.strptime($timestamp,"%Y-%m-%dT%H:%M:%S.%fZ")    modules=datetime
    ${minutes_total}=    Evaluate    $dt.hour * 60 + $dt.minute
    ${seconds_total}=    Evaluate    $minutes_total * 60 + $dt.second
    ${microseconds_total}=    Evaluate    ${seconds_total} * 1000000 + $dt.microsecond
    ${interval_microseconds}=    Evaluate    15 * 60 * 1000000
    ${remainder}=    Evaluate    ${microseconds_total} % ${interval_microseconds}
    ${add_microseconds}=    Evaluate    0 if ${remainder} == 0 else ${interval_microseconds} - ${remainder}
    ${add_minutes}=    Evaluate    ${add_microseconds} // (60 * 1000000)
    ${add_seconds}=    Evaluate    (${add_microseconds} % (60 * 1000000)) // 1000000
    ${add_micro}=    Evaluate    ${add_microseconds} % 1000000
    ${dt2}=    Evaluate    $dt + datetime.timedelta(minutes=${add_minutes}, seconds=${add_seconds}, microseconds=${add_micro})    modules=datetime
    ${rounded}=    Evaluate    $dt2.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    ${wait_ms}=    Evaluate    int(($dt2 - $dt).total_seconds() * 1000)
    RETURN    ${rounded}    ${wait_ms}

Start Btslogs From Local Machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    [Arguments]    ${log_alias}
    btslog.create_btslog_collector    ${log_alias}
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias}
    core.Set Suite Alias    ${log_alias}

Backup of SCF and SWconfig
    [Documentation]       This keyword takes backup of gNB SCF and swconfig
    [Arguments]         ${LOG_PATH}    ${scf_backup_name}
    Backup Scf    ${LOG_PATH}    ${scf_backup_name}
    Get Swconfig File From GNB    ${LOG_PATH}

Create Log Directory for RJIO Script
    [Documentation]    Create Log Directory
    [Arguments]     ${Test_CaseNumber}
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${LOG_PATH}     Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    Set Test Variable       ${LOG_PATH}
    [Return]    ${LOG_PATH}

Download GNB softwarebuild and Upgrade
    [Documentation]       This keyword downloads and upgrade GNB SW
    [Arguments]         ${WFT_link}    ${gNB_SWBuild}
    ${SW_PATH}     Create Log Directory for RJIO Script       Builds
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
#    Wait Coam Site To Be Ready
    Start UTE WTS with lua      ${cfg_filename}
    Sleep    200s
    Basic Bring Up for rjio
    Pass Lua File_cell1      ${lua_file}

Pass Lua File_cell1
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}   entry=RJIO7()
    Sleep    3150s

Basic Bring Up for rjio
    [Documentation]       This keyword is for basic Ng and AP cell setup
    NG Link Should Be UP
    Sleep   60s

Copy PM Files from gNB
    [Arguments]    ${PM_dir}
    OperatingSystem.Run    sshpass -p ${GNB_PASSWORD} scp ${GNB_USERNAME}@${GNB_IP}:/tmp/PM* ${PM_dir}/
    Log    SCP copy completed successfully.

Copy Directory Contents To Opt Iphy Latest
    [Arguments]    ${source_dir}
    ${source}=    Convert To String    ${source_dir}
    ${dest}=       Set Variable    /opt/iphy/latest
    ${cmd}=        Set Variable    sudo cp -vR ${source}/* ${dest}/
    Log    Executing: ${cmd}
    ${result}=    Run Process    ${cmd}    shell=True
    Log    Return code: ${result.rc}
    Log    stdout: ${result.stdout}
    Log    stderr: ${result.stderr}
    Run Keyword If    ${result.rc} != 0    Fail    Copy failed with exit code ${result.rc}
