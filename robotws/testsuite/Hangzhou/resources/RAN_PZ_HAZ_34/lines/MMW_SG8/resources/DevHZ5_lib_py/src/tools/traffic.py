import re
import time
from functools import reduce
import os
from ..common_lib import common_lib
from robot.libraries.BuiltIn import BuiltIn

comm_obj = common_lib()
builtin_obj = BuiltIn()


class linuxOp(object):

    def iperf_send_traffic(
            self,
            host,
            bandwith,
            outputfile,
            port,
            timeout):
        cmd = 'nohup iperf -c {} -u -p {} -l 1300 -b {} -i 1 -t {} > {} 2>&1 &'.format(
            host, port, bandwith, timeout, outputfile)
        comm_obj.execute_cmd_on_pc(cmd)

    def iperf_stop_traffic(self, *other_keys):
        pids = comm_obj.get_linux_process_id("iperf", *other_keys)
        comm_obj.kill_linux_process(pids)

    def iperf_received_traffic(
            self,
            rec_file,
            server,
            port):
        cmd = 'nohup iperf -s -u -p {} -i 1 -B {} > {} 2>&1 &'.format(
            port, server, rec_file)
        comm_obj.execute_cmd_on_pc(cmd)

    def iperf_send_receive_traffic(
            self,
            direct,
            host,
            server,
            bandwith,
            port,
            timeout):

        send_file = "send_{}_{}".format(
            direct, time.strftime(
                '%Y%m%d-%H%M%S', time.localtime()))
        receive_file = "receive_{}_{}".format(
            direct, time.strftime(
                '%Y%m%d-%H%M%S', time.localtime()))
        output_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}", "/home/ute")
        send_file = os.path.join(output_dir, send_file)
        receive_file = os.path.join(output_dir, receive_file)
        self.iperf_received_traffic(receive_file, server, port)
        self.iperf_send_traffic(host, bandwith, send_file, port, timeout)
        builtin_obj.log(
            '{} sending output file {}, received traffic file {}'.format(
                direct, send_file, receive_file))
        return send_file, receive_file

    def iperf_send_receive_dl_traffic(
            self,
            host,
            server,
            bandwith,
            port,
            timeout):
        return self.iperf_send_receive_traffic(
            'dl', host, server, bandwith, port, timeout)

    def iperf_send_receive_ul_traffic(
            self,
            host,
            server,
            bandwith,
            port,
            timeout):
        return self.iperf_send_receive_traffic(
            'ul', host, server, bandwith, port, timeout)

    def iperf_send_receive_dl_ul_traffic(
            self,
            dl_host,
            ul_host,
            server,
            dl_bandwith,
            ul_bandwith,
            port,
            timeout):
        result = {}
        dl_send, dl_rev = self.iperf_send_receive_dl_traffic(dl_host, server, dl_bandwith, port, timeout)
        time.sleep(3)  # add the timeout to make sure the iperf recev file has data
        ul_send, ul_rev = self.iperf_send_receive_ul_traffic(ul_host, server, ul_bandwith, port, timeout)
        result['dl_send'] = dl_send
        result['dl_rev'] = dl_rev
        result['ul_send'] = ul_send
        result['ul_rev'] = ul_rev
        return result

    def iperf_dl_traffic_should_be_ok(
            self,
            host,
            server,
            bandwith,
            port,
            timeout,
            diff_amount,
            bw_thresh):
        send_traffic, receive_traffic = self.iperf_send_receive_dl_traffic(
            host, server, bandwith, port, timeout)
        time.sleep(int(timeout) - 0.5)
        self.iperf_traffic_should_be_ok(
            send_traffic, receive_traffic, diff_amount, bw_thresh)

    def iperf_ul_traffic_should_be_ok(
            self,
            host,
            server,
            bandwith,
            port,
            timeout,
            diff_amount,
            bw_thresh):
        send_traffic, receive_traffic = self.iperf_send_receive_ul_traffic(
            host, server, bandwith, port, timeout)
        time.sleep(int(timeout) - 0.5)
        self.iperf_traffic_should_be_ok(
            send_traffic, receive_traffic, diff_amount, bw_thresh)

    def iperf_traffic_should_be_ok(
            self,
            send_traffic_file,
            received_traffic_file,
            diff_amount=1,
            bw_thresh='95'):
        pids = comm_obj.get_linux_process_id('iperf')
        comm_obj.kill_linux_process(pids)
        # handle multi taffic flow and filter the records from received file
        filtered_received_traffic_file = self._seperate_correct_receive_records(
            send_traffic_file, received_traffic_file)
        builtin_obj.log(
            'seperate received records from {} to {}'.format(
                received_traffic_file,
                filtered_received_traffic_file))
        s_interval, s_amount, s_ave_bandwith = self.get_iperf_traffic_info(
            send_traffic_file)
        r_interval, r_amount, r_ave_bandwith = self.get_iperf_traffic_info(
            filtered_received_traffic_file)
        if s_amount - r_amount > diff_amount:
            raise AssertionError(
                "traffic sends amount {} in {} while only recived {} in {}".format(
                    s_amount, send_traffic_file, r_amount, filtered_received_traffic_file))
        if r_ave_bandwith < float(bw_thresh) / 100 * s_ave_bandwith:
            raise AssertionError(
                "sending traffic average bandwith {} while received average bandwith only {}".format(
                    s_ave_bandwith, r_ave_bandwith))

    def _seperate_correct_receive_records(
            self, send_traffic_file, received_traffic_file):
        # seperate receive records by send port number and received port number
        # step 1. replace file name
        new_file = send_traffic_file.replace('send', 'receive') \
            if 'send' in send_traffic_file else send_traffic_file + 'receive'
        # step 2. get send port number on send_traffic_file
        send_port_p = r'.*local .* port (\d+) connected with.*'
        # step 3. read file content
        with open(send_traffic_file, 'r') as f:
            send_record = f.read()
        with open(received_traffic_file, 'r') as f:
            received_record = f.read()
        # step 4. get send port number on send_traffic_file.
        # local 10.12.2.1 port 39848 connected with 10.12.2.2
        send_port = re.findall(send_port_p, send_record)
        if not send_port:
            raise AssertionError(
                'no sending port found at {} by {}'.format(
                    send_traffic_file, send_port_p))
        # step 5. get udp id on received file by send port number
        received_record_p = r'(\[\s*\d+\]) local .* port .* connected with .* port {}'.format(
            send_port[0])
        received_id = re.findall(received_record_p, received_record)
        if not received_id:
            raise AssertionError(
                'received file {} not have record for port {}'. format(
                    received_traffic_file, send_port[0]))
        # step 6. get all records from received file by filtering udp_id
        records = list(
            [x for x in received_record.splitlines() if x.startswith(
                received_id[0])])
        new_records = '\n'.join(records)
        with open(new_file, 'w') as f:
            f.write(new_records)
        return new_file

    def get_iperf_traffic_info(self, traffic_file):
        from functools import reduce
        with open(traffic_file, 'r') as f:
            content = f.read()
        lines = content.splitlines()
        traffic_records = list(filter(lambda x: 'Mbits/sec' in x, lines))
        if not traffic_records:
            raise AssertionError(
                "traffic file {} does not have the traffic record".format(traffic_file))
        interval = traffic_records[0].split('sec')[0]
        interval = interval.split()[-1]
        amount = len(traffic_records)
        bandwiths = list(map(lambda x: x.split('Mbits/sec')[0].split()[-1], traffic_records))
        ave_bandwith = reduce(
            lambda x, y: float(x) + float(y), bandwiths) / amount
        builtin_obj.log(
            "find traffic {} records with average bandwith {} in {}".format(
                amount, ave_bandwith, traffic_file))
        return interval, amount, ave_bandwith


