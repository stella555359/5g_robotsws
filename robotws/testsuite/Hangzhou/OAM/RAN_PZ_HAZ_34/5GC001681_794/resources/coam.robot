*** Settings ***
Documentation   This is common keyword for 5GC001681 cases coam parts.
...              Author: Han Ruiyu
...              Contact: ruiyu.han@nokia-sbell.com
...              Squard: HZ SG7
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Resource   ../../UUF/Resource/webui_coam.robot
Resource   ../../UUF/Resource/common.robot
Library   ../libraries/ui_operation.py
Library   Collections
Library   taf.selenium.sbts    WITH NAME    selenium_coam
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Library   taf.transport.ssh   WITH NAME   csn
Variables  ../../libraries/global_vars.py
Variables  ../libraries/dcap_server_1.py
Variables  ../libraries/xn_gnb.py
Library    String

*** Variables ***
${dscp}   ${EMPTY}
${coam_alias}   coam

*** Keywords ***
Start Stream Trace Action
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${ip_mode}=ipv4   ${host}=${asik_addr}    ${trace_flag}=single
    ${cells_list}   _Get Request Cell List   stream=${stream}   level=${level}   exec_type=${exec_type}
    Run Keyword If   '${ip_mode}'=='ipv4'    Configure Logging Agent   uplane_destination=${uplane_destination}
    ...   ELSE IF   '${ip_mode}'=='ipv6'    Configure Logging Agent   uplane_destination=${uplane_ipv6}
    ...   source_ip=${host}
    run keyword if  '${trace_flag.lower()}'=='single'
    ...    Start Streaming WebEM  level=${level}  exec_type=${exec_type}  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   ELSE IF    '${trace_flag.lower()}'=='all'    run keywords
    ...    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_hi  exec_type=pdcp  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_hi  exec_type=rlc  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_lo  exec_type=${EMPTY}  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_ps  exec_type=${EMPTY}  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   ELSE IF    '${trace_flag.lower()}'=='l2_hi'    run keywords
    ...   Start Streaming WebEM  level=l2_hi  exec_type=pdcp  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND
    ...   Start Streaming WebEM  level=l2_hi  exec_type=rlc  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}

Stop Stream Trace Action
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${trace_flag}=single
    run keyword if  '${trace_flag.lower()}'=='single'
    ...    Wait Until Keyword Succeeds   1min    5s   Run Keyword   selenium_coam.stop_${stream}_trace
    ...   uplane_${stream}_name=${level.replace('_', '-').upper()}   source=${exec_type.upper()}
    ...   ELSE IF    '${trace_flag.lower()}'=='all'    run keywords
    ...    run keyword and continue on failure  selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=PDCP
    ...   AND    run keyword and continue on failure    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=RLC
     ...   AND    run keyword and continue on failure   selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-PS   source=${EMPTY}
     ...   AND    run keyword and continue on failure    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-LO   source=${EMPTY}
    ...   ELSE IF    '${trace_flag.lower()}'=='l2_hi'    run keywords
    ...    Wait Until Keyword Succeeds   1min    5s    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=PDCP
    ...   AND    Wait Until Keyword Succeeds   1min    5s    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=RLC

Get BBMODs info
    [Arguments]   ${alias}=${coam_alias}
    ${hw_info}   coam.get_detected_hw_info   connection=${alias}
    ${bbmod_info_list}   Create List
    FOR   ${bbmod}   IN   @{hw_info['basebandModules']}
       ${bbmod_info}   Create Dictionary
       Set To Dictionary   ${bbmod_info}   internal=${bbmod['id']['internal']}   configuration=${bbmod['id']['configuration']}
       Append To List   ${bbmod_info_list}   ${bbmod_info}
    END
    #${alarm_info}   coam.get_active_alarms   connection=${alias}
    [Return]   ${bbmod_info_list}

Get Cells with groups info
    [Arguments]   ${alias}=${coam_alias}
    ${bts_info}   COAM Get BTS Info   ${alias}
    ${cells_info}   Create List
    FOR   ${group}   IN   @{bts_info['cellsGroup']}
       ${cell_info_one_group}   _Get Cells in Cell Group   group_info=${group}
       Append To List   ${cells_info}   @{cell_info_one_group}
    END
    [Return]   ${cells_info}

