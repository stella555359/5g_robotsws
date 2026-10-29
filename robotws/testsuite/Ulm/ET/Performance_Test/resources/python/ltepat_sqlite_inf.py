"""
TODO: Documentation
"""

import logging
import datetime
import argparse
import json
import pathlib
import prettytable

from testsuite.Ulm.ET.Performance_Test.resources.python import ltepat_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import scripts

from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_retrieve
from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_insert

logger = logging.getLogger(__name__)


def connect_db(database_path) -> bool:
    return (db_interface_retrieve.connect_to_database(database_path) and
            db_interface_insert.connect_to_database(database_path))


def get_kpi_comparison_dictionary_from_db(kpi_current: dict, testcase_id: int) -> dict:
    _kpi_dictionary_db = get_kpi_dictionary(testcase_id)
    return get_kpi_comparison_dictionary(kpi_current, _kpi_dictionary_db)


def format_cmp_dict_as_table(kpi_comparison: dict) -> str:
    if str(kpi_comparison).lower().rstrip() in ['', 'none']:
        return
    headers = ['kpi', 'current', 'previous', 'difference', 'percent']
    kpitable = prettytable.PrettyTable(headers)
    for kpiname, data in kpi_comparison.items():
        dn = data['distnames']
        if 'mean' in dn:
            current = scripts.try_round(dn['mean']['current'], 1)
            previous = scripts.try_round(dn['mean']['previous'], 1)
            difference = scripts.try_round(dn['mean']['difference'], 1)
            percent = f"{scripts.try_round(dn['mean']['percent'])} %"
            kpitable.add_row([kpiname, current, previous, difference, percent])
    kpitable.align = "r"
    kpitable.sortby = "kpi"
    return str(kpitable)


def get_kpi_dictionary(testcase_id: int) -> dict:
    """
    returns
    '< KPI Name: str >': {
            'distnames': {
                    < distname: str > : {
                        'current': < INT >,
                        'previous': < INT >,
                        'difference': < FLOAT >,
                        'percent': < FLOAT >,
                    }
                }
            }
        },
        ...
        ...
    """
    rows = db_interface_retrieve.get_kpi(
        testcase_id, kpi_name=None, kpi_distname=None, limit=0)
    # row : tcid, tcname, dt, kpi_name, distname, value
    kpi_dictionary = {}
    for _, _, _, kpi_name, distname, value in rows:
        if kpi_name not in kpi_dictionary:
            kpi_dictionary[kpi_name] = {"distnames": {}}
        kpi_dictionary[kpi_name]["distnames"].update({
            distname: value
        })
    return kpi_dictionary


def get_kpi_comparison_dictionary(kpi_current: dict, kpi_db: dict) -> dict:
    """
    returns
        {
            '< KPI Name: str >': {
                'name': < str >,
                'description': < str >,
                'distnames': {
                        < distname: str > : {
                            'current': < INT >,
                            'previous': < INT >,
                            'difference': < FLOAT >,
                            'percent': < FLOAT >,
                        }
                    }
                }
            }
        },
        ...
        ...
    """
    if kpi_current in [{}, None]:
        return {}
    if kpi_db in [{}, None]:
        return {}
    kpi_comparassion_dictionary = {}
    for kpi_name, kpi_data in kpi_current.items():
        distnames = {}
        kpi_data_db = kpi_db.get(kpi_name, {"distnames": {}})['distnames']
        for distname, value in kpi_data['distnames'].items():
            try:
                previous_value = kpi_data_db.get(distname, None)
                previous_value = float(previous_value)
            except TypeError:
                logger.debug("TypeError [%s] (%s) %s", kpi_name, distname, previous_value)
                previous_value = None
            except ValueError:
                logger.debug("ValueError [%s] (%s) %s", kpi_name, distname, previous_value)
                previous_value = None
            difference = (value-previous_value) if previous_value else None
            if previous_value not in ["0", 0, None]:
                percent = round(((difference)/previous_value)*100)
            else:
                percent = None
            distnames.update({
                distname: {
                    'current': value,
                    'previous': previous_value,
                    'difference': difference,
                    'percent': percent,
                }
            })
        kpi_comparassion_dictionary.update({
            kpi_name: {
                "name": kpi_data["name"],
                "distnames": distnames
            }
        })
    return kpi_comparassion_dictionary


if __name__ == "__main__":
    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    # export PYTHONPATH="${PYTHONPATH}:/home/ute/DEVELOPMENT/robotws/"
    # python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/ltepat_sqlite_inf.py
    parser = argparse.ArgumentParser(description='ltepat_sqlite_inf.py')
    ltepat_manager.install()
    parser.add_argument('pi_dirs')
    parser.add_argument('--tcid')
    parser.add_argument('--release', default=None)
    parser.add_argument('--remote_ip', default=None)
    parser.add_argument('--log_dir', default=None)
    parser.add_argument('--ltepat_pm_dir', default=None)
    parser.add_argument(
        '--db', default='/mnt/etlogs/logs/performance/02_database/performance.sqlite3')
    parser.add_argument('--index', default='-1')
    args = parser.parse_args()
    connect_db(args.db)
    start_t = datetime.datetime.now()
    if '.xlsx' in args.pi_dirs:
        ltepat_excel = args.pi_dirs.split(',')
    else:
        ltepat_excel = ltepat_manager.run_ltepat(args.pi_dirs.split(','),
                                                 remote_ip=args.remote_ip,
                                                 log_dir=args.log_dir,
                                                 ltepat_pm_dir=args.ltepat_pm_dir,
                                                 release=args.release)
    print(f"pm_files: {ltepat_excel}")
    new_files = []
    for excel in ltepat_excel:
        excel = pathlib.Path(excel)
        json_file = excel.with_suffix('.json')
        kpi_cur = ltepat_manager.get_kpis_all_to_dict(str(excel), index=int(args.index))
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(kpi_cur, f)

        kpi_dictionary_db = get_kpi_dictionary(args.tcid)
        with open(json_file.with_name(f"db_tcid_{args.tcid}.json"), 'w', encoding='utf-8') as f:
            json.dump(kpi_dictionary_db, f)

        kpi_comparison_dictionary = get_kpi_comparison_dictionary(kpi_cur, kpi_dictionary_db)
        print(format_cmp_dict_as_table(kpi_comparison_dictionary))
        with open(json_file.with_name(f"{json_file.name}_db_tcid_{args.tcid}.json"), 'w', encoding='utf-8') as f:
            json.dump(kpi_comparison_dictionary, f)

        new_files.append(str(json_file))
    print(f"new_files: {new_files}")
    delta_t = datetime.datetime.now() - start_t
    print(f"total time running: {delta_t}")
