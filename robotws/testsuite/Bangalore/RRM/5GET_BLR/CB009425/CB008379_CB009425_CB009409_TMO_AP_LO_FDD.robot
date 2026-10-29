*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED


Resource         ./CB009409_common_resources.robot

Resource         ./CB009425_Resource_New.robot


Resource         ../resources/robot/common_log_collection.robot


#Resource         ../CB008379/CB008379_Resource.robot
Resource         ./CB008379_Resource.robot
Library   	     taf.sw.scout 	WITH NAME	scout


Documentation
...
...             author:           Samik Sarkar
...             maintainer:       Samik Sarkar



*** Variables ***

#${SCFC}         ${CURDIR}${/}../CB009409/config/SCF/Configuration_scf_PMcounter.xml
#${AP_XML}       ${CURDIR}${/}../CB009409/config/SCF/iphy.xml

#${WTS_DIR}          /opt/iphy/latest
${wts_cfg_default}     ${CURDIR}/config/wts/default_1.cfg
#${wts_cfg_default}     ${CURDIR}/config/wts/default.cfg
${wts_cfg_file_1}     ${CURDIR}/config/wts/default_2.cfg
${wts_cfg_file_2}     ${CURDIR}/config/wts/default_3.cfg
#${wts_cfg_file_1}     ${CURDIR}/config/wts/basic_setup_2.cfg
#&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
#${epc_log_path}    /tmp/
${sa_st_ue_id}      1
${sa_en_ue_id}      1
${nsa_st_ue_id}      110
${nsa_en_ue_id}      120
${scell_idx}    0
${ul_ue_ip}    72.23.0.1
${dl_ue_ip}    1.2.4.2
${dl_port}    7073
${ul_port}    7074
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220

#${wts_cfg_file_2}     ${CURDIR}/config/wts/basic_setup_2CC_max_gfbr_30_fdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${51}
${en_ue_id}      ${52}
${en_ue_id_1}      ${55}
${st_ue}      ${56}
${en_ue}      ${57}
#${wts_cfg_file_3}       ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_fdd_um_mode_8379_c13_2.cfg

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       2          3                #4
@{QOS_Prof2_speed_ul}      1      32         amr_wb_18_25     #30
@{QOS_Prof2_speed_dl}      1      32         amr_wb_18_25     #30
@{QOS_Prof2_unit}          kbps    kbps       rtp_codec        #mbps

@{QOS_Prof3}                1
@{QOS_Prof3_speed_ul}       10
@{QOS_Prof3_speed_dl}       30
@{QOS_Prof3_unit}           mbps


@{QOS_Prof7}               1       2           3                4
@{QOS_Prof7_speed_ul}      10       32         amr_wb_18_25     30
@{QOS_Prof7_speed_dl}      10       32         amr_wb_18_25     30
@{QOS_Prof7_unit}          mbps    kbps        rtp_codec        mbps

*** Test Cases ***

[1]CB008379-5G-C_13_Scheduling_Priority_for_UE_with_5QI1_and_5QI2_GBR_bearers_and_Multiple_UEs_with_a_non-GBR_bearer_FDD

    [Tags]    TC03
    [Setup]         Run keywords     Suite setup from scratch
    ...            AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...            AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_GBR_MultiUE_with_8379_20MHz.json
#    ...            AND     sleep    400
    ...                 AND    Sleep   180s
#    ...        AND     Perform SCF Delta Commissioning with delta_scf.json
    ...            AND     sleep    400
    ...            AND     Reboot gNB System Module from Console and check Airscale is ready
    ...            AND     sleep    400
#    ...            AND     Start Default Logging    output_dirpath=${LOG_PATH}
#    ...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file_3}
    ...            AND     Start WTS Using WTS_Runner      ${wts_cfg_default}



    set test variable      ${LOG_PATH}
    CB008379_Resource.Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof7}              ${52}=${QOS_Prof3}
    ...     ${53}=${QOS_Prof3}                ${54}=${QOS_Prof3}      ${55}=${QOS_Prof3}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof7_speed_ul}     ${52}=${QOS_Prof3_speed_ul}
    ...     ${53}=${QOS_Prof3_speed_ul}     ${54}=${QOS_Prof3_speed_ul}     ${55}=${QOS_Prof3_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof7_speed_dl}     ${52}=${QOS_Prof3_speed_dl}
    ...     ${53}=${QOS_Prof3_speed_dl}     ${54}=${QOS_Prof3_speed_dl}   ${55}=${QOS_Prof3_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof7_unit}         ${52}=${QOS_Prof3_unit}
    ...     ${53}=${QOS_Prof3_unit}            ${54}=${QOS_Prof3_unit}       ${55}=${QOS_Prof3_unit}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with fiveQI3

    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...    ${en_ue_id_1}    pdu_id=1    nw_id=1
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id_1}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
# Make sure that Non GBR call is fully occupying the network bandwidth then only  utility.compare_tp will work
    Start Data Transfer     ${st_ue_id}     ${en_ue_id_1}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
