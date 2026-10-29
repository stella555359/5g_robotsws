*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON RRM keywords

Library   taf.sbts.oam.coam.admin    WITH NAME    coam
Library   taf.selenium.gnb.oam.core    WITH NAME      selenium_core
Library   Collections
Library   OperatingSystem
Library   DateTime
Library    taf.sw.nrdim    WITH NAME    NRDIM

Library   String
Library   XML   True
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library           taf.hw.rf_attenuator    WITH NAME    att
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation
Library           taf.analyzer.pcap   WITH NAME    parser


*** Keywords ***
Webem Change RRM params by list
    [Arguments]    ${param_change}    ${runame}    ${framestruct}    ${x2_enb_mrbtsId}=default    ${gnbmode}=SA
    Log to console   | start to change RRM parameters with ${framestruct}...
    ${paramlist_len}    get length   ${param_change['${runame}']['${framestruct}']}
    ${tmp_list}    copy list   ${param_change['${runame}']['${framestruct}']}
    FOR  ${i}  IN RANGE  ${paramlist_len}
        ${status}    run keyword and return status  Dictionary Should Contain Key    ${tmp_list[${i}]}    node_index
        run keyword if  not ${status}    Set To Dictionary     ${tmp_list[${i}]}   node_index=${0}
    END
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    ${value}   selenium_coam.get_parameter_value    dist_name=MRBTS-${GLOBAL_BTS_ID}     filter_param=BTS name
    Return From Keyword If   ${value.count('${framestruct}')} >0
    FOR  ${i}  IN RANGE  ${paramlist_len}
        ${abbr_value}    get variable value    ${tmp_list[${i}]['abbr']}    ${None}
        ${output}    get variable value    ${tmp_list[${i}]['new_value']}
        Run keyword if  $output==${None}   WEBUI Add Element Specific handle
        ...   dist_name=${tmp_list[${i}]['dist_name']}
        ...   filter_param=${tmp_list[${i}]['filter_param']}
        ...   search_param=${tmp_list[${i}]['search_param']}
        ...   node_len=${tmp_list[${i}]['node_len']}
        ...   ELSE     WEBUI Set Param Specific handle
        ...   dist_name=${tmp_list[${i}]['dist_name']}
        ...   filter_param=${tmp_list[${i}]['filter_param']}
        ...   abbr=${abbr_value}
        ...   new_value=${tmp_list[${i}]['new_value']}
        ...   node_index=${tmp_list[${i}]['node_index']}
    END
    selenium_coam.validate_plan
    ${status}    Run Keyword And Return Status    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=360
    Run Keyword If    ${status}==${False}    Fail    /n***Activate plan failed!***/n
    Sleep   10s
    COAM WEBUI Whether Close Start Up View Window
    check mplane and onair meantime during 15min    x2_enb_mrbtsId=${x2_enb_mrbtsId}   gnbmode=${gnbmode}
    COAM Backup SCF    file_name=${runame}_${framestruct}.xml


Admin Change RRM params by list
    [Arguments]    ${param_change}    ${runame}    ${framestruct}    ${x2_enb_mrbtsId}=default    ${gnbmode}=SA
    Log to console   | start to change RRM parameters with ${framestruct}...


    ${value}   COAM Get Parameter Value    dist_name=MRBTS-${GLOBAL_BTS_ID}     parameter=btsName
    Return From Keyword If   ${value.count('${framestruct}')} >0

    COAM Commission Prameters Operation    param_dic_to_change=${param_change['${runame}']['${framestruct}']}
    COAM Backup SCF    file_name=${runame}_${framestruct}.xml
    check mplane and onair meantime during 15min    x2_enb_mrbtsId=${x2_enb_mrbtsId}   gnbmode=${gnbmode}



Check onair and x2 meantime
    [Arguments]   ${x2_enb_mrbtsId}=default   ${gnbmode}=SA
    Log    ${x2_enb_mrbtsId}
    COAM Check all cells should be onair    connection=COAM
    run keyword and ignore error   COAM WEBUI Whether Close Start Up View Window
    run keyword if   ${gnbmode.count('NSA')}>0   COAM Check X2 Link Status at Gnb

check mplane and onair meantime during 15min
    [Arguments]   ${x2_enb_mrbtsId}   ${gnbmode}=SA
    FOR  ${i}    IN RANGE    ${45}
        ${passed1}   run keyword and return status
        ...    Validate IP Reachability from Test PC    ip_addr=${asik_addr}  exp_status=${True}
        ${passed2}   run keyword and return status    Check onair and x2 meantime    x2_enb_mrbtsId=${x2_enb_mrbtsId}
        ...   gnbmode=${gnbmode}
        exit for loop if   ${passed1} and ${passed2}
        sleep   20s
    END

