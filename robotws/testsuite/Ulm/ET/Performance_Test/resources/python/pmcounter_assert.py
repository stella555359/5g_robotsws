

import argparse
import logging
import operator
import pathlib
import json

from testsuite.Ulm.ET.Performance_Test.resources.python import pmcounter_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import pmcounter_sqlite_inf


logger = logging.getLogger(__name__)


def assert_all_counters(pm_counter_comparison_dictionary, tolerance):
    return assert_pm_counters(
        pm_counter_comparison_dictionary,
        pmcounter_manager.PIID_DICTIONARY,
        operator_cmp='>=',
        tolerance=tolerance
    )


def assert_all_counters_for_actFlowControlLoadBalance_checking(pm_counter_comparison_dictionary, tolerance):
    return assert_pm_counters(
        pm_counter_comparison_dictionary,
        pmcounter_manager.ACTFLOWCONTROLLBALANCE_COUNTERS,
        operator_cmp='<=',
        tolerance=tolerance
    )


def assert_pm_counters(pm_counter_comparison_dictionary, piid_list, operator_cmp='>', tolerance='null'):
    logger.debug("==========  start: assert_pm_counters ==========")
    if tolerance == 'null':
        return None
    if len(pm_counter_comparison_dictionary.keys()) == 0:
        logger.error("Counters Not Collected!")
        return False
    operator_cmp = {
        '>': operator.gt,
        '<': operator.lt,
        '>=': operator.ge,
        '<=': operator.le
    }[operator_cmp]

    for piid in piid_list:
        logger.debug("piid: %s", piid)
        for distname, data in pm_counter_comparison_dictionary[piid]["distnames"].items():
            previous = data['previous']
            previous = int(previous) if previous not in [
                'n/a', 'none', None] else 'n/a'
            current = int(data['current'])

            tolerance100 = float(
                tolerance) * (-1 if operator_cmp in [operator.lt, operator.le] else 1)
            if previous != 'n/a':
                result = operator_cmp(
                    current + (current * tolerance100), previous)
            else:
                result = False
            logger.debug("distname: %s, tolerance: %s", distname, tolerance100)
            if not result:
                logger.error(
                    "PM Counter Assert Failed: piid(%s), cur(%s), prev(%s)", piid, current, previous)
                return False
    return True


def main():
    logger.info("pmcounter_assert.py")
    parser = argparse.ArgumentParser(description='pmcounter_assert.py')
    parser.add_argument('--pmdir')
    parser.add_argument('--tcid')
    parser.add_argument('--tolerance', default='0')
    parser.add_argument(
        '--db', default='/home/ute/DEVELOPMENT/database/performance.sqlite3')
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    pmdir = pathlib.Path(args.pmdir)
    all_counters = pmcounter_manager.get_all_counters(str(pmdir))
    pmcounter_sqlite_inf.connect_db(args.db)
    pm_counter_comparison = pmcounter_sqlite_inf.get_pm_counter_comparison_dictionary_from_db(
        all_counters, args.tcid)
    with open(pmdir.joinpath('pmcounter_cmp.json'), 'w', encoding='utf-8') as f:
        json.dump(pm_counter_comparison, f)
    result = assert_all_counters(pm_counter_comparison, args.tolerance)

    logger.info("Result: %s", result)


if __name__ == "__main__":
    main()
