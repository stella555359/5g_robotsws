*** Settings ***
Documentation      author: Lixia Wang
...                contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                This robot file is for 5GC002479 C&P,inculding -AA,BA,CA,DA,FA subfeatures.


Resource       ../../common/NetAct_swing.robot
Resource       ./CB006443_Call_Common_Keyword.robot
Library    taf.sbts.oam.coam.admin   WITH NAME   DU_Rest
Library    taf.transport.ssh    WITH NAME    ssh
Library    ./CB006443_PM.py
Library    taf.nms.netact    WITH NAME    netact
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***

@{ALLOWED_ALARMS}=
...                                         4592
...                                         61524
...                                         61649
...								            61652
...                                         4334
...                                         4340
...                                         4654
...                                         4655
...                                         4681
...                                         61524
...                                         4741
...                                         61641
...                                         7300
...                                         7319
...                                         6327
...                                         4293
...                                         4589
...                                         6825
...                                         6832
...                                         6829
...                                         4282
...                                         1300
...                                         7313
...                                         4293
...                                         4798
...                                         62003
...                                         7509
...                                         8000
...                                         6134
#Configure the TL specific variable

${connection}   COAM
${global_bts_id}           ${tl.gnbs[0].global_bts_id}
${instance_id}              ${tl.gnbs[0].instance_id}
${DU_OAM}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USER}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
####only for debug##########
#${CellBlockDurtion}    &{CASE_INPUT_CB006443}[CB006443_HA_KPI17][KPI17a]
${CellBlockDurtion}     ${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17a']}
${CellUnblockDurtion}    ${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17b']}
#${CellUnblockDurtion}    ${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17b']}
${ResetBBMODDurtion}     ${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
${KPI54A_MAX}         ${CASE_INPUT_CB006443['CB006443_KPI54A']['KPI54A_MAX']}
${ResetRMODDurtion}    ${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_MAX']}
####only for debug###########
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
#${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
#${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}

###For ssh to Netact####
${netact_info}     ${tl.nms.addr}


######## KeyWords for CB006443 #######
*** Keywords ***

TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
    [Documentation]  This is for test case TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
    [Arguments]    ${KPI17a}=${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17a']}
    ...    ${KPI17b}=${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17b']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI17']['cell_block_times']}
    ...    ${check_history}=True     ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

	&{kpi_results}=    Create Dictionary    kpi17a=@{EMPTY}    kpi17b=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_17a  KPI_17b
    Set Test Variable  ${target_kpis}
    ${Fault_ID} =    Set Variable   49
    Set suite variable    ${ALLOWED_ALARMS_KPI17}    ${ALLOWED_ALARMS}
    Append to list   ${ALLOWED_ALARMS_KPI17}    ${Fault_ID}
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DU_WebEM.Block cell and unblock cell one by one
    ...    cell_id_list=${cell_id_list}    connection=${connection}   expected_alarm_index=${49}
    ...	   KPI17a=${KPI17a}    KPI17b=${KPI17b}    check_history=${check_history}
    ${cellid}    evaluate    random.choice(${cell_id_list})    random
    log to console      ${cellid}
    FOR    ${i}    IN RANGE    ${repeat_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${case_status}    RUN KEYWORD AND RETURN STATUS
        ...    RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.Block cell and unblock cell
        ...    cell_id=${cellid}     connection=${connection}
        ...    expected_alarm_index=${49}    loop=${i+1}
        ...    check_history=${check_history}
        ...    KPI17a=${KPI17a}
        ...    KPI17b=${KPI17b}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
    END
    [Teardown]    Run Keywords      run keyword and ignore error  TC.teardown
			   ...    AND    Report KPI    kpi17a
			   ...    AND    Report KPI    kpi17b


TC.CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Documentation]  This is for test case CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Arguments]    ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['BBMOD_reset_times']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['fail_loop_max']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    &{kpi_results}=    Create Dictionary    kpi5=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_5
    Set Test Variable  ${target_kpis}
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DU_WebEM.Get BBMOD distname and id
    FOR    ${BBMOD}    IN    @{BBMOD_id_list}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${case_status}    RUN KEYWORD AND RETURN STATUS    RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.reset BBMOD
        ...    BBMOD_id=${BBMOD}     connection=${connection}     KPI5_MAX=${KPI5_MAX}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal     ${case_status}    ${True}    ignore_case=true
    END
    ${BBMOD_ID}    evaluate    random.choice(@{BBMOD_id_list})    random
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${case_status}    RUN KEYWORD AND RETURN STATUS    RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.reset BBMOD
        ...    BBMOD_id=${BBMOD_ID}     connection=${connection}     KPI5_MAX=${KPI5_MAX}    loop=${i+1}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal     ${case_status}    ${True}     ignore_case=true

        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        Append To List    ${result_list}    ${case_status}
        ${fail_num}    Count Values In List    ${result_list}     False
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown

TC.CB006443_HA_04_OAM_KPI_54a_RU_cold_Reset_Time
    [Documentation]   This is for test RU cold reset KPI 54a
    ...    Precondition: RU PB information must configured in testline_configuration/_init_.py.
    ...    The RU order must be aligned with RU index
    [Arguments]    ${KPI54A_MAX}=${CASE_INPUT_CB006443['CB006443_KPI54A']['KPI54A_MAX']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_KPI54A']['ru_reset_times']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_KPI54A']['fail_loop_max']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}     ${RU_ID}=${None}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    &{kpi_results}=    Create Dictionary    kpi54a=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_54a
    Set Test Variable  ${target_kpis}
     ${Fault_ID} =    Set Variable   10
     Set suite variable     ${ALLOWED_ALARMS_KPI54a}      ${ALLOWED_ALARMS}
     Append to list   ${ALLOWED_ALARMS_KPI54a}    ${Fault_ID}
     ${connection}    Connect to DU by ADMIN API
     DU_WebEM.Get NR Cell distname and id
    ${length}=   Get Length     ${tl.gnbs[0].dus[0].rus}
    log to console    ${length}
    #FOR    ${i}    IN RANGE    ${length}
    #     ${case_status}    RUN KEYWORD AND RETURN STATUS    RUN KEYWORD AND CONTINUE ON FAILURE
    #     ...    PB.Power on or off one RU     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
    #     ...    Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
    #     ...    model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
    #     ...    KPI54A_MAX=${KPI54A_MAX}
    #     ...    loop=${i+1}
    #     RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}   ignore_case=true
    #END
    ${RU_ID_1}     Evaluate    random.randint(0, ${length}-1)    modules=random
    ${RU_INDEX}    Run Keyword If    '${RU_ID}'!='${None}'    Set Variable     ${RU_ID}
    ...    ELSE IF     '${RU_ID}'=='${None}'      Set Variable     ${RU_ID_1}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
         ${case_status}    RUN KEYWORD AND RETURN STATUS    RUN KEYWORD AND CONTINUE ON FAILURE
         ...    PB.Power on or off one RU     pdu_ip=${tl.gnbs[0].dus[0].rus[${RU_INDEX}].pdu_port.pdu.addr}
         ...    Port_Number=${tl.gnbs[0].dus[0].rus[${RU_INDEX}].pdu_port.port_no}
         ...    model=${tl.gnbs[0].dus[0].rus[${RU_INDEX}].pdu_port.pdu.vendor}
         ...    KPI54A_MAX=${KPI54A_MAX}
         ...    loop=${i+1}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true

        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}

        Append To List    ${result_list}    ${case_status}
        ${fail_num}    Count Values In List    ${result_list}     False
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown

TC.CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time
    [Arguments]    ${RF_reset_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['RF_reset_times']}
    ...    ${KPI51_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_MAX']}
    ...    ${KPI51_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_AVG']}
    ...    ${Login_Flag}=${True}     ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    [Documentation]  This is for test case CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time

	&{kpi_results}=    Create Dictionary    kpi51a=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_51a
    Set Test Variable  ${target_kpis}

    wait until keyword succeeds     8min   3s     connect to DU by ADMIN API
    DU_WebEM.Get RMOD ID
    Run Keyword if    '${Login_Flag}'=='True'    run keyword and ignore error     DisConnect to DU by ADMIN API
    DU_WebEM.loop reset all RMOD    RMOD_id_list=${RMOD_id_list}    connection=${connection}
    ...    reset_times=${RF_reset_times}    KPI51_MAX=${KPI51_MAX}     KPI51_AVG=${KPI51_AVG}
    ...    Login_Flag=${Login_Flag}    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}     duration_dl=${duration_dl}
    ${RMOD_ID}    evaluate    random.choice(${RMOD_id_list})    random
    log to console      ${RMOD_ID}
    DU_WebEM.loop reset one RMOD    RMOD_id=${RMOD_ID}     connection=${connection}
    ...     retry_times=${RF_reset_times}    KPI51_MAX=${KPI51_MAX}     KPI51_AVG=${KPI51_AVG}
    ...    Login_Flag=${Login_Flag}    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_ul_tp=${exepected_ul_tp}     exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}
    ...    duration_dl=${duration_dl}
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown    AND    Report KPI    kpi51a
##########Start commmon keyword for CB006443#############
#Get SW release by ADMIN API
#    [Arguments]   ${connection_AdminApi}=COAM   ${StreamVersion}=${StreamVersion}
#   ...    ${Login_Flag}=${False}
#    DU_Rest.connect_to
#    ...    bts_host=${DU_OAM}    name=${connection_AdminApi}
#    ...    username=${WEBUI_USER}
#    ...    password=${WEBUI_PWD}
#   ${BTSInfo}      coam.get_bts_info      connection=${connection_AdminApi}
#    Set Test Variable    ${BTSInfo}
#    ${key1}    Check Parameter valid    Parameter=BTSInfo['swInfo']['swVersion']    default_value=${empty}
#    ${key2}    Check Parameter valid    Parameter=BTSInfo['swInfo']['nrRatVersion']   default_value=${empty}
 #   ${key3}    Check Parameter valid    Parameter=BTSInfo['swInfo']['lteRatVersion']    default_value=${empty}
#    @{release_tmp}    create list   ${EMPTY}
 #   ${release}    Run Keyword if    '${key1}'!='${empty}'
#    ...    String.Split String    ${key1}   _
#    ...    ELSE IF    '${key2}'!='${empty}'
#    ...    String.Split String    ${key2}   _
 #   ...    ELSE IF    '${key3}'!='${empty}'
 #   ...    String.Split String    ${key3}   _
 #   ...    ELSE   Copy List    ${release_tmp}
 #   ${len}    Run Keyword And Ignore Error    Get Length     ${release}
#    ${StreamVersion}      Run Keyword if    '${len[0]}'=='PASS' and '${Empty}' not in ${release}
#    ...    set variable    ${release}[0]
 #   ...    ELSE    set variable    ${StreamVersion}
#    Run Keyword if    '${Login_Flag}'=='True'    Connect to DU by ADMIN API
 #   ...    connection_AdminApi=${connection_AdminApi}
#    [Return]   ${StreamVersion}
 #   [TearDown]    Run Keyword if    '${Login_Flag}'=='False'
 #   ...    Run Keyword And Ignore Error    DisConnect to DU by ADMIN API

Check Parameter valid
    [Arguments]    ${Parameter}    ${default_value}=None
    ${res}    run keyword and ignore error   log    ${${Parameter}}
    Run Keyword if    '${res[0]}'=='FAIL'   set suite variable    ${${Parameter}}    ${default_value}
    [Return]   ${${Parameter}}

Connect to DU by ADMIN API
    [Arguments]      ${connection_AdminApi}=${connection}
    Connect to gnb coam via ssl    connection=${connection_AdminApi}
    ...    bts_host=${DU_OAM}
    ...    username=${WEBUI_USER}
    ...    password=${WEBUI_PWD}
    [Return]   ${connection_AdminApi}

Get stream version
    [Documentation]  This is KW is just for SBTS
    [Arguments]      ${Stream_Master}=${CASE_INPUT_CB006443['Stream_Version']}
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}
    ${StreamVersion}    set variable if    '${ci_var_dict}[stream]'=='SBTS00'
    ...    ${Stream_Master}    ${ci_var_dict}[stream]
    log to console    Stream version is ${StreamVersion}
    [Return]   ${StreamVersion}

