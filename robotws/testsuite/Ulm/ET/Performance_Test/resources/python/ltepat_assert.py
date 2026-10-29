

import operator
import logging
import json

from testsuite.Ulm.ET.Performance_Test.resources.python import scripts


expect_kpi_increase = ["nr_5120a", "nr_5121a", "nr_5138a", "nr_5096f"]
expect_kpi_decrease = ["nr_5192e", "nr_5193b", "nr_5100c"]
kpi_info = ["nr_578d", "nr_5114b", "nr_5115a", "nr_5094a", "nr_5095a",
            "nr_2332a", "nr_5907a", "nr_6097a", "nr_70a", "nr_6098a", "nr_973a"]
all_kpis = [*kpi_info, *expect_kpi_increase, *expect_kpi_decrease]

logger = logging.getLogger(__name__)


def assert_kpi_dictionary(
        kpi_comparison_dictionary,
        tolerance=1,
        average_only=True,
        active_cells=['all']):
    is_pass = True
    if tolerance == 'null':
        logger.debug('assert_kpi_dictionary skip, tolerance  is null')
        return
    assert_result = {}
    if kpi_comparison_dictionary != {} or kpi_comparison_dictionary is not None:
        # Check Increase
        for kpi_name in expect_kpi_increase:
            logger.debug("assert_kpi_distnames: %s", kpi_name)
            distnames = kpi_comparison_dictionary.get(kpi_name, {})
            assert_result.update({kpi_name:
                                  assert_kpi_distnames(
                                      distnames,
                                      tolerance=tolerance,
                                      comparison=operator.gt,
                                      average_only=average_only,
                                      active_cells=active_cells
                                  )}
                                 )
        # Check Decrease
        for kpi_name in expect_kpi_decrease:
            logger.debug("assert_kpi_distnames: %s", kpi_name)
            distnames = kpi_comparison_dictionary.get(kpi_name, {})
            assert_result.update({kpi_name:
                                  assert_kpi_distnames(
                                      distnames,
                                      tolerance=tolerance,
                                      comparison=operator.lt,
                                      average_only=average_only,
                                      active_cells=active_cells
                                  )
                                  })
    else:
        assert_result = {"0": False}
        is_pass = False
        logger.error("No KPI's found")
    for kpi_name, res in assert_result.items():
        if not res:
            is_pass = False
            break
    if not is_pass:
        logger.error("KPI Assert Failed: \n%s",
                     json.dumps(assert_result, indent=4))
    return is_pass


def assert_kpi_distnames(distnames,
                         tolerance=1,
                         comparison=operator.gt,
                         average_only=True,
                         active_cells=['all']):
    logger.debug("assert_kpi_distnames")
    if tolerance == 'null' or tolerance is None:
        return True
    assert_pass = True
    if distnames == {}:
        logger.warning("assert failed, distnames_dict is empty")
        return False
    for distname, data in distnames.items():
        try:
            logger.debug("distname: %s", distname)
            if scripts.is_cell_included_in_distname(distname, active_cells):
                if not (average_only and distname != 'mean') and tolerance < 1:
                    if data['percent'] is None:
                        assert_pass = False
                        logger.warning("percent is None")
                    elif tolerance != 'null':
                        # expecting a decrease then multiply by negative 1, percent should be negative
                        tolerance100 = tolerance * \
                            (-1 if comparison ==
                             operator.lt or comparison == operator.le else 1)
                        percent_tol = data['percent'] + (tolerance100 * 100)
                        if (not comparison(percent_tol, 0)):
                            logger.warning("percent is %s", percent_tol)
                            assert_pass = False
        except KeyError as e:
            logger.exception(e)
            assert_pass = False
    logger.debug("assert_kpi_distnames end")
    return assert_pass
