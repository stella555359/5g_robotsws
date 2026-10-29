*** Settings ***
Documentation   kw to run CB008717

Library         taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnb_scf
Library         taf.ue    WITH NAME    tafue
Library         testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CNI_107623.resources.attenuator.Attenuator    WITH NAME    attenuator
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        wireshark.robot
Variables       modify_para.py
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Library         CustomKeywords.py
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library         taf.rfrl.common_resources.reporting_portal.bts_metadata
Library         taf/rfrl/procedures/resources/python/setups_and_teardowns_keywords.py

#Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnb_cell
#Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    gnb_bts

*** Keywords ***
modify_parameter
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${should_activate}=${True}
    gnb_scf.perform_configuration_parameter_recommissioning     dist_name=${dist_name}
    ...                                                         parameter=${parameter}
    ...                                                         operation=update
    ...                                                         value=${value}
    ...                                                         should_activate=${should_activate}
    ...                                                         skip_parameter_relation_errors=${True}
    ...                                                         timeout=180

require_ue
    tafue.Require Ue    ue_alias=UE_1    capabilities=ANDROID_UE_1

attach_ue
    tafue.Attach Ue    ue_alias=UE_1

detach_ue
    tafue.Detach Ue    ue_alias=UE_1

log_info_ue
    tafue.Log Ue Info    UE_1
