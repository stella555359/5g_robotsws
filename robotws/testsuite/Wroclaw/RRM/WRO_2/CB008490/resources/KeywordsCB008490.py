from robot.libraries.BuiltIn import BuiltIn
from ta5g_tshark import ta5g_tshark
from ta5g_interface_tools import ta5g_interface_tools
from ta5g_egate import ta5g_egate


class KeywordsCB008490(object):
    def __init__(self):
        self._ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')
        self.tshark_instance = ta5g_tshark()
        self.egate_configurator_instance = EgateConfigurator()

    def build_query_for_dRBIDs_for_given_number_of_DRBs(self, container, num_of_drbs=1):
        starting_dRBID = 4
        query = []
        separator = ','
        for dRBID in range(starting_dRBID, num_of_drbs + starting_dRBID):
            query.append('(dRB-ID eq {})'.format(dRBID))
        expectation = separator.join(query)
        return '{} contains ({})'.format(container, expectation)

    # container_with_query_to_check
    def message_to_check(self, container, single_expectation, number_of_occurrences):
        expectation = ', '.join([single_expectation] * int(number_of_occurrences))
        return '{} contains ({})'.format(container, expectation)

    def build_query_for_sCellToBeSetup_with_given_number_of_scells_and_pLMN_and_nRCellId(self, num_of_scells,
                                                                                         plmn,
                                                                                         nrcellidentities_list):
        num_of_scells = int(num_of_scells)
        query = ['(length(SCell-ToBeSetup-List) eq {})'.format(num_of_scells)]
        separator = ' and '
        nrcellidentities_list_integers = [eval(nrcellidentity) for nrcellidentity in nrcellidentities_list]
        for nrcellidentity in nrcellidentities_list_integers:
            query.append(
                'SCell-ToBeSetup-Item contains (sCell-ID contains ((pLMN-Identity eq {}) and '
                '(nRCellIdentity eq "0b{}")))'.format(plmn, bin(nrcellidentity).replace("0b", "").zfill(36)))
        return separator.join(query)

    def build_query_for_sCellToBeSetup_with_given_number_of_scells_and_sCellULConfigured(self, num_of_scells,
                                                                                         starting_scell_index=2):
        num_of_scells = int(num_of_scells)
        separator = ' and '
        query = ['length(SCell-ToBeSetup-List) eq 7']
        for s_cell_index in range(starting_scell_index, num_of_scells + starting_scell_index):
            query.append(
                '(SCell-ToBeSetup-Item contains ((sCellIndex eq {}) and (sCellULConfigured '
                'eq \'none\')))'.format(s_cell_index))
        return separator.join(query)

    def build_query_for_sCellToAddModList_with_given_number_of_scells(self, num_of_scells,
                                                                      starting_scell_index=2):
        num_of_scells = int(num_of_scells)
        query = ['(length(sCellToAddModList) eq {})'.format(num_of_scells)]
        separator = ' and '
        for s_cell_index in range(starting_scell_index, num_of_scells + starting_scell_index):
            query.append(
                '(sCellToAddModList contains ((sCellIndex eq {}) and (sCellConfigCommon '
                'is present)))'.format(s_cell_index))
        return separator.join(query)

    def build_query_for_sCellFailedToSetupList_with_given_number_of_scells(self, num_of_scells):
        num_of_scells = int(num_of_scells)
        query = []
        separator = ' and '
        for s_cell_index in range(num_of_scells):
            query.append('SCell-FailedtoSetup-Item contains' +
                         '(cause contains (radioNetwork eq \'no-radio-resources-available\'')
        return separator.join(query)


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
