from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.XML import XML
from ta_messaging.message_flows import get_flow
from ta_pdml_parser import parse_rrc5g_container
from functools import reduce
from robot.utils import asserts


def verify_that_nr_rrc_dmrs_uplinkforpusch_does_not_contain_dmrs_additionalposition(pdml_file, mapping_type):
    """
    Verifies that dmrs additional position is not present in RRC, meaning that pos2 is used

    :param pdml_file: PDML file converted
    :param mapping_type:   PUSCH or PDSCH Mapping type [ "B" or "A" ]
    """
    xpath = ".//field[@name='f1ap.DUtoCURRCInformation_element']" \
            "//field[@name='nr-rrc.dmrs_UplinkForPUSCH_MappingType{}']" \
            "//field[@name='nr-rrc.dmrs_AdditionalPosition']".format(mapping_type.upper())
    XML().element_should_not_exist(source=pdml_file, xpath=xpath)


def verify_that_nr_rrc_dmrs_downlinkforpdsch_does_not_contain_dmrs_additionalposition(pdml_file):
    """
    Verifies that dmrs additional position is not present in RRC, meaning that pos2 is used

    :param pdml_file: PDML file converted
    """
    path = ".//field[@name='f1ap.DUtoCURRCInformation_element']" \
           "//field[@name='nr-rrc.spCellConfig']" \
           "//field[@name='nr-rrc.pdsch_Config']" \
           "//field[@name='nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA']" \
           "//field[@name='nr-rrc.dmrs_AdditionalPosition']"
    XML().element_should_not_exist(source=pdml_file, xpath=path)


def verify_the_value_of_dmrs_additionalposition(pdml_file, mapping_type, value, direction):
    """
    Verifies the value of dmrs additional position in case it's pos0 or pos1

    :param pdml_file: PDML file
    :param mapping_type:  PUSCH or PDSCH Mapping type [ "B" or "A" ]
    :param value: value of the additional dmrs symbol ["0" or "1"]
    :param direction: Physical channel direction ["UplinkForPUSCH" / "DownlinkForPDSCH"]
    """
    xpath = ".//field[@name='f1ap.UEContextSetupResponse_element']" \
            "//field[@name='f1ap.DUtoCURRCInformation_element']//field[@name='nr-rrc.dmrs_{0}_MappingType{1}']//" \
            "field[@name='nr-rrc.dmrs_AdditionalPosition']".format(direction, mapping_type.upper())
    XML().element_attribute_should_be(source=pdml_file, name="show", expected=value, xpath=xpath)


def verify_the_value_of_high_speed_cell_activation_at_l2_ps(pdml_file, value):
    xpath = ".//field[@name='itf_l2_ps_cell_CellSetupReq_t.actHighSpeedCell']"
    xpath_alternative = ".//field[@name='itf_l2_ps_cell_CellSetupReq.actHighSpeedCell']"
    attributes = XML().get_elements(source=pdml_file, xpath=xpath_alternative) if \
        len(XML().get_elements(source=pdml_file, xpath=xpath)) == 0 else \
        XML().get_elements(source=pdml_file, xpath=xpath)
    for attr in attributes:
        asserts.assert_equal(attr.get("show"), value, "Values do not match {0} != {1}".format(attr.get("show"), value),
                             values=False)


def verify_the_value_of_dmrs_additional_position_in_l2ps(pdml_file, value, channel):
    xpath = ".//field[@name='itf_l2_ps_{0}_{1}Config.dmrsAdditionalPosition']".format(channel.lower(), channel)
    attributes = XML().get_elements(source=pdml_file, xpath=xpath)
    for attr in attributes:
        asserts.assert_equal(attr.get("show"), value, "Values do not match {0} != {1}".format(value, attr.get("show")),
                             values=False)


def verify_the_value_of_dl_layers_at_l2_ps(pdml_file, value):
    xpath = ".//field[@name='itf_l2_ps_cellconfigmodifyparam_t']" \
            "//field[@name='itf_l2_ps_pdsch_PdschConfig.maxNumOfDlLayers']"
    attributes = XML().get_elements(source=pdml_file, xpath=xpath)
    for attr in attributes:
        asserts.assert_equal(attr.get("show"), value, "Values do not match {0} != {1}".format(value, attr.get("show")),
                             values=False)


