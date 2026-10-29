# *** Settings ***
# Force Tags    PY36
# Documentation     author: chuntian
# ...   contact: chun.tian@nokia-sbell.com
# ...   RRM
# 
# Suite Setup     Suite Setup
# #Suite Teardown
# 
# Library           ./Resources/get_list.py
# Library           taf.transport.ssh    WITH NAME    csn
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          ./Resources/CB007590_common_keywords.robot
# Resource          ../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Resource          ../CB007608_5G_A_1854_523/Resources/CB007608_A_523_common_keywords.robot
# Resource          ./Resources/CB007590_common_keywords.robot
# Library      taf.ul.mobile.ui.android     WITH NAME   android_mobile
# Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
# Resource          ../CB007608_B-573/Resources/5GC000573_common_keyword.robot
# Variables         ./Resources/CB007950_parameter.py
# 
# 
# *** Variables ***
# ${ul_throughput}              100M
# ${dl_throughput}              500M
# ${dl_data_sam}                1600M
# ${ul_data_sam}                200M
# ${ul_throughput_case3}        1M
# ${dl_throughput_case3}        1M
# ${dl_peak_throughput}        1350
# ${ul_peak_throughput}        70
# 
# ${server_port_ul_sam}       ${tl.ues[1].iperf_details.ports[2]}
# ${server_port_dl_sam}       ${tl.ues[1].iperf_details.ports[3]}
# ${filter}       uldata_pucchreceivereq
# ${filter_a}       uldata_pucchreceivereq  ||  uldata_pucchreceiverespps
# ${condition_1}        UlData_pucchReceiveReqPucchResource_t.pucchFormat
# ${condition_2}    UlData_pucchReceiveReqPucchResource_t.numOfSymbols
# ${connection}     connection_ute
# ${filter_b}        uldata_pucchreceiverespps
# ${lua_path}       lua_script:/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
# ${startPrb}      UlData_eCpriPucchResourceAllocationStructure_t.startPrb
# ${numOfPrb}      UlData_pucchReceiveReqPucchResource_t.numOfPrb
# ${firstSymbol}      UlData_pucchReceiveReqPucchResource_t.firstSymbol
# ${filter_2}                 uldata_pucchreceiverespps && uci.an
# 
# ${fmat}    UlData_pucchReceiveReqPucchResource_t.pucchFormat
# ${nAN}        UlData_pucchReceiveReqPucchResource_t.nANPucch
# ${srBD}       UlData_pucchReceiveReqPucchResource_t.srBitDetection
# ${nOB}      UlData_pucchReceiveReqPucchResource_t.numOfBitsOfUciInformation
# ${srB}     UlData_pucchReceiveRespPsPucchResource_t.srBit
# ${uciB}       uci.pucch.ucibits
# @{list1}    1   2    0    2
# @{list2}    255    c0000000000000
# @{list5}    3    4    0    4
# @{list6}    255     f0000000000000
# ${sfn}    3gpp.sfn
# ${cqi}   uci.cqi
# ${3gpp}       3gpp.rnti == 65535
# 
# ${apn_NSA}   dxdata1
# ${apn_SA}   SA
# ${mode_name}     5G/LTE/3G/2G (auto connect)
# ${Prb_value}     243
# ${Prb_value2}     253
# ${PuschPrb}      reqMinNumPuschPrb
# ${condition_MoType}         UlData_pucchReceiveReqPucchResource_t.modulationType
# ${pucch_1}     UlData_pucchReceiveReqPucchResource_t.pucchFormat == 1
# 
# ${lua_path}       lua_script:/opt/ute/luashark/generated_luahark/luashark.lua
# ${LOG_PATH}                 ${output_dir}
# ${scf_path}          ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/
# 
# *** Test Cases ***
# 
# [1] CB008423_CB007950_03_ Long_PUCCH_for_Non-BF_FR1-TDD_in_NSA
#         [Tags]    CRT_22R2     CRT_22R3    CRT_22R4    CRT_trunk
# #    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
# #    Switch UE to NSA model
# #    run keyword and ignore error    power_ue.UE Detach    ue_type=samsung
#     5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
#     5GC001937_mmw4_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}    ul_duration=600     dl_duration=600
#     ...    ul_throughput=${ul_throughput_case3}    dl_throughput=${dl_throughput_case3}
#     ${connection}    Start Capture BIP log
#     sleep    20s
#     ${biplog_list}   Stop Capture BIP log and download file      connection=${connection}
#     get AN report from Bip log     biplog_list=${biplog_list}   filter=${filter_2}    # check AN report exit
#     ${return_value}    get parameters from Bip log     biplog_list=${biplog_list}   filter=${filter_a}    condition_expression=${startPrb}
#     Judge item should be greater and equal 0        return_value=${return_value}
#     ${return_value}   get parameters from Bip log     biplog_list=${biplog_list}   filter=${filter_a}    condition_expression=${numOfPrb}
#     Judge item should greater than 0      return_value=${return_value}
#     ${return_value}    get parameters from Bip log      biplog_list=${biplog_list}   filter=${filter_a}    condition_expression=${firstSymbol}
#     should contain       ${return_value}      0
#     ${return_value}    get list from Bip log   biplog_list=${biplog_list}   filter=${filter_a}
#     ${return_list}    get modulationType from Bip log      biplog_list=${biplog_list}   filter=${filter}    condition_ex
# ...pression=${condition_MoType}
#     ${list_Information}   get_modulationType_list     ${return_list}
#     ${return_value}     get check point from Bip log      biplog_list=${biplog_list}   filter=${filter}    condition_expression=${nOB}
# #    ${Type_list}    get_numOfBits_list      ${return_value}
# #    Run Keyword And Continue on failure     lists should be equal     ${Type_list}      ${list_Information}
#     ${return_value}    get numofsymbols_format from Bip log    biplog_list=${biplog_list}   filter=${filter}    condition_expression=${condition_1}
#     ${status1}     run keyword and return status      List Should Contain Value       ${return_value}    1
#     ${status2}     run keyword and return status   List Should Contain Value       ${return_value}    3
#     should be true        ${status1} or ${status2}
#     ${return_value}    get numofsymbols_format from Bip log     biplog_list=${biplog_list}   filter=${filter}    conditi
# ...on_expression=${condition_2}
#     List Should Contain Value       ${return_value}     14
#     ${return_value}   get CSI_Report from Bip log     biplog_list=${biplog_list}     filter=${filter_b}     diff_1=16    diff_2=-1008
#     [Teardown]  Stop traffic and dettach ue    if_ul=${True}      if_dl=${True}
# 
# [1] CB008423_CB007950_10_Support_of_basic_TDD_feature_set_reqMinNumPuschPrb_different_from_default_value_NSA
#      [Tags]    CRT_22R2      CRT_trunk    CRT_22R3
# #     5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
# #     Switch UE to NSA model
# #     run keyword and ignore error    power_ue.UE Detach    ue_type=samsung
#      5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_CSI_320}   gNB_ip=${DU_IP}
#      Modify multi parameter in case 10
#      5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
#      5GC001937_mmw4_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}       ul_duration=600     dl_duration=600
#      ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#      CB007590_common_keywords.start tti trace
#      sleep    5s
#      ${UL_DL_csv_file_path_dict}     CB007590_common_keywords.Stop tti trace log
#      ${result_Prb}      get_ulFdSchedData_numofprb_and_tbsize_19b       file_path_dict=${UL_DL_csv_file_path_dict}
#      Check numofPrb in TTitrace          result_Prb=${result_Prb}    actual_Prb=243
#      sleep     60s
#      Modify Prb value to 253     PuschPrb=${PuschPrb}
#      5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
#      5GC001937_mmw4_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}    ul_duration=600     dl_duration=600
#      ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#      CB007590_common_keywords.start tti trace
#      sleep    5s
#      ${UL_DL_csv_file_path_dict}     CB007590_common_keywords.Stop tti trace log
#      ${result_Prb}      get_ulFdSchedData_numofprb_and_tbsize_19b       file_path_dict=${UL_DL_csv_file_path_dict}
#      Check numofPrb in TTitrace     result_Prb=${result_Prb}     actual_Prb=253
#      [Teardown]  Stop traffic and dettach ue      if_ul=${True}      if_dl=${True}
# 
# 
# *** Keywords ***
# Modify Prb value to 253
#     [Arguments]     ${PuschPrb}
#      ${connection}    CB007590_common_keywords.Rest Login DU
#      Modify scf parameter     dist_name=${dist_name}    parameter=${PuschPrb}     value=253    connection=${connection}
#      [Teardown]    CB007590_common_keywords.Disconnect from DU
# 
# Stop traffic and dettach ue
#      [Arguments]      ${if_dl}      ${if_ul}
#      5GC001937_mmw4_common_keyword.stop multi power ue traffic ul and dl      ue_num=${1}     if_dl=${if_dl}    if_ul=${if_ul}
#      5GC001937_mmw4_common_keyword.detach multi power ue     ue_num=${1}
#      CI_interface.Common Case Teardown
# 
# get check point from Bip log
#     [Arguments]    ${biplog_list}     ${filter}    ${condition_expression}
#     csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
#     ...    alias=connection_ute
#     FOR   ${i}   IN   @{biplog_list}
#         csn.send command
#         ...    command=/usr/bin/tshark -r ${output_dir}/${i} -X ${lua_path} -Y "${filter}" -T fields -e ${condition_expression}
#         ...    connection=connection_ute
#         sleep   5s
#         ${return_value}  csn.Read Output   connection=connection_ute
#         ${return_value}    Set Variable    ${return_value.split('\n')[:-1]}
#     END
#     [Return]     ${return_value}
#     [Teardown]    csn.Disconnect    connection=${connection}
# 
# Modify parameter csi and srPeriod
#     [Arguments]     ${CSI_input}     ${srPeriod_value}
#      5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${CSI_input}   gNB_ip=${DU_IP}
#      ${connection}    CB007590_common_keywords.Rest Login DU
#      Modify scf parameter     dist_name=${dist_name}    parameter=srPeriodicity     value=${srPeriod_value}    connection=${connection}
#      CB007590_common_keywords.Disconnect from DU
#      5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
#      5GC001937_mmw4_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}     ul_duration=600     dl_duration=600
#      ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#     ${connection}    Start Capture BIP log
#     sleep    10s
#     ${biplog_list}   Stop Capture BIP log and download file      connection=${connection}
#     [Return]    ${biplog_list}
#     [Teardown]    Run Keywords     5GC001937_mmw4_common_keyword.stop multi power ue traffic ul and dl      ue_num=${1}
#     ...    AND    power_ue.UE Detach    ue_type=samsung
# 
# Suite Setup
#    Input NSA SCF
# #   Check if Cell Blocked
# 
# Switch UE to NSA model
#    android_mobile.setup
#     ...   ui_version=one ui 3.1
#     ...   host=10.71.217.28
#     ...   username=nokia5G
#     ...   password=noki@123
#     ...   port=22
#     ...   serial_number=RFCR10NE6VX
#     ...   alias=test
#    android_mobile.switch_network_mode    mode_name=${mode_name}    mobile=test
#    android_mobile.switch_apn    apn_name=${apn_NSA}      mobile=test
#    ${access_name}   android_mobile.get_access_point_name         mobile=test
#    log to console    ${access_name}
#    android_mobile.disable_volte_calls      mobile=test
#    android_mobile.teardown    mobile=test
# 
# Switch UE to SA model
#     android_mobile.setup
#     ...   ui_version=one ui 3.1
#     ...   host=10.71.217.28
#     ...   username=nokia5G
#     ...   password=noki@123
#     ...   port=22
#     ...   serial_number=RFCR10NE6VX
#     ...   alias=test
#    android_mobile.switch_network_mode       mode_name=${mode_name}      mobile=test
#    android_mobile.switch_apn    apn_name=${apn_SA}      mobile=test
#    ${access_name}   android_mobile.get_access_point_name         mobile=test
#    log to console    ${access_name}
#    android_mobile.enable_volte_calls    mobile=test
#    android_mobile.teardown    mobile=test
# 
# get CSI_Report from Bip log
#     [Arguments]    ${biplog_list}    ${filter}     ${diff_1}   ${diff_2}
#     csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
#     ...    alias=connection_ute
#     FOR   ${i}   IN   @{biplog_list}
#         csn.send command
#         ...    command=/usr/bin/tshark -r ${output_dir}/${i} -X ${lua_path} -Y "${filter}" -T fields -e ${sfn} -e ${cqi}
#             ...    connection=connection_ute
#         sleep   5s
#         ${return_value}  csn.Read Output   connection=connection_ute
#         ${return_value}    remove duplicates     ${return_value.split('\n')[:-1]}
#         ${lines}    Evaluate    map(lambda x: x.split(), ${return_value})
#         ${result}     get_CSI_InnerFor     ${diff_1}     ${diff_2}     @{lines}
#     END
#     [Teardown]   csn.Disconnect    connection=${connection}
#    [Return]    ${return_value}
# 
# get_CSI_InnerFor
#     [Arguments]   ${diff_1}     ${diff_2}     @{lines}
#     @{list_sfn}    Create List
#     FOR    ${i}    IN RANGE    len(@{lines})
#         run keyword if    len(${lines[${i}]})== 2    Append To List    ${list_sfn}    ${lines[${i}][0]}
#     END
#     log to console    ${list_sfn}
#     ${new_line}    create list
#     FOR    ${i}    IN RANGE    len(@{list_sfn})-1
#         ${diff}    evaluate    ${list_sfn[${i+1}]}-${list_sfn[${i}]}
#         ${result}    run keyword and return status    should be true    '${diff}'=='${diff_1}' or '${diff}'=='${diff_2}'
#         Append To List    ${new_line}    ${result}
#     END
#     log to console    ${new_line}
#     ${count}   set variable   0
#     FOR    ${i}    IN   @{new_line}
#         ${count}     run keyword if   ${i}==True     Evaluate    ${count}+1
#         ...     ELSE    Continue For Loop If     ${i}==False
#     END
#     ${new_line_length}    get length     ${new_line}
#     ${result}     Evaluate    float(${count})/float(${new_line_length})
#     ${return_status}     run keyword and return status    should be true    ${result}>0.6
#     Exit For Loop If      ${return_status}==${True}
#     [Return]      ${result}
# 
# get list from Bip log
#     [Arguments]       ${biplog_list}    ${filter}
#     csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
#     ...    alias=connection_ute
#     FOR   ${i}   IN   @{biplog_list}
#         csn.send command
#         ...  command=/usr/bin/tshark -r ${output_dir}/${i} -Y "${filter}" -T fields -e ${fmat} -e ${nAN} -e ${srBD} -e ${nOB} -e ${srB} -e ${uciB}
#         ...  connection=connection_ute
#         sleep   5s
#         ${return_value}  csn.Read Output   connection=connection_ute
#         ${return_value}    remove duplicates     ${return_value.split('\n')[:-1]}
#         ${lines}    Evaluate    map(lambda x: x.split(), ${return_value})
#         ${return_status}    InnerFor     @{lines}
#         Exit For Loop If    '${return_status}'=='${True}'
#     END
#    [Teardown]   csn.Disconnect    connection=${connection}
#    [Return]    ${return_value}
# 
# InnerFor
#     [Arguments]    @{lines}
#     ${flag1}    set variable    ${0}
#     ${flag3}    set variable    ${0}
#     FOR    ${i}    IN RANGE    1   len(${lines})
#        ${flag1}    run keyword if   "${lines[${i}-1]}"=="@{list1}" and "${lines[${i}]}" == "@{list2}"   evaluate
#         ...    ${flag1}+1    ELSE    set variable    ${flag1}
#         exit for loop if    "${lines[${i}-1]}"=="@{list1}" and "${lines[${i}]}" == "@{list2}"
#     END
#     FOR    ${i}    IN RANGE    len(${lines})
#          ${flag3}    run keyword if    "${lines[${i}-1]}"=="@{list5}" and "${lines[${i}]}" == "@{list6}"   evaluate
#         ...    ${flag1}+1    ELSE    set variable    ${flag1}
#         exit for loop if   "${lines[${i}-1]}"=="@{list5}" and "${lines[${i}]}" == "@{list6}"
#     END
#     ${return_status}    Run Keyword And Return Status    should be true    ${flag1}>=1 or ${flag3}>=1
#     [Return]     ${return_status}
# 
# get numofsymbols_format from Bip log
#     [Arguments]      ${filter}   ${condition_expression}   ${biplog_list}
#     csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
#     ...    alias=connection_ute
#     FOR   ${i}   IN   @{biplog_list}
#         csn.send command
#         ...    command=/usr/bin/tshark -r ${output_dir}/${i} -X ${lua_path} -Y "${filter}" -T fields -e ${condition_expression}
#         ...    connection=connection_ute
#         sleep   5s
#         ${return_value}  csn.Read Output   connection=connection_ute
#         ${return_value}    remove duplicates     ${return_value.split('\n')[:-1]}
#         log to console     ${return_value}
#     END
#     sleep   3s
#     [Teardown]   csn.Disconnect    connection=${connection}
#    [Return]    ${return_value}
# 
# UE start traffic and check traffic
#     [Arguments]  ${ul_data_sam}    ${dl_data_sam}   ${ul_throughput}    ${dl_throughput}
#     UE start traffic sam       ue_index=${0}    tp_direction=both    time=100s
#     ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}    ue_type=samsung
#     ...    iperf_port_ul=${server_port_ul_sam}    iperf_port_dl=${server_port_dl_sam}
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=dl    throughput=${dl_data_sam}     cellid=170901505
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=ul    throughput=${ul_data_sam}     cellid=170901505
# 
