*** Settings ***
Documentation
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    27.07.2020, shouxiang.jiao@nokia-sbell.com, add script
    ...    15.7.2022, luofei.tu@nokia-sbell.com, optimize
    ...    06.11.2023, ella.fang@nokia-sbell.com, add the traffic verify after recovery
    ...    15.10.2024, jakub.kokoszka@nokia.com, adapt to new team TL
    ...    Test with UE: Before starting the test, log in to the UE PC 10.44.72.115.
    ...    Command to run: run_ue_proxy -u android -p 5000

Library     BuiltIn
Library     DateTime
Library     Collections
Library     taf.ul.verify_snapshot    WITH NAME    snapshot
Resource    taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource    ../../Resources/common_keywords.robot
Resource    ../../Resources/common_logging.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource    taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Library     utils.py
Library     taf.hw.fhgw.cli    WITH NAME    fhgw_cli
Library     taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library     taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library     taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library     taf.config.scf                        WITH NAME    scf
Library     taf.hw.fhgw.cli                       WITH NAME    issh
Library     taf.ue.interface.ue                   WITH NAME    ute_ue
Library     String
Library     taf.rfrl.cbts.utilities.generic_utils
Resource    taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Library     re
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.collectors.kubernetes             WITH NAME    kubelog_collect
Library     taf.collectors.core                   WITH NAME    core_collect
Library     taf.transport.ssh.interface.ssh       WITH NAME    tafssh
Resource    ../../Resources/unpacking.robot
Resource    ../../Resources/verdicts.robot


*** Variables ***
${VCU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
${VCU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$
${TIMEOUT}        1200
${INTERVAL}       30

*** Keywords ***
OAM__CLOUD_Master_SLD_Pod_Recovery_After_Pod_Failure_CB007467_E
    Step 0: Precondition
    Step 1: Cell Should Be OnAir
    Step 2: Kill Master SDL Pod
    Step 3: Cell Should Be OnAir
#    Step 3: Make UE call

Step 0: Precondition
     ${connection_alias}=    common_vcu.Connect To vCU K8s Master Node With Tenant    0    3600
     ${cmd_output}=   issh.Execute    oc get pods -n ${CRAN_VCU}   alias=${connection_alias}
     Run Keyword If    'po-' in '''${cmd_output}'''     Set Test Variable    ${pod_prefix}    po
     Run Keyword If    'ute-' in '''${cmd_output}'''    Set Test Variable    ${pod_prefix}    ute
     Should Not Be Empty    ${pod_prefix}    Pod prefix not detected in oc get pods output
     common_keywords.Disconnect Interactive Connection    alias=${connection_alias}

Step 2: Kill Master SDL Pod
    Log  \nStep 2: Kill Master SDL Pod  console=${True}

    Kill Master RCPSDL Pod Should Be Sucessful

Step ${n}: Cell Should Be OnAir
    Log  \nStep ${n}: Cell Should Be OnAir  console=${True}
    aic_common_resources_new.Rest Login on vDU
    Wait For Cells To Be OnAir

Step 3: Make UE call
    Log  \nStep 3: Make UE call  console=${True}

    Loop Each Cell To Make A UE Call   direction=DL   transfer_duration=100s   throughput=100Mbits/sec   expected_tput=5

#######################

Loop Each Cell To Make A UE Call
    [Arguments]   ${direction}=DL  ${transfer_duration}=100s  ${throughput}=80Mbits/sec   ${expected_tput}=5   ${ue_index}=${0}
    ...  ${protocol}=udp  ${packet_size}=1024   ${interval}=20s   ${gnb_index}=0    ${vdu_index}=0
    ...  ${log_collection_duration}=60s  ${reboot_ue}=${False}   ${detach_ue}=${False}  ${loop_each_cell}=${False}  ${stop_data_when_return}=${True}
    ...  ${throughput_DL}=${EMPTY}   ${expected_tput_DL}=${EMPTY}   ${throughput_UL}=${EMPTY}   ${expected_tput_UL}=${EMPTY}
    ...  ${expected_max_tput}=${EMPTY}  ${reattach_ue}=${False}
    [Teardown]  Run Keyword And Ignore Error   Run Keyword If   "${detach_ue}"=="${True}" and "${loop_each_cell}"=="${True}"
     ...   Ue Detach For All UEs   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    [Documentation]   it supports both 'loop' or 'not loop' each cell to make call.
    ...   If you want to loop each cell to make call, please use loop_each_cell=${True}
    ...
    ...   We can use this KW anywhere, need not any UE related operation KW before use it.
    ...
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.8.30, chris.l.cao@nokia-sbell.com, initialize
    ...  2023.10.18, chris.l.cao@nokia-sbell.com, support this KW can be called multiple times in one case
    ...  10.11.2023, chris.l.cao@nokia-sbell.com, add validation: ${duration}>=${log_collection_duration}+${interval}+20s
    ...           because we will discard some time(${interval}) at the beginning of call and give some margin(20s) while we calculate through_put
    ...  15.11.2023, chris.l.cao@nokia-sbell.com, support direction=DLUL bi-direction
	...  30.11.2023, chris.l.cao@nokia-sbell.com, add expected_max_tput
	...  4.12.2023, chris.l.cao@nokia-sbell.com, support loop_each_cell=${True}, that is to loop each cell to make a call
    ...
    ...   | Input Parameters   | Man. | Description |
    ...   | ${direction}}     | Yes  | the direction of Data Transfer, DL or UL or DLUL is supported, DLUL means bi-direction with DL and UL |
    ...   |                   |   | when it's DL or UL, ${throughput} and ${expected_tput} will be used |
    ...   |                   |   | when it's DLUL, ${throughput_DL}, ${expected_tput_DL}, ${throughput_UL} and ${expected_tput_UL} will be used |
    ...   |                   |   | default is DL |
    ...   | ${transfer_duration}  | Yes | the duration for data transmission, such as 2min |
    ...   | ${throughput}    | no | it is used when direction is DL or UL, bandwidth to send at in bits/sec or packets per second, |
    ...   |                  |    | such as 80Mbits/sec, default is 80Mbits/sec |
    ...   | ${expected_tput} | no | it is used when direction is DL or UL, the expected t-put(Mbits/sec), such as 50, default is 5 |
    ...   | ${expected_max_tput} | no | it is used when direction is DL or UL, the max expected t-put(Mbits/sec), such as 50, |
    ...   |                      |    | default is ${EMPTY}, it means we do not check maximum Tput |
    ...   | ${throughput_DL}  | no | it is used when direction is DLUL, DL bandwidth to send at in bits/sec or packets per second, |
    ...   |                   |    | such as 80Mbits/sec, default is ${EMPTY}  |
    ...   | ${expected_tput_DL} | Yes | it is used when direction is DLUL, the expected DL t-put(Mbits/sec), such as 50, |
    ...   |                   |    | default is ${EMPTY} |
    ...   | ${throughput_UL}  | no | it is used when direction is DLUL, DL bandwidth to send at in bits/sec or packets per second, |
    ...   |                   |    | such as 80Mbits/sec, default is ${EMPTY}  |
    ...   | ${expected_tput_UL} | Yes | it is used when direction is DLUL, the expected UL t-put(Mbits/sec), such as 50, |
    ...   |                   |    | default is ${EMPTY} |
    ...   | ${ue_index}      | no  | ue index, default is ${0} |
    ...   | ${cell_index}    | no  | nrcell id, default is  1 |
    ...   | ${protocol}      | no  | default is udp |
    ...   | ${packet_size}   | no  | default is  1024 |
    ...   | ${interval}      | no  | the interval from data transfer started and collect l2rt log, default is 20s |
    ...   | ${gnb_index}     | no  | gnn index, default is 0 |
    ...   | ${vdu_index}     | no  | vdu index, default is 0 |
    ...   | ${log_collection_duration} | no | l2rt log collection duration, default is 60s |
    ...   | ${reboot_ue}     | no   | if ${True} to reboot UE before attach UE, otherwise does not, default is ${False} |
    ...   | ${detach_ue}     | no   | if ${True} to detach UE when return from the KW, otherwise does not, default is ${False} |
    ...   | ${loop_each_cell} | no  | if ${True} to loop each cell to make a call, otherwise does not loop each cell |
    ...   |                   |     | default is ${True} |
    ...   | ${stop_data_when_return} | no | if ${True} to stop data transfer when return from the KW, otherwise does not |
    ...   |                        |   | default is ${True} |
    ...
    ...   *RETURN VALUE*
	...    UE and cell related information, type is dictionary, return value with single direction (direction is DL or UL),
	...    {'ue_attached_cell_id': '1',
	...     'ue_call_info': {'cell_id_dict': {'NRCELL-1': '177258497',
	...                                       'NRCELL-2': '177258498',
	...                                       'NRCELL-3': '177258499'},
	...                      'cell_to_l2rt_mapping': {'177258497': 'po-cran1-l2rt-0',
	...                                               '177258498': 'po-cran1-l2rt-0',
	...                                               '177258499': 'po-cran1-l2rt-0'},
	...                      'l2rt_container_name': 'ctr-cran1-l2rt'
	...                      },
	...     'dt_name': 'DT_DL_UE_0',
	...   }
    ...
    ...  return value with bi-direction(direction is DLUL),
	...    {'ue_attached_cell_id': '1',
	...     'ue_call_info': {'cell_id_dict': {'NRCELL-1': '177258497',
	...                                       'NRCELL-2': '177258498',
	...                                       'NRCELL-3': '177258499'},
	...                      'cell_to_l2rt_mapping': {'177258497': 'po-cran1-l2rt-0',
	...                                               '177258498': 'po-cran1-l2rt-0',
	...                                               '177258499': 'po-cran1-l2rt-0'},
	...                      'l2rt_container_name': 'ctr-cran1-l2rt'
	...                      },
	...     'dt_name_DL': 'DT_DL_UE_0',
	...     'dt_name_UL': 'DT_UL_UE_0',
	...   }
	...
    ...   *Example*
    ...  | Log To Console |  call multiple times |
    ...  | Loop Each Cell To Make A UE Call | direction=DL | transfer_duration=100s | throughput=8Mbits/sec | expected_tput=5 |
    ...  | Loop Each Cell To Make A UE Call | direction=UL | transfer_duration=100s | throughput=2Mbits/sec | expected_tput=5 |
    ...
    ...  | Log To Console |  loop each to make call |
    ...  | Loop Each Cell To Make A UE Call | direction=DL | transfer_duration=100s | throughput=20Mbits/sec | expected_tput=5 |
    ...  | ... | loop_each_cell=${True} |
    ...
    ...  | Log To Console |  call with bi-direction |
    ...  | Loop Each Cell To Make A UE Call | direction=DLUL | transfer_duration=100s | throughput_DL=8Mbits/sec | expected_tput_DL=5 |
    ...  | ...  | throughput_UL=8Mbits/sec | expected_tput_UL=5 |
    ...
    ...  | Log To Console |  does not drop the call |
    ...  | ${ue_and_cell_info} | Loop Each Cell To Make A UE Call | direction=DL | transfer_duration=20m | throughput=80Mbits/sec |
    ...  | ... | expected_tput=5 | stop_data_when_return=${False} |
    ...  | Log To Console | do something here, e.g, reset other RU, rannic, etc. |
    ...  | ${dt_name} | Set Variable | ${ue_and_cell_info["dt_name"]} |
    ...  | Check Data Transfer Is Alive | dt_name=${dt_name} |
    ...  | Throughput Should Be Expected | ue_and_cell_info=${ue_and_cell_info} | expected_tput=5 |
    ...  | stop_data_transfer | ${dt_name} |
    ...  | Ue Detach By Index |
    ...
    ...  Note: If ${detach_ue} is False, 'Ue Detach By Index' or 'Ue Detach For All UEs' should be called in case teardown procedure!
    ...
    Log To Console   Make a UE Call(loop_each_cell:${loop_each_cell})
    Run Keyword If   "${direction}"!="DL" and "${direction}"!="UL" and "${direction}"!="DLUL"
    ...   Fail  direction must be DL or UL or DLUL !

    ${tmp_transfer_duration}  Convert Time    ${transfer_duration}
    ${tmp_log_collection_duration}  Convert Time    ${log_collection_duration}
    ${tmp_interval}  Convert Time    ${interval}
    Should Be True   ${tmp_transfer_duration}>=${tmp_log_collection_duration}+${tmp_interval}+20
    ...   transfer_duration should be greater than ${transfer_duration}+${log_collection_duration}+20s, but actually it's ${transfer_duration}

    Run Keyword If   "${direction}"=="DLUL"   Run Keywords  Should Not Be Empty  ${throughput_DL}  AND  Should Not Be Empty  ${expected_tput_DL}
    ...   AND  Should Not Be Empty  ${throughput_UL}  AND  Should Not Be Empty  ${expected_tput_UL}

    ${ue_and_cell_info}  Run Keyword If  "${loop_each_cell}"=="${False}"    Make A UE Call   direction=${direction}
        ...   transfer_duration=${transfer_duration}  throughput=${throughput}  expected_tput=${expected_tput}  ue_index=${ue_index}
        ...  protocol=${protocol}  packet_size=${packet_size}   interval=${interval}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
        ...  log_collection_duration=${log_collection_duration}  reboot_ue=${reboot_ue}   detach_ue=${detach_ue}
        ...  stop_data_when_return=${stop_data_when_return}   throughput_DL=${throughput_DL}
        ...  expected_tput_DL=${expected_tput_DL}  throughput_UL=${throughput_UL}  expected_tput_UL=${expected_tput_UL}
        ...  expected_max_tput=${expected_max_tput}  reattach_ue=${reattach_ue}
    Return From Keyword If  "${loop_each_cell}"=="${False}"    ${ue_and_cell_info}

    #enable RU power for all RUs via adjusting PA
    ${ru_number}  Get Ru Number  gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR  ${ru_index}  IN RANGE  ${ru_number}
        Enable RU Power Via Adjusting PA   ru_index=${ru_index}   report_error_if_not_exist_attenuator=${False}
    END

    ${ue_and_cell_info_list}  Create List
    FOR  ${ru_index}  IN RANGE  ${ru_number}
        ${ue_and_cell_info}   Make A UE Call   direction=${direction}
        ...   transfer_duration=${transfer_duration}  throughput=${throughput}  expected_tput=${expected_tput}  ue_index=${ru_index}
        ...  protocol=${protocol}  packet_size=${packet_size}   interval=${interval}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
        ...  log_collection_duration=${log_collection_duration}  reboot_ue=${reboot_ue}   detach_ue=${detach_ue}
        ...  stop_data_when_return=${stop_data_when_return}   throughput_DL=${throughput_DL}
        ...  expected_tput_DL=${expected_tput_DL}  throughput_UL=${throughput_UL}  expected_tput_UL=${expected_tput_UL}
        ...  expected_max_tput=${expected_max_tput}  reattach_ue=${reattach_ue}
       Append To List   ${ue_and_cell_info_list}   ${ue_and_cell_info}
    END
    [Return]  ${ue_and_cell_info_list}

Enable RU Power Via Adjusting PA
    [Arguments]  ${ru_index}=0    ${enable_db_value}=0    ${pa_index}=${EMPTY}    ${report_error_if_not_exist_attenuator}=${True}
    [Documentation]   Enable RU Power Via Adjusting PA
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2023-12-4 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg     | Main | description |
    ...   | ru_index     | NO | ru_index, default is 0 |
    ...   | pa_index     | NO | pa_index, default is ${EMPTY}. |
    ...   |              |     | When it's ${EMPTY}, it will be set 0 if there is only one attenuator, otherwise it's same as ru_index |
    ...   | report_error_if_not_exist_attenuator | NO | When there is no attenuator, |
    ...   |                       | When attenuator does not exist, it will report error if it's ${True}, else it does not report error |
    ...
    ...   *Return*
    ...   - int, RU numbers
    ...
    ...   *Example*
    ...   | Enable RU Power Via Adjusting PA | ru_index=0 |
    ...   | Enable RU Power Via Adjusting PA | ru_index=1 |
    ...
    ${r}  ${attenuation_port_number}  Run Keyword And Ignore Error   Get RU Attenuation Ports   ru_index=${ru_index}
    Return From Keyword If   "${r}"=="FAIL" and "${report_error_if_not_exist_attenuator}"=="${False}"
    Run Keyword If  "${r}"=="FAIL" and "${report_error_if_not_exist_attenuator}"=="${True}"  Fail  There is no attenuator for ru_index:${ru_index} !

    ${attenuator_number}  Get Attenuator Number
    ${real_pa_index}  Set Variable If   "${pa_index}"!="${EMPTY}"  ${pa_index}
       ...   "${pa_index}"=="${EMPTY}" and ${attenuator_number}==1   0   ${ru_index}
    Connect To PA    pa_index=${real_pa_index}    attenuation_port_numbers=${attenuation_port_number}
    FOR  ${port}    IN    @{attenuation_port_number}
        Set PA Power Value   attenuator_port=${port}   db_value=${enable_db_value}    pa_index=${real_pa_index}
        Get PA Port Value    attenuator_port=${port}   pa_index=${real_pa_index}
    END
    Sleep  2

Get PA Port Value
    [Arguments]    ${attenuator_port}    ${pa_index}=${0}
    [Documentation]  Get PA port value
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-May-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ${attenuator_port}   | Yes |  The PA port to set db value |
    ...    |  ${pa_index}  | No |  the index from tl.attenuators[],  ${0} in default  |
    ...    *RETURN VALUE*
    ...    port_value
    ...    Example
    ...    |  Get PA Port Value |  HBTE_0  |  1  |
    ${attenuator_port}=    Convert To Integer    ${attenuator_port}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    ${port_value}    att.read_attenuation    port=${attenuator_port}    attenuator_device=${vendor}_${pa_index}
    [return]  ${port_value}

Set PA Power Value
    [Arguments]    ${attenuator_port}    ${db_value}    ${pa_index}=${0}
    [Documentation]  Set PA port db value
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-May-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ${attenuator_device}  | Yes |  PA alias, Such as HBTE_0 |
    ...    |  ${attenuator_port}   | Yes |  The PA port to set db value |
    ...    |  ${pa_index}          | No |  the index from tl.attenuators[],  ${0} in default  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Set PA Power Vlaue |  HBTE_0  |  1  |  ${20}  |
    ${attenuator_port}=    Convert To Integer    ${attenuator_port}
    ${db_value}=    Convert To Integer    ${db_value}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    att.set_attenuation     port=${attenuator_port}    value=${db_value}    attenuator_device=${vendor}_${pa_index}

Connect To PA
    [Arguments]    ${pa_index}=${0}
    ...    ${attenuation_port_numbers}=${1}    ${max_attenuation_value}=${127}
    [Documentation]  Get PA port value
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-May-2020>, <lingtsun>, <Initial creation>
    ...    modified by:        <19-May-2023>, <lingzhao>,Add Parameter Description For TOPYOUNG
    ...    | Input Parameters              | Man. | Description |
    ...    |  ${pa_index}  | No |  the index from tl.attenuators[],  ${0} in default  |
    ...    |  ${attenuation_port_numbers}  | NO   |  port numbers, int or list, TOPYOUNG support list only, default is 1  |
    ...    |  ${max_attenuation_value}     | NO   |  maximum port value, default is 127  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Connect To PA |  HBTE_0  |
    ${ip_addr}    set variable    ${tl.attenuators[${pa_index}].ip_addr}
    ${api_port}    set variable    ${tl.attenuators[${pa_index}].port}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    ${model}       set variable if
    ...    "${vendor.upper()}"=="HBTE"  PA-16-2-4-127-0.5
    ...    "${vendor.upper()}"=="TOPYOUNG"   ${None}
    ${max_attenuation_value}   set variable if
    ...    "${vendor.upper()}"=="HBTE"   ${127}
    ...    "${vendor.upper()}"=="TOPYOUNG"   ${120}
    att.setup_attenuator    alias=${vendor}_${pa_index}    ip_addr=${ip_addr}    port=${api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}

Get Attenuator Number
    [Documentation]   Get Attenuator Number
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2023-12-11 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   None
    ...   *Return*
    ...    Attenuator number
    ...
    ...   *Example*
    ...   | ${attenuator_number} | Get Attenuator Number |
    ...
    ${all_attenuator_info}    Set Variable   ${tl.attenuators}
    ${attenuator_number}    Set Variable    ${all_attenuator_info.__len__()}
    [Return]    ${attenuator_number}

Get RU Attenuation Ports
    [Arguments]  ${ru_index}=0    ${vdu_index}=0    ${gnb_index}=0  ${fhgw_index}=0
    [Documentation]  Get RU Attenuation Ports
    ...  author: calla.wang@nokia-sbell.com
    ...  modified by:        <21-7-2022>, <calla.wang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | ru_index | no | ru_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   attenuation_port_numbers, e.g, [1,2,3,4]
    ...
    ...    Example
    ...    | ${attenuation_port_numbers} |  Get RU Attenuation Ports  |
    ...
    ${attenuation_ports_list}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].attenuation_ports}
    ${ports_amount}    Get Length    ${attenuation_ports_list}
    @{attenuation_port_numbers}    create list
    FOR    ${index}    IN RANGE    ${ports_amount}
        ${channel_port}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].attenuation_ports[${index}].port_no}
        Append To List    ${attenuation_port_numbers}    ${channel_port}
    END
    [Return]    ${attenuation_port_numbers}

