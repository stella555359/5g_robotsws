# Collect Flame Graphs
#
#  to start
#      source /home/ute/DEVELOPMENT/env_activate
#      python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/perf_script.py
#          --containers'0x1734,0x1735' --pidof 'cp_ue'
#
#  to end
#      source /home/ute/DEVELOPMENT/env_activate/home/ute/DEVELOPMENT/env_activate
#      python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/perf_script.py
#          --containers '0x1734,0x1735' --end
#

import argparse
import logging
from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper


logger = logging.getLogger(__name__)
flame_graph_path = '/home/ute/DEVELOPMENT/FlameGraph'


def start_perf_script(containers, hw='gnb',
                      pidof='cp_ue', connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                      timeout=None):
    containers_arr = containers.split(',')
    for container in containers_arr:
        logger.info(f'[LXC-1:0.{hw}] {container} Start Perf Script')
        filename = f'perf_cpue_{hw}_{container}'
        cmd = "pid=$(ssh -q 1:0.{} \"lxc-attach -n {} -- pidof {} | {}\");".format(
            hw,
            container,
            pidof,
            "awk '{ print $1 }'"
        )
        cmd = "{} ssh 1:0.{} \"lxc-attach -n {} -- bash -c".format(
            cmd, hw, container)
        cmd = "{} 'perf record --freq=8000 -p {} -o {}.out --call-graph dwarf,65528 sleep 2' \"".format(
            cmd, "${pid}", filename)
        ret = taf_transport_ssh_wrapper.execute(
            cmd, connection=connection, timeout=timeout)
        logger.info(cmd)
        logger.info(ret)


def stop_perf_script(containers, target_dir, subfolder='', hw='gnb',
                     connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                     timeout=None):
    containers_arr = containers.split(',')
    for container in containers_arr:
        logger.info(f'[LXC-1:0.{hw}] {container} Stop Perf Script')
        filename = f'perf_cpue_{hw}_{container}'
        cmd = "ssh 1:0.{hw} \"lxc-attach -n {container} -- bash -c '{script}'\" &&".format(
            hw=hw,
            container=container,
            script=f'perf script --input={filename}.out > /ffs/run/logs/{filename}.txt'
        )
        cmd = "{cmd} scp 1%0.{hw}:/ffs/run/logs/{filename}.txt {target_dir}/{subfolder}/{filename}.txt".format(
            cmd=cmd,
            hw=hw,
            filename=filename,
            target_dir=target_dir,
            subfolder=subfolder
        )
        ret = taf_transport_ssh_wrapper.execute(
            f"mkdir -p {target_dir}/{subfolder}", connection=connection, timeout=timeout)
        ret = taf_transport_ssh_wrapper.execute(
            cmd, connection=connection, timeout=timeout)
        logger.info(cmd)
        logger.info(ret)
        generate_flame_graph(
            f"{target_dir}/{subfolder}/{filename}.txt", connection=connection)
        logger.info(f"generated: {target_dir}/{subfolder}/{filename}.txt")


def generate_flame_graph(perf_file, connection):
    logger.info("generating flame graph")
    ret = taf_transport_ssh_wrapper.execute(
        f"{flame_graph_path}/stackcollapse-perf.pl --tid {perf_file} > {perf_file}.collapsed",
        connection=connection,
        timeout=None)
    logger.info(ret)
    ret = taf_transport_ssh_wrapper.execute(
        f"{flame_graph_path}/flamegraph.pl {perf_file}.collapsed > {perf_file}.flamegraph.html",
        connection=connection,
        timeout=None)
    logger.info(ret)


if __name__ == "__main__":
    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=logging.INFO
    )
    parser = argparse.ArgumentParser(description='perf_script.py')
    parser.add_argument('--end', action='store_true')
    parser.add_argument('--containers', default='0x1734,0x1735')
    parser.add_argument('--target_dir', default='/tmp/')
    parser.add_argument('--subfolder', default='perf_script')
    parser.add_argument('--pidof', default='cp_ue')
    parser.add_argument('--hw', default='gnb')
    args = parser.parse_args()

    taf_transport_ssh_wrapper.ssh_connect()
    if not args.end:
        start_perf_script(args.containers, hw=args.hw,
                          pidof=args.pidof, connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                          timeout=None)
    else:
        stop_perf_script(args.containers, target_dir=args.target_dir, subfolder=args.subfolder, hw=args.hw,
                         connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                         timeout=None)