def verify_max_mimo_layers_value(pdml_file, max_mimo_value, channel):
    """
    Verifies the maxMIMOLayers value in RRC

    :param pdml_file:  PDML file
    :param max_mimo_value: Expected max mimo layers values
    :param channel: Physical channel ("pusch" or "pdsch")
    """
    path = ".//field[@name='f1ap.UEContextSetupResponse_element']" \
           "//field[@name='f1ap.DUtoCURRCInformation_element']//field[@name='nr-rrc.{}_ServingCellConfig']" \
           "//field[@name='nr-rrc.maxMIMO_Layers']".format(channel)
    XML().element_attribute_should_be(source=pdml_file, xpath=path, expected=max_mimo_value, name="show")


def verify_tput_deviation_is_within_margin(tput_1, tput_2, margin):
    difference = abs(int(tput_1) - int(tput_2))
    percent_deviation = float((difference/int(tput_2)))*100
    assert percent_deviation < int(margin)


def get_from_message(flow_alias, message_alias, field):
    msg = get_flow(flow_alias).get_message(message_alias)
    field_values = msg.get_all_values_by_key(field)
    if len(field_values) > 1:
        if field != 'eventId':
            return field_values[0]
        field_value_list = list()
        for field_value in field_values:
            field_value_list.append(field_value.keys()[0])
        return field_value_list
    else:
        return field_values[0]


def get_nr_ue_capabilities_from_message(flow_alias, message_alias, field):
    ue_capabilityrat_containerlist = parse_rrc5g_container("UE-CapabilityRAT-ContainerList",
                                                           get_from_message(flow_alias, message_alias, field))
    nr_ue_capabilities = parse_rrc5g_container("UE-NR-Capability",
                                               ue_capabilityrat_containerlist[u'UE-CapabilityRAT-ContainerList'][0][
                                                   u'ue-CapabilityRAT-Container'])
    BuiltIn().log(nr_ue_capabilities)
    return nr_ue_capabilities


def assert_ue_capability(map_list, data_dict, expected_result):
    value = reduce(lambda x, y: x.__getitem__(y) if isinstance(x, dict) or isinstance(x, list) else None, map_list,
                   data_dict)
    assert str(value) == str(expected_result)


def verify_that_ue_supports_feature(
        flow_alias,
        message_alias,
        field,
        feature_name,
        expected_result
):
    ue_capabilities_fields = {
        'ss-SINR-Meas': ['UE-NR-Capability', 'measAndMobParameters', 'measAndMobParametersFRX-Diff', 'ss-SINR-Meas'],

        'pusch-256QAM': ['UE-NR-Capability', 'rf-Parameters', 'supportedBandListNR', 0, 'pusch-256QAM'],

        'absoluteTPC-Command': ['UE-NR-Capability', 'phy-Parameters', 'phy-ParametersFRX-Diff', 'absoluteTPC-Command'],

        'pucch-F3-4-HalfPi-BPSK': ['UE-NR-Capability', 'phy-Parameters', 'phy-ParametersFRX-Diff',
                                   'pucch-F3-4-HalfPi-BPSK'],

        'channelBWs-DL': ['UE-NR-Capability', 'rf-Parameters', 'supportedBandListNR', 0, 'channelBWs-DL',
                          'fr1', 'scs-30kHz'],

        'twoFL-DMRS-TwoAdditionalDMRS-UL': ['UE-NR-Capability', 'phy-Parameters', 'phy-ParametersFRX-Diff',
                                            'twoFL-DMRS-TwoAdditionalDMRS-UL'],

        'oneFL-DMRS-TwoAdditionalDMRS-UL': ['UE-NR-Capability', 'phy-Parameters', 'phy-ParametersFRX-Diff',
                                            'oneFL-DMRS-TwoAdditionalDMRS-UL'],

        'oneFL-DMRS-TwoAdditionalDMRS-DL': ['UE-NR-Capability', 'featureSets', 'featureSetsDownlink-v1540', 0,
                                            'oneFL-DMRS-TwoAdditionalDMRS-DL'],

        'ptrs-DensityRecommendationSetUL_freqDensity1': ['UE-NR-Capability', 'rf-Parameters', 'supportedBandListNR', 0,
                                                         'mimo-ParametersPerBand', 'ptrs-DensityRecommendationSetUL',
                                                         'scs-30kHz', 'frequencyDensity1'],

        'ptrs-DensityRecommendationSetUL_freqDensity2': ['UE-NR-Capability', 'rf-Parameters', 'supportedBandListNR', 0,
                                                         'mimo-ParametersPerBand', 'ptrs-DensityRecommendationSetUL',
                                                         'scs-30kHz', 'frequencyDensity2'],

        'ptrs-DensityRecommendationSetDL_freqDensity1': ['UE-NR-Capability', 'rf-Parameters', 'supportedBandListNR', 0,
                                                         'mimo-ParametersPerBand', 'ptrs-DensityRecommendationSetDL',
                                                         'scs-30kHz', 'frequencyDensity1'],

        'ptrs-DensityRecommendationSetDL_freqDensity2': ['UE-NR-Capability', 'rf-Parameters', 'supportedBandListNR', 0,
                                                         'mimo-ParametersPerBand', 'ptrs-DensityRecommendationSetDL',
                                                         'scs-30kHz', 'frequencyDensity2'],

        'onePortsPTRS': ['UE-NR-Capability', 'phy-Parameters', 'phy-ParametersFRX-Diff', 'onePortsPTRS'],

        'supportedDMRS-TypeDL': ['UE-NR-Capability', 'phy-Parameters', 'phy-ParametersFRX-Diff',
                                 'supportedDMRS-TypeDL'],

        'supportedDMRS-TypeUL': ['UE-NR-Capability', 'phy-Parameters', 'phy-ParametersFRX-Diff',
                                 'supportedDMRS-TypeUL']
    }

    ue_capabilities_fields = {k.lower(): v for k, v in ue_capabilities_fields.items()}

    nr_ue_capabilities = get_nr_ue_capabilities_from_message(flow_alias, message_alias, field)

    assert_ue_capability(
        ue_capabilities_fields[feature_name.lower()],
        nr_ue_capabilities,
        expected_result
    )