Make A UE Call
    [Arguments]   ${direction}=DL  ${transfer_duration}=100s  ${throughput}=80Mbits/sec   ${expected_tput}=5   ${ue_index}=${0}
    ...  ${protocol}=udp  ${packet_size}=1024   ${interval}=20s   ${gnb_index}=0    ${vdu_index}=0
    ...  ${log_collection_duration}=60s  ${reboot_ue}=${False}   ${detach_ue}=${False}    ${stop_data_when_return}=${True}
    ...  ${throughput_DL}=${EMPTY}   ${expected_tput_DL}=${EMPTY}   ${throughput_UL}=${EMPTY}   ${expected_tput_UL}=${EMPTY}
    ...  ${expected_max_tput}=${EMPTY}   ${reattach_ue}=${False}
    [Teardown]  Run Keyword And Ignore Error   Run Keyword If   "${detach_ue}"=="${True}"    Ue Detach By Index    ue_index=${ue_index}
    [Documentation]  This KW only makes call under one cell where UE is attached. it will not loop each cell to make call.
    ...   If you want to loop each to make call, please use 'Loop Each Cell To Make A UE Call'
    ...   We can use this KW anywhere, need not any UE related operation KW before use it.
    ...
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.8.30, chris.l.cao@nokia-sbell.com, initialize
    ...  2023.10.18, chris.l.cao@nokia-sbell.com, support this KW can be called multiple times in one case
    ...  10.11.2023, chris.l.cao@nokia-sbell.com, add validation: ${duration}>=${log_collection_duration}+${interval}+20s
    ...           because we will discard some time(${interval}) at the beginning of call and give some margin(20s) while we calculate through_put
    ...  15.11.2023, chris.l.cao@nokia-sbell.com, support direction=DLUL bi-direction
	...  30.11.2023, chris.l.cao@nokia-sbell.com, add expected_max_tput
	...  4.12.2023, chris.l.cao@nokia-sbell.com, rename KW from 'Loop Each Cell To Make A UE Call' to 'Make A UE Call'
    ...
    ...   | Input Parameters   | Man. | Description |
    ...   | ${direction}}     | Yes  | the direction of Data Transfer, DL or UL or DLUL is supported, DLUL means bi-direction with DL and UL |
    ...   |                   |   | when it's DL or UL, ${throughput} and ${expected_tput} will be used |
    ...   |                   |   | when it's DLUL, ${throughput_DL}, ${expected_tput_DL}, ${throughput_UL} and ${expected_tput_UL} will be used |
    ...   |                   |   | default is DL |
    ...   | ${transfer_duration}  | Yes | the duration for data transmission, such as 2min |
    ...   | ${throughput}    | no | it is used when direction is DL or UL, bandwidth to send at in bits/sec or packets per second, |
    ...   |                  |    | such as 80Mbits/sec, default is 80Mbits/sec |
    ...   | ${expected_tput} | no | it is used when direction is DL or UL, the expected t-put(Mbits/sec), such as 50, default is 5 |
    ...   | ${expected_max_tput} | no | it is used when direction is DL or UL, the max expected t-put(Mbits/sec), such as 50, |
    ...   |                      |    | default is ${EMPTY}, it means we do not check maximum Tput |
    ...   | ${throughput_DL}  | no | it is used when direction is DLUL, DL bandwidth to send at in bits/sec or packets per second, |
    ...   |                   |    | such as 80Mbits/sec, default is ${EMPTY}  |
    ...   | ${expected_tput_DL} | Yes | it is used when direction is DLUL, the expected DL t-put(Mbits/sec), such as 50, |
    ...   |                   |    | default is ${EMPTY} |
    ...   | ${throughput_UL}  | no | it is used when direction is DLUL, DL bandwidth to send at in bits/sec or packets per second, |
    ...   |                   |    | such as 80Mbits/sec, default is ${EMPTY}  |
    ...   | ${expected_tput_UL} | Yes | it is used when direction is DLUL, the expected UL t-put(Mbits/sec), such as 50, |
    ...   |                   |    | default is ${EMPTY} |
    ...   | ${ue_index}      | no  | ue index, default is ${0} |
    ...   | ${cell_index}    | no  | nrcell id, default is  1 |
    ...   | ${protocol}      | no  | default is udp |
    ...   | ${packet_size}   | no  | default is  1024 |
    ...   | ${interval}      | no  | the interval from data transfer started and collect l2rt log, default is 20s |
    ...   | ${gnb_index}     | no  | gnn index, default is 0 |
    ...   | ${vdu_index}     | no  | vdu index, default is 0 |
    ...   | ${log_collection_duration} | no | l2rt log collection duration, default is 60s |
    ...   | ${reboot_ue}     | no   | if ${True} to reboot UE before attach UE, otherwise does not, default is ${False} |
    ...   | ${detach_ue}     | no   | if ${True} to detach UE when return from the KW, otherwise does not, default is ${False} |
    ...   | ${loop_each_cell} | no  | if ${True} to loop each cell to make a call, otherwise does not loop each cell |
    ...   |                   |     | default is ${True} |
    ...   | ${stop_data_when_return} | no | if ${True} to stop data transfer when return from the KW, otherwise does not |
    ...   |                        |   | default is ${True} |
    ...
    ...   *RETURN VALUE*
	...    UE and cell related information, type is dictionary, return value with single direction (direction is DL or UL),
	...    {'ue_attached_cell_id': '1',
	...     'ue_call_info': {'cell_id_dict': {'NRCELL-1': '177258497',
	...                                       'NRCELL-2': '177258498',
	...                                       'NRCELL-3': '177258499'},
	...                      'cell_to_l2rt_mapping': {'177258497': 'po-cran1-l2rt-0',
	...                                               '177258498': 'po-cran1-l2rt-0',
	...                                               '177258499': 'po-cran1-l2rt-0'},
	...                      'l2rt_container_name': 'ctr-cran1-l2rt'
	...                      },
	...     'dt_name': 'DT_DL_UE_0',
	...   }
    ...
    ...  return value with bi-direction(direction is DLUL),
	...    {'ue_attached_cell_id': '1',
	...     'ue_call_info': {'cell_id_dict': {'NRCELL-1': '177258497',
	...                                       'NRCELL-2': '177258498',
	...                                       'NRCELL-3': '177258499'},
	...                      'cell_to_l2rt_mapping': {'177258497': 'po-cran1-l2rt-0',
	...                                               '177258498': 'po-cran1-l2rt-0',
	...                                               '177258499': 'po-cran1-l2rt-0'},
	...                      'l2rt_container_name': 'ctr-cran1-l2rt'
	...                      },
	...     'dt_name_DL': 'DT_DL_UE_0',
	...     'dt_name_UL': 'DT_UL_UE_0',
	...   }
	...
    ...   *Example*
	...  | Log To Console |  call 1 time |
    ...  | Loop Each Cell To Make A UE Call | direction=DL | transfer_duration=100s | throughput=80Mbits/sec | expected_tput=5 |  protocol=udp |
    ...  | ... | detach_ue=${True} |
    ...
    ...  | Log To Console |  call 4 times |
    ...  | Loop Each Cell To Make A UE Call | direction=DL | transfer_duration=100s | throughput=8Mbits/sec | expected_tput=5 |
    ...  | Loop Each Cell To Make A UE Call | direction=UL | transfer_duration=100s | throughput=2Mbits/sec | expected_tput=5 |
    ...  | Loop Each Cell To Make A UE Call | direction=UL | transfer_duration=100s | throughput=2Mbits/sec | expected_tput=5 |
    ...  | Loop Each Cell To Make A UE Call | direction=UL | transfer_duration=100s | throughput=20Mbits/sec | expected_tput=5 | detach_ue=${True} |
    ...
    ...  | Log To Console |  call with bi-direction |
    ...  | Loop Each Cell To Make A UE Call | direction=DLUL | transfer_duration=100s | throughput_DL=8Mbits/sec | expected_tput_DL=5 |
    ...  | ...  | throughput_UL=8Mbits/sec | expected_tput_UL=5 |
    ...
    ...  | Log To Console |  does not drop the call |
    ...  | ${ue_and_cell_info} | Loop Each Cell To Make A UE Call | direction=DL | transfer_duration=20m | throughput=80Mbits/sec |
    ...  | ... | expected_tput=5 | stop_data_when_return=${False} |
    ...  | Log To Console | do something here, e.g, reset other RU, rannic, etc. |
    ...  | ${dt_name} | Set Variable | ${ue_and_cell_info["dt_name"]} |
    ...  | Check Data Transfer Is Alive | dt_name=${dt_name} |
    ...  | Throughput Should Be Expected | ue_and_cell_info=${ue_and_cell_info} | expected_tput=5 |
    ...  | stop_data_transfer | ${dt_name} |
    ...  | Ue Detach By Index |
    ...
    ...  Note: If ${detach_ue} is False, 'Ue Detach By Index' should be called in case teardown procedure!
    ...
    Run Keyword If   "${direction}"!="DL" and "${direction}"!="UL" and "${direction}"!="DLUL"
    ...   Fail  direction must be DL or UL or DLUL !

    ${tmp_transfer_duration}  Convert Time    ${transfer_duration}
    ${tmp_log_collection_duration}  Convert Time    ${log_collection_duration}
    ${tmp_interval}  Convert Time    ${interval}
    Should Be True   ${tmp_transfer_duration}>=${tmp_log_collection_duration}+${tmp_interval}+20
    ...   transfer_duration should be greater than ${transfer_duration}+${log_collection_duration}+20s, but actually it's ${transfer_duration}

    Run Keyword If   "${direction}"=="DLUL"   Run Keywords  Should Not Be Empty  ${throughput_DL}  AND  Should Not Be Empty  ${expected_tput_DL}
    ...   AND  Should Not Be Empty  ${throughput_UL}  AND  Should Not Be Empty  ${expected_tput_UL}

    ${ue_call_info}   Data Transfer Preparation  gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${r}   ${dummy}    Run Keyword And Ignore Error   Set Variable If   ${ue_index}==0    ${ALIAS_UE_0}
        ...                                                         ${ue_index}==1    ${ALIAS_UE_1}   ${ue_index}==2    ${ALIAS_UE_2}
    Run Keyword If   "${reboot_ue}"=="${True}"    Android UE Recover   ue_index=${ue_index}
    Run Keyword If   "${r}"=="FAIL"    Qualcomm UE Pre-condition  ue_index=${ue_index}
    Run Keyword If    "${r}"=="FAIL" or "${reattach_ue}"=="${True}"
       ...   Qualcomm UE Attach To GNB   ue_index=${ue_index}
    Run Keyword If   "${r}"=="FAIL"    _Set UE Alias   ue_index=${ue_index}

    ${cell_id}    Get UE Attched Cell Index   ue_index=${ue_index}   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${dt_name_DL}   ${dt_name_UL}   Run Keyword If  "${direction}"=="DLUL"  UE Data Transfer Bidirection With T-put Check For Single Cell
        ...   throughput_DL=${throughput_DL}    expected_tput_DL=${expected_tput_DL}
        ...   throughput_UL=${throughput_UL}    expected_tput_UL=${expected_tput_UL}
        ...   transfer_duration=${transfer_duration}
        ...   ue_index=${ue_index}  cell_index=${cell_id}   protocol=${protocol}   packet_size=${packet_size}
        ...   interval=${interval}  gnb_index=${gnb_index}   vdu_index=${vdu_index}  log_collection_duration=${log_collection_duration}
        ...   stop_data_when_return=${stop_data_when_return}
    ${dt_name}  Run Keyword If  "${direction}"=="DL" or "${direction}"=="UL"  UE Data Transfer With T-put Check For Single Cell
        ...   direction=${direction}
        ...   throughput=${throughput}    expected_tput=${expected_tput}    transfer_duration=${transfer_duration}
        ...   expected_max_tput=${expected_max_tput}
        ...   ue_index=${ue_index}  cell_index=${cell_id}   protocol=${protocol}   packet_size=${packet_size}
        ...   interval=${interval}  gnb_index=${gnb_index}   vdu_index=${vdu_index}  log_collection_duration=${log_collection_duration}
        ...   stop_data_when_return=${stop_data_when_return}

    ${cell_id}   Convert To String   ${cell_id}
    ${ue_and_cell_info}  Run Keyword If  "${direction}"=="DLUL"
         ...   Create Dictionary  ue_call_info=${ue_call_info}  ue_attached_cell_id=${cell_id}  dt_name_DL=${dt_name_DL}  dt_name_UL=${dt_name_UL}
         ...   direction=${direction}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  log_collection_duration=${log_collection_duration}
     ...  ELSE  Create Dictionary  ue_call_info=${ue_call_info}  ue_attached_cell_id=${cell_id}  dt_name=${dt_name}
         ...   direction=${direction}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  log_collection_duration=${log_collection_duration}

    [Return]  ${ue_and_cell_info}

