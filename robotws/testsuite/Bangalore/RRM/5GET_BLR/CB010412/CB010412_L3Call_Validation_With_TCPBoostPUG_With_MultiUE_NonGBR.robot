*** Settings ***

Documentation    :copyright: Nokia
...   The aim of the feature is to support  1Tx DL and 2Rx UL per cell operation for NR FDD

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB008983/resources/CB008983_Resource.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../CB009409/resources/CB009409_common_resources.robot
Library          ../CB009409/resources/PDU_Status.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem


################AIC
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Library             taf.collectors.tcpdump    WITH NAME    tcpdumpAIC
Library             taf.collectors.l2stream3    WITH NAME    l2stream3AIC
Library    			taf.collectors.core    WITH NAME    coreAIC
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource          	../resources/robot/Common_Keywords.robot
Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
Resource           ../CB009567/resource/9567_resource.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot


Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
...                     AND				 Update RAD Debug Parameter    ${para_list}
...                     AND              Fast Delta Commission vDU With Delta XML File   ${delta_vdu}
...                     AND              log to console   loading cfg file....
...                     AND              Start WTS Using WTS_Runner      ${wts_cfg_file}



Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner
Test Teardown      Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${delta_vdu}           ${CURDIR}/config/SBTS24R2/TC2_TCPBoostPUG_Activation_AllUEs.xml
${wts_cfg_file}        ${CURDIR}/config/wts/basic_T_F.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${st_ue_id}            1
${en_ue_id}            2
${ul_ue_ip}    72.23.0.1
${dl_ue_ip_1}    10.12.2.2
${dl_ue_ip_2}    10.12.2.3
${dl_port_1}    7073
${dl_port_2}    7074
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220
${value}               0
${file_path}     /opt/iphy/latest/egate_console.log
${mimolayer}      2
${ss_pbch_power}    10
${overhead}    xOh12
${no_of_ports}    2
${cdm_type}    fd-CDM2
${density}    one
${delta_vdu}   ${CURDIR}/config/TC2_TCPBoostPUG_Activation_AllUEs.xml
&{para_dict1}=    name=rdFeatureFlagBitmapLevel    value=3
&{para_dict2}=    name=rdFeatureFlagBitmap4    value=32
@{para_list}=       ${para_dict1}    ${para_dict2}
@{NR_Cell3}=   NRCELL-1    NRCELL-2    NRCELL-3     NRCELL-4





*** Test Cases ***
[1]CB010412_L3Call_Validation_With_TCPBoostPUG_With_MultiUE_NonGBR    
    set test variable      ${LOG_PATH}
    ${Tcp_Boost_Ues}  MultiUE Register should be Successful with External Trf Type    ${st_ue_id}    ${en_ue_id}    
    ...   pdu_id=1    nw_id=1
	UE PDU Modfication should be Successful     ${st_ue_id}   pdu_id=${en_ue_id}    qosflows_to_add=4
	
    ${cells}  create list   NRCELL-1
    Start TCP Downlink Iperf Data    ${dl_ue_ip_1}    ${dl_port_1}    ${duration}
    Start TCP Downlink Iperf Data    ${dl_ue_ip_2}    ${dl_port_2}    ${duration}
    Start L2Ps TTI logs from vDU    ${NR_Cell3}
    sleep  10s
    ${tti}    Stop L2Ps TTI logs from vDU    test_scenario=New1
    Decode TTI Trace    New1  
    Stop Iperf Traffic

    Verify MultiUE TCP Boost Grant event in ulPreSchedData    ${tti}[ttitrace]/output_ul_formated.csv     ${Tcp_Boost_Ues}
    Verify MultiUE ResReqClassPrio in ulTdSchedSubcellData     ${tti}[ttitrace]/output_ul_formated.csv   ${Tcp_Boost_Ues}



***Keyword***


Update RAD Debug Parameter
    [Arguments]    ${para_list} 
    VDU Rest Login
    ${update_params}    vdu.update_rad_debug_params    persistency=persistent   domain_name=L2PS    parameters=${para_list}
    sleep  15s
    ${current_update_operation}    vdu.get_rad_debug_params_update_operation    operation_id=${update_params['operation_id']}
    ${rad_debug_params}    vdu.get_rad_debug_params_summary
    Should Be Equal    '${rad_debug_params}'   'True'
    [Teardown]  vDU Rest Logout
