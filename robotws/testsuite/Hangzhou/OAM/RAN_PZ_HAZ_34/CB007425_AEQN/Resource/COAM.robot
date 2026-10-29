*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***
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
    ${add_str}   Convert To String   ${add_all_pcmd}
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