def verify_the_value_of_pucch_additional_dmrs(pdml_file):
    xpath = ".//field[@name='f1ap.UEContextSetupResponse_element']" \
            ".//field[@name='nr-rrc.pucch_Config']" \
            ".//field[@name='nr-rrc.format3']" \
            ".//field[@name='nr-rrc.additionalDMRS']"

    XML().element_attribute_should_be(source=pdml_file, xpath=xpath,
                                      expected="additionalDMRS: true (0)", name="showname")


def verify_that_message_meets_the_post_conditions_criteria(message, field, value, pdml_file):
    xpath = ".//proto[@name='{}']" \
            ".//field[@name='{}']".format(message, field)
    attributes = XML().get_elements(source=pdml_file, xpath=xpath)
    for attr in attributes:
        asserts.assert_equal(attr.get("show"), value, message, values=False)


def verify_ptrs_density_config_in_ue_capability_param(density_dir, density_num, value, pdml_file):
    xpath = ".//field[@name='f1ap.UEContextSetupRequest_element']" \
            ".//field[@name='nr-rrc.UE_NR_Capability_element']" \
            ".//field[@name='nr-rrc.ptrs_DensityRecommendationSet{}_element']" \
            ".//field[@name='nr-rrc.frequencyDensity{}']".format(density_dir.upper(), density_num)
    if value.lower() == "not_exist":
        XML().element_should_not_exist(source=pdml_file, xpath=xpath)
    else:
        XML().element_attribute_should_be(source=pdml_file, xpath=xpath,
                                          expected=value, name="show")


def verify_frequency_density_for_downlink(density_value1, density_value2, pdml_file):
    xpath = ".//field[@name='nr-rrc.rrcReconfiguration_element']" \
            ".//field[@name='nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA']" \
            ".//field[@name='nr-rrc.frequencyDensity_item']"

    attributes = XML().get_elements(source=pdml_file, xpath=xpath)
    asserts.assert_equal(attributes[0].get("showname"), "frequencyDensity item: {}"
                         .format(density_value1), values=False)
    asserts.assert_equal(attributes[1].get("showname"), "frequencyDensity item: {}"
                         .format(density_value2), values=False)


def verify_that_downlink_ptrs_config_is_not_present_in_rrc(pdml_file):
    xpath = ".//field[@name='nr-rrc.rrcReconfiguration_element']" \
            ".//field[@name='nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA']" \
            ".//field[@name='nr-rrc.phaseTrackingRS']"

    XML().element_should_not_exist(source=pdml_file, xpath=xpath)


def verify_ul_ptrs_and_dl_ptrs_flag_at_l2_ps(pdml_file, value, channel, flag):
    xpath = ".//field[@name='itf_l2_ps_{0}_{1}Config.{2}']".format(channel.lower(), channel, flag)
    attributes = XML().get_elements(source=pdml_file, xpath=xpath)
    assert any([attr_element.get("show") == value for attr_element in attributes])
