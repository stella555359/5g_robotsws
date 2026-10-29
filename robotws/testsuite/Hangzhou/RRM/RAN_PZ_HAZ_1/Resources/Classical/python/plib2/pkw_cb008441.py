#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import os
import time
import re
from petbase import gv
from pprint import pprint
logger = gv.logger
kw = gv.kw


class pkw_cb008441(object):

    def __init__(self):
        self.alg_result = []
        self.summary = []

    def show_table(self, intable, fields):
        from pprint import pprint
        table = []
        table.append('|'.join(fields))
        for row in intable:
            table.append('|'.join([str(row[key]) for key in fields]))

        output = ['<TABLE BORDER=1 BORDERCOLOR="#000000" CELLPADDING=4 CELLSPACING=0>']
        for i in range(len(table)):
            output.append('<tr>')
            tstr = 'th' if i == 0 else 'td'
            for item in table[i].split('|'):
                # if item.strip():
                output.append('<%s>%s</%s>' % (tstr, item, tstr))
            output.append('</tr>')
        output.append('</table>')
        print("*HTML* \n%s" % ('\n'.join(output)))

    def run_iperf3_on_data_device(self, **kwargs):
        '''
            -   用iperf3打下行流，保证能成功，然后根据输出，计算出平均的throughput和retry
            -   输出的througput是 Kbps
        '''

        def _successful_output(output):
            return 'iperf Done' in output

        def _parse_iperf_output(output):
            lines = [x.strip() for x in output.splitlines() if x.strip()]
            lines = [x for x in lines if x.endswith('sender') and 'SUM' not in x.upper()]
            result = []
            for line in lines:
                value, unit, retry = line.split()[6:9]
                value = float(value) * 1024 * 1024 if 'Gbits' in unit else value
                value = float(value) * 1024 if 'Mbits' in unit else value
                result.append((float(value), float(retry), 2))
            return round(sum([x[0] for x in result]), 2), round(sum([x[1] for x in result]), 2)

        tag = kwargs.get('tag', time.strftime("%H_%M_%S"))
        logdir = kwargs.get('logdir', gv.pv('${CASE_DIRE}'))
        logfilename = os.path.join(logdir, f'iperf3_{tag}.txt')
        gv.logger.info(f'Start Iperf3 for CB008441, tag: {tag}')
        succeed = False
        avg_throughput, avg_retry = 0, 0
        while not succeed:
            if kwargs.get('use_ap', False):
                output = os.popen(kwargs.get('cmd')).read()
            else:
                output = kw('l2_ssh_exec_command', kwargs.get('host'), kwargs.get('cmd'))
            for line in output.splitlines():
                print(line)
            succeed = _successful_output(output)
            if succeed:
                gv.logger.info(f'iperf 3 successfully done, logfile: {logfilename}')
                with open(logfilename, 'w') as f:
                    f.write(output)
                avg_throughput, avg_retry = _parse_iperf_output(output)
                gv.logger.info(f'Average throughput: {avg_throughput} Kbps, retry: {avg_retry}')
            else:
                gv.logger.info('!!!! Iperf failed, try again.')
        return avg_throughput, avg_retry

    def get_avg_rtt_from_pcapfile(self, pacpfile, timeout):
        '''
            -   对用tcpdump抓的ip包用tshark命令计算平均的rtt
        '''
        cmd = f'tshark -r {pacpfile} -q -z io,stat,{timeout},"AVG(tcp.analysis.ack_rtt)tcp.analysis.ack_rtt"'
        gv.logger.info(cmd)
        output = [x.strip() for x in os.popen(cmd).read().splitlines() if f'0 <> {timeout}' in x]
        print(output)
        if output:
            return float(output[0].split('|')[2])
        else:
            raise Exception(f'Could not find 0 <> {timeout} in command output')

    def do_download_service_and_calc_kpis_for_cb008441(self, **kwargs):
        '''
            为Feature CB008441 打流，抓包，并且计算相应的 throughput kpi
            -   到打流服务器上执行tcpdump开始抓包；
            -   到打流服务器上用给定的命令开始打下行流；这里用iperf3命令，结果输出到一个文本文件，后面要根据文件内容进行计算；
            -   等到下行流执行结束，退出；解析命令的输出，计算出平均的throughput 和平均的retry
            -   停止tcpdump，然后下载抓的包文件test.pcap到本地；
            -   执行tshark命令计算平均的rtt值； 最后返回这3个kpi

            -   必须给的参数：command, 打流的命令；iperf_timeout，打流的时间，这个计算要用；
        '''
        datadevice = kwargs.get('host', '10.69.9.58')
        command = kwargs.get('command')
        tag = kwargs.get('tag', time.strftime("%H_%M_%S"))
        # iperf_timeout = kwargs.get('iperf_timeout')
        use_ap = kwargs.get('use_ap', 'NO').upper() in ['Y', 'YES', 'TRUE']
        iperf_timeout = re.findall(r'-t([\d]+)', command)[0]
        logdir = kwargs.get('logdir', gv.pv('${CASE_DIRE}'))
        pcap_file = os.path.join(logdir, f'pcap_{tag}.pcap')

        if os.path.exists(pcap_file):
            os.remove(pcap_file)

        if use_ap:
            kw('run', 'sudo pkill tcpdump')
            kw('run', f'sudo rm -rf {pcap_file}')
            cmd = f'sudo nohup tcpdump host 10.12.2.2 -i any -vv -w {pcap_file} &'
            print(cmd)
            os.system(cmd)
            # kw('run', f'sudo nohup tcpdump host 10.12.2.2 -i any -vv -w {pcap_file} &')
        else:
            kw('l2_ssh_exec_command', datadevice, 'sudo pkill tcpdump')
            kw('l2_ssh_exec_command', datadevice, 'sudo rm -rf test.pcap')
            kw('l2_ssh_exec_command', datadevice, 'sudo tcpdump port 50001 -w test.pcap', 'use_shell=Y')

        avg_throughput, avg_retry = kw('run_iperf3_on_data_device', f'host={datadevice}',
                                       f'cmd={command}', 'timeout=60', 'use_ap=' + kwargs.get('use_ap', 'NO'),
                                       f'logdir={logdir}', f'tag={tag}')
        kw('sleep', '5s')
        if use_ap:
            kw('run', 'sudo pkill tcpdump')
        else:
            kw('l2_ssh_exec_command', datadevice, 'sudo pkill tcpdump')
            kw('l2_ssh_exec_command', datadevice, 'sudo pkill tcpdump')
            kw('l2_ssh_get_file', datadevice, 'test.pcap', pcap_file)
        avg_rtt = kw('get_avg_rtt_from_pcapfile', pcap_file, iperf_timeout)
        return avg_throughput, avg_retry, avg_rtt

    def repeat_do_download_service_for_cb008441(self, **kwargs):
        def _avg(alist):
            return round(sum(alist) / len(alist), 4) if alist else 0
        _params = [f'{x}={kwargs[x]}' for x in kwargs if x.lower() not in ['repeat_count']]
        repeat_count = int(kwargs.get('repeat_count', 1))
        tag = kwargs.get('tag', 'CoDel')
        interval = kwargs.get('interval', '1s')
        command = kwargs.get('command', '')
        need_attach = kwargs.get('need_attach', 'N').upper() in ['Y', 'YES', 'TRUE']
        _t = re.findall(r'-t([\d]+)', command)[0]
        _p = re.findall(r'-P([\d]+)', command)[0]
        tputlist, retrylist, rttlist = [], [], []
        self.alg_result = []
        for i in range(repeat_count):
            kw('log to console', f'\n第 {i + 1} 轮')
            if need_attach:
                kw('attach_ue_and_activate_pdu', '1', 'external')
            round_dire = os.path.join(gv.pv('${CASE_DIRE}'), f'{tag}_P{_p}_t{_t}_Round_{i+1}')
            kw('run', f'mkdir -p {round_dire}')
            _params.append(f'logdir={round_dire}')
            avg_throughput, avg_retry, avg_rtt = kw(
                'do_download_service_and_calc_kpis_for_cb008441',
                *_params  # 这种方法可以把外面传进来的可变变量传进去；
            )
            tputlist.append(avg_throughput)
            retrylist.append(avg_retry)
            rttlist.append(avg_rtt)
            kw('log to console', f'tput: {avg_throughput}, retry: {avg_retry}, rtt: {avg_rtt}')
            self.alg_result.append(dict(Index=i+1, ALG=tag, Parallel=_p, Duration=_t,
                                        Throughput=avg_throughput, Retry=avg_retry, Rtt=avg_rtt))
            if need_attach:
                kw('detach_ue_with_power_off', '1')
            kw('sleep', interval)
        self.alg_result.append(dict(Index='AVG', ALG=tag, Parallel=_p, Duration=_t,
                                    Throughput=_avg(tputlist), Retry=_avg(retrylist), Rtt=_avg(rttlist)))
        self.show_table(self.alg_result, ['Index', 'ALG', 'Parallel', 'Duration', 'Throughput', 'Retry', 'Rtt'])
        kw('log to console', f'最终平均：tput: {_avg(tputlist)}, retry: {_avg(retrylist)}, rtt: {_avg(rttlist)}')

        fname = os.path.join(os.path.join(gv.pv('${CASE_DIRE}'), f'summary.txt'))
        if not os.path.exists(fname):
            with open(fname, 'w') as f:
                f.write('ALG    Parallel    Duration    Throughput    Retry    RTT\n')
        with open(fname, 'a') as f:
            f.write(f'{tag}     {_p}        {_t}    {_avg(tputlist)}    {_avg(retrylist)}    {_avg(rttlist)}\n')
        self.summary.append(dict(ALG=tag, Parallel=_p, Duration=_t,
                                 Throughput=_avg(tputlist), Retry=_avg(retrylist), Rtt=_avg(rttlist)))
        return [_avg(tputlist), _avg(retrylist), _avg(rttlist)]

    def set_ue_listen_on(self, ue, server_port=50001):
        kw('Call Method', ue, 'exec_adb_command', 'root')
        kw('Call Method', ue, 'stop_iperf_listen_on', server_port)
        kw('Call Method', ue, 'start_iperf_listen_on', server_port)

    def compare_kpi_between_codel_and_pi2(self, result1, result2):
        kw('should be true', result1[0] <= result2[0])
        kw('should be true', result1[1] >= result2[1])
        kw('should be true', result1[2] >= result2[2])
        kw('log to console', 'Codel 模式 和 PI2 模式 测试数据结果比较成功。')

    def show_summary(self):
        self.show_table(self.summary, ['ALG', 'Parallel', 'Duration', 'Throughput', 'Retry', 'Rtt'])

    def get_counter_before_service(self, unit_name, counter_list):
        self.init_counters = {}
        for item in counter_list:
            self.init_counters[item['id']] = kw('paic_get_counter', unit_name, item['dist_name'], item['id'])['values']
            # self.init_counters[item['id']] = []

    def get_counter_after_service(self, unit_name, counter_list):
        self.final_counters = {}
        for item in counter_list:
            self.final_counters[item['id']] = kw('paic_get_counter', unit_name, item['dist_name'], item['id'])['values']

    def calc_counter_diff(self):
        def _sum_counter(values):
            result = {}
            for line in values:
                result[line['start_time']] = float(line['value'])
            return result

        diffs = []
        for id in self.final_counters:
            init = _sum_counter(self.init_counters[id])
            final = _sum_counter(self.final_counters[id])
            for line in final:
                if line not in init:
                    diffs.append([id, line, final[line]])
        pprint(diffs)
        result = {}
        for id in self.final_counters:
            result[id] = sum([x[2] for x in diffs if x[0] == id])
        pprint(result)
        return result