#    Start and Stop TTI TRACE
    sleep   ${duration}s
#    Collect TTI Trace   tti_trace

    ${nongbr_tp_read}=     Run Keyword And Ignore Error
    ...     Verify data transfer and get tp gbr_nongbr      ${st_ue_id}     ${en_ue_id_1}     ${duration}
	...     both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}       gbr_chk=1


#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id_1}
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting


[1]CB009425-A_TC24_Improved_transmission_link_reliability_due_to_inhibiting_MCS_downgrade_control_for_VoNR_Ues
    [Tags]    TC01
    [Setup]         Run keywords     Suite setup from scratch
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#    ...        AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_GBR_MultiUE_with_8379_20MHz.json
#    ...                 AND    Sleep   80s
    ...        AND     Perform SCF Delta Commissioning with Delta_Configuration_FDD_with_9425.json
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    Sleep   360s    reason=wait for RMOD- to comeup
#    ...                 AND     CB009425_Resource_New.Check Cell On Air      ${wts_cfg_file_2}
    ...                 AND     CB009425_Resource_New.Check Cell On Air          ${wts_cfg_default}


    set test variable      ${LOG_PATH}
    CB009425_Resource_New.Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${56}=${QOS_Prof2}       ${57}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${56}=${QOS_Prof2_speed_ul}    ${57}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${56}=${QOS_Prof2_speed_dl}    ${57}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${56}=${QOS_Prof2_unit}    ${57}=${QOS_Prof2_unit}

    Start Log    btslog
    ${crnti_list}     ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_ue}    ${en_ue}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Log to Console             crnti_list with${crnti_list}
    CB009425_Resource_New.Create Modify PDU session   ${st_ue}     ${en_ue}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}      ue_to_bearer_list=${ue_to_bearer_list}
    ${duration}      Set Variable    1200
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue}     ${en_ue}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}      ${qos_profile_speed_dl}    ${qos_profile}
    CB009425_Resource_New.Set fixed cqi bler for single UE    ${st_ue}    dl
#    Start log    ttitrace
#    sleep    3s
#    ${new_path}    Stop log    ttitrace    test_scenario=ttitrace1
    Start TTI_TRACE custom     ${57}
    sleep     1s
#    sleep     2s
    ${new_path}     Stop Log     ttitrace   test_scenario=ttitrace1

    Decode TTI Trace    ttitrace1

    final verdict for mcs drop     ${crnti_list[0]}     ${new_path}[ttitrace]/output_dl_formated.csv
    ...     dlMcsDropLimitForVoNR=${2}    tc_scen=${1}

    MultiUE Deregister should be Successful   ${st_ue}    ${en_ue}

# Disabling the dlMCSdowngrade parameter value i.e dlMCSdowngrade=0
    Perform SCF Delta Commissioning with Delta_Configuration_2CC_FDD_GBR_MultiUE_with_9425_15MHz_online3.json

    ${crnti_list1}     ${ue_to_bearer_list1}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_ue}    ${en_ue}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list1}
    Log to Console             crnti_list with${crnti_list1}
    CB009425_Resource_New.Create Modify PDU session   ${st_ue}     ${en_ue}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}      ue_to_bearer_list=${ue_to_bearer_list1}
    ${duration}      Set Variable    1200
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue}     ${en_ue}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}      ${qos_profile_speed_dl}    ${qos_profile}
    CB009425_Resource_New.Set fixed cqi bler for single UE    ${st_ue}    dl

#    Start log    ttitrace   52
#    sleep    3s
#    ${new_path1}    Stop log    ttitrace    btslog    test_scenario=ttitrace2
    Start TTI_TRACE custom     ${57}
    sleep     1s
#    sleep     2s
    ${new_path1}     Stop Log     ttitrace     btslog    test_scenario=ttitrace2

    MultiUE Deregister should be Successful   ${st_ue}    ${en_ue}

    Decode TTI Trace    ttitrace2

    final verdict for mcs drop    ${crnti_list1[0]}     ${new_path1}[ttitrace]/output_dl_formated.csv
    ...      dlMcsDropLimitForVoNR=${0}    tc_scen=${4}

    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
*** Keywords ***
Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}
    Log to Console  ${node_id}

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}



Start TTI_TRACE custom
    [Arguments]    ${cell_id}=${50}
    Common Start Ttitrace With Streaming Mode_3 custom        pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
    ${nr_phy_cell_ids}    Create List    ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate  map(int, $nr_phy_cell_ids)
    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
#    ${localIpAddr}=    Get localIpAddr Of GNB
#10.0.1.2 for ute
    ${localIpAddr}=    set variable    10.0.1.2
#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