WEBUI Add Element Specific handle
    [Arguments]   ${dist_name}   ${filter_param}    ${search_param}   ${node_len}
    Run keyword and ignore error    Repeat Keyword    3x    COAM WEBUI Set Parameter Value
    ...   dist_name=${dist_name}
    ...   filter_param=${EMPTY}
#    ...   abbr=${EMPTY}
    ...   new_value=${EMPTY}
    ...   node_index=${0}
    ${return_list}    selenium_coam.get_parameter_value_by_global_search    filter_param=${search_param}
    run keyword if   len(${return_list})!=${node_len}
    ...   selenium_coam.add_element
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}

WEBUI Set Param Specific handle
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}    ${node_index}=${0}
    run keyword if   '${new_value}'!='NA'    Wait Until Keyword Succeeds    3x   10s    COAM WEBUI Set Parameter Value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   new_value=${new_value}
    ...   node_index=${node_index}
    ...   ELSE    Get AND Delete parameter combine
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   node_index=${node_index}

Get AND Delete parameter combine
     [Arguments]    ${dist_name}    ${filter_param}   ${abbr}    ${node_index}
     ${value}   selenium_coam.get_parameter_value    dist_name=${dist_name}     filter_param=${filter_param}
     run keyword if  '${value}'!='${EMPTY}'    selenium_coam.delete_parameter
     ...   dist_name=${dist_name}
     ...   filter_param=${filter_param}
     ...   abbr=${abbr}
     ...   node_index=${node_index}

Set the HBTE PA value
    [Arguments]      ${value_list}    ${att_index}=0
    att.setup_attenuator    attenuator=${tl.attenuators[${att_index}]}
    ${port_lenth}   get length   ${tl.attenuator[${att_index}].attenuation_port_numbers}
    FOR  ${i}  IN RANGE  ${port_lenth}
        att.set_attenuation     port=${tl.attenuator[${att_index}].attenuation_port_numbers[${i}]}    value=${${value_list[${i}]}}
    END
    FOR  ${i}  IN RANGE  ${port_lenth}
        ${value}    att.read_attenuation    port=${tl.attenuator[${att_index}].attenuation_port_numbers[${i}]}
        should be equal    ${value}    ${${value_list[${i}]}}
    END

Get physCellId and ARFCN by Cellid
    [Arguments]   ${gloablecellid}    ${Technology}=NR
    ${physCellId}    run keyword if  ${Technology.count('NR')}>0    COAM Get Parameter Value By XPath
    ...    xpath=cmData/managedObject[@distName="MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${gloablecellid}"]/p[@name="physCellId"]
    ...   ELSE    COAM Get Parameter Value By XPath
    ...    xpath=cmData/managedObject[@distName="MRBTS-${GLOBAL_BTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${gloablecellid}"]/p[@name="phyCellId"]
    ${arfcn}    run keyword if  ${Technology.count('NR')}>0    COAM Get Parameter Value By XPath
    ...    xpath=cmData/managedObject[@distName="MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${gloablecellid}"]/p[@name="arfcnSsbPbch"]
    ...   ELSE    COAM Get Parameter Value By XPath
    ...   xpath=cmData/managedObject[@distName="MRBTS-${GLOBAL_BTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${gloablecellid}/LNCEL_TDD-0"]/p[@name="earfcn"]
    [Return]    ${physCellId}    ${arfcn}

Get Cell Band by Cellid
    [Arguments]   ${gloablecellid}    ${Technology}=NR
    ${pci}     ${arfcn}   Get physCellId and ARFCN by Cellid    gloablecellid=${gloablecellid}    Technology=${Technology}
    ${bts_info}    COAM Get BTS Info
    FOR    ${nrcell}    IN    @{btsinfo['cells']['nr']}
          Exit For Loop If     len(${btsinfo['cells']['nr']})<=0 or '${Technology}'!='NR'
          ${band}    set variable if     '${nrcell['physicalCellId']}'=='${pci}' and '${nrcell['globalCellId']}'=='${gloablecellid}'
          ...   ${nrcell['band']}    default
          Exit For Loop If   '${band}'!='default'
    END
    FOR    ${ltecell}    IN    @{btsinfo['cells']['lte']}
          Exit For Loop If     len(${btsinfo['cells']['lte']})<=0 or '${Technology}'!='LTE'
          ${band}    set variable if     '${ltecell['physicalCellId']}'=='${pci}' and '${ltecell['globalCellId']}'=='${gloablecellid}'
          ...   B${ltecell['bandNumber']}    default
          Exit For Loop If   '${band}'!='default'
    END
    [Return]   ${band}

