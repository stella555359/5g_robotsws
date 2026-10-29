*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author
...    Deprecated case removed by civen.chen

#
#Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#
#Force Tags
#...      CRT             #Tag Item
#...      RAN_PZ_HAZ_1             #Competence Area
#...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
#...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]
#
#Test Timeout    600 minutes
#
#Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
#Resource          ../../T02/Common_Case/common_resource.robot
#
#
#
#*** Test Cases ***
#Verify
#    [Tags]    CRT
#    [Documentation]
#    ...    Author: mengli.yang@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,mengli.yang@nokia-sbell.com, draft
#    [Setup]    Case Precondition
#    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
#    Start Call For UE        ue_index=0    direction=dl
#    Start Emergency Call For UE    ue_index=0
#    Start VONR Call For UE    ue_index=0    capabilities=huawei1
#    Start Collect Wireshark Log    NE=vDU
#    Stop Wireshark Log    NE=vDU
#    Check Wireshark Log   input_file=${wireshark_local_file_path_vCU}
#    Modify Parameters By Delta Plan    ne=vDU
#    ...                                parameter=actCDrx
#    ...                                value=true
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    Block Cell From vDU    cell_id=all
#    Unblock Cell From vDU    cell_id=all
#    Adjust PA Signal To Trigger HO With Stage
#    Reset vDU With Check Cell On Air    need_check_on_air=${True}
#    Reset vCU With Check Cell On Air    gnb_index=0
#    ${vcu_trace_id}    Start Capture Log By Dcap    dcap_ip=${dcap_server}    alias=dcap    ne_type=vcu
#    ...                                             vcu_custom_profile=${vcu_profile}    gnb_index=0    vdu_index=0
#    Stop Trace Log By Dcap    ne_type=vcu    gnb_index=0    vdu_index=0
#    ${vdu_zip_file_path}    Save Trace Log By Dcap    ne_type=vdu    gnb_index=0    vdu_index=0
#    Start Bip Log In vDU
#    Check Bip Log In vDU    name=l2hi
#    Check Counter
#    [Teardown]    Case Postcondition
#
#*** Keywords ***
#Adjust PA Signal To Trigger HO With Stage
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    Start to Trigger intra Fre intra gnb based Handover
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[2]}=${index}
#        ...                                             ${attenuation_channels[3]}=${index}
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[0]}=${target_cell_index}
#        ...                                             ${attenuation_channels[1]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#    END
#    Log to console    Stop to Trigger intra Fre intra gnb based Handover
#
#Check Wireshark Log
#    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
#    ${filter_list} =    Create list    f1ap.service_state == 0
#    ${expect_message}=    Create list    UEContextReleaseCommand
#    ${filter_length}    get length    ${filter_list}
#    FOR    ${index}    IN RANGE    ${filter_length}
#        ${result} =    Analysis Wireshark Log    input_file=${input_file}
#        ...                                      filter_expression=${filter_list[${index}]}
#        should contain    ${result}    ${expect_message[${index}]}
#    END
#
#
#Check Counter
#    Sleep    360s    reason=wait generate counter
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID_list}[0]/NRBTS-${MRBTS_ID_list}[0]
#    &{type1_counter_dict}    create dictionary    counterId=MXXXXXCXXXXX,MXXXXXCXXXXX
#    ...                                           dimDN=${dim_dn}
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=MXXXXXCXXXXX,MXXXXXCXXXXX
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}
#    FOR    ${counter}    IN    @{counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
#
#Check Any One Value In Multiple Counters
#    Sleep    360s    reason=wait generate counter
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID_list}[0]/NRBTS-${MRBTS_ID_list}[0]
#    &{type1_counter_dict}    create dictionary    counterId=MXXXXXCXXXXX,MXXXXXCXXXXX
#    ...                                           dimDN=${dim_dn}
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=MXXXXXCXXXXX,MXXXXXCXXXXX
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}
#    FOR    ${counter}    IN    @{counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#        Run Keyword If    '${ne}'=='vDU'     Check Any One Value In Multiple Counters In vDU
#        ...                                                         counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Any One Value In Multiple Counters In vCU
#        ...                                                         counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
