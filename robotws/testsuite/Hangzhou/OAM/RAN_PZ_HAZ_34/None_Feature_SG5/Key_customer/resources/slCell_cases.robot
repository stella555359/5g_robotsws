*** Settings ***
Documentation     author: annie.hu
...               Group: HGZ_SG5
...               contact: annie.hu@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource          ./slCell_keywords.robot

*** Variables ***
@{Cells_to_Test}                 ${1}   ${2}   ${3}
@{RUs_to_Test}                   ${1}   ${2}   ${3}
@{BBUs_to_Test}                  ${1}

${SW_build_path}                  /home/ute/Downloads
${InputPackage}                   SBTS00_ENB_9999_230918_000003
#${SBTS23R1_package_link}         https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS23R1_packages/
#${SBTS23R2_package_link}         https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS23R2_packages/
#${SBTS00_package_link}           https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages/
#${package_link}                  https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/
${package_link}                   https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/

${Cellid_l3call}                  ${1}
${nr_block_or_unblock_time}       60    #Seconds  #CFAM: 20s ?
${nr_lock_or_unlock_time}         60    #Seconds
${RU_reset_downtime_duration}     360   #Seconds
${BBU_reset_downtime_duration}    600   #Seconds
${Site_reset_downtime_duration}   600   #Seconds
${SW_update_downtime_duration}    3600  #Seconds  #N to N
${SW_upgrade_downtime_duration}   3600  #Seconds  #N to N+x or N-x
@{swconfig_list_HWF}              0x190030=0    0x4F0214=0
#@{swconfig_list_HWF}             ${EMPTY}     #0x190030=0 (BRANCH) or 0x4F0214=0 (TRUNK)

*** Keywords ***
slCell_Cell_Block_Unblock
    [Arguments]  ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${alias}=ASIK Master    ${test_phase}=${EMPTY}
    #uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    #uuf_rfrl_common_keywords.Get Iteration Start Time
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}
    ${cell_list}    Get All Cell Id
    ${cellNum}    BuiltIn.Get Length    ${cell_list}
    ${numOfCellsTest}    BuiltIn.Get Length    ${Cells_to_Test}
    Run Keyword If    '${gNB_type}'!='SA'    Get X2 link shutdown waiting time
    ${statu}  Run Keyword And Return Status   Run Keyword If  ${cellNum}==${1}
    ...    Block unblock single cell and check L3 with PCMD   block_list=${cell_list}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}    test_phase=${test_phase}
    ...    ELSE IF  ${cellNum}>${1} and '${numOfCellsTest}'!='${0}'
    ...    Block unblock cells and check L3 with PCMD   block_list=${Cells_to_Test}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}
    ...    ELSE    Log To Console   \nWarning: please double check which cell(s) to be blocked/unblocked
    Run Keyword If   not ${statu} and ${cellNum}==${1}   Run Keyword And Ignore Error    Unblock single cell and check
    ...    block_list=${cell_list}    gnb_type=${gNb_CuType}    check_alarm=${False}
    ...    ELSE IF   not ${statu} and ${cellNum}>${1} and '${numOfCellsTest}'!='${0}'   Run Keyword And Ignore Error
    ...    UnBlock Cells and check status   block_list=${Cells_to_Test}   check_alarm=${False}   gnb_type=${gNb_CuType}
    ...    ELSE    Log To Console    \nall cells are already in unblocked status
    Run Keyword And Continue On Failure    Should Be True    ${statu}
    #uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

slCell_Cell_Lock_Unlock
    [Arguments]  ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${alias}=ASIK Master
    #uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    #uuf_rfrl_common_keywords.Get Iteration Start Time
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}
    ${cell_list}    Get All Cell Id
    ${cellNum}    BuiltIn.Get Length    ${cell_list}
    ${numOfCellsTest}    BuiltIn.Get Length    ${Cells_to_Test}
    Run Keyword If    '${gNB_type}'!='SA'    Get X2 link shutdown waiting time
    ${statu}  Run Keyword And Return Status   Run Keyword If  ${cellNum}==${1}
    ...    Lock unlock single cell and check L3 with PCMD   lock_list=${cell_list}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}
    ...    ELSE IF  ${cellNum}>${1} and '${numOfCellsTest}'!='${0}'
    ...    Lock unlock cells and check L3 with PCMD   lock_list=${Cells_to_Test}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}
    ...    ELSE    Log To Console   \nWarning: please double check which cell(s) to be locked/unlocked
    Run Keyword If   not ${statu} and ${cellNum}==${1}   Run Keyword And Ignore Error    Unlock single cell and check
    ...    unlock_list=${cell_list}    gnb_type=${gNb_CuType}    check_alarm=${False}
    ...    ELSE IF   not ${statu} and ${cellNum}>${1} and '${numOfCellsTest}'!='${0}'   Run Keyword And Ignore Error
    ...    Unlock cells or groups and check status   lock_list=${Cells_to_Test}   is_group=${False}   check_alarm=${False}
    ...    gnb_type=${gNb_CuType}    connection=${connection}
    ...    ELSE    Log To Console    \nall cells are already in unlocked status
    Run Keyword And Continue On Failure    Should Be True    ${statu}
    #uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

