*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot    WITH NAME    snapshot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
#Library          ../../../../../resources/python_libs/check_csv_log.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Library    taf.analyzer.pcap    WITH NAME    pcap

*** Variables ***
#${luashark_path}    /home/ute/Downloads/Lua/generated_luashark/luashark.lua
${tshark_path}    /usr/bin/tshark
${swconfig_file}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${scf_path}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${scf_file_path}    ${scf_path}/common.xml
${pdsch_slot}     DlData_PdschSendReq.PdschSendReq.slot
${pdsch_sfn}      DlData_PdschSendReq.PdschSendReq.sfn
${command_filter}    \"dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq\"
${command_temp_21B}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_21B} -Y ${command_filter} -T pdml
${command_temp_22R1}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R1} -Y ${command_filter} -T pdml  
${command_temp_22R2}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R2} -Y ${command_filter} -T pdml   
${luashark_path_21B}      /home/ute/Downloads/Lua/generated_luashark_SBTS21B/luashark.lua
${luashark_path_22R1}      /home/ute/Downloads/Lua/generated_luashark_SBTS22R1/luashark.lua
${luashark_path_22R2}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R2/luashark.lua


*** Keywords ***
Load BIP Log
    [Arguments]    ${pcap_file}    ${tshark_path}=${tshark_path}    ${luashark_path}=${luashark_path}    ${filter}=${none}
    Run Keyword If    "${filter}"=="${none}"    Set Test Variable    ${command_template}    ${none}
    ...    ELSE    Set Test Variable    ${command_template}    
    ...    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y \"${filter}\" -T pdml
    pcap.load_pcap_file    pcap_file=${pcap_file}    tshark_path=${tshark_path}    
    ...    luashark_path=${luashark_path}    command_template=${command_template}

Check Csirs result
    [Arguments]    ${pcap_file}=${bip_log_path}    ${filter}=dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq    
    ...    ${4layer}=True    ${sfn_period}=4    ${multi_ue}=True    ${multiply}=${12}    ${ue_num}=${2}    ${enable6667}=False
    ...    ${filter_expression}=DlData_PdschSendReq.grants_item_15.isCsirsRateMatching==0x00000001    ${8026}=False    ${52RB}=False
    Set filter variable
    ${packets}    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_temp}
    Filter Packets By Expression    filter_expression=${filter_expression}
    ${sfn}    Get Value From Bip Log    field_name=${pdsch_sfn}
    ${numofprb}    Get Value From Bip Log    field_name=${pdsch_numofprb}
    #${mcs}    Get Value From Bip Log    field_name=${pdsch_mcs}
	${mcs}    Get value from Bip Log by xpath    xpath=.//DlData_PdschSendReq.grants_item_0.mcs
    ${numoflayer}    Get Value From Bip Log    field_name=${pdsch_numoflayers}
    ${numcsirsMR}    Get Value From Bip Log    field_name=${pdsch_numcsirsMR}
    ${rnti}    Get Value From Bip Log    field_name=${pdsch_rnti}
    ${filter_length}    get length    ${numofprb}
    Run Keyword If    ${52RB}==False    Check PRB Number Value    numofprb=${numofprb}    numcsirsMR=${numcsirsMR}    
    ...    filter_num=${filter_length}    multiply=${multiply}
    ${mcs_value}    evaluate    int(${mcs}[1])
    ${rnti_c}    Remove Duplicates    ${rnti}
    ${count}    get length    ${rnti_c}
    ${num}    get length    ${mcs}
    Run Keyword And Continue On Failure    Run Keyword If    ${multi_ue}==True    Should Be True    
    ...    ${count}==${ue_num}    ELSE    Should Be True    ${count}==${1}
    FOR    ${index}    IN RANGE    ${num}
        ${check_value}    evaluate    int(${mcs}[${index}])
        Should Be True    ${check_value}>${5}
	END
    Run Keyword If    ${4layer}==True    Should Be True    "${numoflayer}[1]"=="0x00000004"    ELSE    Should Be True    
    ...    "${numoflayer}[1]"=="0x00000002"
    ${sfn_first}    evaluate    int(${sfn}[1])
    ${sfn_filter}    Run Keyword If    ${ue_num}<4    Evaluate    ${ue_num}*2    ELSE    Evaluate    ${4}*2
    ${sfn_trans}    Evaluate    ${ue_num}*2
	Run Keyword If    ${enable6667}==True and ${ue_num}<8 and ${8026}==True and ${52RB}==False    
	...    Set Test Variable    ${sfn_filter}    ${sfn_trans}
    ...    ELSE IF    ${enable6667}==True and ${ue_num}>7 and ${8026}==True and ${52RB}==False    
    ...    Set Test Variable    ${sfn_filter}    ${15}
    ...    ELSE IF    ${enable6667}==True and ${8026}==False    Set Test Variable    ${sfn_filter}    ${sfn_trans}
    ...    ELSE IF    ${52RB}==True    Set Test Variable    ${sfn_filter}    ${sfn_trans}
    ${sfn_num}    evaluate    int(${sfn}[${sfn_filter}])
    ${sfn_gap}    evaluate    ${sfn_num}-${sfn_first}
    Should Be True    ${sfn_gap}==${sfn_period}    	
    ${return_sfn}    Set Variable    ${sfn}[${sfn_filter}]
    [Return]    ${return_sfn}    ${mcs_value}

