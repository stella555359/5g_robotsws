from taf.collectors.tcpdump import tcpdump
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
import os


def start_tcpdump_on_test_pc(interface, option=None, collector='tcpdump'):
    testpc_ssh_config = {'host': tl.test_pc.default_ssh_connection_details.addr,
                         'user': tl.test_pc.default_ssh_connection_details.username,
                         'password': tl.test_pc.default_ssh_connection_details.password}
    options = '-i {interface} {option}'.format(interface=interface, option=option)
    tcpdump_collector = tcpdump()
    tcpdump_collector.create_tcpdump_collector(name=collector, options=options, executor=testpc_ssh_config)
    tcpdump_collector.setup_collectors(names=collector)
    tcpdump_collector.start_collectors(names=collector)
    tcpdump_collector.set_suite_alias(collector)
    return collector


def stop_tcpdump_on_test_pc(collector='tcpdump', target_dir='tcpdump'):
    tcpdump_collector = tcpdump()
    tcpdump_collector.stop_collectors(names=collector)
    tcpdump_collector.collect_collectors(names=collector, target_dir=target_dir)
    tcpdump_collector.teardown_collectors(names=collector)
    return os.path.join(target_dir, collector, collector + '.pcap')
