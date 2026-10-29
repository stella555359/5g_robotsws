*** Settings ***
Documentation     UE common keyword for normal L3 call, support to control Multi UE also.
...               Please do not modify the file without notification to author
...               Author: Civen Chen
...               Contact: civen.chen@nokia-sbell.com

Resource          ./UE/power_ue/UEs/qct_dx50.robot
Resource          ./UE/power_ue/UEs/qualcomm_ue.robot
Resource          ./UE/power_ue/UEs/SMAwave_UE.robot
Resource          ./UE/power_ue/power_ue.robot

*** Variables ***
${not_used}


*** Keywords ***
#########################################################################
##                        qualcomm ue special code                     ##
#########################################################################

Qualcomm L3 call
    [Arguments]    ${DL_Tput}    ${UL_Tput}    ${dl_deviation}    ${RAT}    ${PMcounter_refresh_period}=${PM_reporting_interval}    ${ue_index}=0
    Log to console    \n[INFO]:Qualcomm L3 call starting ...
    Qualcomm UE Pre-condition
    Qualcomm UE Attach    ${RAT}
    ${pci}    ${nci}    Get Serving Cell Id    ${ue_index}
    Run Keyword If    '${RAT.upper()}'=='4G'    Log to console    \n[INFO]:The UE attached phyical cellid is ${pci}
    Run Keyword If    '${RAT.upper()}'=='5G'    Log to console    \n[INFO]:The UE attached NR Cell Id is ${nci}
    ${ue_ip}=    Get Ue Info    UE_${ue_index}    IP
    Log to console    \n[INFO]:The UE ip is ${ue_ip}
    Start UL Traffic Via Iperf From Andriod UE    ${UL_Tput}
    Start DL Traffic Via Iperf on Iperf server    ${DL_Tput}    ${ue_ip}
    ${DL_Target_Tput}    Evaluate    int(${DL_Tput.strip('M')})*(100-(int(${dl_deviation.strip('%')})))/100
    ${UL_Target_Tput}    Evaluate    int(${UL_Tput.strip('M')})*(100-(int(${dl_deviation.strip('%')})))/100
    ${DL_Target_Tput_4G}    Run Keyword If    '${rat.upper()}'=='4G'    Evaluate    ${DL_Target_Tput}*1024
    ${UL_Target_Tput_4G}    Run Keyword If    '${rat.upper()}'=='4G'    Evaluate    ${UL_Target_Tput}*1024
    Run Keyword If    '${RAT.upper()}'=='4G'    Verify DL and UL throughput    ${PMcounter_refresh_period}    ${DL_Target_Tput_4G}
    ...    ${UL_Target_Tput_4G}    ${pci}
    Run Keyword If    '${RAT.upper()}'=='5G'    Run Keyword And Continue On Failure    qct_dx50.Check throughput    direction=dl
    ...    throughput=${DL_Target_Tput}    ue_index=${ue_index}    cellid=${nci}
    Run Keyword If    '${RAT.upper()}'=='5G'    Run Keyword And Continue On Failure    qct_dx50.Check throughput    direction=ul
    ...    throughput=${UL_Target_Tput}    ue_index=${ue_index}    cellid=${nci}
    Log to console    \n[INFO]:Qualcomm ${RAT} L3 call is completed!
    [Teardown]    Run Keywords    Stop UL Traffic on Andriod UE    AND    Stop DL Traffic on Iperf server
    ...    AND    Ue Detach By Index

Get hostname
    ${rc}    ${output}    Run And Return Rc And Output    hostname
    Should Be True    ${rc}==0    Get hostname failed
    ${tl_name}=    Run Keyword If    '-' in '${output}'    Replace String    ${output}    -    _
    log to console    \nINFO:the hostname is ${tl_name}
    [Return]    ${tl_name}

#########################################################################
##                        SMAwave ue special code                      ##
#########################################################################

SMAwave L3 call
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=41    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=1000    ${protocol}=udp    ${PMcounter_refresh_period}=${PM_reporting_interval}
    SMAwave UE attach    ${rat}    ${cell_id}    ${band}    ${specific_UE_index}
    ${call_duration}    Evaluate    ${duration}+300
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${call_duration}
    ${call_duration}    Evaluate    ${duration}//300
    Run Keyword If    ${duration}<=300    Sleep    ${duration}    ELSE    Sleep    ${call_duration}
    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${PMcounter_refresh_period}
    [Teardown]    SMAwave Stop Data And Detach

SMAwave UE attach
    [Arguments]    ${rat}    ${cell_id}=${None}    ${band}=41    ${specific_UE_index}=${EMPTY}
    [Documentation]    To perform CPE attach by Band Lock or EARFCN Lock.
    ...    | Arguments | Mandatory | Default | Description |
    ...    | rat | Yes | NA | rat should be set: 5G / 4G. |
    ...    | cell_id | No | None | if rat=5G and cell_id=None, or cell_id is not found in BTS, random cell will be selected. |
    ...    | band | No | 41 | if rat=4G, UE attach will be with Band Lock. |
    ...    | specific_UE_index | No | EMPTY | if EMPTY, all ue defined in tl configuration will be selected and perform to attach. |

    ${arfcnSsbPbch}    ${cellId_list}    Get Runtime arfcnSsbPbch    cell_Id=${cell_id}    rat=${rat}
    Set Test Variable    ${arfcnSsbPbch}
    Set Test Variable    ${cellId_list}
    Should Be True    '${rat.upper()}' in ('5G', '4G')    [ERROR]rat ${rat} should be 4G or 5G.
    Set UE Variables
    ${5G_ue_index_list}    Run keyword If    '${rat.upper()}'=='5G'    Get Dictionary Keys    ${5G_UEPC_DICT}
    ${4G_ue_index_list}    Run keyword If    '${rat.upper()}'=='4G'    Get Dictionary Keys    ${4G_UEPC_DICT}
    ${is_5GUE}    Run Keyword And Return Status    Should Not Be Empty    ${5G_ue_index_list}
    ${ue_index_list_1}    Set Variable If    ${is_5GUE}    ${5G_ue_index_list}    ${4G_ue_index_list}
    @{ue_index_list_2}    Run Keyword If    '${specific_UE_index}'!='${EMPTY}'    Create List    ${specific_UE_index}
    ${is_SpecificUE}    Run Keyword And Return Status    Should Not Be Empty    ${ue_index_list_2}
    ${ue_list}    Set Variable If    ${is_SpecificUE}    ${ue_index_list_2}    ${ue_index_list_1}
    ${isNone}    _It is None    ${ue_list}
    Run Keyword If    ${isNone}    Fail    msg=[ ERROR ] ${rat} UE is [ ${ue_list} ]: | 5GUE = ${5G_ue_index_list} | 4GUE = ${4G_ue_index_list} |.
    Set Test Variable    ${ue_list}
    FOR    ${ue_index}    IN    @{ue_list}
        SMAwave UE attach Succeed    ue_index=${ue_index}    rat=${rat}    band=${band}    arfcn=${arfcnSsbPbch}
    END

