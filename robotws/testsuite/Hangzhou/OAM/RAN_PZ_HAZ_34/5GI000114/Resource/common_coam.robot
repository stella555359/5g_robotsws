*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ./NetAct_Fast_Pass_common.robot
Library    os

*** Variables ***
# ${file_name}   old_commission.xml
${testline_name}      null
${CONFIGURATION}      null

*** Keywords ***
COAM Get All Suite Variables
    COAM Login
    ${release}   COAM Get SW Release
    Set Suite Variable   ${RELEASE}   ${RELEASE}

    ${active_sw_version}   ${passive_sw_version}   ${planned_sw_version}   COAM Get SW Version
    Set Suite Variable   ${SOFTWARE_VERSION}   ${active_sw_version}

    ${bts_info}   COAM Get BTS Info
    ${systemModule}   Set Variable   ${bts_info['systemModules'][0]['productName']}
    @{split_list}   Split String   ${systemModule}   ${SPACE}
    Set Suite Variable   ${SYSTEM_MODULE}   ${split_list[0]}

    COAM Backup SCF
    ${XML}   XML.Parse XML   source=${OUTPUT_DIR}/old_commission.xml
    ${oam_tls_status}   xml.Get Element Text   ${XML}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="oamTls"]
    Run Keyword If    '${oam_tls_status}'=='off'    Set Suite Variable    ${NE3SWS_mode}    no TLS
    ...    ELSE    Set Suite Variable    ${NE3SWS_mode}    TLS

    ${status_ip}=    Run Keyword And Return Status    Should Contain    ${oam_addr}    :
    Run Keyword If    ${status_ip}    Set Suite Variable    ${NE3SWS_IPversion}    IPv6
    ...    ELSE    Set Suite Variable    ${NE3SWS_IPversion}    IPv4
    Set Suite Variable   ${Dns_flag}   False

    [Teardown]  COAM Logout

COAM Update Parameter ON COAM ADMIN
    [Arguments]   ${dist_name}   ${parameter}   ${value}
    Run Keyword And Ignore Error   COAM Logout
    COAM Login
    COAM Update Parameter
    ...   dist_name=${dist_name}
    ...   parameter=${parameter}
    ...   value=${value}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

COAM Wait GNB Startup
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   15m   1m   COAM Login
    ${status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    Log To Console   BTS OnAir Status: ${status}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

COAM Check Cell Status Expected
    [Arguments]    ${cell_target_status}
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ${COAM_webUI_output}   COAM Get Cell Status
    ${cell_actual_status}   Set Variable   ${COAM_webUI_output['administrativeState']}
    Should Be Equal   ${cell_actual_status.lower()}   ${cell_target_status.lower()}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

COAM Check Snssai Status Expected
    [Arguments]    ${snssai_target_status}
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ${COAM_webUI_output}  COAM Get Parameter Value   ${MO_name}/${NO_name}/SNSSAI-1   administrativeState
    #${cell_actual_status}   Set Variable   ${COAM_webUI_output['administrativeState']}
    Should Be Equal   ${COAM_webUI_output.lower()}   ${snssai_target_status.lower()}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

COAM Login And Backup SCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=old_commission.xml
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM Backup SCF   local_dir=${local_dir}   file_name=${file_name}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

COAM Login And Load SCF
    [Arguments]   ${filepath}=${OUTPUT_DIR}/old_commission.xml
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM SCF Commission   filepath=${filepath}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

COAM Login And Check Parameter Value
    [Arguments]   ${dist_name}   ${parameter}   ${expect_value}
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ${actual_value}   COAM Get Parameter Value   dist_name=${dist_name}   parameter=${parameter}
    Should Be Equal   ${actual_value}   ${expect_value}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

Commissioning SCF And Check On Air 5GI000114
    [Arguments]   ${Active_SW_version}=9999
    @{rest}    String.split string    string=${Active_SW_version}    separator=.
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -41
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${EXTRACTED_TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${EXTRACTED_TLNAME}[0]
    ${GOLDEN_FULL_SCF}   Set Variable    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_${rest}[0].xml
    COAM Login And Load SCF   ${GOLDEN_FULL_SCF}
    COAM Wait GNB Startup
