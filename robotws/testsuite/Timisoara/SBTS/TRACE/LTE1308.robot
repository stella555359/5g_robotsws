*** Settings ***
Documentation    CB008779 keywords
Library     taf.sbts.oam.coam.admin     #WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     DateTime
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
#Resource    ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource    LTE_TRACE.robot

*** Variables ***
${UE}    LTE
${tce_ipv4}    10.5.26.85
${tce_ipv6}    2a00:8a00:8000:10c:1:d:0:402
${tce_ip}    2a00:8a00:8000:10c:1:d:0:402
${lnbts_id}    10832

*** Keywords ***
LTE1308 Immediate MDT Basic Operation
    Set Up UE       ${UE}
    Enable Tracing Falgs
    TCE IP version Check based On Mplane IP
    Delete CTRLTS
    Create CTRLTS
    Create MTRACE With Admin    actPCMDReporting=false
    Make A Call for LTE1308
    ${msg_list}=    Read Traced Content From UTF
    Measurement Report Verification    ${msg_list}
    Delete CTRLTS

Measurement Report Verification
    [Arguments]    ${msg_list}
    ${user_data_list}=    Get User Data List   ${msg_list}
    FOR    ${user_data}    IN    @{user_data_list}
        ${MR_included}=    Run Keyword And Return Status    Should Contain    ${user_data}    MeasurementReport
        Return From Keyword If    ${MR_included}
    END
    Fail    Measurement Report Not found.

Make A Call for LTE1308
    [Documentation]    Short description.
    Attach UE And Start ICMP Ping		UE_alias=${UE}		required_ue=${UE}   ping_count=999
    Sleep    60s
    Detach UE And Stop Traffic      ${UE}

TC Setup
    Common Test Setup
    LTE_TRACE.Get BTS ID

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND   Setup Scout And Send Configuration
    ...  AND   Common Test Teardown
