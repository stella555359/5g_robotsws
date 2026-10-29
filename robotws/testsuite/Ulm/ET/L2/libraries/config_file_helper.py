import copy
import attr

from typing import List, Dict
from enum import Enum


class DcapLogOptions(Enum):
    pmc = 'pmFiles5g'
    syslog = 'condor5gSyslog'
    scf = 'SCF5g'
    tti = 'L2Ps_Component'
    l2lo = 'L2Lo_Component'
    rlc = 'L2HiRlc_Component'
    pdcp = 'L2HiPdcp_Component'
    l2ps_sherpa = 'L2Ps_Sherpa'
    l2lo_sherpa = 'L2Lo_Sherpa'
    rlc_sherpa = 'L2HiRlc_Sherpa'
    pdcp_sherpa = 'L2HiPdcp_Sherpa'
    tracer_5g = 'Tracer_5g'
    l1iq = 'l1IqTracer'
    emil = 'cp_5g'
    bip = 'bip_interface_mirroring'
    l1 = 'L1stream'


@attr.s(cmp=False)
class Scenario():
    name: str = attr.ib(default=None)
    cells_ue_mapping: Dict[str, Dict] = attr.ib(default=None)
    traffic_profiles: Dict[str, List] = attr.ib(default=None)
    special_keywords: List[str] = attr.ib(default=[])
    with_pm_counters: bool = attr.ib(default=True)

    def clone(self, new_name: str):
        clone = copy.deepcopy(self)
        clone.name = new_name
        return clone

    def get_dict(self):
        scenario_data = self.__dict__
        scenario_name = scenario_data.pop('name')
        return {scenario_name: scenario_data}


@attr.s(cmp=False)
class TestDescription():
    scenarios: List[Scenario] = attr.ib(default=None)

    def get_dict(self):
        assert self.scenarios, 'No scenarios defined'
        scenario_dict = {}
        for scenario in self.scenarios:
            scenario_dict.update(scenario.get_dict())
        return scenario_dict


@attr.s(cmp=False)
class LogsAndTraces():
    TTITrace: Dict = attr.ib(default={
        "collection": False,
        "start_point": "after_attach",
        "stop_point": "after_traffic",
        "stop_delay_sec": 0,
        "conversion": {
            "excelCsv": False,
            "filtered_json": False,
            "pickled_df": False}})
    BIPTrace: Dict = attr.ib(default={
        "L1L2BIPTrace": False,
        "AP_L1L2BIPTrace": False,
        "start_point": "before_attach",
        "stop_point": "after_detach",
        "stop_delay_sec": 0})
    DCAP: Dict = attr.ib(default={
        "collection": "False",
        "custom_profile": [],
        "start_point": "before_attach",
        "stop_point": "after_detach"})
    KPI: Dict = attr.ib(default={
        "calculation": "False",
        "runtime_options": {
            "@PmReleaseFile": "application/rel/Flexi/PM/PMPegs_SBTS25R1_5G.xml",
            "@PmKPIFile": "application/rel/Flexi/PM/PMKPI_SBTS25R1_5G.xml",
        },
        "pm_options": {
            "@UseInputDir": "False"
        }})
    extra_options: Dict[str, bool] = attr.ib(default={"restore_scf": True})
    AP_SOSLogs: bool = attr.ib(default=False)
    X2Trace: bool = attr.ib(default=False)
    BTS_Snapshot: bool = attr.ib(default=False)
    IMS_Snapshot: bool = attr.ib(default=False)
    CellSetup_Syslogs: bool = attr.ib(default=False)
    Syslog_Initial_Commissioning: bool = attr.ib(default=False)
    Syslog_Teardown: bool = attr.ib(default=False)
    Syslogs: bool = attr.ib(default=False)
    Syscom_L2_L3_Trace: bool = attr.ib(default=False)
    WtsLogs: bool = attr.ib(default=False)
    CellSetupL2_L3Trace: bool = attr.ib(default=False)

    def get_dict(self):
        return self.__dict__