Get cellid by Globlecellid
    [Arguments]   ${gloablecellid}
    ${status}    ${gnbidlength}    Run Keyword And Ignore Error    COAM Get Parameter Value By XPath
    ...    xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    ${gnbidlength}    Set Variable If   '${status}'=='FAIL'    22    ${gnbidlength}
    ${mrbtsid}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${nrCellIdentity}    Evaluate    int(${mrbtsid})*(int(2)**(${36}-int(${gnbidlength})))+int(${gloablecellid})
    [Return]    ${nrCellIdentity}


COAM Check all cells should be onair
    [Arguments]    ${connection}=COAM
    log to console     //TODO:   COAM Check all cells should be onair
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Exit For Loop If     len(${nr_cells_info})<=0
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END
    ${lte_cells_info}   coam.get_cells_info  cell_type=lte    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{lte_cells_info}
        Exit For Loop If     len(${lte_cells_info})<=0
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END
    Log to console    \n all GNB cells are onair\n


COAM Check all cells should be onair but one
    [Arguments]    ${exclude_cellid}    ${connection}=COAM
    log to console     //TODO:   COAM Check all cells should be onair
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Exit For Loop If     len(${nr_cells_info})<=0
        Continue For Loop If    '${cell['globalCellId']}'=='${exclude_cellid}'
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END
    ${lte_cells_info}   coam.get_cells_info  cell_type=lte    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{lte_cells_info}
        Exit For Loop If     len(${lte_cells_info})<=0
        Continue For Loop If    '${cell['globalCellId']}'=='${exclude_cellid}'
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END
    Log to console    \n all GNB cells are onair\n

Stop Control PC Windows Process
    [Arguments]    ${ip_index}   ${processname}=python.*RDP    ${process_exist}=RDP
    Connect to control pc enhanced   ue_index=${ip_index}
    ${output}    csn.execute    command=tasklist | more | grep -E '${processname}'   connection=cpc_${ip_index}
    ${output}    strip string    ${output}
    ${status}    run keyword and return status    should not contain    ${output}    python
    Return from keyword if  """${output}"""=="""${EMPTY}""" or ${status}
    ${multi_process}    Split String    ${output}    separator=\r\n
    FOR    ${single_process}    IN    @{multi_process}
        ${process_num}    run keyword if   ${single_process.count('${process_exist}')}>0
        ...   Get Regexp Matches   ${single_process}   \\s+(\\d{2,9})\\s+    1
        ${output}    run keyword if   '${process_num[0]}'!='None'
        ...   csn.execute    command=taskkill /F /PID ${process_num[0]}   connection=cpc_${ip_index}
        run keyword if   '${process_num[0]}'!='None'   should contain     ${output}   SUCCESS
    END
    [Teardown]   csn.disconnect   connection=cpc_${ip_index}

Stop Control PC Cygwin Process
    [Arguments]    ${ip_index}   ${process_exist}=SAS
    Connect to control pc enhanced   ue_index=${ip_index}
    ${python_exist}    csn.execute    command=ps -ef | grep python   connection=cpc_${ip_index}
    ${python_exist}    strip string    ${python_exist}
    ${status}   run keyword and return status    should not contain    ${python_exist}    python
    Return from keyword if  """${python_exist}"""=="""${EMPTY}""" or ${status}
    ${multi_process}    Split String    ${python_exist}    separator=\r\n
    FOR    ${single_process}    IN    @{multi_process}
        ${process_num}      Get Regexp Matches   ${single_process}   \\D+\\s+(\\d{2,9})\\s+    1
        ${SAS_exist}   csn.execute    command=cat /proc/${process_num[0]}/cmdline   connection=cpc_${ip_index}
        run keyword if  ${SAS_exist.count('${process_exist}')}>0
        ...   csn.execute    command=kill ${process_num[0]}   connection=cpc_${ip_index}
    END
    [Teardown]   csn.disconnect   connection=cpc_${ip_index}

