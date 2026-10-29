*** Settings ***
Documentation    Suite description
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Library        SSHLibrary    timeout=10s

*** Variables ***
${UE_TYPE}                ${tl.ues[0].capabilities[-1]}
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

*** Keywords ***

TC01 EE features IWK with Site reset
    [Documentation]  check Repeatedly entering and exiting ESM and DSM
    [Arguments]    ${loops}=${ESM['TC01']['loops']}
    ...            ${nrcells}=${ESM['TC01']['nrcells']}
    ...            ${ltecells}=${ESM['TC01']['ltecells']}
    ...            ${Radio_list}=${ESM['TC01']['Radio_list']}
    ...            ${scf}=${ESM['TC01']['scf']}
    KW.EeFeatureIWKTestingPreparation    scf=${scf}    nrcells=${nrcells}    ltecells=${ltecells}    Radio=${Radio_list}
    Log to console    Start to reset site
    wait until keyword succeeds    2x    30s    COAM_Admin.Login
    FOR  ${i}  IN RANGE  0  ${loops}
        Log to console    Loop-${i}, Start to reset site
        COAM_Admin.ResetSite    timeout=1800s
        Sleep  5min
        KW.CheckCells&RadioEeStatus    NrCell=${nrcells}    LteCell=${ltecells}    Radio=${Radio_list}
    END
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Log to console    Cells entered ESM and Radios entered DSM successfully after site reset without any unexpected alarms

TC02 Repeatedly entering ESM and DSM by time and exit ESM and DSM by CM update with actCellSwitchOnForCmUpdate
    [Documentation]  check Repeatedly entering and exiting ESM and DSM
    [Arguments]  ${dn_param}=${ESM['TC02']['dn_param']}
    ...          ${nrcells}=${ESM['TC02']['nrcells']}
    ...          ${ltecells}=${ESM['TC02']['ltecells']}
    ...          ${Radio_list}=${ESM['TC02']['Radio_list']}
    ...          ${scf}=${ESM['TC02']['scf']}
    ${cm_update_times}    Get Length    ${dn_param}
    KW.EeFeatureIWKTestingPreparation    scf=${scf}    nrcells=${nrcells}    ltecells=${ltecells}    Radio=${Radio_list}
    wait until keyword succeeds   2x   30s    COAM_Admin.Login
    FOR  ${i}  IN RANGE  0  ${cm_update_times}
        wait until keyword succeeds    2x    1min    COAM Update Parameter    dist_name=${dn_param}[${i}][0]
        ...    parameter=${dn_param}[${i}][1]    value=${dn_param}[${i}][2]
        KW.CheckCells&RadioEeStatus    NrCell=${nrcells}    LteCell=${ltecells}    Radio=${Radio_list}
    END
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Log to console    Cells exited ESM and RUs exited DSM by CM update successfully without any unexpected alarms

TC03 Repeatedly entering ESM and DSM by time and exit ESM and DSM by CM update without actCellSwitchOnForCmUpdate
    [Documentation]  check Repeatedly entering and exiting ESM and DSM
    [Arguments]  ${dn_param}=${ESM['TC02']['dn_param']}
    ...          ${nrcells}=${ESM['TC02']['nrcells']}
    ...          ${ltecells}=${ESM['TC02']['ltecells']}
    ...          ${Radio_list}=${ESM['TC02']['Radio_list']}
    ...          ${scf}=${ESM['TC03']['scf']}
    ${cm_update_times}    Get Length    ${dn_param}
    KW.EeFeatureIWKTestingPreparation    scf=${scf}    nrcells=${nrcells}    ltecells=${ltecells}    Radio=${Radio_list}
    wait until keyword succeeds   2x   30s    COAM_Admin.Login
    FOR  ${i}  IN RANGE  0  ${cm_update_times}
        wait until keyword succeeds    2x    1min    COAM Update Parameter    dist_name=${dn_param}[${i}][0]
        ...    parameter=${dn_param}[${i}][1]    value=${dn_param}[${i}][2]
        KW.CheckCells&RadioEeStatus    NrCell=${nrcells}    LteCell=${ltecells}    Radio=${Radio_list}
    END
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Log to console    Cells exited ESM and RUs exited DSM by CM update successfully without any unexpected alarms

