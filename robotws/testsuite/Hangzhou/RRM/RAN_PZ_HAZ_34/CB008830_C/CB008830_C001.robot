*** Settings ***
Suite Setup       Common Suite Setup And Setup BTS Env For CB008830
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup For CB008830
Test Teardown     Common Test Teardown For CB008830
Force Tags    5G_RAN    VRF3_7    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/UEs/Dingli_common_keywords.robot

*** Variables ***
${tl_info}    7_5_UTE5G402T2459

${DEBUG}                      ${True}
${EMIL_FLAG}                  ${True}
${SYSCOM_FLAG}                ${True}
${GNB_BIP_FLAG}               ${True}
${TTITRACE_FLAG}              ${False}
${AUTO_ANALYSIS_FLAG}         ${False}
${RESOURCES_LEAKAGE_FLAG}     ${False}
${RECREATE_WIRESHARK_FLAG}    ${False}
${SNAPSHOT_FLAG}              pass:False,fail:True

#UE Attach CELL4
${Attach_Cell_PCI}    528
@{CELLs_Ports}    @{CELL1_Ports}    @{CELL2_Ports}    @{CELL3_Ports}    @{CELL4_Ports}
@{CELL1_Ports}    ${7}    ${8}    ${15}    ${16}
@{CELL2_Ports}    ${3}
@{CELL3_Ports}    ${4}
#Due to PA no TA API, need manual set PA value for UE attach Cell4, and cannot trigger RRE or HO.
@{CELL4_Ports}    ${5}    ${6}
@{PA_Def_Value}    ${120}    ${120}    ${120}    ${120}    ${120}    ${120}    ${10}    ${10}

#Dingli config, need make sure cid1 for ims and cid2 for stdata2
${APN1_AT}           AT+CGDCONT=1,"IPV4V6","stdata2"
${APN2_AT}           AT+CGDCONT=2,"IPV4V6","ims"
${Query_APN_AT}      AT+CGDCONT?
${mPDU_AT}           at$qcrmcall=1,1    #auto call, activate stdata2
${En_IMS_AT}         AT+QCFG="ims",1
#AT+CGACT=1,2        #Format: <0：deactivated，1：activated>,<cid>
${Setup_VoNR_AT}     AT+CGACT=1,2    #active ims
${REL_VoNR_AT}       AT+CGACT=0,2    #deactive ims

#Wireshark filter
${CELL4_Config}      (nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA == 1 && nr-rrc.scramblingID0 == 528 && nr-rrc.dmrs_AdditionalPosition == 1)
${Attach_type1}      (nr-rrc.rrcSetupRequest_element && ${CELL4_Config}) && !(nr-rrc.dmrs_Type == 0)
${Reconfig_DMRS}     (nr-rrc.rrcReconfiguration_element && ${CELL4_Config})
${Reconfig_type1}    ${Reconfig_DMRS} && !(nr-rrc.dmrs_Type == 0)
${Reconfig_type2}    ${Reconfig_DMRS} && (nr-rrc.dmrs_Type == 0)

*** Test Cases ***
CB008830-ST-C001_Verify_Dynamic_switch_between_type_1_and_type_2_due_to_VoNR
    [Documentation]
    ...    1. The purpose of this test case is
    ...    2. Test Case Steps:
    [Tags]    QC_47179    C001
    Step0 UE Prepare
    Step1 UE Attach
    Step2 AT Make First VoNR Call
    Step3 AT End First VoNR Call
    Step4 AT Release First VoNR Session
    Check Wireshark For C001

    #OnlineParamChange    NRCELL-1:dlDmrsType=Type1
    #Step5 AT Setup Second VoNR Session
    #Step6 AT Make Second VoNR Call
    #Step7 UE Trigger RRE To Origin Cell
    #Step8 AT Release Second VoNR Session

*** Keywords ***
Common Suite Setup And Setup BTS Env For CB008830
    Setup BTS env and set keyword prority
    #Prepare PA And Set Default Value

