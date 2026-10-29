*** Settings ***
Documentation
...  author: Yang Liqin 
...  contact: liqin.yang@nokia-sbell.com
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

*** Variables ***
${BTSID}    MRBTS-${tl.gnbs[0].instance_id}
${INSID}   ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
${WEBUI_ADDR}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}   ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
*** Keywords ***  
Get ALL Suite Variables
    taf_coam.COAM Login
    taf_coam.COAM Backup Full SCF  local_dir=${TS_CASE_LOG_PATH}
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ${SMOD_NAME}   Get SMOD Product Name
    Set Suite Variable   ${SMOD_NAME}

    ${local_xml}   XML.Parse XML   ${TS_CASE_LOG_PATH}/full_commission.xml
    ${gNbIdLength}  XML.Get Element Text  ${local_xml}  xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    Set Suite Variable   ${gNbIdLength}

    ${mcc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mcc"]
    ${mnc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mnc"]
    ${mnclength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mncLength"]

    ${local_tmp}   Set Variable If
    ...   '${mnclength}'=='2'   ${mcc}f${mnc.zfill(int(${mnclength}))}
    ...   '${mnclength}'=='3'   ${mcc}${mnc.zfill(int(${mnclength}))}
    Set Suite Variable   ${PLMN_IDENTITY}   ${local_tmp[1]}${local_tmp[0]}${local_tmp[3]}${local_tmp[2]}${local_tmp[5]}${local_tmp[4]}
    ${PLMN_IDENTITY_tmp}    Catenate    ${local_tmp[1]}${local_tmp[0]}:${local_tmp[3]}${local_tmp[2]}:${local_tmp[5]}${local_tmp[4]}
    Set Suite Variable   ${PLMN_IDENTITY_col}    ${PLMN_IDENTITY_tmp}    
    ${cell_elements}=     XML.Get Elements    ${local_xml}
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"] 
    BuiltIn.Should Not Be Empty    ${cell_elements} 
    ${cell_num}=    BuiltIn.Get Length    ${cell_elements}
    Set Suite Variable    ${cell_num} 

    ${nrcellid_1}  XML.Get Element Text  ${local_xml}  xpath=cmData/managedObject[@distName="${INSID}/NRCELL-${cell_1}"]/p[@name="nrCellIdentity"]
    Set Suite Variable   ${nrcellid_1}
    ${nrcellid_2}  XML.Get Element Text  ${local_xml}  xpath=cmData/managedObject[@distName="${INSID}/NRCELL-${cell_2}"]/p[@name="nrCellIdentity"]
    Set Suite Variable   ${nrcellid_2}
    Get hexadecimal CellIdentity
    ${traceid_dec}   XML.Get Element Text   ${local_xml}   
    ...    xpath=cmData/managedObject[@distName="${INSID}/NRCTRLTS-1/NRMTRACECU-1"]/list[@name="nrRanTraceReference"]//p[@name="traceId"]
    ${tmp}    Get hexadecimal traceId    ${traceid_dec}
    ${traceId_col}    Catenate
    ...  ${tmp[0]}${tmp[1]}:${tmp[2]}${tmp[3]}:${tmp[4]}${tmp[5]}
    Set Suite Variable   ${traceId}    ${tmp} 
    Set Suite Variable   ${traceId_col}

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS

    ${reportAmount}   Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    XML.Get Element Text   ${local_xml}
    ...   xpath=cmData/managedObject[@distName="${INSID}/NRCTRLTS-1/NRMTRACECU-1"]/list[@name="nrPeriodicUeMeas"]//p[@name="reportAmount"]
    ...    ELSE      XML.Get Element Text   ${local_xml}
    ...    xpath=cmData/managedObject[@distName="${INSID}/NRCTRLTS-1/NRMTRACECU-1"]/list[@name="immedMDTUEMeas"]//p[@name="reportAmount"]

    Set Suite Variable   ${amount}    ${reportamountD}[${reportAmount}]

    ${reportInterval}   Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...     XML.Get Element Text   ${local_xml}
    ...   xpath=cmData/managedObject[@distName="${INSID}/NRCTRLTS-1/NRMTRACECU-1"]/list[@name="nrPeriodicUeMeas"]//p[@name="reportInterval"]
    ...    ELSE       XML.Get Element Text   ${local_xml}
    ...   xpath=cmData/managedObject[@distName="${INSID}/NRCTRLTS-1/NRMTRACECU-1"]/list[@name="immedMDTUEMeas"]//p[@name="reportInterval"]

    ${tmp}    Set Variable    ${reportInterval}
    Set Suite Variable   ${interval}    ${reportintervalD}[${reportInterval}]
    ${report_Interval}    String.Replace String Using Regexp    ${reportInterval}    (ms|min)    ${EMPTY}
    Set Suite Variable    ${report_Interval}
    ${unit}    String.Remove String    ${tmp}    ${report_Interval}
    Set Suite Variable    ${unit}

    
    ${AMF_IP}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/SERVEDAMF-1"]/p[@name="amfIPAddress"]
    Set Suite Variable   ${AMF_IP}
    ${dcap_server_ip}   XML.Get Element Text   ${local_xml}
    ...   xpath=cmData/managedObject[@distName="${BTSID}/MNL-1/TCEADM-1/TCE-1"]/p[@name="tceIpAddress"]
    Set Suite Variable   ${dcap_server_ip}
    ${dcap_server_port}   XML.Get Element Text   ${local_xml}
    ...   xpath=cmData/managedObject[@distName="${BTSID}/MNL-1/TCEADM-1/TCE-1"]/p[@name="tcePortNumber"]
    Set Suite Variable   ${dcap_server_port}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout 

Get hexadecimal CellIdentity
    FOR  ${idx}    IN RANGE    1    ${cell_num}+1
        ${CellIndentity_hex}     Evaluate    hex(${nrcellid_${idx}})
        ${CellIndentity_end}     Catenate    SEPARATOR=     ${CellIndentity_hex}         0
        ${CellIndentity_pure_num}     Remove String    ${CellIndentity_end}       0x
        ${CellIndentity_length}   Get Length    ${CellIndentity_pure_num}
        ${CellIndentity_0_num}    Evaluate      10-${CellIndentity_length}
        ${tmp}     Get Pure Number CllIdentity    ${CellIndentity_0_num}   ${CellIndentity_pure_num}
        Set Suite Variable    ${hex_nrcellid_${idx}}    ${tmp}
        ${CellIndentity_pure_num}    Catenate
        ...  ${tmp[0]}${tmp[1]}:${tmp[2]}${tmp[3]}:${tmp[4]}${tmp[5]}:${tmp[6]}${tmp[7]}:${tmp[8]}${tmp[9]}
        Set Suite Variable    ${nrcellid_${idx}_col}    ${CellIndentity_pure_num}
    END

    
Get hexadecimal traceId
    [Arguments]    ${traceid_dec}
    ${traceId_hex}     Evaluate       hex(${traceid_dec})
    ${traceId_pure_num}     Remove String    ${traceId_hex}       0x
    ${traceId_length}   Get Length    ${traceId_pure_num}
    ${traceId_0_num}    Evaluate      6-${traceId_length}
    FOR   ${idx}    IN RANGE    0    ${traceId_0_num}
        ${traceId_pure_num}     Catenate   SEPARATOR=     0    ${traceId_pure_num}
    END
    [Return]    ${traceId_pure_num}
    
Get Pure Number CllIdentity
    [Arguments]      ${CellIndentity_0_num}    ${CellIndentity_pure_num}
    FOR   ${idx}    IN RANGE    0    ${CellIndentity_0_num}
          ${CellIndentity_pure_num}     Catenate   SEPARATOR=     0    ${CellIndentity_pure_num}
    END
    [Return]   ${CellIndentity_pure_num}