_Get Cells in Cell Group
    [Arguments]   ${group_info}
    ${cells_info}   Create List
    FOR   ${cell}   IN   @{group_info['nrCellList']}
       ${cell_info}   Create Dictionary
       Set To Dictionary   ${cell_info}   group=${group_info['name']}   name=${cell}
       Append To List   ${cells_info}   ${cell_info}
    END
    [Return]   ${cells_info}

_Get Request Cell List
    [Arguments]  ${level}   ${exec_type}=${EMPTY}   ${alias}=${coam_alias}
#    Return From Keyword If   '${stream.lower()}'=='sherpa'   ${EMPTY}
    Return From Keyword If   '${level.lower()}'=='l2_hi' and '${exec_type.lower()}'=='pdcp'   ${EMPTY}
    ${cells_list}   Get Cells Runtime List   alias=${alias}
    [Return]   ${cells_list}

Get Cells Index List
    [Arguments]   ${alias}=${coam_alias}
    ${cells}   Get Cells with groups info   ${alias}
    ${cells_index}   Create List
    FOR   ${cell}   IN   @{cells}
       Append To List   ${cells_index}   ${${cell['name'].split('-')[1]}}
    END
    Sort List   ${cells_index}
    [Return]   ${cells_index}

Get Cells Runtime List
    [Arguments]   ${alias}=${coam_alias}
    ${index_list}   Get Cells Index List   alias=${alias}
    ${runtime_list}   Create List
    ${PCI_list}   Create List
    ${Cell_Name_list}   Create List
    ${MRBTS_ID}   selenium_coam.get_bts_id
#    ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ...   filter_param=Physical cell identifier
    FOR   ${index}   IN   @{index_list}
        ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
        ...   filter_param=Physical cell identifier
        Append To List   ${PCI_list}   ${PCI_ID}
    END
    FOR   ${index}   IN   @{index_list}
        ${Cell_Name}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
       ...   filter_param=Cell name
          Append To List   ${Cell_Name_list}   ${Cell_Name}
    END
    FOR   ${index}   IN   @{index_list}
       Append To List   ${runtime_list}   [PCI: ${PCI_list[${index-1}]}][${Cell_Name_list[${index-1}]}]NRCELL_R-${index}
    END
    [Return]   ${runtime_list}

Start Streaming WebEM
    [Arguments]   ${level}   ${exec_type}   ${stream}=sherpa   ${cells_list}=${EMPTY}
    ui_operation.Verify Input Start Trace   level=${level}   exec_type=${exec_type}
#    ${gnb_release}   Get gnb release
#    ${input}   Run Keyword If   '${gnb_release}'=='5G21A' and '${exec_type}' == 'PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21A' and '${exec_type}' == 'pdcp'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'pdcp'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='pdcp'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='RLC'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='rlc'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}'=='PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}'=='pdcp'   Create Dictionary
#    ...   ELSE   Create Dictionary   cells_list=${cells_list}
    ${input}   Run Keyword If   '${exec_type}' == 'PDCP'   Create Dictionary
    ...   ELSE IF   '${exec_type}' == 'pdcp'   Create Dictionary
    ...   ELSE   Create Dictionary   cells_list=${cells_list}
    ${status}   Run Keyword and Ignore Error
    ...   selenium_coam.start_${level}_${exec_type}_${stream}_trace_and_return_result
    Should Be Equal   ${status[0]}   PASS
    Should Contain   ${status[1]}   ucce
    [Return]   ${status[1]}

Configure Logging Agent
    [Arguments]   ${uplane_destination}   ${source_ip}=${asik_addr}
    Run Keyword and Ignore Error   selenium_coam.deactivate_internal_trace
    selenium_coam.configure_logging_agent    source_ip=${source_ip}   vlan=${EMPTY}   dscp=${dscp}
    ...   cplane_destination=${EMPTY}   uplane_destination=${uplane_destination}
    Run Keyword and Ignore Error   selenium_coam.activate_internal_trace
    Log To Console   Logging Agent: ${source_ip}, DSCP: ${dscp}, Service: ${uplane_destination}