DisConnect to DU by ADMIN API
     [Arguments]      ${connection_AdminApi}=${connection}
     DU_Rest.teardown    connection=${connection_AdminApi}

TC.teardown
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache


TC.Precondition
    KW.CleanFirefox


DU_WebEM.Get alarm in DU
    [Documentation]  This KW is for get all activate alarm  and history alarm in DU
    [Arguments]    ${active_fault_list}=${Empty}    ${historic_fault_list}=${Empty}
    ...    ${ParameterInput}=True    ${check_history}=True

    ${active_fault_list}    Run Keyword If   '${ParameterInput}'=='False'
    ...    DU_Rest.get_active_alarms    connection=${connection}   timeout=20
    ...    ELSE IF    '${ParameterInput}'=='True'     Set Variable    ${active_fault_list}
    ${len}=    Get Length    ${active_fault_list}

    FOR    ${index}    IN RANGE    ${len}
        Keep In Dictionary    ${active_fault_list[${index}]}
        ...   faultId    configObjectName    btsObservationTime
    END
    @{historic_fault_list_0}    create list   ${empty}
    ${historic_fault_list_1}        Run Keyword If   '${ParameterInput}'=='False' and '${check_history}'=='True'
    ...    DU_Rest.get_historic_alarms    connection=${connection}   timeout=20
    ...    ELSE IF    '${ParameterInput}'=='True' and '${check_history}'=='True'
    ...    Set Variable    ${historic_fault_list}
    ...    ELSE IF    '${check_history}'=='False'    Set Variable    @{historic_fault_list_0}
    ${len1}=    Get Length    ${historic_fault_list_1}
    FOR    ${index}    IN RANGE    ${len1}
         Keep In Dictionary    ${historic_fault_list_1[${index}]}
         ...   faultId    configObjectName    eventTime
    END
    [Return]     ${active_fault_list}    ${historic_fault_list_1}

