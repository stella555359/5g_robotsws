*** Settings ***
Documentation
...    Common keywords for UE handling

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_utils.py
Library      taf.transport.ssh     WITH NAME   ssh
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot

*** Keywords ***
Is Ue Reserved
    [Arguments]    ${ue}
    ${value}=    Get Variable Value    ${${ue}_reserved}
    ${is_reserved}=    Set Variable If    ${value} == None or ${value} == ${False}     ${False}    ${True}
    [Return]    ${is_reserved}

Check Cell And Signal Strength For Ue
    [Arguments]    ${ue}
    ${pci}    Run Keyword And Ignore Error    ute_ue.Get UE Info  ${ue}  PCI
    ${rsrp}    Run Keyword And Ignore Error    ute_ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
    Show Text on Console    UE: ${ue} cell: ${pci}[1], rsrp: ${rsrp}[1]    colour=${GREEN}    show_timestamp=no
    Set Test Variable    ${${ue}_RSRP}    ${rsrp}
    [Return]    ${pci}    ${rsrp}

Require Ue If Not Reserved
    [Arguments]    ${ue_alias}    ${scope}=test
    ${reserved}    Is Ue Reserved    ${ue_alias}
    Run Keyword If    not ${reserved}
    ...    Require Ue    ${ue_alias}    capabilities=${ue_alias}
    IF    '${scope}' == 'suite'
        Set Suite Variable    ${${ue_alias}_reserved}    ${True}
    ELSE IF    '${scope}' == 'test'
        Set Test Variable    ${${ue_alias}_reserved}    ${True}
    END


Change APN
    [Arguments]   ${apn_name}  ${ue_name}  ${plmn}=310260
    [Documentation]    Change or create a new apn with given name
    ...     :param apn_name:   A name of appn to change
    ...     :param ue_name:    UE name from yaml config - taf.ue.proxy only
    ...     :param plmn:       UE plmn (imsi)

    Import Variables    ${tl.ues[0]}
    ssh.connect_to
    ...    hostname=${UE_POOLS['TafUeAndroidPool']['inline_config']['${ue_name}']['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_address']}
    ...    username=${UE_POOLS['TafUeAndroidPool']['inline_config']['${ue_name}']['CONSTRUCTOR_PARAMETERS']['configuration']['login']}
    ...    password=${UE_POOLS['TafUeAndroidPool']['inline_config']['${ue_name}']['CONSTRUCTOR_PARAMETERS']['configuration']['password']}
    ...    alias=ue_pc

    ${ue_sn}   Set Variable   ${UE_POOLS['TafUeAndroidPool']['inline_config']['${ue_name}']['CONSTRUCTOR_PARAMETERS']['serial_number']}
    ${command_to_execute}   Set Variable   content query --uri content://telephony/carriers --where \\"name=\'${apn_name}\'\\"
    ${output}   ssh.execute   adb -s ${ue_sn} shell "${command_to_execute}"
    ...                       timeout=2s
    ...                       connection=ue_pc

    ${apn_id}  get_apn_id_from_query   ${output}  ${apn_name}  ${plmn}
    ssh.execute   adb -s ${ue_sn} shell \"content insert --uri content://telephony/carriers/preferapn --bind apn_id:i:${apn_id}\"
    ...           timeout=2s
    ...           connection=ue_pc

    Log To Console   \n APN for ${ue_name}, SN:${ue_sn} changed to \'${apn_name}\'

Enable Inactive State Feature On Ue
    [Documentation]    Enabling Inactive State on ue. Only MTK ues
    [Arguments]    ${ue}
    Require Ue If Not Reserved    ${ue}
    Set Mtk Sbp Feature    ${ue}    5    SBP_DISABLE_NR_RRC_INACTIVE_STATUS    0


Reboot Ue Before Test
    [Arguments]    ${ue}
    ${IS_REBOOTED}=    Get Variable Value    ${IS_REBOOTED_${ue}}    None
    ${IS_REBOOTED}=    Set Variable If    '${IS_REBOOTED}' == 'None'    ${FALSE}    ${IS_REBOOTED}
    IF  ${IS_REBOOTED} == ${FALSE}
        Require Ue If Not Reserved    ${ue}
        Reboot Ue    ${ue}
        Detach Ue    ${ue}
        Set Suite Variable  ${IS_REBOOTED_${ue}}  ${TRUE}
    END
