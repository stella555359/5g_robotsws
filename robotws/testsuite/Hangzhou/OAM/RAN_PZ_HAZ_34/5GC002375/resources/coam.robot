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
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Library   taf.transport.ssh   WITH NAME   csn
Variables  ../../libraries/global_vars.py
Variables  ../libraries/dcap_server_1.py
Variables  ../libraries/xn_gnb.py

*** Variables ***
${dscp}   ${EMPTY}
${coam_alias}   coam
${MRBTS_COAM_ID}   ${tl.gnbs[0].global_bts_id}
${instance_id}    ${tl.gnbs[0].instance_id}

*** Keywords ***
Start Stream Trace Action
    [Arguments]   ${stream}   ${level}   ${cells_list}    ${exec_type}=${EMPTY}   ${ip_mode}=ipv4   ${host}=${asik_addr}
    ...    ${trace_flag}=single
#    Run Keyword If   '${ip_mode}'=='ipv4'    Configure Logging Agent   uplane_destination=${uplane_destination}
#    ...   ELSE IF   '${ip_mode}'=='ipv6'    Configure Logging Agent   uplane_destination=${uplane_ipv6}
#    ...   source_ip=${host}
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
    Log to console   Stream Trace Start

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
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${alias}=${coam_alias}
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
    [Arguments]   ${alias}=${coam_alias}  ${tmpdir}=/tmp
    ${index_list}   Get Cells Index List   alias=${alias}
    ${runtime_list}   Create List
    ${PCI_list}   Create List
    ${Cell_Name_list}   Create List
    #${MRBTS_COAM_ID}   selenium_coam.get_bts_id
#    ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/NRBTS-${MRBTS_COAM_ID}/NRCELL-1
#    ...   filter_param=Physical cell identifier
    FOR   ${index}   IN   @{index_list}
        ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/NRBTS-${instance_id}/NRCELL-${index}
        ...   filter_param=Physical cell identifier
        Append To List   ${PCI_list}   ${PCI_ID}
    END
    FOR   ${index}   IN   @{index_list}
        ${Cell_Name}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/NRBTS-${instance_id}/NRCELL-${index}
        ...   filter_param=Cell name
        Append To List   ${Cell_Name_list}   ${Cell_Name}
    END
    FOR   ${index}   IN   @{index_list}
       Append To List   ${runtime_list}   [PCI: ${PCI_list[${index-1}]}][${Cell_Name_list[${index-1}]}]NRCELL_R-${index}
    END
    [Return]   ${runtime_list}

Start Streaming WebEM
    [Arguments]   ${level}   ${exec_type}   ${stream}=sherpa   ${cells_list}=${EMPTY}   ${ip_mode}=ipv4   ${host}=${asik_addr}
    ui_operation.Verify Input Start Trace   level=${level}   exec_type=${exec_type}
    ${gnb_release}   Get gnb release    host=${LMP_ADDR}
    ${input}   Run Keyword If   '${gnb_release}'=='5G20A' and '${exec_type}' == 'PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G20A' and '${exec_type}' == 'pdcp'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}' == 'PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}' == 'pdcp'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'pdcp'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='pdcp'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='RLC'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='rlc'   Create Dictionary
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
    COAM Login    bts_host=${xn_gnb_ip}   username=${xn_gnb_username}    password=${xn_gnb_password}
    COAM Update Parameter    dist_name=MRBTS-${xn_gnb_btsid}/NRBTS-${xn_gnb_btsid}/NRADJGNB-${xn_gnb_Ncell_id}
    ...   parameter=administrativeState    value=Locked
    Sleep   15s
    COAM Update Parameter    dist_name=MRBTS-${xn_gnb_btsid}/NRBTS-${xn_gnb_btsid}/NRADJGNB-${xn_gnb_Ncell_id}
    ...   parameter=administrativeState    value=Unlocked
    sleep    20s
    [Teardown]    COAM Logout

Get PCI list
    [Arguments]   ${alias}=${coam_alias}
    ${index_list}   Get Cells Index List   alias=${alias}
    ${PCI_list}   Create List
    #${MRBTS_COAM_ID}   selenium_coam.get_bts_id
    FOR   ${index}   IN   @{index_list}
        ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/NRBTS-${instance_id}/NRCELL-${index}
        ...   filter_param=Physical cell identifier
        Append To List   ${PCI_list}   ${PCI_ID}
    END
    [Return]   ${PCI_list}

Check Cell Setup in COAM
    log to console    Check Cell Setup in COAM
