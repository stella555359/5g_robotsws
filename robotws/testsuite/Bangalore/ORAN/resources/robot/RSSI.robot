*** Settings ***
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin
Library    Collections
Library    ../python/RSSIValidator.py

*** Keywords ***
RSSI_Values_Validation    [Arguments]    ${cell}    ${UD_Value}=2
     ${cell info} =    Get Cell Specific Info    ${cell}
     Return From Keyword    validate_rssi    ${cell info}