slCell_RU_Reset
    [Arguments]  ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${alias}=ASIK Master    ${test_phase}=${EMPTY}
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    #uuf_rfrl_common_keywords.Get Iteration Start Time
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}
    ${ru_index_list}   Get All RU Index   connection=GNB_OAM
    ${ruNum}    BuiltIn.Get Length    ${ru_index_list}
    ${numOfRUsTest}    BuiltIn.Get Length    ${RUs_to_Test}
    Run Keyword If    '${gNB_type}'!='SA'    Get X2 link shutdown waiting time
    ${statu}  Run Keyword And Return Status   Run Keyword If  ${ruNum}==${1}
    ...    Reset single RU and check L3 with PCMD   ru_list=${ru_index_list}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}
    ...    ELSE IF  ${ruNum}>${1} and '${numOfRUsTest}'!='${0}'
    ...    Reset RUs and check L3 with PCMD   ru_list=${RUs_to_Test}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}
    ...    ELSE    Log To Console   \nWarning: please double check which RU(s) to be reset
    Run Keyword And Continue On Failure    Should Be True    ${statu}
    uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
    #Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

slCell_Capacity_Module_Reset
    [Arguments]  ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${alias}=ASIK Master    ${timeout}=600
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    uuf_rfrl_common_keywords.Get Iteration Start Time
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}
    Connect to gnb coam via ssl    connection=${connection}
    ${bbmod_index_list}    Get All BBmod Index    connection=${connection}
    ${bbuNum}    BuiltIn.Get Length    ${bbmod_index_list}
    ${numOfBBUsTest}    BuiltIn.Get Length    ${BBUs_to_Test}
    Run Keyword If    '${gNB_type}'!='SA'    Get X2 link shutdown waiting time
    ${statu}  Run Keyword And Return Status   Run Keyword If  ${bbuNum}==${1}
    ...    Reset single BBU and check L3 with PCMD   bbu_list=${bbmod_index_list}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}
    ...    ELSE IF  ${bbuNum}>${1} and '${numOfBBUsTest}'!='${0}'
    ...    Reset BBUs and check L3 with PCMD   bbu_list=${BBUs_to_Test}   gnb_type=${gNb_CuType}
    ...    with_pcmd=${False}
    ...    ELSE    Log To Console   \nWarning: please double check which BBU(s) to be reset
    Run Keyword And Continue On Failure    Should Be True    ${statu}
    uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

slCell_Delta_Commissioning_With_Site_Reset_Required
    [Arguments]  ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${alias}=ASIK Master
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}
    ${orig_value}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    filter_param=Time zone
    ${set_value}   Set Variable If   '${orig_value}'=='(GMT+8) Asia/Shanghai'   (GMT+8) Asia/Chongqing   (GMT+8) Asia/Shanghai
    ${statu}  Run Keyword And Return Status    Change parameters on webEM and check status
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1    filter_param=Time zone
    ...    abbr=timeZone    new_value=${set_value}    despite_ERR=${False}
    ...    gnb_type=${gNb_CuType}   with_pcmd=${False}
    Run Keyword And Continue On Failure    Should Be True    ${statu}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

slCell_Reset_with_HWF_deletion
    [Arguments]    ${gnb_type}=${gNb_CuType}    ${alias}=ASIK Master    ${timeout}=600   ${test_phase}=${EMPTY}
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    #uuf_rfrl_common_keywords.Get Iteration Start Time
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Set Test Variable    ${test_round}    1
    #${swconfig_list_HWF}=   Create List   0x190030=0    0x4F0214=0
    FOR    ${count}    IN RANGE    1    ${test_round}+1
        Log To Console    \nstart HWF reset inner loop: ${count}
        Reset with HWF deletion for e2e    gnb_type=${gNb_CuType}    with_pcmd=${False}
    END
    uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

