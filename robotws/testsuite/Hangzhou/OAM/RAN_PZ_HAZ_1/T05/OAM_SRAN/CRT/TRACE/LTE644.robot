*** Settings ***
Documentation    CB008779 keywords
Resource    ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource    LTE_TRACE.robot

*** Variables ***
${UE}    LTE
${tce_ipv4}    10.21.41.148
${tce_ipv6}    2a00:8a00:8000:10c:1:d:0:402
${tce_ip}    2a00:8a00:8000:10c:1:d:0:402
${lnbts_id}    5050

*** Keywords ***
LTE644 Subscriber and Equipment Trace
    Set Up UE       ${UE}
    Enable Tracing Falgs
    TCE IP version Check based On Mplane IP
    Delete CTRLTS
    Create CTRLTS    extUeTraceRep=true
    Make A Call for LTE644
    ${msg_list}=    Read Traced Content From UTF
    SBA Trace Records Verification    ${msg_list}
    Delete CTRLTS

SBA Trace Records Verification
    [Arguments]    ${msg_list}
    FOR    ${msg}    IN    @{msg_list}
        Log Dictionary    ${msg}
    END

Make A Call for LTE644
    [Documentation]    Short description.
    Attach UE And Start ICMP Ping		UE_alias=${UE}		required_ue=${UE}   ping_count=999
    Sleep    60s
    Detach UE And Stop Traffic      ${UE}

LTE644 Setup
    TC Setup
#    Fake Setup
    Get BTS ID

LTE644 Teardown
    Common Test Teardown
