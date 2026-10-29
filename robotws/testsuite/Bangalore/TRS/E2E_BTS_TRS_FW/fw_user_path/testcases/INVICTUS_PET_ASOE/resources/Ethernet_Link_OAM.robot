*** Settings ***
Documentation
...                 [Author]    "Nandini R"
...                 [Maintenance]    "TRS I & V Tools Bangalore Team"

Library             Ethernet_Link_OAM.py


*** Keywords ***
Check Activate Loopback
#    ${interface}=    Set variable    EIF4
    ${result}=    Activate_Loopback
    LOG    ${result}
    ${tx}=    Convert To Integer    ${result['transmitted_non_oam']}
    ${rx}=    Convert To Integer    ${result['received_non_oam']}
    Should Be True    ${tx} == ${rx} and ${tx} > 0