TC04 Power reset RU in DSM
    [Documentation]  power reset RU in DSM due to EE feature or manual cell lock/block
    [Arguments]  ${BlkCel_nr}=${ESM['TC04']['BlkCel_nr']}
    ...          ${BlkCel_lte}=${ESM['TC04']['BlkCel_lte']}
    ...          ${Radio_list}=${ESM['TC02']['Radio_list']}
    ...          ${loops}=${ESM['TC04']['loops']}
    ...          ${scf}=${ESM['TC04']['scf']}
    KW.EeFeatureIWKTestingPreparation    scf=${scf}
    ${DistNameList}    KW.GenerateDistNameList    nrcells=${BlkCel_nr}    ltecells=${BlkCel_lte}
    FOR  ${i}  IN RANGE  0  ${loops}
        Log to console    Loop-${i}, Start to block cells: NR cells-${BlkCel_nr} , LTE cells-${BlkCel_lte}
        AlarmWatchdog.add_allow_alarms    fault_id=49
        wait until keyword succeeds   2x    30s    KW.CoamBlockCells_UnblockCells    dist_name=${DistNameList}
        Log to console    RU-${Radio_list} should enter DSM due to EE feature and cells blocked
        wait until keyword succeeds    10x    1min    KW.CheckCells&RadioEeStatus    Radio=${Radio_list}
        Log to console    RUs entered DSM successfully, start power reset RU to exit DSM
        AlarmWatchdog.add_allow_alarms    fault_id=10
        AlarmWatchdog.add_allow_alarms    fault_id=4589
        KW.Power Reset5GRU    RuIndex=${Radio_list}
        Log to console    Power reset RU successfully, then check RU exit DSM
        wait until keyword succeeds    10x    1min    KW.CheckCells&RadioEeStatus    Radio=${Radio_list}    status=AWAKE
        AlarmWatchdog.remove_allow_alarms    fault_id=10
        AlarmWatchdog.remove_allow_alarms    fault_id=4589
        wait until keyword succeeds   2x    30s    KW.CoamBlockCells_UnblockCells    dist_name=${DistNameList}    operation=Unblock
        AlarmWatchdog.remove_allow_alarms    fault_id=49
        Sleep  5min
    END
    Log to console    RU exit DSM without any unexpected alarms

KW.Power Reset5GRU
    [Documentation]   power reset Rus
    [Arguments]   ${RuIndex}
    FOR  ${i}  IN  @{RuIndex}
        Power.Reset5GRU    pdu_ip=${tl.gnbs[0].dus[0].rus[${i}-1].pdu_port.pdu.addr}
        ...                Port_Number=${tl.gnbs[0].dus[0].rus[${i}-1].pdu_port.port_no}
        ...                model=${tl.gnbs[0].dus[0].rus[${i}-1].pdu_port.pdu}
        Sleep  5s
    END

KW.EeFeatureIWKTestingPreparation
    [Documentation]   prepare for EE feature IWK testing
    [Arguments]   ${scf}=None    ${nrcells}=None   ${ltecells}=None    ${Radio}=None
    Run Keyword If  '${scf}' != 'None'    Run Keywords
    ...   wait until keyword succeeds   3x    30s    COAM_Admin.commission    scf_file=${CFGFILE_PATH}${scf}
    ...   AND    Sleep  5min
    KW.CheckCells&RadioEeStatus    NrCell=${nrcells}    LteCell=${ltecells}    Radio=${Radio}

KW.CheckCells&RadioEeStatus
    [Documentation]   check cells should in ESM or not, check radios in DSM or not
    [Arguments]   ${NrCell}=None    ${LteCell}=None    ${Radio}=None    ${status}=SLEEP
    IF    '${NrCell}' != 'None'
        wait until keyword succeeds    30x    1min    kw.CheckCellInEnergySavingOrNot    CELL_list=${NrCell}
        Log to console    NR cells-${NrCell} in ESM
    ELSE IF    '${LteCell}' != 'None'
        wait until keyword succeeds    30x    1min    kw.CheckCellInEnergySavingOrNot    CELL_list=${LteCell}    technology=LTE
        Log to console    LTE cells-${LteCell} in ESM
    ELSE
        Log to console    No cells need to be checked
    END
    Sleep  5s
    IF  '${Radio}' != 'None'
        FOR  ${i}  IN  @{Radio}
            wait until keyword succeeds    30x    1min    KW.Check RU in DSM or NOT    RU_index=${i}    status=${status}
        END
        Run Keyword If    '${status}' == 'SLEEP'    Log to console  Radios-${Radio} in DSM
        ...    ELSE    Log to console  Radios-${Radio} Not in DSM
    ELSE
        Log to console    No radios need to be checked
    END