DU_WebEM.check alarm by string
    [Documentation]  This KW is for get all activate alarm  and history alarm in DU
    ...    parameter 'FaultFlag' can be set to 'Raised' or 'Cleared'
    [Arguments]       ${fault_id}=${49}    ${FaultFlag}=Raised
    ${active_fault_list}=    DU_Rest.get_active_alarms    connection=${connection}   timeout=20
    ${historic_fault_list}=    DU_Rest.get_historic_alarms    connection=${connection}   timeout=20
    ${active_fault_string}    Convert To String    ${active_fault_list}
    Run Keyword If   '${FaultFlag}'=='Raised'
    ...    Should Contain    ${active_fault_string}    'faultId':${Space}${fault_id}
    ...    ELSE IF    '${FaultFlag}'=='Cleared'
    ...    Should Not Contain    ${active_fault_string}    'faultId':${Space}${fault_id}

    [Return]   ${active_fault_list}     ${historic_fault_list}

DU_WebEM.Check alarm in DU
    [Documentation]  This KW is for check new alarm is reported after some operations
    [Arguments]       ${alarm1}    ${alarm2}
    ${len}=    Get Length    ${alarm1}
    ${len1}=    Get Length    ${alarm2}
    @{new_alarm_list}   Create List
    FOR    ${index}    IN RANGE    ${len1}
        Run Keyword If  ${alarm2[${index}]} not in @{alarm1}    Append To List    ${new_alarm_list}    ${alarm2[${index}]}
    END
    [Return]    @{new_alarm_list}

DU_WebEM.Validate alarm is raised or canceled in DU
    [Documentation]  This KW is for check new alarm is reported after some operations
    ...    alarm status have two values:raised,canceled
    [Arguments]    ${active_fault_list_0}    ${historic_fault_list_0}
    ...    ${active_fault_list}    ${historic_fault_list}    ${expected_alarm_index}    ${alarm_status}
    ...    ${check_history}=True
    ${new_faultid_list}    DU_WebEM.Check alarm in DU   alarm1=${active_fault_list_0}    alarm2=${active_fault_list}
    ${history_faultid_list}     Run keyword if    '${check_history}' == 'True'
    ...    DU_WebEM.Check alarm in DU   alarm1=${historic_fault_list_0}   alarm2=${historic_fault_list}
    ${len}=    Get Length    ${new_faultid_list}
    ${len1}    Run keyword if    '${check_history}' == 'True'   Get Length    ${history_faultid_list}
    Run keyword if    '${alarm_status}' == 'raised' and '${check_history}' == 'True'
    ...    RUN KEYWORDS    Should Be Equal    ${len}  ${1}    AND
    ...    Should Be Equal    ${new_faultid_list[0]['faultId']}    ${expected_alarm_index}    AND
    ...    Should Be Equal    ${len1}  ${0}
    ...    ELSE IF    '${alarm_status}' == 'canceled' and '${check_history}' == 'True'
    ...    RUN KEYWORDS    Should Be Equal    ${len}  ${0}    AND
    ...    Should Be Equal    ${len1}  ${1}    AND
    ...    Should Be Equal    ${history_faultid_list[0]['faultId']}    ${expected_alarm_index}
    ...    ELSE IF    '${alarm_status}' == 'raised' and '${check_history}' == 'False'
    ...    RUN KEYWORDS    Should Be Equal    ${len}  ${1}    AND
    ...    Should Be Equal    ${new_faultid_list[0]['faultId']}    ${expected_alarm_index}
    ...    ELSE IF    '${alarm_status}' == 'canceled' and '${check_history}' == 'False'
    ...    Should Be Equal    ${len}  ${0}

