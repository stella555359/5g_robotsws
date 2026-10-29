*** Settings ***
Documentation
...   Author:
...   Contact:
...   Description: This is the Airphone module test cases

Resource                ../Airphone_Operation.robot
Resource                ../Module.robot
#Resource                ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot

#Suite Setup             Common MultiBTS Suite Setup For RRM
#Test Setup              Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#Test Teardown           Common MultiBTS Test Teardown For RRM
#Suite Teardown          Common MutliBTS Suite Teardown For RRM

Force Tags        RAN_VRF_HAZ1

Test Timeout      60 minutes


*** Test Cases ***
TC01_Env_Setup_gnb
    [Tags]    TC01
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s


TC02_swconfig
    [Tags]    TC02
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

TC03_Traffic
    [Tags]    TC03
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
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


TC04_Env_Setup_Multi
    [Tags]    TC04
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=Multi
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

TC05_swconfig_multi_gnb
    [Tags]    TC05
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
    ...                   tag=Multi
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=300s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s


TC06_Env_Setup_Cloud
    [Tags]    TC06
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
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

TC07_Env_Setup_Cloud
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

TC08_Traffic
    [Tags]    TC08
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

TC09_Traffic
    [Tags]    TC09
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
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

TC10_Traffic
    [Tags]    TC10
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=SA_HO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=uldl
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                                product_type=${None}
    ...                                                                traffic_info_dic=${traffic_info_dic}
    ...                                                                tag=${None}
    ...                                                                cmd=${None}
    ...                                                                pass_regexp=${None}
    ...                                                                timeout=600s
    ${output}    Airphone Operation    operation=send_common_command
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

TC11_Traffic
    [Tags]    TC11
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=uldl
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                  product_type=${None}
    ...                                                  traffic_info_dic=${traffic_info_dic}
    ...                                                  tag=${None}
    ...                                                  cmd=${None}
    ...                                                  pass_regexp=${None}
    ...                                                  timeout=600s
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ...                   pass_regexp=${None}
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
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}

TC12_Traffic
    [Tags]    TC12
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=uldl
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                  product_type=${None}
    ...                                                  traffic_info_dic=${traffic_info_dic}
    ...                                                  tag=${None}
    ...                                                  cmd=${None}
    ...                                                  pass_regexp=${None}
    ...                                                  timeout=600s
    ${Tput_dict}    Airphone Operation    operation=check_traffic
    ...                                                  product_type=${None}
    ...                                                  traffic_info_dic=${traffic_info_dic}
    ...                                                  tag=${None}
    ...                                                  cmd=${None}
    ...                                                  pass_regexp=${None}
    ...                                                  timeout=600s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}

TC13_Traffic
    [Tags]    TC13
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=dl
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                  product_type=${None}
    ...                                                  traffic_info_dic=${traffic_info_dic}
    ...                                                  tag=${None}
    ...                                                  cmd=${None}
    ...                                                  pass_regexp=${None}
    ...                                                  timeout=600s
    ${Tput_dict}    Airphone Operation    operation=check_traffic
    ...                                                  product_type=${None}
    ...                                                  traffic_info_dic=${traffic_info_dic}
    ...                                                  tag=${None}
    ...                                                  cmd=${None}
    ...                                                  pass_regexp=${None}
    ...                                                  timeout=600s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}

TC14_Traffic
    [Tags]    TC14
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=ul
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                                  product_type=${None}
    ...                                                  traffic_info_dic=${traffic_info_dic}
    ...                                                  tag=${None}
    ...                                                  cmd=${None}
    ...                                                  pass_regexp=${None}
    ...                                                  timeout=600s
    ${Tput_dict}    Airphone Operation    operation=check_traffic
    ...                                                  product_type=${None}
    ...                                                  traffic_info_dic=${traffic_info_dic}
    ...                                                  tag=${None}
    ...                                                  cmd=${None}
    ...                                                  pass_regexp=${None}
    ...                                                  timeout=600s
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}

TC15_Env_Setup_gnb
    [Tags]    TC15
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=RJIO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ...                   customer=RJIO
    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