Common Test Setup For CB008830
    Common Test Setup And Start To Capture Logs
    OnlineParamChange    ${PARAMS_CB008830}
    Set Test Variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}

Common Test Teardown For CB008830
    Run Keyword And Ignore Error    DingLi_Client.Detach
    OnlineParamChange    ${Post_Config}
    Common Test Teardown With Scout

Prepare PA And Set Default Value
    BuiltIn.Log    Prepare PA And Set Default Value...    console=${True}
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    Adjust Cells HBTE Attenuation Value To Default

Adjust Cells HBTE Attenuation Value To Default
    [Arguments]    ${port_value_list}=${PA_Def_Value}
    ${numberOfPorts}    Get Length    ${CELLs_Ports}
    FOR    ${index}    IN RANGE    ${numberOfPorts}
        attenuator.set_attenuation     port=${CELLs_Ports[${index}]}    value=${port_value_list[${index}]}
        attenuator.read_attenuation    port=${CELLs_Ports[${index}]}
        BuiltIn.Log    Attenuator Set Port ${CELLs_Ports[${index}]} Value ${port_value_list[${index}]}...    console=${True}
    END

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Run Keyword And Ignore Error    Cells Should Be OnAir

Step0 UE Prepare
    [Documentation]    Prepare UE for L3 call test.
    ...    :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    [Arguments]    ${ue_index}=${0}    ${alias}=pioneer    ${ue_alias}=multiUE
    ...    ${ue_host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${until_timeout}=${300}    ${port}=30999
    BuiltIn.Log    Step0 UE Prepare...    console=${True}
    client.setup_service    host=${ue_host}    port=${port}    ssh_username=${cpc_username}    ssh_password=${cpc_password}    alias=${alias}
    Run Keyword And Ignore Error    client.stoplog      service=${alias}
    @{UEs_info}    client.prepare_ues    service=${alias}
    ${imei_list}    create list
    FOR    ${item}    IN    @{UEs_info}
        Append To List     ${imei_list}     ${item}[imei]
    END
    Remove values From List    ${imei_list}    ERROR
    Set Suite Variable    ${imei_list}
    ${ue_num}=    get length    ${imei_list}
    ${uegroup}    create list
    FOR    ${i}    IN RANGE     ${ue_num}
        client.require_ue    imei=${imei_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
        Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Suite Variable    ${uegroup}
    Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${until_timeout}
    Sleep    10s
    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${until_timeout}
    Sleep    1min
    DingLi AT APN Setting

Step1 UE Attach
    [Arguments]    ${ue_index}=${0}
    BuiltIn.Log    Step1 UE Attach...    console=${True}
    Start To Capture Wireshark Log    1_UE_Attach
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach    ues_index=${ue_index}
    Sleep    3s
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${ue_index}    expect_pci=${Attach_Cell_PCI}
    Run Keyword And Ignore Error    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    [Teardown]    Stop Capture Wireshark Log

DingLi_Client.UE Attach
    [Arguments]    ${ues_index}=${${0}}    ${until_timeout}=${300}    ${apn}=stdata2    ${UE_mode}=5G_SA
    Sleep    10s
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        log to console    Start To Attach ${uegroup}[${index}]
        ${status}    ${attach_status}    Run Keyword And Ignore Error    DingLi_Client.Get MultiUE attach status
        ...    ue=${uegroup}[${index}]    until_timeout=${until_timeout}
        Sleep    3s
        run keyword if    '${attach_status}' == 'Attached'    Run Keywords
        ...    Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${300}    AND
        ...    Sleep    8s    AND
        ...    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${300}    AND
        ...    Sleep    1min    AND
        ...    Run Keyword And Ignore Error    client.detach    ue=${uegroup}[${index}]    until_timeout=${300}    withpdu=1
        Sleep    5s
        run keyword if    '${UE_mode}' == '5G_SA'
        ...    Run Keyword And Ignore Error    client.sendat    command=${lock_band_atcommand}    until_timeout=${until_timeout}
        ...    ue=${uegroup}[${index}]
        Sleep    15s
        Run Keyword And Ignore Error    client.sendat    command=${disable_auto_connect_atcommand}
        ...    until_timeout=${until_timeout}    ue=${uegroup}[${index}]
        Sleep    3s
        ${status}    ${attach_status}    Run Keyword And Ignore Error    DingLi_Client.Get MultiUE attach status
        ...    ue=${uegroup}[${index}]    until_timeout=${until_timeout}
        Sleep    5s
        log to console    ---UE Status Is ${status} Before Do Attach---
        Run Keyword And Ignore Error    client.attach    uemode=${UE_mode}     ue=${uegroup}[${index}]
        ...    until_timeout=${until_timeout}
        Sleep    1min
        ${status}    ${attach_status}    Run Keyword And Ignore Error    DingLi_Client.Get MultiUE attach status
        ...    ue=${uegroup}[${index}]    until_timeout=${until_timeout}
        Sleep    3s
    END
    #Annotations due to this Env cannot get IP addr, un-annotations below if need make trf
    FOR    ${index}    IN    @{ues_index}
        log to console    Start To Get UE IP to ${uegroup}[${index}]
        Run Keyword And Continue On Failure    client.sendat    command=${mPDU_AT}    until_timeout=${until_timeout}    ue=${uegroup}[${index}]
        Sleep    3s
        ${upd_info}    Run Keyword And Continue On Failure   client.getpduinfo    until_timeout=${until_timeout}
        ...    apn=${apn}     ue=${uegroup}[${index}]
        #should be true    ${upd_info}[Param][State]==0
        Run Keyword And Ignore Error    Set Test variable    ${UE${index}_IP}    ${upd_info}[Param][IP]
        Sleep    3s
        Run Keyword And Continue On Failure    client.sendat    command=at+cgpaddr    until_timeout=${until_timeout}    ue=${uegroup}[${index}]
        Sleep    3s
        log to console    ${uegroup}[${index}] IP Is: ${upd_info}[Param][IP]
    END
    [Return]    ${True}

DingLi UE Start Trf And Check Tput
    [Arguments]    ${ue_index}=${0}    ${cellid}=2    ${ue_type}=huawei_sigspark    ${check_source}=aasyslog
    ...    ${ul_throughput}=5000    ${dl_throughput}=10M    ${expect_ul_tput}=5    ${expect_dl_tput}=10
    ...    ${is_do_require_ue}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0.3    ${duration}=180
    BuiltIn.Log    DingLi UE Start Trf And Check Tput...    console=${True}
    DingLi_Client.Start Data Transfer    ues_index=${ue_index}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    @{direction_component_list}    Create List    UL    DL
    Check Tput With Power UE    cellid=${cellid}    ue_type=${ue_type}    check_source=${check_source}
    ...    expect_dl_tput=${expect_dl_tput}    expect_ul_tput=${expect_ul_tput}
    ...    duration=${duration}    direction_component_list=@{direction_component_list}    target_avg_percent=0.95    min_percent=0.85
    [Teardown]    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer

DingLi AT APN Setting
    [Arguments]    ${ue_index}=${0}    ${until_timeout}=${300}
    client.sendat    command=${APN1_AT}    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    client.sendat    command=${APN2_AT}    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    client.sendat    command=${Query_APN_AT}    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s

Step2 AT Make First VoNR Call
    [Arguments]    ${ue_index}=${0}    ${number}=6688    ${until_timeout}=${300}
    BuiltIn.Log    Step2 AT Make First VoNR Call...    console=${True}
    Start To Capture Wireshark Log    2_Make_VoNR1
    client.sendat    command=${En_IMS_AT}    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    client.sendat    command=ATD${number};    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    [Teardown]    Stop Capture Wireshark Log

Step3 AT End First VoNR Call
    [Arguments]    ${ue_index}=${0}    ${until_timeout}=${300}
    BuiltIn.Log    Step3 AT End VoNR Call...    console=${True}
    Start To Capture Wireshark Log    3_End_VoNR1
    client.sendat    command=ATH    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    [Teardown]    Stop Capture Wireshark Log

Step4 AT Release First VoNR Session
    [Arguments]    ${ue_index}=${0}    ${until_timeout}=${300}
    BuiltIn.Log    Step4 AT Release VoNR...    console=${True}
    Start To Capture Wireshark Log    4_Rel_VoNR1
    client.sendat    command=${REL_VoNR_AT}    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    [Teardown]    Stop Capture Wireshark Log

Step5 AT Setup Second VoNR Session
    [Arguments]    ${ue_index}=${0}    ${until_timeout}=${300}
    BuiltIn.Log    Step5 AT Setup VoNR...    console=${True}
    Start To Capture Wireshark Log    5_Setup_VoNR2_PDU_5QI5
    client.sendat    command=${Setup_VoNR_AT}    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    [Teardown]    Stop Capture Wireshark Log

Step6 AT Make Second VoNR Call
    [Arguments]    ${ue_index}=${0}    ${number}=6688    ${until_timeout}=${300}
    BuiltIn.Log    Step6 AT Make Second VoNR Call...    console=${True}
    Start To Capture Wireshark Log    6_Make_VoNR2
    client.sendat    command=ATD${number};    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    [Teardown]    Stop Capture Wireshark Log

Step7 UE Trigger RRE To Origin Cell
    [Arguments]    ${attach_cell}=${1}
    BuiltIn.Log    Step7 UE trigger RRE To Origin Cell...    console=${True}
    Start To Capture Wireshark Log    7_RRE
    Adjust Attach Cell HBTE Attenuation Value To Max And Recover Immediately    attach_cell=${attach_cell}
    Sleep    10s
    [Teardown]    Stop Capture Wireshark Log

Step8 AT Release Second VoNR Session
    [Arguments]    ${ue_index}=${0}    ${until_timeout}=${300}
    BuiltIn.Log    Step8 AT Release VoNR...    console=${True}
    Start To Capture Wireshark Log    8_Rel_VoNR2_PDU
    client.sendat    command=${REL_VoNR_AT}    until_timeout=${until_timeout}    ue=multiUE${ue_index}
    Sleep    3s
    [Teardown]    Stop Capture Wireshark Log

Adjust Attach Cell HBTE Attenuation Value To Max And Recover Immediately
    BuiltIn.Log    Adjust Attach Cell HBTE Attenuation Value To Max And Recover Immediately...    console=${True}
    [Arguments]    ${attach_cell}=${1}
    Adjust Cell HBTE Attenuation Value    cellid=${attach_cell}    port_value=${120}
    Sleep    3s
    Adjust Cell HBTE Attenuation Value    cellid=${attach_cell}    port_value=${10}

Adjust Cell HBTE Attenuation Value
    [Arguments]    ${cellid}    ${port_value}
    FOR    ${port}    IN    @{CELL${cellid}_Ports}
        attenuator.set_attenuation     port=${port}    value=${port_value}
        attenuator.read_attenuation    port=${port}
    END

Check Wireshark For C001
    ${Count}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}/wireshark_1_UE_Attach.pcap    ${Attach_type1}
    Should Be True    ${Count}>=1
    ${Count}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}/wireshark_1_UE_Attach.pcap    ${Reconfig_type2}
    Should Be True    ${Count}>=1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_2_Make_VoNR1.pcap    ${Reconfig_type1} @1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_3_End_VoNR1.pcap    ${Reconfig_type2} @1
    Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_4_Rel_VoNR1.pcap    ${Reconfig_DMRS} @0
    #Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_5_Setup_VoNR2_PDU_5QI5.pcap    ${Reconfig_DMRS} @0
    #Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_6_Make_VoNR2.pcap    ${Cell1_type1}
    #Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_7_RRE.pcap    ${Cell1_type1}
    #Check Num Of Wireshark As Excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_8_Rel_VoNR2_PDU.pcap    ${Cell1_type1}