UE Data Transfer Bidirection With T-put Check For Single Cell
    [Arguments]    ${transfer_duration}  ${throughput_DL}   ${expected_tput_DL}   ${throughput_UL}   ${expected_tput_UL}
    ...   ${ue_index}=${0}   ${cell_index}=1
    ...   ${protocol}=udp  ${packet_size}=1024  ${interval}=20s
    ...   ${gnb_index}=0    ${vdu_index}=0   ${log_collection_duration}=20s   ${stop_data_when_return}=${True}
    [Documentation]      This keyword is to perform bidirection(DL and DL at the same time) data transfer and
    ...    check throughput for specific cell, before that,
    ...    pls use kw Data Transfer Preparation to get the must have informations, see example:
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
    ...    modified by:        <15-Nov-2023>, chris.l.cao@nokia-sbell.com, add stop_data_when_return and return dt_name
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ${transfer_duration}     | Yes   |  the duration for data transmission, such as 2min |
    ...    |  ${throughput_DL}   | Yes   |  bandwidth to send at in bits/sec or packets per second for DL, such as 160Mbits/sec |
    ...    |  ${expected_tput_DL}     | Yes   |  the expected DL t-put(Mbits/sec support only), such as 150  |
    ...    |  ${throughput_UL}   | Yes   |  bandwidth to send at in bits/sec or packets per second for UL, such as 160Mbits/sec |
    ...    |  ${expected_tput_UL}     | Yes   |  the expected UL t-put(Mbits/sec support only), such as 30  |
    ...    |  ${ue_index}   | No   |  ue index, default is ${0}  |
    ...    |  ${cell_index}   | no   |  nrcell id, default is  1  |
    ...    |  ${protocol}   | no   |  default is udp  |
    ...    |  ${packet_size}   | no  |  default is  1024  |
    ...    |  ${interval}   | no  |  the interval from data transfer started and collect l2rt log, default is 20s |
    ...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
    ...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
    ...    |  ${log_collection_duration}   | no   | l2rt log collection duration, default is 20s |
    ...    |  ${stop_data_when_return} | no | if ${True} to stop data transfer when return from the KW, otherwise does not, default is ${True} |
    ...
    ...    *RETURN VALUE*
    ...    [ <dt_name_DL>, <dt_name_UL>] which identify the data transfer instance, We can use them to stop the call.
    ...    e.g, ['DT_DL_UE_0', 'DT_UL_UE_0'].
    ...
    ...    Example
    ...    | Data Transfer Preparation | gnb_index=0 | vdu_index=0 |
    ...    | UE Data Transfer Bidirection With T-put Check For Single Cell | transfer_duration=2min | throughput_DL=160Mbits/sec |
    ...    | expected_tput_DL=50 | throughput_UL=160Mbits/sec | expected_tput_UL=30 | ue_index=0 | cell_index=2 |
    ...
    ${dt_name_DL}=   Start UE Data Transfer  direction=DL   duration=${transfer_duration}   throughput=${throughput_DL}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
    ${dt_name_UL}=   Start UE Data Transfer  direction=UL   duration=${transfer_duration}   throughput=${throughput_UL}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
    sleep    ${interval}
    run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name_DL}
    run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name_UL}
    ${log_dir}   ${global_cell_id}=   Collect L2RT Log    cell_index=${cell_index}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...   log_collection_duration=${log_collection_duration}
    ${log_path}    set variable   ${log_dir}${l2rt_container_name}.log
    ${tput_DL}=   _Get T-put for Specific Cell   direction=DL   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}
    ${tput_UL}=   _Get T-put for Specific Cell   direction=UL   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}

    run keyword and continue on failure    should be true   ${tput_DL}>${expected_tput_DL}  msg=${tput_DL} is not as expected
    run keyword and continue on failure    should be true   ${tput_UL}>${expected_tput_UL}  msg=${tput_UL} is not as expected
    [Teardown]  Run Keyword If  "${stop_data_when_return}"=="${True}"
       ...  Run Keywords   stop_data_transfer  ${dt_name_DL}   AND   stop_data_transfer  ${dt_name_UL}
    [Return]  ${dt_name_DL}   ${dt_name_UL}

