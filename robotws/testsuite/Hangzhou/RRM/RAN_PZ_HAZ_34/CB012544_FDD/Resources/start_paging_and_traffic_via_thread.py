# owner: liujia
# time: 1/11/24 1:58 PM

# *-coding=utf-8-*

import threading
import taf.transport.ssh as ssh
import time
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
ute_username = tl.test_pc.default_ssh_connection_details.username
ute_password = tl.test_pc.default_ssh_connection_details.password


class startpagingtraffic:
    def __init__(self):
        pass

    def start_paging_with_simulation(slef, Simulation_IP, paging_command, connection="simulation_pc"):
        sshconn = ssh.ssh()
        connss = sshconn.connect_to(hostname=Simulation_IP,
                                    username=tl.test_pc.default_ssh_connection_details.username,
                                    password=tl.test_pc.default_ssh_connection_details.password,
                                    alias=connection)
        tn = connss.invoke_shell()
        tn.send('telnet 0 20000\n')
        time.sleep(2)
        tn.recv(65535)
        time.sleep(2)
        tn.send('{}\n'.format(paging_command))
        time.sleep(20)
        tn.recv(65535)
        time.sleep(5)
        sshconn.disconnect(connection=connection)

    def start_dl_trafic_on_UTE(self, Simulation_IP, dl_port, ue_addr, dl_time, dl_throughput,
                               dl_length, connection="UTE_pc", timeout=120, iperf_index=2):
        sshconn = ssh.ssh()
        sshconn.connect_to(hostname=Simulation_IP,
                           username=tl.test_pc.default_ssh_connection_details.username,
                           password=tl.test_pc.default_ssh_connection_details.password,
                           alias=connection)
        kill_command = f"ps -ef | grep iperf | grep -v grep | grep {dl_port} | awk '{{print $2}}' | xargs kill -9"
        sshconn.send_command(command=kill_command, connection=connection)
        time.sleep(6)
        # Start iperf process based on protocol
        iperf_command = f"iperf -c {ue_addr} -u -p {dl_port} -l {dl_length}-b {dl_throughput} -i 1 -t {dl_time} &"
        print(iperf_command)
        sshconn.send_command(command=iperf_command, connection=connection)
        time.sleep(10)
        check_command = f"ps -ef | grep iperf |grep {dl_port} |grep -v grep |awk '{{print ${iperf_index}}}'"
        sshconn.send_command(command=check_command, connection=connection, timeout=timeout)
        output = sshconn.read_output(connection=connection)
        iperf_pid = output.strip()
        if not iperf_pid or int(iperf_pid) <= 0:
            raise Exception("iperf process does not exist")
        return iperf_pid

    def start_via_threading(self, Simulation_IP, paging_command, dl_port,
                            ue_addr, dl_time, dl_throughput, dl_length, depart='tput_paging'):
        threads = []
        if depart == 'tput_paging':
            th1 = threading.Thread(target=self.start_dl_trafic_on_UTE,
                                   args=(Simulation_IP, dl_port, ue_addr, dl_time, dl_throughput, dl_length))
            threads.append(th1)
            th2 = threading.Thread(target=self.start_paging_with_simulation,
                                   args=(Simulation_IP, paging_command))
            threads.append(th2)
        for t in threads:
            t.start()
            time.sleep(2)
        for t in threads:
            t.join()


def start_traffic_and_paging(action_mode, Simulation_IP, paging_command, dl_port,
                             ue_addr, dl_time, dl_throughput, dl_length):
    up = startpagingtraffic()
    up.start_via_threading(Simulation_IP, paging_command, dl_port, ue_addr,
                           dl_time, dl_throughput, dl_length, depart=action_mode)


def start_traffic_via_simulator(Simulation_IP, dl_port, ue_addr, dl_time,
                                dl_throughput, dl_length):
    st = startpagingtraffic()
    st.start_dl_trafic_on_UTE(Simulation_IP, dl_port, ue_addr, dl_time,
                              dl_throughput, dl_length,)
