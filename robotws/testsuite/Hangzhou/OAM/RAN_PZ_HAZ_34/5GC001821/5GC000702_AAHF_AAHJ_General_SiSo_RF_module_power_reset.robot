#  *** Settings ***
#  Documentation
#  ...   author: He Jingmin
#  ...   contact: jingmin.he@nokia-sbell.com
# 
#  Resource   ./Resource/common.robot
#  Resource   ./Resource/702.robot
#  Library   taf.pdu   WITH NAME   pdu
#  Suite Setup   Suite Setup Steps
#  Suite Teardown   Suite Teardown Steps
#  Force Tags   SG_08   CA_5G_Siso         CRT
#  ...    PY36
# 
#  *** Variables ***
#  &{qc_AAHJ_id}   O=422227   L=NA   M=NA
#  &{qc_AAHF_id}   O=NA   L=NA   M=NA
# 
#  *** Test Cases ***
#  [1]5GC000702_AAHF_AAHJ_General_SiSo_RF_module_power_reset
#      [Timeout]    5h
#      [Tags]    AUTHOR_jingmin.he@nokia-sbell.com
#      [Setup]   Case Setup
#  #    Set Common Test Tag   case_key=rf_power_reset
#      ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
#      ${ru_count}   Get Length   ${rus}
#      :FOR   ${index}    IN RANGE    ${ru_count}
#          One RU Power Reset   rus=${rus}   index=${index+1}
#      END
#      [Teardown]   Run Keywords   COAM Logout
#      ...   AND    Case Teardown
# 
#  *** Keywords ***
#  One RU Power Reset
#      [Arguments]   ${rus}   ${index}
#      ${pb_host}   Set Variable   ${rus[${index-1}].pdu_port.pdu.addr}
#      ${pb_port}   Set Variable   ${rus[${index-1}].pdu_port.port_no}
#      pdu.setup_pdu   model=HBTE   host=${pb_host}   alias=ru_${index}
#      log to console    RF POWER OFF RU${index}!
#      RF power operation   pb_port=${pb_port}   alias=ru_${index}   operation=off
#      log to console      CHECK RU${index} Abnormal!
#      Wait Until Keyword Succeeds   5m   30s   RU Status abnormal   index=${index}
#      log to console      RF POWER ON RU${index}!
#      RF power operation   pb_port=${pb_port}   alias=ru_${index}
#      log to console      CHECK RU${index} status normal!
#      Wait Until Keyword Succeeds   10m   30s   Check RU Status   rmod=${index}
#      log to console      CHECK cells on air!
#      Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
#      [Teardown]   RF power operation   pb_port=${pb_port}   alias=ru_${index}
# 
#  RU Status abnormal
#      [Arguments]   ${index}
#      ${ru_normal}   Run Keyword and Return Status   Check RU Status    rmod=${index}
#      Should Not Be True   ${ru_normal}
# 
#  Check RU Status
#      [Arguments]    ${rmod}=1
#      ${ru_status}=    selenium_coam.get_ru_info    ru_index=${rmod}
#      ${operational_state}=  set variable  ${ru_status["Status"]["Operational state"]}
#      ${availability_status}=  set variable   ${ru_status["Status"]["Availability status"]}
#      ${administrative_state}=  set variable  ${ru_status["Status"]["Administrative state"]}
#      Should Be Equal   ${administrative_state.lower()}   unlocked
#  #    Should Be Equal   ${availability_status.lower()}   online
#      Should Be Equal   ${operational_state.lower()}   enabled
# 
# 
#  RF power operation
#      [Arguments]   ${pb_port}   ${alias}   ${operation}=on
#      run keyword    pdu.power_${operation}   port=${pb_port}   pdu_device=${alias}
#      Sleep   5s
#      ${pb_status}   pdu.get_port_status   port=${pb_port}   pdu_device=${alias}
#      Should Be Equal   ${pb_status.lower()}   ${operation}