DU_WebEM.Get NR Cell distname and id
    [Arguments]    ${connection}=${connection}
    [Documentation]  This KW is for get cell distname and id list

    ${cell_info}=    DU_Rest.get_cells_info    cell_type=nr    timeout=30    connection=${connection}
    @{cell_id_list}    create list
    FOR    ${elem}    IN    @{cell_info}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${cell_id_list}   ${elem['id']}
        Set Suite Variable    ${cell_id_list}
    END

DU_WebEM.Check NR Cell status
    [Documentation]  This KW is for get one cell status and check cell onair
    [Arguments]    ${cell_internal_id}     ${operational_State}=${empty}
    ...    ${procedural_Status}=${empty}    ${availability_Status}=${empty}    ${blockingState}=${empty}
    ...    ${administrative_State}=${empty}       ${timeout}=${30}
    log to console      parameter timeout '${timeout}' is not used
    ${cell_info}=    DU_Rest.get_cell_specific_info
    ...   cell_id=${cell_internal_id}   timeout=30    connection=${connection}
    Run keyword if   '${operational_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['operationalState']}    ${operational_State}    ignore_case=true
    Run keyword if   '${procedural_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['proceduralStatus']}    ${procedural_Status}     ignore_case=true
    Run keyword if   '${availability_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['availabilityStatus']}    ${availability_Status}    ignore_case=true
    Run keyword if   '${blockingState}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['blockingState']}    ${blockingState}    ignore_case=true
    Run keyword if   '${administrative_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['administrativeState']}    ${administrative_State}    ignore_case=true


DU_WebEM.Check all NR Cell status
    [Documentation]  This KW is for get and check all cell status
    [Arguments]    ${cell_id_list}    ${all_flag}    ${connection}=COAM    ${operational_State}=${empty}
    ...    ${availability_Status}=${empty}    ${blockingState}=${empty}
    ...    ${administrative_State}=${empty}
    ...    ${procedural_Status}=${empty}
    #log to console      parameter procedural_Status:"${procedural_Status}" is not used and can be ignored
    ${procedural_Status_not_used}      set variable       ${procedural_Status}
    log to console      check NR cell on air
    @{check_status_list}    create list
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${cell_info}=    DU_Rest.get_cell_specific_info
        ...   cell_id=${cell_id['internal']}   timeout=30    connection=${connection}
		${status}    Run Keyword And Return Status    Should be equal    ${cell_info['status']['operationalState']}
		...    ${operational_State}    ignore_case=true
        Run keyword if    "${all_flag}" == "False"    Run Keywords    Append to list    ${check_status_list}    ${status}
        ...    AND           set test variable    ${check_status_list}
        Run keyword if    "${all_flag}" == "True" and '${operational_State}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['operationalState']}    ${operational_State}    ignore_case=true
        Run keyword if    "${all_flag}" == "True" and '${availability_Status}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['availabilityStatus']}
        ...    ${availability_Status}    ignore_case=true
        Run keyword if    "${all_flag}" == "True" and '${blockingState}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['blockingState']}    ${blockingState}    ignore_case=true
        Run keyword if    "${all_flag}" == "True" and '${administrative_State}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['administrativeState']}
        ...    ${administrative_State}    ignore_case=true
    END
	Run keyword if    "${all_flag}" == "False"      List Should Contain Value    ${check_status_list}    ${True}


DU_WebEM.LogIn and Check all NR Cell On Air
    [Arguments]    ${login_flag}=${True}    ${connection}=COAM    ${reset_flag}=${False}
    ...    ${wait_time}=20min
    Run keyword if    "${login_flag}"=="${True}"    Wait Until Keyword Succeeds    ${wait_time}    15s
    ...    Connect to DU by ADMIN API    connection_AdminApi=${connection}
    DU_WebEM.Get NR Cell distname and id      connection=${connection}
    ${cell_status}    RUN KEYWORD AND RETURN STATUS
    ...    Wait Until Keyword Succeeds    ${wait_time}    10s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True    connection=${connection}
    ...    operational_State=Enabled
    ...    blockingState=Unblocked    administrative_State=Unlocked
    Run Keyword If    '${cell_status}'=='${True}'    run keyword and ignore error      log to console
    ...  NR cells are all onair
    ...  ELSE
    ...  run keyword and ignore error      log to console     NR cells are not onair after ${wait_time}
    run keyword if    '${cell_status}'=='${False}' and '${reset_flag}'=='${True}'    RUN KEYWORDS
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    taf.sbts.oam.coam.admin.reset_site     timeout=300
    ...    connection=${connection}    wait_for_reconnection=${True}
    ...    AND    RUN KEYWORD AND CONTINUE ON FAILURE    Wait Until Keyword Succeeds    ${wait_time}    15s
    ...    Connect to DU by ADMIN API    connection_AdminApi=${connection}
    ...    AND    Wait Until Keyword Succeeds    ${wait_time}    2s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled
    ...    blockingState=Unblocked    administrative_State=Unlocked    connection=${connection}
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${cell_status}    ${True}
    [Teardown]    Run keyword if    "${login_flag}" == "${True}"
    ...    run keyword and ignore error  DisConnect to DU by ADMIN API     connection_AdminApi=${connection}

Update or Create parameter by Admin API
    [Documentation]  This KW is for update one parameter
    [Arguments]       ${class_name}    ${parameter_Abbreviation}
	...    ${Expected_Value}    ${Dist_name}    ${Operation}=update    ${connection_AdminApi}=${connection}

	 ${out_parameters_list}     taf.sbts.oam.coam.admin.get_managed_objects
        ...    class_name=${class_name}    connection=${connection_AdminApi}
    ${out_parameter}    Get From Dictionary    ${out_parameters_list[0]}    parameters
    ${parameter_value}    Get From Dictionary    ${out_parameter}    	${parameter_Abbreviation}
     run keyword if    '${parameter_value}'!='${Expected_Value}'
	 ...    taf.sbts.oam.coam.admin.perform_parameter_recommissioning   dist_name=${Dist_name}
	 ...    parameter=${parameter_Abbreviation}    operation=${Operation}    value=${Expected_Value}
     ...   connection=${connection_AdminApi}   skip_parameter_relation_errors=True
    [Return]    ${parameter_value}

