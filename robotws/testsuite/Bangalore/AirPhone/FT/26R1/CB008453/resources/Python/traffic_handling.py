"""
:copyright: Nokia Networks
"""

import logging
import re
import ute_wtssim
import utils
from time import sleep
from ta_egate_cmd_parser import ta_egate_cmd_parser


class traffic_handling:
    @utils.skip_if_dryrun
    def __init__(self):
        self.ta_egate = ta_egate_cmd_parser()
        self.wtssim_instance = ute_wtssim.ute_wtssim()
        self.wtssim_instance.setup_egate(egate_port=20000)

    def parse_ue_range(self, ue_range):
        ues_regex = re.match(r"([0-9]+)\s*-\s*([0-9]+)", ue_range)
        first_ue_id = int(ues_regex.group(1))
        last_ue_id = int(ues_regex.group(2))
        return first_ue_id, last_ue_id

    def start_SA_traffic(self, ue, dir, traffic_rate, start_trf_id=1, qfi=1, pdu=None, protocol='udp', size=1350,
                         packets=None):
        """
        Verifies that EGATE and UE are active and then starts requested SA traffic in mbps/kbps/bps units
        -  :param ue: (mandatory)
        -  :param dir: dl, DL, ul, UL (mandatory)
        -  :param traffic_rate: requested traffic rate mbps/kbps/bps (mandatory)
        -  :param pdu: pdu id (optional, default equal to ue_id)
        -  :param start_trf_id: first trf id, consecutive ids will be used for each 150mbps (optional, default 1)
        -  :param protocol: (optional, default udp)
        -  :param size: packet size range (optional)
        -  :param packets: maximum packets to generate (optional)
        :return:
        """
        pdu = pdu or ue
        trf_dir = {'ul': 'Uplink', 'dl': 'Downlink'}
        pass_regexp = f"Started {trf_dir[dir.lower()]} Internal traffic over UDP on Ue:{ue}"
        value, unit, traffic_listed = self._convert_traffic_rate_to_value_unit_and_list(traffic_rate)
        for trf_id, traffic_value in enumerate(traffic_listed, start_trf_id):
            sleep(0.5)
            assert trf_id <= 20, 'MaxTrfIdReached: maximum index for trf_id is 20. Set start_trf_id to lower value.'
            command = f'trf_data_start ' \
                      f'ue={ue} ' \
                      f'pdu={pdu} ' \
                      f'qfi={qfi} ' \
                      f'dir={dir.lower()} ' \
                      f'{unit}={traffic_value} ' \
                      f'trf_id={trf_id} ' \
                      f'protocol={protocol} ' \
                      f'size={size} '
            if packets:
                command += f'packets={packets}'
            self.wtssim_instance.execute_egate_command(cmd=command, pass_regexp=pass_regexp)

    def start_SA_traffic_for_multiple_UEs(self, ues, dir, traffic_rate, start_trf_id=1, pdu=1, protocol='udp',
                                          size=1350, packets=None):
        """
        Executes start_SA_traffic for provided range of UEs e.g. 1-20
        """
        logging.info(f"Starting {traffic_rate} {dir} traffic for UEs {ues} on PDU {pdu}.")
        first_ue_id, last_ue_id = self.parse_ue_range(ues)
        for ue in range(first_ue_id, last_ue_id + 1):
            self.start_SA_traffic(ue=ue, dir=dir, traffic_rate=traffic_rate, start_trf_id=start_trf_id, pdu=pdu,
                                  protocol=protocol, size=size, packets=packets)

    def reduce_SA_traffic(self, ue, dir, traffic_rate, start_trf_id=1, qfi=1, pdu=None, protocol='udp', size=1350,
                          packets=None):
        pdu = pdu or ue

        requested_value, unit, traffic_listed = self._convert_traffic_rate_to_value_unit_and_list(traffic_rate)
        current_value = self.get_traffic_value(ue=ue, dir=dir.lower(), unit=unit, qfi=qfi, pdu=pdu)
        logging.info(f"Current traffic: {current_value} {unit}, requested traffic: {requested_value} {unit}")
        assert current_value > requested_value, f'Traffic already lower [{current_value} {unit}] than requested ' \
                                                f'[{requested_value} {unit}]'

        self.stop_traffic_on_redundant_trf_ids(ue=ue, dir=dir.lower(), pdu=pdu, qfi=qfi, traffic_rate=traffic_rate,
                                               start_trf_id=start_trf_id)
        self.start_SA_traffic(ue=ue, dir=dir.lower(), traffic_rate=traffic_rate, start_trf_id=start_trf_id, pdu=pdu,
                              protocol=protocol, qfi=qfi, size=size, packets=packets)

    def increase_SA_traffic(self, ue, dir, traffic_rate, start_trf_id=1, qfi=1, pdu=None, protocol='udp', size=1350,
                            packets=None):
        pdu = pdu or ue
        requested_value, unit, traffic_listed = self._convert_traffic_rate_to_value_unit_and_list(traffic_rate)
        current_value = self.get_traffic_value(ue=ue, dir=dir.lower(), unit=unit, qfi=qfi, pdu=pdu)
        logging.info(f"Current traffic: {current_value} {unit}, requested traffic: {requested_value} {unit}")
        assert current_value < requested_value, f'Traffic already higher [{current_value} {unit}] than requested ' \
                                                f'[{requested_value} {unit}]'

        self.stop_traffic_on_redundant_trf_ids(ue=ue, dir=dir.lower(), pdu=pdu, qfi=qfi, traffic_rate=traffic_rate,
                                               start_trf_id=start_trf_id)
        self.start_SA_traffic(ue=ue, dir=dir.lower(), traffic_rate=traffic_rate, start_trf_id=start_trf_id, pdu=pdu,
                              protocol=protocol, qfi=qfi, size=size, packets=packets)

    def reduce_NSA_traffic(self, ue, dir, traffic_rate, start_trf_id=1, id=2, protocol='udp', size=1350, packets=None):
        requested_value, unit, traffic_listed = self._convert_traffic_rate_to_value_unit_and_list(traffic_rate)
        current_value = self.get_traffic_value(ue=ue, dir=dir.lower(), unit=unit, mode='NSA')
        logging.info(f"Current traffic: {current_value} {unit}, requested traffic: {requested_value} {unit}")
        assert current_value > requested_value, f'Traffic already lower [{current_value} {unit}] than requested ' \
                                                f'[{requested_value} {unit}]'
        self.stop_traffic_on_redundant_trf_ids(ue=ue, dir=dir.lower(), id=id, traffic_rate=traffic_rate,
                                               start_trf_id=start_trf_id)
        self.start_NSA_traffic(ue=ue, dir=dir.lower(), traffic_rate=traffic_rate, start_trf_id=start_trf_id, bearer=id,
                               protocol=protocol, size=size, packets=packets)

    def increase_NSA_traffic(self, ue, dir, traffic_rate, start_trf_id=1, id=2, protocol='udp', size=1350,
                             packets=None):
        requested_value, unit, traffic_listed = self._convert_traffic_rate_to_value_unit_and_list(traffic_rate)
        current_value = self.get_traffic_value(ue=ue, dir=dir.lower(), unit=unit, mode='NSA')
        logging.info(f"Current traffic: {current_value} {unit}, requested traffic: {requested_value} {unit}")
        assert current_value < requested_value, f'Traffic already higher [{current_value} {unit}] than requested ' \
                                                f'[{requested_value} {unit}]'
        self.stop_traffic_on_redundant_trf_ids(ue=ue, dir=dir.lower(), id=id, traffic_rate=traffic_rate,
                                               start_trf_id=start_trf_id)
        self.start_NSA_traffic(ue=ue, dir=dir.lower(), traffic_rate=traffic_rate, start_trf_id=start_trf_id, bearer=id,
                               protocol=protocol, size=size, packets=packets)

    def start_NSA_traffic_for_multiple_UEs(self, ues, dir, traffic_rate, start_trf_id=1, bearer=2, protocol='udp',
                                           size=1350, packets=None):
        """
        Executes start_NSA_traffic for provided range of UEs e.g. 1-20
        """
        logging.info(f"Starting {traffic_rate} {dir} traffic for UEs {ues} on bearer {bearer}.")
        first_ue_id, last_ue_id = self.parse_ue_range(ues)
        for ue in range(first_ue_id, last_ue_id + 1):
            self.start_NSA_traffic(ue=ue, dir=dir, traffic_rate=traffic_rate, start_trf_id=start_trf_id, bearer=bearer,
                                   protocol=protocol, size=size, packets=packets)

    def stop_traffic_on_redundant_trf_ids(self, ue, dir, traffic_rate, start_trf_id, qfi=None, pdu=None, id=None):
        value, unit, traffic_listed = self._convert_traffic_rate_to_value_unit_and_list(traffic_rate)
        trf_ids_to_be_started = set(map(str, (range(start_trf_id, len(traffic_listed)+1))))
        if pdu:
            qfi = qfi or pdu
            current_trf_ids = set(self.get_5G_trf_ids_from_trf_internal_disp(ue=ue, trf_dir=dir.lower(), pdu=pdu,
                                                                             qfi=qfi))
            trf_ids_to_be_stopped = ','.join(sorted(current_trf_ids - trf_ids_to_be_started))
            trf_stop_cmd = f'trf_data_stop ue={ue} pdu={pdu} dir={dir.lower()} trf_id={trf_ids_to_be_stopped}'
        else:
            current_trf_ids = set(self.get_4G_trf_ids_from_trf_internal_disp(ue=ue, trf_dir=dir.lower(), id=id))
            trf_ids_to_be_stopped = ','.join(sorted(current_trf_ids - trf_ids_to_be_started))
            trf_stop_cmd = f'trf_data_stop ue={ue} id={id} dir={dir.lower()} trf_id={trf_ids_to_be_stopped}'
        self.wtssim_instance.execute_egate_command(cmd=trf_stop_cmd)
        if trf_ids_to_be_stopped:
            logging.info(f'Traffic was stopped for trf_ids: {trf_ids_to_be_stopped}')

    def get_traffic_value(self, ue, dir, unit='mbps', scell=None, type='Current', pdu=None, qfi=1, id=2,
                          bearer_type='all', mode='SA'):
        if mode == 'SA':
            if scell:
                data_rate = self.get_ue_stats_nr_data_rate(ue=ue, dir=dir.lower(), data_rate_type=type, scells=scell)
            else:
                pdu = pdu or ue
                type = 'Last' if type == 'Current' else type
                data_rate = self.get_SA_bearer_stats_data_rate(ue=ue, dir=dir.lower(), data_rate_type=type, qfi=qfi,
                                                               pdu=pdu)
        else:
            type = 'Last' if type == 'Current' else type
            data_rate = self.get_NSA_bearer_stats_data_rate(dir=dir.lower(), ue=ue, data_rate_type=type, bearer=id,
                                                            bearer_type=bearer_type)
        converted_traffic = self.convert_data_rate(data_rate, 'bps', unit)
        return converted_traffic

    @staticmethod
    def _convert_traffic_rate_to_value_unit_and_list(traffic_rate):
        value, unit = traffic_handling._split_traffic_string_to_value_and_unit(traffic_rate)
        assert value > 0, 'Requested traffic rate must be greater than 0.'
        traffic_listed = [value]
        if unit == 'mbps':
            traffic_listed = traffic_handling._split_traffic_into_list(value)
        return value, unit, traffic_listed

    def start_NSA_traffic(self, ue, dir, traffic_rate, start_trf_id=1, bearer=2, protocol='udp', size=1350,
                          packets=None):
        """
        Verifies that EGATE and UE are active and then starts requested NSA traffic in mbps/kbps/bps units
        -  :param ue: (mandatory)
        -  :param dir: dl, DL, ul, UL (mandatory)
        -  :param traffic_rate: requested traffic rate mbps/kbps/bps (mandatory)
        -  :param start_trf_id: first trf id, consecutive ids will be used for each 150mbps (optional, default 1)
        -  :param bearer: bearer id (optional, default 2)
        -  :param protocol: (optional, default udp)
        -  :param size: packet size range (optional)
        -  :param packets: maximum packets to generate (optional)
        :return:
        """
        pass_regexp = f"UE {ue}: {protocol.upper()} {dir.upper()} TRF"
        value, unit = traffic_handling._split_traffic_string_to_value_and_unit(traffic_rate)
        assert value > 0, 'Requested traffic rate must be greater than 0.'
        traffic = [traffic_rate]
        if unit == 'mbps':
            traffic = traffic_handling._split_traffic_into_list(value)
        for trf_id, traffic_value in enumerate(traffic, start_trf_id):
            command = f'trf_data_start ' \
                      f'ue={ue} ' \
                      f'id={bearer} ' \
                      f'dir={dir.lower()} ' \
                      f'{unit}={traffic_value} ' \
                      f'trf_id={trf_id} ' \
                      f'protocol={protocol} ' \
                      f'size={size} '
            if packets:
                command += f'packets={packets}'
            sleep(0.5)
            assert trf_id <= 20, 'MaxTrfIdReached: maximum index for trf_id is 20. Set start_trf_id to lower value.'
            self.wtssim_instance.execute_egate_command(cmd=command, pass_regexp=pass_regexp)

    def stop_SA_traffic(self, ue, pdu=None, dir='bi', trf_id='1-20'):
        """
        Verifies that EGATE and UE are active and then stops data traffic
        -  :param ue: (mandatory)
        -  :param pdu: (optional, default 1)
        -  :param dir: (optional, default bi)
        -  :param trf_id: (optional, default 1-20)
        :return:
        """
        sleep(1)
        pdu = pdu or ue
        pass_regexp = 'Stopping Uplink' if dir == 'ul' else 'Traffic was stopped'
        self.wtssim_instance.execute_egate_command(cmd=f'trf_data_stop ue={ue} pdu={pdu} dir={dir.lower()} '
                                                       f'trf_id={trf_id}', pass_regexp=f'{pass_regexp}')
        sleep(1)

    def stop_NSA_traffic(self, ue, bearer=2, dir='bi', trf_id='1-20'):
        """
        Verifies that EGATE and UE are active and then stops data traffic
        -  :param ue: (mandatory)
        -  :param bearer: (optional, default 2)
        -  :param dir: (optional, default bi)
        -  :param trf_id: (optional, default 1-20)
        :return:
        """
        sleep(1)
        self.wtssim_instance.execute_egate_command(cmd=f'trf_data_stop ue={ue} id={bearer} dir={dir.lower()} '
                                                       f'trf_id={trf_id}', pass_regexp='Traffic was stopped')
        sleep(1)

    def get_5G_trf_ids_from_trf_internal_disp(self, ue, trf_dir, pdu=1, qfi=1):
        cmd = self.ta_egate.get_command('trf_internal_disp')
        trf_disp = cmd(rat='5G', ue=ue, pdu=pdu, qfi=qfi).execute_and_parse()
        trf_id_list = [trf_id for trf_id in trf_disp[str(qfi)] if (trf_dir.upper() in trf_disp[str(qfi)][str(trf_id)])]
        return trf_id_list

    def get_4G_trf_ids_from_trf_internal_disp(self, ue, trf_dir, id=2):
        cmd = self.ta_egate.get_command('trf_internal_disp')
        trf_disp = cmd(ue=ue, id=id).execute_and_parse()
        trf_id_list = [trf_id for trf_id in trf_disp[str(id)] if (trf_dir.upper() in trf_disp[str(id)][str(trf_id)])]
        return trf_id_list

    @staticmethod
    def _split_traffic_string_to_value_and_unit(traffic_rate):
        """
        Parses e.g. '150 Mbps' to int traffic value and string unit
        -  :param traffic_rate: (mandatory)
        :return: value (int), unit (str)
        """
        traffic = re.match(r"([0-9]+)\s*([a-zA-Z]+)", traffic_rate)
        value = int(traffic.group(1))
        unit = traffic.group(2).lstrip().lower()
        assert unit in ['bps', 'kbps', 'mbps'], f"Incorrect unit '{unit}'. Only 'bps', 'kbps', 'mbps' are allowed."
        return value, unit

    @staticmethod
    def _get_traffic_range_and_unit(traffic_rate):
        """
        Parses e.g. '150-220Mbps' to int min and max values and string unit
        -  :param traffic_rate: (mandatory)
        :return: min_val (int), max_val (int), unit (str)
        """
        traffic = re.match(r"([0-9]+)\s*-\s*([0-9]+)\s*([a-zA-Z]+)", traffic_rate)
        min_val = int(traffic.group(1))
        max_val = int(traffic.group(2))
        unit = traffic.group(3).lstrip().lower()
        assert unit in ['bps', 'kbps', 'mbps'], f"Incorrect unit '{unit}'. Only 'bps', 'kbps', 'mbps' are allowed."
        return min_val, max_val, unit

    def check_if_egate_is_active(self):
        """
        Executes state command on egate and wait for 'The state is ACTIVE' regexp
        :return:
        """
        try:
            self.wtssim_instance.execute_egate_command(cmd='state', pass_regexp='The state is ACTIVE')
        except Exception:
            raise Exception('EgateNotActiveError: EGATE is not ACTIVE')
        logging.info('EGATE is ACTIVE')

    def check_if_ue_is_active(self, ue):
        """
        Executes ue_disp command on egate and checks UE state
        :return:
        """
        sleep(0.5)
        cmd = self.ta_egate.get_command('ue_disp')
        ue_state = cmd(id=ue).execute_and_parse()['state']['Value']
        assert ue_state == 'ACTIVE', f"UENotActiveError: UE{ue} is not ACTIVE. Current state: {ue_state}"
        logging.info(f'UE{ue} is ACTIVE')
        sleep(0.5)

    def verify_SA_traffic(self, dir, ue, expected_traffic, data_rate_type='Average', qfi=1, pdu=None, scells=None,
                          tolerance=3, num_of_tries=3):
        """
        Check that Average, Maximum, Minimum or Current traffic rate is expected range. If scells are provided method
        uses ue_stats_nr command to check requested scells, if not bearer_stats is used.
        -  :param dir: dl|ul
        -  :param ue: ue id
        -  :param expected_traffic: expected traffic rate or range e.g. 150Mbps, 120-220Mbps, 33 - 44 mbps
        -  :param qfi: qfi id
        -  :param pdu: pdu id
        -  :param tolerance: percentage tolerance for tput
        -  :param num_of_tries: number of tput check attempts
        -  :param data_rate_type: Average|Maximum|Minimum|Current
        -  :param scells: list of scells separated by comma e.g.  0,1,2,3
        :return:
        """
        assert data_rate_type.lower() in ['average', 'maximum', 'minimum', 'current'], \
            "WrongDataRateType: data_rate_type accepts only these strings: 'average', 'maximum', 'minimum', 'current'"
        sleep(5)
        pdu = pdu or ue
        if '-' in expected_traffic:
            min_val, max_val, unit = traffic_handling._get_traffic_range_and_unit(expected_traffic)
        else:
            exp_value, unit = traffic_handling._split_traffic_string_to_value_and_unit(expected_traffic)
            min_val, max_val = exp_value * (100 - int(tolerance)) / 100, exp_value * (100 + int(tolerance)) / 100
        for retry in range(1, int(num_of_tries) + 1):
            if scells:
                data_rate = self.get_ue_stats_nr_data_rate(dir.lower(), ue, data_rate_type.capitalize(),
                                                           scells)
            else:
                data_rate_type = 'Last' if data_rate_type.lower() == 'current' else data_rate_type
                data_rate = self.get_SA_bearer_stats_data_rate(dir.lower(), ue, data_rate_type.capitalize(),
                                                               qfi, pdu)
            current_value = traffic_handling.convert_data_rate(data_rate=data_rate, input_unit='bps', output_unit=unit)
            logging.info(f'Traffic check try #{retry}: {data_rate_type} data rate = {current_value} {unit}')
            if min_val <= current_value <= max_val:
                break
            sleep(5)
        else:
            raise Exception(f'TrafficValueError: {data_rate_type.capitalize()} {dir.upper()} Traffic value '
                            f'({current_value} {unit}) did not meet required range {min_val} - {max_val} {unit} '
                            f'for UE{ue}.')

    def verify_NSA_traffic(self, ue, dir, expected_traffic, bearer=2, scells=None, tolerance=3,
                           data_rate_type='Average', bearer_type="all", num_of_tries=3):
        """
        Check that Average, Maximum, Minimum or Current traffic rate is expected range within number of tries (every 5
        sec)
        -  :param dir: dl|ul
        -  :param ue: ue id
        -  :param expected_traffic: expected traffic rate or range e.g. 150Mbps, 120-220Mbps, 33 - 44 mbps
        -  :param bearer: bearer id
        -  :param tolerance: percentage tolerance for tput
        -  :param bearer_type: mcg|scg|all
        -  :param data_rate_type: average|maximum|minimum|last case insensitive
        -  :param num_of_tries: number of tput check attempts
        :return:
        """
        assert data_rate_type.lower() in ['average', 'maximum', 'minimum', 'last'], \
            "WrongDataRateType: data_rate_type accepts only these strings: 'average', 'maximum', 'minimum', 'last'"
        sleep(5)
        if '-' in expected_traffic:
            min_val, max_val, unit = traffic_handling._get_traffic_range_and_unit(expected_traffic)
        else:
            exp_value, unit = traffic_handling._split_traffic_string_to_value_and_unit(expected_traffic)
            min_val, max_val = exp_value * (100 - int(tolerance)) / 100, exp_value * (100 + int(tolerance)) / 100
        for retry in range(1, num_of_tries + 1):
            if scells:
                data_rate = self.get_ue_stats_nr_data_rate(dir.lower(), ue, data_rate_type.capitalize(),
                                                           scells)
            else:
                data_rate_type = 'Last' if data_rate_type.lower() == 'current' else data_rate_type
                data_rate = self.get_NSA_bearer_stats_data_rate(dir.lower(), ue, data_rate_type.capitalize(),
                                                                bearer_type, bearer)
            current_value = traffic_handling.convert_data_rate(data_rate=data_rate, input_unit='bps', output_unit=unit)
            logging.info(f'Traffic check try #{retry}: {data_rate_type.capitalize()} data rate = {current_value} '
                         f'{unit}')
            if min_val <= current_value <= max_val:
                break
            sleep(5)
        else:
            raise Exception(f'TrafficValueError: {data_rate_type.capitalize()} {dir.upper()} Traffic value '
                            f'({current_value} {unit}) did not meet required range {min_val} - {max_val} {unit} '
                            f'for UE{ue}.')

    def verify_that_SA_traffic_is_not_present(self, dir, ue, scells='0'):
        """
        Check if traffic is not present on selected scells
        :return:
        """
        sleep(3)
        ue_stats_nr = self.get_ue_stats_nr_output(dir.lower(), ue, scells)
        for cell in scells.split(','):
            assert (f'CellIndex-{cell}' not in ue_stats_nr) or \
                   ((f'CellIndex-{cell}' in ue_stats_nr) and float(ue_stats_nr[f'CellIndex-{cell}']['Current']['value'])
                    == 0), f'DataPresentError: There is {dir.upper()} data for UE{ue} on at least one CellIndex from ' \
                           f'list: {scells}'

    def verify_that_SA_traffic_is_present(self, dir, ue, scells='0'):
        """
        Check if traffic is present on selected scells
        :return:
        """
        sleep(3)
        ue_stats_nr = self.get_ue_stats_nr_output(dir.lower(), ue, scells)
        for cell in scells.split(','):
            assert (f'CellIndex-{cell}' in ue_stats_nr) and float(ue_stats_nr[f'CellIndex-{cell}']['Current']['value'])\
                   != 0, f'DataNotPresentError: There is no {dir.upper()} data for UE{ue} on CellIndex-{cell}'

    def verify_that_NSA_traffic_is_present(self, ue, dir, scells='8'):
        sleep(3)
        ue_stats_nr = self.get_ue_stats_nr_output(dir.lower(), ue, scells)
        for cell in scells.split(','):
            assert (f'CellIndex-{cell}' in ue_stats_nr) and float(ue_stats_nr[f'CellIndex-{cell}']['Current']['value'])\
                   != 0, f'DataNotPresentError: There is no {dir.upper()} data for UE{ue} on CellIndex-{cell}'

    def verify_that_NSA_traffic_is_not_present(self, ue, dir, scells='8'):
        sleep(3)
        ue_stats_nr = self.get_ue_stats_nr_output(dir.lower(), ue, scells)
        for cell in scells.split(','):
            assert (f'CellIndex-{cell}' not in ue_stats_nr) or \
                   ((f'CellIndex-{cell}' in ue_stats_nr) and float(ue_stats_nr[f'CellIndex-{cell}']['Current']['value'])
                    == 0), f'DataPresentError: There is {dir.upper()} data for UE{ue} on at least one CellIndex from ' \
                           f'list: {scells}'

    def get_SA_bearer_stats_data_rate(self, dir, ue, data_rate_type, qfi, pdu):
        """
        Get data rate value in bits per second using bearer_stats command
        :return: data_rate (int)
        """
        cmd = self.ta_egate.get_command('bearer_stats')
        bearer_stats = cmd(ue=ue, pdu=pdu, qfi=qfi, dir=dir.lower()).execute_and_parse()
        data_rate = int(bearer_stats[f'{data_rate_type} data rate']['Value'].split('(')[0])
        return data_rate

    def get_ue_stats_nr_data_rate(self, dir, ue, data_rate_type, scells):
        """
        Get data rate value in bits per second using ue_stats_nr command
        :return: data_rate (int)
        """
        data_rate = 0
        ue_stats_nr = self.get_ue_stats_nr_output(dir.lower(), ue, scells)

        for cell in scells.split(','):
            assert f'CellIndex-{cell}' in ue_stats_nr, f'NoDataError: There is no data in ue_stats_nr for ' \
                                                       f'CellIndex-{cell}'
            unit = ue_stats_nr[f'CellIndex-{cell}'][data_rate_type]['unit']
            value = float(ue_stats_nr[f'CellIndex-{cell}'][data_rate_type]['value'])
            logging.info(f"CellIndex-{cell} {data_rate_type} traffic value: {value} {unit}")
            data_rate += traffic_handling.convert_data_rate(value, unit, 'bps')
        return data_rate

    def get_ue_stats_nr_output(self, dir, ue, scells):
        traffic_type = {'dl': 'pdsch', 'ul': 'pusch'}
        cmd = self.ta_egate.get_command('ue_stats_nr')
        ue_stats_nr = cmd(id=ue, scell=scells, type=traffic_type[dir.lower()]).execute_and_parse()
        return ue_stats_nr

    @staticmethod
    def convert_data_rate(data_rate, input_unit, output_unit):
        input_unit = 'bps' if not input_unit else input_unit
        units = {'mbps': 1000000, 'kbps': 1000, 'bps': 1}
        multiplier = units[input_unit.lower()] / units[output_unit.lower()]
        return round(float(data_rate * multiplier), 3)

    def get_NSA_bearer_stats_data_rate(self, dir, ue, data_rate_type, bearer_type, bearer):
        """
        Get data rate value in bits per second using bearer_stats command
        :return: data_rate (int)
        """
        cmd = self.ta_egate.get_command('bearer_stats')
        bearer_stats = cmd(ue=ue, id=bearer, dir=dir.lower(), dc_cell_group=bearer_type).execute_and_parse()
        data_rate = int(bearer_stats[f'{data_rate_type} data rate']['Value'].split('(')[0])
        return data_rate

    @staticmethod
    def _split_traffic_into_list(traffic_value):
        """
        Splits traffic value into list of values that sums up to traffic value.
        e.g.
        input 550
        output [150, 150, 150, 100]

        :return: traffic_list
        """
        traffic_list = [150 for x in range(traffic_value // 150)]
        if traffic_value % 150:
            traffic_list.append(traffic_value % 150)
        assert len(traffic_list) <= 20, 'Maximum number of trf_ids is 20. Provided traffic value is too big.'
        return traffic_list

    def get_summarize_data_rate_for_multiple_NSA_UEs(self, dir, first_ue, last_ue, data_rate_type, bearer_type, bearer):
        """
        Get sum of traffic for UEs on specific bearer for all cells in configuration

        :return: sum of all NSA UES traffic on all cells
        """
        sum_of_cell_traffic = 0
        for ue in range(int(first_ue), int(last_ue) + 1):
            data_rate = self.get_NSA_bearer_stats_data_rate(dir=dir.lower(), ue=ue, data_rate_type=data_rate_type,
                                                            bearer=bearer,
                                                            bearer_type=bearer_type)
            converted_traffic = self.convert_data_rate(data_rate, 'bps', 'mbps')
            sum_of_cell_traffic += converted_traffic
            logging.info(f"UE: {ue} traffic: {converted_traffic}")
        logging.info(f"Cell traffic: {sum_of_cell_traffic}")
        return sum_of_cell_traffic

    def get_summarize_data_rate_for_multiple_SA_UEs(self, dir, first_ue, last_ue, data_rate_type, qfi, pdu):
        """
        Get sum of traffic for UEs on specific bearer for all cells in configuration

        :return: sum of all NSA UES traffic on all cells
        """
        sum_of_cell_traffic = 0
        for ue in range(int(first_ue), int(last_ue) + 1):
            data_rate = self.get_SA_bearer_stats_data_rate(dir=dir.lower(), ue=ue, data_rate_type=data_rate_type,
                                                           qfi=qfi,
                                                           pdu=pdu)
            converted_traffic = self.convert_data_rate(data_rate, 'bps', 'mbps')
            sum_of_cell_traffic += converted_traffic
            logging.info(f"UE: {ue} traffic: {converted_traffic}")
        logging.info(f"Cell traffic: {sum_of_cell_traffic}")
        return sum_of_cell_traffic
