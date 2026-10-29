*** Settings ***

Documentation
...   This is for 1200 TA keywords related to multiple UE tests.
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: SG_04

Resource    ./5GC001200_keywords.robot

*** Keywords ***
#Iperf stop traffic from appserver and ue side  ## could be used for multi ue as unchanged
#Trigger DTX according to given flag/Trigger DTX via pusch data method per UE/Trigger DTX via dlharq feedback
#method per UE/Enable ul power control per UE
#is changed in 1200_keywords.robot

Test Preparation
   [Documentation]    Author: Cui Lingxue
   [Arguments]    ${parameters_to_update_via_api}    ${is_need_to_check_validation_errors}
   ...    ${e500_script_path_multi_ue}    ${number_of_ue}
    coam_gnb_classical.COAM Create log directory
    Online modify nidd parameters via rest api
    ...    1200_other_nidd_modify_via_api=${parameters_to_update_via_api}
    Log to console    Start to prepare cobham, attach UE and data transfer
    Adjust programmable attenuation
    ...    port_of_layer0_ul=${LAYER0_UL_PORT}
    ...    port_of_layer0_dl=${LAYER0_DL_PORT}
    ...    port_of_layer1_ul=${LAYER1_UL_PORT}
    ...    port_of_layer1_dl=${LAYER1_DL_PORT}
    ...    attenuation_of_layer0_ul=${INITIAL_LAYER0_UL_ATTEN}
    ...    attenuation_of_layer0_dl=${INITIAL_LAYER0_DL_ATTEN}
    ...    attenuation_of_layer1_ul=${INITIAL_LAYER1_UL_ATTEN}
    ...    attenuation_of_layer1_dl=${INITIAL_LAYER1_DL_ATTEN}

    Cobham connection and start logging    e500_script_path=${e500_script_path_multi_ue}    connection=${TMA_SSH_ALIAS}

    connection_alias_store.Connect to Common Unit Master     alias=${ASIK_ALIAS}
    Synchron gNB and cobham    alias=${ASIK_ALIAS}
    sleep    10s
    tm500_hangzhou.Perform cell search    cell_search_script_path=${e500_script_path_multi_ue}/NSA_5G_Cell_Config.txt    tm500_alias=${TMA_APP_ALIAS}
    ${UE_IP_LIST}    Cobham multiple UEs attach    number_of_ue=${number_of_ue}    e500_script_path_multi_ue=${e500_script_path_multi_ue}
    ...    e500_alias=${TMA_APP_ALIAS}
    set test variable    ${UE_IP_LIST}
    Iperf send DL traffic with real epc for multiple UEs    number_of_ue=${number_of_ue}    throughput=${10}    traffic_time=${99999}
    ...    dl_port=${IPERF_DL_PORT}    dl_host_ip_list=${UE_IP_LIST}
    Iperf send UL traffic with real epc for multiple UEs    number_of_ue=${number_of_ue}    throughput=${10}    traffic_time=${99999}
    ...    ul_host_ip=${E500_HLS_IP}    ul_port_list=${IPERF_UL_PORT_LIST}
    Sleep   6 s
    FOR    ${ue_index}    IN RANGE    0    ${number_of_ue}
        wait until keyword succeeds    1 min    3s   Evaluate throughput for NR data transfer    direction=dl    dl_data_transfer_exp=${1}
        ...    ue_index=${ue_index}
        run keyword and continue on failure    Evaluate throughput for NR data transfer    direction=ul    ul_data_transfer_exp=${1}
        ...    ue_index=${ue_index}
    END
    wait until keyword succeeds    2 min    10 s    Connect to cobham control pc via ssh    tma_ssh_alias=${TMA_SSH_ALIAS}


Test Teardown
    [Documentation]    Author: Cui Lingxue
    run keyword and continue on failure    Iperf stop traffic from appserver and ue side    port=${IPERF_UL_PORT_LIST_TO_KILL}
    run keyword and continue on failure    Cobham multiple UEs detach    number_of_ue=${NUMBER_OF_UE}
    run keyword and continue on failure    Collect tma logs to test pc
    Run keyword and ignore error    coam_gnb_classical.COAM Verify if alarm exists    connection=${GNB_COAM_ALIAS}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    COAM Save snapshot via webUI
    Run keyword and ignore error    csn.Disconnect    connection=${ASIK_ALIAS}
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections    connection=${GNB_COAM_ALIAS}
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}