Activate Internal Trace
    ${status}   Run Keyword and Ignore Error
    ...   selenium_coam.activate_internal_trace
    Should Be Equal   ${status[0]}   PASS
    Should Contain   ${status[1]}   ucce
    [Return]   ${status[1]}

Deactivate Internal Trace
    ${status}   Run Keyword and Ignore Error
    ...   selenium_coam.deactivate_internal_trace
    Should Be Equal   ${status[0]}   PASS
    Should Contain   ${status[1]}   ucce
    [Return]   ${status[1]}

_Get_gnb_version
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${version}   csn.Execute    cd /ffs/run;ls TargetBD*.xml  connection=release_info
    ${version}    Fetch From Right    ${version}    TargetBD_
    ${version}    Fetch From Left    ${version}    .
    [Return]    ${version}
    [Teardown]   csn.Disconnect   connection=release_info

Format COAM Release
    ${active_version}    _Get_gnb_version
    ${version_temp}    Fetch From Right    ${active_version}    GNB_
    @{version_split}    split string    ${version_temp}    _
    ${versionlist}    Create List
    FOR   ${string}  IN   @{version_split}
       ${stringreturn}    strip string    ${string}    characters=0    mode=left
       ${stringreturn}    run keyword if   '${stringreturn}'==''    set variable    ${0}    ELSE    set variable    ${stringreturn}
       Append to list     ${versionlist}    ${stringreturn}
    END
    [Return]    ${versionlist[0]}.${versionlist[1]}.${versionlist[2]}

Setup Xn Link
    COAM Login
    COAM Update Parameter    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRADJGNB-${xn_gnb_Ncell_id}
    ...   parameter=administrativeState    value=Locked
    Sleep   15s
    COAM Update Parameter    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRADJGNB-${xn_gnb_Ncell_id}
    ...   parameter=administrativeState    value=Unlocked
    sleep    20s
    [Teardown]    COAM Logout

Get PCI list
    [Arguments]   ${alias}=${coam_alias}
    ${index_list}   Get Cells Index List   alias=${alias}
    ${PCI_list}   Create List
    ${MRBTS_ID}   selenium_coam.get_bts_id
    FOR   ${index}   IN   @{index_list}
        ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
        ...   filter_param=Physical cell identifier
        Append To List   ${PCI_list}   ${PCI_ID}
    END
    [Return]   ${PCI_list}

Check Cell Setup in COAM
    log to console    Check Cell Setup in COAM
    Wait Until Keyword Succeeds   20 min   1 min    COAM Login
    Wait Until Keyword Succeeds   20 min   1 min    COAM Check Cell Status    connection=COAM    cell_index=0
    [Teardown]   run keyword and ignore error    COAM Logout

Get Current SCF File On COAM
    [Arguments]   ${xn_gnb_ip}
    coam_client.Connect to   bts_host=${xn_gnb_ip}   name=cOAM
    ${SCF_FILE}   coam_client.Get current scf file   local_dir_path=${OUTPUT_DIR}   file_name=Configuration_scf.xml
    ...   timeout=30   connection=cOAM
    [Teardown]  run keyword and ignore error  coam_client.teardown   connection=cOAM
    [Return]   ${SCF_FILE}


Change_Nradjgnb_AMF_Param
    [Arguments]      ${modify_scfpath}
