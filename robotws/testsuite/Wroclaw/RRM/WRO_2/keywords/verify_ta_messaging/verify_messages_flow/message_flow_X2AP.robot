*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

*** Keywords ***
Set expected message flow X2AP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${endcX2Setup}=0    ${endcConfigUpd}=0
    Set expected message flow X2AP ENDC    gnb_id=${gnb_id}    timeout=${timeout}    endcX2Setup=${endcX2Setup}    endcConfigUpd=${endcConfigUpd}

Set expected message flow X2AP ENDC
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${endcX2Setup}=0    ${endcConfigUpd}=0
    Run Keyword If    '${endcX2Setup}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} X2AP ${endcX2Setup}*endcX2Setup
    Run Keyword If    '${endcConfigUpd}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} X2AP ${endcConfigUpd}*endcConfigurationUpdate

Verify expected message flow X2AP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${endcX2Setup}=0    ${endcConfigUpd}=0
    Verify expected message flow X2AP ENDC    gnb_id=${gnb_id}    timeout=${timeout}    endcX2Setup=${endcX2Setup}    endcConfigUpd=${endcConfigUpd}

Verify expected message flow X2AP ENDC
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${endcX2Setup}=0    ${endcConfigUpd}=0
    Run Keyword If    '${endcX2Setup}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} X2AP ${endcX2Setup}*endcX2Setup
    Run Keyword If    '${endcConfigUpd}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} X2AP ${endcConfigUpd}*endcConfigurationUpdate
