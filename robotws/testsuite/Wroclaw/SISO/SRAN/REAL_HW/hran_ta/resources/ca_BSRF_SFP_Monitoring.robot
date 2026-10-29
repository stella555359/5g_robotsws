*** Settings ***
Documentation    Maintainer: lukasz.wystup@nokia.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin

*** Keywords ***

Get SFP Links Type By Radio Module
    [Arguments]  ${rmod_sn}  ${cable_dn_type}=internal

    ${bts}  admin.Get BTS Info
    FOR  ${rmod}  IN  @{bts['radioModules']['rmod']}
        Continue For Loop If  '${rmod['serialNumber']}'!='${rmod_sn}'
        ${rmod_distname_id}  Set Variable  ${rmod['id']['internal']}
    END

    ${sfp_linkmode_dict}  Create Dictionary
    ${cablink_distname_to_sfp_linkmode_dict}  Create Dictionary
    FOR  ${cable}  IN  @{bts['cables']}
        Continue For Loop If  '${rmod_distname_id}' not in '${cable['secondEndPointId']['internal']}'
        Run Keyword If
        ...  '${cable['linkMode']['synchronization']}'=='True'  Run Keywords
        ...  Set To Dictionary  ${sfp_linkmode_dict}  ${cable['secondEndPointId']['${cable_dn_type}'][-1]}  primary
        ...  AND  Set To Dictionary  ${cablink_distname_to_sfp_linkmode_dict}  ${cable['id']['${cable_dn_type}']}  primary
        ...  ELSE  Run Keywords  Set To Dictionary  ${sfp_linkmode_dict}  ${cable['secondEndPointId']['${cable_dn_type}'][-1]}  secondary
        ...  AND  Set To Dictionary  ${cablink_distname_to_sfp_linkmode_dict}  ${cable['id']['${cable_dn_type}']}  secondary
    END

    [Return]  ${sfp_linkmode_dict}  ${cablink_distname_to_sfp_linkmode_dict}

Get Value For ActTransceiverAlarmMonitoring Parameter
    [Arguments]  ${object_variable_transceiver}

    ${param_value_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=default
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actTransceiverAlarmMonitoring_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${object_variable_transceiver}']/p[@name='actTransceiverAlarmMonitoring']/text())
    Set To Dictionary  ${param_value_dict}  actTransceiverAlarmMonitoring  ${actTransceiverAlarmMonitoring_scf}
    [Return]  ${param_value_dict}

Restore Reference Configuration
    [Arguments]  ${reference_dict}  ${object_variable_transceiver}

    Log To Console  Restore Reference Configuration...\n

    ${actual_dict}  Get Value For ActTransceiverAlarmMonitoring Parameter  ${object_variable_transceiver}
    Run Keyword If  '${reference_dict['actTransceiverAlarmMonitoring'].lower()}' != '${actual_dict['actTransceiverAlarmMonitoring'].lower()}'
    ...  Run Keywords
    ...  Log To Console  Transceiver alarms and warnings monitoring feature have to be restored to reference state, please wait!\n
    ...  AND  admin.Perform Parameter Recommissioning
    ...  ${object_variable_transceiver}  actTransceiverAlarmMonitoring  update  ${reference_dict['actTransceiverAlarmMonitoring']}
    ...  AND  Log To Console
    ...  Transceiver alarms and warnings monitoring feature restored to actPowerMeter -> ${reference_dict['actTransceiverAlarmMonitoring']}
    ...  ELSE
    ...  Log To Console  Transceiver alarms and warnings monitoring featurealready in reference state, no more actions needed!
