*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Description: These keywords handles actions performed with on pdu ports
...              FT in charge: name + mailing list
...              Confluence link:
...              References: (documentation link(e.g. doors or sphinx))
...              QualityCenter: (test set url to QC)
...              Sample execution:

Library     ute_pdu
# Variables    config
Resource    ./system.robot

*** Variables ***
${PDU_ENB_ALIAS}=                   enb
${PDU_IPHY_ALIAS}=                  iphy
${PDU_EXTENSION_MODULE_ALIAS}=      extmod
${PDU_RMOD_ALIAS}=                  rmod

*** Keywords ***
PDU Setup Pdu
    [Arguments]    ${alias}
    ...            ${model}=${tl.pdu_type}
    ...            ${host}=${tl.pdu_ip}
    ute_pdu.Setup Pdu    host=${host}
    ...                  model=${model}
    ...                  alias=${alias}

PDU Teardown Pdu
    [Arguments]    ${alias}
    ute_pdu.Teardown Pdu    alias=${alias}

PDU Turn On IPHY Port
    PDU Setup Pdu    alias=${PDU_IPHY_ALIAS}
    Pdu Outlet On    outlet=${tl.iphy_pdu_outlet}
    ...              alias=${PDU_IPHY_ALIAS}
    PDU Teardown Pdu    alias=${PDU_IPHY_ALIAS}

PDU Turn On ENB Port
    PDU Setup Pdu    alias=${PDU_ENB_ALIAS}
    Pdu Outlet On    outlet=${tl.enb_pdu_outlet}
    ...               alias=${PDU_ENB_ALIAS}
    PDU Teardown Pdu    alias=${PDU_ENB_ALIAS}

PDU Turn Off IPHY Port
    PDU Setup Pdu    alias=${PDU_IPHY_ALIAS}
    Pdu Outlet Off    outlet=${tl.iphy_pdu_outlet}
    ...               alias=${PDU_IPHY_ALIAS}
    PDU Teardown Pdu    alias=${PDU_IPHY_ALIAS}

PDU Turn Off ENB Port
    PDU Setup Pdu    alias=${PDU_ENB_ALIAS}
    Pdu Outlet Off    outlet=${tl.enb_pdu_outlet}
    ...               alias=${PDU_ENB_ALIAS}
    PDU Teardown Pdu    alias=${PDU_ENB_ALIAS}

PDU IPHY Port Reset
    PDU Setup Pdu    alias=${PDU_IPHY_ALIAS}
    Pdu Outlet Reset    outlet=${tl.iphy_pdu_outlet}
    ...                 alias=${PDU_IPHY_ALIAS}
    PDU Teardown Pdu    alias=${PDU_IPHY_ALIAS}

PDU ENB Port Reset
    PDU Setup Pdu    alias=${PDU_ENB_ALIAS}
    Pdu Outlet Reset    outlet=${tl.enb_pdu_outlet}
    ...                 alias=${PDU_ENB_ALIAS}
    PDU Teardown Pdu    alias=${PDU_ENB_ALIAS}

PDU Turn Off RMOD port
    [Arguments]  ${rmod_number}
    PDU Setup Pdu    alias=${PDU_RMOD_ALIAS}
    Pdu Outlet Off    outlet=${tl.rf[${rmod_number}].pdu.port}
    ...               alias=${PDU_RMOD_ALIAS}
    PDU Teardown Pdu    alias=${PDU_RMOD_ALIAS}

PDU Turn On RMOD port
    [Arguments]  ${rmod_number}
    PDU Setup Pdu    alias=${PDU_RMOD_ALIAS}
    Pdu Outlet On    outlet=${tl.rf[${rmod_number}].pdu.port}
    ...              alias=${PDU_RMOD_ALIAS}
    PDU Teardown Pdu    alias=${PDU_RMOD_ALIAS}

PDU RMOD port reset
    [Arguments]  ${rmod_number}
    PDU Setup Pdu    alias=${PDU_RMOD_ALIAS}
    Pdu Outlet Reset    outlet=${tl.rf[${rmod_number}].pdu.port}
    ...                 alias=${PDU_RMOD_ALIAS}
    PDU Teardown Pdu    alias=${PDU_RMOD_ALIAS}

