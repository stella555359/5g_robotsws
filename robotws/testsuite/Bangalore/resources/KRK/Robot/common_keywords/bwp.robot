*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ../../Python/bwp_verifiers.py

*** Variables ***
&{BW_TO_SCS15KHz_RB}=   5=25      10=52     15=79     20=106    25=133    30=160    40=216    50=270
&{BW_TO_SCS30KHz_RB}=   5=11      10=24     15=38     20=51     25=65     30=78     40=106    50=133
...                     60=162    70=189    80=217    90=245    100=273

*** Keywords ***
Get BWP fields in RRC for NRCELL-${cell_id:\d+}
    ${already_calculated}    get variable value      ${NRCELL_${cell_id}_RRC_BWP}    "False"
    ${rrc_bwp}=    Run keyword if    ${already_calculated}=="False"
    ...    Calculate BWP fields in RRC    &{NRCELL_${cell_id}_BWP}
    ...    ELSE    set variable    ${NRCELL_${cell_id}_RRC_BWP}

    [Return]    ${rrc_bwp}

Calculate BWP fields in RRC
 	[Documentation]
 	...    Keyword can be used once per suite, or after each NRCELL BWP parameters related reconfiguration
 	...    Usage example with all possible parameters in &{CELL_BWP} dictionary:
 	...    1. For not asymmetric cell
    ...    &{CELL_BWP}=    (mandatory)    ID=1    SMALL_BW=10    LARGE_BW=30
    ...                    (optional)    SECOND_BW=20    BLANKED_PRB_LOW_UL=10    BLANKED_RPB_LOW_DL=10
 	...    2. For asymmetric cell
    ...    &{CELL_BWP}=    (mandatory)    ID=1    ASYMMETRIC=${TRUE}    SMALL_BW_DL=10    SMALL_BW_UL=10    LARGE_BW_DL=30    LARGE_BW_UL=10
    ...                    (optional)    SECOND_BW_DL=20    SECOND_BW_UL=10    BLANKED_PRB_LOW_UL=10    BLANKED_PRB_LOW_DL=10

    [Arguments]    &{CELL_BWP}
    ${scs}=    get enb parameter value    NRCELL-${CELL_BWP.ID}    ssbScs
    ${asymmetric_cell}=    get variable value    ${CELL_BWP.ASYMMETRIC}    ${FALSE}
    ${blanked_prbs_dl}=    get variable value    ${CELL_BWP.BLANKED_PRB_LOW_DL}    ${0}
    ${blanked_prbs_ul}=    get variable value    ${CELL_BWP.BLANKED_PRB_LOW_UL}    ${0}

    ${rb_dl_small}=    Run Keyword If    ${asymmetric_cell}    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SMALL_BW_DL}']}
    ...                ELSE                                    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SMALL_BW}']}
    ${rb_ul_small}=    Run Keyword If    ${asymmetric_cell}    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SMALL_BW_UL}']}
    ...                ELSE                                    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SMALL_BW}']}
    ${rb_dl_second}=   Run Keyword If    ${asymmetric_cell}    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SECOND_BW_DL}']}
    ...                                                                               "NOT_DEFINED IN TEST SUITE"
    ...                ELSE                                    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SECOND_BW}']}
    ...                                                                               "NOT_DEFINED IN TEST SUITE"
    ${rb_ul_second}=   Run Keyword If    ${asymmetric_cell}    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SECOND_BW_UL}']}
    ...                                                                               "NOT_DEFINED IN TEST SUITE"
    ...                ELSE                                    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.SECOND_BW}']}
    ...                                                                               "NOT_DEFINED IN TEST SUITE"
    ${rb_dl_large}=    Run Keyword If    ${asymmetric_cell}    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.LARGE_BW_DL}']}
    ...                ELSE                                    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.LARGE_BW}']}
    ${rb_ul_large}=    Run Keyword If    ${asymmetric_cell}    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.LARGE_BW_UL}']}
    ...                ELSE                                    Get variable Value     ${BW_TO_SCS${scs}_RB['${CELL_BWP.LARGE_BW}']}
    ${rb_dl_large}=    Evaluate    ${rb_dl_large} - ${blanked_prbs_dl}
    ${rb_ul_large}=    Evaluate    ${rb_ul_large} - ${blanked_prbs_ul}

    ${loc_and_bw_small_dl}=    calculate locationAndBandwidth    ${rb_dl_small}   ${blanked_prbs_dl}
    ${loc_and_bw_small_ul}=    calculate locationAndBandwidth    ${rb_ul_small}   ${blanked_prbs_ul}
    ${loc_and_bw_second_dl}=   Run Keyword If    ${rb_dl_second}=="NOT_DEFINED IN TEST SUITE"
    ...                        Set variable    "NOT CALCULATED"
    ...                        ELSE
    ...                        calculate locationAndBandwidth    ${rb_dl_second}  ${blanked_prbs_dl}
    ${loc_and_bw_second_ul}=   Run Keyword If    ${rb_ul_second}=="NOT_DEFINED IN TEST SUITE"
    ...                        Set variable    "NOT CALCULATED"
    ...                        ELSE
    ...                        calculate locationAndBandwidth    ${rb_ul_second}  ${blanked_prbs_ul}
    ${loc_and_bw_large_dl}=    calculate locationAndBandwidth    ${rb_dl_large}   ${blanked_prbs_dl}
    ${loc_and_bw_large_ul}=    calculate locationAndBandwidth    ${rb_ul_large}   ${blanked_prbs_ul}

    ${rrc_bwp}=    Create dictionary
    ...    rb_dl_small=${rb_dl_small}
    ...    rb_ul_small=${rb_ul_small}
    ...    rb_dl_second=${rb_dl_second}
    ...    rb_ul_second=${rb_ul_second}
    ...    rb_dl_large= ${rb_dl_large}
    ...    rb_ul_large= ${rb_ul_large}
    ...    loc_and_bw_dl_small=${loc_and_bw_small_dl}
    ...    loc_and_bw_ul_small=${loc_and_bw_small_ul}
    ...    loc_and_bw_dl_second=${loc_and_bw_second_dl}
    ...    loc_and_bw_ul_second=${loc_and_bw_second_ul}
    ...    loc_and_bw_dl_large=${loc_and_bw_large_dl}
    ...    loc_and_bw_ul_large=${loc_and_bw_large_ul}
    ...    offset_dl_small=${blanked_prbs_dl}
    ...    offset_dl_second=${blanked_prbs_dl}
    ...    offset_dl_large=${0}
    ...    offset_ul_small=${blanked_prbs_ul}
    ...    offset_ul_second=${blanked_prbs_ul}
    ...    offset_ul_large=${0}

    set suite variable    &{NRCELL_${CELL_BWP.ID}_RRC_BWP}    &{rrc_bwp}
    [Return]  &{NRCELL_${CELL_BWP.ID}_RRC_BWP}