Check MCS degrade
    [Arguments]    ${input_sfn}    ${input_mcs}    ${pcap_file}=${bip_log_path}    
    ...    ${filter}=dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq
    Set filter variable
    ${packets}    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_temp}
    ${need_transit}    evaluate    int(${input_sfn})-1
    ${filter_sfn}    Convert To Hex    ${need_transit}    prefix=0x    length=8
    Filter Packets By Expression    filter_expression=DlData_PdschSendReq.PdschSendReq.sfn==${filter_sfn}
    #${mcs}    Get Value From Bip Log    field_name=${pdsch_mcs}
	${mcs}    Get value from Bip Log by xpath    xpath=.//DlData_PdschSendReq.grants_item_0.mcs
    ${current_mcs}    evaluate    ${mcs}[-1]
    Should Be True    ${input_mcs}<${current_mcs}

Get SFN Period
    [Arguments]    ${pcap_file}=${bip_log_path}    ${filter}=dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq    
    ...    ${check_period}=1
    Load BIP Log    pcap_file=${pcap_file}    filter=${filter}
    ${pdsch_sfn}    Get Value From Bip Log    field_name=${pdsch_sfn}
    ${pdsch_slot}    Get Value From Bip Log    field_name=${pdsch_slot}
    ${iscsirsRM}    Get Value From Bip Log    field_name=${pdsch_iscsirsRM}
    ${check_value}    evaluate     ${check_period}+1
    ${start_num}    Set Variable    0
    FOR    ${num}    IN RANGE    400
        ${start_num}    Run Keyword If    "${pdsch_slot}[${num}]"=="0x00000000" and "${iscsirsRM}[${num}]"=="0x00000001"    
        ...    evaluate    ${start_num}+1    ELSE    Set Variable    ${start_num}
        Run Keyword If    ${start_num}==${check_value}    Exit For Loop
	END
    ${sfn_num}    evaluate    int(${pdsch_sfn}[${num}])
    [Return]    ${sfn_num}

Get filter num
    [Arguments]
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Run keyword if    'ENB' in ${result}    set test variable    ${release}    ${result}[0]
    ...    ELSE    set test variable    ${release}    21A
    set test variable    ${index}    0
    Run keyword if    '${release}'=='21A'    set test variable    ${index}    15
    #${index}    set variable if    '${release}'=='SBTS21B'    15
    #...    '${release}'=='SBTS22R1'    0
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${index}

Set filter variable
    [Arguments]
    ${rest}    Get filter num
    Set test variable    ${pdsch_numofprb}    DlData_PdschSendReq.grants_item_${rest}.numOfPrb
    Set test variable    ${pdsch_mcs}    DlData_PdschSendReq.grants_item_${rest}.mcs
    Set test variable    ${pdsch_numoflayers}    DlData_PdschSendReq.grants_item_${rest}.numOfLayers
    Set test variable    ${pdsch_iscsirsRM}    DlData_PdschSendReq.grants_item_${rest}.isCsirsRateMatching
    Set test variable    ${pdsch_numcsirsMR}    DlData_PdschSendReq.grants_item_${rest}.numCsirsMappingRes
    Set test variable    ${pdsch_rnti}    DlData_PdschSendReq.grants_item_${rest}.rnti
    #Set test variable    ${luashark_path}    /home/ute/Downloads/Lua/generated_luashark_${release}/luashark.lua

