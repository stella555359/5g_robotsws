*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

#*** Variables ***
# ${example}   SEPARATOR=
# ...   123
# ...   456
# ...   789

# ${del1}   {"distName":"${MRBTS}/${NRBTS}/NRCTRLTS-1","operation":"delete","parameters":[]}
# ${del2}   {"distName":"${MRBTS}/${NRBTS}/NRDU-1/NRCTRLTSDU-1","operation":"delete","parameters":[]}
# ${del3}   {"distName":"${MRBTS}/MNL-1/TCEADM-1","operation":"delete","parameters":[]}
# ${del_pcmd}   [${del1},${del2},${del3}]

*** Keyword ***
COAM Remove PCMD Object
    # COAM Update PCMD Flag
    Check PCMD Related Object Exist
    @{del_all_pcmd}   Create List
    Run Keyword If   ${NRCTRLTS_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrlts}
    Run Keyword If   ${NRCTRLTSDU_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrltsdu}
    Run Keyword If   ${TCEADM_EXIST}   Append To List   ${del_all_pcmd}   ${del_tceadm}
    ${del_str}   Convert To String   ${del_all_pcmd}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTS_EXIST} or ${NRCTRLTSDU_EXIST} or ${TCEADM_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}

COAM Add PCMD Object
    # COAM Update PCMD Flag   flag=true
    ${all_pcmd_object}   Run Keyword If   '${SW_Release}'>'SBTS25R3'   Set Variable   ${add_all_pcmd_26R1}
    ...   ELSE IF   '${SW_Release}'=='SBTS25R3'   Set Variable   ${add_all_pcmd_25R3}
    ...   ELSE IF   '${SW_Release}'>='SBTS24R3' and '${SW_Release}'<'SBTS25R3'   Set Variable   ${add_all_pcmd_24R3}
    ...   ELSE IF   '${SW_Release}'>='SBTS23R4' and '${SW_Release}'<'SBTS24R3'   Set Variable   ${add_all_pcmd_new}
    ${add_str}   Convert To String   ${all_pcmd_object}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Update PCMD Flag
    [Arguments]   ${flag}=true
    Run Keyword If   '${flag}'!='false' and '${flag}'!='true'   FAIL   Please Input "true" or "false"!
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=actPCMDReport   value=${flag}

COAM Update Celltrace Flag
    [Arguments]   ${flag}=true
    Run Keyword If   '${flag}'!='false' and '${flag}'!='true'   FAIL   Please Input "true" or "false"!
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=actCellTraceReport   value=${flag}

Check PCMD Related Object Exist
    ${scf_xml}   COAM Get SCF Content
    # COAM Backup Full SCF
    # ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${NRCTRLTS_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
    ${NRCTRLTSDU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSDU"]
    ${TCEADM_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCEADM"]
    Set Suite Variable   ${NRCTRLTS_EXIST}
    Set Suite Variable   ${NRCTRLTSDU_EXIST}
    Set Suite Variable   ${TCEADM_EXIST}

Check the target cellIdentity For 1756
     [Arguments]     ${cellIdentity}      ${pcap_cellIdentity}    ${cell_numbers}
     ${cell_string}   set variable   ${EMPTY}
     FOR   ${idx}    IN RANGE    0   ${cell_numbers}
            @{cellIdengtity_element}    Split String    ${cellIdentity}
            ${cell_string}   Run Keyword if  '${pcap_cellIdentity}' == '${cellIdengtity_element}[${idx}]'   Set Variable    ${1}
            ...   ELSE   Set Variable    ${EMPTY}
            Exit For Loop If   '${pcap_cellIdentity}' == '${cellIdengtity_element}[${idx}]'
            ${cell_string}   Catenate    SEPARATOR=   ${cell_string}   ${0}
     END
     [Return]   ${cell_string}

Delete MO via COAM
    [Arguments]  ${MO_name}   ${BTS_ip}=${WEBUI_ADDR}   ${usernanme}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    log to console   Delete MO via COAM
    ${parameter}    create list
    ${conn}   wait until keyword succeeds  5 times   1min   coam.connect_to
    ...   bts_host=${BTS_ip}
    ...   username=${usernanme}
    ...   password=${password}
    ...   name=COAM
    coam.perform_object_recommissioning   dist_name=${MO_name}   parameter=${parameter}   operation=delete
    ...   skip_parameter_relation_errors=True   connection=${conn}
    [Teardown]  run keyword and ignore error   coam.teardown   connection=${conn}

Get Last Reset from Blackbox
     Wait Until Keyword Succeeds   1m   3x   COAM Login   alias=BBOX
     ${SW_release}   COAM Get SW Release   connection=BBOX
     wait until keyword succeeds   1min    3x
     ...   csn.Connect to   hostname=${LMP_ADDR}   username=${asik_username}   password=${asik_password}   alias=ASIK
     ${blackbox}   run keyword if   '${SW_release}'>'SBTS25R1'
     ...   csn.execute    command=cd /ffs/run/logs/lifetimedata;cat blackbox_reset   timeout=300   connection=ASIK
     ...   ELSE   csn.execute    command=cd /ffs/run/config/lifedata;cat blackbox_reset   timeout=300   connection=ASIK
     @{blackbox_split} =   Split String   ${blackbox}     \r\n
     [Return]   ${blackbox_split[-2]}
     [Teardown]   run keywords   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK
     ...   AND   Run Keyword And Ignore Error    COAM Logout   connection=BBOX

Check Extra Reset From Blackbox on Teardown
    [Arguments]   ${Reset_before}
     Wait Until Keyword Succeeds   1m   3x   COAM Login   alias=BBOX
     ${SW_release}   COAM Get SW Release   connection=BBOX
     wait until keyword succeeds   1min    3x
     ...   csn.Connect to   hostname=${LMP_ADDR}   username=${asik_username}   password=${asik_password}   alias=ASIK
     ${blackbox}   run keyword if   '${SW_release}'>'SBTS25R1'
     ...   csn.execute    command=cd /ffs/run/logs/lifetimedata;cat blackbox_reset   timeout=300   connection=ASIK
     ...   ELSE   csn.execute    command=cd /ffs/run/config/lifedata;cat blackbox_reset   timeout=300   connection=ASIK
     @{blackbox_split} =   Split String   ${blackbox}     \r\n
     FOR   ${reset}   IN   @{Extra_Reset}
        ${has_reset}   run keyword and return status   Should Not Be Equal   ${Reset_before}    ${blackbox_split[-2]}
        ${status}   run keyword and return status   Should Contain   ${blackbox_split[-2]}    ${reset}    msg=Extra Reboot Happen
#        @{black_result}   Split String   ${blackbox_split[-8]}   /ffs
        Run Keyword If  ${has_reset} and ${status}   fail  msg=Unexpected gnb reset happen: ${blackbox_split[-2]}
     END
     [Teardown]   run keywords   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK
     ...   AND   Run Keyword And Ignore Error    COAM Logout   connection=BBOX

COAM Remove And Add CUUP PCMD Object
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    ${scf_xml}   COAM Get SCF Content
    ${NRCTRLTSCUUP_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSCUUP"]
    @{del_cuup_pcmd}   Create List
    Run Keyword If   ${NRCTRLTSCUUP_EXIST}   Append To List   ${del_cuup_pcmd}   ${del_nrctrltscuup}
    ${del_str}   Convert To String   ${del_cuup_pcmd}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTSCUUP_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}

    ${add_str}   Convert To String   ${add_cuup_pcmd}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout
