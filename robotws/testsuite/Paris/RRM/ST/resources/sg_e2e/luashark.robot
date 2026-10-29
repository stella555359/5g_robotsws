*** Settings ***
Documentation
...  Helpfull keyword to download autoamatically the related luashark for the gnb Software.
...                Author: Abderrahmane NEZROUK
...                Update: 08/06/2021 SBTS loads management


Library         OperatingSystem
Library         Process
Library         ${CURDIR}/remote_load_url.py      WITH NAME    rload
Library         Collections
Library         String

*** Keywords ***
Get Related Luashark
    [Documentation]    This keyword catch the luashark file for the given gNB release
    [Arguments]    ${rel}

    ${luashark_url}    rload.get_remote_luashark_url    ${rel}
    ${cmd}    catenate    curl --head --silent ${luashark_url} | head -n 1
    ${resp}     Run   timeout 5 ${cmd}
    ${UrlFound}    Is Fullstring Contain SubString   ${resp}    200
    Run Keyword If    ${UrlFound}
    ...  Download Related Luashark    ${luashark_url}

Download Related Luashark
    [Documentation]    This keyword catch the luashark file
    [Arguments]    ${luashark_url}
    ${cmd}      catenate         cd /opt/;timeout 60 sudo wget
	...   ${luashark_url}
    ${resp}     Run         ${cmd}
    log     ${resp}
    @{fname}    Split String    ${luashark_url}    /
    ${resp}     Run         sudo rm -rf /opt/luashark
    ${resp}     Run         sudo mkdir /opt/luashark
    ${resp}     Run         cd /opt/;sudo unzip -o /opt/@{fname}[-1]
    ${resp}     Run         sudo cp -rf /opt/generated_luashark/* /opt/luashark/
    ${resp}     Run         sudo chmod 777 /opt/luashark
    ${resp}     Run         sudo chmod 777 -R /opt/luashark/*
    ${resp}     Run         sudo rm -r /opt/generated_luashark/
    ${resp}     Run         sudo rm -f /opt/@{fname}[-1]
    # UCI Work Around
    Attempt to Perform Arithmetic on nil Work Around

Is Fullstring Contain SubString
	[Documentation]    this keword return True if fullstring conatin subString expression
	[Arguments]        ${fullstring}    ${substring}
	${match}    ${value}    Run Keyword And Ignore Error    Should Contain    ${fullstring}    ${substring}
    ${resp}   Set Variable If    '${match}' == 'PASS'    ${True}    ${False}
    [Return]    ${resp}

UCI Work Around
    [Documentation]    this keword return True if fullstring conatin subString expression
    ${resp}     Run         sudo cp  -f ${CURDIR}/luasharkWA/UCI.lua /opt/luashark/
    ${resp}     Run         sudo yes | cp -f ${CURDIR}/luasharkWA/PucchReceiveRespPs.lua /opt/luashark/5G_L1-UL_L2-PS/UlData/
    ${resp}     Run         sudo yes | cp -f ${CURDIR}/luasharkWA/PucchReceiveReq.lua /opt/luashark/5G_L1-UL_L2-PS/UlData/

Attempt to Perform Arithmetic on nil Work Around
    [Documentation]    The temporary solution is in using Luashark Q&A 6.1.10.
    #to avoid yes: standard output: "Broken pipe when copy existing file"
    ${resp}    Run    sudo rm /opt/luashark/itf/L2Log/Du/Ps/Events/DssSlotType/RrmFddCurrentDlShareBitmap80.lua
    ${resp}    Run    sudo cp ${CURDIR}/luasharkWA/RrmFddCurrentDlShareBitmap80.lua /opt/luashark/itf/L2Log/Du/Ps/Events/DssSlotType/