COAM Get FBB Type
    [Arguments]    
    Connect to gnb coam via ssl
    @{output_fbb_info}    coam.get_fbb_info    connection=GNB_OAM
    ${fbb_type}    Set Variable    ${output_fbb_info[0]['productName'].split(' ')}[0]
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${fbb_type}

Enable mirror port on Loki for 2538
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    csn.Execute     command=/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asik_alias}
    csn.Execute     command=/usr/bin//lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -p xgmac97 -r    connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -d netdriver -p xgmac97    connection=${asik_alias}

Start Bip Log Capture on Loki for 2538
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    Enable mirror port on Loki for 2538    mirror_port=${mirror_port}
    csn.Send command     command=tcpdump -i ${mirror_port} -w /tmp/tcpdump_L2L1.pcap
    ...                  connection=${asik_alias}

Stop Bip Log Capture on Loki and download BIP Logs to testPC for 2538
    [Arguments]     ${interface}=eths2    ${connection}=ASIK Master
    ...             ${log_path}=${TS_CASE_LOG_PATH}    ${download_type}=Download
    ...             ${log_prefix}=${None}
    Stop BIP Capture On ASIK    interface=${interface}
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    connection=${connection}
    ...    download_type=${download_type}
    ...    log_prefix=${log_prefix}
    [Return]    ${list_log_path_local}

Capture BIP log and download on ABIO
    [Arguments]     ${duration}=5s
    Connect to Common Unit Master
    Start Bip Log Capture on Loki for 2538
    Sleep    ${duration}
    ${list_log_path_local}    Stop Bip Log Capture on Loki and download BIP Logs to testPC for 2538    log_path=${OUTPUT_DIR}
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Csn.Disconnect    connection=ASIK Master

Capture BIP Log and Download By Web
    [Arguments]    ${duration}=5s
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    sleep    ${duration}
    ${bip_file}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    set test variable    ${bip_log_path}    ${bip_file}[0]
    

Check PRB Number Value
    [Arguments]     ${numofprb}    ${numcsirsMR}    ${filter_num}=10    ${multiply}=${12}
    FOR    ${index}    IN RANGE    ${filter_num}
        ${prb_num}    evaluate    int(${numofprb}[${index}])
        ${csirsMR}    evaluate    int(${numcsirsMR}[${index}])
        Should Be True    ${prb_num}*${multiply}==${csirsMR}
    END

Check TRS slot shcedule UE number
    [Arguments]    ${pcap_file}=${bip_log_path}    ${filter}=dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq
    ...    ${filter_expression}=DlData_PdschSendReq.grants_item_15.isCsirsRateMatching==0x00000001    ${ue_num}=${4}
    ...    ${enable6667}=False    ${tag_rate}=0.5    ${8026}=True
    #Load BIP Log    pcap_file=${pcap_file}    filter=${filter}
	${packets}    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_temp}
    Filter Packets By Expression    filter_expression=${filter_expression}
    ${sfn}    Get Value From Bip Log    field_name=${pdsch_sfn}
    ${slot}    Get Value From Bip Log    field_name=${pdsch_slot}
    ${length_trans}    get length    ${slot}
    ${length}    Evaluate    ${length_trans}-1
    Set Test Variable    ${suc_slot}    ${0}
    Set Test Variable    ${all_slot}    ${0}
    FOR    ${index}    IN RANGE    ${length}
        Run Keyword If    ${sfn}[${index}]==${sfn}[${index+1}] and ${slot}[${index}]==${slot}[${index+1}]    
        ...    Run Keywords    Continue For Loop
        Set Test Variable    ${all_slot}    ${${all_slot}+1}
        ${packets}    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_temp}
        Filter Packets By Expression     filter_expression=${pdsch_sfn}==${sfn}[${index}] and ${pdsch_slot}==${slot}[${index}]
        ${rnti}    Get Value From Bip Log    field_name=${pdsch_rnti}
        ${rnti_trans}    Remove Duplicates    ${rnti}
        ${rnti_num}    get length    ${rnti_trans}
        ${status}    Run Keyword and Return Status    Run Keyword If    ${enable6667}==True and ${ue_num}<8 and ${8026}==True    Should Be True    
        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==True and ${ue_num}>7 and ${8026}==True
        ...    Should Be True    ${rnti_num}==${7}    ELSE IF    ${enable6667}==False and ${ue_num}<5    Should Be True    
        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==False and ${ue_num}>4    Should Be True    ${rnti_num}==${4}
        ...    ELSE IF    ${enable6667}==True and ${8026}==False    Should Be True    ${rnti_num}==${ue_num}
        Run Keyword If    ${status}==True    Set Test Variable    ${suc_slot}    ${${suc_slot}+1}
    END
    ${suc_rate}    Evaluate    float(${suc_slot})/${all_slot}
    Should Be True    ${suc_rate}>${tag_rate}