UE Data Transfer With T-put Check For Single Cell
    [Arguments]   ${direction}  ${transfer_duration}  ${throughput}   ${expected_tput}   ${ue_index}=${0}   ${cell_index}=1
    ...   ${protocol}=udp  ${packet_size}=1024  ${interval}=20s
    ...   ${gnb_index}=0    ${vdu_index}=0   ${log_collection_duration}=60s  ${stop_data_when_return}=${True}
    ...   ${expected_max_tput}=${EMPTY}
    [Documentation]      This keyword is to perform DL/UL data transfer and check throughput for specific cell, before that,
    ...    pls use kw Data Transfer Preparation to get the must have informations, see example:
	...    author: lingting.sun@nokia-sbell.com
	...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
	...    modified by:        <10-Nov-2023>, chris.l.cao@nokia-sbell.com, add stop_data_when_return and return dt_name
	...    modified by:        <30-Nov-2023>, chris.l.cao@nokia-sbell.com, add expected_max_tput
	...
	...    | Input Parameters | Man. | Description |
    ...    |  ${direction}}     | Yes   |  the direction of Data Transfer, DL or UL is supported |
	...    |  ${transfer_duration}     | Yes   |  the duration for data transmission, such as 2min |
	...    |  ${throughput}    | Yes   |  bandwidth to send at in bits/sec or packets per second, such as 160Mbits/sec  |
	...    |  ${expected_tput}     | Yes   |  the expected t-put(Mbits/sec support only), such as 50  |
	...    |  ${ue_index}   | No   |  ue index, default is ${0}  |
	...    |  ${cell_index}   | no   |  nrcell id, default is  1  |
   	...    |  ${protocol}   | no   |  default is udp  |
   	...    |  ${packet_size}   | no  |  default is  1024  |
   	...    |  ${interval}   | no  |  the interval from data transfer started and collect l2rt log, default is 20s |
   	...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
   	...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
   	...    |  ${log_collection_duration} | no | l2rt log collection duration, default is 60s |
   	...    |  ${stop_data_when_return} | no | if ${True} to stop data transfer when return from the KW, otherwise does not, default is ${True} |
   	...
    ...    *RETURN VALUE*
	...    dt_name which identify the data transfer instance, e.g, DT_DL_UE_0, DT_UL_UE_0. We can use it to stop the call.
	...
	...    Example
    ...    | Data Transfer Preparation | gnb_index=0 | vdu_index=0 |
    ...    | UE Data Transfer With T-put Check For Single Cell | direction=DL | 2min | 160Mbits/sec |  expected_tput=50 | cell_index=2 |
    ...
    ...    | ${dt_name} | UE Data Transfer With T-put Check For Single Cell | DL | transfer_duration=2min | throughput=160Mbits/sec |
    ...    | ... | expected_tput=50 | stop_data_when_return=${False} |
    ...    | Log To Console |  Do something here... |
    ...    | stop_data_transfer | ${dt_name} |
    ...
    ${dt_name}=   Start UE Data Transfer  direction=${direction}   duration=${transfer_duration}   throughput=${throughput}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
    Sleep    ${interval}
    Run Keyword And Continue On Failure   Check Data Transfer Is Alive   dt_name=${dt_name}
    ${log_dir}   ${global_cell_id}=   Collect L2RT Log    cell_index=${cell_index}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...   log_collection_duration=${log_collection_duration}
    ${log_path}    Set Variable   ${log_dir}${l2rt_container_name}.log
    ${tput}=   _Get T-put for Specific Cell   direction=${direction}   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}
    Should Be True   ${tput}>=${expected_tput}  msg=${tput}>=${expected_tput} : fail!
    Run Keyword If   "${expected_max_tput}"!="${EMPTY}"   Should Be True   ${tput}<=${expected_max_tput}  msg=${tput}<=${expected_max_tput} : fail!
    [Return]  ${dt_name}
    [Teardown]   Run Keyword If  "${stop_data_when_return}"=="${True}"  stop_data_transfer  ${dt_name}

Collect L2RT Log
    [Arguments]   ${cell_index}=1  ${gnb_index}=0   ${vdu_index}=0   ${log_collection_duration}=60s  ${cell_to_l2rt_mapping_ex}=${EMPTY}
    ...   ${l2rt_container_name_ex}=${EMPTY}    ${cell_id_dict_ex}=${EMPTY}
    [Documentation]   Collect L2RT Log
    ...    *AUTHOR* unknown
    ...    history change: <date>,<who>,<what and how>
    ...   13.11.2023,chris.l.cao@nokia-sbell.com, decouple from global variable ${cell_to_l2rt_mapping},${l2rt_container_name},${cell_id_dict}
    ...                                           for 'Throughput Should Be Expected' usage.
    ...
    ...   | Input Parameters | Man. | Description |
    ...	  | cell_index | no | cell_index, 1 |
    ...	  | gnb_index  | no | gnb_index, default value is 0 |
    ...	  | vdu_index  | no | vdu_index, default value is 0 |
    ...	  | log_collection_duration | no | log_collection_duration, default value is 60s |
    ...	  | cell_to_l2rt_mapping_ex | no | cell_to_l2rt_mapping_ex,
    ...   |                         |    | default value is ${EMPTY} which means to use global variable ${cell_to_l2rt_mapping} |
    ...	  | l2rt_container_name_ex  | no | l2rt_container_name_ex, |
    ...   |                         |    | default value is ${EMPTY} which means to use global variable ${l2rt_container_name} |
    ...	  | cell_id_dict_ex         | no | cell_id_dict_ex, |
    ...   |                         |    | default value is ${EMPTY} which means to use global variable ${cell_id_dict} |
    ...
    ...    *RETURN VALUE*
    ...   <log_path>, <global_cell_id>
    ...
    log to console   Start to collect l2rt log of Cell_${cell_index}
    ${cell_to_l2rt_mapping}  Set Variable If   "${cell_to_l2rt_mapping_ex}"=="${EMPTY}"   ${cell_to_l2rt_mapping}   ${cell_to_l2rt_mapping_ex}
    ${l2rt_container_name}  Set Variable If   "${l2rt_container_name_ex}"=="${EMPTY}"   ${l2rt_container_name}   ${l2rt_container_name_ex}
    ${cell_id_dict}  Set Variable If   "${l2rt_container_name_ex}"=="${EMPTY}"   ${cell_id_dict}   ${cell_id_dict_ex}

    ${global_cell_id}    ${pod_name}   _Get Global Cell Index And L2rt Located Pod Of Specific Cell
    ...   cell_to_l2rt_mapping=${cell_to_l2rt_mapping}   cell_id_dict=${cell_id_dict}   cell_index=${cell_index}
    ${log_path}   Collect vDU K8S Logs In Given Pod   pod_name=${pod_name}   kubelog_file_name=l2rt_${pod_name}
    ...   container_name=${l2rt_container_name}   duration=${log_collection_duration}
    ...   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]   ${log_path}    ${global_cell_id}

_Get Global Cell Index And L2rt Located Pod Of Specific Cell
    [Arguments]    ${cell_to_l2rt_mapping}   ${cell_id_dict}  ${cell_index}=1   ${gnb_index}=0    ${vdu_index}=0
    ${local_cell_id}   set variable    NRCELL-${cell_index}
    ${global_cell_id}   set variable    ${cell_id_dict['${local_cell_id}']}
    ${res}    Run Keyword And Return Status    Dictionary Should Contain Key   ${cell_to_l2rt_mapping}   ${global_cell_id}
    run keyword if    '${res}'=='False'   Data Transfer Preparation    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${pod_name}    set variable   ${cell_to_l2rt_mapping['${global_cell_id}']}
    [Return]   ${global_cell_id}    ${pod_name}

Start UE Data Transfer
    [Arguments]   ${direction}  ${duration}  ${throughput}   ${ue_index}=${0}
    ...   ${protocol}=udp  ${packet_size}=1024  ${max_segment_size}=1300
    log to console   Start ${direction} data transfer for UE_${ue_index}
    ${dt_name}   set variable   DT_${direction}_UE_${ue_index}
    Run keyword if  "${protocol}" == "udp"  wait until keyword succeeds   3X  10s  start data transfer  dt_name=${dt_name}
    ...  ue_alias=UE_${ue_index}  direction=${direction}  duration=${duration}  throughput=${throughput}   protocol=${protocol}
    ...  packet_size=${packet_size}
    Run keyword if  "${protocol}" == "tcp"  wait until keyword succeeds   3X  10s  start data transfer  dt_name=${dt_name}
    ...  ue_alias=UE_${ue_index}  direction=${direction}  duration=${duration}  throughput=${throughput}   protocol=${protocol}
    ...  packet_size=${packet_size}   max_segment_size=${max_segment_size}
    [Return]   ${dt_name}

