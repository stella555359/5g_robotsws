*** Settings ***
Documentation
...    author: xiaodan li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin              WITH NAME    coam
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library    taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.config.testline    WITH NAME    testline
Library    taf.ul.messaging.mtk    WITH NAME    message
Library    taf.pdu       WITH NAME    pdu
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot

*** Variables ***
@{att_ports}    ${5GRU1_ANT1}    ${5GRU1_ANT2}    ${5GRU1_ANT3}    ${5GRU1_ANT4}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
@{values}    ${0}    ${0}    ${0}    ${0}
${bts_host}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${tl_scf_dir_path}    /opt/workspace/CRT/SCF_file/
${ul_expect_throughput}    68
${dl_expect_throughput}    1500
${dl_throughput}    1800M
${ul_throughput}    120M


*** Keywords ***
## GNB BTS Precondition ##

Prepare with COAM classical BTS cell onair
    [Arguments]    ${tl_scf_filename}=${tl_scf_filename}
    Prepare the gNB cells onair status    tl_scf_file_name=${tl_scf_filename}
    Wait until keyword succeeds    15min   30s    Check the COAM gnb RU status ready
    Wait Until Keyword Succeeds    5 min    30 sec     Check the cells status on air    bts_host=${bts_host}
    ...    connection=gnb
    Wait Until Keyword Succeeds    5 min    30 sec     wait the eNB onair

Case preparation
    COAM Create log directory
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to Capacity Unit Loner    alias=ABIL Loner_1
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK Master    connection=GNB_OAM

Case env recovery
    Cell Should Be Unlocked    cell_idx=${1}    cell_group_idx=${0}    timeout=10    connection=GNB_OAM
    Run keyword and ignore error    Teardown all connections
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9

Teardown all connections
    [Arguments]    #${log_path_alarm}=${TS_CASE_LOG_PATH}
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}
    Run keyword and ignore error    csn.Disconnect    connection=ABIL Loner_1
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=RU_1


Case env recovery for cell lock
    Perform Cell Unlock    cell_idx=${1}
    Case env recovery


COAM gNB Reset site
    Connect to gnb coam via ssl    connection=coam_admin
    coam.reset_site         connection=coam_admin
    COAM Teardown gnb connections    coam_admin
    Wait Until Keyword Succeeds    5 min    30 sec     Check the cells status on air    bts_host=${bts_host}
    ...    connection=gnb
    Wait Until Keyword Succeeds    5 min    30 sec     wait the eNB onair

lock the LTE allcells
    Connect to eNB via ssl    connection=enblte
    ${subcell_status}=  coam.get_cells_info   cell_type=lte    connection=enblte
    ${length}=    get Length    ${subcell_status}
    enblte.teardown    connection=enblte
    FOR    ${index}    IN RANGE    1    ${length}+1
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_LTE_LOCKG${index}}
        Check LTEcell should be locked    cell_idx=${index}
    END


Unlock the LTE allcells
    Connect to eNB via ssl    connection=enblte
    ${subcell_status}=  coam.get_cells_info   cell_type=lte    connection=enblte
    ${length}=    get Length    ${subcell_status}
    enblte.teardown    connection=enblte
    FOR    ${index}    IN RANGE    1    ${length}+1
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_LTE_UNLOCKG${index}}
        Check LTEcell should be unlocked    cell_idx=${index}
    END

Check Unexpect Alarm should not exist
    Connect to gnb coam via ssl
    @{alarm_list}    COAM Get active alarms
    FOR    ${alarms}    IN    @{alarm_list}
       ${alarms_tmp}    Convert To String    ${alarms}[additionalFaultID]
       List Should Contain Value    ${ALLOWED_FAULT_LIST}    ${alarms_tmp}
    END
    [Teardown]  COAM Teardown gnb connections

Check cell should be locked
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    180sec    30 sec    Cell Should Be Locked
    COAM Teardown gnb connections

Check cell should be unlocked
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5 min    30 sec     Cell Should Be Unlocked
    COAM Teardown gnb connections

Check LTEcell should be locked
    [Arguments]    ${cell_idx}=${cell_idx}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    180sec    30 sec    LTECell Should Be Locked    cell_idx=${cell_idx}
    COAM Teardown gnb connections

Check LTEcell should be unlocked
    [Arguments]    ${cell_idx}=${cell_idx}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5 min    30 sec     LTECell Should Be Unlocked    cell_idx=${cell_idx}
    COAM Teardown gnb connections

Check RU should be locked
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Locked
    COAM Teardown gnb connections

Check RU should be unlocked
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    4 min   3 sec     RU Should Be Unlocked
    COAM Teardown gnb connections

Check cell should be disable
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    240 sec    3 sec    Cell Should Be Disabled
    COAM Teardown gnb connections

Get LTECell Status
    [Documentation]   Auther: xiaodan.li@nokia-sbell.com
    ...               Description: return cell status info DICT.
    ...                            Key are availabilityStatus,administrativeState,operationalState
    ...               cell_type: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]  ${cell_type}=nr    ${cell_idx}=${1}   ${timeout}=10   ${connection}=GNB_OAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${subcells_status}    coam.get_cells_info   cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${index}    ${subcell}    IN ENUMERATE   @{subcells_status}
            ${status_dict}   Run keyword if    '${subcell['cellName']}'=='LTEcell-${cell_idx}'
    ...              Catenate
    ...                         'operationalState':
    ...                         '${subcell["status"]["operationalState"]}',
    ...                         'administrativeState':
    ...                         '${subcell["status"]["administrativeState"]}',
    ...                         'blockingState':
    ...                         '${subcell["status"]["blockingState"]}',
           Exit For Loop If	'${subcell['cellName']}'=='LTEcell-${cell_idx}'
    END
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

LTECell Should Be Locked
    [Documentation]   Auther: xiaodan.li@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  Get LTECell Status      cell_type=lte    cell_idx=${cell_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${locked}    Set Variable If    ${result}    Locked    locked
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${disabled}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${locked}

LTECell Should Be Unlocked
    [Documentation]   Auther: xiaodan.li@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  Get LTECell Status      cell_type=lte    cell_idx=${cell_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${unlocked}    Set Variable If    ${result}    Unlocked    unlocked
    Should Be Equal As Strings  ${subcell_status["operationalState"]}    ${enabled}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}    ${unlocked}
