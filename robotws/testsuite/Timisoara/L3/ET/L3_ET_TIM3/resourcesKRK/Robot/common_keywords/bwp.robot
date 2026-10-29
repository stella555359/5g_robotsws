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
${rb_scs15_bw5}=  25
${rb_scs15_bw10}=  52
${rb_scs15_bw15}=  79
${rb_scs15_bw20}=  106
${rb_scs15_bw25}=  133
${rb_scs15_bw30}=  160
${rb_scs15_bw40}=  216
${rb_scs15_bw50}=  270

${loc_and_bw_scs15_bw5}=  6600
${loc_and_bw_scs15_bw10}=  14025
${loc_and_bw_scs15_bw15}=  21450
${loc_and_bw_scs15_bw20}=  28875
${loc_and_bw_scs15_bw25}=  36300
${loc_and_bw_scs15_bw30}=  32174
${loc_and_bw_scs15_bw40}=  16774
${loc_and_bw_scs15_bw50}=  1924

${rb_scs30_bw5}=  11
${rb_scs30_bw10}=  24
${rb_scs30_bw15}=  38
${rb_scs30_bw20}=  51
${rb_scs30_bw25}=  65
${rb_scs30_bw30}=  78
${rb_scs30_bw40}=  106
${rb_scs30_bw50}=  133
${rb_scs30_bw60}=  162
${rb_scs30_bw70}=  189
${rb_scs30_bw80}=  217
${rb_scs30_bw90}=  245
${rb_scs30_bw100}=  273

${loc_and_bw_scs30_bw5}=  2750
${loc_and_bw_scs30_bw10}=  6325
${loc_and_bw_scs30_bw15}=  10175
${loc_and_bw_scs30_bw20}=  13750
${loc_and_bw_scs30_bw25}=  17600
${loc_and_bw_scs30_bw30}=  21175
${loc_and_bw_scs30_bw40}=  28875
${loc_and_bw_scs30_bw50}=  36300
${loc_and_bw_scs30_bw60}=  31624
${loc_and_bw_scs30_bw70}=  24199
${loc_and_bw_scs30_bw80}=  16499
${loc_and_bw_scs30_bw90}=  8799
${loc_and_bw_scs30_bw100}=  1099

*** Keywords ***
Verify that UE${ue_id:\d+} is configured with ${bwp_type:(large|small)} BWP profile after ICS at NRCELL-${cell_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (
    ...         downlinkBWP-ToAddModList contains (
    ...             locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp_type}_bwp}[1]
    ...         )
    ...         and
    ...         uplinkBWP-ToAddModList contains (
    ...             locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp_type}_bwp}[1]
    ...         )
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run keyword if   "${bwp_type}" == "small"
    ...     Verify That Message Fulfills Query
    ...     downlinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp_type}_bwp}[0])
    ...     and
    ...     uplinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp_type}_bwp}[0])
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run keyword if   "${bwp_type}" == "large"
    ...     Verify That Message Fulfills Query
    ...     (carrierBandwidth is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}


Verify that UE${ue_id:\d+} is configured with ${bwp_type:(large|small)} BWP profile in RRC Reconfiguration after BFR at NRCELL-${cell_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Run keyword if   "${bwp_type}" == "small"
    ...     Verify That Message Fulfills Query
    ...     downlinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp_type}_bwp}[0])
    ...     and
    ...     uplinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp_type}_bwp}[0])
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

Verify that UE${ue_id:\d+} is configured only with large BWP after inter GNB HO
    ${flow}=     Get Flow Name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

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

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextModificationRequest
    ...    rach_should_be_present=True    setup_release=setup
    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextModificationResponse
    ...    rach_should_be_present=True    setup_release=release

Verify that RACH config setup is present in PS-BWP for UE${ue_id:\d+} after inter gNB HO
    ${flow}=     Get Flow Name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextSetupResponse    rach_should_be_present=True    setup_release=setup

Verify that RACH config is not present in PS-BWP for UE${ue_id:\d+} after inter gNB HO
    ${flow}=     Get Flow Name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=UEContextSetupResponse    rach_should_be_present=False