Calculate locationAndBandwidth
    [Arguments]    ${rb}    ${blanked_prbs}

    ${location_and_bandwidth}=    run Keyword if
    ...    ${${rb} - ${1}} <= ${137}
    ...        Evaluate    ${275} * (${rb} - ${1}) + ${blanked_prbs}
    ...    ELSE
    ...        Evaluate    ${275} * (${275} - ${rb} + ${1}) + (${275} - ${1} - ${blanked_prbs})

    [Return]    ${location_and_bandwidth}

Verify that UE${ue_id:\d+} is configured with ${bwp_type} BWP profile after ${procedure:ICS|reestablishment} to NRCELL-${cell_id:\d+}
    Builtin.Log         ${procedure}
    Should match regexp  ${bwp_type}  large|second|small
    ${rrc_bwp}=    Get BWP fields in RRC for NRCELL-${cell_id}

    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (
    ...         downlinkBWP-ToAddModList contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_${bwp_type}])
    ...         and
    ...         uplinkBWP-ToAddModList contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_ul_${bwp_type}])
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run keyword if   "${bwp_type}" != "large"
    ...     Verify That Message Fulfills Query
    ...     downlinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${rrc_bwp}[rb_dl_${bwp_type}])
    ...     and
    ...     uplinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${rrc_bwp}[rb_ul_${bwp_type}])
    ...     and
    ...     downlinkChannelBW-PerSCS-List contains (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...     and
    ...     uplinkChannelBW-PerSCS-List contains (offsetToCarrier eq ${rrc_bwp}[offset_ul_${bwp_type}])
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run keyword if   "${bwp_type}" == "large"
    ...     Verify That Message Fulfills Query
    ...     (carrierBandwidth is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that UE${ue_id:\d+} is configured with ${bwp_type} BWP profile after HO to NRCELL-${cell_id:\d+}
    Should match regexp  ${bwp_type}  large|second|small
    ${rrc_bwp}=    Get BWP fields in RRC for NRCELL-${cell_id}

    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (
    ...         downlinkBWP-ToAddModList contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_${bwp_type}])
    ...         and
    ...         uplinkBWP-ToAddModList contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_ul_${bwp_type}])
    ...     )
    ...     and
    ...     spCellConfigCommon contains (
    ...         initialDownlinkBWP contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_small])
    ...         and
    ...         initialUplinkBWP contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_ul_small])
    ...     )
    ...     and
    ...     spCellConfigCommon contains (
    ...         downlinkConfigCommon contains (carrierBandwidth eq ${rrc_bwp}[rb_dl_large])
    ...         and
    ...         uplinkConfigCommon contains (carrierBandwidth eq ${rrc_bwp}[rb_ul_large])
    ...         and
    ...         downlinkConfigCommon contains (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...         and
    ...         uplinkConfigCommon contains (offsetToCarrier eq ${rrc_bwp}[offset_ul_${bwp_type}])
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run keyword if   "${bwp_type}" != "large"
    ...     Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (
    ...         downlinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${rrc_bwp}[rb_dl_${bwp_type}])
    ...         and
    ...         uplinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${rrc_bwp}[rb_ul_${bwp_type}])
    ...         and
    ...         downlinkChannelBW-PerSCS-List contains (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...         and
    ...         uplinkChannelBW-PerSCS-List contains (offsetToCarrier eq ${rrc_bwp}[offset_ul_${bwp_type}])
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that UE${ue_id:\d+} is configured with PSCell NRCELL-${cell_id:\d+} ${bwp_type} BWP profile after EN-DC setup with gNB${gnb_id:\d+}
    Should match regexp  ${bwp_type}  large|second|small
    ${rrc_bwp}=    Get BWP fields in RRC for NRCELL-${cell_id}
    ${flow_alias_x2ap}=     Get Flow Name
    ...     procedure=sgNBAdditionPreparation
    ...     device=gNB${gnb_id}
    ...     protocol=X2AP
    Builtin.Log     ${ue_id}

    Verify That Message Fulfills Query
    ...     spCellConfigCommon contains (
    ...         downlinkConfigCommon contains (carrierBandwidth eq ${rrc_bwp}[rb_dl_${bwp_type}])
    ...         and
    ...         uplinkConfigCommon contains (carrierBandwidth eq ${rrc_bwp}[rb_ul_${bwp_type}])
    ...         and
    ...         downlinkConfigCommon contains (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...         and
    ...         uplinkConfigCommon contains (offsetToCarrier eq ${rrc_bwp}[offset_ul_${bwp_type}])
    ...     )
    ...     and
    ...     spCellConfigDedicated contains (
    ...         downlinkBWP-ToAddModList contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_${bwp_type}])
    ...         and
    ...         uplinkBWP-ToAddModList contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_ul_${bwp_type}])
    ...     )
    ...     and
    ...     spCellConfigCommon contains (
    ...         initialDownlinkBWP contains ( locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_ul_small])
    ...         and
    ...         initialUplinkBWP contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_ul_small])
    ...     )
    ...     message_alias=SgNBAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias_x2ap}