@attr.s(cmp=False)
class UeGroup():
    name: str = attr.ib()
    ue_type: str = attr.ib()
    number_of_ues: int = attr.ib(default=1)
    ue_cap: str = attr.ib(default=None)
    csi_report_profile: str = attr.ib(default=None)
    pdu: int = attr.ib(default=2)
    lte_optional_args_attach: Dict = attr.ib(default={})
    bearer: int = attr.ib(default=2)

    def __attrs_post_init__(self) -> None:
        if self.ue_type == 'sa':
            self.__dict__.pop('bearer')
            self.__dict__.pop('lte_optional_args_attach')
        elif self.ue_type == 'nsa':
            self.__dict__.pop('pdu')

    def get_dict(self):
        ue_group_params = {k: v for k, v in self.__dict__.items() if v is not None}
        ue_group_name = ue_group_params.pop('name')
        ue_group_params['type'] = ue_group_params.pop('ue_type')
        return {ue_group_name: ue_group_params}

    def clone(self, new_name: str):
        clone = copy.deepcopy(self)
        clone.name = new_name
        return clone


@attr.s(cmp=False)
class UeProfiles():
    ue_groups: List[UeGroup] = attr.ib()

    def get_dict(self):
        ue_groups_dict = {}
        for ue_group in self.ue_groups:
            ue_groups_dict.update(ue_group.get_dict())
        return {'ue_groups': ue_groups_dict}


@attr.s(cmp=False)
class TrafficProfile():
    name: str = attr.ib()
    traffic_duration_sec: int = attr.ib()
    throughput_dl: int = attr.ib(default=0)
    throughput_ul: int = attr.ib(default=0)
    unit_dl: str = attr.ib(default='mbps')
    unit_ul: str = attr.ib(default='mbps')

    def get_dict(self):
        traffic_profile_data = self.__dict__
        traffic_profile_name = traffic_profile_data.pop('name')
        return {traffic_profile_name: traffic_profile_data}


@attr.s(cmp=False)
class SpecialTrafficProfile():
    name: str = attr.ib()
    rtp_codec: str = attr.ib()
    rtp_voice_silence: str = attr.ib()
    direction: str = attr.ib()
    traffic_duration_sec: int = attr.ib()
    qfi: int = attr.ib(default=3)

    def get_dict(self):
        traffic_profile_data = self.__dict__
        traffic_profile_name = traffic_profile_data.pop('name')
        return {traffic_profile_name: traffic_profile_data}


@attr.s(cmp=False)
class TrafficProfiles():
    traffic_profiles: List[TrafficProfile] = attr.ib()

    def get_dict(self):
        traffic_profile_dict = {}
        for scenario in self.traffic_profiles:
            traffic_profile_dict.update(scenario.get_dict())
        return traffic_profile_dict


@attr.s(cmp=False)
class TealConfig():
    test_description: TestDescription = attr.ib()
    ue_profiles: UeProfiles = attr.ib()
    traffic_profiles: TrafficProfiles = attr.ib()
    logs_and_traces: LogsAndTraces = attr.ib(default=LogsAndTraces())
    csi_report_profile: Dict = attr.ib(default=None)
    scenario_configuration: Dict = attr.ib(default=None)

    def get_dict(self):
        return {
            'test_description': self.test_description.get_dict(),
            'ue_profiles': self.ue_profiles.get_dict(),
            'traffic_profiles': self.traffic_profiles.get_dict(),
            'logs_and_traces': self.logs_and_traces.get_dict(),
            'csi_report_profile': self.csi_report_profile,
            'scenario_configuration': self.scenario_configuration}


# if __name__ == '__main__':
#     test = TestDescription()
#     scenario = Scenario()
#     scenario.name = 'scenario1'
#     scenario.cells_ue_mapping = {'cell1': 'ue1'}
#     scenario.traffic_profiles = {'tp1': 'tp1'}
#     scenario.special_keywords = ['special1']
#     scenario.with_pm_counters = True
#     test.scenarios = [scenario]
#     print(test.get_dict())

#     logs = LogsAndTraces()
#     print(logs.get_dict())

#     ue_group = UeGroup(name='ue1', number_of_ues=1, ue_type='sa')
#     print(ue_group.get_dict())

#     ue_group_2 = UeGroup(name='ue2', number_of_ues=3, ue_type='nsa')
#     print(ue_group_2.get_dict())

#     traffic_profile = TrafficProfile(name='tp1', throughput_ul=10,
#                                      throughput_dl=20, traffic_duration_sec=30)

#     special_traffic_profile = SpecialTrafficProfile(
#         name='stp1', rtp_codec='g711', rtp_voice_silence='no', direction='ul', traffic_duration_sec=30)
#     print(special_traffic_profile.get_dict())

#     ue_profiles = UeProfiles([ue_group_2])
#     print(ue_profiles.get_dict())

#     traffic_profiles = TrafficProfiles([traffic_profile])
#     print(traffic_profiles.get_dict())
