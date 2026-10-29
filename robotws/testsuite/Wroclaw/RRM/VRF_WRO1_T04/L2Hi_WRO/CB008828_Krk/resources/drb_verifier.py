"""
:copyright: Nokia Solutions and Networks
:authors:
    Michal Gorski <michal.gorski@nokia.com>
:maintainers:
    Michal Gorski <michal.gorski@nokia.com>
"""

from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources_kr.python.csv_verifiers import csv_verifiers
import variables


VERIFIER = csv_verifiers()

NUM_OF_DRB = 3

NON_UE_RNTIS = {0, 65535}

COLUMN_NAMES = [
    "rnti",
    "physCellId",
    "dlDrbWeightData.drbNumber",
]

for possible_drb in range(NUM_OF_DRB):
    COLUMN_NAMES.extend(
        [
            f"dlDrbWeightData.dlDrbsWeightData[{possible_drb}].logicalChannelIdentity",
            f"dlDrbWeightData.dlDrbsWeightData[{possible_drb}].resourceGroupId",
        ]
    )

COLUMN_INDEX = dict((column_name, column_number) for column_number, column_name in enumerate(COLUMN_NAMES))


class Ue:
    def __init__(self, rnti):
        self._drb_mapping = {}
        self._rnti = rnti

    def __contains__(self, lc_id):
        return lc_id in self._drb_mapping

    @property
    def rnti(self):
        return self._rnti

    def add_drb_mapping_entry(self, lc_id, rg_id):
        """
        Record DRB mapping entry (logicalChannelIdentity -> resourceGroupId) if not already recorded, otherwise
        assert incoming entry is the same as already recorded entry (i.e. logicalChannelIdentity points to the same
        resourceGroupId)
        :param lc_id: (int) logicalChannelIdentity found in TtiTrace entry
        :param rg_id: (int) resourceGroupId found in TtiTrace entry for provided logicalChannelIdentity
        """
        if lc_id in self:
            self._assert_mapping_entry_is_identical_to_existing_one(lc_id, rg_id)
        else:
            self._drb_mapping[lc_id] = rg_id

    def _assert_mapping_entry_is_identical_to_existing_one(self, lc_id, rg_id):
        assert self._drb_mapping[lc_id] == rg_id, \
            f"Mapping entry mismatch for rnti={self._rnti}: " \
            f"expecting {lc_id} -> {self._drb_mapping[lc_id]}, " \
            f"found {lc_id} -> {rg_id}"

    def log_drb_mapping(self):
        """
        Log UE rnti and all recorded DRB mapping entries
        """
        logger.info(f"rnti = {self._rnti}")
        for lc_id in sorted(self._drb_mapping):
            logger.info(f"{lc_id} -> {self._drb_mapping[lc_id]}")

    def verify_drb_mapping(self, expected_mapping):
        """
        Verify that recorded DRB mapping is the same as provided in expected_mapping
        :param expected_mapping: dictionary of expected values where keys are integer logicalChannelIdentities
                                 and values are integer resourceGroupIds
        """
        assert self._drb_mapping == expected_mapping, \
            f"Actual mapping {self._drb_mapping} does not match expected {expected_mapping}"


class DrbEntry:
    def __init__(self, fields):
        self._fields = fields

    @property
    def rnti(self):
        return self._get_integer_value("rnti")

    @property
    def drb_number(self):
        number_of_drbs = self._get_integer_value("dlDrbWeightData.drbNumber")
        return number_of_drbs if number_of_drbs is not None else 0

    @property
    def drb_mapping(self):
        mapping = {}
        for drb in range(self.drb_number):
            lc_id = self._get_integer_value(f"dlDrbWeightData.dlDrbsWeightData[{drb}].logicalChannelIdentity")
            rg_id = self._get_integer_value(f"dlDrbWeightData.dlDrbsWeightData[{drb}].resourceGroupId")
            mapping[lc_id] = rg_id
        return mapping

    def _get_integer_value(self, field_name):
        field = self._fields[COLUMN_INDEX[field_name]]
        return int(float(field)) if field != "" else None


class TraceManager:
    def __init__(self, trace_file, cell_id):
        unfiltered_traces = VERIFIER.create_list_of_lists_from_csv(trace_file)
        self._traces = VERIFIER.filter_csv_by_column_value(unfiltered_traces, "physCellId", "==", cell_id)

    def _get_unique_rntis(self):
        unique_string_rntis = VERIFIER.get_column_values(self._traces, "rnti", unique_values=True)
        unique_rntis = {int(float(rnti)) for rnti in unique_string_rntis}
        return unique_rntis - NON_UE_RNTIS

    def _get_drb_traces(self):
        drb_entries = VERIFIER.get_multiple_columns_values_as_rows(
            input_list=self._traces,
            ignore_wrong_column=True,
            *COLUMN_NAMES
        )
        return list(map(DrbEntry, drb_entries))

    def get_ues_with_mapping(self):
        """
        Get from TtiTraces DRB mapping for every UE
        :return: list of Ue objects with unique rnti and DRB mapping (logicalChannelIdentity to resourceGroupId mapping)
        """
        ues = {rnti: Ue(rnti) for rnti in self._get_unique_rntis()}
        for entry in self._get_drb_traces():
            if entry.rnti not in NON_UE_RNTIS:
                for lc_id, rg_id in entry.drb_mapping.items():
                    ues[entry.rnti].add_drb_mapping_entry(lc_id, rg_id)
        return ues.values()


def verify_drb_allocation_to_rgs(trace_file, rnti_to_ue_id_mapping, test_case, cell_id):
    """
    Get DRB mappings for UEs from provided trace_file and verify they are consistent with provided expected mappings
    +------------------+-------+------------+------------+-------+-----------+
    |     Example                                                            |
    +==================+=======+============+============+==========+========+
    | Verify DRB allocation to RGs                                           |
    | ...    trace_file=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv          |
    | ...    rnti_to_ue_id_mapping=${ues_rnti}                               |
    | ...    test_case=C-a-B4                                                |
    | ...    cell_id=50                                                      |
    +------------------+-------+------------+------------+-------+-----------+
    :param trace_file:            (str) path to DL TtiTrace csv file
    :param rnti_to_ue_id_mapping: dictionary containing mapping between string UE rntis (keys) and string UE_IDs
                                  used in Robot test case (values), preferably created by "Get C-RNTI for UE" keyword
                                  from CB008828_resources.robot
    :param test_case:             (str) key for DRB_MAPPING dictionary defined in variables.py, value obtained for this
                                  key needs to be an another dictionary with keys being integer UE_IDs from Robot test
                                  case and values being yet another dictionaries with keys being integer expected values
                                  for logicalChannelIdentity and values being corresponding integer expected values for
                                  resourceGroupIds
    :param cell_id:               (str) physCellId for filtering TtiTrace file
    """
    traces = TraceManager(trace_file, cell_id)
    expected_mappings = variables.DRB_MAPPING[test_case]

    for ue in traces.get_ues_with_mapping():
        ue.log_drb_mapping()
        ue_id = int(rnti_to_ue_id_mapping[str(ue.rnti)])
        ue.verify_drb_mapping(expected_mappings[ue_id])