_Get T-put for Specific Cell
    [Arguments]    ${direction}    ${log_path}    ${global_cell_id}
    ${tput}=   run keyword if   '${direction}'=="UL"
    ...  get_ul_tput_from_l2_log   log_path=${log_path}    cell_id=${global_cell_id}
    ...  ELSE IF   '${direction}'=="DL"  get_dl_tput_from_l2_log    log_path=${log_path}    cell_id=${global_cell_id}
    log to console  ${direction}_throughput of cell_${global_cell_id}: ${tput}
    [Return]  ${tput}

Get UE Attched Cell Index
    [Arguments]  ${ue_index}=${0}   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   This KW will check the cell index which can be used for tput kw cell_index
    ...   Before use this KW, Data Transfer Preparation is mandatory to use
    ...   *AUTHOR* unknown@nokia-sbell.com
    ...  Change History
    ...  2023.x.x, unknown@nokia-sbell.com, unknown
    ...  2023.8.30, chris.l.cao@nokia-sbell.com, optimize and move to common KW resource
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...   cell index
    ...
    ...   Example
    ...   | Data Transfer Preparation |
    ...   | Qualcomm UE Pre-condition |
    ...   | Qualcomm UE Attach To GNB |
    ...   | ${cell_index} | Get UE Attched Cell Index |
    ...   | UE Data Transfer With T-put Check For Single Cell | direction=DL | throughput=20Mbits/sec | expected_tput=5 | cell_index=${cell_index} |
    ...   | ...   | transfer_duration=30s |
    ...
    ${cell_id_dict}    vDU Get Global Cells ID Dict   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_id}=  Get UE Attached Global Cell Id  ue_index=${ue_index}

    FOR    ${one_dict}    IN    @{cell_id_dict}
        ${key_value}  Get Dictionary Items   ${one_dict}
        Exit For Loop If   '${key_value[1]}'=='${Cell_id}'
    END
    ${matches}=    Get Regexp Matches    ${key_value[0]}    \\d+
    ${cell_index}=    Convert To Integer    ${matches[0]}
    [Return]    ${cell_index}

_Set UE Alias
   [Arguments]  ${ue_index}
   Run Keyword If   "${ue_index}"=="0"   Set Test Variable   ${ALIAS_UE_0}   AliasAlreadyAssigned
   ...  ELSE IF  "${ue_index}"=="1"   Set Test Variable   ${ALIAS_UE_1}   AliasAlreadyAssigned
   ...  ELSE IF  "${ue_index}"=="2"   Set Test Variable   ${ALIAS_UE_2}   AliasAlreadyAssigned



Get UE Attached Global Cell Id
    [Arguments]    ${ue_index}=${0}
    [Documentation]  After UE attach success, can use this keyword to get the UE attached global cell id.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <09-Mar-2023>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Get UE Attached Global Cell Id |  |
    ${attached_cell_id}    ute_ue.Get Ue Info    UE_${ue_index}    CELL_ID
    [Return]  ${attached_cell_id}

Qualcomm UE Attach To GNB
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword is to perform UE attach and check the attach status.
    ...    and also one time reattach as WA for not success with ute_ue lib connect issue.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:
    ...    31-Mar-2020, lingtsun, Initial creation
    ...    09-SEP-2020, tluo, Initial creation
    ...    17-SEP-2020, lutu, add qualccomm atatch verify
    ...    17-May-2021, shojiao, comments qualccomm atatch method
    ...    29-Agu-2023, horao, add SM-S906U for attach
    ...    20-Feb-2024, chris.l.cao, add 'Delete Rules In Iptable In App Server' to solve one of the UL data failure problems
    ...                              add network connectivity detection between UE and App Server to help troubleshooting UL data failure
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  duration  | No |  waiit for ADB log catch,  20s in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Qualcommn UE Pre-condition |
    ...    | Qualcomm UE Attach to GNB  |
    ${model}    Get UE MODEL    ${ue_index}
    run keyword if    'SM-G991U' in '${model}' or 'SM-S911U' in '${model}' or 'SM-S906U' in '${model}' or '2106118C' in '${model}'
    ...  _Samsung UE Attach TDD    ${ue_index}
    ...  ELSE IF  'SM-G986U' in '${model}' or 'QUALCOMM' in '${model}' or 'HMD Global Nokia' in '${model}'   Samsung UE Attach    ${ue_index}
    ...   ELSE     Fail    Unknown UE_type:${model}!

    Run Keyword And Ignore Error   Delete Rules In Iptable In App Server   ue_index=${ue_index}
    Run Keyword And Ignore Error   Network Connectivity Should Be OK Between UE And App Server   ue_index=${ue_index}

_Samsung UE Attach TDD
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword is to perform Samsung UE attach and check the attach status.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <28-Jan-2021>, <lingtsun>, <Initial creation>
    ...    modified by:        <13-Apr-2021>, <huilxu>, <add some l2rt log to verify>
    ...    modified by:        <13-Apr-2022>, <luofei.tu>, <add sleep >
    ...    modified by:        <6-May-2022>, <luofei.tu>, <add   _Attach Result Check TDD>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Samsung UE Attach |  |
    log to console    \nInfo:---------UE_${ue_index} Begin Attach ---------!
    UE Detach By Index   ${ue_index}
    wait until keyword succeeds   3x   2s    Ue Attach By Index   ${ue_index}
    sleep  100s
    wait until keyword succeeds   1min   10sec    _UE Attach Result Check TDD   ${ue_index}

Ue Detach By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  When with UE_CAPABILITIES is REAL_ANDORID_UE,
    ...    the keyword will send adb command to turn on the airplane mode.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Ue detach by index  |  |
    ute_ue.detach_ue    UE_${ue_index}

Ue Attach By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...    If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Ue attach by index |  |
    run keyword and return status  ute_ue.attach_ue    UE_${ue_index}

Samsung UE Attach
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword is to perform Samsung UE attach and check the attach status.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <28-Jan-2021>, <lingtsun>, <Initial creation>
    ...    modified by:        <13-Apr-2021>, <huilxu>, <add some l2rt log to verify>
    ...    modified by:        <13-Apr-2021>, <luofei.tu>, <add sleep >
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Samsung UE Attach |  |
    log to console    \nInfo:---------UE_${ue_index} Begin Attach ---------!
    Ue Detach By Index   ${ue_index}
    sleep  10s
    wait until keyword succeeds   3x   2s    Ue Attach By Index   ${ue_index}
    sleep  180s
    wait until keyword succeeds   5min   5sec    _UE Attach Result Check TDD   ${ue_index}

_Get Attached UEIP
    [Arguments]  ${ue_index}=${0}
     [Documentation]  This keyword is to perform Get Samsung UE attach IP INFO.
    ...    author: luofei.tu@nokia-sbell.com
    ...    modified by:        <6-May-2022>, <lutu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Get Attached UEIP |  |
    ${ue_ip}    ute_ue.log Ue Info   UE_${ue_index}   IP
    [Return]   ${ue_ip}

_UE Attach Result Check TDD
    [Arguments]  ${ue_index}=${0}
     [Documentation]  This keyword is to perform  check the Samsung UE attach status.
    ...    author: luofei.tu@nokia-sbell.com
    ...    modified by:        <6-May-2022>, <lutu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _UE Attach Result Check TDD|  |
    ${ue_attach_result}   Run Keyword If  "${tl.ues[${ue_index}].__class__.__name__}" == "Android"
    ...  run keyword and return status  ute_ue.Get Ue Info  UE_${ue_index}  5G_STATE
    ...  ELSE IF
    ...  "${tl.ues[${ue_index}].__class__.__name__}" == "TafUeAndroid"   run keyword and return status  ute_ue.Get Ue Info  UE_${ue_index}  NR_STATE
    ${ue_attach_ip}     run keyword and ignore error    _Get Attached UEIP   ${ue_index}
    ${ue_attach_ip_list}   Set Variable    ${ue_attach_ip}[0]

    run keyword if    '${ue_attach_ip_list}' == 'PASS' and '${ue_attach_result}' == '${True}'
    ...  log to console    \nInfo:UE_${ue_index} Status ---------Attach Successful ${ue_attach_ip_list}---------!
    ...  ELSE   run keywords  log to console  \nInfo:UE_${ue_index} Status ------ Attach Fail will try to adb reboot -----!
    ...  AND  _ADB Reboot UE By Index  ${ue_index}  AND  wait until keyword succeeds   1min   10s   _Get Attached UEIP   ${ue_index}

Delete Rules In Iptable In App Server
    [Arguments]  ${ue_index}=0
    [Teardown]  Run Keyword And Ignore Error  issh.disconnect   alias=${alias}
    [Documentation]      Delete Rules In Iptable In App Server for one UE
    ...  author:  chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index  |  no | ue_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Delete Rules In Iptable In App Server |
    ...    |  Delete Rules In Iptable In App Server | ue_index=1 |
    ...
    ${ue_info}    Set Variable   ${tl.ues[${ue_index}]}
    Return From Keyword If  "${ue_info.__class__.__name__}" != "TafUeAndroid"

    ${app_server_info}   Get App Server Info  ue_index=${ue_index}
    ${address}  Set Variable   ${app_server_info["address"]}
    ${user}  Set Variable      ${app_server_info["user"]}
    ${password}  Set Variable  ${app_server_info["password"]}

    ${alias}  get_unique_id
    UTE Connection   hostname=${address}   username=${user}   password=${password}  keyfile=${EMPTY}  alias=${alias}

    ${out}   issh.Execute   command=sudo -i        alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL  alias=${alias}
    ${out}   issh.Execute   command=iptables -F    alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL  alias=${alias}

Network Connectivity Should Be OK Between UE And App Server
    [Arguments]  ${ue_index}=0
    [Documentation]    Check  Network Connectivity Should Be OK Between UE And App Server
    ...  author:  chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index  |  no | ue_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Network Connectivity Should Be OK Between UE And App Server |
    ...    |  Network Connectivity Should Be OK Between UE And App Server | ue_index=1 |
    ...
    ${ue_info}    Set Variable   ${tl.ues[${ue_index}]}
    Return From Keyword If  "${ue_info.__class__.__name__}" != "TafUeAndroid"

    ${r}   Run Keyword And Return Status   UE Should Be Pingable From App Server   ue_index=${ue_index}
    Return From Keyword If   "${r}"=="True"

    ${msg}   Set Variable   Network path is Iperf server<-->NGU/S1U<-->vCU<-->vDU<-->UE.
    ${msg}   Set Variable  ${msg} Note: it's bi-drection, so we need check route from both Iperf server to UE and UE to Iperf server.
    ${msg}   Set Variable  ${msg} Especially when we can't make UL data(protocol: udp) call, we need check network route from VCU to NGU/S1U
    ${msg}   Set Variable  ${msg} because AMF may allocate different NGU/S1U network but we did not set right route for all those NGU/S1U network.
    ${msg}   Set Variable  ${msg} All in all, we need confirm bi-drection route is ok, including every path component between iperf server and UE.
    Fail     ${msg}

UE Should Be Pingable From App Server
    [Arguments]  ${ue_index}=0   ${deadline}=4
    [Teardown]  Run Keyword And Ignore Error  issh.disconnect   alias=${alias}
    [Documentation]    UE Should Be Pingable From App Server
    ...  author:  chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index  |  no | ue_index, default value is 0 |
    ...    | deadline  |  no | ping deadline, default value is 2, unit is second |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | UE Should Be Pingable From App Server |
    ...    | UE Should Be Pingable From App Server | ue_index=1 |
    ...
    ${app_server_info}   Get App Server Info  ue_index=${ue_index}
    ${address}  Set Variable   ${app_server_info["address"]}
    ${user}  Set Variable      ${app_server_info["user"]}
    ${password}  Set Variable  ${app_server_info["password"]}

    ${target_ip}    utils.get_ue_info    UE_${ue_index}   IP
    Should Be True   "${target_ip}"!="${None}"

    ${bIpV6Address}    Set Variable If    ":" in """${target_ip}"""    1      0
    ${cmd}    Set Variable If   ${bIpV6Address}==1   sudo ping6 ${target_ip} -c 2 -w ${deadline}
    ...   sudo ping ${target_ip} -c 2 -w ${deadline}

    ${alias}  get_unique_id
    UTE Connection   hostname=${address}   username=${user}   password=${password}  keyfile=${EMPTY}  alias=${alias}
    ${out}   issh.Execute   command=${cmd}  check_result=${False}  alias=${alias}

    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}==0

