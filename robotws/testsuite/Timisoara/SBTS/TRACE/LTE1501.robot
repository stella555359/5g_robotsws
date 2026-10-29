*** Settings ***
Documentation    keywords
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
MDT with enhCellVendorSpecTracing on 4TRX TDD Radio
    Set Up UE       ${UE}
    Enable Tracing Falgs
    TCE IP version Check based On Mplane IP
    Delete CTRLTS
    Create CTRLTS
    Create MTRACE With Admin
    Attach UE And Start ICMP Ping		UE_alias=${UE}		required_ue=${UE}   ping_count=999
    Sleep    60s
    Detach UE And Stop Traffic      ${UE}
    ${msg_list}=    Read Traced Content From UTF
    MAC messagaes Verificaiton    ${msg_list}
    No Crash
    Delete CTRLTS

No Crash
    ${alarms}=    taf.sbts.oam.coam.admin.get_active_alarms
    FOR    ${alarm}    IN    @{alarms}
        Should not be True    '${alarm}[faultId]'=='6450'
    END

LTE1501 setup
    TC Setup
#    Fake Setup
    Get BTS ID

LTE1501 teardown
    Common Test Teardown
