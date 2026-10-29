"""
TODO: Documentation
"""

import argparse
import datetime
import pathlib
import json
import logging

import pandas as pd

from testsuite.Ulm.resources.Common.python.ltepat import ltepat_setup
from testsuite.Ulm.resources.Common.python.ltepat import ltepat_run

from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper as sshw

logger = logging.getLogger(__name__)
OAM_CONNECT_RETRY = 3


def install():
    ltepat_setup.install_lte_pat()


def run_ltepat(pi_dirs: list,
               remote_ip: str = None,
               conversion_options: dict = None,
               runtime_options: dict = None,
               log_dir: str = None,
               ltepat_pm_dir: str = None,
               release: str = None) -> list:
    if ltepat_pm_dir is None:
        ltepat_pm_dir = pathlib.Path.home().joinpath("ltepat/rel/Flexi/PM")
    if log_dir is None:
        current_time = datetime.datetime.now().strftime(r'%Y%m%d_%H%M%S')
        log_dir = pathlib.Path.home().joinpath("Downloads", f"ltepat_manager_{current_time}")
    log_dir = pathlib.Path(log_dir)
    log_dir.mkdir(parents=True, exist_ok=True)
    logger.debug("ltepat log dir: %s", str(log_dir))
    if release is None:
        try:
            with sshw.oam_http_session_context(remote_ip=remote_ip, retries=OAM_CONNECT_RETRY) as oam_alias:
                release = sshw.get_admin_obj().get_sw_release_name(connection=oam_alias)
        except sshw.Exc.AdminConnectionError:
            logger.exception("sshw.Exc.AdminConnectionError")
            return None
    runtime_options_default = {
        '@OutputDirectory': str(log_dir),
        '@PmReleaseFile': f"{str(ltepat_pm_dir)}/PMPegs_{release}_5G.xml",
        '@PmKPIFile': f"{str(ltepat_pm_dir)}/PMKPI_{release}_5G.xml",
    }
    if runtime_options is not None:
        runtime_options_default.update(runtime_options)
    config_path = ltepat_run.create_configuration_file(pm_files=pi_dirs,
                                                       conversion_options=conversion_options,
                                                       runtime_options=runtime_options_default,
                                                       suite_log_dir=str(log_dir))
    ltepat_run.run_ltepat(config_path, f"{log_dir}/ltepat_output.txt")
    return [str(f) for f in log_dir.glob(r"*_PMOutput.xlsx") if f.is_file()]


def get_sys_lvl_kpis_all_to_dict(ltepat_output_excel: str) -> dict:
    df = get_sys_lvl_kpis_all_df(ltepat_output_excel)
    return df_to_dictionary(df)


def get_kpis_all_to_dict(ltepat_output_excel, inactive_cells: list = None, pm_time=None, index=-1, ignore_zero=True):
    """
    returns
        {
            '< KPI ID: str >': {
                'name': < str >,
                'description': < str >,
                'distnames': {
                        < distname: str > :  < INT >
                    }
                }
            },
            ...
            ...
        }
    """
    try:
        df = get_kpis_all_df(ltepat_output_excel, pm_time=pm_time, index=index)
    except Exc.UnexpectedFormat:
        logger.error("LTEPat UnexpectedFormat: \n%s", ltepat_output_excel)
        return None
    if inactive_cells:
        df = remove_inactive_cells(df, inactive_cells)
    return df_to_dictionary(df, ignore_zero=ignore_zero)


def remove_inactive_cells(df, cells):
    if cells is not None:
        for cell in cells:
            try:
                df = df[~df['localMoid'].str.contains(f"NRCELL-{cell}")]
            except KeyError as e:
                logger.debug("KeyError, remove_inactive_cells: %s", e)
    return df


def get_sys_lvl_kpis_all_df(ltepat_output_excel):
    try:
        df = pd.read_excel(ltepat_output_excel, sheet_name='KPIs_All')
    except ValueError as e:
        raise Exc.KpiSheetNotFound from e
    df = df[df['StartDate'] == 'System Level']
    df = df.drop(columns=['StartDate', 'StartTime', 'baseId', 'cellId'])
    df = df.dropna(subset=['localMoid'])
    df = df.T
    return df