class traffic(object):
    def __init__(self):
        self.linux_inst = linuxOp()
        self.server = "10.0.2.1"
        self.port = "7070"

    def iperf_send_dl_traffic(self, ue_id, bandwith='5M', duration='600'):
        """This keyword is to use iperf to send the dl traffic and receive it from server
        | Input Parameters | Man. | Description |
        | ue_id  | Yes   | ue id |
        | bandwith  | No | default 5M |
        | duration  | No | default 600s |

        Example:
        | iperf_send_dl_traffic | 1 |
        """
        ue_ip = comm_obj.get_ue_ip(ue_id)
        return self.linux_inst.iperf_send_receive_dl_traffic(
            ue_ip, self.server, bandwith, self.port, duration)

    def iperf_send_ul_traffic(self, ue_id, bandwith='2M', duration='600'):
        """This keyword is to use iperf to send the ul traffic and receive it from server
        | Input Parameters | Man. | Description |
        | ue_id  | Yes   | ue id |
        | bandwith  | No | default 5M |
        | duration  | No | default 600s |

        Example:
        | iperf_send_ul_traffic | 1 |
        """
        pdu_gw_ip = comm_obj.get_ue_gw_ip(ue_id)
        return self.linux_inst.iperf_send_receive_ul_traffic(
            pdu_gw_ip, self.server, bandwith, self.port, duration)

    def iperf_send_dl_ul_traffic(self,
                                 ue_id,
                                 dl_bandwith='5M',
                                 ul_bandwith='2M',
                                 duration='600'):
        """This keyword is to use iperf to send the ul and dl traffic and receive it from server
        | Input Parameters | Man. | Description |
        | ue_id  | Yes   | ue id |
        | dl_bandwith  | No | default 5M |
        | ul_bandwith  | No | default 2M |
        | duration  | No | default 600s |

        Example:
        | iperf_send_ul_traffic | 1 |
        """
        ue_ip = comm_obj.get_ue_ip(ue_id)
        pdu_gw_ip = comm_obj.get_ue_gw_ip(ue_id)
        return self.linux_inst.iperf_send_receive_dl_ul_traffic(ue_ip, pdu_gw_ip, self.server,
                                                                dl_bandwith, ul_bandwith, self.port, duration)

    def iperf_stop_dl_traffic(self, ue_id):
        """This keyword is to kill the dl traffic on the specified ue
        | Input Parameters | Man. | Description |
        | ue_id  | Yes   | ue id |

        Example:
        | iperf_stop_dl_traffic | 1 |
        """
        ue_ip = comm_obj.get_ue_ip(ue_id)
        return self.linux_inst.iperf_stop_traffic(ue_ip)

    def iperf_stop_ul_traffic(self, ue_id):
        """This keyword is to kill the ul traffic on the specified ue
        | Input Parameters | Man. | Description |
        | ue_id  | Yes   | ue id |

        Example:
        | iperf_stop_ul_traffic | 1 |
        """
        pdu_gw_ip = comm_obj.get_ue_gw_ip(ue_id)
        return self.linux_inst.iperf_stop_traffic(pdu_gw_ip)

    def iperf_dl_traffic_should_be_ok(self, ue_id,
                                      bandwith='5M',
                                      duration='5',
                                      diff_amount=1,
                                      bw_thresh='95'):
        """This keyword is to use iperf to send the dl traffic and receive it from server, and compare the records \
        received with the sent.
        | Input Parameters | Man. | Description |
        | ue_id  | Yes   | ue id |
        | bandwith  | No | default 5M |
        | duration  | No | default 5s |
        | diff_amount | string | default 1, which means sending records - received record < diff_amount
        | bw_thresh | string | default 95, means received average bandwith
        not less than 0.95 * sending average bandwith

        Example:
        | iperf_dl_traffic_should_be_ok | 1 |
        """
        ue_ip = comm_obj.get_ue_ip(ue_id)
        return self.linux_inst.iperf_dl_traffic_should_be_ok(
            ue_ip, self.server, bandwith, self.port, duration, diff_amount, bw_thresh)

    def iperf_ul_traffic_should_be_ok(self, ue_id,
                                      bandwith='2M',
                                      duration='5',
                                      diff_amount=1,
                                      bw_thresh='95'):
        """This keyword is to use iperf to send the up traffic and receive it from server, and compare the records \
        received with the sent.
        | Input Parameters | Man. | Description |
        | ue_id  | Yes   | ue id |
        | bandwith  | No | default 2M |
        | duration  | No | default 5s |
        | diff_amount | string | default 1, which means sending records - received record < diff_amount
        | bw_thresh | string | default 95, means received average bandwith
        not less than 0.95 * sending average bandwith

        Example:
        | iperf_ul_traffic_should_be_ok | 1 |
        """
        pdu_gw_ip = comm_obj.get_ue_gw_ip(ue_id)
        return self.linux_inst.iperf_ul_traffic_should_be_ok(
            pdu_gw_ip, self.server, bandwith, self.port, duration, diff_amount, bw_thresh)

    def iperf_traffic_should_be_ok(self,
                                   send_traffic_file,
                                   received_traffic_file,
                                   diff_amount=1,
                                   bw_thresh='95'):
        """
        compare the sending records and received records files
        :input:
        | send_traffic_file  | string | iperf sending traffic output file
        | received_traffic_file | string | iperf server received traffic output file
        | diff_amount | string | default 1, which means sending records - received record < diff_amount
        | bw_thresh | string | default 95, means received average bandwith not less than 0.95 * sending \
        average bandwith
        :return:
        :example:
        | iperf_traffic_should_be_ok | ${sending_file} | ${received_traffic_file}

        """
        return self.linux_inst.iperf_traffic_should_be_ok(
            send_traffic_file, received_traffic_file, diff_amount, bw_thresh
        )