UTE Connection
    [Arguments]  ${hostname}=${UTE_SSH_IP}   ${username}=${UTE_SSH_USER_NAME}   ${password}=${UTE_SSH_PASSWORD}  ${alias}=default
    ...   ${keyfile}=/home/ute/.ssh/id_rsa
    [Documentation]   UTE Connection
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  20.2.2024 chris.l.cao@nokia-sbell.com, add prompt for root user, support both keyfile and password to login
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | hostname  |  no | hostname, default value is ${UTE_SSH_IP} |
    ...    | username  |  no | username, default value is ${UTE_SSH_USER_NAME} |
    ...    | password  |  no | password, default value is ${UTE_SSH_PASSWORD} |
    ...    | keyfile   |  no | keyfile, when it's empty, it will use password to login, default value is /home/ute/.ssh/id_rsa |
    ...    | alias     |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | UTE Connection |
    ...    | UTE Connection | password=abc | keyfile=${EMPTY} |
    ...    | ${out}         | issh.Execute | command=ls -l |
    ...    | Interactive Connection Disconnect |
    ...
    ${prompt}  Set Variable   ${username}@.*\\$|root@.*\\#
    issh.connect_to   ip=${hostname}    username=${username}   password=${password}
              ...   prompt=${prompt}   keyfile=${keyfile}   alias=${alias}   width=500

    RETURN  ${alias}

Qualcomm UE Pre-condition
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    [Documentation]  This keyword is the precondition for Qualcomm ue attach,
    ...    action contain QPST start to avoid UE crash and airplane mode turn on
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
	...    modified by:        <19-May-2022>, <exuan>, <Modify wait until keyword succeeds>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  cap_index  | No |  the index from tl.ues.capabilities[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Qualcommn UE Pre-condition  |  |
    wait until keyword succeeds  30s  2s  _Require UE By Index    ue_index=${ue_index}    cap_index=${cap_index}

_Require UE By Index
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
    ...    It will read the testline tl.ues all parameter in ue_pool
    ...    It is strongly suggested to put this keyword into the suite setup.
    ...    If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...    Important: this keyword support multi ue ,
    ...    but need to config the tl.ues[xx].capability[] at least with one different value.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  cap_index  | No |  the index from tl.ues.capabilities[]  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Require ue by index  |  |
    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ute_ue.require Ue    ue_alias=UE_${ue_index}    capabilities=${ue_cap}

Android UE Recover
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword is the recovery action if ue attach failed
    ...    action contain UE reboot and airplane mode turn on.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  cap_index  | No |  the index from tl.ues.capabilities[]  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Android UE Recover |  |
    Is UE Connected To Control PC    ${ue_index}
    ADB Reboot UE By Index    ${ue_index}
    Is UE Connected To Control PC    ${ue_index}
    wait until keyword succeeds    2min    10s    Ue Detach By Index    ${ue_index}

Get UE MODEL
    [Arguments]    ${ue_index}=${0}
    [Documentation]  After UE attach success, can use this keyword to get the UE MODEL.
    ...    author: tina.luo@nokia-sbell.com
    ...    modified by:        <09-SEP-2020>, <tluo>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Get UE MODEL |  |
    ${MODEL}    ute_ue.Get Ue Info    UE_${ue_index}    DEVICE_MODEL
    [return]  ${MODEL}

ADB Reboot UE By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  Use adb command to reboot the android ue device
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  ADB Reboot UE by index  |  |
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    Connect To Control PC    ${ue_index}
    tafssh.execute    command=adb -s ${SN} reboot   connection=cpc_${ue_index}
    tafssh.disconnect   connection=cpc_${ue_index}

Connect To Control PC
    [Arguments]  ${ue_index}=${0}
    [Documentation]  connect the control PC
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Connect to control pc  |  |
    Wait Until Keyword Succeeds    2min    20s
    ...   tafssh.Connect to   ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...                       ${tl.ues[${ue_index}].ssh_connection_details.username}
    ...                       ${tl.ues[${ue_index}].ssh_connection_details.password}   alias=cpc_${ue_index}

Is UE Connected To Control PC
    [Arguments]  ${ue_index}=${0}
    [Documentation]  Check the UE device is connect to control pc normally.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Is UE connected to control PC  |  |
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    Connect To Control PC    ${ue_index}
    wait until keyword succeeds    3 min    10s
    ...     _Is ADB Device Connected   alias=cpc_${ue_index}    serial_number=${SN}
    tafssh.disconnect   connection=cpc_${ue_index}

Data Transfer Preparation
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   Get cell to lwrt mapping and nrcell to global cell mapping, and set as test variable
	...    author: lingting.sun@nokia-sbell.com
	...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
	...    | Input Parameters | Man. | Description |
   	...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
   	...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
   	...
	...    *RETURN VALUE*
	...    UE call information, type is Dictonary, value like below,
	...         {'cell_id_dict': {'NRCELL-1': '177258497',
	...                        'NRCELL-2': '177258498',
	...                        'NRCELL-3': '177258499'},
	...         'cell_to_l2rt_mapping': {'177258497': 'po-cran1-l2rt-0',
	...                         '177258498': 'po-cran1-l2rt-0',
	...                         '177258499': 'po-cran1-l2rt-0'},
	...         'l2rt_container_name': 'ctr-cran1-l2rt'}
	...
	...    Example
    ...    | ${ue_call_info} | Data Transfer Preparation | gnb_index=0 | vdu_index=0|
    ...
    ${cell_to_l2rt_mapping}   wait until keyword succeeds   2X  40s   Get Cell To L2RT Mapping
    ...   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable   ${cell_to_l2rt_mapping}
    ${cell_id_list}   vDU Get Global Cells ID Dict    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_id_dict}   create dictionary
    FOR  ${item}  IN  @{cell_id_list}
       ${local_cell_id}  Get Dictionary Keys  ${item}
       ${global_cell_id}  Get Dictionary values  ${item}
       set to dictionary    ${cell_id_dict}    ${local_cell_id[0]}    ${global_cell_id[0]}
    END
    set test variable    ${cell_id_dict}
    log to console   ${cell_id_dict}
    ${l2rt_container_name}   Get Full Container Name By Container Abbreviation   ctr_abbr=l2rt
    set test variable    ${l2rt_container_name}

    ${ue_call_info}   Create Dictionary  cell_to_l2rt_mapping=${cell_to_l2rt_mapping}   cell_id_dict=${cell_id_dict}
                                 ...   l2rt_container_name=${l2rt_container_name}
    [Return]  ${ue_call_info}

Get Cell To L2RT Mapping
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  Get the global cell id list to up pod mapping dict
    ...   *Author:* lingting.sun@nokia-sbell.com
    ...   *Change History*
    ...   | 2023-3-7 | lingtsun | update up to l2rt|
     ...   | 2022-4-14 | lingtsun | init create |
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int,gnb index, default is 0 |
    ...   | vdu_index | NO | int,vdu index, default is 0 |
    ...    *RETURN VALUE*
    ...    cell_to_l2rt_mapping_dict}
    ...   {'176586753': 'po-cran1-up-0', '176586754': 'po-cran1-up-0', '176586755': 'po-cran1-up-0'}
    ...   *Example*
    ...   | cell_to_l2rt_mapping_dict |
    ${ns}   get_vdu_namespace_from_testline   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pods_info}=    vDU Get Pods Full Info     vdu_index=${vdu_index}   namespace=${ns}    gnb_index=${gnb_index}
    ${pods_name_list}=    Get Dictionary Keys    ${pods_info}
    ${pod_list}  create list   @{empty}
    FOR  ${pod}  IN  @{pods_name_list}
       run keyword if    '-up-' in '${pod}' or '-l2rt-' in '${pod}'   Append To List   ${pod_list}   ${pod}
    END
    ${container_name}   Get Full Container Name By Container Abbreviation   ctr_abbr=l2rt
    ...  vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${l2rt_to_cell_mapping}  create dictionary
     FOR    ${pod}    IN    @{pod_list}
        log   ${pod}
        ${log_path}   Collect vDU K8S Logs In Given Pod   ${pod}   l2rt_${pod}    ${container_name}  duration=20s
    ...   vdu_index=${vdu_index}   gnb_index=${gnb_index}
        ${nrcellid_list}=   get_nrcellid_list_from_l2_log   ${log_path}${container_name}.log
        set to dictionary    ${l2rt_to_cell_mapping}    ${pod}    ${nrcellid_list}
    END
    ${cell_to_l2rt_mapping_dict}   utils.Get Cell Global L2rt Mapping Dict     cell_to_l2rt_mapping=${l2rt_to_cell_mapping}
    [return]   ${cell_to_l2rt_mapping_dict}

Collect vDU K8S Logs In Given Pod
    [Documentation]  collect vdu kube logs in one pod using 'kubectl logs' command
    ...   *Author*  calla.wang@nokia-sbell.com
    ...    04.09.2020,lingting.sun@nokia-sbell.com,add param duration and return log path
    ...   | Input Parameters | Man. | Description |
    ...	  | pod_name | Yes. | the pod name |
    ...   | kubelog_file_name | Yes. | the log file name that will be stored in local |
    ...   | container_name | No. | the container name, default is None means all containers of the pod |
    ...   | vdu_index | No. | the vdu index default is 0 |
    ...   | duration  | No. | the duration default is 60s |
    ...   *Return Value*
    ...   None
    [Arguments]  ${pod_name}  ${kubelog_file_name}  ${container_name}=${None}  ${vdu_index}=0  ${gnb_index}=0
                 ...   ${duration}=60s
    ${index}=  Get Unique Id
#    ${local_filepath}   get a Directory   k8s_log_${index}
#jk
    Run    mkdir /home/ute/logs/k8s_log_${index}
    ${local_filepath}    Set Variable  /home/ute/logs/k8s_log_${index}


    ${executor}    Create Dictionary
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    kubelog_collect.create_kubernetes_collector
    ...    name=kubelog
    ...    namespace=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...    pod_name=${pod_name}
    ...    container=${container_name}
    ...    executor=${executor}
    ...    target_file_name=${kubelog_file_name}
    ...    sudo_password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    core_collect.setup_collectors    names=kubelog
    core_collect.start_collectors    names=kubelog
    Sleep  ${duration}
    core_collect.stop_collectors    names=kubelog
    core_collect.collect_collectors    names=kubelog    target_dir=${local_filepath}
    core_collect.teardown_collectors    names=kubelog
    Run Keyword And Ignore Error    OperatingSystem.Run   cd ${local_filepath}/kubelog/;tar -xvf *
    [Return]    ${local_filepath}/kubelog/

vDU Cluster Login With Tenant
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Connect to vdu cluster with tenant
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <08-04-2022>, <lingtsun>, <add the doc accroding to code rule>
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no |  gnb index  |
    ...    | vdu_index  | no |  vdu index  |
    ...    *RETURN VALUE*
    ...    connection session
    ...
    ...    Example
    ...    |  vDU Cluster Login With Tenant |
    # ${conn}=    helm.helm_master_connect    ${VDU_1_MASTER_NODE_SSH_IP}    22    ${VDU_1_TENANT_SSH_USER_NAME}    ${VDU_1_TENANT_SSH_PASSWORD}
    ${conn}=    helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  22
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    [Return]   ${conn}

