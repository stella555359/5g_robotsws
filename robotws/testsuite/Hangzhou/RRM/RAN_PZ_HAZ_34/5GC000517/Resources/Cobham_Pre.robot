*** Settings ***
Documentation    This is related with cobham UE L3 call
...              Author: Ding Binmei
...              Squard: HZ MMW_SG1
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot

*** Keywords ***
#-----------------Connections
Retry ue attach if failed
    [Timeout]    10 min
    [Documentation]    Author: Ding Binmei [Deprecated]
    ...               Will retry detach and attach if attach failed. Max retry time is 10
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${retry_time}=${10}    ${e500_alias}=${TMA_APP_ALIAS}
    ...    ${is_need_to_check_mul_drb_established}=${False}    ${mul_drb_code_stream}=142D28DFAFC7370CD311FAFC7370CC28

    viavi_common_keyword.Cobham retry ue attach if failed    e500_script_path=${e500_script_path}    retry_time=${retry_time}
    ...    e500_alias=${e500_alias}    is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
    ...    mul_drb_code_stream=${mul_drb_code_stream}

Cobham UE attach
    [Timeout]  10 min
    [Documentation]    Author: Ding Binmei
    ...                Description: UE attach on cobham
    ...                Logic: 1. Kill tma process in case manual forget about this step
    ...                       2. Open tma software and run init_config script to connect to cobham
    ...                       3. Start logging on cobham so that protocol logs are captured
    ...                       4. Run cell config script and do ue attach( Will retry 10 times if attach failed)
    ...                       5. ${UE_IP} will get this ip if attach successfully
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}
    ...            ${tma_path}=${TMA_APP_PATH}
    Precondition for attach    e500_script_path=${e500_script_path}    tma_path=${tma_path}
    Cobham Retry ue attach if failed    e500_script_path=${e500_script_path}

Cobham multiple UEs attach
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to perform tm500 attach for multiple UEs and return with their IP addresses.
    ...    ${number_of_ue} specify the number of UEs.
    ...    Each UE attach will attempt for ${retry_time}, if one of them fail to attach after retry times, this keyword will fail.
    ...    ${UE_IP_LIST} contains all UEs' IP addresses, and will be set as TEST varilble after all UEs attach successfully.
    ...    2020-2-29 Ding Binmei: Added ${is_cell_config_update_needed}: if ${True} then cell config script need to be executed for each UE;
    ...        If ${False}, then it means for all ues they can use the same cell config file.
    [Arguments]    ${number_of_ue}    ${e500_script_path_multi_ue}=${E500_SCRIPTS_MULTI_UE}    ${retry_time}=${10}
    ...    ${e500_alias}=${TMA_APP_ALIAS}    ${is_cell_config_update_needed}=${False}
    ...    ${is_need_to_check_mul_drb_established}=${False}    ${mul_drb_code_stream}=142D28DFAFC7370CD311FAFC7370CC28
    ${ue_ip_list}    create list
    FOR    ${i}    IN RANGE    ${number_of_ue}
        Run keyword if    ${is_cell_config_update_needed}    tm500_hangzhou.Perform cell search
        ...    cell_search_script_path=${e500_script_path_multi_ue}/script_ue${i}/NSA_5G_Cell_Config.txt    tm500_alias=${e500_alias}
        Cobham retry ue attach if failed    e500_script_path=${e500_script_path_multi_ue}/script_ue${i}    retry_time=${retry_time}
        ...    e500_alias=${e500_alias}    is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
        ...    mul_drb_code_stream=${mul_drb_code_stream}
        append to list    ${ue_ip_list}    ${UE_IP}
    END
    [Return]    ${ue_ip_list}

Cobham multiple UEs detach
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to detach multiple UEs.
    ...    ${number_of_ue} specify the number of UEs.
    [Arguments]    ${number_of_ue}    ${e500_script_path_multi_ue}=${E500_SCRIPTS_MULTI_UE}
    FOR    ${i}    IN RANGE    ${number_of_ue}
        tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}
        ...    detach_script_path=${e500_script_path_multi_ue}/script_ue${i}/NSA_5G_UEdetach.txt
    END
    [Teardown]    tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}

Iperf send DL traffic with real epc for multiple UEs
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to send DL traffic for multiple UEs on app server.
    ...    ${number_of_ue} specify the number of UEs.
    ...    ${UE_IP_LIST} is returned from multiple UE attach
    ...    Need to configure iperf path to cygwin
    ...    DL port value range: 54000~55000
    [Arguments]    ${number_of_ue}    ${throughput}    ${traffic_time}    ${dl_port}    ${dl_host_ip_list}=${UE_IP_LIST}
    Log to console    Start DL traffic with real epc
    ${number_of_ue_ip}    get length    ${dl_host_ip_list}
     FOR    ${i}    IN RANGE    ${number_of_ue}
         Iperf send DL traffic with real epc    port=${dl_port}    dl_host_ip=${dl_host_ip_list[${i}]}
         ...    throughput=${throughput}    traffic_time=${traffic_time}
     END

Iperf send UL traffic with real epc for multiple UEs
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to send UL traffic for multiple UEs to app server.
    ...    ${number_of_ue} specify the number of UEs.
    ...    ${ul_host_ip} will default to 192.168.10.70
    ...    ${ul_port_list} is the port configured for each UE in cobham script. It could be 5410, 5411, 5412...
    [Arguments]    ${number_of_ue}    ${throughput}    ${traffic_time}    ${ul_port_list}    ${ul_host_ip}=192.168.10.70    ${length}=${1024}
    FOR    ${i}    IN RANGE    ${number_of_ue}
        Iperf send UL traffic with real epc    throughput=${throughput}    traffic_time=${traffic_time}    port=${ul_port_list[${i}]}
        ...    ul_host_ip=${ul_host_ip}    length=${length}
    END

