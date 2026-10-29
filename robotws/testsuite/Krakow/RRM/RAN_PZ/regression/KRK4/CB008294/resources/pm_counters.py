"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
:team: MN_RAN_L2_SW_2_KRK_Vrf_SG
"""

import re
import copy
from abc import ABC, abstractmethod

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_console_info, logger_info
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.pm_counters import (
    wait_for_next_pm_period,
    wait_for_next_pm_period_with_advance,
    get_pm_counters_values,
    verify_any_counters_extended
)
from suite_specific_keywords import get_test_info_from_test_name, test_is_crt
from egate import get_scells_pci_per_ue_mapping, _get_cell_occurrences, _get_activated_cells_pcis
from log_collection import get_test_log_dirpath
from pm_counters_vars import *
from variables import *


class PmCounterValidationAbstract(ABC):
    """Abstract class for validating counters
    """

    only_ul_counter_regexes = [
        r"UE_SCELL_\d_CONF_SCELL_UL_SA",
        r"SAMPLES_UL_UE_AMOUNTS",
        r"UE_PSCELL_ACT_SCELL_UL",
        r"UL_RLC_PDU_VOL_RX_SEC_PATH",
        r"UL_RLC_PDU_RX_SEC_PATH",
    ]

    only_tput_counter_regexes = [
        r"UE_PSCELL_ACT_SCELL_DL",
        r"UE_PSCELL_ACT_SCELL_UL",
    ]

    def __init__(self, pcell_pci=None, ues=None, cc_dl=None, cc_ul=None, cell_subcell_map=None,
                 pm_period=None):
        logger_console_info(f"Initializing an instance of {self.__class__.__name__}")
        pcell_pci = BuiltIn().get_variable_value("${PCELL_PCI}") if pcell_pci is None else pcell_pci
        cell_subcell_map = BuiltIn().get_variable_value("${CELL_SUBCELL_MAP}") if cell_subcell_map is None else \
            cell_subcell_map
        self.pm_period = BuiltIn().get_variable_value("${PM_PERIOD}") if pm_period is None else pm_period
        self.ues = len(BuiltIn().get_variable_value("${UE_IDS}")) if ues is None else ues
        cc_dl = BuiltIn().get_variable_value("${CC_DL}") if cc_dl is None else cc_dl
        cc_ul = BuiltIn().get_variable_value("${CC_UL}") if cc_ul is None else cc_ul
        self.pcell = PCI_TO_CELL_ID_MAP[pcell_pci]
        self.init_cell_related_variables(pcell_pci, self.ues, cc_dl, cc_ul, cell_subcell_map)
        self.counters_data = None
        self._all_counter_ids_list = None

    def init_cell_related_variables(self, pcell_pci, ues, cc_dl, cc_ul, cell_subcell_map):
        self.scc_dl = cc_dl - 1
        self.scc_ul = cc_ul - 1
        activated_scells_dl_pcis_dl = _get_activated_cells_pcis(pcell_pci, cell_subcell_map, cc_dl, "dl", ues)
        activated_scells_dl_pcis_ul = _get_activated_cells_pcis(pcell_pci, cell_subcell_map, cc_ul, "ul", ues)
        activated_scells_dl_pcis_dl.remove(pcell_pci)
        activated_scells_dl_pcis_ul.remove(pcell_pci)
        activated_scells_dl = [PCI_TO_CELL_ID_MAP[cell] for cell in activated_scells_dl_pcis_dl]
        activated_scells_ul = [PCI_TO_CELL_ID_MAP[cell] for cell in activated_scells_dl_pcis_ul]
        self.activated_scells_map = dict(DL=activated_scells_dl, UL=activated_scells_ul)
        self.scells_with_traffic_expected_map = self.activated_scells_map
        scells_pcis_dl, scells_pcis_ul = get_scells_pci_per_ue_mapping(
            pcell_pci=pcell_pci,
            cc_dl=cc_dl,
            cc_ul=cc_ul,
            number_of_ues=self.ues,
            cell_subcell_map=cell_subcell_map
        )
        cell_occurrences_dl_pci = _get_cell_occurrences(scells_pcis_dl)
        cell_occurrences_ul_pci = _get_cell_occurrences(scells_pcis_ul)
        self.cell_ue_occurrences_dl = self._convert_dict_with_pci_as_keys_to_cell_ids(cell_occurrences_dl_pci)
        self.cell_ue_occurrences_ul = self._convert_dict_with_pci_as_keys_to_cell_ids(cell_occurrences_ul_pci)

    @property
    def counter_name_format_kwargs(self):
        return dict(
            scc_dl=self.scc_dl,
            scc_ul=self.scc_ul
        )

    @property
    def counter_value_format_kwargs(self):
        return dict(
            ues=self.ues,
            ues_intervals_lesser=self.pm_period * 60 - 15,
            ues_intervals_greater=self.pm_period * 60 + 15
        )

    @property
    @abstractmethod
    def all_counter_ids_list(self):
        pass

    def _format_counter_name(self, counter_name):
        return counter_name.format(**self.counter_name_format_kwargs)

    def _format_counter_value(self, value):
        return value.format(**self.counter_value_format_kwargs)

    def _format_counter_ids_and_values_in_counter_values_dict(self, counter_value_dict):
        """Format counter names from counter_value_dict into proper counter ids based on test
           variables settings. Same for counter expected value.
        """
        def _handle_format_elem_if_present_in_value_dict(elem):
            if elem in value.keys() and isinstance(value[elem], str) and \
                    self._is_formatable_string(value[elem]):
                value_in_dict = self._format_counter_value(value[elem])
                value[elem] = value_in_dict

        ready_values = {}
        for cell_type, counters_dict in counter_value_dict.items():
            ready_values.setdefault(cell_type, {})
            for counter_name, value in counters_dict.items():
                if self._is_formatable_string(counter_name):
                    counter_name = self._format_counter_name(counter_name)
                if isinstance(value, str) and self._is_formatable_string(value):
                    value = self._format_counter_value(value)
                elif isinstance(value, dict):
                    value = copy.deepcopy(value)
                    _handle_format_elem_if_present_in_value_dict("value")
                    _handle_format_elem_if_present_in_value_dict("lesser")
                    _handle_format_elem_if_present_in_value_dict("greater")
                counter_id = counters_name_to_id_map[counter_name]
                ready_values[cell_type][counter_id] = value
        return ready_values

    @staticmethod
    def _convert_dict_with_pci_as_keys_to_cell_ids(dictionary):
        return {PCI_TO_CELL_ID_MAP[pci]: value for pci, value in dictionary.items()}

    @staticmethod
    def _is_formatable_string(string):
        brackets_stack = []
        for char in string:
            if char == "{":
                brackets_stack.append(char)
            if char == "}":
                try:
                    brackets_stack.pop()
                except IndexError:
                    return False
        return (not bool(brackets_stack)) and all([char in string for char in "{}"])

    def get_pm_counters(self):
        if self.all_counter_ids_list:
            logger_info(f"Gettig counters: {self.all_counter_ids_list}")
            self.counters_data = get_pm_counters_values(
                counter_ids_list=self.all_counter_ids_list,
                json_filepath=os.path.join(get_test_log_dirpath(), "counters_data.json")
            )
        else:
            logger_console_info("Counter collection skipped: no counter conditions defined.")

    def _prepare_arguments_for_counter_validation(self, counter_nested_dict):
        """Prepares arguments used for external counter validation function.
           Handles cases for PCELL, SCELL and BTS respectively.
           If you need to override some behaviour in creation of arguments in a child class,
           override appropriate functions handle_* in the child class definition.
        """
        args_dict = {}
        for cell_type, counters_dict in counter_nested_dict.items():
            for counter_id, value in counters_dict.items():
                comparator = "=="
                period_offset = 0
                lesser = None
                greater = None
                if isinstance(value, dict):
                    comparator = value.get("comparator", comparator)
                    period_offset = value.get("period_offset", 0)
                    if comparator == "between":
                        lesser = value.get("lesser", None)
                        greater = value.get("greater", None)
                    value = value.get("value", None)

                args_for_period_list = args_dict.setdefault(period_offset, [])
                if cell_type == "PCELL":
                    self.handle_pcell_args_preparation(args_for_period_list, counter_id, comparator,
                                                       value, period_offset, lesser, greater)
                if cell_type == "SCELL":
                    self.handle_scell_args_preparation(args_for_period_list, counter_id, comparator,
                                                       value, period_offset, lesser, greater)
                if cell_type == "BTS":
                    self.handle_bts_args_preparation(args_for_period_list, counter_id, comparator,
                                                     value, period_offset, lesser, greater)
        return args_dict

    def _append_to_list_wrapper(self, args_list, element, counter_name, period_offset=0):
        logger_info(f"{counter_name:<30}  {element}\tperiod_offset: {period_offset}")
        args_list.append(element)

    def _get_argument_string_for_counter_validation(self, counter_id, comparator, value,
                                                    cell=None, lesser=None, greater=None):
        if cell:
            cell_str = f'{{"{counter_id}": "NRCELL-{cell}"}}'
        else:
            cell_str = f'{counter_id}'
        if lesser and greater and comparator == "between":
            arg = f'{lesser} < {cell_str} < {greater}'
        else:
            arg = f'{cell_str} {comparator} {value}'
        return arg

    def _get_value_if_per_ue_cell_dependant(self, value, ues):
        if value == "ues_intervals_lesser_per_cell":
            return self.counter_value_format_kwargs["ues_intervals_lesser"] * ues
        elif value == "ues_intervals_greater_per_cell":
            return self.counter_value_format_kwargs["ues_intervals_greater"] * ues
        elif value == "ues_per_cell":
            return ues
        else:
            return value

    def handle_pcell_args_preparation(self, args_list, counter_id, comparator, value, period_offset, lesser, greater):
        counter_name = counters_id_to_name_map[counter_id]

        _value = self._get_value_if_per_ue_cell_dependant(value, self.ues)
        _lesser = self._get_value_if_per_ue_cell_dependant(lesser, self.ues)
        _greater = self._get_value_if_per_ue_cell_dependant(greater, self.ues)

        arg = self._get_argument_string_for_counter_validation(
            counter_id=counter_id,
            comparator=comparator,
            value=_value,
            cell=self.pcell,
            lesser=_lesser,
            greater=_greater
        )
        self._append_to_list_wrapper(args_list, arg, counter_name, period_offset)

    def handle_scell_args_preparation(self, args_list, counter_id, comparator, value, period_offset, lesser, greater):
        counter_name = counters_id_to_name_map[counter_id]
        only_ul_counter = any(
            [re.search(counter_regex, counter_name) for counter_regex in self.only_ul_counter_regexes]
        )
        only_tput_counter = any(
            [re.search(counter_regex, counter_name) for counter_regex in self.only_tput_counter_regexes]
        )

        def _get_arg_and_append_to_list(cell, value, lesser, greater):
            arg = self._get_argument_string_for_counter_validation(
                counter_id=counter_id,
                comparator=comparator,
                value=value,
                cell=cell,
                lesser=lesser,
                greater=greater
            )
            self._append_to_list_wrapper(args_list, arg, counter_name, period_offset)

        activated_scells_dl = self.activated_scells_map["DL"]
        activated_scells_ul = self.activated_scells_map["UL"]
        for cell in activated_scells_ul:
            if only_ul_counter:
                ues = self.cell_ue_occurrences_ul[cell]
                _value = self._get_value_if_per_ue_cell_dependant(value, ues)
                _lesser = self._get_value_if_per_ue_cell_dependant(lesser, ues)
                _greater = self._get_value_if_per_ue_cell_dependant(greater, ues)
                if only_tput_counter:
                    if cell in self.scells_with_traffic_expected_map["UL"]:
                        _get_arg_and_append_to_list(cell, _value, _lesser, _greater)
                    else:
                        logger_info(f"Cell {cell} not in scells_with_traffic_expected['UL'], skipping counter "
                                    f"throughput validation")
                else:
                    _get_arg_and_append_to_list(cell, _value, _lesser, _greater)

        for cell in activated_scells_dl:
            if not only_ul_counter:
                ues = self.cell_ue_occurrences_dl[cell]
                _value = self._get_value_if_per_ue_cell_dependant(value, ues)
                _lesser = self._get_value_if_per_ue_cell_dependant(lesser, ues)
                _greater = self._get_value_if_per_ue_cell_dependant(greater, ues)
                if only_tput_counter:
                    if cell in self.scells_with_traffic_expected_map["DL"]:
                        _get_arg_and_append_to_list(cell, _value, _lesser, _greater)
                    else:
                        logger_info(f"Cell {cell} not in scells_with_traffic_expected['DL'], skipping counter "
                                    f"throughput validation")
                else:
                    _get_arg_and_append_to_list(cell, _value, _lesser, _greater)

    def handle_bts_args_preparation(self, args_list, counter_id, comparator, value, period_offset, lesser, greater):
        counter_name = counters_id_to_name_map[counter_id]
        arg = self._get_argument_string_for_counter_validation(
            counter_id=counter_id,
            comparator=comparator,
            value=value,
            lesser=lesser,
            greater=greater
        )
        self._append_to_list_wrapper(args_list, arg, counter_name, period_offset)

    @abstractmethod
    def validate(self, skip_validation=False):
        pass


class FeaturePmCounterValidationAbstract(PmCounterValidationAbstract):
    """Abstract class for validating feature counters
    """

    feature_counters_values = {
        "PCELL": {},
        "SCELL": {},
        "BTS": {}
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._feature_counters_values_ready = None

    @property
    def feature_counters_values_ready(self):
        """Property for retrieving formatted counter_ids.
        """
        if self._feature_counters_values_ready is None:
            self._feature_counters_values_ready = self._format_feature_counters()
        return self._feature_counters_values_ready

    @property
    def all_counter_ids_list(self):
        if self._all_counter_ids_list is None:
            all_counter_ids = []
            for counter_dict in self.feature_counters_values_ready.values():
                all_counter_ids.extend(counter_dict.keys())
            self._all_counter_ids_list = list(set(all_counter_ids))
        return self._all_counter_ids_list

    def _format_feature_counters(self):
        return self._format_counter_ids_and_values_in_counter_values_dict(self.feature_counters_values)

    def _validate_feature_counters(self, skip_validation=False):
        logger_info("Checked feature counter relations:")
        args_dict = self._prepare_arguments_for_counter_validation(self.feature_counters_values_ready)
        for period_offset, args_list in args_dict.items():
            if args_list and not skip_validation:
                verify_any_counters_extended(
                    *args_list,
                    counters_data=self.counters_data,
                    timestamp_offset=-period_offset
                )

    def validate(self, skip_validation=False):
        if self.all_counter_ids_list:
            self._validate_feature_counters(skip_validation=skip_validation)
        else:
            logger_console_info("Counter Validation: no counter conditions defined, skipping validation.")


class LegacyPmCounterValidationAbstract(PmCounterValidationAbstract):
    """Abstract class for validating legacy counters
    """

    legacy_counters_values = {
        "PCELL": {},
        "SCELL": {},
        "BTS": {}
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._legacy_counters_values_ready = None

    @property
    def legacy_counters_values_ready(self):
        """Property for retrieving formatted counter_ids.
        """
        if self._legacy_counters_values_ready is None:
            self._legacy_counters_values_ready = self._format_legacy_counters()
        return self._legacy_counters_values_ready

    @property
    def all_counter_ids_list(self):
        if self._all_counter_ids_list is None:
            all_counter_ids = []
            for counter_dict in self.legacy_counters_values_ready.values():
                all_counter_ids.extend(counter_dict.keys())
            self._all_counter_ids_list = list(set(all_counter_ids))
        return self._all_counter_ids_list

    def _format_legacy_counters(self):
        return self._format_counter_ids_and_values_in_counter_values_dict(self.legacy_counters_values)

    def _validate_legacy_counters(self, skip_validation=False):
        logger_info("Checked legacy counter relations:")
        args_dict = self._prepare_arguments_for_counter_validation(self.legacy_counters_values_ready)
        for period_offset, args_list in args_dict.items():
            if args_list and not skip_validation:
                verify_any_counters_extended(
                    *args_list,
                    counters_data=self.counters_data,
                    timestamp_offset=-period_offset
                )

    def validate(self, skip_validation=False):
        if self.all_counter_ids_list:
            self._validate_legacy_counters(skip_validation=skip_validation)
        else:
            logger_console_info("Counter Validation: no counter conditions defined, skipping validation.")


class RegressionFeaturePmCounterValidationAbstract(
    FeaturePmCounterValidationAbstract, LegacyPmCounterValidationAbstract
):
    """Abstract class for validating feature counters as well as legacy counters
    """

    @property
    def all_counter_ids_list(self):
        if self._all_counter_ids_list is None:
            all_counter_ids = []
            for counter_dict in self.feature_counters_values_ready.values():
                all_counter_ids.extend(counter_dict.keys())
            for counter_dict in self.legacy_counters_values_ready.values():
                all_counter_ids.extend(counter_dict.keys())
            self._all_counter_ids_list = list(set(all_counter_ids))
        return self._all_counter_ids_list

    @staticmethod
    def _merge_dicts(dict1, dict2):
        return {key: dict1.get(key, []) + dict2.get(key, []) for key in set(dict1) | set(dict2)}

    def _validate_feature_and_legacy_counters(self, skip_validation=False):
        logger_info("Checked feature counter relations:")
        args_dict_feature = self._prepare_arguments_for_counter_validation(self.feature_counters_values_ready)
        logger_info("Checked legacy counter relations:")
        args_dict_legacy = self._prepare_arguments_for_counter_validation(self.legacy_counters_values_ready)
        merged_args_dict = self._merge_dicts(args_dict_feature, args_dict_legacy)
        for period_offset, args_list in merged_args_dict.items():
            if args_list and not skip_validation:
                verify_any_counters_extended(
                    *args_list,
                    counters_data=self.counters_data,
                    timestamp_offset=-period_offset
                )

    def validate(self, skip_validation=False):
        if self.all_counter_ids_list:
            self._validate_feature_and_legacy_counters(skip_validation=skip_validation)
        else:
            logger_console_info("Counter Validation: no counter conditions defined, skipping validation.")


class A_B302_RegressionPmCounterValidation(LegacyPmCounterValidationAbstract):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": ues_intervals_302,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals_302,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals_302,
            "SAMPLES_UL_UE_AMOUNTS": ues_intervals_302,
            "SAMPLES_DL_UE_AMOUNTS": ues_intervals_302,
            "PSCELL_UE_7_ACT_SCELL_DL": ues_intervals_302,
            "PSCELL_UE_3_ACT_SCELL_UL": ues_intervals_302,
            "MAX_PSCELL_UE_7_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_3_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            "SAMPLES_UE_AMOUNTS": ues_intervals_302,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals_302,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals_302,
            "SAMPLES_UL_UE_AMOUNTS": ues_intervals_302,
            "SAMPLES_DL_UE_AMOUNTS": ues_intervals_302
        }
    }


class A_B303_RegressionPmCounterValidation(LegacyPmCounterValidationAbstract):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            "PSCELL_UE_7_ACT_SCELL_DL": ues_intervals,
            "PSCELL_UE_3_ACT_SCELL_UL": ues_intervals,
            "MAX_PSCELL_UE_7_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_3_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues
        }
    }


class A_B304_01_RegressionPmCounterValidation(RegressionFeaturePmCounterValidationAbstract):
    feature_counters_values = {
        "PCELL": {
            "SAMPLES_UL_UE_AMOUNTS": samples_ues
        },
        "SCELL": {
            "SCELL_ACTIVATIONS": {"value": "{ues}", "period_offset": -1}
        }
    }
    legacy_counters_values = {
        "PCELL": {
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
        },
        "SCELL": {}
    }


class A_B304_02_PmCounterValidation(FeaturePmCounterValidationAbstract):
    feature_counters_values = {
        "PCELL": {
            "SAMPLES_UL_UE_AMOUNTS": samples_ues
        },
        "SCELL": {}
    }


class A_B305_PmCounterValidation(FeaturePmCounterValidationAbstract):
    feature_counters_values = {
        "PCELL": {
            # "RRC_RECONF_ADD{scc_dl}DLSCELL_ATT_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_dl}DLSCELL_SUCC_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_ul}ULSCELL_ATT_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_ul}ULSCELL_SUCC_SA": "{ues}",
            # "UE_PCELL_{scc_dl}_CONF_SCELL_DL_SA": "{ues}",
            # "UE_PCELL_{scc_ul}_CONF_SCELL_UL_SA": "{ues}",
            # "GNB_DU_SCELL_{scc_dl}_ADMI_REQ_SA": "{ues}",
            # "GNB_DU_SCELL_{scc_dl}_ADMI_SUCC_SA": "{ues}",
            # "GNB_SCELL_{scc_dl}_ADMI_REQ_SA": "{ues}",
            # "GNB_SCELL_{scc_dl}_ADMI_SUCC_SA": "{ues}",
            # Following counters are not updated
            # "MAX_UE_PCELL_{scc_ul}_CONF_SCEL_UL_SA": "{ues}",
            # "MAX_UE_PCELL_{scc_dl}_CONF_SCEL_DL_SA": "{ues}",
        },
        "SCELL": {
            # "UE_SCELL_{scc_ul}_CONF_SCELL_UL_SA": {"value": "ues_per_cell"},
            # "UE_SCELL_{scc_dl}_CONF_SCELL_DL_SA": {"value": "ues_per_cell"},
        }
    }


class A_B305_RegressionPmCounterValidation(RegressionFeaturePmCounterValidationAbstract, A_B305_PmCounterValidation):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            "PSCELL_UE_{scc_dl}_ACT_SCELL_DL": ues_intervals,
            "PSCELL_UE_{scc_ul}_ACT_SCELL_UL": ues_intervals,
            "MAX_PSCELL_UE_{scc_dl}_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_{scc_ul}_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
        }
    }


class A_B307_PmCounterValidation(FeaturePmCounterValidationAbstract):
    feature_counters_values = {
        "PCELL": {
            # "RRC_RECONF_ADD{scc_dl}DLSCELL_ATT_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_dl}DLSCELL_SUCC_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_ul}ULSCELL_ATT_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_ul}ULSCELL_SUCC_SA": "{ues}",
            "SAMPLES_UE_AMOUNTS": samples_ues
        },
        "SCELL": {}
    }


class A_B307_RegressionPmCounterValidation(RegressionFeaturePmCounterValidationAbstract, A_B307_PmCounterValidation):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            "PSCELL_UE_{scc_dl}_ACT_SCELL_DL": ues_intervals,
            "PSCELL_UE_{scc_ul}_ACT_SCELL_UL": ues_intervals,
            "MAX_PSCELL_UE_{scc_dl}_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_{scc_ul}_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues
        }
    }


class A_B311_PmCounterValidation(FeaturePmCounterValidationAbstract):
    feature_counters_values = {
        "PCELL": {
            # "RRC_RECONF_ADD{scc_dl}DLSCELL_ATT_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_dl}DLSCELL_SUCC_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_ul}ULSCELL_ATT_SA": "{ues}",
            # "RRC_RECONF_ADD{scc_ul}ULSCELL_SUCC_SA": "{ues}",
        },
        "SCELL": {
            "SCELL_DEACT_BUFFER_STATUS": "{ues}",
        }
    }


class A_B311_RegressionPmCounterValidation(RegressionFeaturePmCounterValidationAbstract, A_B311_PmCounterValidation):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues_prev_pm,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals_prev_pm,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals_prev_pm,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues_prev_pm,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues_prev_pm,
            "PSCELL_UE_{scc_dl}_ACT_SCELL_DL": ues_intervals_prev_pm,
            "PSCELL_UE_{scc_ul}_ACT_SCELL_UL": ues_intervals_prev_pm,
            "MAX_PSCELL_UE_{scc_dl}_ACT_SCELL_DL": {"value": "{ues}", "period_offset": -1},
            "MAX_PSCELL_UE_{scc_ul}_ACT_SCELL_UL": {"value": "{ues}", "period_offset": -1}
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -2},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -2},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -2},
            "SAMPLES_UE_AMOUNTS": samples_ues_prev_pm,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals_prev_pm,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals_prev_pm,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues_prev_pm,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues_prev_pm
        }
    }


class A_B6_RegressionPmCounterValidation(LegacyPmCounterValidationAbstract):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            # "NR_RLC_PDU_DL_VOL_CA_PCELL": 1,
            "PSCELL_UE_{scc_dl}_ACT_SCELL_DL": ues_intervals,
            "PSCELL_UE_{scc_ul}_ACT_SCELL_UL": ues_intervals,
            "MAX_PSCELL_UE_{scc_dl}_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_{scc_ul}_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues
        }
    }


class A_B7_RegressionPmCounterValidation(LegacyPmCounterValidationAbstract):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            # "NR_RLC_PDU_DL_VOL_CA_PCELL": 1,
            "PSCELL_UE_{scc_dl}_ACT_SCELL_DL": ues_intervals,
            "PSCELL_UE_{scc_ul}_ACT_SCELL_UL": ues_intervals,
            "MAX_PSCELL_UE_{scc_dl}_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_{scc_ul}_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues
        }
    }


class B_B101_RegressionPmCounterValidation(LegacyPmCounterValidationAbstract):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            # "NR_RLC_PDU_DL_VOL_CA_PCELL": 1,
            # "UL_RLC_PDU_VOL_RX_PRI_PATH": 1,
            # "UL_RLC_PDU_RX_PRI_PATH": 1,
            "PSCELL_UE_{scc_dl}_ACT_SCELL_DL": ues_intervals,
            "PSCELL_UE_{scc_ul}_ACT_SCELL_UL": ues_intervals,
            "MAX_PSCELL_UE_{scc_dl}_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_{scc_ul}_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            # "NR_RLC_PDU_DL_VOL_CA_SCELL": 1,
            # "UL_RLC_PDU_VOL_RX_SEC_PATH": 1,
            # "UL_RLC_PDU_RX_SEC_PATH": 1,
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            # "UL_RLC_PDU_VOL_RX_PRI_PATH": 1,
            # "UL_RLC_PDU_RX_PRI_PATH": 1
        }
    }


class E_B101_PmCounterValidation(FeaturePmCounterValidationAbstract):
    feature_counters_values = {
        "PCELL": {
            "RRC_RECONF_ADD{scc_dl}DLSCELL_ATT_SA": {"value": "{ues}", "period_offset": -1},
            "RRC_RECONF_ADD{scc_dl}DLSCELL_SUCC_SA": {"value": "{ues}", "period_offset": -1},
            "RRC_RECONF_ADD{scc_ul}ULSCELL_ATT_SA": {"value": "{ues}", "period_offset": -1},
            "RRC_RECONF_ADD{scc_ul}ULSCELL_SUCC_SA": {"value": "{ues}", "period_offset": -1},
            "UE_PCELL_{scc_dl}_CONF_SCELL_DL_SA": ues_intervals,
            "UE_PCELL_{scc_ul}_CONF_SCELL_UL_SA": ues_intervals,
            "GNB_DU_SCELL_{scc_dl}_ADMI_REQ_SA": {"value": "{ues}", "period_offset": -1},
            "GNB_DU_SCELL_{scc_dl}_ADMI_SUCC_SA": {"value": "{ues}", "period_offset": -1},
            "GNB_SCELL_{scc_dl}_ADMI_REQ_SA": {"value": "{ues}", "period_offset": -1},
            "GNB_SCELL_{scc_dl}_ADMI_SUCC_SA": {"value": "{ues}", "period_offset": -1},
            "MAX_UE_PCELL_{scc_ul}_CONF_SCEL_UL_SA": "{ues}",
            "MAX_UE_PCELL_{scc_dl}_CONF_SCEL_DL_SA": "{ues}",
        },
        "SCELL": {
            "UE_SCELL_{scc_ul}_CONF_SCELL_UL_SA": ues_intervals,
            "UE_SCELL_{scc_dl}_CONF_SCELL_DL_SA": ues_intervals,
        }
    }


class E_B101_RegressionPmCounterValidation(RegressionFeaturePmCounterValidationAbstract, E_B101_PmCounterValidation):
    legacy_counters_values = {
        "PCELL": {
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues,
            "NR_RLC_PDU_DL_VOL_CA_PCELL": {"value": 0, "comparator": ">"},
            "UL_RLC_PDU_VOL_RX_PRI_PATH": {"value": 0, "comparator": ">"},
            "UL_RLC_PDU_RX_PRI_PATH": {"value": 0, "comparator": ">"},
            "PSCELL_UE_{scc_dl}_ACT_SCELL_DL": ues_intervals,
            "PSCELL_UE_{scc_ul}_ACT_SCELL_UL": ues_intervals,
            "MAX_PSCELL_UE_{scc_dl}_ACT_SCELL_DL": "{ues}",
            "MAX_PSCELL_UE_{scc_ul}_ACT_SCELL_UL": "{ues}"
        },
        "SCELL": {
            "GNB_DU_SCELL_ADMI_REQ_SA": {"value": "ues_per_cell", "period_offset": -1},
            "GNB_DU_SCELL_ADMI_SUCC_SA": {"value": "ues_per_cell", "period_offset": -1},
            "SCELL_ACTIVATIONS": {"value": "ues_per_cell", "period_offset": -1},
            "NR_RLC_PDU_DL_VOL_CA_SCELL": {"value": 0, "comparator": ">"},
            "UL_RLC_PDU_VOL_RX_SEC_PATH": {"value": 0, "comparator": ">"},
            "UL_RLC_PDU_RX_SEC_PATH": {"value": 0, "comparator": ">"},
            "SAMPLES_UE_AMOUNTS": samples_ues,
            "UE_PSCELL_ACT_SCELL_DL": ues_intervals,
            "UE_PSCELL_ACT_SCELL_UL": ues_intervals,
            "SAMPLES_UL_UE_AMOUNTS": samples_ues,
            "SAMPLES_DL_UE_AMOUNTS": samples_ues
        }
    }


def perform_pm_counter_validation(*args, **kwargs):
    """Factory method choosing appropriate validation class and running validate function
    """
    skip_validation = BuiltIn().get_variable_value("${SKIP_PM_COUNTERS_VALIDATION}", default=False)
    test_info = get_test_info_from_test_name()
    tc = test_info["tc"]
    split_subfeature = test_info["split_subfeature"]
    instance = None

    if split_subfeature == "A_B302":
        if test_is_crt():
            instance = A_B302_RegressionPmCounterValidation()
        else:
            raise ValueError("Invalid test case type")
    elif split_subfeature == "A_B303":
        if test_is_crt():
            instance = A_B303_RegressionPmCounterValidation()
        else:
            raise ValueError("Invalid test case type")
    elif split_subfeature == "A_B304":
        if test_is_crt() and tc == "01":
            instance = A_B304_01_RegressionPmCounterValidation()
        else:
            if tc == "02":
                instance = A_B304_02_PmCounterValidation()
            else:
                raise ValueError("Invalid test case type")
    elif split_subfeature == "A_B305":
        if test_is_crt():
            instance = A_B305_RegressionPmCounterValidation()
        else:
            instance = A_B305_PmCounterValidation()
    elif split_subfeature == "A_B307":
        if test_is_crt():
            instance = A_B307_RegressionPmCounterValidation()
        else:
            instance = A_B307_PmCounterValidation()
    elif split_subfeature == "A_B311":
        if test_is_crt():
            instance = A_B311_RegressionPmCounterValidation()
        else:
            instance = A_B311_PmCounterValidation()
    elif split_subfeature == "A_B6":
        if test_is_crt():
            instance = A_B6_RegressionPmCounterValidation(
                cell_subcell_map=DEFAULT_CELL_SUBCELL_MAP,
                ues=kwargs.pop("number_of_ues_fr2_sa"),
                **kwargs
            )
        else:
            raise ValueError("Test case is not CRT and pm counters should not be checked!")
    elif split_subfeature == "A_B7":
        if test_is_crt():
            instance = A_B7_RegressionPmCounterValidation(
                cell_subcell_map=DEFAULT_CELL_SUBCELL_MAP,
                ues=kwargs.pop("number_of_ues_fr2_sa"),
                **kwargs
            )
        else:
            raise ValueError("Test case is not CRT and pm counters should not be checked!")
    elif split_subfeature == "B_B101":
        if test_is_crt():
            instance = B_B101_RegressionPmCounterValidation()
    elif split_subfeature == "E_B101":
        if test_is_crt():
            instance = E_B101_RegressionPmCounterValidation()
        else:
            instance = E_B101_PmCounterValidation()
    else:
        raise ValueError("Invalid test case type")

    if instance:
        instance.get_pm_counters()
        instance.validate(skip_validation=skip_validation)


def wait_for_next_pm_period_with_advance_before_attach(advance=60):
    return wait_for_next_pm_period_with_advance(interval=5, advance=advance)


def wait_for_next_pm_period_before_detach(delay=0):
    return wait_for_next_pm_period(interval=5, delay=delay)


def perform_pm_counter_validation_for_b6_tc9():
    counters_list = [
        "M55118C01000",
        "M55316C02000",
        "M55316C02001",
        "M55316C01002",
        "M55316C01003",
        "M55316C03007",
        "M55316C04003",
        "M55316C05007",
        "M55316C06003",
        "M55139C01001",
        "M55139C01002",
        "M55316C09000"
    ]
    counters_data = get_pm_counters_values(
        counter_ids_list=counters_list,
        json_filepath=os.path.join(get_test_log_dirpath(), "counters_data.json")
    )
    verify_any_counters_extended(
        '270 < {"M55118C01000": "NRCELL-1"} < 330',
        '870 < {"M55316C02000": "NRCELL-1"} < 930',
        '870 < {"M55316C02001": "NRCELL-1"} < 930',
        '270 < {"M55316C01002": "NRCELL-1"} < 330',
        '270 < {"M55316C01003": "NRCELL-1"} < 330',
        '570 < {"M55316C03007": "NRCELL-1"} < 630',
        '870 < {"M55316C04003": "NRCELL-1"} < 930',
        '270 < {"M55118C01000": "NRCELL-2"} < 330',
        '270 < {"M55118C01000": "NRCELL-3"} < 330',
        '270 < {"M55118C01000": "NRCELL-4"} < 330',
        '270 < {"M55118C01000": "NRCELL-5"} < 330',
        '270 < {"M55118C01000": "NRCELL-6"} < 330',
        '270 < {"M55118C01000": "NRCELL-7"} < 330',
        '270 < {"M55118C01000": "NRCELL-8"} < 330',
        '870 < {"M55316C02000": "NRCELL-2"} < 930',
        '870 < {"M55316C02000": "NRCELL-3"} < 930',
        '870 < {"M55316C02000": "NRCELL-4"} < 930',
        '570 < {"M55316C02000": "NRCELL-5"} < 630',
        '570 < {"M55316C02000": "NRCELL-6"} < 630',
        '570 < {"M55316C02000": "NRCELL-7"} < 630',
        '570 < {"M55316C02000": "NRCELL-8"} < 630',
        '870 < {"M55316C02001": "NRCELL-2"} < 930',
        '870 < {"M55316C02001": "NRCELL-3"} < 930',
        '870 < {"M55316C02001": "NRCELL-4"} < 930',
        '270 < {"M55316C01002": "NRCELL-2"} < 330',
        '270 < {"M55316C01002": "NRCELL-3"} < 330',
        '270 < {"M55316C01002": "NRCELL-4"} < 330',
        '270 < {"M55316C01003": "NRCELL-2"} < 330',
        '270 < {"M55316C01003": "NRCELL-3"} < 330',
        '270 < {"M55316C01003": "NRCELL-4"} < 330',
        '270 < {"M55316C01003": "NRCELL-5"} < 330',
        '270 < {"M55316C01003": "NRCELL-6"} < 330',
        '270 < {"M55316C01003": "NRCELL-7"} < 330',
        '270 < {"M55316C01003": "NRCELL-8"} < 330',
        '{"M55316C05007": "NRCELL-1"} == 2',
        '{"M55316C06003": "NRCELL-1"} == 3',
        counters_data=counters_data, timestamp_offset=0
    )
    verify_any_counters_extended(
        '{"M55139C01001": "NRCELL-2"} == 3',
        '{"M55139C01001": "NRCELL-3"} == 3',
        '{"M55139C01001": "NRCELL-4"} == 3',
        '{"M55139C01001": "NRCELL-5"} == 2',
        '{"M55139C01001": "NRCELL-6"} == 2',
        '{"M55139C01001": "NRCELL-7"} == 2',
        '{"M55139C01001": "NRCELL-8"} == 2',
        '{"M55139C01002": "NRCELL-2"} == 3',
        '{"M55139C01002": "NRCELL-3"} == 3',
        '{"M55139C01002": "NRCELL-4"} == 3',
        '{"M55139C01002": "NRCELL-5"} == 2',
        '{"M55139C01002": "NRCELL-6"} == 2',
        '{"M55139C01002": "NRCELL-7"} == 2',
        '{"M55139C01002": "NRCELL-8"} == 2',
        '{"M55316C09000": "NRCELL-2"} == 3',
        '{"M55316C09000": "NRCELL-3"} == 3',
        '{"M55316C09000": "NRCELL-4"} == 3',
        '{"M55316C09000": "NRCELL-5"} == 2',
        '{"M55316C09000": "NRCELL-6"} == 2',
        '{"M55316C09000": "NRCELL-7"} == 2',
        '{"M55316C09000": "NRCELL-8"} == 2',
        counters_data=counters_data, timestamp_offset=1
    )


def perform_pm_counter_validation_for_b7_tc6():
    counters_list = [
        "M55118C01000",
        "M55316C02000",
        "M55316C02001",
        "M55316C01002",
        "M55316C01003",
        "M55316C03001",
        "M55316C04001",
        "M55316C05001",
        "M55316C06001",
        "M55139C01001",
        "M55139C01002",
        "M55316C09000"
    ]
    counters_data = get_pm_counters_values(
        counter_ids_list=counters_list,
        json_filepath=os.path.join(get_test_log_dirpath(), "counters_data.json")
    )
    verify_any_counters_extended(
        '270 < {"M55118C01000": "NRCELL-1"} < 330',
        '870 < {"M55316C02000": "NRCELL-1"} < 930',
        '870 < {"M55316C02001": "NRCELL-1"} < 930',
        '270 < {"M55316C01002": "NRCELL-1"} < 330',
        '270 < {"M55316C01003": "NRCELL-1"} < 330',
        '570 < {"M55316C03001": "NRCELL-1"} < 630',
        '570 < {"M55316C04001": "NRCELL-1"} < 630',
        '270 < {"M55118C01000": "NRCELL-2"} < 330',
        '570 < {"M55316C02000": "NRCELL-2"} < 630',
        '570 < {"M55316C02001": "NRCELL-2"} < 630',
        '270 < {"M55316C01002": "NRCELL-2"} < 330',
        '270 < {"M55316C01003": "NRCELL-2"} < 330',
        '{"M55316C05001": "NRCELL-1"} == 2',
        '{"M55316C06001": "NRCELL-1"} == 2',
        counters_data=counters_data, timestamp_offset=0
    )
    verify_any_counters_extended(
        '{"M55139C01001": "NRCELL-2"} == 2',
        '{"M55139C01002": "NRCELL-2"} == 2',
        '{"M55316C09000": "NRCELL-2"} == 2',
        counters_data=counters_data, timestamp_offset=1
    )


def perform_pm_counter_validation_for_b_b101_tc2():
    counters_list = [
        'M55118C01000',
        'M55139C01001',
        'M55139C01002',
        'M55316C01002',
        'M55316C01003',
        'M55316C02000',
        'M55316C02001',
        'M55316C03003',
        'M55316C04001',
        'M55316C05003',
        'M55316C06001',
        'M55316C09000'
    ]
    counters_data = get_pm_counters_values(
        counter_ids_list=counters_list,
        json_filepath=os.path.join(get_test_log_dirpath(), "counters_data.json")
    )
    verify_any_counters_extended(
        '270 < {"M55118C01000": "NRCELL-1"} < 330',
        '285 < {"M55316C02000": "NRCELL-1"} < 315',
        '285 < {"M55316C02001": "NRCELL-1"} < 315',
        '270 < {"M55316C01002": "NRCELL-1"} < 330',
        '270 < {"M55316C01003": "NRCELL-1"} < 330',
        '180 < {"M55316C03003": "NRCELL-1"} < 250',
        '285 < {"M55316C04001": "NRCELL-1"} < 315',
        '270 < {"M55118C01000": "NRCELL-2"} < 330',
        '270 < {"M55118C01000": "NRCELL-3"} < 330',
        '270 < {"M55118C01000": "NRCELL-4"} < 330',
        '285 < {"M55316C02000": "NRCELL-2"} < 315',
        '200 < {"M55316C02000": "NRCELL-3"} < 315',
        '150 < {"M55316C02000": "NRCELL-4"} < 250',
        '285 < {"M55316C02001": "NRCELL-2"} < 315',
        '270 < {"M55316C01002": "NRCELL-2"} < 330',
        '270 < {"M55316C01003": "NRCELL-2"} < 330',
        '270 < {"M55316C01003": "NRCELL-3"} < 330',
        '270 < {"M55316C01003": "NRCELL-4"} < 330',
        '{"M55316C05003": "NRCELL-1"} == 1',
        '{"M55316C06001": "NRCELL-1"} == 1',
        '{"M55316C09000": "NRCELL-4"} == 1',
        counters_data=counters_data, timestamp_offset=0
    )
    verify_any_counters_extended(
        '{"M55139C01001": "NRCELL-2"} == 1',
        '{"M55139C01001": "NRCELL-3"} == 1',
        '{"M55139C01001": "NRCELL-4"} == 1',
        '{"M55139C01002": "NRCELL-2"} == 1',
        '{"M55139C01002": "NRCELL-3"} == 1',
        '{"M55139C01002": "NRCELL-4"} == 1',
        '{"M55316C09000": "NRCELL-2"} == 1',
        '{"M55316C09000": "NRCELL-3"} == 1',
        counters_data=counters_data, timestamp_offset=1
    )


def perform_pm_counter_validation_for_robustness(deact_scell_prints):
    counters_list = ['M55316C09001', 'M55316C09002']
    counters_data = get_pm_counters_values(
        counter_ids_list=counters_list,
        json_filepath=os.path.join(get_test_log_dirpath(), "counters_data.json")
    )
    scell_print_counts = deact_scell_prints[0]
    pm_counters_validation_args = []
    for scell, count in scell_print_counts.items():
        nrcell = PCI_TO_CELL_ID_MAP[scell]
        pm_counters_validation_args.append(f'{{"M55316C09001": "NRCELL-{nrcell}"}} == {count}')
    verify_any_counters_extended(
        *pm_counters_validation_args,
        counters_data=counters_data, timestamp_offset=1
    )
    verify_any_counters_extended(
        '{"M55316C09002": "NRCELL-4"} > 0',
        counters_data=counters_data, timestamp_offset=0
    )