Verify that UE${ue_id:\d+} is configured with SCell NRCELL-${cell_id:\d+} ${bwp_type} BWP profile after EN-DC setup with gNB${gnb_id:\d+}
    Should match regexp  ${bwp_type}  large|second|small
    ${rrc_bwp}=    Get BWP fields in RRC for NRCELL-${cell_id}
    ${physcellid}=    get enb parameter value    NRCELL-${cell_id}    physCellId

    ${flow_alias_x2ap}=     Get Flow Name
    ...     procedure=sgNBAdditionPreparation
    ...     device=gNB${gnb_id}
    ...     protocol=X2AP
    Builtin.Log     ${ue_id}

    Verify That Message Fulfills Query
    ...     sCellToAddModList contains (
    ...         (physCellId eq ${physcellid})
    ...         and
    ...         (sCellConfigDedicated contains (
    ...             locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_${bwp_type}]
    ...         ))
    ...         and
    ...         (initialDownlinkBWP contains (
    ...             locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_small]
    ...         ))
    ...         and
    ...         (downlinkConfigCommon contains (
    ...             (carrierBandwidth eq ${rrc_bwp}[rb_dl_${bwp_type}])
    ...             and
    ...             (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...         ))
    ...     )
    ...     message_alias=SgNBAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias_x2ap}

