from robot.libraries.BuiltIn import BuiltIn
from ta5g_tshark import ta5g_tshark
from ta5g_interface_tools import ta5g_interface_tools
from ta5g_egate import ta5g_egate
from contextlib import contextmanager
from ta_messaging.message_flows import get_flow
from ta_pdml_parser.interface import parse_rrc5g_container


class KeywordsCB008717(object):
    def __init__(self):
        self._ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')
        self.tshark_instance = ta5g_tshark()
        self.egate_configurator_instance = EgateConfigurator()

    @contextmanager
    def configure_wts_without_onair_check(self, lua_cfg, logs_dirpath=None, timeout=1200):
        self.egate_configurator_instance.reach_onair_without_sib_check(lua_cfg, logs_dirpath)

    def verify_if_UERadioCapability_from_two_messages_is_the_same(self, message_source, flow_source,
                                                                  message_to_verify, flow_to_verify):
        msg_content_nr_rrc = get_flow(flow_source).get_message(message_source)
        msg_content_ngap = get_flow(flow_to_verify).get_message(message_to_verify)
        ue_cap_nr_rrc = msg_content_nr_rrc.get_value_by_unique_key('ue-CapabilityRAT-Container')
        ue_cap_ngap = msg_content_ngap.get_value_by_unique_key('ue-CapabilityRAT-Container')
        assert ue_cap_nr_rrc == ue_cap_ngap, \
            'UECap from NR_RRC: {} does not match with UECap forwarded to AMF: {}'.format(ue_cap_nr_rrc, ue_cap_ngap)

    def generate_ASN1_octetsting(self, number, padding):
        value = int(number) - 1
        hex_pattern = "\"0x%0" + padding + "X\""
        return hex_pattern % value

    # container_with_query_to_check
    def message_to_check(self, container, single_expectation, number_of_occurrences):
        expectation = ', '.join([single_expectation] * int(number_of_occurrences))
        return '{} contains ({})'.format(container, expectation)

    def build_query_for_sCellToAddModList_with_given_number_of_scells_and_Mimo(self, num_of_scells,
                                                                               mimo, starting_scell_index=2):
        num_of_scells = int(num_of_scells)
        query = ['(length(sCellToAddModList) eq {})'.format(num_of_scells)]
        separator = ' and '
        for s_cell_index in range(starting_scell_index, num_of_scells + starting_scell_index):
            query.append('(sCellToAddModList contains ((sCellIndex eq {}) and (sCellConfigDedicated '
                         'contains (pdsch-ServingCellConfig contains (maxMIMO-Layers eq {})) '
                         'and (uplinkConfig is not present))))'.format(s_cell_index, mimo))
        # logger.info(query, also_console=True)
        return separator.join(query)

    def build_query_for_sCellToBeSetup_with_given_number_of_scells_and_sCellULConfigured(self, num_of_scells,
                                                                                         starting_scell_index=2):
        num_of_scells = int(num_of_scells)
        query = ['(length(SCell-ToBeSetup-List) eq {})'.format(num_of_scells)]
        separator = ' and '
        for s_cell_index in range(starting_scell_index, num_of_scells + starting_scell_index):
            query.append(
                '(SCell-ToBeSetup-Item contains ((sCellIndex eq {}) and (sCellULConfigured '
                'eq \'none\')))'.format(s_cell_index))
        return separator.join(query)

    def build_query_for_sCellToBeSetup_with_given_number_of_scells_and_pLMN_and_nRCellId(self, num_of_scells,
                                                                                         plmn,
                                                                                         starting_nrcellidentity):
        num_of_scells = int(num_of_scells)
        starting_nrcellidentity = int(starting_nrcellidentity)
        query = []
        separator = ' and '
        for nrcellidentity in range(starting_nrcellidentity, starting_nrcellidentity + num_of_scells):
            query.append(
                'SCell-ToBeSetup-Item contains (sCell-ID contains ((pLMN-Identity eq {}) and '
                '(nRCellIdentity eq "0b{}")))'.format(plmn, bin(nrcellidentity).replace("0b", "").zfill(36)))
        return separator.join(query)

    def build_query_for_sCellFailed_with_given_number_of_scells_and_pLMN_and_nRCellId_and_cause(self,
                                                                                                num_of_scells,
                                                                                                plmn,
                                                                                                starting_nrcellid):
        num_of_scells = int(num_of_scells)
        starting_nrcellid = int(starting_nrcellid)
        query = []
        separator = ' and '
        for nrcellidentity in range(starting_nrcellid, starting_nrcellid + num_of_scells):
            query.append(
                'SCell-FailedtoSetup-Item contains (sCell-ID contains ((pLMN-Identity eq {}) and '
                '(nRCellIdentity eq "0b{}")) and (cause contains (radioNetwork eq '
                '"no-radio-resources-available")))'.format(plmn, bin(nrcellidentity).replace("0b", "").zfill(36)))
        return separator.join(query)

    def build_query_for_dRBIDs_for_given_number_of_DRBs(self, container, num_of_drbs=1):
        starting_dRBID = 4
        query = []
        separator = ','
        for dRBID in range(starting_dRBID, num_of_drbs + starting_dRBID):
            query.append('(dRB-ID eq {})'.format(dRBID))
        expectation = separator.join(query)
        return '{} contains ({})'.format(container, expectation)

    def build_query_for_measObjectToAddModList_with_given_number_of_measObjects_freq_and_startID(self,
                                                                                                 startID,
                                                                                                 num_of_measObjects,
                                                                                                 freq):
        num_of_measObjects = int(num_of_measObjects)
        startID = int(startID)
        freq = int(freq)
        separator = ' and '
        query = []
        for measObject in range(startID, (startID + num_of_measObjects)):
            query.append('measObjectToAddModList contains ((measObjectId eq {}) and '
                         '(freqBandIndicatorNR eq {}))'.format(measObject, freq))
        return separator.join(query)

    def build_query_for_measIds_with_given_number_of_measObjects_startID_and_reportID(self, startID,
                                                                                      num_of_measObjects,
                                                                                      reportID):
        num_of_measObjects = int(num_of_measObjects)
        startID = int(startID)
        reportID = int(reportID)
        query = []
        separator = ' and '
        for measObject in range(startID, (startID + num_of_measObjects)):
            query.append('measIdToAddModList contains ((measId eq {}) and (measObjectId eq {}) and '
                         '(reportConfigId eq {}))'.format(measObject, measObject, reportID))
        return separator.join(query)

    def verify_if_measConfig_contains(self, flow_alias, message_alias, field, value):
        msg_f1ap = get_flow(flow_alias).get_message(message_alias)
        measConfig_hex = msg_f1ap.get_value_by_unique_key('measConfig')
        BuiltIn().log('{}- equals to {} '.format('measConfig HEX IE', str(measConfig_hex)))
        measConfig_IE = parse_rrc5g_container('MeasConfig', measConfig_hex)
        BuiltIn().log('{}- equals to {} '.format('MeasConfig', measConfig_IE))

        if value == 'is present':
            measConfig_IE.get_value_by_unique_key(field)
        else:
            msg_content = str(measConfig_IE.get_value_by_unique_key(field))
            BuiltIn().log('{}- equals to {} '.format(field, msg_content))
            assert msg_content == str(value)

    def build_query_for_sCellToBeSetupMod_with_given_number_of_scells_and_pLMN_and_nRCellId(self, num_of_scells,
                                                                                            plmn,
                                                                                            starting_nrcellidentity):
        num_of_scells = int(num_of_scells)
        starting_nrcellidentity = int(starting_nrcellidentity)
        query = []
        separator = ' and '
        for nrcellidentity in range(starting_nrcellidentity, starting_nrcellidentity + num_of_scells):
            query.append(
                'SCell-ToBeSetupMod-Item contains (sCell-ID contains ((pLMN-Identity eq {}) and '
                '(nRCellIdentity eq "0b{}")))'.format(plmn, bin(nrcellidentity).replace("0b", "").zfill(36)))
        return separator.join(query)

    def build_query_for_sCellToAddModList_with_given_number_of_scells(self, num_of_scells,
                                                                      starting_scell_index):
        starting_scell_index = int(starting_scell_index)
        num_of_scells = int(num_of_scells)
        query = ['(length(sCellToAddModList) eq {})'.format(num_of_scells)]
        separator = ' and '
        for s_cell_index in range(starting_scell_index, num_of_scells + starting_scell_index):
            query.append('(sCellToAddModList contains (physCellId eq {}))'.format(s_cell_index))
        return separator.join(query)

    def verify_if_measConfig_contains_non_unique_value(self, flow_alias, message_alias, field, value):
        value = int(value)
        msg_f1ap = get_flow(flow_alias).get_message(message_alias)
        measConfig_hex = msg_f1ap.get_value_by_unique_key('measConfig')
        BuiltIn().log('{}- equals to {} '.format('measConfig HEX IE', str(measConfig_hex)))
        measConfig_IE = parse_rrc5g_container('MeasConfig', measConfig_hex)
        BuiltIn().log('{}- equals to {} '.format('MeasConfig', measConfig_IE))
        list_of_values = measConfig_IE.get_all_values_by_key(field)
        BuiltIn().log('List of values- {} '.format(list_of_values))
        assert value in list_of_values

    def build_query_for_SCellToBeRemovedList_with_given_number_of_scells_and_pLMN_and_nRCellId(self, num_of_scells,
                                                                                               plmn,
                                                                                               starting_nrcellidentity):
        num_of_scells = int(num_of_scells)
        starting_nrcellidentity = int(starting_nrcellidentity)
        query = []
        separator = ' and '
        for nrcellidentity in range(starting_nrcellidentity, starting_nrcellidentity + num_of_scells):
            query.append(
                'SCell-ToBeRemoved-Item contains (sCell-ID contains ((pLMN-Identity eq {}) and '
                '(nRCellIdentity eq "0b{}")))'.format(plmn, bin(nrcellidentity).replace("0b", "").zfill(36)))
        return separator.join(query)

    def build_query_for_sCellToReleaseList_with_given_scell_index_list(self, scell_index_list):
        query = []
        for index in scell_index_list:
            query.append('(sCellToReleaseList contains ({}))'.format(index))
        return ' and '.join(query)

    def build_query_for_measObjectsToRemoveList_with_given_meas_objects_list(self, meas_obj_list):
        query = []
        for meas_obj in meas_obj_list:
            query.append('(measObjectToRemoveList contains ({}))'.format(meas_obj))
        return ' and '.join(query)

    def build_query_for_csi_ReportConfigToAddModList_with_given_reportConfigIds(self, report_list):
        query = []
        BuiltIn().log('report_list_type- {}, report_list- {}'.format(type(report_list), report_list))
        for id in report_list:
            query.append(
                'csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq {}))'.format(id))
        return " and ".join(query)


class EgateConfigurator(ta5g_egate):

    def reach_onair_without_sib_check(self, lua_cfg, logs_dirpath=None):
        """
        Start egate service using .lua config file
        :param lua_cfg: File path of .lua config file
        :return:
        """
        if not logs_dirpath:
            logs_dirpath = ta5g_interface_tools().get_robot_output_dir()
        self.start_wts_and_store_config_file_in_logs_dir(lua_cfg=lua_cfg, logs_dirpath=logs_dirpath)
        self._ute_wtssim_instance.execute_egate_command(cmd='start version_check=off', timeout=10)