Check TRS slot shcedule UE number for 52RB
    [Arguments]    ${pcap_file}=${bip_log_path}    ${filter}=dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq
    ...    ${filter_expression}=DlData_PdschSendReq.grants_item_15.isCsirsRateMatching==0x00000001    ${ue_num}=${4}
    ...    ${enable6667}=False    ${tag_rate}=0.5    ${8026}=True
    #Load BIP Log    pcap_file=${pcap_file}    filter=${filter}
	${packets}    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_temp}
    Filter Packets By Expression    filter_expression=${filter_expression}
    ${sfn}    Get Value From Bip Log    field_name=${pdsch_sfn}
    ${slot}    Get Value From Bip Log    field_name=${pdsch_slot}
    ${length_trans}    get length    ${slot}
    ${length}    Evaluate    ${length_trans}-1
    Set Test Variable    ${suc_slot}    ${0}
    Set Test Variable    ${all_slot}    ${0}
    FOR    ${index}    IN RANGE    ${length}
        Run Keyword If    ${sfn}[${index}]==${sfn}[${index+1}] and ${slot}[${index}]==${slot}[${index+1}]    
        ...    Run Keywords    Continue For Loop
        Set Test Variable    ${all_slot}    ${${all_slot}+1}
        #Load BIP Log    pcap_file=${pcap_file}    filter=${filter}
		${packets}    Load BIP Log with Template Command    pcap_file=${bip_log_path}    command_template=${command_temp}
        Filter Packets By Expression    filter_expression=${pdsch_sfn}==${sfn}[${index}] and ${pdsch_slot}==${slot}[${index}]
        ${rnti}    Get Value From Bip Log    field_name=${pdsch_rnti}
        ${rnti_trans}    Remove Duplicates    ${rnti}
        ${rnti_num}    get length    ${rnti_trans}
        ${status}    Run Keyword and Return Status    Run Keyword If    ${enable6667}==True and ${8026}==True    Should Be True    
        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==False and ${ue_num}<5    Should Be True    
        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==False and ${ue_num}>4    Should Be True    ${rnti_num}==${4}
        ...    ELSE IF    ${enable6667}==True and ${8026}==False    Should Be True    ${rnti_num}==${ue_num}
        Run Keyword If    ${status}==True    Set Test Variable    ${suc_slot}    ${${suc_slot}+1}
    END
    ${suc_rate}    Evaluate    float(${suc_slot})/${all_slot}
    Should Be True    ${suc_rate}>${tag_rate}