vDU Get Pods Full Info
    [Arguments]    ${pod_name}=all    ${namespace}=${EMPTY}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  get pods full infomation
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ...    *RETURN VALUE*
    ...    pods info dict
    Run Keyword If    '${namespace}' != '${EMPTY}'    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    ...    ELSE    vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${pods_info}=    get_vdu_pods_info    ${pod_name}    ${namespace}
    Set Test Variable    ${Pods_Info}    ${pods_info}
    [Return]  ${Pods_Info}
    [Teardown]    helm.helm_master_close

vDU Cluster Login With Admin
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    # ${conn}=  helm.helm_master_connect  ${VDU_1_MASTER_NODE_SSH_IP}  22  ${VDU_1_MASTER_NODE_SSH_USER_NAME}  ${VDU_1_MASTER_NODE_SSH_PASSWORD}
    ${conn}=  helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    [Return]   ${conn}

Get Full Container Name By Container Abbreviation
    [Arguments]    ${ctr_abbr}       ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Get Full Container Name By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | ctr_abbr          |  Yes | container name abbreviation, eg, oamfh, oam, cprt, nwmgmt,etc |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full Container name, e.g, ctr_cran1_oamfh
    ...
    ...    Example
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=oamfh |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=nwmgmt | vdu_index=0 |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=cprt | vdu_index=0 |
    ...

    #@{ctr_list}  create list   appsecretinithttpd  appsecretinitne3sagent  appsecretinitprovidercontroller  httpdstunnel
    #...  ne3sagentstunnel  providercontrollerstunnel  httpdcredmediator  ne3sagentcredmediator  providercontrollercredmediator
    #: FOR    ${ctr}    IN    @{ctr_list}
    #\   Return From Keyword If   "${ctr_abbr}"=="${ctr}"   ${ctr_abbr}

    ${container_prefix}  Get Container Name Prefix   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${start_with_prefix}   Set Variable  ${ctr_abbr.startswith("${container_prefix}")}
    Return From Keyword If   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${full_ctr_name}   Set Variable  ${container_prefix}${ctr_abbr}
    [Return]  ${full_ctr_name}

Get Container Name Prefix
    [Arguments]     ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Container Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...
    ...    *Example*
    ...    | ${container_prefix} | Get Container Name Prefix |
    ...    | ${container_prefix} | Get Container Name Prefix | vdu_index=0 |
    ...
#    ${r}  ${out}  Run Keyword And Ignore Error   Set Variable   ${_G_CONTAINER_PREFIX}
#    Return From Keyword If  "${r}"=="PASS"   ${_G_CONTAINER_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Set Suite Variable   ${_G_CONTAINER_PREFIX}

    [Return]  ${_G_CONTAINER_PREFIX}


_Get Container Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   _Get Container Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *History Change*
    ...    | date | who | what and how |
    ...    | 14.8.2021 | chris.l.cao@nokia-sbell.com | change from tenant to admin account to adapt OCP |
    ...    | 15.7.2022 | lingting.sun@nokia-sbell.com| adaption for multi gnb |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    *Example*
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use |
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use | vdu_index=0 |
    ...

     ${ns}   get_vdu_namespace_from_testline   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${cnf_release_value_json}  _Get CNF Release Values With Json Format   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${cnf_release_value_json_format}   Split To Lines   ${cnf_release_value_json}
    Remove From List    ${cnf_release_value_json_format}   0

    ${container_prefix}=   parse_name_convention_from_json_cnf_release_values   ${cnf_release_value_json_format}[0]  ${ns}  container_prefix
    [Return]    ${container_prefix}

_Get CNF Release Values With Json Format
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  fast_disconnect  alias=${alias}
    ${alias}  Get Unique Id
    fast_connect_to_k8s_master  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${cmd}   set variable   helm list
    ${with_pipeline_command}  set variable  | grep -v cluster | grep -v prerequisite | grep -v NAME | awk '{print $1}'
    ${cnf_release}  fast_execute  command=${cmd}   with_pipeline_command=${with_pipeline_command}
    ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}

    ${cnf_release_name}   Split To Lines   ${cnf_release}
    Remove From List    ${cnf_release_name}   0

    ${cmd}=  set variable  helm get values ${cnf_release_name}[0] -o json
    ${response}  fast_execute  command=${cmd}
    ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}

    [Return]    ${response}

vDU Get Global Cells ID Dict
   [Arguments]  ${vdu_index}=0    ${gnb_index}=0
   [Documentation]      Get all avaiable cells id list.
    ...  author: lingting.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  vDU Get Cells ID list  | 0 |
    ${alias}  aic_common_resources_new.Rest Login on vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cells_dict}    vdu.get_vdu_cell_id   vdu_connection=${alias}
    [Return]   ${cells_dict}
    [Teardown]  vDU Rest Logout   alias=${alias}

Ue Detach For All UEs
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Ue Detach For All UEs
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2023-12-3 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int,gnb index, default is 0 |
    ...   | vdu_index | NO | int,vdu index, default is 0 |
    ...
    ...   *Return*
    ...   None
    ...
    ...   *Example*
    ...   | Ue Detach For All UEs |
    ...
    ${ru_number}  Get RU Number  gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR  ${ru_index}  IN RANGE  ${ru_number}
       Ue Detach By Index   ue_index=${ru_index}
    END
######################


Wait For Cells To Be OnAir
    [Documentation]    Keyword checks cell status until the condition is met

    ${start_time}=     Evaluate    time.time()
    FOR    ${i}    IN RANGE    0    ${TIMEOUT}/${INTERVAL}
        Wait Until Keyword Succeeds   360  10    Get vDU Cells Status
        ${all_cells_ready}=    Check Cell Status    ${get_cells_statuses}
        Run Keyword If    ${all_cells_ready}    Return From Keyword
        Sleep    ${INTERVAL}
        ${elapsed_time}=    Evaluate    time.time() - ${start_time}
        Exit For Loop If    ${elapsed_time} > ${TIMEOUT}
    END
    Fail    Cells did not reach onair state within ${TIMEOUT} seconds

Get vDU Cells Status
    [Documentation]
    ...  This KW Get vDU Cells Status

    ${get_cells_statuses}=    vdu.Get Vdu Cells Status
    Set Test Variable  ${get_cells_statuses}

Check Cell Status
    [Documentation]
    ...  This KW Check Cell Status

    [Arguments]    ${get_cells_statuses}
    ${cells_statuses}=    Set Variable    ${get_cells_statuses}
    FOR    ${cell}    IN    @{cells_statuses}
        ${administrative_state}=    Get From Dictionary    ${cell}    administrative_state
        ${availability_status}=     Get From Dictionary    ${cell}    operational_state
        ${operational_state}=       Get From Dictionary    ${cell}    availability_status

        Run Keyword If    '${administrative_state}' == 'None'    Return From Keyword    False
        Run Keyword If    '${availability_status}' == 'None'    Return From Keyword    False
        Run Keyword If    '${operational_state}' == 'None'    Return From Keyword    False

        Run Keyword If    '${administrative_state.lower()}' != 'unlocked'    Return From Keyword    False
        Run Keyword If    '${availability_status.lower()}' != 'enabled'      Return From Keyword    False
        Run Keyword If    '${operational_state.lower()}' != 'on line'        Return From Keyword    False

    END
    RETURN    True



Get Unique ID
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}   ${precise}=HIGH
    [Documentation]   Get Unique ID
    ...    | Input Parameters | Man. | Description |
    ...    | prefix       | no | prefix, default is ${EMTPY} |
    ...    | suffix       | no | suffix, default is ${EMTPY} |
    ...    | precise      | no | precise, HIGH or LOW, default is HIGH |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...  | ${tmp_id} | Get Unique ID |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=LOW |
    ${precise}  Set Variable  ${precise.upper()}
    ${rtn}  Run Keyword If  "${precise}"=="HIGH"  Get Unique ID High Precise  prefix=${prefix}   suffix=${suffix}
    ...   ELSE   Get Unique ID LOW Precise   prefix=${prefix}   suffix=${suffix}
    RETURN    ${rtn}

Get Unique ID High Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id}    String.Replace String    ${unique_id}    -    ${EMPTY}
    RETURN    ${prefix}${unique_id}${suffix}

Get Unique ID LOW Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    RETURN    ${prefix}${unique_id}${suffix}

Kill Master RCPSDL Pod Should Be Sucessful
    vCU Master rcpsdl pod killed and recovery

vCU Master RCPSDL Pod Killed And Recovery
    ${rcpsdl_role}  ${master_rcpsdl_index}    vCU Get RCPSDL Role And Master Index

    ${master_rcpsdl_restart_times}    Get vCU Pod Restart Times    pod_abbr=rcpsdl    pod_index=${master_rcpsdl_index}

    log to console    start to kill master rcpsdl pod
    Trigger vCU Pods Restart By Killing Ministarter     pod_abbr=rcpsdl    con_abbr=rcpsdl    pod_index=${master_rcpsdl_index}

    log to console   wait master rcpsdl pod recovery...
    wait until keyword succeeds    3min    5s     Check Pods and Containers Status With Tenant for vCU
    sleep    30s
    ${master_rcpsdl_restart_times_after_recovery}   Get vCU Pod Restart Times    pod_abbr=rcpsdl    pod_index=${master_rcpsdl_index}
    ${expected_master_rcpsdl_restart_times_after_recovery}    Evaluate    int(${master_rcpsdl_restart_times}[0])+${1}
    should be true    ${expected_master_rcpsdl_restart_times_after_recovery}==${master_rcpsdl_restart_times_after_recovery[0]}
    ...    msg=Master rcpsdl pod recovery failed
    ${rcpsdl_role_after_covery}    wait until keyword succeeds   3min  5s   vCU Get RCPSDL Role Status
    log to console    after recovery: ${rcpsdl_role_after_covery}
    should not be equal    ${rcpsdl_role_after_covery['master']}    ${rcpsdl_role['master']}   msg=Master rcpsdl pod switch failed

Check Pods and Containers Status With Tenant for vCU
    [Arguments]    ${gnb_index}=0
    [Documentation]  Check vCU pods and containers status
    ...   author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vcu_scf} | Get VCU Scf File From Test Line |
    ${pods_info}=    Get Pods Full Info from vCU   gnb_index=${gnb_index}
    ${itmes}   get dictionary items  ${pods_info}
    FOR  ${pod}  ${pods_values}  IN  @{itmes}
        Should Be Equal    ${pods_values}[status]   Running
        @{split_ready}=    Split String    ${pods_values}[ready]    /
        Should Be Equal    ${split_ready[0]}     ${split_ready[1]}

    END

Get Pods Full Info from vCU
    [Arguments]    ${pod_name}=all   ${gnb_index}=0
    [Documentation]  get pods full infomation
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ...    *RETURN VALUE*
    ...    pods info dict
    Cluster helm Login With Tenant for vCU   gnb_index=${gnb_index}
    ${ns}    Get CU Namespace From Testline   gnb_index=${gnb_index}
    ${pods_info}=    get_vdu_pods_info    ${pod_name}    namespace=${ns}  # just use get_vdu_pods_info to get vCU pods info
    ${All_Pods_Info}     Set Variable     ${pods_info}
    RETURN  ${All_Pods_Info}
    [Teardown]    helm.helm_master_close

Cluster helm Login With Tenant for vCU
    [Arguments]  ${gnb_index}=0
     [Documentation]    helm connect to CU cluster with tenant permission
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:        <07-12-2021>, <luofei.tu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the connection alias used to execute command later.
    ...    Example
    ...    |  Cluster helm Login With Tenant for vCU  |    |
    ${conn}=    helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  22
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    RETURN   ${conn}

