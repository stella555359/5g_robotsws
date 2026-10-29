
import argparse
import logging
from pathlib import Path
import plotly

import numpy as np
import pandas as pd

from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper

logger = logging.getLogger(__name__)


def start_cpu_usage(hostname, username, password,
                    target=str(Path.home() / "Downloads"),
                    alias=taf_transport_ssh_wrapper.CONST_CORE_ALIAS, proxy=None, force=False):
    taf_transport_ssh_wrapper.ssh_connect(hostname=hostname, username=username, password=password,
                                          alias=alias, proxy=proxy, force=force)
    header = r"TIME,CPU,%usr,%nice,%sys,%iowait,%irq,%soft,%steal,%guest,%gnice,%idle"
    taf_transport_ssh_wrapper.execute(
        f"echo \"{header}\" > {target}/cpu_usage.txt",
        connection=alias, timeout=5)
    bash_cmd = "mpstat 1 -P ALL | grep -v -e '^[[:space:]]*$' | grep -v CPU | tr -s ' ' ','"
    cmd = f"export S_TIME_FORMAT='ISO'; nohup {bash_cmd} >> {target}/cpu_usage.txt &"
    logger.debug(cmd)
    return taf_transport_ssh_wrapper.send_command(cmd, connection=alias, timeout=5)


def stop_cpu_usage(hostname, username, password, target=str(Path.home() / "Downloads"),
                   alias=taf_transport_ssh_wrapper.CONST_CORE_ALIAS, proxy=None, force=False):
    taf_transport_ssh_wrapper.ssh_connect(hostname=hostname, username=username, password=password,
                                          alias=alias, proxy=proxy, force=force)
    taf_transport_ssh_wrapper.execute(
        "pkill mpstat && sleep 2", connection=alias, timeout=5)
    return f"{target}/cpu_usage.txt"


def get_df(input):
    df = pd.read_csv(input)
    df[r'%usage'] = 100 - df[r'%idle'].astype(float)
    df = df.drop(columns=[r"%idle"])
    df = df.dropna()
    return df


def check_cpu_usage(df, threshold=90):
    cpu_dict = {}
    for cpu in df.set_index(["TIME", "CPU"]).index.get_level_values('CPU').unique():
        filtered_df = df[df['CPU'] == cpu]
        for _, row in filtered_df.iterrows():
            if float(row[r'%usage']) > float(threshold):
                cpu_dict.update({
                    cpu: row
                })
    return True if 'all' in cpu_dict else cpu_dict


def to_plot(df, target):
    np.bool8 = np.bool_
    pd.options.plotting.backend = "plotly"
    df = df.set_index(["TIME", "CPU"])
    files = []
    for cpu in df.index.get_level_values('CPU').unique():
        file = f'{target}/cpu_usage_vm_{cpu}.html'
        fig = df.loc[(slice(None), cpu), :].groupby('TIME').sum().plot()
        fig.update_layout(xaxis_title="Time",
                          yaxis_title="Usage (%)", legend_title=cpu)
        files.append(plotly.offline.plot(fig, filename=file, auto_open=False))
    df = df.drop(columns=[r"%usr", r"%nice", r"%sys", r"%iowait",
                 r"%irq", r"%soft", r"%steal", r"%guest", r"%gnice"])
    df = df.pivot_table('%usage', ['TIME'], 'CPU')
    fig = df.groupby('TIME').sum().plot()
    files.append(plotly.offline.plot(
        fig, filename=f'{target}/cpu_usage_vm_summary.html', auto_open=False))
    return files


def main():
    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=logging.INFO
    )
    parser = argparse.ArgumentParser(description='cpu_usage.py')
    parser.add_argument('--end', action='store_true')
    parser.add_argument('--target_dir', default=str(Path.home() / "Downloads"))
    args = parser.parse_args()

    if not args.end:
        logger.info("Start CPU Usage")
        start_cpu_usage("0", "ute", "UTE.debian12")
    else:
        logger.info("Stop CPU Usage")
        result = stop_cpu_usage("0", "ute", "UTE.debian12")
        df = get_df(result)
        logger.info("Check Overload")
        cpu = check_cpu_usage(df)
        logger.info(cpu)
        logger.info("Create Plot")
        plots = to_plot(df, args.target_dir)
        logger.info(plots)


if __name__ == "__main__":
    main()
