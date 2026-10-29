*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***


*** Keyword ***
Start Capture Wireshark
    [Arguments]   ${connection}   ${file_name}
    csn.Connect to
    ...   hostname=${${connection}_SSH_ADDR}
    ...   username=${${connection}_SSH_USER}
    ...   password=${${connection}_SSH_PWD}
    ...   alias=${connection}
    csn.Send Command   command=tcpdump sctp -i ${${connection}_INTERFACE} -w /rom/${file_name} &> /dev/null &
    ...   timeout=${60}   connection=${connection}
    Sleep   10s
    [Teardown]   csn.Disconnect   connection=${connection}

Stop Capture Wireshark
    [Arguments]   ${connection}   ${file_name}
    csn.Connect to
    ...   hostname=${${connection}_SSH_ADDR}
    ...   username=${${connection}_SSH_USER}
    ...   password=${${connection}_SSH_PWD}
    ...   alias=${connection}
    ${processinfo}   csn.Execute   command=ps aux | grep "tcpdump sctp" | grep -v grep  connection=${connection}
    ${processinfo}   Strip String   ${processinfo}
    ${processinfo}   Split String   ${processinfo}   ${SPACE}
    Remove Values From List   ${processinfo}   ${EMPTY}
    csn.Execute   command=kill -2 ${processinfo[1]}   connection=${connection}
    Sleep   10s
    csn.Download File   remote_path=/rom/${file_name}   local_path=${OUTPUT_DIR}/${file_name}   connection=${connection}
    csn.Execute   command=rm /rom/${file_name}   connection=${connection}
    [Teardown]   csn.Disconnect   connection=${connection}


Check Wireshark XN Setup Failure
    [Arguments]   ${file_name}   ${message_filter}   ${misc_value}
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=${XNAP}
    ${Message_Type}   Catenate   ${message_filter}
    cap.Check Expression   condition_expression=${Message_Type}

    ${id}   cap.Get Element Value
    ...   element_expression=${XNAP}.id
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
    Should Be Equal   ${id[0]}   0007

    ${criticality}   cap.Get Element Value
    ...   element_expression=${XNAP}.id
    ...   condition_expression=${message_filter}
    ...   element_idx=${1}
    Should Be Equal   ${criticality[0]}   004c

    ${misc}   cap.Get Element Value
    ...   element_expression=${XNAP}.misc
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
#    List Should Contain Value   ${misc}   ${misc_value}
#    Should Be Equal   ${misc[0]}   ${misc_value}

Check Wireshark XN Setup Request
    [Arguments]   ${file_name}   ${filter}   ${plmn}=64f020   ${tac_exp}=0000c8   ${band_log}=0028
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=${XNAP}.AMF_Region_Information
    ${Message_Type}   Catenate   ${filter}
    cap.Check Expression   condition_expression=${Message_Type}

    ${plmn_id}   cap.Get Element Value
    ...   element_expression=${XNAP}.plmn_id
    ...   condition_expression=${filter}
    ...   element_idx=${0}
    List Should Contain Value   ${plmn_id}   ${plmn}
#    Should Be Equal   ${plmn_id[0]}   ${plmn}

    # ${band}   cap.Get Element Value
    # ...   element_expression=${XNAP}.nr_frequency_band
    # ...   condition_expression=${filter}
    # ...   element_idx=${0}
    # Should Be Equal   ${band[0]}   ${band_log}

    ${tac}   cap.Get Element Value
    ...   element_expression=${XNAP}.tac
    ...   condition_expression=${filter}
    ...   element_idx=${1}
    ${tac_ck}   Evaluate   int(str('${tac[0]}'), 16)
    ${tac_exp}   Evaluate   int(str('${tac_exp}'), 16)
    Should Be Equal   ${tac_ck}   ${tac_exp}

    ${amf_region_id}   cap.Get Element Value
    ...   element_expression=${XNAP}.amf_region_id
    ...   condition_expression=${filter}
    ...   element_idx=${0}
    Should Be Equal   ${amf_region_id[0]}   01


Check Wireshark XN Setup Response
    [Arguments]   ${file_name}   ${filter}   ${plmn}=64f020   ${tac_exp}=0000c8   ${band_log}=0028
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=${XNAP}
    ${Message_Type}   Catenate   ${filter}
    cap.Check Expression   condition_expression=${Message_Type}
    Wait Until Keyword Succeeds   15s   5s   cap.Check Expression   condition_expression=${Message_Type}
    FOR    ${index}    IN RANGE    50
       ${plmn_id} =    cap.get_element_value    element_expression=${XNAP}.plmn_id   element_idx=${index}   condition_expression=${filter}
       Return From Keyword If    '${plmn_id[0]}' == '${plmn}'    ${true}
    END