KW.GenerateDistNameList
    [Documentation]   generate dist_name list based on input cell list
    [Arguments]   ${nrcells}=None    ${ltecells}=None
    ${dist_name_nr_tmp}=    Set Variable    	${MRBTS_ID}/${NRBTS_ID}/NRCELL-
    ${dist_name_lte_tmp}=    Set Variable    ${MRBTS_ID}/${LNBTS_ID}/LNCEL-
    ${dist_name_nr}=    Create List
    ${dist_name_lte}=    Create List
    IF  '${nrcells}' != 'None'
        FOR  ${cellid}  IN  @{nrcells}
            ${dist_name_nr_item}=    Set Variable    ${dist_name_nr_tmp}${cellid}
            Append To List    ${dist_name_nr}    ${dist_name_nr_item}
        END
    END
    IF  '${ltecells}' != 'None'
        FOR  ${cellid}  IN  @{ltecells}
            ${dist_name_lte_item}=    Set Variable    ${dist_name_lte_tmp}${cellid}
            Append To List    ${dist_name_lte}    ${dist_name_lte_item}
        END
    END
    ${DistNameList}=    Create List    @{dist_name_nr}    @{dist_name_lte}
    [Return]    ${DistNameList}

KW.CoamBlockCells_UnblockCells
    [Documentation]   Block cells based on input cell list
    [Arguments]   ${dist_name}    ${operation}=Block
    wait until keyword succeeds   20x   1min    COAM_Admin.Login
    IF  '${operation}' == 'Block'
        FOR  ${item}  IN  @{dist_name}
            COAM Block Cell    dist_name=${item}
            Sleep  2s
        END
    ELSE
        FOR  ${item}  IN  @{dist_name}
            COAM Unblock Cell    dist_name=${item}
            Sleep  2s
        END
    END
    Log to console    Cells ${operation}ed successfully
    Run Keyword And Ignore Error    COAM_Admin.Logout

kw.CheckCellInEnergySavingOrNot
    [Documentation]   check cell is in EnergySaving state or not
    [Arguments]   ${CELL_list}    ${technology}=NR    ${ESM}=True
    ${BTSInfo}      COAM_Admin.GetBTSInfo
    ${CellsInfonr}    set variable    ${BTSInfo['cells']['nr']}
    ${CellsInfolte}    set variable    ${BTSInfo['cells']['lte']}
    ${Not_ESM_status}    Create List    NotEnergySaving    notEnergySaving
    IF  '${technology}' == 'NR'
        Log to console    Start to check NR cells energysaving status
        FOR  ${item}   IN   @{CellsInfonr}
            ${cell_id}=    set variable    ${item['globalCellId']}
            ${cell_esm_status}=    set variable    ${item['energySavingState']}
            ${CellInList}    Evaluate    ${cell_id} in ${CELL_list}
            ${ESM_Check}    Evaluate    '${cell_esm_status}' not in ${Not_ESM_status}
            Run Keyword If    ${CellInList}    Should Be True    '${ESM_Check}' == '${ESM}'
        END
    ELSE IF  '${technology}' == 'LTE'
        Log to console    Start to check LTE cells energysaving status
        FOR  ${item}   IN   @{CellsInfolte}
            ${cell_id}=    set variable    ${item['globalCellId']}
            ${cell_esm_status}=    set variable    ${item['energySavingState']}
            ${CellInList}    Evaluate    ${cell_id} in ${CELL_list}
            ${ESM_Check}    Evaluate    '${cell_esm_status}' not in ${Not_ESM_status}
            Run Keyword If    ${CellInList}    Should Be True    '${ESM_Check}' == '${ESM}'
        END
    ELSE
        Log to console    Start to check LTE cells energysaving status
        FOR  ${item}   IN   @{CellsInfolte}
            ${cell_id}=    set variable    ${item['globalCellId']}
            ${cell_esm_status}=    set variable    ${item['energySavingState']}
            ${CellInList}    Evaluate    ${cell_id} in ${CELL_list}
            ${ESM_Check}    Evaluate    '${cell_esm_status}' not in ${Not_ESM_status}
            Run Keyword If    ${CellInList}    Should Be True    '${ESM_Check}' == '${ESM}'
        END
        Log to console    Start to check NR cells energysaving status
        FOR  ${item}   IN   @{CellsInfonr}
            ${cell_id}=    set variable    ${item['globalCellId']}
            ${cell_esm_status}=    set variable    ${item['energySavingState']}
            ${CellInList}    Evaluate    ${cell_id} in ${CELL_list}
            ${ESM_Check}    Evaluate    '${cell_esm_status}' not in ${Not_ESM_status}
            Run Keyword If    ${CellInList}    Should Be True    '${ESM_Check}' == '${ESM}'
        END
    END

