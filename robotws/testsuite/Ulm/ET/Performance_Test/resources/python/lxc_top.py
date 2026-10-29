# Collect Top Threads and plot
#  Pre-req: robotws must be in python path
#  to start
#      source /home/ute/DEVELOPMENT/env_activate
#      python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/lxc_top.py
#          --containers'0x1734,0x1735' --filter 'cp_ue|cp_sb'
#
#  to end
#      source /home/ute/DEVELOPMENT/env_activate
#      python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/lxc_top.py
#          --containers '0x1734,0x1735' --end
#

import argparse
import traceback
import logging
import plotly
import importlib

import numpy as np
import pandas as pd

from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper

logger = logging.getLogger(__name__)


def start_lxc_top(containers, target_dir, subfolder='', hw='gnb', filter='cp_ue|cp_sb', csv=True,
                  connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                  timeout=None):
    containers_arr = containers.split(',')
    for container in containers_arr:
        logger.info(f'[LXC-1:0.{hw}] {container} start_lxc_top')
        filename = f'top_threads_output_{hw}_{container}.txt'
        taf_transport_ssh_wrapper.execute(
            f"kill $(pgrep -f ^ssh.*{hw}.*lxc-attach.*{container}.* | tr -s '\\n ' ' ')",
            connection=connection, timeout=timeout)
        taf_transport_ssh_wrapper.execute(
            f"mkdir -p {target_dir}/{subfolder}",
            connection=connection, timeout=timeout)
        cmd = f"ssh -q 1:0.{hw} 'lxc-attach -n {container} -- bash -c \"top -H -d 1 -b\"'"
        if csv:
            header = "TIME,PID,USER,PR,NI,VIRT,RES,SHR,S,%CPU,%MEM,TIME+,COMMAND"
            taf_transport_ssh_wrapper.execute(
                f"echo \"{header}\" > {target_dir}/{subfolder}/{filename}",
                connection=connection, timeout=timeout)
            awk = '{print strftime("%Y-%m-%d-%H:%M:%S", systime()), $0}'
            cmd = f"{cmd} | awk '/{filter}/ {awk}' | tr -s ' ' ','"
        taf_transport_ssh_wrapper.send_command(f"nohup {cmd} >> {target_dir}/{subfolder}/{filename} 2>&1 &",
                                               connection=connection)


def stop_lxc_top(containers, target_dir, subfolder='', hw='gnb',
                 connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                 timeout=None):
    containers_arr = containers.split(',')
    for container in containers_arr:
        logger.info(f'[LXC-1:0.{hw}] {container} stop_lxc_top')
        filename = f'top_threads_output_{hw}_{container}.txt'
        cmd = f"kill $(pgrep -f ^ssh.*{hw}.*lxc-attach.*{container}.* | tr -s '\\n ' ' ')"
        logger.info(cmd)
        taf_transport_ssh_wrapper.execute(
            cmd,
            connection=connection, timeout=timeout)
        try:
            top_thread_to_plot(f"{target_dir}/{subfolder}/{filename}",
                               f"{target_dir}/{subfolder}", prefix=f"{container}_")
        except TypeError as e:
            logger.error(f"e={e}\n{traceback.format_exc()}")


def top_thread_to_plot(file_path, target, prefix=''):
    logger.info(f'top_thread_to_plot: {file_path}')
    np.bool8 = np.bool_
    pd.options.plotting.backend = "plotly"
    df = pd.read_csv(file_path)
    df = df.drop(columns=['USER', 'PR', 'NI',
                 'VIRT', 'RES', 'SHR', 'S', 'TIME+'])
    df = df.dropna()
    df['command_pid'] = df['COMMAND'].astype(
        str) + '_' + df['PID'].astype(int).astype(str)
    df = df.set_index(['TIME', 'command_pid'])
    df = df.drop(columns=['PID', 'COMMAND'])
    fig = df.groupby('TIME').sum().plot()
    fig.update_layout(xaxis_title="Time",
                      yaxis_title="Usage (%)", legend_title="All Process")
    all_cmd = f'{target}/top_threads_plot_{prefix}all.html'
    result = plotly.offline.plot(fig, filename=all_cmd, auto_open=False)
    files = [result]
    for command in df.index.get_level_values('command_pid').unique():
        fname = command.replace('/', '_')
        file = f'{target}/top_threads_plot_{prefix}{fname}.html'
        fig = df.loc[(slice(None), command), :].groupby('TIME').sum().plot()
        fig.update_layout(xaxis_title="Time",
                          yaxis_title="Usage (%)", legend_title=command)
        result = plotly.offline.plot(fig, filename=file, auto_open=False)
        files.append(result)
    return files


def main():
    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=logging.INFO
    )
    parser = argparse.ArgumentParser(description='lxc_top.py')
    parser.add_argument('--end', action='store_true')
    parser.add_argument('--containers', default='0x1734,0x1735')
    parser.add_argument('--target_dir', default='/tmp/')
    parser.add_argument('--subfolder', default='lxc_top')
    parser.add_argument('--hw', default='gnb')
    parser.add_argument('--filter', default='cp_ue|cp_sb')  # cp_ue|cp_sb
    parser.add_argument('--not_csv',  action='store_true')
    args = parser.parse_args()

    taf_transport_ssh_wrapper.ssh_connect()
    if not args.end:
        start_lxc_top(args.containers, args.target_dir, subfolder=args.subfolder, hw=args.hw, filter=args.filter,
                      csv=not args.not_csv,
                      connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                      timeout=None)
    else:
        stop_lxc_top(args.containers, args.target_dir, subfolder=args.subfolder, hw=args.hw,
                     connection=taf_transport_ssh_wrapper.CONST_CORE_ALIAS,
                     timeout=None)


if __name__ == "__main__":
    main()