#    ${plmn_id}   cap.Get Element Value
#    ...   element_expression=${XNAP}.plmn_id
#    ...   condition_expression=${filter}
#    ...   element_idx=${0}
#    Should Be Equal   ${plmn_id[0]}   ${plmn}

    # ${band}    cap.Get Element Value
    # ...   element_expression=${XNAP}.nr_frequency_band
    # ...   condition_expression=${filter}
    # ...   element_idx=${0}
    # Should Be Equal   ${band[0]}   ${band_log}

    ${tac}   cap.Get Element Value
    ...   element_expression=${XNAP}.tac
    ...   condition_expression=${filter}
    ...   element_idx=${1}
    ${tac_ck}   Evaluate   int(str('${tac[0]}'), 16)
    ${tac_exp}   Evaluate   int(str('${tac_exp}'), 16)
    Should Be Equal   ${tac_ck}   ${tac_exp}

Check Wireshark XN Reset Request
    [Arguments]   ${file_name}   ${message_filter}
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=${XNAP}
    ${Message_Type}   Catenate   ${message_filter}
    cap.Check Expression   condition_expression=${Message_Type}

    ${id}   cap.Get Element Value
    ...   element_expression=${XNAP}.id
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
    Should Be Equal   ${id[0]}   0038

    ${ResetRequestTypeInfo}   cap.Get Element Value
    ...   element_expression=${XNAP}.ResetRequestTypeInfo
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
    Should Be Equal   ${ResetRequestTypeInfo[0]}   00

    ${misc}   cap.Get Element Value
    ...   element_expression=${XNAP}.misc
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
#    Should Be Equal   ${misc[0]}   68
    Should Contain Any   ${misc[0]}   68   64


Check Wireshark XN Reset Response
    [Arguments]   ${file_name}   ${message_filter}
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=${XNAP}
    ${Message_Type}   Catenate   ${message_filter}
    cap.Check Expression   condition_expression=${Message_Type}

    ${id}   cap.Get Element Value
    ...   element_expression=${XNAP}.id
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
    Should Be Equal   ${id[0]}   0039

    ${ResetResponseTypeInfo}   cap.Get Element Value
    ...   element_expression=${XNAP}.ResetResponseTypeInfo
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
    Should Be Equal   ${ResetResponseTypeInfo[0]}   00

Check Wireshark SCTP Shutdown
    [Arguments]   ${file_name}   ${SCTP_filter}
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=sctp
    ${Message_Type}   Catenate   ${SCTP_filter}
    cap.Check Expression   condition_expression=${Message_Type}

Check Wireshark NGRAN Node Config Update
    [Arguments]   ${file_name}   ${message_filter}   ${nrcellid}
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=${XNAP}
    ${Message_Type}   Catenate   ${message_filter}
    cap.Check Expression   condition_expression=${Message_Type}

    ${NR_Cell_Identity}   cap.Get Element Value
#    ...   element_expression=${XNAP}.${XNAP}.NR-Cell-Identity
    ...   element_expression=${XNAP}.NR_Cell_Identity
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}
    ${NR_Cell_Identity}   run keyword if   $NR_Cell_Identity   set variable   ${NR_Cell_Identity}
    ...   ELSE   cap.Get Element Value
    ...   element_expression=${XNAP}.NR-Cell-Identity
    ...   condition_expression=${message_filter}
    ...   element_idx=${0}

    Should contain   ${NR_Cell_Identity[0].lower()}   ${nrcellid.lower()}
#    Should Be Equal   ${NR_Cell_Identity[0]}   0010480010

Check Wireshark NGRAN Node Config Update ACK
    [Arguments]   ${file_name}
    cap.Read Cap   cap_file=${OUTPUT_DIR}/${file_name}   display_filter=${XNAP}
    ${Message_Type}   Catenate   ${XNAP}.RespondingNodeTypeConfigUpdateAck == 1
    cap.Check Expression   condition_expression=${Message_Type}

Set XNAP Protocol
    [Arguments]   ${file_name}
    ${XNAP}   OperatingSystem.Run   tshark -r ${OUTPUT_DIR}/${file_name} -P | grep -i xnap |awk 'NR==1{print $(NF-2)}'
    ${XNAP}   Strip String   ${XNAP}
    ${XNAP}   Convert To Lower Case   ${XNAP}
    [Return]   ${XNAP}
