from robot.api import SuiteVisitor

'''
Code to be used as prerunner for KPI test.
It increases the TC repetition by the given number.
Example:
--prerunmodifier kpi_prerun.py:KPI1,10
robot --prerunmodifier kpi_prerun.py:KPI1,10 test.robot
'''


class kpi_prerun(SuiteVisitor):
    def __init__(self, *args):
        self.args = args
        self.test_dict = {}
        kpi_test = {"KPI1": ["Site_reset"],
                    "KPI2_4": ["SW_download_and_activation__SBTS_to_SBTS_TARGET",
                               "SBTS_SOAM_rollback_to_SBTS_SOAM",
                               "SW_download_and_activation__SBTS_to_SBTS_INTERMEDIATE"],
                    "KPI3": ["Site_power_reset"],
                    "KPI5": ["BBMOD_Reset_From_WebEM"],
                    "KPI7": ["LTE_RAT_reset_from_ADMIN"],
                    "KPI7a": ["LTE_RAT_reset_from_ADMIN_Soft"],
                    "KPI7b": ["LTE_RAT_reset_from_ADMIN_Hard"],
                    "KPI8": ["WCDMA_RAT_reset_from_ADMIN"],
                    "KPI9": ["GSM_RAT_reset_from_ADMIN"],
                    "KPI10": ["5G_RAT_Reset_From_WebEM"],
                    "KPI10a": ["5G_RAT_Reset_From_WebEM_Soft"],
                    "KPI10b": ["5G_RAT_Reset_From_WebEM_Hard"],
                    "KPI11": ["Remote_power_reset"],
                    "KPI12": ["BTS_autonomous_reset_after_plan_activation"],
                    "KPI14": ["BBMOD_Power_Reset_From_WebEM"],
                    "KPI15": ["Configuration_plan_activation_with_cell_locking"],
                    "KPI16": ["Cell_lock_unlock_for_LTE_or_NR"],
                    "KPI17": ["Cell_block_unblock"],
                    "KPI51": ["Radio_module_reset_from_admin"],
                    "KPI54": ["RMOD_power_reset"],
                    "KPI55_57": ["SBTS_Independent_RU_SW_Upgrade",
                                 "SBTS_SOAM_rollback_to_SBTS_SOAM",
                                 "SW_download_and_activation__SBTS_to_SBTS_INTERMEDIATE"],
                    }

        for index, given_param in enumerate(args):
            given_list = given_param.split(',')
            self.test_dict[index] = {'repetitions': int(given_list[1]) - 1, 'test': kpi_test[given_list[0]]}

    def start_suite(self, suite):
        suite.doc = f'Prerun parameters used: {self.args}'
        for test in self.test_dict:
            if (("download" in self.test_dict[test]['test'][0]) or
                    ("Independent_RU_SW_Upgrade" in self.test_dict[test]['test'][0])):
                self.__add_swr_test_to_suite(suite, self.test_dict[test])
            else:
                self.__add_test_to_suite(suite, self.test_dict[test])

    @staticmethod
    def __get_test_index(suite, test):
        for index, test_name in enumerate(list(suite.tests)):
            if test in test_name.name:
                return index

    @staticmethod
    def __find_all_tests(suite, test):
        list_indexes = []
        for index, test_name in enumerate(list(suite.tests)):
            if test in test_name.name:
                list_indexes.append(index)
        return list_indexes

    def __add_test_to_suite(self, suite, test):
        index_list = self.__find_all_tests(suite, test['test'][0])
        for loop, index in enumerate(index_list):
            if loop == 0:
                index_tc = index
            else:
                index_tc = index + test['repetitions'] * loop
            copy = suite.tests[index_tc].copy(name=suite.tests[index_tc].name)
            for nr in range(test['repetitions']):
                suite.tests.insert(index_tc + nr, copy)

    def __add_swr_test_to_suite(self, suite, test):
        index_swr = self.__get_test_index(suite, test['test'][0])
        index_rollback = self.__get_test_index(suite, test['test'][1])
        index_intermediate = self.__get_test_index(suite, test['test'][2])
        copy_swr = suite.tests[index_swr].copy(name=suite.tests[index_swr].name)
        copy_rollback = suite.tests[index_rollback].copy(name=suite.tests[index_rollback].name)
        copy_intermediate = suite.tests[index_intermediate].copy(name=suite.tests[index_intermediate].name)
        for nr in range(test['repetitions']):
            if nr <= test['repetitions'] / 2:
                swr_target = self.__add_snapshot_collection_flag(copy_swr.deepcopy())
            else:
                swr_target = copy_swr.deepcopy()
            suite.tests.insert(index_swr + 3, swr_target)
            if nr == 0:
                suite.tests.insert(index_swr + 3, copy_rollback)
                continue
            suite.tests.insert(index_swr + 4, copy_rollback)
            suite.tests.insert(index_swr + 5, copy_intermediate)
            suite.tests.insert(index_swr + 3, copy_rollback)

    @staticmethod
    def __add_snapshot_collection_flag(test):
        initial = list(test.setup.args)
        add_snap = ('AND', 'Set Test Variable', '${COLLECT_SNAPSHOT_FLAG}', 'always')
        initial.extend(add_snap)
        test.setup.args = tuple(initial)
        return test