Update or Create parameter based on NIDD
    [Documentation]  This KW is for update one parameter,will spend more time,
    ...    but if there is new parameter added, it will work
    [Arguments]    ${class_name}    ${filelocation}
	...    ${Expected_Value}    ${Dist_name}    ${MOCName}   ${exception_list}
	...    ${sheet_name}=Parameters    ${connection_AdminApi}=${connection}
	...    ${filter}=MNL-productVariantPlanned==5gClassicalBTS, then this parameter MUST NOT be configured

	${parameter_list}=    read_pm_parameter_from_nidd   filelocation=${filelocation}
    ...    sheet=${sheet_name}    MOCName=${MOCName}    filter=${filter}     exception_list=@{exception_list}
	${out_parameters}     taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}    connection=${connection_AdminApi}
    ${out_parameter_list}    Get From Dictionary    ${out_parameters[0]}    parameters
	${len}    get length    ${parameter_list}
	FOR    ${i}    IN RANGE    ${len}
         ${parameter_value}    Get From Dictionary    ${out_parameter_list}   	${parameter_list[${i}]}
         run keyword if    '${parameter_value}' != '${Expected_Value}' and '${parameter_value}' != '${empty}'
	 ...    Run Keyword And Ignore error    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
	 ...    dist_name=${Dist_name}   parameter=${parameter_list[${i}]}   operation=update    value=${Expected_Value}
     ...   connection=${connection_AdminApi}   skip_parameter_relation_errors=True
         run keyword if    '${parameter_value}' == '${empty}'
	 ...    Run Keyword And Ignore error    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
	 ...    dist_name=${Dist_name}   parameter=${parameter_list[${i}]}     operation=create   value=${Expected_Value}
     ...   connection=${connection_AdminApi}    skip_parameter_relation_errors=True
    END

Update or Create Object based on NIDD
    [Arguments]    ${class_name}    ${filelocation}
	           ...    ${Expected_Value}    ${Dist_name}    ${MOCName}   ${exception_list}
	           ...    ${sheet_name}=Parameters    ${connection_AdminApi}=${connection}
	           ...    ${filter}=MNL-productVariantPlanned==5gClassicalBTS, then this parameter MUST NOT be configured
	${parameter_list}=    read_pm_parameter_from_nidd   filelocation=${filelocation}
    ...    sheet=${sheet_name}    MOCName=${MOCName}    filter=${filter}     exception_list=@{exception_list}
	${out_parameters}     taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}    connection=${connection_AdminApi}
    ${out_parameter_list}    Get From Dictionary    ${out_parameters[0]}    parameters
	${len}    get length    ${parameter_list}
    @{MO_p_list}     Create List
	FOR    ${i}    IN RANGE    ${len}
        ${parameter_value}    Get From Dictionary    ${out_parameter_list}   	${parameter_list[${i}]}
        ${param_dict}    run keyword if
        ...    '${parameter_value}' != '${Expected_Value}' and '${parameter_value}' != '${empty}'
	    ...    Create Dictionary    parameterName=${parameter_list[${i}]}  value=${Expected_Value}    operation=update
        ...    ELSE IF    '${parameter_value}' == '${empty}'
	    ...    Create Dictionary    parameterName=${parameter_list[${i}]}  value=${Expected_Value}    operation=create
	    ${res1}    Run Keyword And Return Status    Dictionary Should Contain Key    ${param_dict}    parameterName
        run keyword if    '${res1}'!='False'    Append to list   ${MO_p_list}    ${param_dict}
        # ${MO_p_list}    set variable    ${MO_p_list}
        Set Suite Variable    ${MO_p_list}
    END
    ${len}    get length   ${MO_p_list}
    run keyword if    '${len}'!='${0}'    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${Dist_name}
    ...    parameter=${MO_p_list}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection_AdminApi}

##########End commmon keyword for CB006443#############