Verify that UE${ue_id:\d+} is configured with SCell NRCELL-${cell_id:\d+} ${bwp_type} BWP profile
    Verify in 1 out of 1 RRCReconfiguration that UE${ue_id} is configured with SCell NRCELL-${cell_id} ${bwp_type} BWP

Verify in ${num:\d+} out of ${all:\d+} RRCReconfiguration that UE${ue_id:\d+} is configured with SCell NRCELL-${cell_id:\d+} ${bwp_type} BWP
    Should match regexp  ${bwp_type}  large|second|small
    ${rrc_bwp}=    Get BWP fields in RRC for NRCELL-${cell_id}
    ${physcellid}=    get enb parameter value    NRCELL-${cell_id}    physCellId

    ${procedure}    set variable if    ${all} == ${1}    RRCReconfiguration    ${all}*RRCReconfiguration
    ${message_alias}    set variable if    ${all} == ${1}    RRCReconfiguration    RRCReconfiguration_${num}

    ${flow_alias_rrc}=     Get Flow Name
    ...     ${procedure}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     sCellToAddModList contains (
    ...         (physCellId eq ${physcellid})
    ...         and
    ...         (sCellConfigDedicated contains (
    ...             locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_${bwp_type}]
    ...         ))
    ...         and
    ...         (initialDownlinkBWP contains (
    ...             locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_small]
    ...         ))
    ...         and
    ...         (downlinkConfigCommon contains (
    ...             (carrierBandwidth eq ${rrc_bwp}[rb_dl_${bwp_type}])
    ...             and
    ...             (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...         ))
    ...     )
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias_rrc}

Verify that UE${ue_id:\d+} is not configured with PS-BWP after ICS
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    run keyword and expect error
    ...    AssertionError
    ...    Verify That Message Fulfills Query
    ...    (bwp-Id contains (2))
    ...    message_alias=RRCReconfiguration
    ...    flow_alias=${flow}