Trigger vCU Pods Restart By Killing Ministarter
    [Arguments]  ${pod_abbr}  ${con_abbr}   ${gnb_index}=0   ${pod_index}=0
    [Documentation]    trigger vDU pod restart by killing ministarter process,
    ...    connect and disconnect to OE are included in this keyword.
    ...    *AUTHOR*  luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | con_abbr | Yes | container name appreviation, eg, rcpsdl |
    ...    | pod_index | No | pod index if there are many pod, like 0 for rcpsdl-0 |
    ...    | gnb_index | No | gnb_index. Default value is 0 |

    ...    *RETURN VALUE*
    ...    None

     ${nsp}   Get CU Namespace From TestLine   gnb_index=${gnb_index}
     ${ns}    set variable    ${nsp}
     ${alias}   Connect To K8S Master CU With Tenant   gnb_index=${gnb_index}
     ${command}=   set variable   kill 1
     ${out}   CU Kubectl Exec SDL  pod_abbr=${pod_abbr}  container=${con_abbr}  command=${command}  alias=${alias}   gnb_index=${gnb_index}
     ...   pod_index=${pod_index}
    [Teardown]  Run Keyword And Ignore Error    Interactive Connection Disconnect  alias=${alias}

Get vCU Pod Restart Times
    [Arguments]  ${pod_abbr}   ${pod_index}=0   ${gnb_index}=0

    [Documentation]    get vdu pod restart times, connect and disconnect to OE are included in this keyword.
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | pod_index | No | pod index if there are many pod, like 0 for rcpsdl-0 |
    ...    | gnb_index | No | vdu_index. Default value is 0 |

    ...    *RETURN VALUE*
    ...    the pod restart times

    ${nsp}   Get CU Namespace From TestLine   gnb_index=${gnb_index}
    ${ns}    set variable  ${nsp}
    ${alias}   Connect To K8S Master CU With Tenant   gnb_index=${gnb_index}
    ${cmd}   set variable    kubectl get pods -n ${ns}|egrep "(-${pod_abbr}-${pod_index})" | awk '{print $4}'
    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${nr_reset}   strip prompt  ${out}

    ${num_reset}    Split To Lines   ${nr_reset}
    Remove From List    ${num_reset}   0

    RETURN   ${num_reset}
    [Teardown]  Run Keyword And Ignore Error    Interactive Connection Disconnect  alias=${alias}

vCU Get RCPSDL Role And Master Index
    ${rcpsdl_role}=    create dictionary
    ${rcpsdl_role}    wait until keyword succeeds   3min  5s   vCU Get RCPSDL Role Status
    @{values}    String.Split String    ${rcpsdl_role['master']}    -
    ${master_rcpsdl_index}    Set Variable    ${values[-1]}
    RETURN   ${rcpsdl_role}   ${master_rcpsdl_index}

vCU Get RCPSDL Role Status
     [Arguments]  ${gnb_index}=${0}
     [Documentation]    get the RCPSDL pods role type, connect and disconnect to OE are included in this keyword.
    ...    *AUTHOR*  luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index. Default value is 0 |

    ...    *RETURN VALUE*
    ...    dict like: {'master': 'po-cran3-rcpsdl-0', 'slave': ['po-cran3-rcpsdl-1', 'po-cran3-rcpsdl-2']}

     ${nsp}   Get CU Namespace From TestLine   gnb_index=${gnb_index}
     ${ns}    set variable    ${nsp}
     ${alias}  Connect To K8S Master CU With Tenant   gnb_index=${gnb_index}
     ${rcpsdl_pods_name_list}=   __Get All RCPSDL Pods Name   ${ns}   ${alias}

     ${rcpsdl_role_status}=   vCU Determine RCPSDL Role   ${rcpsdl_pods_name_list}   ${ns}   ${alias}   ${gnb_index}
     RETURN  ${rcpsdl_role_status}
     [Teardown]  Run Keyword And Ignore Error    Interactive Connection Disconnect  alias=${alias}

Connect To K8S Master CU With Tenant
    [Arguments]  ${gnb_index}=0   ${width}=${None}   ${timeout}=300
    [Documentation]    connect to CU K8S cluster with tenant permission
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:        <06-23-2021>, <calwang>, <initial created>
    ...    history change: 29.9.2021,chris.l.cao@nokia-sbell.com, set more strict prompt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the connection alias used to execute command later.
    ...    Example
    ...    |  Connect To CU K8S Master With Admin  |    |
    ${host_ip}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}=  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${prompt}  set variable   ${VCU_OE_SERVER_PROMPT_TENANT}|${VCU_CONTAINER_PROMPT}|\\[${username}@.*\\]\\$
    ${alias}=  get unique id
    issh.Connect_To
    ...   ip=${host_ip}
    ...   username=${username}
    ...   password=${password}
    ...   prompt=${prompt}
    ...   width=${width}
    ...   alias=${alias}
    ...   timeout=${timeout}
    RETURN  ${alias}

__Get All RCPSDL Pods Name
    [Arguments]  ${ns}  ${conn_alias}
    ${cmd}   set variable  kubectl get pods -n ${ns}
    ${out}   issh.Execute   command=${cmd}   alias=${conn_alias}
    ${out_conv}     Split To Lines   ${out}
    Remove From List    ${out_conv}   0
    should be true   "No resources found" not in """${out_conv}[0]"""
    ${cmd}   set variable  ${cmd} | egrep "(-rcpsdl-)" | awk '{print $1}'
    ${out}   issh.Execute  command=${cmd}   alias=${conn_alias}
    ${out}   strip prompt  ${out}
    ${rcpsdl_pods_name_list}     Split To Lines   ${out}
    Remove From List    ${rcpsdl_pods_name_list}   0
    RETURN  ${rcpsdl_pods_name_list}

vCU Determine RCPSDL Role
    [Arguments]  ${rcpsdl_pods_list}   ${ns}   ${conn_alias}   ${gnb_index}=0
    ${command}=   set variable   redis-cli -h rcpsdl-announce-0 -p 26379 sentinel get-master-addr-by-name session
    ${out}   CU Kubectl Exec SDL  pod_abbr=rcpsdl  container=rcpsdl  command=${command}  alias=${conn_alias}   gnb_index=${gnb_index}
    ${lines}    Split To Lines   ${out}
    Remove From List    ${lines}    0
    ${master_rcpsdl_ip}   Set Variable   ${lines[0].split()[1].strip()}
    ${cmd}   set variable   kubectl get svc -n ${ns}|grep rcpsdl|grep ${master_rcpsdl_ip} |awk '{print $1}'
    ${out}   issh.Execute  command=${cmd}   alias=${conn_alias}
    ${out}   strip prompt  ${out}
    ${master_rcpsdl_announce}   Set Variable  ${out.strip()}
    ${words}=  split string  ${master_rcpsdl_announce}  -
    ${master_rcpsdl_index}    set variable  ${words[-1]}
#    ${master_rcpsdl_pod}   set variable   po-${ns}-rcpsdl-${master_rcpsdl_index}
    ${master_rcpsdl_pod}   set variable   ${pod_prefix}-rcpsdl-${master_rcpsdl_index}
    remove values from list    ${rcpsdl_pods_list}   ${master_rcpsdl_pod}
    ${rcpsdl_role_status}    Create Dictionary
#    set to dictionary   ${rcpsdl_role_status}   master  po-${ns}-rcpsdl-${master_rcpsdl_index}
    set to dictionary   ${rcpsdl_role_status}   master  ${pod_prefix}-rcpsdl-${master_rcpsdl_index}
    set to dictionary   ${rcpsdl_role_status}   slave  ${rcpsdl_pods_list}
    RETURN  ${rcpsdl_role_status}

CU Kubectl Exec SDL
    [Arguments]  ${pod_abbr}   ${container}   ${command}   ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
    ...  ${pod_index}=0
    [Documentation]  execute kubectl exec command in CU cluster
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    26.7.2021,luofei.tu@nokia-sbell.com, add sudo for cbis-admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | command | Yes. | the command need to be executed. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...    | pod_index | No | pod index if there are many pod, like 0 for rcpsdl-0 |

    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${output}= | CU Kubectl Exec | oamcm | oamcm | date | ${alias} |
    ...    | Interactive Connection Disconnect | ${alias} |

    ${nsp}   Get CU Namespace From Testline  ${gnb_index}
    ${ns}    Set Variable  ${nsp}
    ${sudo_outer}  Get Sudo For Current vCU User   alias=${alias}

#    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl exec -it po-${ns}-${pod_abbr}-${pod_index} -c ctr-${ns}-${container} -n ${ns} -- ${command}
    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl exec -it ${pod_prefix}-${pod_abbr}-${pod_index} -c ctr-${container} -n ${ns} -- ${command}
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${check_result}   alias=${alias}
    ${out}   strip prompt  ${out}
    RETURN  ${out}

Get Sudo For Current vCU User
    [Arguments]  ${alias}=default
    [Documentation]   Get Sudo For Current vCU User
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias | no | alias, default value is default  |
    ...
    ...    *RETURN VALUE*
    ...   if current login name is cbis-admin, return sudo. if current login name is root, return ${EMPTY}, otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For Current vCU User | alias=myalias |
    ...
    ${current_user_name}   cu_trs_conn.Get Current User Name Interactively   alias=${alias}
    ${sudo}   set variable if   "${current_user_name}"=="cbis-admin"   sudo
        ...   "${current_user_name}"=="root"   ${EMPTY}
        ...   ${EMPTY}
    RETURN   ${sudo}

Interactive Connection Disconnect
    [Arguments]  ${alias}=default
    [Documentation]   Interactive Connection Disconnect for specifical connection identified by alias name
    ...   *Author*:chris.l.cao@nokia-sbell.com
    ...   *History Change*:
    ...   | date | who | what and how |
    ...   | 2022-02-15 | chris.l.cao@nokia-sbell.com | add WA for https://jiradc.ext.net.nokia.com/browse/RCP-2176
    ...                                          When this jira is solved, this WA can be removed. |
    ...   | 2022-03-31 | r3li | update documentation |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | No | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${out} | issh.Execute | command=pwd |
    ...    | Interactive Connection Disconnect |
    ...
    ...    | Connect To K8s Master Interactively | alias=alias2 |
    ...    | ${out} | issh.Execute | command=pwd | alias=alias2 |
    ...    | Interactive Connection Disconnect | alias=alias2 |
    ...
    should not be empty   ${alias}

    Run Keyword And Ignore Error   Exit Container   alias=${alias}
    issh.disconnect  alias=${alias}

Exit Container
    [Arguments]  ${alias}
    [Documentation]   Exit Container
    ...    *Author*:chris.l.cao@nokia-sbell.com
    ${r}  ${cur_prompt}=    Run Keyword And Ignore Error   issh.get_prompt   alias=${alias}
    Return From Keyword If    '${r}'=='FAIL'
    ${expr_vdu_admin}    Set Variable   "${cur_prompt}"!="${VDU_OE_SERVER_PROMPT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}"
    ${expr_vdu_tenant}   Set Variable   "${cur_prompt}"!="${VDU_OE_SERVER_PROMPT_TENANT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}"
    ${expr_vcu_tenant}   Set Variable   "${cur_prompt}"!="${VCU_OE_SERVER_PROMPT_TENANT}|${VCU_CONTAINER_PROMPT}"
    Return From Keyword If   ${expr_vdu_admin} and ${expr_vdu_tenant} and ${expr_vcu_tenant}
    ${out}    issh.Execute   command=ls  check_result=${False}  alias=${alias}
    ${match}  Get Regexp Matches  ${out}   ${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}|${VCU_CONTAINER_PROMPT}
    ${out}    Run Keyword If   ${match.__len__()}>0    issh.Execute   command=exit  check_result=${False}  alias=${alias}

_Is ADB Device Connected
    [Arguments]  ${alias}    ${serial_number}
    [Documentation]  Check the UE device connection status.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | Yes |  the connection alias |
    ...    |  serial_number  | Yes |  the ue serial number |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Is ADB device connected  |  |
    tafssh.send_command   command=adb devices    connection=${alias}    timeout=5
    BuiltIn.Sleep   3s
    ${result}    tafssh.read output    connection=${alias}
    Should contain   ${result}   ${serial_number}
    should not contain  ${result}   connecting
