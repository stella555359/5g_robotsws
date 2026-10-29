*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Test Setup      Common Test Setup For AIC
Test Teardown    Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot




*** Test Cases ***
################################ PA module template #################################
PA_Source
    [Tags]    CRT    TC02
    ${source_pa_port_list}     Create List     1    2    17    18    35
    ${source_pa_value_list}    Create List     23    61
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=none

PA_Target
    [Tags]    CRT    TC05
    ${target_pa_port_list}     Create List    37-39   53    54-55
    ${target_pa_value_list}    Create List    59    26
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=none    target=&{target}

PA_Both
    [Tags]    CRT    TC06
    ${source_pa_port_list}     Create List     1    18
    ${source_pa_value_list}    Create List     0    40
    ${target_pa_port_list}     Create List    37    54
    ${target_pa_value_list}    Create List    63    30
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=&{target}

################################ Airphone module template #################################
Airphone_Env_Setup_gnb
    [Tags]    TC01
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=SA_HO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

Swconfig
    [Tags]    swconfig
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=swconfig
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=SA_HO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=300s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s


Airphone_Traffic_DLUL
     [Tags]    traffic
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=cloud
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=dlul
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=999    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                                product_type=${None}
    ...                                                                traffic_info_dic=${traffic_info_dic}
    ...                                                                tag=${None}
    ...                                                                cmd=${None}
    ...                                                                pass_regexp=${None}
    ...                                                                timeout=600s
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ...                   pass_regexp=PDU SESSION RESOURCE MODIFY RESPONSE
    ...                   timeout=100s
    ${traffic_info_dic}    Create Dictionary    ue_id=1    bearer_id=2    dir=dlul    trf_id=1
    Airphone Operation    operation=stop_traffic
    ...                   product_type=${None}
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1
    Airphone Operation    operation=detach
    ...                   product_type=${None}
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=aplog
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s


Env_Setup_Cloud_With_Default
    [Tags]    TC07
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

UL_Traffic
    [Tags]    ul
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=SA_HO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=ul
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                                product_type=${None}
    ...                                                                traffic_info_dic=${traffic_info_dic}
    ...                                                                tag=${None}
    ...                                                                cmd=${None}
    ...                                                                pass_regexp=${None}
    ...                                                                timeout=600s
    ${output}     Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ...                   pass_regexp=PDU SESSION RESOURCE MODIFY RESPONSE
    ...                   timeout=100s
    ${traffic_info_dic}    Create Dictionary    ue_id=1    bearer_id=2    dir=ul    trf_id=1
    Airphone Operation    operation=stop_traffic
    ...                   product_type=${None}
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1
    Airphone Operation    operation=detach
    ...                   product_type=${None}
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=aplog
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s


DL_Traffic
    [Tags]    dl
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=SA_HO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=dl
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_dl=178m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                                product_type=${None}
    ...                                                                traffic_info_dic=${traffic_info_dic}
    ...                                                                tag=${None}
    ...                                                                cmd=${None}
    ...                                                                pass_regexp=${None}
    ...                                                                timeout=600s
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ...                   pass_regexp=PDU SESSION RESOURCE MODIFY RESPONSE
    ...                   timeout=100s
    ${traffic_info_dic}    Create Dictionary    ue_id=1    bearer_id=2    dir=dl    trf_id=1
    Airphone Operation    operation=stop_traffic
    ...                   product_type=${None}
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1
    Airphone Operation    operation=detach
    ...                   product_type=${None}
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=aplog
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
