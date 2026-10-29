*** Settings ***
Documentation    CB008779 keywords
Resource    ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource    LTE_TRACE.robot

*** Variables ***
${UE1}    LTE
${tce_ipv4}    10.21.41.148
${tce_ipv6}    2a00:8a00:8000:10c:1:d:0:402
${tce_ip}    2a00:8a00:8000:10c:1:d:0:402
${lnbts_id}    5050

*** Keywords ***
CB008779 verification
    Set Test Variable  ${UE}    ${UE1}
    Set Up UE       ${UE}
    Enable Tracing Falgs
    TCE IP version Check based On Mplane IP
    Delete CTRLTS
    Create CTRLTS
    Create MTRACE With Admin
    Make A Call For CB008779
    ${msg_list}=    Read Traced Content From UTF    ${lnbts_id}    LTE
    PCMD messgas Verification    ${msg_list}
#    MAC messagaes Verificaiton    ${msg_list}
    Delete CTRLTS

PCMD messgas Verification
    [Arguments]    ${msg_list}
    [documentation]    Possible PCMD messages:
    ...  PCMD_StartRecordingSession
    ...  bearerRecord
    ...  dlRbPdcpThroughputRecord
    ...  dlRbRlcThroughputRecord
    ...  dlSchedulingRecord
    ...  ripRecord
    ...  rrcSetupRecord
    ...  rtdRecord
    ...  ueInfoRecord
    ...  ueReleaseRecord
    ...  ueSetupRecord
    ...  ulLcgRecord
    ...  ulRbRlcThroughputRecord
    ...  ulSchedulingRecord
    ...  PCMD_StopRecordingSession
    ${expected_pcmd_msg_list}=    Create List
    ...    PCMD_StartRecordingSession    bearerRecord    dlRbPdcpThroughputRecord    dlRbRlcThroughputRecord
    ...    dlSchedulingRecord    ripRecord    rrcSetupRecord    rtdRecord    ueInfoRecord    ueReleaseRecord
    ...    ueSetupRecord    ulLcgRecord    ulRbRlcThroughputRecord    ulSchedulingRecord    PCMD_StopRecordingSession
    ${message_name_list}=    Get Message Name List    ${msg_list}
    FOR    ${msg}    IN    @{expected_pcmd_msg_list}
        Should Contain    ${message_name_list}    ${msg}
    END
    Get PCMD records    ${message_name_list}

Get PCMD records
    [Arguments]    ${message_name_list}
    [documentation]    message name end with "Record".
    ${pcmd_msg_list}=    Create List
    FOR    ${msg}    IN    @{message_name_list}
        ${end_with_record}=    Run Keyword And Return Status  Should Contain     ${msg}    Record
        Run Keyword If    ${end_with_record}    Append To List    ${pcmd_msg_list}    ${msg}
    END
    ${pcmd_msg_list}=    Remove Duplicates    ${pcmd_msg_list}
    Log List    ${pcmd_msg_list}

MAC messagaes Verificaiton
    [Arguments]    ${msg_list}
    [documentation]    MAC messagaes List:
    ...    MAC_CONTINUAL_TA
    ...    MAC_RI
    ...    MAC_PUSCH_PRB_NUMBER
    ...    MAC_PDSCH_PRB_NUMBER
    ...    MAC_PHR
    ...    MAC_UL_SINR
    ...    MAC_BSR
    ...    MAC_DL_UE_TPUT
    ...    MAC_UL_UE_TPUT
    ${expected_mac_msg_list}=    Create List    MAC_BSR    MAC_CONTINUAL_TA    MAC_DL_UE_TPUT    MAC_PDSCH_PRB_NUMBER
    ...    MAC_PHR    MAC_PUSCH_PRB_NUMBER    MAC_RI    MAC_UL_SINR    MAC_UL_UE_TPUT
    ${message_name_list}=    Get Message Name List    ${msg_list}
    FOR    ${msg}    IN    @{expected_mac_msg_list}
        Should Contain    ${message_name_list}    ${msg}    ignore_case=True
    END

Make A Call For CB008779
    [Documentation]    Short description.
    Attach UE And Start ICMP Ping		UE_alias=${UE}		required_ue=${UE}   ping_count=999
    Sleep    60s
    Detach UE And Stop Traffic      ${UE}

Repeat Site Reset Without HWF for 50 Times
    FOR    ${count}    IN RANGE    0    50
        Log To Console    Round ${count}
        Site Reset Without HWF
        Sleep    3min
    END

Site Reset Without HWF
    Disable BTS Start Up with HWF
    taf.sbts.oam.coam.admin.reset_site
    wait until keyword succeeds    30min    5s    Check if any cell is onAir
    Enable Loading HWF

Disable BTS Start Up with HWF
    ${hwf_loading}=    Run Keyword And Return status    BTS Start Up with HWF
    Run Keyword If    ${hwf_loading}==${FALSE}    Disable Loading HWF
    BTS Start Up with HWF

BTS Start Up with HWF
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh -o StrictHostKeyChecking=no toor4nsn@192.168.255.129
    ...    cat /rom/swconfig.txt|grep -i 4F0214|grep -v "#"
    ${output}=    Run    ${cmd}
    Should Contain    ${output}    =0

Disable Loading HWF
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh -o StrictHostKeyChecking=no toor4nsn@192.168.255.129
    ...    "echo 0x4F0214=0>>/rom/swconfig.txt"
    ${output}=    Run    ${cmd}

Enable Loading HWF
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh -o StrictHostKeyChecking=no toor4nsn@192.168.255.129
    ...    "sed -i \"s/0x4F0214=0//g\" /rom/swconfig.txt"

CB008779 Setup
    TC Setup
#    Fake Setup
    Get LNBTS ID

CB008779 Teardown
    Common Test Teardown