#    ${modify_scfpath}    set variable    ${OUTPUT_DIR}/Configuration_scf.xml
    ${root}=        XML.Parse XML   ${modify_scfpath}
    ${disname}     set variable   MRBTS-${xn_gnb_btsid}/NRBTS-${xn_gnb_instanceid}
    XML.Set Element Text   ${root}    text=262    xpath=cmData/managedObject[@distName="${disname}"]/p[@name="mcc"]
    XML.Set Element Text   ${root}    text=3    xpath=cmData/managedObject[@distName="${disname}"]/p[@name="mnc"]
    XML.Set Element Text   ${root}    text=2    xpath=cmData/managedObject[@distName="${disname}"]/p[@name="mncLength"]
    ${disname}     set variable   MRBTS-${xn_gnb_btsid}/NRBTS-${xn_gnb_instanceid}/NRADJGNB-2
    XML.Set Element Text   ${root}    text=262    xpath=cmData/managedObject[@distName="${disname}"]/list/item/p[@name="mcc"]
    XML.Set Element Text   ${root}    text=3    xpath=cmData/managedObject[@distName="${disname}"]/list/item/p[@name="mnc"]
    XML.Set Element Text   ${root}    text=2    xpath=cmData/managedObject[@distName="${disname}"]/list/item/p[@name="mncLength"]
    ${disname}     set variable   MRBTS-${xn_gnb_btsid}/NRBTS-${xn_gnb_instanceid}/NRPLMN-1
    XML.Set Element Text   ${root}    text=262    xpath=cmData/managedObject[@distName="${disname}"]/p[@name="mcc"]
    XML.Set Element Text   ${root}    text=3    xpath=cmData/managedObject[@distName="${disname}"]/p[@name="mnc"]
    XML.Set Element Text   ${root}    text=2    xpath=cmData/managedObject[@distName="${disname}"]/p[@name="mncLength"]
    ${disname}     set variable   MRBTS-${xn_gnb_btsid}/NRBTS-${xn_gnb_instanceid}/SERVEDAMF-1
    XML.Set Element Text   ${root}    text=10.110.90.66    xpath=cmData/managedObject[@distName="${disname}"]/p[@name="amfIPAddress"]
    XML.Save XML  ${root}  ${OUTPUTDIR}/modify_scf.xml
    ${modified_scf}    set variable    ${OUTPUTDIR}/modify_scf.xml
    [Return]    ${modified_scf}

#Import SCF On COAM
#    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
#    Wait until keyword succeeds  30min   1min   coam_client.connect_to   bts_host=${IP_WEBUI}   name=cOAM
#    Log to console   \nImport SCF File: ${SCF_FILE}
#    ${version}   coam_client.get_sw_version   timeout=${60}   connection=cOAM
#    log to console   \n${version}
#    coam_client.perform_commissioning
#    ...   scf_file=${SCF_FILE}
#    ...   skip_parameter_relation_errors=${true}
#    ...   should_activate=${true}
#    ...   timeout=${1000}
#    ...   connection=cOAM
#    [Teardown]  run keyword and ignore error  coam_client.teardown   connection=cOAM

Get GNB Node ID
    wait until keyword succeeds   3x   1min
    ...  csn.Connect to   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    &{nodeinfo}    create dictionary
    ${smod_type}   Get SMOD type
    ${nodeinfo}     run keyword if  '${smod_type}'=='ASIK'
     ...  _CMD to get nodeid    cmd=bsh 1:0 "cd /tmp;ls -lt | grep /node";bsh 0:1 "cd /tmp;ls -lt | grep /node"   nodeinfo=${nodeinfo}
     ...   ELSE IF   '${smod_type}'=='ASIB' or '${smod_type}'=='ASIL' or '${smod_type}'=='ASIM'
     ...   _CMD to get nodeid    cmd=bsh 1:0 "cd /tmp;ls -lt | grep /node";bsh 0:0 "cd /tmp;ls -lt | grep /node"    nodeinfo=${nodeinfo}
     ...   ELSE IF    '${smod_type}'=='ASOE' or '${smod_type}'=='ASOG' or '${smod_type}'=='ASOF' or '${smod_type}'=='ASOH'
     ...   _CMD to get nodeid    cmd=bsh 0:0 "cd /tmp;ls -lt | grep /node"    nodeinfo=${nodeinfo}
    [Return]       ${node_info}
    [Teardown]    csn.Disconnect   connection=gnb

