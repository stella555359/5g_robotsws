import re
import os
import subprocess
from robot.api import logger

DEFAULT_PORT = '7070'
NAT_GW = '10.0.2.1'


class IperfUtilities(object):
    def __init__(self):
        self.proc_iperf_server = None
        self.proc_iperf_client = None

    def start_iperf(self, client_ip, throughput, duration, iperf_file, server=NAT_GW, port=DEFAULT_PORT):
        base, ext = os.path.splitext(iperf_file)
        server_log = f"{base}_server{ext}"
        client_log = f"{base}_client{ext}"
        server_file = open(server_log, 'w+')
        client_file = open(client_log, 'w+')
        server_cmd = ['iperf', '-s', '-p', str(port), '-i', '1', '-B', server]
        client_cmd = ['iperf', '-c', client_ip, '--trip-times', '-e', '-p', str(port), '-l', '1400',
                      '-b', throughput, '-i', '10', '-t', str(duration), '-B', server]
        print("Running server command:", ' '.join(server_cmd))
        print("Running client command:", ' '.join(client_cmd))
        self.proc_iperf_server = subprocess.Popen(server_cmd, stdout=server_file, universal_newlines=True)
        self.proc_iperf_client = subprocess.Popen(client_cmd, stdout=client_file, universal_newlines=True)
        return self.proc_iperf_server, self.proc_iperf_client

    def start_iperf_L4S(self, client_ip, throughput, duration, iperf_file, server=NAT_GW, port=DEFAULT_PORT):
        base, ext = os.path.splitext(iperf_file)
        server_log = f"{base}_server{ext}"
        client_log = f"{base}_client{ext}"
        server_file = open(server_log, 'w+')
        client_file = open(client_log, 'w+')
        server_cmd = [
            'iperf', '-s', '-p', str(port), '--tcp-congestion', 'prague',
            '-i', '1', '-B', server
        ]
        client_cmd = [
            'iperf', '-c', client_ip, '--tcp-congestion', 'prague',
            '--trip-times', '-e', '-p', str(port), '-l', '1400',
            '-b', throughput, '-i', '10', '-t', str(duration), '-B', server
        ]
        print("Running L4S server command:", ' '.join(server_cmd))
        print("Running L4S client command:", ' '.join(client_cmd))
        self.proc_iperf_server = subprocess.Popen(server_cmd, stdout=server_file, universal_newlines=True)
        self.proc_iperf_client = subprocess.Popen(client_cmd, stdout=client_file, universal_newlines=True)
        return self.proc_iperf_server, self.proc_iperf_client

    def stop_traffic(self, proc_iperf_server, proc_iperf_client):
        proc_iperf_client.kill()
        proc_iperf_server.kill()
        try:
            proc_iperf_client.wait(timeout=3)
            print("Client process killed")
        except subprocess.TimeoutExpired:
            print("Client process did not terminate")
        try:
            proc_iperf_server.wait(timeout=3)
            print("Server process killed")
        except subprocess.TimeoutExpired:
            print("Server process did not terminate")

    def check_average_throughput_is_reached_in_DL(self, throughput, DL_iperf_file):
        downlink_throughput_check = False
        downlink_throughput_check = self.check_throughput(throughput, DL_iperf_file)
        if downlink_throughput_check:
            logger.console('Downlink traffic was successful')
        else:
            raise Exception('Downlink throughput was not reached')

    def check_average_throughput_is_reached_in_UL(self, throughput, UL_iperf_file):
        uplink_throughput_check = False
        uplink_throughput_check = self.check_throughput(throughput, UL_iperf_file)
        if uplink_throughput_check:
            logger.console('Uplink traffic was successful')
        else:
            raise Exception('Uplink throughput was not reached')

    def check_throughput(self, expected_throughput, iperf_file_path):
        counter = 0
        is_tput_reached = False
        no_of_lines_withMbits_per_sec = self.get_line_count(iperf_file_path)
        file = open(iperf_file_path, "r")
        for line in file:
            line_matched = re.search(r'([{0}]+\.\d+)\s+Mbits/sec'.format(expected_throughput), line)
            if bool(line_matched):
                counter += 1
        file.close()
        if counter >= (no_of_lines_withMbits_per_sec - 5):
            is_tput_reached = True
        return is_tput_reached

    def get_line_count(self, iperf_file_path):
        file_open = open(iperf_file_path, "r")
        no_of_lines_withMbits_per_sec = 0
        for line in file_open:
            line_matched = re.search(r'([^\n]+Mbits/sec[^\n]+\n)', line)
            if bool(line_matched):
                no_of_lines_withMbits_per_sec += 1
        return no_of_lines_withMbits_per_sec

    def get_average_bandwidth(self, iperf_file_path):
        print(f"\n=== Processing iperf file: {iperf_file_path} ===")
        with open(iperf_file_path, 'r') as f:
            contents = f.read()
            print(contents)  # print full file contents
            f.seek(0)
        total_bandwidth = 0.0
        count = 0
        with open(iperf_file_path, 'r') as f:
            for line in f:
                if "Mbits/sec" in line:
                    parts = line.strip().split()
                    try:
                        mbits_index = parts.index("Mbits/sec")
                        bandwidth = float(parts[mbits_index - 1])
                        total_bandwidth += bandwidth
                        count += 1
                    except (ValueError, IndexError):
                        continue
        return total_bandwidth / count if count > 0 else None

    def check_average_latency_is_reached(self, latency, iperf_file_path):
        rtt_values = []
        pattern = re.compile(r"\s([\d]+)K/([\d]+)\(([\d]+)\)\s+us")

        with open(iperf_file_path, 'r') as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    try:
                        rtt_us = int(match.group(2))
                        rtt_values.append(rtt_us)
                    except ValueError:
                        continue

        if not rtt_values:
            print("No latency/RTT values found in the file.")
            return False

        avg_rtt = sum(rtt_values) / len(rtt_values)
        print(f"Average latency/RTT: {avg_rtt:.2f} µs")
        return avg_rtt < float(latency)