##########start keyword for CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually#############
DU_WebEM.Block cell and unblock cell
    [Documentation]  This KW is for blocking one cell and unblocking one cell by cell distname
    [Arguments]    ${cell_id}    ${connection}
    ...    ${KPI17a}=${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17a']}
    ...    ${KPI17b}=${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17b']}
    ...    ${check_history}=True
    ...    ${expected_alarm_index}=${49}  ${loop}=${2}
    log to console      expected_alarm_index '${expected_alarm_index}' and loop '${loop}' is not used
	ims_keywords.check_instance_connection    gnbbbu
    oam_kpi_calculations.clear_results
    log to console    block cell start
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    ${faultid_list_0}    DU_WebEM.Get alarm in DU     ParameterInput=False    check_history=${check_history}
    #${block_startTime}    KW.TimerStart
    wait until keyword succeeds   1min   2s    DU_Rest.block_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    #${alarm_startTime}    KW.TimerStart
    ${block_cell_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3min    3s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_id['internal']}
    ...    timeout=30   operational_State=Disabled
    ...    blockingState=Blocked    administrative_State=Unlocked

    ${status}    wait until keyword succeeds   15s   66ms    DU_WebEM.check alarm by string    FaultFlag=Raised
   log to console    unblock cell start
    ${faultid_list_0}    DU_WebEM.Get alarm in DU     ParameterInput=False    check_history=${check_history}
    Run Keyword and Continue on Failure
    ...    wait until keyword succeeds   15s   5s    DU_Rest.unblock_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    ${unblock_cell_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3min    3s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_id['internal']}    timeout=30   operational_State=Enabled
    ...    blockingState=Unblocked    administrative_State=Unlocked


    ${status}    Run Keyword and Continue on Failure
    ...     wait until keyword succeeds   15s   5ms    DU_WebEM.check alarm by string    FaultFlag=Cleared

    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI17}    referrence_time=${referrence_time}
	Run Keyword And Ignore Error     sleep    2s
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${timestamp_log}_ims2/
    ${status_kpi}  Run Keyword And Continue On Failure    Analyse IMS File   kpi_list=${kpi_list}    loop=${timestamp_log}
    ${status}  Evaluate  ${status_kpi} or ${alarm_status} or ${history_alarm_status}
    ${cell_status}  Evaluate  ${block_cell_status} or ${unblock_cell_status}
    #${duration_time_tmp}    Set Variable    ${kpi_avg}
	${block_duration}    Run Keyword And Continue On Failure
	...    oam_kpi_calculations.get_average_results    kpi_name=${kpi_list}[0]
	${unblock_duration}    Run Keyword And Continue On Failure
	...    oam_kpi_calculations.get_average_results    kpi_name=${kpi_list}[1]
	RUN KEYWORD AND CONTINUE ON FAILURE     log to console    block and unblock duration is ${block_duration} and ${unblock_duration}

    ${test_status}	   Set Variable If
    ...    "${cell_status}"=="True" and "${status}"=="False" and ${1}<${block_duration}<${KPI17a} and ${0}<${unblock_duration}<${KPI17b}
    ...    pass      fail
     ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
     ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error    WEBUI.Collect snapshot
     ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
     Run Keyword If    '${test_status}'=='pass'    Run Keyword And Ignore Error
     ...    Run keywords      Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
     ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${timestamp_log}_ims2/

     Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
     Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
     Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
     RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
     Run Keyword And Ignore Error    log to console    the testing result of this block unblock cell is ${test_status}
    [Teardown]     run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu
    #[Teardown]    run keyword and ignore error     DU_WebEM.TearDown.unblock one cell
    #...    cell=${cell_id}     connection=${connection}

DU_WebEM.Block cell and unblock cell one by one
    [Documentation]  This KW is for blocking cell and unblocking cell one by one
    [Arguments]    ${cell_id_list}    ${connection}    ${expected_alarm_index}
    ...    ${KPI17a}=${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17a']}
    ...    ${KPI17b}=${CASE_INPUT_CB006443['CB006443_HA_KPI17']['KPI17b']}
    ...    ${check_history}=True
    FOR    ${cell}    IN    @{cell_id_list}
        ${case_status}    RUN KEYWORD AND RETURN STATUS
        ...    RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.Block cell and unblock cell
        ...    cell_id=${cell}     connection=${connection}
        ...    expected_alarm_index=${expected_alarm_index}    	KPI17a=${KPI17a}    KPI17b=${KPI17b}
        ...    check_history=${check_history}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true

    END

DU_WebEM.TearDown.unblock cell
    [Arguments]    ${cell_id_list}    ${connection}
    FOR    ${cell}    IN    @{cell_id_list}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=${cell['internal']}    timeout=30   operational_State=Enabled
        ...    blockingState=Unblocked    administrative_State=Unlocked
        RUN KEYWORD If    '${res[0]}'=='FAIL'    run keyword and ignore error    DU_Rest.unblock_cell
        ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}
    END

DU_WebEM.TearDown.unblock one cell
    [Arguments]    ${cell}    ${connection}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=${cell['internal']}    timeout=30   operational_State=Enabled
        ...    blockingState=Unblocked    administrative_State=Unlocked
        RUN KEYWORD If    '${res[0]}'=='FAIL'    run keyword and ignore error    DU_Rest.unblock_cell
        ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}

##########End keyword for CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually#############

##########Start keyword for CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration#############
DU_WebEM.Get BBMOD distname and id
    [Documentation]  This KW is for get BBMOD distname and id list
    ${BBMOD_info}=    DU_Rest.get_fbb_info    timeout=30    connection=${connection}
    @{BBMOD_id_list}    create list
    FOR    ${elem}    IN    @{BBMOD_info}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${BBMOD_id_list}   ${elem['id']}
        Set Suite Variable    ${BBMOD_id_list}
    END

DU_WebEM.reset BBMOD
    [Arguments]    ${BBMOD_id}    ${connection}=COAM    ${loop}=${0}
    ...    ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    log to console    reset BBMOD start loop${loop}
    ims_keywords.check_instance_connection    gnbbbu
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    wait until keyword succeeds   1min   3s    DU_Rest.reset_unit
    ...    dist_name=${BBMOD_id['internal']}    reset_type=Warm   timeout=300    connection=${connection}
    log to console    check all cell status start
    Run Keyword and Continue on Failure     Wait Until Keyword Succeeds    8min    1s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled
    ...    blockingState=Unblocked    administrative_State=Unlocked

    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${loop}_${timestamp_log}    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    ${status}  Run Keyword and Continue on Failure     Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If
        ...     ${10}<${duration_time_tmp}<${KPI5_MAX} and "${alarm_status}"=="False" and "${history_alarm_status}"=="False"
        ...     True      False
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='False'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    Run Keyword If    '${reset_status}'=='True'     Run Keyword And Ignore Error
        ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    log to console    The testing result of this reset BBMOD is ${reset_status}
    RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    True    ignore_case=true
    log to console    KPI5 loop${loop} is ${reset_status} and KPI is ${duration_time_tmp}
    [Teardown]    Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
##########End keyword for CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration#############