SMAwave Start Data Traffic
    [Arguments]    ${dl_tput}    ${ul_tput}    ${protocol}=udp    ${duration}=1000
    ${isString}    Run Keyword And Return Status    Should Be String    ${duration}
    ${duration}    Set Variable If    ${isString}    ${duration.strip('s')}    ${duration}
    FOR    ${ue_index}    IN    @{ue_list}
        ${smawave_ue_addr}    Get From Dictionary    ${sma_ue_addr_dict}    ${ue_index}
        Set Test Variable    ${smawave_ue_addr}
        SMAwave Start DL Iperf Process    ${ue_index}    ${protocol}    ${dl_tput}    ${duration}
        SMAwave Start UL Iperf Process    ${ue_index}    ${protocol}    ${ul_tput}    ${duration}
    END

SMAwave Verify throughput for DL and UL
    [Arguments]    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${PMcounter_refresh_period}=${PM_reporting_interval}
    Should Be True    '${rat.upper()}' in ('5G', '4G')    [ERROR]rat ${rat} should be 4G or 5G.
    ${DL_Target_Tput}    Evaluate    int(${dl_tput.strip('M')})*(100-(int(${dl_deviation.strip('%')})))/100
    ${UL_Target_Tput}    Evaluate    int(${ul_tput.strip('M')})*(100-(int(${dl_deviation.strip('%')})))/100
    ${DL_Target_Tput_4G}    Run Keyword If    '${rat.upper()}'=='4G'    Evaluate    ${DL_Target_Tput}*1024
    ${UL_Target_Tput_4G}    Run Keyword If    '${rat.upper()}'=='4G'    Evaluate    ${UL_Target_Tput}*1024
    FOR    ${ue_index}    IN    @{ue_list}
        Verify Attach To Which Cell    ${ue_index}
        ${global_cellid}    Run Keyword If    '${rat.upper()}'=='4G'    common_resource_ue._Get global cell id via pci from UE
        Run Keyword If    '${rat.upper()}'=='5G'    Run Keyword And Continue On Failure    qct_dx50.Check throughput    direction=dl
        ...    throughput=${DL_Target_Tput}    ue_index=${ue_index}    cellid=${attached_cell_info}[cell_details][0][cell_id]
        Run Keyword If    '${rat.upper()}'=='5G'    Run Keyword And Continue On Failure    qct_dx50.Check throughput    direction=ul
        ...    throughput=${UL_Target_Tput}    ue_index=${ue_index}    cellid=${attached_cell_info}[cell_details][0][cell_id]
        Run Keyword If    '${rat.upper()}'=='4G'    common_resource_bts.Verify DL and UL throughput    ${PMcounter_refresh_period}
        ...    ${DL_Target_Tput_4G}    ${UL_Target_Tput_4G}    ${global_cellid}
    END

SMAwave Stop Data And Detach
    FOR    ${ue_index}    IN    @{ue_list}
        Run Keyword And Ignore Error    SMAwave detach    ${ue_index}
        Run Keyword And Ignore Error    SMAwave and APPserver Stop Iperf Process    ${ue_index}
    END

_Get global cell id via pci from UE
    ${cell_value_dict}=    Get physicalCellId From LTE Cells
    ${lte_global_cellid_list}      Get Dictionary Keys      ${cell_value_dict}    sort_keys=False
    ${lte_physical_cellid_list}    Get Dictionary Values    ${cell_value_dict}    sort_keys=False
    ${length}    get length    ${lte_physical_cellid_list}
    FOR    ${index}    IN RANGE    ${length}
        ${lte_global_cellid}    Run Keyword If    ${lte_physical_cellid_list[${index}]}==${attached_cell_info}[cell_details][0][pci]
        ...    Set Variable    ${lte_global_cellid_list[${index}]}
        Exit For Loop If    ${lte_physical_cellid_list[${index}]}==${attached_cell_info}[cell_details][0][pci]
    END
    log to console    \nINFO:globalCellId of attached cell is ${lte_global_cellid}
    [Return]    ${lte_global_cellid}

#########################################################################
##                   run ue detach when case failed                    ##
#########################################################################
Ue detach when case failed
    ${ue_status}    run keyword and return status    should contain    ${TEST TAGS}    QUALCOMM_UE
    run keyword if    ${ue_status}==True    Qualcomm ue stop data transfer and detach    ${UE_alias}    ${DL_DT_Name}    ${UL_DT_Name}
    ...    ELSE    UE detach    UE1