_CMD to get nodeid
     [Arguments]    ${cmd}    &{nodeinfo}
    ${output}    csn.execute    ${cmd}   connection=gnb
    ${output}   strip string    ${output}
    ${list}   Split String  ${output}   \r\n
    FOR   ${content}  IN   @{list}
       ${content}    fetch from right   ${content}    node_0x
       ${node}    run keyword if  ${content.count('node_L2')} > 0    Get Regexp Matches       ${content}     (L2[A-Z]{2})
       ...   ELSE  Get Regexp Matches     ${content}     ([A-Z]{3,5})
       ${nodeid}   Get Regexp Matches	   ${content}   ([0-2][0-9]{2}\\S)
       ${node_name}    set variable   ${node[0][:2]}-${node[0][2:]}
       ${node_id}    set variable    ${nodeid[0][:2]}${SPACE}${nodeid[0][2:]}
       Set To Dictionary    ${nodeinfo}    ${node_name}   ${node_id}
#       log to console   nodename:${node_name}
#       log to console   nodeid:${node_id}
    END
    [Return]    ${nodeinfo}

CMD to get nodeid after BSH removed
    [Arguments]    ${smod_type}   ${host}   &{nodeinfo}
    wait until keyword succeeds   2x   1min
    ...  csn.Connect to   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    ${output_on_fct}    run keyword if   '${smod_type}' != 'ASIK'   csn.execute   command=cd /tmp;ls -lt | grep /node   connection=gnb
    ...   ELSE    Read node info on board   host=fctlb   proxy=gnb
    ${output_on_fsp}    run keyword if   '${smod_type}' == 'ASIM' or '${smod_type}'=='ASIL' or '${smod_type}'=='ASIK'
    ...    Read node info on board   host=${host}   proxy=gnb
    ...   ELSE IF   '${smod_type}' == 'ASIB'    Read node info on board   host=${host}   proxy=gnb
    ${output_sum}   Catenate    ${output_on_fsp}   ${output_on_fct}
    ${output}   strip string    ${output_sum}
    ${list}   Split String  ${output}   \r\n
    FOR   ${content}  IN   @{list}
       ${content}    fetch from right   ${content}    node_0x
       ${node}    run keyword if  ${content.count('node_L2')} > 0    Get Regexp Matches       ${content}     (L2[A-Z]{2})
       ...   ELSE  Get Regexp Matches     ${content}     ([A-Z]{3,5})
       ${nodeid}   Get Regexp Matches	   ${content}   ([0-2][0-9]{2}\\S)
       ${node_name}    set variable   ${node[0][:2]}-${node[0][2:]}
       ${node_id}    set variable    ${nodeid[0][:2]}${SPACE}${nodeid[0][2:]}
       Set To Dictionary    ${nodeinfo}    ${node_name}   ${node_id}
    END
    [Return]    ${nodeinfo}
    [Teardown]    run keyword and ignore error   csn.disconnect   connection=gnb

Read node info on board
    [Arguments]    ${host}   ${proxy}
    wait until keyword succeeds   3x   1min
    ...   csn.Connect to   hostname=${host}    username=${asik_username}    password=${asik_password}    alias=fsp   proxy=${proxy}
    ${output_on_fsp}   csn.execute   command=cd /tmp;ls -lt | grep /node   connection=fsp
    [Return]    ${output_on_fsp}
    [Teardown]   run keyword and ignore error   csn.disconnect   connection=fsp

Get GNB Node ID After BSH Removed
    wait until keyword succeeds   3x   1min
    ...  csn.Connect to   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    &{nodeinfo}    create dictionary
    ${smod_type}   Get SMOD type
    ${host}   set variable if    '${smod_type}' == 'ASIM' or '${smod_type}'=='ASIL' or '${smod_type}'=='ASIK'   fsp1_a   fsp-1a
    ${node_info}   CMD to get nodeid after BSH removed    smod_type=${smod_type}   host=${host}   nodeinfo=${nodeinfo}
    [Return]       ${node_info}
    [Teardown]    run keyword and ignore error   csn.Disconnect   connection=gnb

Get SMOD type
    [Arguments]    ${alias}=gnb
    ${cmd_get_hw_type}    Set variable    ddal -s ddal_sysinfo_module_get_unit_id 0|grep "value"
    ${output}    csn.execute    command=${cmd_get_hw_type}    connection=${alias}
    ${hw_type}    Get Regexp Matches    ${output}    value='(.*)'    1
    [Return]  ${hw_type[0].strip()}








