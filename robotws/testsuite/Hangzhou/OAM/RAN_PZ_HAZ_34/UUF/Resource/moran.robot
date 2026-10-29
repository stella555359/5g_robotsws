*** Settings ***
Resource   webui_coam.robot
Variables   moran_vars.py

*** Keywords ***
Moran Set Share Mode
    [Arguments]   ${mode}=false
#    COAM Download SCF to Current Dir   filename=SCF_MORAN.xml
    ${shared_RUs}   Get Moran shared RU Settings
    ${web_addrs}   Create Dictionary   master=${WEBUI_ADDR}   slave=${Peer_WEBUI_ADDR}
    Set Suite Variable   ${shared_RUs}
    FOR   ${pos}   IN   master   slave
        Moran Set Mode    shared_RUs=${shared_RUs['${pos}']}   host=${web_addrs}[${pos}]   mode=${mode}
    END
    [Return]   ${shared_RUs}

Moran Set Mode
    [Arguments]   ${shared_RUs}   ${host}=${WEBUI_ADDR}   ${mode}=true
    webui_coam.WEBEM Login   url=https://${host}   sbts=moran
    ${value_modified}   Set Variable   ${False}
    FOR   ${ru_dist}   IN   @{shared_RUs}
        ${value}   Get Moran actIndSwUpgradeForSharedRU   distname=${ru_dist}   sbts=moran
        Continue For Loop If   $value == $mode
        Modify Moran actIndSwUpgradeForSharedRU   distname=${ru_dist}   value=${mode}   sbts=moran
        ${value_modified}   Set Variable   ${True}
    END
    selenium_sbts.Validate Plan   sbts=moran
    Run Keyword If   ${value_modified}   selenium_sbts.Activate Plan   sbts=moran
    [Teardown]   webui_coam.WEBEM Logout   sbts=moran

Get Moran actIndSwUpgradeForSharedRU
    [Arguments]   ${distname}   ${sbts}=${None}
    ${value}   selenium_sbts.Get Parameter Value   dist_name=${distname}   abbr=actIndSwUpgradeForSharedRU
    ...    filter_param=Activate independent SW upgrade for shared radio unit   sbts=${sbts}
    [Return]   ${value}

Modify Moran actIndSwUpgradeForSharedRU
    [Arguments]   ${distname}   ${value}   ${sbts}=${None}
    selenium_sbts.Set Parameter Value   dist_name=${distname}   abbr=actIndSwUpgradeForSharedRU   new_value=${value}
    ...    filter_param=Activate independent SW upgrade for shared radio unit   sbts=${sbts}

Get Moran shared RU Settings
    [Arguments]   ${bts_id}=${bts_id}
    [Return]   ${moran_shared_RUs}[${bts_id}]

Get Moran shared RU List
    [Arguments]     ${SCF_path}=${CURDIR}/SCF_MORAN.xml
    ${shareRU_upgrade}    XML.Get Elements    ${SCF_path}
    ...    xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    ${Req_RUs}   Create List
    FOR   ${element}   IN   @{shareRU_upgrade}
        ${children}   XML.Get Child Elements	${element}
        ${actIndSwUpgradeForSharedRU}   Found actIndSwUpgradeForSharedRU   ${children}
        Run Keyword If   $actIndSwUpgradeForSharedRU=="true"   Append To List   ${Req_RUs}   ${element.attrib["distName"]}
    END
    [Return]   ${Req_RUs}

Found actIndSwUpgradeForSharedRU
    [Arguments]   ${elements}
    ${actIndSwUpgradeForSharedRU}   Set Variable   false
    FOR   ${ele}   IN   @{elements}
        Return From Keyword If   $ele.attrib["name"] == "actIndSwUpgradeForSharedRU"   ${ele.text}
    END
    [Return]   false