#Check TRS slot shcedule UE number for 52RB
#    [Arguments]    ${pcap_file}=${bip_log_path}    ${filter}=dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq
#    ...    ${filter_expression}=DlData_PdschSendReq.grants_item_15.isCsirsRateMatching==0x00000001    ${ue_num}=${4}
#    ...    ${enable6667}=False    ${tag_rate}=0.5    ${8026}=True
#    ${packets}    Load BIP Log    pcap_file=${pcap_file}    filter=${filter}
#    ${filter_result}    Filter Packets By Expression    packets=${packets}    
#    ...    filter_expression=${filter_expression}
#    ${sfn}    Get Value From Bip Log    packets=${filter_result}    field_name=${pdsch_sfn}
#    ${slot}    Get Value From Bip Log    packets=${filter_result}    field_name=${pdsch_slot}
#    ${length_trans}    get length    ${slot}
#    ${length}    Evaluate    ${length_trans}-1
#    Set Test Variable    ${suc_slot}    ${0}
#    Set Test Variable    ${all_slot}    ${0}
#    FOR    ${index}    IN RANGE    ${length}
#        Run Keyword If    ${sfn}[${index}]==${sfn}[${index+1}] and ${slot}[${index}]==${slot}[${index+1}]    
#        ...    Run Keywords    Continue For Loop
#        Set Test Variable    ${all_slot}    ${${all_slot}+1}
#        ${ue_list}    Filter Packets By Expression    packets=${packets}    
#        ...    filter_expression=${pdsch_sfn}==${sfn}[${index}] and ${pdsch_slot}==${slot}[${index}]
#        ${rnti}    Get Value From Bip Log    packets=${ue_list}    field_name=${pdsch_rnti}
#        ${rnti_trans}    Remove Duplicates    ${rnti}
#        ${rnti_num}    get length    ${rnti_trans}
#        ${status}    Run Keyword and Return Status    Run Keyword If    ${enable6667}==True and ${8026}==True    Should Be True    
#        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==False and ${ue_num}<5    Should Be True    
#        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==False and ${ue_num}>4    Should Be True    ${rnti_num}==${4}
#        ...    ELSE IF    ${enable6667}==True and ${8026}==False    Should Be True    ${rnti_num}==${ue_num}
#        Run Keyword If    ${status}==True    Set Test Variable    ${suc_slot}    ${${suc_slot}+1}
#    END
#    ${suc_rate}    Evaluate    float(${suc_slot})/${all_slot}
#    Should Be True    ${suc_rate}>${tag_rate}
#
#Check TRS slot shcedule UE number for 52RB
#    [Arguments]    ${pcap_file}=${bip_log_path}    ${filter}=dldata_pdschsendreq||dldata_ssblocksendreq||dldata_csirssendreq
#    ...    ${filter_expression}=DlData_PdschSendReq.grants_item_15.isCsirsRateMatching==0x00000001    ${ue_num}=${4}
#    ...    ${enable6667}=False    ${tag_rate}=0.5    ${8026}=True
#    ${packets}    Load BIP Log    pcap_file=${pcap_file}    filter=${filter}
#    ${filter_result}    Filter Packets By Expression    packets=${packets}    
#    ...    filter_expression=${filter_expression}
#    ${sfn}    Get Value From Bip Log    packets=${filter_result}    field_name=${pdsch_sfn}
#    ${slot}    Get Value From Bip Log    packets=${filter_result}    field_name=${pdsch_slot}
#    ${length_trans}    get length    ${slot}
#    ${length}    Evaluate    ${length_trans}-1
#    Set Test Variable    ${suc_slot}    ${0}
#    Set Test Variable    ${all_slot}    ${0}
#    FOR    ${index}    IN RANGE    ${length}
#        Run Keyword If    ${sfn}[${index}]==${sfn}[${index+1}] and ${slot}[${index}]==${slot}[${index+1}]    
#        ...    Run Keywords    Continue For Loop
#        Set Test Variable    ${all_slot}    ${${all_slot}+1}
#        ${ue_list}    Filter Packets By Expression    packets=${packets}    
#        ...    filter_expression=${pdsch_sfn}==${sfn}[${index}] and ${pdsch_slot}==${slot}[${index}]
#        ${rnti}    Get Value From Bip Log    packets=${ue_list}    field_name=${pdsch_rnti}
#        ${rnti_trans}    Remove Duplicates    ${rnti}
#        ${rnti_num}    get length    ${rnti_trans}
#        ${status}    Run Keyword and Return Status    Run Keyword If    ${enable6667}==True and ${8026}==True    Should Be True    
#        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==False and ${ue_num}<5    Should Be True    
#        ...    ${rnti_num}==${ue_num}    ELSE IF    ${enable6667}==False and ${ue_num}>4    Should Be True    ${rnti_num}==${4}
#        ...    ELSE IF    ${enable6667}==True and ${8026}==False    Should Be True    ${rnti_num}==${ue_num}
#        Run Keyword If    ${status}==True    Set Test Variable    ${suc_slot}    ${${suc_slot}+1}
#    END
#    ${suc_rate}    Evaluate    float(${suc_slot})/${all_slot}
#    Should Be True    ${suc_rate}>${tag_rate}