slCell_SW_upgrade_rollback
    [Arguments]  ${check_alarm}=${True}   ${check_historyalarm}=${True}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E   ${alias}=ASIK Master
    ...          ${with_call}=${True}    ${with_pcmd}=${False}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1    ${test_phase}=${EMPTY}
     Set Test Variable    ${CELL_DOWNTIME}    ${None}
     admin.Teardown All Aliases For Admin
     ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
     Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
     Selenium Login And Disable Screen Lock    version=${SBTS_verion}
     Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
     ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
     ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
     uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
     Log To Console    \nstart SW upgrade with ${InputPackage}
     ${target_version}=   Align SBTS stream for Trunk Build    InputPackage=${InputPackage}
     Set Test Variable     ${REPORT_SW}    ${target_version}
     ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
     Selenium Login And Disable Screen Lock    version=${SBTS_verion}
     ${ActVerB4Updt}   ${CurVers}   Wait Until Keyword Succeeds   1min   10s   check SW version for e2e   version_type=Active
     ${ActVerB4Updt}=   Align SBTS stream for Trunk Build    InputPackage=${ActVerB4Updt}
     Exit For Loop IF  '${target_version}'=='${EMPTY}' or '${target_version}'=='default' or '${target_version}'=='${ActVerB4Updt}'
     ${full_link}    Get Download Link From Target Version    InputVersion=${target_version}
     ${upgrade_package_path}=   Download SW Build to UTE VM    package_full_link=${full_link}
     Log To Console  \nStart to Upgrade site with active selected
     Connect to gnb coam via ssl    connection=${connection}
     ${startTime}    BuiltIn.Get Time    epoch
     ${result}    coam.update_software    sw_package=${upgrade_package_path}   timeout=3600   connection=${connection}
     Sleep    2min
     Wait Until Keyword Succeeds    20min    10sec    Check all cells info should be onair   connection=${connection}
     ${endTime}    BuiltIn.Get Time    epoch
     ${swUpgrade_duration}    Evaluate    ${endTime}-${startTime}
     Run Keyword And Continue On Failure   Should Be True    ${swUpgrade_duration} < ${SW_upgrade_downtime_duration}
     Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
     Connect to gnb coam via ssl    connection=${connection}
     Run Keyword If    ${check_alarm}    Run Keywords
     ...    Sleep    5min    AND
     ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
     ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
     ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${connection}
     ...    ELSE    Log To Console   \nWarning: not check alarms/history alarms after SW upgrade
     Run Keyword And Ignore Error    Selenium Logout And Close Browser
     Selenium Login And Disable Screen Lock    version=${SBTS_verion}
     ${ActVerAfterUpdt}   ${CurVers}   Wait Until Keyword Succeeds   1min   10s   check SW version for e2e   version_type=Active
     ${ActVerAfterUpdt}=   Align SBTS stream for Trunk Build    InputPackage=${ActVerAfterUpdt}
     ${PsvVerAfterUpdt}   ${CurVers}   Wait Until Keyword Succeeds   1min   10s   check SW version for e2e   version_type=Passive
     ${PsvVerAfterUpdt}=   Align SBTS stream for Trunk Build    InputPackage=${PsvVerAfterUpdt}
     Should Be Equal As Strings    ${ActVerAfterUpdt}   ${target_version}
     Should Be Equal As Strings    ${PsvVerAfterUpdt}   ${ActVerB4Updt}
     Log To Console   \nStart to rollback SW and check
     ${result}    coam.rollback_software    timeout=1800    connection=${connection}
     Sleep    5min
     #Wait Until Keyword Succeeds    20min    1min    Check all cells info should be onair   connection=${connection}
     Run Keyword And Ignore Error    Selenium Logout And Close Browser
     Selenium Login And Disable Screen Lock    version=${SBTS_verion}
     ${ActVerAfterRollbk}   ${CurVers}   Wait Until Keyword Succeeds   1min   10s   check SW version for e2e   version_type=Active
     ${ActVerAfterRollbk}=   Align SBTS stream for Trunk Build    InputPackage=${ActVerAfterRollbk}
     ${PsvVerAfterRollbk}   ${CurVers}   Wait Until Keyword Succeeds   1min   10s   check SW version for e2e   version_type=Passive
     ${PsvVerAfterRollbk}=   Align SBTS stream for Trunk Build    InputPackage=${PsvVerAfterRollbk}
     ${stat1}  Run Keyword And Return Status    Should Be Equal As Strings    ${ActVerAfterRollbk}   ${ActVerB4Updt}
     ${stat2}  Run Keyword And Return Status    Should Be Equal As Strings    ${PsvVerAfterRollbk}   ${target_version}
     Exit For Loop IF    not ${stat1} or not ${stat2}
     Run Keyword If    ${check_alarm}    Run Keywords
     ...    Sleep    5min    AND
     ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
     ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
     ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${connection}
     ...    ELSE    Log To Console   \nWarning: not check alarms/history alarms after SW rollback
     Run Keyword And Ignore Error   OperatingSystem.Remove Files   ${upgrade_package_path}   ${upgrade_package_path}.sha256
     uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