Get Expected Throughput by NRDIM
    [Arguments]     ${cellid}    ${Nrdim_param_dic}=${None}
    set test variable   ${use_nrdim}    ${True}
    COAM Backup SCF    file_name=caculate_peak.xml
    ${cellgrp_name}    _Get_nrcellgroupid_by_cellid    scf_path=${OUTPUT_DIR}/caculate_peak.xml    cellid=${cellid}
    NRDIM.Setup    scf_file_path=${OUTPUT_DIR}/caculate_peak.xml
    ...            cell_distname=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cellid}
    ...            cellgroup_distname=${cellgrp_name}
    ...            alias=Test
    _Set_Nrdim_Param_Onebyone   Nrdim_param_dic=${Nrdim_param_dic}
    ${calculated_throughput}=    NRDIM.Calculate Expected Throughput    calculator=Test
#    ${dl_calc}    ${ul_calc}    throughput_computation.get_theoretical_throughput
#    ...    scf_path=${OUTPUT_DIR}/caculate_peak.xml
#    ...    cell_id=${cellid}
    ${dl_calc}   set variable    ${calculated_throughput['downlink']}
    ${ul_calc}   set variable    ${calculated_throughput['uplink']}
    [Return]   ${dl_calc}    ${ul_calc}

_Set_Nrdim_Param_Onebyone
    [Arguments]    ${Nrdim_param_dic}
    ${value}    get variable value    ${Nrdim_param_dic}
    Return From Keyword If    ${value}==${None}
    ${Nrdim_param_keys}=  Get Dictionary Keys  ${Nrdim_param_dic}
    ${Nrdim_param_values}=  Get Dictionary Values  ${Nrdim_param_dic}
    FOR  ${key}  ${value}  IN ZIP  ${Nrdim_param_keys}  ${Nrdim_param_values}
        NRDIM.Set Parameter    name=${key}   value=${value}    calculator=Test
    END


_Get_nrcellgroupid_by_cellid
    [Arguments]   ${scf_path}    ${cellid}
    ${scf_xml}   XML.Parse XML   ${scf_path}
    ${nrCellGRPs}    XML.Get Elements   ${scf_xml}
        ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    FOR   ${nrCellGRP}    IN    @{nrCellGRPs}
        ${cellgrp_name}   XML.Get Element Attribute   ${nrCellGRP}   name=distName    xpath=.
        ${nrcellid}    XML.Get Element Text   ${nrCellGRP}   xpath=list[@name="nrCellList"]/p
        Exit For Loop If     ${nrcellid}==${cellid}
    END
    [Return]    ${cellgrp_name}

Common Get Nrcellid by Globlecellid
    [Arguments]   ${gloablecellid}
    ${gnbidlength}    COAM Get Parameter Value By XPath
    ...    xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    ${nrCellIdentity}    Evaluate    int(${MRBTS_ID})*(int(2)**(${36}-int(${gnbidlength})))+int(${gloablecellid})
    [Return]    ${nrCellIdentity}


Check Wireshark Attach nRCellIdentity should be same
    [Arguments]    ${logpath}    ${cellid}=1
    log to console    check tcpdumplog nRCellIdentity should be same
    ${nRCellIdentity}    Common Get Nrcellid by Globlecellid    gloablecellid=${cellid}
    ${nrcellid_16}    Convert To Hex     ${nRCellIdentity}
    parser.load_pcap_file    pcap_file=${logpath}   alias=Wireshark
    ${filter_expression}=     Catenate    (nr-rrc.c1 == 0) && (f1ap.procedureCode == 11)
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.nRCellIdentity
    FOR   ${cellid}   IN    @{result}
        ${cellid}   Remove String     ${cellid}   :
        should be true    ${cellid.count('${nrcellid_16.lower()}')}>=1
    END

Check Wireshark Attach Successful
    [Arguments]    ${logpath}    ${times}=10
    log to console    Check tcpdumplog Attach Successful
    parser.load_pcap_file    pcap_file=${logpath}   alias=Wireshark
    ${filter_expression}=     Catenate    (ngap.procedureCode == 14) && (ngap.fiveQI == 7)
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//ngap.fiveQI
    should be true    len(${result})>=${times}
#    :For   ${cellid}   IN    @{result}
#        ${cellid}   Remove String     ${cellid}   :
#        should be true    ${cellid.count('${nrcellid_16.lower()}')}>=1
#    END

Check Wireshark No Restablisment
    [Arguments]    ${logpath}
    log to console    Check Wireshark No Restablisment
    parser.load_pcap_file    pcap_file=${logpath}   alias=Wireshark
    ${filter_expression}=     Catenate    nr-rrc.reestablishmentCause == 2||nr-rrc.reestablishmentCause == 0
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//nr-rrc.reestablishmentCause
    Should Not Contain Any    ${result}    2    0
