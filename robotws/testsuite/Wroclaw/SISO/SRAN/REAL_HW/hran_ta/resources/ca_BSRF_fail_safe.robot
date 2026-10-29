*** Settings ***
Documentation  Maintainer: patryk.niewiejski@nokia.com
...  Resource for fail safe mode

Library           ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

*** Keywords ***

Enable Fail Safe Mode For RM
    [Arguments]  ${sn}  ${forced_reboot}=${True}
    Log To Console  Enabling Radio Module Fail Safe Mode on ${sn}
    ${fail_safe_mode_status}=  radio.Get Fail Safe Mode Status  ${sn}
    Run Keyword If  "${fail_safe_mode_status}"!="Enabled"
    ...  radio.Enable Radio Module Fail Safe Mode  ru_serial_number=${sn}  radio_reset=${forced_reboot}
    ...  ELSE  Log To Console  Radio Module Fail Safe Mode is enabled already - skipping...


Disable Fail Safe Mode For RM
    [Arguments]  ${sn}  ${forced_reboot}=${True}
    Log To Console  Disabling Radio Module Fail Safe Mode on ${sn}
    ${fail_safe_mode_status}=  radio.Get Fail Safe Mode Status  ${sn}
    Run Keyword If  "${fail_safe_mode_status}"!="Disabled"
    ...  radio.Disable Radio Module Fail Safe Mode  ru_serial_number=${sn}  radio_reset=${forced_reboot}
    ...  ELSE  Log To Console  Radio Module Fail Safe Mode is disabled already - skipping...


Check Fail Safe mode For RM
    [Arguments]  ${sn}  ${state}
    ${fail_safe_mode_status}=  radio.Get Fail Safe Mode Status  ${sn}
    Return From Keyword If  "${fail_safe_mode_status}"!="${state}"  Fail
