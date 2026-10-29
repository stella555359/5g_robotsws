*** Settings ***
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library    taf.ccs.aashell   WITH NAME    aashell
Library    taf.collectors.dcap       WITH NAME    dcap

Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    release: 24R2

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Enable AiC DCAP Params
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Set Internal Traffic Type To UEs


Test Teardown     Run Keywords        Deregister Multiple Ues   first_ue_id=1    last_ue_id=6
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   120s
${WAIT_FOR_L2_TRACES_COLLECTORS}=    3min
${unzip_vdu_dcap_path}=    ${OUTPUT DIR}/CB009917/CB009917_L2Hi_streaming/dcap/dcap_vdu
${vdu_dcap_path}=    ${OUTPUT DIR}/CB009917/CB009917_L2Hi_streaming/dcap/dcap_vdu/dcap.zip
${unzip_vcu_dcap_path}=    ${OUTPUT DIR}/CB009917/CB009917_L2Hi_streaming/dcap/dcap_vcu
${vcu_dcap_path}=    ${OUTPUT DIR}/CB009917/CB009917_L2Hi_streaming/dcap/dcap_vcu/dcap.zip

*** Test Cases ***
CB009917_L2Hi_streaming
    Get TL config
    Perform OVL via R&D mechanism      value_of_RdAvgL2HICPULoadThreshStream=1
    Collect U-plane Traces
    Attach Multiple Ues And Establish Session
    Start 10Mbps Ul And Dl Data Traffic For All Ues
    Stop Collect U-plane Traces
    Check If L2 Traces Not Exist
    Collect U-plane Traces
    Perform OVL via R&D mechanism      value_of_RdAvgL2HICPULoadThreshStream=95
    Sleep  ${WAIT_FOR_L2_TRACES_COLLECTORS}
    Display Ue Statistics
    Stop Collect U-plane Traces
    Check If L2 Traces Exist


*** Keywords ***
Attach Multiple Ues And Establish Session
   ${alias}=    Start Tshark For Custom Interface  eth_interface=eth7
    Attach Multiple Ues    first_ue_id=1    last_ue_id=6
    Set Pdu Session To Multiple Ues

Start 10Mbps Ul And Dl Data Traffic For All Ues
   Start Data Traffic To Multiple Ues   num_of_ues=6  tput=10

Display Ue Statistics
    Sleep  ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats For Multiple Ues
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check Data Traffic
    Display Ue Statistics
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.2    direction=bi

Perform OVL via R&D mechanism
    [Arguments]  ${value_of_RdAvgL2HICPULoadThreshStream}

    &{mapping}=    Create Dictionary
    ...    upue=0x5A00A1
    ...    l2nrt=0x5B023C
    &{k8s_CU}=    Create Dictionary
    ...    host=${MASTER_CU}[hostname]
    ...    user=${MASTER_CU}[username]
    ...    password=${MASTER_CU}[password]

    &{k8s_DU}=    Create Dictionary
    ...    host=${MASTER_DU}[hostname]
    ...    user=${MASTER_DU}[username]
    ...    password=${MASTER_DU}[password]

    aashell.create_aashell_cli
    ...    name=aashell_upue
    ...    hops=${k8s_CU}
    ...    namespace=${NAMESPACE_CU}
    ...    pod=ute-${NAMESPACE_CU}-upue-0
    ...    port=15007

    aashell.create_aashell_cli
    ...    name=aashell_l2nrt
    ...    hops=${k8s_DU}
    ...    namespace=${NAMESPACE_DU}
    ...    pod=ute-${NAMESPACE_DU}-l2nrt-0
    ...    port=15007

    aashell.setup    aashell_upue
    aashell.setup    aashell_l2nrt
    ${params_CU}=    Create List
    ...    ${mapping}[upue]  ${value_of_RdAvgL2HICPULoadThreshStream}

    ${params_DU}=    Create List
    ...    ${mapping}[l2nrt]  ${value_of_RdAvgL2HICPULoadThreshStream}

    aashell.change_rad_params    aashell_upue    ${params_CU}    is_permanent=True
    aashell.execute_aashell_command  aashell_upue  command=rad -u

    aashell.change_rad_params    aashell_l2nrt    ${params_DU}    is_permanent=True
    aashell.execute_aashell_command  aashell_l2nrt  command=rad -u

    [Teardown]    Run Keywords
    ...  aashell.teardown   aashell_upue
    ...  AND  aashell.teardown   aashell_l2nrt

Check If L2 Traces Not Exist
   extract_dcap_to_dir    path=${vdu_dcap_path}    dir=${unzip_vdu_dcap_path}
   extract_dcap_to_dir    path=${vcu_dcap_path}    dir=${unzip_vcu_dcap_path}
   ${vdu_traces}=    check_if_l2_trace_present     dir=${unzip_vdu_dcap_path}
   Should Not Be True     ${vdu_traces}
   ${vcu_traces}=    check_if_l2_trace_present     dir=${unzip_vcu_dcap_path}
   Should Not Be True     ${vcu_traces}


Check If L2 Traces Exist
   extract_dcap_to_dir    path=${vdu_dcap_path}    dir=${unzip_vdu_dcap_path}
   extract_dcap_to_dir    path=${vcu_dcap_path}    dir=${unzip_vcu_dcap_path}
   ${vdu_traces}=    check_if_l2_trace_present     dir=${unzip_vdu_dcap_path}
   Should Be True     ${vdu_traces}
   ${vcu_traces}=    check_if_l2_trace_present     dir=${unzip_vcu_dcap_path}
   Should Be True    ${vcu_traces}