PDU Turn On ENB And IPHY Ports
    PDU Turn On ENB Port
    PDU Turn On IPHY Port

PDU Turn Off ENB And IPHY Ports
    PDU Turn Off ENB Port
    PDU Turn Off IPHY Port

PDU Reset ENB And IPHY Ports
    PDU ENB Port Reset
    PDU IPHY Port Reset

PDU Reset IPHY And ENB Ports
    PDU IPHY Port Reset
    PDU RESET Port Reset

PDU Turn Off ENB and IPHY Ports And Check If Not Reachable
    PDU Turn Off ENB And IPHY Ports
    SYSTEM Check If Enb And Iphy Are Not Pingable

PDU Turn Off ENB Port And Check If Not Reachable
    PDU Turn Off ENB Port
    SYSTEM Check If ENB Is Not Pingable

PDU Turn Off IPHY Port And Check If Not Reachable
    PDU Turn Off IPHY Port
    SYSTEM Check If Iphy Is Not Pingable

PDU ENB Port Reset And Check If Not Pingable
    PDU ENB Port Reset
    SYSTEM Check If ENB Is Not Pingable

PDU IPHY Port Reset And Check If Not Pingable
    PDU IPHY Port Reset
    SYSTEM Check If Iphy Is Not Pingable

PDU Reset ENB And IPHY Ports And Check If Not Reachable
    PDU Reset ENB And IPHY Ports
    SYSTEM Check If Enb And Iphy Are Not Pingable

PDU ENB And IPHY Reset And Check If Not Reachable
    [Documentation]
    ...   1. eNB pdu reset
    ...   2. IPHY pdu reset
    ...   3. Ping check for eNB and IPHY
    PDU Reset ENB And IPHY Ports
    SYSTEM Check If Enb And Iphy Are Not Pingable

PDU IPHY And ENB Reset And Check If Not Reachable
    [Documentation]
    ...   1. IPHY pdu reset
    ...   2. eNB pdu reset
    ...   3. Ping check for eNB and IPHY
    PDU Reset IPHY And ENB Ports
    SYSTEM Check If Enb And Iphy Are Not Pingable

PDU Turn On BBMOD Port
    [Arguments]    ${bbmod_number}
    ...            ${alias}=${PDU_EXTENSION_MODULE_ALIAS}
    PDU Setup Pdu    alias=${alias}
    Pdu Outlet On    outlet=${tl.bbmod${bbmod_number}_pdu_outlet}    alias=${alias}
    PDU Teardown Pdu    alias=${alias}

PDU Turn Off BBMOD Port
    [Arguments]    ${bbmod_number}
    ...            ${alias}=${PDU_EXTENSION_MODULE_ALIAS}
    PDU Setup Pdu    alias=${alias}
    Pdu Outlet Off    outlet=${tl.bbmod${bbmod_number}_pdu_outlet}    alias=${alias}
    PDU Teardown Pdu    alias=${alias}

PDU Turn On Specific Outlet
    [Arguments]    ${alias}
    ...            ${outlet}
    ...            ${model}=${tl.pdu_type}
    ...            ${host}=${tl.pdu_ip}
    PDU Setup Pdu    alias=${alias}
    ...              model=${model}
    ...              host=${host}
    Pdu Outlet On    outlet=${outlet}
    ...              alias=${alias}
    PDU Teardown Pdu    alias=${alias}

PDU Turn Off Specific Outlet
    [Arguments]    ${alias}
    ...            ${outlet}
    ...            ${model}=${tl.pdu_type}
    ...            ${host}=${tl.pdu_ip}
    PDU Setup Pdu    alias=${alias}
    ...              model=${model}
    ...              host=${host}
    Pdu Outlet Off    outlet=${outlet}
    ...               alias=${alias}
    PDU Teardown Pdu    alias=${alias}

PDU Reset Specific Outlet
    [Arguments]    ${alias}
    ...            ${outlet}
    ...            ${model}=${tl.pdu_type}
    ...            ${host}=${tl.pdu_ip}
    PDU Setup Pdu    alias=${alias}
    ...              model=${model}
    ...              host=${host}
    Pdu Outlet Reset    outlet=${outlet}
    ...                 alias=${alias}
    PDU Teardown Pdu    alias=${alias}