def get_kpis_all_df(ltepat_output_excel, pm_time=None, index=-1):
    try:
        df = pd.read_excel(ltepat_output_excel, sheet_name='KPIs_All')
    except ValueError as e:
        raise Exc.KpiSheetNotFound from e
    df = df.drop(df[df.StartDate == 'System Level Average'].index)
    df = df.drop(df[df.StartDate == 'System Level'].index)
    df = df.drop(df[df.StartDate.isna()].index)
    try:
        pm_time = df['StartTime'].iloc[index] if pm_time is None else datetime.datetime.strptime(
            pm_time, '%H:%M:%S').time()
    except IndexError as e:
        raise Exc.UnexpectedFormat from e
    df = df.loc[df['StartTime'] == pm_time]
    df = df.drop(columns=['StartDate', 'StartTime', 'baseId', 'cellId'])
    df = df.dropna(axis=1, how='all')
    # df = df[~df['localMoid'].str.contains("NRCELL-[0-9]+$")]
    df = df.T
    return df


def get_cell_level_df(ltepat_output_excel, pm_time=None, index=-1):
    try:
        df = pd.read_excel(ltepat_output_excel, sheet_name='KPIs_CellLevel')
    except ValueError as e:
        raise Exc.KpiSheetNotFound from e
    df = df.drop(df[df.StartDate == 'System Level Average'].index)
    df = df.drop(df[df.StartDate == 'System Level'].index)
    df = df.drop(df[df.StartDate.isna()].index)
    pm_time = df['StartTime'].iloc[index] if pm_time is None else datetime.datetime.strptime(
        pm_time, '%H:%M:%S').time()
    df = df.loc[df['StartTime'] == pm_time]
    df = df.drop(columns=['StartDate', 'StartTime', 'baseId', 'CellId'])
    df = df.dropna(axis=1, how='all')
    df = df.T
    return df


def all_to_all_to_dictionary(ltepat_output_excel, pm_time=None, index=-1):
    kpis_all_df = get_kpis_all_df(ltepat_output_excel, pm_time=pm_time, index=index)
    cell_level_df = get_cell_level_df(ltepat_output_excel, pm_time=pm_time, index=index)
    return {
        'kpis_all': df_to_dictionary(kpis_all_df),
        'cell_level': df_to_dictionary(cell_level_df)
    }


def add_mean(df):
    df = df.T
    try:
        df = df.set_index(["localMoid"])
        df.loc['mean'] = df.astype(float).mean()
    except KeyError as e:
        logger.error("KeyError, add_mean: %s", e)
    return df.T


def df_to_dictionary(df, ignore_zero=True):
    """
    returns
        {
            '< KPI Name: str >': {
                'name': < str >,
                'description': < str >,
                'distnames': {
                        < distname: str > :  < INT >
                    }
                }
            },
            ...
            ...
        }
    """
    df = add_mean(df)
    df = df.replace({float('nan'): None})
    py_dict = df.to_dict(orient='index')
    py_dict2 = {}
    for kpifull, distnames_dict in py_dict.items():
        mean = distnames_dict.get("mean", None)
        if mean is None or (float(mean) == 0.0 and ignore_zero):
            continue
        key_sp = kpifull.split(' ', maxsplit=1)
        kpi_code = key_sp[0]
        kpi_name = key_sp[1]
        distnames = {}
        for distname, value in distnames_dict.items():
            if value is not None:
                distnames.update({
                    distname: value
                })
        py_dict2.update({
            kpi_code.lower(): {
                "distnames": distnames,
                "name": kpi_name,
                "description": "TBA"
            }
        })
    return py_dict2


class Exc:

    class UnexpectedFormat(Exception):
        pass

    class KpiSheetNotFound(Exception):
        pass


if __name__ == "__main__":
    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    # export PYTHONPATH="${PYTHONPATH}:/home/ute/DEVELOPMENT/robotws/"
    # python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/ltepat_manager.py
    parser = argparse.ArgumentParser(description='ltepat_manager.py')
    install()
    parser.add_argument('pi_dirs')
    parser.add_argument('--release', default=None)
    parser.add_argument('--remote_ip', default=None)
    parser.add_argument('--log_dir', default=None)
    parser.add_argument('--ltepat_pm_dir', default=None)
    args = parser.parse_args()
    start_t = datetime.datetime.now()
    ltepat_excel = run_ltepat(args.pi_dirs.split(','),
                              remote_ip=args.remote_ip,
                              log_dir=args.log_dir,
                              ltepat_pm_dir=args.ltepat_pm_dir,
                              release=args.release)
    print(f"ltepat_excel: {ltepat_excel}")
    new_files = []
    for excel in ltepat_excel:
        excel = pathlib.Path(excel)
        kpi_json_file = excel.with_suffix('.json')
        with open(kpi_json_file, 'w', encoding='utf-8') as f:
            json.dump(get_kpis_all_to_dict(str(excel)), f)
        new_files.append(str(kpi_json_file))
    print(f"new_files: {new_files}")
    delta_t = datetime.datetime.now() - start_t
    print(f"total time running: {delta_t}")