#    Wait Until Keyword Succeeds   20 min   1 min    COAM Login
    Wait Until Keyword Succeeds   20 min   1 min    COAM Check Cell Status    connection=${coam_alias}     cell_index=0
#    [Teardown]   run keyword and ignore error    COAM Logout

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

Import SCF On COAM
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    Wait until keyword succeeds  30min   1min   coam_client.connect_to   bts_host=${IP_WEBUI}   name=cOAM
    Log to console   \nImport SCF File: ${SCF_FILE}
    ${version}   coam_client.get_sw_version   timeout=${60}   connection=cOAM
    log to console   \n${version}
    coam_client.perform_commissioning
    ...   scf_file=${SCF_FILE}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=cOAM
    [Teardown]  run keyword and ignore error  coam_client.teardown   connection=cOAM

Get Mplane IP
    ${MPlaneDN}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...    filter_param=Management plane IPv4 IP address reference
    ${MPlane_IP}    selenium_coam.get_parameter_value   dist_name=${MPlaneDN}    filter_param=Local IPv4 address
    Log to console    MPlane IP is ${MPlane_IP}
    [Return]    ${MPlane_IP}

Change Mplane to Internal IP
    [Arguments]    ${IPIF_NUM}
    #${MRBTS_COAM_ID}   selenium_coam.get_bts_id
    Run Keyword If   '${IPIF_NUM}'=='2'    selenium_coam.set_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...    filter_param=Management plane IPv4 IP address reference    new_value=MRBTS-${MRBTS_COAM_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
    ...    ELSE    selenium_coam.set_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...    filter_param=Management plane IPv4 IP address reference    new_value=MRBTS-${MRBTS_COAM_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-4/IPADDRESSV4-2
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}
    Sleep   2m
    COAM WEBUI Whether Close Start Up View Window
    ${MPlane_IP}    wait until keyword succeeds     10min    30s     Get Mplane IP
    Log to console    change Mplane to ${MPlane_IP}

Get port status
    [Arguments]   ${ETHLK_NUM}
    #${MRBTS_COAM_ID}   selenium_coam.get_bts_id
    ${status}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_COAM_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-${ETHLK_NUM}
    ...    filter_param=Administrative state of the Ethernet link
    Log to console    ETHLK-${ETHLK_NUM} is ${status}
    [Return]    ${status}

Add Interface by perform SCF
   [Arguments]    ${port}=SEI
   wait until keyword succeeds     10x    30s    COAM Login    bts_host=${LMP_ADDR}
#   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
#   ${gnb_release}    Run keyword if   '${gnb_release}'=='SBTS22R2'     set variable   22R2
#   ...   ELSE IF    '${gnb_release}'=='SBTS22R3'     set variable   22R3
#   ...   ELSE IF    '${gnb_release}'=='SBTS22R4'     set variable   22R4
#   ...   ELSE IF    '${gnb_release}'=='SBTS23R1'     set variable   23R1
#   ...   ELSE IF    '${gnb_release}'=='TRUNK'     set variable   TRUNK
#   ...   ELSE        set variable   TRUNK
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
   wait until keyword succeeds     5x    5min
   ...   COAM SCF Commission    filepath=${CURDIR}/../../../../../../commissionings/HGZ/${testline}/SCF_${port}.xml
   [Teardown]    COAM Logout

Delete Interface by perform SCF
   wait until keyword succeeds     10x    30s    COAM Login    bts_host=${LMP_ADDR}
#   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
#   ${gnb_release}    Run keyword if   '${gnb_release}'=='SBTS21B'     set variable   21B
#   ...   ELSE IF    '${gnb_release}'=='5G21A'     set variable   21A
#   ...   ELSE IF    '${gnb_release}'=='SBTS22R1'     set variable   22R1
#   ...   ELSE IF    '${gnb_release}'=='SBTS22R2'     set variable   22R2
#   ...   ELSE IF    '${gnb_release}'=='TRUNK'     set variable   TRUNK
#   wait until keyword succeeds     5x    5min
#   ...   COAM SCF Commission    filepath=${CURDIR}/../../../../../../commissionings/HGZ/${testline}/SCF_${gnb_release}_novlan.xml
   wait until keyword succeeds     5x    5min
   ...   COAM SCF Commission    filepath=${OUTPUT_DIR}/old_commission.xml
   [Teardown]    COAM Logout

Backup Old SCF
   wait until keyword succeeds    10min   1min   COAM Login
   wait until keyword succeeds     5min    30s    COAM Backup SCF
   [Teardown]    COAM Logout

Add Interface and Backup SCF
    [Arguments]    ${port}=SEI
    Backup Old SCF
    Add Interface by perform SCF    port=${port}