##########Start keyword for CB006443_HA_04_OAM_KPI_54a_RU_cold_Reset_Time#############
PB.Power on or off one RU
    [Documentation]  This is KW is for power on or off one RU by RU index
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${model}=FACOM
     ...    ${KPI54A_MAX}=${CASE_INPUT_CB006443['CB006443_KPI54A']['KPI54A_MAX']}
     ...    ${loop}=${1}
     log to console     parameter loop '${loop}' is not used
     oam_kpi_calculations.clear_results
     ims_keywords.check_instance_connection    gnbbbu
     Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
     ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
     ${referrence_time}      convert date    ${timestamp_log}    epoch
     PB.PowerOnOff     pdu_ip=${pdu_ip}    Port_Number=${Port_Number}    Action=power_off    model=${model}
	 log to console    check all cell status start
	 Run Keyword And Return Status
	    ...    Wait Until Keyword Succeeds    3min    3s     DU_WebEM.Check all NR Cell status
        ...    cell_id_list=${cell_id_list}     all_flag=False
        ...    operational_State=Disabled
        ...    blockingState=Unblocked    administrative_State=Unlocked
    Timer.Start
	PB.PowerOnOff     pdu_ip=${pdu_ip}    Port_Number=${Port_Number}    Action=power_on    model=${model}
	log to console    check all cell status start
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    Wait Until Keyword Succeeds    15min    3s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled
    ...    blockingState=Unblocked    administrative_State=Unlocked
     ${duration_1}     Timer.Stop
     #Run Keyword And Ignore Error     log to console     old KPI is ${duration_1}
     ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
     ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
     ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI54a}    referrence_time=${referrence_time}

    #Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    #${status}  Run Keyword And Continue On Failure    Analyse IMS File
    #...    kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}
    ${alarm_status_all}  Evaluate  ${alarm_status} or ${history_alarm_status}
    #${timestart}      convert date    ${timestartTmp}    epoch
    #${timeendTmp}     Get Current Date
    #${timeend}        convert date    ${timeendTmp}     epoch
    #${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    #${duration_time_tmp}    Set Variable   ${kpi_avg}

    ${test_status}	   Set Variable If
    ...    "${alarm_status_all}"=="False" and ${10}<${duration_1}<${KPI54A_MAX}
    ...    pass      fail
    ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
     Run Keyword If    '${test_status}'=='pass'     Run Keyword And Ignore Error
     ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
     Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
     Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
     Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
    Run Keyword And Ignore error    log to console
    ...    Loop${loop}_${timestamp_log} KPI54a is ${test_status} and ${duration_1                         }
    [Teardown]    Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu


PB.PowerOnOff
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${Action}=power_off    ${model}=HBTE
    taf.pdu.Setup Pdu       host=${pdu_ip}    model=${model}
    Run Keyword If    '${Action}'=='power_off'    taf.pdu.power_off    port=${Port_Number}
    ...    ELSE IF   '${Action}'=='power_on'    taf.pdu.power_on    port=${Port_Number}
    ...    ELSE IF   '${Action}'=='both'    Run Keywords    taf.pdu.power_off    port=${Port_Number}    AND    sleep    1s
    ...    AND    taf.pdu.power_on    port=${Port_Number}

##########End keyword for CB006443_HA_04_OAM_KPI_54a_RU_cold_Reset_Time#############

##########Start keyword for CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time#############
DU_WebEM.Get RMOD ID
    [Documentation]  This KW is for get RMOD distname and id list
    ${RMOD_info}=    DU_Rest.get_frm    timeout=30    connection=${connection}
    @{RMOD_id_list}    create list
    FOR    ${elem}    IN    @{RMOD_info}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${RMOD_id_list}   ${elem['id']}
        Set Suite Variable    ${RMOD_id_list}
    END


