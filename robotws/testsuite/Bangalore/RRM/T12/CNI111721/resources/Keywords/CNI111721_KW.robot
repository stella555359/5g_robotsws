*** Settings ***
Documentation     This contains keywords used for CNI111721 automation cases.
...               :author Tom Toby
Resource       ./combo_mue_keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${AP_IP}                  192.168.200.1
${AP_USERNAME}            toor4nsn
${AP_PASSWORD}            oZPS0POrRieRtu
${VLAN_ID}                ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${vlanif_distname}        ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DeltaConfigDir}         ${CURDIR}/../../config/gnb_scf/
${APConfigDir}            ${CURDIR}/../../config/ap_iphy/
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts
${TOPOLOGY}         	CLOUD_5G_I_LO_AP_LO
${LUA_FILE}             ${CURDIR}/scripts.lua


*** Keywords ***
Full Commision Scf And Iphy
    [Documentation]    This keyword is used to change SCF and IPHY file
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword Unless    '${iphy}' == '${EMPTY}'    update_and_put_iphy_xml
    ...      input_filepath=${iphy}
    Run Keyword Unless    '${scf}' == '${EMPTY}'     Full Commission With SCF File For UTE
    ...    ${scf}

Register Multiple SA UEs
    [Arguments]             ${Start_UE}     ${End_UE}
    [Documentation]    This Keyword is to register multiple SA UEs and start traffic in uplink and downlink
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    ${End_UE}=    Evaluate   ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        Log to Console      Starting Registration for SA UE: ${UE_ID}
        Enable Internal TG   ${UE_ID}    1
        wtsrunner.ue_register   id=${UE_ID}
        Sleep   10s
        Pass Lua File       ${LUA_FILE}
        ${output}    Run Keyword And Ignore Error      Read WTS Output Until Pattern Matches
        ...         ${UE_register_complete_pattern}    ${Timeout_SA}
        Run Keyword Unless      ${output}=='PASS'
        ...     wtsrunner.ue_register   id=${UE_ID}
        Sleep   10s
        wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UE_ID}   nwslice=1   gw=1
        wtsrunner.Read Wtsemu Output Until Re
        ...               expected=Initial Context Setup Successful
        ...               timeout=${Timeout_SA}
        Sleep   15s
        Pass Lua File       ${LUA_FILE}
        Log to Console    Running DL/UL Traffic for UE:${UE_ID}
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=1   mbps=50    dir=dl    trf_id=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=1    mbps=50   dir=ul    trf_id=1
        Pass Lua File       ${LUA_FILE}
    END