Verify that UE${ue_id:\d+} is configured with ${bwp_type} BWP profile in RRC Reconfiguration after BFR at NRCELL-${cell_id:\d+}
    Should match regexp  ${bwp_type}  large|second|small
    ${rrc_bwp}=    Get BWP fields in RRC for NRCELL-${cell_id}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Run keyword if   "${bwp_type}" != "large"
    ...     Verify That Message Fulfills Query
    ...     downlinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${rrc_bwp}[rb_dl_${bwp_type}])
    ...     and
    ...     uplinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${rrc_bwp}[rb_ul_${bwp_type}])
    ...     and
    ...     downlinkChannelBW-PerSCS-List contains (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...     and
    ...     uplinkChannelBW-PerSCS-List contains (offsetToCarrier eq ${rrc_bwp}[offset_ul_${bwp_type}])
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run keyword if   "${bwp_type}" == "large"
    ...     Verify That Message Fulfills Query
    ...     (carrierBandwidth is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}


Verify that UE${ue_id:\d+} is configured with PS-BWP after ICS
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list    flow_alias=${flow}    message_alias=RRCReconfiguration

Verify that UE${ue_id:\d+} is configured with PS-BWP after ICS in PCell
    ${flow}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list_beamforming
    ...    flow_alias=${flow}
    ...    message_alias=RRCReconfiguration_1
    ...    number_of_beams=2

Beamforming (${number_of_beams:\d+} beams): Verify that UE${ue_id:\d+} is configured with PS-BWP after ICS
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list_beamforming
    ...    flow_alias=${flow}
    ...    message_alias=RRCReconfiguration
    ...    number_of_beams=${number_of_beams}

Beamforming (${number_of_beams:\d+} beams): Verify that UE${ue_id:\d+} is configured only with large BWP after ICS
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_full_bwp_on_csi_and_bwp_to_add_mod_list_beamforming
    ...    flow_alias=${flow}
    ...    message_alias=RRCReconfiguration
    ...    number_of_beams=${number_of_beams}

Verify that UE${ue_id:\d+} is configured only with large BWP after ICS
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_full_bwp_on_csi_and_bwp_to_add_mod_list    flow_alias=${flow}    message_alias=RRCReconfiguration

Verify that UE${ue_id:\d+} is configured with PS-BWP after inter GNB HO
    ${flow}=     Get Flow Name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP
    verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list_during_ho    flow_alias=${flow}    message_alias=UEContextSetupResponse
    Builtin.Log     ${ue_id}

Verify that UE${ue_id:\d+} is configured only with large BWP after inter GNB HO
    ${flow}=     Get Flow Name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP
    Builtin.Log     ${ue_id}
    verify_full_bwp_on_csi_and_bwp_to_add_mod_list_during_ho    flow_alias=${flow}    message_alias=UEContextSetupResponse

Verify that UE${ue_id:\d+} is configured with PS-BWP after intra GNB HO
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list_during_ho    flow_alias=${flow}    message_alias=RRCReconfiguration

Verify that UE${ue_id:\d+} is configured only with large BWP after intra gNB HO
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_full_bwp_on_csi_and_bwp_to_add_mod_list_during_ho    flow_alias=${flow}    message_alias=RRCReconfiguration

Verify that RACH config setup is present in PS-BWP for UE${ue_id:\d+}
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=RRCReconfiguration    rach_should_be_present=True    setup_release=setup

Verify that RACH config is not present in PS-BWP for UE${ue_id:\d+}
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=RRCReconfiguration    rach_should_be_present=False

Verify that RACH config is not present in PS-BWP for UE${ue_id:\d+} in PCell
    ${flow}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=RRCReconfiguration_1    rach_should_be_present=False

Verify that RACH config release is present in PS-BWP for UE${ue_id:\d+}
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=RRCReconfiguration    rach_should_be_present=True    setup_release=release

Verify that RACH config setup is present in UEContextModificationRequest and release in UEContextModificationResponse for UE${ue_id:\d+}
    ${flow}=     Get Flow Name
    ...     procedure=uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP
    Builtin.Log     ${ue_id}
    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextModificationRequest
    ...    rach_should_be_present=True    setup_release=setup
    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextModificationResponse
    ...    rach_should_be_present=True    setup_release=release

Verify that RACH config setup is present in PS-BWP for UE${ue_id:\d+} after inter gNB HO
    ${flow}=     Get Flow Name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP
    Builtin.Log     ${ue_id}
    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextSetupResponse    rach_should_be_present=True    setup_release=setup

Verify that RACH config is not present in PS-BWP for UE${ue_id:\d+} after inter gNB HO
    ${flow}=     Get Flow Name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP
    Builtin.Log     ${ue_id}
    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextSetupResponse    rach_should_be_present=False