SuiteSetup
    log to console    \n*** Coam Suite Setup***
    TestSuite.Start
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Import Variables         ${CFGFILE_PATH}/TLConfiguration.py
    set suite variable      ${bts_type}    ${ESM['bts_type']}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    log to console    \n***commission gnb***

SuiteTearDown
    wait until keyword succeeds   2min    10s    COAM_Admin.commission
    ...      scf_file=${CFGFILE_PATH}ESM_Recovery.xml
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=${bts_type}
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

ESM.TestCase.Stop
    log to console    \n***Coam Test Teardown***
    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    run keyword if test failed     Collect_snapshot_by_WEBUI
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    TestCase.Stop

ESM.TestCase.Start
    robot_common_operations.Common Case Setup    allowed_faults_ids=${ESM['allowed_faults_ids']}
    CI_interface.Common Case Setup
    Run Keyword And Ignore error     BtsLog.StartBTSlogCollection

Collect_snapshot_by_WEBUI
    [Arguments]    ${loop}=0
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${SAVE LOG DIRECTORY}/snapshot_${filename}_${loop}.zip

KW.Check RU in DSM or NOT
    [Arguments]    ${required_info}=powerState    ${status}=DEEPSLEEP    ${RU_index}=1
    ${get_status}    get required RU info    required_info=${required_info}    RU_index=${RU_index}
    should be equal    ${get_status}    ${status}

get required RU info
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: get required info of RU
    ...    Argument: ${required_info}: e.g. cellDepType, physicalCellId, status, id, chBwDl, nrarfcnDl, band
    ...    Return: get value of required info, retun type may String, List, Dictonary
    [Arguments]    ${required_info}    ${RU_index}    ${gnb_index}=${0}    ${enb_index}=${0}
    ...    ${connection}=GNB_OAM    ${bts_type}=nr
    ${RU_list}    get RU list on bts    gnb_index=${gnb_index}    enb_index=${enb_index}
    ...    connection=${connection}    bts_type=${bts_type}
    ${RU_num}    Get Length    ${RU_list}
    ${RU_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${RU_num}
        Append To List    ${RU_dist_name_list}    ${RU_list[${index}]['id']['configuration']}
    END
    FOR    ${index}    ${RU}    IN ENUMERATE    @{RU_dist_name_list}
        ${RU_search}    Split String    ${RU}    /
        Run keyword if    '${RU_search}[-1]' == 'RMOD-${RU_index}'
        ...    Run keywords    Set Suite Variable    ${RU_index_find}    ${index}    AND    Exit For Loop
    END
    Set Suite Variable    ${required_RU_info}    ${RU_list[${RU_index_find}]['status']['${required_info}']}
    [Return]    ${required_RU_info}

get RU list on bts
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: get cell info of nr or lte or others
    ...    Return: list of cells info
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM    ${bts_type}=nr    ${timeout}=900
    Run Keyword If    '${bts_type}' == 'nr'
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=${connection}
    ...    ELSE IF    '${bts_type}' == 'lte'
    ...    Wait Until Keyword Succeeds    1 min    20 sec
    ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${connection}
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}    timeout=${timeout}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${list_RUs}