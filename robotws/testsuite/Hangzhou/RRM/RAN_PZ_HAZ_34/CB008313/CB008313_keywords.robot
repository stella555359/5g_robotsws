# @Time    : 2022/1/10 10:15
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB008313_keywords.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    CB008313_precondition.robot

*** Keywords ***
UE Attach And Check Traffic With Wireshark Log
    [Documentation]  Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    ul_tp : 100M
    ...    ul_tp_threshold : 50
    ...    dl_tp : 200M
    ...    dl_tp_threshold : 100
    ...    cellid : 178520065
    ...    remote_pacp_path : /tmp/tmp.pcap
    ...    local_pcap_path : /home/ute/tmpcj/CB008313/case201.pcap
    [Arguments]    ${ul_tp}    ${ul_tp_threshold}    ${dl_tp}    ${dl_tp_threshold}    ${cellid}
    ...    ${local_pcap_path}    ${attach_mode}    ${ue_index}=0
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Start To Capture Wireshark Log From DU
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=600    iperf_type=via_command
    UE Start DL Traffic    throughput=${dl_tp}
    power_ue.Check throughput    ue_index=${ue_index}    direction=ul    ue_type=${ue_type}    throughput=${ul_tp_threshold}
    ...    cellid=${cellid}
    power_ue.Check throughput   ue_index=${ue_index}    direction=dl    ue_type=${ue_type}    throughput=${dl_tp_threshold}
    ...    cellid=${cellid}
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    Stop To Capture Wireshark Log From DU    local_pcap_path=${local_pcap_path}

Verify Rach Config Generic Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${local_pcap_path}    ${alias}=for8313
    Connect to gnb coam via ssl
    @{MOs}    coam.get_managed_objects    class_name=NRCELL_A    connection=GNB_OAM
    FOR    ${cell}    IN  @{MOs}
        ${dist_name}    Set Variable    ${cell['distName']}
        ${first}    ${cell_name}    Split String From Right    ${dist_name}    /    1
        Exit For Loop If    '${cell_name}' == 'NRCELL_A-1'
    END
    &{dict_pattern}    coam.get_parameters    dist_name=${dist_name}    connection=GNB_OAM

    cap.setup    infile=${local_pcap_path}    tshark_path=${TSHARK_PATH}    alias=${alias}
    cap.get_packets    pcap_parser=${alias}
    
    ${prach_ConfigurationIndex}    cap.get_field_value    field_name=nr-rrc.prach_ConfigurationIndex    pcap_parser=${alias}
    Should Contain    '${prach_ConfigurationIndex[-1][-1]}'    '${dict_pattern['prachConfigurationIndex']}'
    ${msg1_FDM}    cap.get_field_value    field_name=nr-rrc.msg1_FDM    pcap_parser=${alias}    fmt=showname
    Should Contain    ${msg1_FDM[-1][-1]}    ${dict_pattern['nbrOfSsbPerRachOccasion']}
    ${msg1_FrequencyStart}    cap.get_field_value    field_name=nr-rrc.msg1_FrequencyStart    pcap_parser=${alias}
    Should Contain    '${msg1_FrequencyStart[-1][-1]}'    '${dict_pattern['msg1FrequencyStart']}'
    ${zeroCorrelationZoneConfig}    cap.get_field_value    field_name=nr-rrc.zeroCorrelationZoneConfig    pcap_parser=${alias}
    Should Contain    '${zeroCorrelationZoneConfig[-1][-1]}'    '${dict_pattern['zeroCorrelationZoneConfig']}'
    ${preambleReceivedTargetPower}    cap.get_field_value    field_name=nr-rrc.preambleReceivedTargetPower    pcap_parser=${alias}
    Should Contain    '${preambleReceivedTargetPower[-1][-1]}'    '${dict_pattern['initialPreambleReceivedTargetPower']}'
    ${preambleTransMax}    cap.get_field_value    field_name=nr-rrc.preambleTransMax    pcap_parser=${alias}    fmt=showname
    Should Contain    ${preambleTransMax[-1][-1]}    ${dict_pattern['preambleTransMax']}
    ${powerRampingStep}    cap.get_field_value    field_name=nr-rrc.powerRampingStep    pcap_parser=${alias}    fmt=showname
    Should Contain    ${powerRampingStep[-1][-1]}    ${dict_pattern['powerRampingStep']}
    ${ra_ResponseWindow}    cap.get_field_value    field_name=nr-rrc.ra_ResponseWindow    pcap_parser=${alias}    fmt=showname
    Should Contain    ${ra_ResponseWindow[-1][-1]}    ${dict_pattern['raResponseWindow']}
    [Teardown]    COAM Teardown gnb connections

Check The Prach PM Counters
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${counter_path}=BTS/CELLS/NRCELL-1/NRACH    ${counter1_id}=M55306C06001    ${counter2_id}=M55306C00001
    ...    ${counter3_id}=M55306C03001    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${counter1_value_list}    get_pm_counter_values    counter_id=${counter1_id}    connection=${connection}
    ...    dic_path=${counter_path}    date=all
    ${counter2_value_list}    get_pm_counter_values    counter_id=${counter2_id}    connection=${connection}
    ...    dic_path=${counter_path}    date=all
    ${counter3_value_list}    get_pm_counter_values    counter_id=${counter3_id}    connection=${connection}
    ...    dic_path=${counter_path}    date=all
    ${length}    Get Length    ${counter1_value_list}
    FOR    ${index}    IN RANGE  ${length}
        ${back_index}    Evaluate    ${index} - ${length}
        ${counter1_value}    Set Variable    ${counter1_value_list}[${back_index}]
        ${counter2_value}    Set Variable    ${counter2_value_list}[${back_index}]
        ${counter3_value}    Set Variable    ${counter3_value_list}[${back_index}]
        Exit For Loop If    ${counter1_value} == 1
    END
    Should Be True    ${counter2_value} > 0
    Should Be True    ${counter3_value} > 0
    [Teardown]    coam.teardown    connection=GNB_OAM

Verify Target Prach Available
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${prach_configuration_index}    ${ul_tp}    ${ul_tp_threshold}    ${dl_tp}    ${dl_tp_threshold}
    ...    ${cellid}    ${local_pcap_path}    ${attach_mode}
    Modify PrachConfigurationIndex With Cell Lock Unlock    value=${prach_configuration_index}
    UE Attach And Check Traffic With Wireshark Log    ul_tp=${ul_tp}    ul_tp_threshold=${ul_tp_threshold}
    ...    dl_tp=${dl_tp}    dl_tp_threshold=${dl_tp_threshold}    cellid=${cellid}
    ...    local_pcap_path=${local_pcap_path}    attach_mode=${attach_mode}
    Check The Prach PM Counters
    Verify Rach Config Generic Normal    local_pcap_path=${local_pcap_path}

Verify Target Prach List Available
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${prach_configuration_index_list}    ${ul_tp}    ${ul_tp_threshold}    ${dl_tp}    ${dl_tp_threshold}
    ...    ${cellid}    ${local_pcap_path}    ${attach_mode}
    FOR    ${prach_configuration_index}    IN    @{prach_configuration_index_list}
        Wait Until Keyword Succeeds    3x    5s    Verify Target Prach Available
        ...    prach_configuration_index=${prach_configuration_index}
        ...    ul_tp=${ul_tp}    ul_tp_threshold=${ul_tp_threshold}
        ...    dl_tp=${dl_tp}    dl_tp_threshold=${dl_tp_threshold}
        ...    cellid=${cellid}    local_pcap_path=${local_pcap_path}    attach_mode=${attach_mode}
    END
