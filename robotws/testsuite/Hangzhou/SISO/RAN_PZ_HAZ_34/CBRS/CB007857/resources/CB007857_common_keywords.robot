*** Settings ***
Resource    ../../resources/cbrs_common_keywords.robot

Documentation    This is for CB007857 common keywords
...              Author: cailanwen
...              Squard: HZ SG8

*** Variables ***
${CB007857_conf_path}    ${CURDIR}/conf
${CB007857_1_conf}    ${CB007857_conf_path}/CB007857_1.conf

*** Keywords ***
CB007857_background_hunting_channel_block_bigger_than_desiredCHBW
    Set NRCBSDCELL Parameter by coam    parameter_name=desiredCHBW    parameter_value=40MHz
    Set NRCBSDCELL Parameter by coam    parameter_name=maxGrantChBwRed    parameter_value=40
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    ${chBw_coam}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
    should be True    '${chBw_coam}'=='40MHz'
    sleep    5min   # querySasServerPeriod expired
    ${chBw_coam}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
    should be True    '${chBw_coam}'=='60MHz'
    Check CBRS L3 call    tput=${60M_TPUT}

Set NRCBSDCELL Parameter by coam
    [Arguments]    ${parameter_name}    ${parameter_value}    ${CELLID}=1    ${NRCBSDCELL}=0
    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${CELLID}/NRCBSDCELL-${NRCBSDCELL}
    ...    parameter=${parameter_name}
    ...    value=${parameter_value}
    ...    operation=update
    ...    connection=GNB_OAM

CB007857_maxERIP_check_8DL_40MHz
    ${8D4U_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_8D4U_
    Commissioning SCF And Check RU On Air    scf_file_path=${8D4U_SCF}
    Activate feature CBRS By Coam
    Start SAS server
    Wait until keyword succeeds    5min    20s    verify all cells should be onair
    ${chBw}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
    ${pmax}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=pMax
    ${nrCellType}    Get NRCELL value by coam    class_name=NRCELL_A    pattern=nrCellType
    ${antennaGain}    Get NRCBSD_A value by coam    pattern=antennaGain
    ${maxEiRP_exp}    Calculate_maxEiRP    pMax=${pmax}    antGain=${antennaGain}    chBw=${chBw}   numStreams=${nrCellType}
    ${maxEiRP_log}    get_maxEiRP_from_SASlog    filepath=${sas_log_path}
    should be equal    ${maxEiRP_log}    13.1

CB007857_grant_fail_desiredCHBW_less_than_channel_block_with_maxGrantChBwRed_0
    Start SAS server    config_name=${CB007857_1_conf}
    Wait until keyword succeeds    5min    10s    Check SI trigger and no grant request
    Wait until keyword succeeds    5min    10s    Expect Fault Should Present    faultId=6828

Check SI trigger and no grant request
    [Arguments]    ${NRCBSDID}=1    ${ru_index}=1
    log to console    Start Check SI trigger and no grant request
    Get Correct Register Parameters Value By Coam    groupId_need=${False}    groupType_need=${False}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is not found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    [Teardown]    end_to_check

Set TL32 peak PA
    [Documentation]   [TEST PURPOSE]Set TL32 Peak PA   Owner_lanwen.cai@nokia-sbell.com
    ${PA_CBRS}    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    FOR  ${index}    IN RANGE    13    17
        attenuator.set_attenuation    port=${index}    value=${10}    attenuator_device=${PA_CBRS}
    END
