
import argparse
import logging
import pathlib
import json
import prettytable
from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_retrieve
from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_insert

from testsuite.Ulm.ET.Performance_Test.resources.python import pmcounter_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import scripts


logger = logging.getLogger(__name__)


def connect_db(db_path):
    return (
        db_interface_insert.connect_to_database(db_path) and
        db_interface_retrieve.connect_to_database(db_path)
    )


def get_pm_counter_comparison_dictionary_from_db(pm_counters, prev_testcase_id):
    pm_counters_db = get_pm_counters_from_db(prev_testcase_id)
    return get_pm_counter_comparison_dictionary(pm_counters, pm_counters_db)


def format_cmp_dict_as_table(pm_counter_comparison_dictionary: dict) -> str:
    if str(pm_counter_comparison_dictionary).lower().rstrip() in ['', 'none']:
        return
    headers = ['pmcounter', 'current', 'previous', 'difference', 'percent']
    pm_table = prettytable.PrettyTable(headers)
    for pmname, data in pm_counter_comparison_dictionary.items():
        dn = data['distnames']
        if 'mean' in dn:
            current = scripts.try_round(dn['mean']['current'], 1)
            previous = scripts.try_round(dn['mean']['previous'], 1)
            difference = scripts.try_round(dn['mean']['difference'], 1)
            percent = f"{scripts.try_round(dn['mean']['percent'])} %"
            pm_table.add_row([pmname, current, previous, difference, percent])
    pm_table.align = "r"
    pm_table.sortby = "pmcounter"
    return str(pm_table)


def get_pm_counters_from_db(prev_testcase_id):
    """
    returns
        {
            '< pmcounter Name: str >': {
                'testname': < str >,
                'testdate': < str >,
                'testcase_id': < str >,
                'distnames': {
                        < distname: str > : < INT >,
                        ...
                    }
                }
            }
        },
        ...
        ...
    """
    dictionary = {}
    logger.debug("db_interface_retrieve start")
    rows = db_interface_retrieve.get_pmcounter(prev_testcase_id, piid_name=None, distname=None, limit=0)
    if rows is None:
        return dictionary
    logger.debug("db_interface_retrieve end")
    for testcase_id, testname, testdate, piid_name, piid_value, distname in rows:
        if piid_name not in dictionary:
            dictionary[piid_name] = {
                "testname": testname,
                "testdate": testdate,
                "testcase_id": testcase_id,
                "distnames": {}
                }
        dictionary[piid_name]["distnames"].update({
            distname: piid_value
        })
    return dictionary


def get_pm_counter_comparison_dictionary(pm_counters, pm_counters_db):
    """
    returns
        {
            '< piid_name : str >': {
                'name': < str >,
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
    dictionary = {}
    for piid_name, data in pm_counters.items():
        distnames = {}
        pm_counters_db_data = pm_counters_db.get(piid_name, {"distnames": {'mean': None}})['distnames']
        for distname, value in data['distnames'].items():
            try:
                previous_value = pm_counters_db_data.get(distname, None)
                previous_value = float(previous_value) if previous_value is not None else None
            except TypeError as e:
                logger.debug("TypeError %s:%s \n%s", piid_name, distname, e)
                previous_value = None
            except ValueError as e:
                logger.debug("ValueError %s:%s \n%s", piid_name, distname, e)
                previous_value = None
            difference = (value-previous_value) if previous_value else None
            if previous_value not in ["0", 0, None, 'n/a']:
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
        dictionary.update({
            piid_name: {
                "name": pmcounter_manager.ALL_PIID_DICTIONARY.get(piid_name, 'TBA'),
                "distnames": distnames
            }
        })
    return dictionary


def insert_to_db(testcase_id, pmdict, ignore_zero=True):
    db_interface_insert.insert_pmcounters_dict(testcase_id, pmdict, ignore_zero=ignore_zero)


def main():
    logger.info("pmcounter_manager.py")
    parser = argparse.ArgumentParser(description='pmcounter_manager.py')
    parser.add_argument('--pmdir')
    parser.add_argument('--tcid')
    parser.add_argument(
        '--db', default='/home/ute/DEVELOPMENT/database/performance.sqlite3')
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    pmdir = pathlib.Path(args.pmdir)
    all_counters = pmcounter_manager.get_all_counters(str(pmdir))
    connect_db(args.db)
    pm_counters_db = get_pm_counters_from_db(args.tcid)
    with open(pmdir.joinpath('pmcounter_db.json'), 'w', encoding='utf-8') as f:
        json.dump(pm_counters_db, f)
    pmcounter_cmp = get_pm_counter_comparison_dictionary(all_counters, pm_counters_db)
    print(format_cmp_dict_as_table(pmcounter_cmp))
    with open(pmdir.joinpath('pmcounter_cmp.json'), 'w', encoding='utf-8') as f:
        json.dump(pmcounter_cmp, f)


if __name__ == "__main__":
    main()
