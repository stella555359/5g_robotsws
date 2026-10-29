# -*- coding: utf-8 -*-
"""
Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
"""
import logging
import time
import re
from statistics import mean
from taf.transport.ssh import ssh


class SMAWaveTput():

    def __init__(self):
        self.ssh = ssh()

    def run_downlink_traffic(self, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                             uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1', smawave_username='root',
                             smawave_password='Js0Bf7Lq8Gk2', tput_port=6888, tput_command=1400,
                             appserver_ip='10.84.168.70', appserver_username='5g', appserver_passwd='5g',
                             duration_time=120, tput_expected=267, deviation='10%', protocol='tcp', parallel_streams=2,
                             tcp_iperf_version=3, key_algorithm=None, ssh_method='plink'):
        self._connect_to_uepc(uepc_ip, username=uepc_username, passwd=uepc_passwd)
        smawave_channel, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                    username=smawave_username,
                                                                    key_algorithm=key_algorithm, perform_reboot=True)
        putty_channel = self._run_putty(appserver_ip, username=appserver_username, password=appserver_passwd,
                                        ssh_method=ssh_method)

        if protocol.lower() == 'tcp':
            self._verify_and_close_putty_tput_port(putty_channel, tput_port, appserver_username)
            if tcp_iperf_version == 3:
                smawave_channel.send('iperf3 -s -p{} -i1\n'.format(tput_port))
                time.sleep(5)
                logging.debug('Perform TCP Downlink L3 Call')
                putty_channel.send('iperf3 -c {} -i1 -p{} -t{} -M{} -l{} -P{}\n'.format(smawave_core_ip, tput_port,
                                                                                        duration_time, tput_command,
                                                                                        tput_command, parallel_streams))
            elif tcp_iperf_version == 2:
                smawave_channel.send('iperf -s -p{} -i1\n'.format(tput_port))
                time.sleep(5)
                logging.debug('Perform TCP Downlink L3 Call')
                putty_channel.send('iperf -c {} -i1 -p{} -t{} -M{} -l{} -P{}\n'.format(smawave_core_ip, tput_port,
                                                                                       duration_time, tput_command,
                                                                                       tput_command, parallel_streams))
            else:
                logging.error('Iperf version is not correct')
                self._disconnect_on_fail()
                raise IperfVersionError

        elif protocol.lower() == 'udp':
            smawave_channel.send('iperf -s -p{} -u -l1400 -i1\n'.format(tput_port))
            time.sleep(5)
            logging.debug('Perform UDP Downlink L3 Call')
            putty_channel.send('iperf -c {} -u -i1 -p{} -l1400 -t{} -b{}M -w32m\n'.format(smawave_core_ip, tput_port,
                                                                                          duration_time, tput_command))
        else:
            logging.error('Protocol is not correct')
            self._disconnect_on_fail()
            raise ProtocolError

        time.sleep(duration_time+5)
        hostname_putty = putty_channel.recv(65536)
        hostname_smawave = smawave_channel.recv(65536)
        throughput = str(hostname_smawave).split('\\n')

        if self._verify_tput(throughput, tput_expected, deviation, protocol, parallel_streams=parallel_streams,
                             duration=duration_time):
            logging.debug('Output downlink is as expected')
            self._disconnect()
        else:
            logging.error('Output downlink is below expected: {} Mbits/s'.format(tput_expected))
            self._disconnect_on_fail()
            raise ThroughputNotAsExpected

    def run_downlink_traffic_and_wait_for_0_tput(self, uepc_ip='PLKR-SG02-207.intra.noklab.net',
                                                 smawave_password='Js0Bf7Lq8Gk2',  tput_port=6888, tput_command=260,
                                                 app_server_ip='10.84.168.70',  duration_time=120,  key_algorithm=None):
        self._connect_to_uepc(uepc_ip)
        smawave_channel, smawave_core_ip = self._connect_to_smawave(password=smawave_password, perform_reboot=True,
                                                                    key_algorithm=key_algorithm)
        putty_channel = self._run_putty(app_server_ip)
        smawave_channel.send('iperf -s -p{} -u -l1400 -i1\n'.format(tput_port))
        time.sleep(5)
        putty_channel.send('iperf -c {} -u -i1 -p{} -l1400 -t{} -b{}M -w32m\n'.format(smawave_core_ip, tput_port,
                                                                                      duration_time, tput_command))
        is_traffic_down = False
        throughput_full = []

        while duration_time > 0:
            duration_time -= 5
            time.sleep(5)
            hostname_smawave = smawave_channel.recv(65536)
            hostname_putty = putty_channel.recv(65536)
            throughput = str(hostname_smawave).split('\\n')
            logging.debug(f'SMAWAve:\n{hostname_smawave}\n\n')
            logging.debug(f'Putty:\n{hostname_putty}\n\n')

            for line in throughput:
                throughput_full.append(line)

            if self._verify_tput(throughput_full[-5:], 0, '0%', 'udp'):
                logging.debug('Downlink traffic is down')
                is_traffic_down = True
                break

        if not is_traffic_down:
            logging.error('Traffic did not break during test time')
            self._disconnect_on_fail()
            raise TrafficNotBreak
        else:
            self._disconnect()

    def run_uplink_traffic(self, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                           uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1', smawave_username='root',
                           smawave_password='Js0Bf7Lq8Gk2', tput_port=6889, tput_command=350,
                           appserver_ip='10.84.168.70', appserver_username='5g', appserver_passwd='5g',
                           appserver_traffic_ip='10.84.169.54', duration_time=120, tput_expected=26, deviation='10%',
                           protocol='tcp'):
        self._connect_to_uepc(uepc_ip, username=uepc_username, passwd=uepc_passwd)
        smawave_channel, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                    username=smawave_username, perform_reboot=True)
        putty_channel = self._run_putty(appserver_ip, username=appserver_username, password=appserver_passwd)

        if protocol.lower() == 'tcp':
            self._verify_and_close_putty_tput_port(putty_channel, tput_port, appserver_username)
            putty_channel.send('iperf3 -s -i1 -p{}\n'.format(tput_port))
            time.sleep(5)
            logging.debug('Perform TCP Uplink L3 Call')
            smawave_channel.send('iperf3 -c {} -i1 -t{} -p{} -M{} -l{}\n'.format(appserver_traffic_ip, duration_time,
                                                                                 tput_port, tput_command, tput_command))
        elif protocol.lower() == 'udp':
            putty_channel.send('iperf -s -u -i1 -p{} -l1350 -w2m\n'.format(tput_port))
            time.sleep(5)
            logging.debug('Perform UDP Uplink L3 Call')
            smawave_channel.send('iperf -u -c {} -b{}M -t{} -i1 -p{} -l1350\n'.format(appserver_traffic_ip,
                                                                                      tput_command, duration_time,
                                                                                      tput_port))
        else:
            logging.error('Protocol is not correct')
            self._disconnect_on_fail()
            raise ProtocolError

        time.sleep(duration_time + 5)
        hostname_putty = putty_channel.recv(65536)
        throughput = str(hostname_putty).split('\\n')

        if self._verify_tput(throughput, tput_expected, deviation, protocol, duration=duration_time, is_dl=False):
            logging.debug('Output uplink is as expected')
            self._disconnect_on_fail()
        else:
            logging.error('Output uplink is below expected: {} Mbits/s'.format(tput_expected))
            self._disconnect_on_fail()
            raise ThroughputNotAsExpected

    def run_uplink_traffic_multistream(self, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                                       uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1', smawave_username='root',
                                       smawave_password='Js0Bf7Lq8Gk2', tput_port=6889, tput_command=350,
                                       appserver_ip='10.84.168.70', appserver_username='5g', appserver_passwd='5g',
                                       appserver_traffic_ip='10.84.169.54', duration_time=120, tput_expected=26,
                                       deviation='10%', protocol='tcp', parallel_streams=2, key_algorithm=None,
                                       tcp_iperf_version=2, ssh_method='plink', perform_reboot=True):
        self._run_uplink_traffic_multistream(uepc_ip=uepc_ip, uepc_username=uepc_username,
                                             uepc_passwd=uepc_passwd, smawave_ip=smawave_ip,
                                             smawave_username=smawave_username, smawave_password=smawave_password,
                                             tput_port=tput_port, tput_command=tput_command,
                                             appserver_ip=appserver_ip, appserver_username=appserver_username,
                                             appserver_passwd=appserver_passwd,
                                             appserver_traffic_ip=appserver_traffic_ip,
                                             duration_time=duration_time, tput_expected=tput_expected,
                                             deviation=deviation, protocol=protocol,
                                             parallel_streams=parallel_streams, key_algorithm=key_algorithm,
                                             tcp_iperf_version=tcp_iperf_version, ssh_method=ssh_method,
                                             perform_reboot=perform_reboot)

    def _run_uplink_traffic_multistream(self, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                                        uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1', smawave_username='root',
                                        smawave_password='Js0Bf7Lq8Gk2', tput_port=6889, tput_command=350,
                                        appserver_ip='10.84.168.70', appserver_username='5g', appserver_passwd='5g',
                                        appserver_traffic_ip='10.84.169.54', duration_time=120, tput_expected=26,
                                        deviation='10%', protocol='tcp', parallel_streams=2, key_algorithm=None,
                                        tcp_iperf_version=2, ssh_method='plink', perform_reboot=True):
        self._connect_to_uepc(uepc_ip, username=uepc_username, passwd=uepc_passwd)
        smawave_channel, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                    username=smawave_username,
                                                                    key_algorithm=key_algorithm,
                                                                    perform_reboot=perform_reboot)
        putty_channel = self._run_putty(appserver_ip, username=appserver_username, password=appserver_passwd,
                                        ssh_method=ssh_method)

        if protocol.lower() == 'tcp':
            self._verify_and_close_putty_tput_port(putty_channel, tput_port, appserver_username)
            if tcp_iperf_version == 3:
                putty_channel.send('iperf3 -s -i1 -p{}\n'.format(tput_port))
                time.sleep(5)
                logging.debug('Perform TCP Uplink L3 Call')
                smawave_channel.send('iperf3 -c {} -i1 -t{} -p{} -M{} -l{} -P{}\n'.format(appserver_traffic_ip,
                                                                                          duration_time, tput_port,
                                                                                          tput_command, tput_command,
                                                                                          parallel_streams))
            elif tcp_iperf_version == 2:
                putty_channel.send('iperf -s -i1 -p{}\n'.format(tput_port))
                time.sleep(5)
                logging.debug('Perform TCP Uplink L3 Call')
                smawave_channel.send('iperf -c {} -i1 -t{} -p{} -M{} -l{} -P{}\n'.format(appserver_traffic_ip,
                                                                                         duration_time, tput_port,
                                                                                         tput_command, tput_command,
                                                                                         parallel_streams))
            else:
                logging.error('Iperf version is not correct')
                self._disconnect_on_fail()
                raise IperfVersionError

        elif protocol.lower() == 'udp':
            putty_channel.send('iperf -s -u -i1 -p{} -l1350 -w2m\n'.format(tput_port))
            time.sleep(5)
            logging.debug('Perform UDP Uplink L3 Call')
            smawave_channel.send('iperf -u -c {} -b{}M -t{} -i1 -p{} -l1350\n'.format(appserver_traffic_ip,
                                                                                      tput_command, duration_time,
                                                                                      tput_port))
        else:
            logging.error('Protocol is not correct')
            self._disconnect_on_fail()
            raise ProtocolError

        time.sleep(duration_time + 5)
        hostname_putty = putty_channel.recv(65536)
        throughput = str(hostname_putty).split('\\n')

        if self._verify_tput(throughput, tput_expected, deviation, protocol, duration=duration_time,
                             parallel_streams=parallel_streams):
            logging.debug('Output uplink is as expected')
            self._disconnect()
        else:
            logging.error('Output uplink is below expected: {} Mbits/s'.format(tput_expected))
            self._disconnect_on_fail()
            raise ThroughputNotAsExpected

    def run_bidirectional_traffic(self, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                                  uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1', smawave_username='root',
                                  smawave_password='Js0Bf7Lq8Gk2', tput_port_dl=6888, tput_port_ul=6889,
                                  tput_command_dl=1400, tput_command_ul=350,  appserver_ip='10.84.168.70',
                                  appserver_username='5g', appserver_passwd='5g', appserver_traffic_ip='10.84.169.54',
                                  duration_time=120, tput_expected_dl=267, tput_expected_ul=26, deviation='10%',
                                  protocol='tcp', key_algorithm=None, parallel_streams=2):
        self._connect_to_uepc(uepc_ip, username=uepc_username, passwd=uepc_passwd)
        smawave_channel_dl, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                       username=smawave_username, perform_reboot=True,
                                                                       key_algorithm=key_algorithm)
        smawave_channel_ul, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                       username=smawave_username,
                                                                       key_algorithm=key_algorithm)
        putty_channel_dl = self._run_putty(appserver_ip, username=appserver_username, password=appserver_passwd)
        putty_channel_ul = self._run_putty(appserver_ip, username=appserver_username, password=appserver_passwd)

        if protocol.lower() == 'tcp':
            self._verify_and_close_putty_tput_port(putty_channel_ul, tput_port_ul, appserver_username)
            putty_channel_ul.send('iperf3 -s -i1 -p{}\n'.format(tput_port_ul))
            smawave_channel_dl.send('iperf3 -s -p{} -i1\n'.format(tput_port_dl))
            time.sleep(5)
            logging.debug('Perform TCP Bidirectional L3 Call')
            putty_channel_dl.send('iperf3 -c {} -i1 -p{} -t{} -M{} -l{} -P{}\n'.format(smawave_core_ip, tput_port_dl,
                                                                                       duration_time, tput_command_dl,
                                                                                       tput_command_dl,
                                                                                       parallel_streams))
            time.sleep(2)
            smawave_channel_ul.send('iperf3 -c {} -i1 -t{} -p{} -M{} -l{}\n'.format(appserver_traffic_ip, duration_time,
                                                                                    tput_port_ul, tput_command_ul,
                                                                                    tput_command_ul))

        elif protocol.lower() == 'udp':
            putty_channel_ul.send('iperf -s -u -i1 -p{} -l1350 -w2m -t{}\n'.format(tput_port_ul, duration_time))
            smawave_channel_dl.send('iperf -s -p{} -u -l1400 -i1 -t{}\n'.format(tput_port_dl, duration_time))
            time.sleep(5)
            logging.debug('Perform UDP Bidirectional L3 Call')
            putty_channel_dl.send('iperf -c {} -u -i1 -p{} -l1400 -t{} -b{}M -w32m\n'.format(smawave_core_ip,
                                                                                             tput_port_dl,
                                                                                             duration_time,
                                                                                             tput_command_dl))
            time.sleep(2)
            smawave_channel_ul.send('iperf -u -c {} -b{}M -t{} -i1 -p{} -l1350\n'.format(appserver_traffic_ip,
                                                                                         tput_command_ul, duration_time,
                                                                                         tput_port_ul))

        else:
            logging.error('Protocol is not correct')
            self._disconnect_on_fail()
            raise ProtocolError

        time.sleep(duration_time + 7)
        hostname_putty_ul = putty_channel_ul.recv(65536)
        hostname_smawave_dl = smawave_channel_dl.recv(65536)

        throughput_ul = str(hostname_putty_ul).split('\\n')
        throughput_dl = str(hostname_smawave_dl).split('\\n')

        throughput_failed = False
        if self._verify_tput(throughput_ul, tput_expected_ul, deviation, protocol, duration=duration_time):
            logging.debug('Output uplink is as expected')
        else:
            logging.error('Output uplink is not as expected: {} Mbits/s'.format(tput_expected_ul))
            self._disconnect_on_fail()
            throughput_failed = True

        if self._verify_tput(throughput_dl, tput_expected_dl, deviation, protocol, parallel_streams=parallel_streams,
                             duration=duration_time):
            logging.debug('Output downlink is as expected')
        else:
            logging.error('Output downlink is not as expected: {} Mbits/s'.format(tput_expected_dl))
            self._disconnect_on_fail()
            throughput_failed = True

        if throughput_failed:
            raise ThroughputNotAsExpected

        self._disconnect()

    def run_bidirectional_traffic_multistream(self, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                                              uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1',
                                              smawave_username='root', smawave_password='Js0Bf7Lq8Gk2',
                                              tput_port_dl=6888, tput_port_ul=6889, tput_command_dl=1400,
                                              tput_command_ul=350, appserver_ip='10.84.168.70',
                                              appserver_username='5g', appserver_passwd='5g',
                                              appserver_traffic_ip='10.84.169.54', duration_time=120,
                                              tput_expected_dl=267, tput_expected_ul=26, deviation='10%',
                                              protocol='tcp', key_algorithm=None, parallel_streams_dl=4,
                                              parallel_streams_ul=8, ssh_method='plink'):

        self._run_bidirectional_traffic_multistream(uepc_ip=uepc_ip, uepc_username=uepc_username,
                                                    uepc_passwd=uepc_passwd, smawave_ip=smawave_ip,
                                                    smawave_username=smawave_username,
                                                    smawave_password=smawave_password, tput_port_dl=tput_port_dl,
                                                    tput_port_ul=tput_port_ul, tput_command_dl=tput_command_dl,
                                                    tput_command_ul=tput_command_ul, appserver_ip=appserver_ip,
                                                    appserver_username=appserver_username,
                                                    appserver_passwd=appserver_passwd,
                                                    appserver_traffic_ip=appserver_traffic_ip,
                                                    duration_time=duration_time, tput_expected_dl=tput_expected_dl,
                                                    tput_expected_ul=tput_expected_ul, deviation=deviation,
                                                    protocol=protocol, key_algorithm=key_algorithm,
                                                    parallel_streams_dl=parallel_streams_dl,
                                                    parallel_streams_ul=parallel_streams_ul, ssh_method=ssh_method)

    def _run_bidirectional_traffic_multistream(self, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                                               uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1',
                                               smawave_username='root', smawave_password='Js0Bf7Lq8Gk2',
                                               tput_port_dl=6888, tput_port_ul=6889, tput_command_dl=1400,
                                               tput_command_ul=350, appserver_ip='10.84.168.70',
                                               appserver_username='5g', appserver_passwd='5g',
                                               appserver_traffic_ip='10.84.169.54', duration_time=120,
                                               tput_expected_dl=267, tput_expected_ul=26, deviation='10%',
                                               protocol='tcp', key_algorithm=None, parallel_streams_dl=4,
                                               parallel_streams_ul=8, ssh_method='plink'):
        self._connect_to_uepc(uepc_ip, username=uepc_username, passwd=uepc_passwd)
        smawave_channel_dl, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                       username=smawave_username, perform_reboot=True,
                                                                       key_algorithm=key_algorithm)
        smawave_channel_ul, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                       username=smawave_username,
                                                                       key_algorithm=key_algorithm)
        putty_channel_dl = self._run_putty(appserver_ip, username=appserver_username, password=appserver_passwd,
                                           ssh_method=ssh_method)
        putty_channel_ul = self._run_putty(appserver_ip, username=appserver_username, password=appserver_passwd,
                                           ssh_method=ssh_method)

        if protocol.lower() == 'tcp':
            self._verify_and_close_putty_tput_port(putty_channel_ul, tput_port_ul, appserver_username)
            putty_channel_ul.send('iperf3 -s -i1 -p{}\n'.format(tput_port_ul))
            smawave_channel_dl.send('iperf3 -s -p{} -i1\n'.format(tput_port_dl))
            time.sleep(5)
            logging.debug('Perform TCP Bidirectional L3 Call')
            putty_channel_dl.send('iperf3 -c {} -i1 -p{} -t{} -M{} -P{}\n'.format(smawave_core_ip, tput_port_dl,
                                                                                  duration_time, tput_command_dl,
                                                                                  parallel_streams_dl))
            time.sleep(2)
            smawave_channel_ul.send('iperf3 -c {} -i1 -t{} -p{} -M{} -P{}\n'.format(appserver_traffic_ip, duration_time,
                                                                                    tput_port_ul, tput_command_ul,
                                                                                    parallel_streams_ul))

        elif protocol.lower() == 'udp':
            putty_channel_ul.send('iperf -s -u -i1 -p{} -l1350 -w2m -t{}\n'.format(tput_port_ul, duration_time))
            smawave_channel_dl.send('iperf -s -p{} -u -l1400 -i1 -t{}\n'.format(tput_port_dl, duration_time))
            time.sleep(5)
            logging.debug('Perform UDP Bidirectional L3 Call')
            putty_channel_dl.send('iperf -c {} -u -i1 -p{} -l1400 -t{} -b{}M -w32m\n'.format(smawave_core_ip,
                                                                                             tput_port_dl,
                                                                                             duration_time,
                                                                                             tput_command_dl))
            time.sleep(2)
            smawave_channel_ul.send('iperf -u -c {} -b{}M -t{} -i1 -p{} -l1350\n'.format(appserver_traffic_ip,
                                                                                         tput_command_ul, duration_time,
                                                                                         tput_port_ul))

        else:
            logging.error('Protocol is not correct')
            self._disconnect_on_fail()
            raise ProtocolError

        time.sleep(duration_time + 7)
        hostname_putty_ul = putty_channel_ul.recv(65536)
        hostname_smawave_dl = smawave_channel_dl.recv(65536)

        throughput_ul = str(hostname_putty_ul).split('\\n')
        throughput_dl = str(hostname_smawave_dl).split('\\n')

        throughput_failed = False
        if self._verify_tput(throughput_ul, tput_expected_ul, deviation, protocol, parallel_streams=parallel_streams_ul,
                             duration=duration_time):
            logging.debug('Output uplink is as expected')
        else:
            logging.error('Output uplink is not as expected: {} Mbits/s'.format(tput_expected_ul))
            self._disconnect_on_fail()
            throughput_failed = True

        if self._verify_tput(throughput_dl, tput_expected_dl, deviation, protocol, parallel_streams=parallel_streams_dl,
                             duration=duration_time):
            logging.debug('Output downlink is as expected')
            self._disconnect()
        else:
            logging.error('Output downlink is not as expected: {} Mbits/s'.format(tput_expected_dl))
            self._disconnect_on_fail()
            throughput_failed = True

        if throughput_failed:
            raise ThroughputNotAsExpected

    def verify_nr_hostcell_bandwidth(self, bandwidth, uepc_ip='PLKR-SG02-207.intra.noklab.net', uepc_username='pzkrk',
                                     uepc_passwd='NokiaBts2003', smawave_ip='192.168.1.1', smawave_username='root',
                                     smawave_password='Js0Bf7Lq8Gk2'):
        self._connect_to_uepc(uepc_ip, username=uepc_username, passwd=uepc_passwd)
        smawave_channel, smawave_core_ip = self._connect_to_smawave(smawave_ip=smawave_ip, password=smawave_password,
                                                                    username=smawave_username)
        smawave_channel.send('/etc/init.d/comd stop\n')
        time.sleep(5)
        hostname_smawave = smawave_channel.recv(65536)
        smawave_channel.send('atcmd /dev/ttyUSB2 115200 AT+GTCCINFO?\n')
        time.sleep(5)
        hostname_smawave = smawave_channel.recv(65536)
        smawave_band = str(hostname_smawave).split('\\n')
        smawave_band = smawave_band[4].strip('\\r')
        logging.debug('GTCCINFO: {}'.format(smawave_band))
        smawave_band = smawave_band.split(',')[9]
        logging.debug('SMAWave bandwidth: {}'.format(smawave_band))
        smawave_channel.send('/etc/init.d/comd start\n')
        time.sleep(5)
        self._disconnect()

        if smawave_band == str(bandwidth):
            logging.debug('SMAWave is connected to cell with correct Bandwidth')
        else:
            logging.error('SMAWave is connected to cell with incorrect Bandwidth')
            raise IncorrectBandwidth

    def _connect_to_uepc(self, uepc_ip, username='pzkrk', passwd='NokiaBts2003', alias='signature_check'):
        self.ssh.connect_to(hostname=uepc_ip, username=username, password=passwd, alias=alias)
        logging.debug('Connection to UEPC has been established')

    def _connect_to_smawave(self, smawave_ip='192.168.1.1', password='Js0Bf7Lq8Gk2', username='root',
                            perform_reboot=False, key_algorithm=None, alias='signature_check'):
        logging.debug('Connecting to SMAWave')
        connection = self.ssh.get_connection_by_alias(alias)
        channel = connection.invoke_shell()

        if perform_reboot:
            channel = self._reboot_smawave(channel, smawave_ip, password, username, key_algorithm)
            time.sleep(5)

        if password is not None:
            passwd = ''.join((password, '\n'))

        if key_algorithm is not None:
            channel.send('ssh {} {}@{}\n'.format(key_algorithm, username, smawave_ip))
        else:
            channel.send('ssh {}@{}\n'.format(username, smawave_ip))

        time.sleep(5)
        hostname = channel.recv(65536)

        if 'Are you sure you want to continue connecting (yes/no)' in str(hostname):
            channel.send('yes\n')
            hostname = channel.recv(65536)
            logging.debug(str(hostname))

        if password is not None:
            channel.send(passwd)
            time.sleep(5)
            hostname = channel.recv(65536)
            logging.debug(str(hostname))

        smawave_core_ip = self._get_smawave_ip(channel)
        channel = self._kill_firewall(channel)
        logging.debug('Connection to SMAWave has been established')
        return (channel, smawave_core_ip)

    def _run_putty(self, appserver_ip, port=22, username='5g', password='5g', alias='signature_check',
                   ssh_method='plink'):
        logging.debug('Setting AppServer via Putty')
        connection = self.ssh.get_connection_by_alias(alias)
        channel = connection.invoke_shell()

        if ssh_method == 'plink':
            channel.send('plink {}@{} -P {}\n'.format(username, appserver_ip, port))

        elif ssh_method == 'ssh':
            channel.send('ssh {}@{} -P {}\n'.format(username, appserver_ip, port))

        else:
            logging.error('SSH method is not correct')
            self._disconnect_on_fail()
            raise SshMethodError

        if password is not None:
            passwd = ''.join((password, '\n'))

        time.sleep(5)
        hostname = channel.recv(65536)
        logging.debug('Ssh to AppServer via Putty')
        logging.debug(str(hostname))

        if password is not None:
            channel.send(passwd)
            time.sleep(5)
            hostname = channel.recv(65536)
            logging.debug('Password send')
            logging.debug(str(hostname))

        if 'Press Return to begin session.' in str(hostname):
            channel.send('\n')
            hostname = channel.recv(65536)
            logging.debug('Press return to begin session visible')

        return channel

    def _verify_and_close_putty_tput_port(self, channel, port, username):
        channel.send('ps aux | grep {}\n'.format(port))
        time.sleep(5)
        hostname = str(channel.recv(65536)).split('\\n')

        for item in hostname:
            item = re.sub("\\s\\s+", " ", item)

            if str(port) in item and username in item:
                channel.send('kill -9 {}\n'.format(item.split()[1]))
                time.sleep(2)

        return channel

    def _get_smawave_ip(self, channel):
        channel.send('ip addr show | grep usb -A5 | grep inet\n')
        time.sleep(5)
        hostname = channel.recv(65536)
        logging.debug('IP:{}'.format(str(hostname)))
        smawave_ip = re.search(r"inet (.*?) scope", str(hostname))

        try:
            smawave_ip = smawave_ip.group(1).split('/')[0]
        except AttributeError:
            logging.error('SMAWave is not connected to a core network')
            raise IpError

        return smawave_ip

    def _kill_firewall(self, channel):
        logging.debug('Stop Firewall on SMAWave')
        channel.send('/etc/init.d/firewall start\n')
        time.sleep(5)
        channel.send('/etc/init.d/firewall stop\n')
        time.sleep(5)
        hostname = channel.recv(65536)
        return channel

    def _reboot_smawave(self, channel, smawave_ip, password, username, key_algorithm, timeout=250):
        logging.debug('Perform Reboot of SMAWave')

        if password is not None:
            passwd = ''.join((password, '\n'))

        if key_algorithm is not None:
            channel.send('ssh {} {}@{}\n'.format(key_algorithm, username, smawave_ip))
        else:
            channel.send('ssh {}@{}\n'.format(username, smawave_ip))

        time.sleep(5)
        hostname = channel.recv(65536)
        logging.debug(str(hostname))

        if 'Are you sure you want to continue connecting (yes/no)' in str(hostname):
            channel.send('yes\n')
            hostname = channel.recv(65536)

        if password is not None:
            channel.send(passwd)
            time.sleep(5)
            hostname = channel.recv(65536)

        login_output = str(hostname).split('\\n')
        logging.debug(str(hostname))

        if 'root@OpenWrt' in login_output[-1]:
            channel.send('reboot\n')
        else:
            logging.error('Login to SMAWave failed')
            self._disconnect_on_fail()
            raise SMAWaveLoginFailed

        while timeout > 0:
            timeout -= 25
            channel.send('ping {}\n'.format(smawave_ip))
            time.sleep(25)
            hostname = channel.recv(65536)
            logging.debug(str(hostname))

            if 'Write failed: Connection reset by peer' in str(hostname) or 'Connection to {} closed by remote host'.\
                    format(smawave_ip) in str(hostname) or 'Read from remote host {}: Connection reset by peer'.\
                    format(smawave_ip) in str(hostname) or 'Connection reset by peer' in str(hostname):
                break

        while timeout > 0:
            timeout -= 25
            channel.send('ping {}\n'.format(smawave_ip))
            logging.debug('sleep 25s\n\n')
            time.sleep(25)
            logging.debug('hostname recv\n\n')
            hostname = channel.recv(65536)
            logging.debug(str(hostname))

            if 'Reply from {}: bytes=32'.format(smawave_ip) in str(hostname):
                logging.debug('Connection is restored')
                break

        if timeout <= 0:
            logging.debug('Connection has not beed restored')
            self._disconnect_on_fail()
            raise SMAWaveConnectionFailed

        return channel

    def _disconnect(self, alias='signature_check'):
        self.ssh.disconnect(connection=alias)

    def _disconnect_on_fail(self, alias='signature_check'):
        try:
            self.ssh.disconnect(connection=alias)
        except Exception as e:
            logging.error(e)

    def _verify_tput(self, throughput, tput_expected, deviation, protocol, parallel_streams=1, duration=None):
        output = []
        to_verify = {'Gbits/sec': 1000,
                     'Gbits/sec\\r': 1000,
                     'Gbits/sec\\r\\r': 1000,
                     'Mbits/sec': 1,
                     'Mbits/sec\\r': 1,
                     'Mbits/sec\\r\\r': 1,
                     'Kbits/sec': 1/1000,
                     'Kbits/sec\\r': 1/1000,
                     'Kbits/sec\\r\\r': 1/1000,
                     'bits/sec': 1/1000000,
                     'bits/sec\\r': 1/1000000,
                     'bits/sec\\r\\r': 1/1000000}

        for line in throughput:
            logging.debug('TPUT: {}'.format(line))
            line = re.sub("\\s\\s+", " ", line)
            line = line.split(' ')

            for key, value in to_verify.items():
                if protocol.lower() == 'tcp':
                    if key in line and '[SUM]' in line and parallel_streams != 1:
                        index = line.index(key)
                        logging.debug('value {}'.format(float(line[index-1]) * value))
                        output.append(float(line[index-1]) * value)
                    elif key in line and parallel_streams == 1:
                        index = line.index(key)
                        output.append(float(line[index-1]) * value)
                elif protocol.lower() == 'udp':
                    if key in line:
                        index = line.index(key)
                        output.append(float(line[index-1]) * value)

        if len(output) == 0:
            logging.error('There were no Throughput during testrun')
            self._disconnect_on_fail()
            raise ThroughputNotAvailable

        if duration is not None:
            while len(output) - duration > 0:
                output.pop()

        average_tput = mean(output)
        tput_expected = float(tput_expected)
        deviation_top = tput_expected + tput_expected * float(deviation.strip('%'))/100
        deviation_bottom = tput_expected - tput_expected * float(deviation.strip('%'))/100
        logging.debug('Average tput is: {}'.format(average_tput))

        if deviation_bottom <= average_tput <= deviation_top:
            return True
        else:
            return False


class ThroughputNotAsExpected(Exception):
    pass


class TrafficNotBreak(Exception):
    pass


class SMAWaveConnectionFailed(Exception):
    pass


class SMAWaveLoginFailed(Exception):
    pass


class ThroughputNotAvailable(Exception):
    pass


class ProtocolError(Exception):
    pass


class IncorrectBandwidth(Exception):
    pass


class IpError(Exception):
    pass


class IperfVersionError(Exception):
    pass


class SshMethodError(Exception):
    pass
