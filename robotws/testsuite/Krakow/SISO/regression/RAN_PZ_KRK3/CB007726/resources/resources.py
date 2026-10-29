import logging
from taf.rfrl.bts.parsers.snapshot_analyzer import *
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations, login_logout
from taf.rfrl.bts.connections import device_aliases

rfsw_log_list = ['startup', 'runtime', 'UnitOAM_SOAP', 'bbox3', 'ant_discovery',
                 'pm_1_syslog', 'pm_2_syslog', 'pm_startup_DEFAULT', 'pm_UnitOAM_SOAP_Log',
                 'pm_ant_discovery_log', 'pm_fault_history_log', 'fault_history', 'version', 'clock_service']

rfsw_log_list_aphg = ['ptp_log_0000', 'rocal_state']

prrh_logs_gen1 = {'EID_': 1, 'RFSW_tx_gain_trace_': 6, 'Squatch_Dump_Ant_': 1, 'cal_': 1}

prrh_logs_gen2 = {'EID_': 1, 'RFSW_tx_gain_trace_': 4, 'Squatch_Dump_Ant_': 1, 'rfsw_asi5g-tx-cal-cache': 1,
                  'rfsw_asir-rx-cal-cache': 1}


class RfswLogs(GenericDuOperations):

    bts_type = 'GNB'

    def __init__(self, device="GNB0", device_state="FCT"):
        super(RfswLogs, self).__init__(bts_type=RfswLogs.bts_type)
        self.device = device
        self.device_state = device_state

    def get_shub_prrh_types(self, ip,  bts_id=0, du_id=0, ru_id=0):
        """
        Collects information about all pRRHs connected to  given shub.
        :param shub_number: shub id in moler configuration
        :type shub_number: int
        :param ip: shub ip
        :type ip: str
        :return prrh_list: list with all pRRHs connected to  given shub
        :type plan_name_dict: list
        """
        shub = DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format(RfswLogs.bts_type,
                                                                            bts_id, du_id, ru_id),
                                        establish_connection=False)
        shub.ru_ip_address = ip
        shub.goto_state(state="RU")
        cmd = "/tmp/ant_discovery_log | grep -E 'ANT status:|Vendor:|Serial Number:' | sed 's/^.*: //'"
        shubcmd = shub.get_cmd(cmd_name="cat", cmd_params={"path": "{}".format(cmd)})
        prrh_output = shubcmd()
        shub.goto_state(state="BTS")
        sn_tmp_list = prrh_output["LINES"][1::3]
        prrh_tmp_list = prrh_output["LINES"][2::3]
        ready_list = prrh_output["LINES"][0::3]
        prrh_list = []
        sn_list = []
        for index in range(0, len(prrh_tmp_list)):
            if sn_tmp_list[index] not in sn_list:
                prrh_list.append(prrh_tmp_list[index])
                sn_list.append(sn_tmp_list[index])
            if sn_tmp_list[index] in sn_list and ready_list[index] == "Not Ready":
                index_to_remove = sn_list.index(sn_tmp_list[index])
                prrh_list.pop(index_to_remove)
                sn_list.remove(sn_tmp_list[index])
        return prrh_list

    @load_moler_configuration_from_tl()
    def get_shubs_sn_type_and_prrh_types(self):
        """
        Collects information about all sHUB and their type connected to BTS.
        :return ru_dict: dictionary containing information about: shubs SN, shubs type, pRRH connected to these shubs
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        path = "/rom/config/FRIps.txt"
        catcmd = gnb.get_cmd(cmd_name="cat", cmd_params={"path": "{}".format(path)})
        ru_list = catcmd()
        ru_list = list(ru.split(';') for ru in ru_list["LINES"])
        ru_dict = {}
        for ru in ru_list:
            prrh_list = self.get_shub_prrh_types(ru[2])
            ru_dict[ru[3]] = [ru[4], prrh_list]
        return ru_dict

    def check_log_size(self, match_list, file_dict):
        """
        Checks if files in snapshot are not empty.
        :param match_list: list of strings containing rfsw logs that are present in the snapshot
        :param file_dict: dictionary of snapshot file names as keys and their size as value
        """
        for rfsw_log in match_list:
            if file_dict[rfsw_log] == 0:
                raise ValueError("Mandatory RFSW file {} "
                                 "has no data {}".format(rfsw_log, file_dict[rfsw_log]))

    def count_prrhs(self, shub_sn, prrh_types, sn_dict):
        """
        Counts prrhs of given generation.
        :param shub_sn: string serial number of shub on which logs are checked
        :param prrh_types: list of strings containing information about types of pRRH gen 1 connected to BTS
        :param sn_dict: dictionary containing information about: shubs SN, shubs type, pRRH connected to these shub
        :return prrh_count: intiger number of prrh of given generation
        """
        prrh_count = 0
        for prrh in sn_dict[shub_sn][1]:
            if prrh in prrh_types:
                prrh_count += 1
        return prrh_count

    def check_prrh_logs(self, shub_sn, prrh_types, file_dict, sn_dict, prrh_logs):
        """
        Checks if mandatory prrh logs (per shub) are in snapshot.
        :param shub_sn: string serial number of shub on which logs are checked
        :param prrh_types: list of strings containing information about types of pRRH gen 1 connected to BTS
        :param file_dict: dictionary of snapshot file names as keys and their size as value
        :param sn_dict: dictionary containing information about: shubs SN, shubs type, pRRH connected to these shub
        :param prrh_logs: list of strings or string containing information about types of pRRH connected to BTS
        :return prrh_matched_logs: dictionary containing information about prrh logs
        that are present in the snapshot
        """
        prrh_count = self.count_prrhs(shub_sn, prrh_types, sn_dict)
        prrh_matched_logs = {}
        for log in prrh_logs.keys():
            regex_file_list = re.compile(r'BTS_{}.*RMOD_.*{}'.format(shub_sn, log))
            match_list = list(filter(regex_file_list.match, file_dict.keys()))
            for prrh in prrh_types:
                if not match_list and prrh in sn_dict[shub_sn][1]:
                    raise ValueError("Mandatory RFSW file containing name {} "
                                     "not found in snapshot {}".format(log, regex_file_list))
            if match_list:
                self.check_log_size(match_list, file_dict)
                prrh_matched_logs[log] = [prrh_count, len(match_list)]
        return prrh_matched_logs

    def check_prrh_logs_quantity(self, prrh_matched_logs_gen1, prrh_matched_logs_gen2, shub_sn,
                                 mandatory_logs_gen1_prrh=prrh_logs_gen1,
                                 mandatory_logs_gen2_prrh=prrh_logs_gen2):
        """
        Checks if there is proper number of mandatory prrh logs per shub.
        :param prrh_matched_logs_gen1: dictionary containing information about gen1 prrh logs
        that are present in the snapshot
        with number of prrh per shub and number of particular prrh logs per shub
        :param prrh_matched_logs_gen2: dictionary containing information about gen2 prrh logs
        that are present in the snapshot
        with number of prrh per shub and number of particular prrh logs per shub
        :param shub_sn: string serial number of shub on which logs are checked
        :param mandatory_logs_gen1_prrh: dictionary of mandatory prrh gen1 logs (keys) with exact number of logs
         per single prrh (values)
        :param mandatory_logs_gen2_prrh: dictionary of mandatory prrh gen1 logs (keys) with exact number of logs
         per single prrh (values)
        """
        prrh_matched_logs = {**prrh_matched_logs_gen2, **prrh_matched_logs_gen1}
        for log in prrh_matched_logs.keys():
            try:
                prrh_gen1_log_count = mandatory_logs_gen1_prrh[log]
                prrh_gen1_count = prrh_matched_logs_gen1[log][0]
                prrh_gen2_log_count = mandatory_logs_gen2_prrh[log]
                prrh_gen2_count = prrh_matched_logs_gen2[log][0]
            except KeyError:
                if log not in mandatory_logs_gen1_prrh.keys():
                    prrh_gen1_log_count = 0
                    prrh_gen1_count = 0
                elif log not in mandatory_logs_gen2_prrh.keys():
                    prrh_gen2_log_count = 0
                    prrh_gen2_count = 0
            logs_number = prrh_gen1_log_count * prrh_gen1_count + prrh_gen2_log_count * prrh_gen2_count
            if prrh_matched_logs[log][1] < logs_number:
                raise ValueError("Too few mandatory RFSW files containing name {} "
                                 "for shub with SN {}, should be {}, but there is {}".format(log, shub_sn,
                                                                                             logs_number,
                                                                                             prrh_matched_logs[log][1]))

    def find_mandatory_rfsw_logs_in_snapshot_asir(self, directory, prrh_gen1, prrh_gen2,
                                                  mandatory_logs_shub=rfsw_log_list,
                                                  mandatory_logs_aphg=rfsw_log_list_aphg,
                                                  mandatory_logs_gen1_prrh=prrh_logs_gen1,
                                                  mandatory_logs_gen2_prrh=prrh_logs_gen2):
        """
        Searches for RFSW files in snapshot and checks if all necessary are available.
        :param directory: string path to directory with snapshot
        :param prrh_gen1: list of strings or string containing information about types of pRRH gen 1 connected to BTS
        :param prrh_gen2: list of strings or string containing information about types of pRRH gen 2 connected to BTS
        :param mandatory_logs_shub: list of mandatory shub logs to be checked
        :param mandatory_logs_aphg: list of mandatory aphg logs to be checked
        :param mandatory_logs_gen1_prrh: dictionary of mandatory prrh gen1 logs (keys) with exact number of logs
         per single prrh (values)
        :param mandatory_logs_gen2_prrh: dictionary of mandatory prrh gen2 logs with exact number of logs
         per single prrh (values)
        :return: None
        """
        if type(prrh_gen1) is not list:
            prrh_gen1 = [prrh_gen1]
        if type(prrh_gen2) is not list:
            prrh_gen2 = [prrh_gen2]
        sn_dict = self.get_shubs_sn_type_and_prrh_types()
        file_list, file_dict = find_mandatory_files_in_snapshot(directory, True)
        mandatory_logs = mandatory_logs_shub
        mandatory_logs_apha = mandatory_logs
        for sn in sn_dict.keys():
            prrh_matched_logs_gen1 = self.check_prrh_logs(sn, prrh_gen1, file_dict, sn_dict, mandatory_logs_gen1_prrh)
            prrh_matched_logs_gen2 = self.check_prrh_logs(sn, prrh_gen2, file_dict, sn_dict, mandatory_logs_gen2_prrh)
            self.check_prrh_logs_quantity(prrh_matched_logs_gen1, prrh_matched_logs_gen2, sn, mandatory_logs_gen1_prrh,
                                          mandatory_logs_gen2_prrh)
            if sn_dict[sn][0] == 'APHG':
                mandatory_logs = mandatory_logs + mandatory_logs_aphg
            else:
                mandatory_logs = mandatory_logs_apha
            for mandatory_log in mandatory_logs:
                regex_file_list = re.compile(r'BTS_{}.*RMOD_.*{}'.format(sn, mandatory_log))
                match_list = list(filter(regex_file_list.match, file_dict.keys()))
                if not match_list and "ptp_log_" in mandatory_log:
                    logging.warn("Mandatory RFSW file containing name {} "
                                 "not found in snapshot{} if this chained APHG that is ok".format
                                 (mandatory_log, regex_file_list))
                elif not match_list:
                    raise ValueError("Mandatory RFSW file containing name {} "
                                     "not found in snapshot{}".format(mandatory_log, regex_file_list))
                else:
                    self.check_log_size(match_list, file_dict)
            mandatory_logs = mandatory_logs_shub
