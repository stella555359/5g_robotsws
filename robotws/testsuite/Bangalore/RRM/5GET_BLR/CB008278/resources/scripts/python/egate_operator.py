from ute_wtssim import ute_wtssim
from ta5g_cp.utils.utils import CommonItem
import time
import os
import commands
import re


class EgateOpe():
    pdu_info = {}

    def __init__(self):
        self.egate_inst = ute_wtssim()
        self.setup_egate_flag = False

    def execute_egate_command_without_kargs(self,
                                            cmd,
                                            pass_regexp=None,
                                            fail_regexp=None,
                                            timeout=None,
                                            egate_port='20000'):
        if not self.setup_egate_flag:
            self.egate_inst.setup_egate(egate_port)
            self.setup_egate_flag = True
        return self.egate_inst.execute_egate_command(
            cmd, pass_regexp, fail_regexp, timeout)

    def _nsa_attach_ue(
            self,
            ue='1',
            target_gnb='2',
            target_cells='1',
            bearer='2',
            plmn=''):
        cmd = 'ue_attach id={}'.format(ue)
        endc_cmd = 'ue_dc_enb_start ue={} target_gnb={} target_cells={} bearer={} type=split_scg'.format(
            ue, target_gnb, target_cells, bearer)
        self.execute_egate_command_without_kargs(
            cmd, pass_regexp='UE IS ACTIVE')
        if plmn:
            set_plmn_cmd = 'enb_endc_param selected_plmn={} id=1'.format(plmn)
            self.execute_egate_command_without_kargs(set_plmn_cmd)
        self.execute_egate_command_without_kargs(
            endc_cmd, pass_regexp='reported successful RA')

    def sa_attach_ue(
            self,
            ue='1',
            pdu='1',
            nwslice='1',
            gw='1'):
        cmd = 'ue_register id={}'.format(ue)
        endc_cmd = 'ue_pdu_session_setup pdu={} ue={} nwslice={} gw={}'.format(
            pdu, ue, nwslice, gw)
        self.execute_egate_command_without_kargs(
            cmd, pass_regexp='NG RM Registered')
        self.execute_egate_command_without_kargs(
            endc_cmd, pass_regexp='QoS Routing Table')
        self.pdu_info.setdefault(pdu, {})
        self.pdu_info[pdu]['gw'] = gw
        self.pdu_info[pdu]['ue'] = ue
        self.pdu_info[pdu]['nwslice'] = nwslice

    def pdu_setup(
            self,
            ue='1',
            pdu='1',
            nwslice='1',
            gw='1',
            request_type=''):
        if request_type:
            cmd = 'ue_pdu_session_setup pdu={} ue={} nwslice={} gw={} request_type={}'.format(
                pdu, ue, nwslice, gw, request_type)
        else:
            cmd = 'ue_pdu_session_setup pdu={} ue={} nwslice={} gw={}'.format(
                pdu, ue, nwslice, gw)
        output = self.execute_egate_command_without_kargs(
            cmd, pass_regexp='QoS Routing Table')
        self.pdu_info.setdefault(pdu, {})
        self.pdu_info[pdu]['gw'] = gw
        self.pdu_info[pdu]['ue'] = ue
        self.pdu_info[pdu]['nwslice'] = nwslice
        result = CommonItem()
        result.output = output
        ue_ip = re.findall(r'UE IP address:(.*?) ', output)
        if len(ue_ip) != 0:
            result.ue_ip = ue_ip[0]
            return result
        else:
            raise Exception("Not found UE IP address")

    def pdu_modify(self,
                   ue='1',
                   pdu='1',
                   qosflows_to_add='',
                   qosflows_to_del='',
                   by='amf'):
        if qosflows_to_add:
            cmd = 'ue_pdu_session_modify ue={} pdu={} qosflows_to_add={} by={}'.format(
                ue, pdu, qosflows_to_add, by)
            output = self.execute_egate_command_without_kargs(
                cmd, pass_regexp='QoS Routing Table')

        if qosflows_to_del:
            cmd = 'ue_pdu_session_modify ue={} pdu={} qosflows_to_del={} by={}'.format(
                ue, pdu, qosflows_to_del, by)
            output = self.execute_egate_command_without_kargs(
                cmd, pass_regexp='Pdu Session Resource Modify \
            Response Message with RAN UE NGAP ID')

    def sa_ue_register(self, ue='1'):
        cmd = 'ue_register id={}'.format(ue)
        output = self.execute_egate_command_without_kargs(
            cmd, pass_regexp='NG RM Registered')
        return output

    def sa_amf_paging(self, amf='1', ue='1'):
        cmd = 'amf_paging_start id={} ue={}'.format(amf, ue)
        self.execute_egate_command_without_kargs(
            cmd, pass_regexp='rrcSetupRequest')

    def nsa_dettach_ue(self, ue='1'):
        cmd = 'ue_detach id={}'.format(ue)
        self.execute_egate_command_without_kargs(cmd, pass_regexp='detached')

    def sa_dettach_ue(self, ue='1', pdu='1'):
        self._remove_pdu_info(ue)
        cmd = 'ue_deregister id={} ue_deregister_type=switch_off'.format(ue)
        endc_cmd = 'ue_pdu_session_release pdu={} ue={} '.format(
            pdu, ue)
        self.execute_egate_command_without_kargs(
            endc_cmd, pass_regexp='Successfully released PDU Session')
        self.execute_egate_command_without_kargs(
            cmd, pass_regexp='detached')

    def _remove_pdu_info(self, ue):
        pdu_ids = list(
            filter(
                lambda x: self.pdu_info[x]['ue'] == ue,
                self.pdu_info))
        for pdu_id in pdu_ids:
            self.pdu_info.pop(pdu_id)

    def sa_ue_deregister(self, ue='1'):
        self._remove_pdu_info(ue)
        cmd = 'ue_deregister id={} ue_deregister_type=switch_off'.format(ue)
        self.execute_egate_command_without_kargs(
            cmd, pass_regexp='detached')

    def flush_log(self):
        cmd = 'set_log flush'
        self.execute_egate_command_without_kargs(cmd)

    def send_measurement_report(
            self,
            ue='1',
            meas_id='1',
            event='A3',
            srsrp_nr='11',
            srsrq_nr='11',
            phycell_id='381',
            nrsrp_nr='30',
            nrsrq_nr='30',
            pass_regexp=None):
        if event == 'A2':
            cmd = 'ue_measurement_send_nr id={} meas_id={} event={} srsrp_nr={} srsrq_nr={}'.format(
                ue, meas_id, event, srsrp_nr, srsrq_nr)
        else:
            cmd1 = 'ue_measurement_send_nr id={} meas_id={} event={} srsrp_nr={} '.format(
                ue, meas_id, event, srsrp_nr)
            cmd2 = 'srsrq_nr={} phycell_id={} nrsrp_nr={} nrsrq_nr={}'.format(
                srsrq_nr, phycell_id, nrsrp_nr, nrsrq_nr)
            cmd = cmd1 + cmd2

        self.execute_egate_command_without_kargs(
            cmd, pass_regexp)

    def get_traffic_stats(
            self,
            dir,
            bearer_id='2',
            ue='1',
            dc_cell_group='scg'):
        cmd = 'bearer_stats id={} ue={} dir={} dc_cell_group={}'.format(
            bearer_id, ue, dir, dc_cell_group)
        output = self.execute_egate_command_without_kargs(
            cmd, pass_regexp='Average packet interval')

        attr_map = {'Maximum data rate': 'max_data_rate',
                    'Minimum data rate': 'min_data_rate',
                    'Average data rate': 'ave_data_rate',
                    'Last data rate': 'last_data_rate',
                    'Absolute max data rate': 'abs_max_data_rate',
                    'Absolute min data rate': 'abs_min_data_rate',
                    'Bytes sent': 'bytes_sent'

                    }
        result = CommonItem()
        lines = output.splitlines()
        for line in lines:
            if len(line) <= 61:
                continue
            para = line[:61].strip()
            value = line[61:].strip()
            if para in attr_map:
                if 'data rate' in para:
                    value = value.split(None, 1)[-1]
                    value = value.strip('(')
                    value = value.strip(')')
                    setattr(result, attr_map[para], value)
                else:
                    value = value.split(None, 1)[-1]
                    setattr(result, attr_map[para], value)
        return result

    def nsa_start_traffic(self, trf_id, direct, mbps, ue='1', bearer_id='2'):
        cmd = 'trf_data_start id={} ue={} dir={} mbps={} trf_id={}'.format(
            bearer_id, ue, direct, mbps, trf_id)
        self.execute_egate_command_without_kargs(
            cmd, pass_regexp='UDP {} TRF'.format(direct.upper()))

    def traffic_should_be_ok(
            self,
            bearer_id='2',
            ue='1',
            dl_mbps='5',
            ul_mbps='1', timeout=5):
        thresh = 0.9
        start_dl_cmd = 'trf_data_start id={} ue={} dir=dl mbps={} trf_id=1'.format(
            bearer_id, ue, dl_mbps)
        start_ul_cmd = 'trf_data_start id={} ue={} dir=ul mbps={} trf_id=2'.format(
            bearer_id, ue, ul_mbps)
        stop_dl_cmd = 'trf_data_stop id={} ue={} dir=dl trf_id=1'.format(
            bearer_id, ue)
        stop_ul_cmd = 'trf_data_stop id={} ue={} dir=ul trf_id=2'.format(
            bearer_id, ue)
        self.execute_egate_command_without_kargs(
            start_dl_cmd, pass_regexp='UDP DL TRF')
        self.execute_egate_command_without_kargs(
            start_ul_cmd, pass_regexp='UDP UL TRF')
        time.sleep(int(timeout))
        dl_stats = self.get_traffic_stats('dl', bearer_id, ue)
        ul_stats = self.get_traffic_stats(
            'ul', bearer_id, ue, dc_cell_group='all')
        self.execute_egate_command_without_kargs(
            stop_dl_cmd, pass_regexp='stopped')
        self.execute_egate_command_without_kargs(
            stop_ul_cmd, pass_regexp='stopped')
        if 'K' in dl_stats.max_data_rate:
            dl_max = float(dl_stats.max_data_rate.split()[0]) / 1000.0
        else:
            dl_max = float(dl_stats.max_data_rate.split()[0])
        if 'K' in ul_stats.max_data_rate:
            ul_max = float(ul_stats.max_data_rate.split()[0]) / 1000.0
        else:
            ul_max = float(ul_stats.max_data_rate.split()[0])
        if dl_max < thresh * float(dl_mbps):
            raise AssertionError(
                'dl max data rate is {} which is below {}*{}'.format(dl_max, thresh, dl_mbps))
        if ul_max < thresh * float(ul_mbps):
            raise AssertionError(
                'ul max data rate is {} which is below {}*{}'.format(ul_max, thresh, ul_mbps))

    def check_nsa_traffic(
            self,
            direct,
            expect_mbps,
            thresh=90,
            bearer_id='2',
            ue='1',
            dc_cell_group='scg'):
        """
        | Arguments | Meaning|
        | direct  |  mandatory, 'dl' or 'ul' |
        |expect_mbps | mandatory, e.g.  5 |
        |thresh | optional, default 90 means 90% |
        |bearer_id | optional, default 2 |
        | ue | optional ,default 1 |
        | dc_cell_group | optional, default scg, other values: all, mcg |
        """
        stats = self.get_traffic_stats(direct, bearer_id, ue, dc_cell_group)
        if 'K' in stats.max_data_rate:
            t_max = float(stats.max_data_rate.split()[0]) / 1000.0
        else:
            t_max = float(stats.max_data_rate.split()[0])
        thresh = int(thresh) / 100.0
        if t_max < thresh * float(expect_mbps):
            raise AssertionError(
                '{} max data rate is {} which is below {}*{}'.format(direct, t_max, thresh, expect_mbps))

    def nsa_attach_ue(
            self,
            ue='1',
            target_gnb='2',
            target_cells='1',
            bearer='2',
            scg_check=True,
            plmn=''):
        # self.tail_egate_log_out(start=True)
        self._nsa_attach_ue(
            ue,
            target_gnb,
            target_cells,
            bearer,
            plmn)
        if scg_check:
            time.sleep(5)
            # self.flush_log()
            # time.sleep(5)
            # self.tail_egate_log_out(start=False)
            # self.check_no_scg_fail()

    def get_active_ue(self, env_type="NSA"):
        active_ue = []
        start_search = False
        ue_disp_mode = ""

        output = self.execute_egate_command_without_kargs(
            'ue_disp', pass_regexp='EGATE>')
        lines = output.splitlines()

        for line in lines:
            line = line.strip('\n')
            if re.match(r'^Parameter\s+Value.*', line) is not None:
                ue_disp_mode = "seperated"
            elif re.match(r'^UE Id\s+Type\s+State.*', line) is not None:
                ue_disp_mode = "summary"
            else:
                continue

        print("------ue_disp mode-------")
        print(ue_disp_mode)
        print("-------------------------")
        if ue_disp_mode == "seperated":
            for num, line in enumerate(lines):
                matched_ue = re.findall(r'UE-\d+', line)
                if matched_ue:
                    start_search = True
                    matched_ue = re.findall(r'UE-(\d+)', line)
                    print(line)
                    ue_id = matched_ue[0]
                    print("--------")
                    print(ue_id)
                    continue
                if start_search and 'state' in line:
                    start_search = False
                    if env_type == "NSA":
                        if 'ACTIVE' in line:
                            active_ue.append(ue_id)
                    elif env_type == "SA":
                        if 'ACTIVE' in line or 'IDLE' in line:
                            active_ue.append(ue_id)
                    else:
                        raise Exception("Input Wrong env_type.")
        elif ue_disp_mode == "summary":
            for num, line in enumerate(lines):
                if "Configured UEs" in line:
                    start_search = True
                if start_search:
                    if 'ACTIVE' in line or 'IDLE' in line:
                        ue_id = line.split(' ')[0]
                        active_ue.append(ue_id)
        else:
            raise Exception("Cannot match a ue_disp mode.")

        print(active_ue)
        return active_ue

    def tail_egate_log_out(self, start, outfile="/tmp/tail_egate_out.log"):
        if start:
            os.system('rm -rf {}'.format(outfile))
            os.system(
                'nohup tail -F -n 0 /opt/iphy/latest/egate_console.log > {} &'.format(outfile))
        else:
            (status, pids) = commands.getstatusoutput('pgrep "tail"')
            pid_list = pids.split('\n')
            for pid in pid_list:
                print(pid)
                os.system(
                    'kill -9 {}'.format(pid))

    def check_no_scg_fail(self, outfile="/tmp/tail_egate_out.log"):
        (status, attach_line) = commands.getstatusoutput(
            'sed -n "/reported successful RA/=" {}'.format(outfile))
        print(attach_line)
        (status, scg_line) = commands.getstatusoutput(
            'sed -n "/Bearer-type change from SCG-split to MCG/=" {}'.format(outfile))
        print(scg_line)

        if len(scg_line) != 0:
            if int(scg_line) > int(attach_line):
                raise Exception("Fail!! PR515356")
        else:
            print("--!!! No msg: Bearer-type change from SCG-split to MCG --!!!")

    def get_ue_disp_info(self):
        result = {}

        def _handle_one_line(line):
            items = line.split('  ')
            items = list(filter(lambda x: x, items))
            items = list(map(lambda x: x.strip(), items))
            return items
        output = self.execute_egate_command_without_kargs(
            'ue_disp', pass_regexp='EGATE>')
        lines = output.splitlines()
        start = False
        ue_info = []
        for line in lines:
            if not line.strip():
                continue
            if '====' in line:
                start = False
            if start:
                ue_info.append(line)
            if 'UE Id  Type' in line:
                head = line
            if '-----' in line:
                start = True
        head_items = _handle_one_line(head)
        for line in ue_info:
            ue_items = _handle_one_line(line)
            ue_pairs = zip(head_items, ue_items)
            pair = dict(ue_pairs)
            result[pair['UE Id']] = pair
        return result

    def get_attached_ue_network_mode(self, ue):
        ue_info = self.get_ue_disp_info()
        print(ue_info)
        if not ue_info:
            return ''
        active_ue = list(
            filter(
                lambda x: ue_info[x]['State'] == 'ACTIVE' and x == ue,
                ue_info))
        if not active_ue:
            return ''
        if ue_info[ue]['MME'] != '-':
            return 'NSA'
        else:
            return 'SA'


if __name__ == '__main__':
    inst = EgateOpe()
    print(inst.get_attached_ue_network_mode('1'))