DU_WebEM.loop reset all RMOD
   [Arguments]    ${RMOD_id_list}    ${connection}=COAM
   ...    ${KPI51_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_MAX']}
   ...    ${KPI51_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_AVG']}
   ...    ${Login_Flag}=${True}   ${Check_Call}=${False}    ${call_loop}=${2}
   ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
   ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
   ...    ${duration_ul}=300    ${duration_dl}=300
   ...    ${reset_times}=2
   log to console      parameter reset_times ${reset_times} is not used
    FOR    ${RMOD}    IN    @{RMOD_id_list}
        RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.loop reset one RMOD
        ...    RMOD_id=${RMOD}     connection=${connection}
        ...    retry_times=${1}    KPI51_MAX=${KPI51_MAX}     KPI51_AVG=${KPI51_AVG}
        ...    Login_Flag=${Login_Flag}    Check_Call=${Check_Call}     call_loop=${call_loop}
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}
        ...    duration_dl=${duration_dl}
    END

DU_WebEM.loop reset one RMOD
    [Arguments]       ${RMOD_id}    ${connection}=COAM    ${retry_times}=1
    ...    ${KPI51_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_MAX']}
    ...    ${KPI51_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_AVG']}
    ...    ${Login_Flag}=${True}     ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    start reset RMOD${RMOD_id} loop${i}
        ${res}     RUN KEYWORD AND CONTINUE ON FAILURE     DU_WebEM.reset one RMOD    loop=${i+1}
        ...    RMOD_id=${RMOD_id}     connection=${connection}     Login_Flag=${Login_Flag}
        ...    KPI51_MAX=${KPI51_MAX}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1]}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    pass    ignore_case=true
        KW.CaseStatusCaluate    duration=${duration_time_tmp}
        ...    max=${KPI51_MAX}
        log to console     Case loop ${i+1} END
        ##Get common info     case_result=${reset_status}    case_name=rf_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${reset_status}'=='pass' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=2
    END
	Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi51a']}
    KW.CaseStatusFinnal    case_avg=${KPI51_AVG}    max_loop=${retry_times}


DU_WebEM.reset one RMOD
    [Arguments]    ${RMOD_id}    ${connection}=COAM    ${loop}=${0}    ${Login_Flag}=${True}
    ...    ${KPI51_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_MAX']}
    oam_kpi_calculations.clear_results
    ims_keywords.check_instance_connection    gnbbbu
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    Run Keyword if    '${Login_Flag}'=='True'    Connect to DU by ADMIN API
    ...    connection_AdminApi=${connection}
    #${timestartTmp}   Get Current Date
    ${reset_RF}     Run Keyword And Return Status
    ...    wait until keyword succeeds   3min   3s    DU_Rest.reset_unit
    ...    dist_name=${RMOD_id['internal']}    timeout=600    connection=${connection}
    #${reset_status_Tmp}     Run Keyword If   '${reset_RF}'=='True'
    #...    Run Keyword And Return Status     Check all cells Should Be On Air
    #...    ELSE    set variable    False
    ${reset_status_Tmp}     Run Keyword And Return Status     Check all cells Should Be On Air
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}_${timestamp_log}
    ...    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    ${status}  Run Keyword And Continue On Failure    Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}
    ${status}  Evaluate  ${alarm_status} or ${history_alarm_status}
    #${timestart}      convert date    ${timestartTmp}    epoch
    #${timeendTmp}     Get Current Date
    #${timeend}        convert date    ${timeendTmp}     epoch
    #${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If
    ...    "${reset_status_Tmp}"=="True" and "${status}"=="False" and ${10}<${duration_time_tmp}<${KPI51_MAX}   pass      fail
    #run keyword and ignore error    COAM_Admin.Logout
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error    WEBUI.Collect snapshot

    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords   Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/*
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    log to console    this reset RMOD loop${loop} is ${reset_status} and KPI is ${duration_time_tmp}
    ims_keywords.instance_disconnect  gnbbbu
    [Return]    ${reset_status}   ${duration_time_tmp}
    [TearDown]    Run Keyword if    '${Login_Flag}'=='True'
    ...    Run Keyword And Ignore Error    DisConnect to DU by ADMIN API    connection_AdminApi=${connection}


#########KW for FA_02############
Check exist session
	@{EM_session_list}    create list
	${sessionlist_EM}    DU_Rest.check_link_status    connection=${connection}
	FOR    ${element}    IN    @{sessionlist_EM}
	    Run keyword if     '${element['stateInfo']['usageState']}'=='Active' and '${element['type']}'=='EM'
    ...    Append to list   ${EM_session_list}    ${element}
    END
    ${session_number}    get length    ${EM_session_list}
    log to console    The number of existed session in DU is ${session_number}
	[Return]    ${session_number}
#########KW for NetAct Case ###########
ssh to netact vm
    [Arguments]    ${service_name}=cmwas   ${alias}=cmwas_ssh
    netact.add_node
    ...   service_name=${service_name}
    ...   hostname=${netact_info['cmwas_ip']}
    ...   username=${netact_info['user']}
    ...   password=${netact_info['password']}
    ...   alias=${alias}
    [Return]  ${alias}

disconnect ssh to netact vm
    [Arguments]    ${service_name}=cmwas   ${alias}=cmwas_ssh
    netact.delete_node
    ...   service_name=${service_name}
    ...   alias=${alias}


Delete integration From NetAct
    [Arguments]   ${mrbts_name}=MRBTS-${global_bts_id}
    ${alias}   ssh to netact vm    service_name=cmwas
    ${deintegration_logs}    netact.deintegrate_mrbts_from_netact
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  alias=${alias}
    [Return]   ${deintegration_logs}
    [Teardown]   disconnect ssh to netact vm   alias=${alias}

Integrate DU To NetAct
    [Arguments]    ${release}=SBTS22R2   ${gnb_index}=0  ${du_index}=0  ${alias}=cmwas_ssh   ${ip_version}=IPv4
    ...  ${security_mode}=No TLS    ${mrbts_name}=MRBTS-${global_bts_id}
   ${alias}   ssh to netact vm    service_name=cmwas
    ${integration_logs}    netact.integrate_mrbts_with_netact
    ...  release=${release}
    ...  mr=${netact_info['mr']}
    ...  mrbts_address=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  presentation_name=PLMN-PLMN/${mrbts_name}
    ...  http_port=8080
    ...  https_port=8443
    ...  ip_version=${ip_version}
    ...  security_mode=${security_mode}
    ...  mrbts_em_address=None
    ...  alias=${alias}
    [Return]  ${integration_logs}
    [Teardown]   disconnect ssh to netact vm   alias=${alias}

#######Check call######
Verify UE send full UDP UL data and full UDP DL data
    [Arguments]    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
	...   ${throuthput_dl}=600M    ${protocol}=udp    ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
	...   ${duration_ul}=300    ${duration_dl}=300
    L3 call start    ue_index=${ue_index}
    Start Capture wireshark log
	power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput= ${throuthput_ul}    duration=${duration_ul}
    ...    iperf_type=via_command    ue_index=${ue_index}    protocol=${protocol}
	power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${throuthput_dl}    duration=${duration_dl}
    ...    iperf_type=via_command    ue_index=${ue_index}    protocol=${protocol}
    sleep   10s
	Check none release
	${res}    Run Keyword And Return Status
	...    Run keyword and continue on failure    check ul and dl throughput of one cell
	...    ultp=${exepected_ul_tp}     ul_throughput=${0}
	...    dltp=${exepected_dl_tp}    NR_cell_id=${NR_cell_id}    dl_throughput=${0}
	${snapshot_file}    Run Keyword If    '${res}'=='${False}'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error    WEBUI.Collect snapshot
   [Teardown]    RUN KEYWORDS
   ...    run keyword and ignore error    power_ue.Stop traffic
   ...    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}    iperf_type=via_command
   ...    AND     run keyword and ignore error    power_ue.Stop traffic
   ...    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}    iperf_type=via_command
   ...    AND     run keyword and ignore error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}


check ul and dl throughput of one cell
    [Arguments]    ${ultp}=${100}    ${dltp}=${500}    ${NR_cell_id}=${15024129}    ${ul_throughput}=${0}
    ...    ${dl_throughput}=${0}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_ul.txt
    ${ul_throughput_tmp}    Run keyword and continue on failure
    ...    Caculate UL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${NR_cell_id}
    ${ul_throughput}=    Evaluate    ${ul_throughput}+${ul_throughput_tmp}
    Log to console    ul_throughput = ${ul_throughput}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_dl.txt
    ${dl_throughput_tmp}    Run keyword and continue on failure
    ...    Caculate DL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${NR_cell_id}
    ${dl_throughput}=    Evaluate    ${dl_throughput}+${dl_throughput_tmp}
    Log to console    dl_throughput = ${dl_throughput}
    Run keyword and continue on failure    should be true    ${ul_throughput} > ${ultp}
    Run keyword and continue on failure    should be true    ${dl_throughput} > ${dltp}
