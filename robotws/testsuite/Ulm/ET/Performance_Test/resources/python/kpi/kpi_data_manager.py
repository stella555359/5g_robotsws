'''
LTEpat deprecation solution

source /home/ute/DEVELOPMENT/env_activate
python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/kpi/kpi_data_manager.py \
    --active_cells 7,8,9,10,11 \
    --pm_counter_directory "${Home}/Downloads/test/pm" --kpi_list "NR_5192e,NR_5193b"


example output:

    "NR_5193b": {
    "name": "5G Average number of scheduled (FDM and MU-MIMO) UEs on PUSCH",
    "description": "This KPI shows the average number of UEs scheduled per slot in UL...",
    "formula": "Sum([M55308C18001]) / Sum([M55308C00006] + [M55308C00010])",
    "required_pm_counters": [
      "M55308C00010",
      "M55308C00006",
      "M55308C18001"
    ],
    "object_summary_levels": "PLMN-MRBTS-NRBTS-NRCEL",
    "distnames": {
      "MRBTS-1/NRBTS-1/NRCELL-7": 2.97,
      "MRBTS-1/NRBTS-1/NRCELL-8": 2.98,
      "MRBTS-1/NRBTS-1/NRCELL-9": 2.98,
      "MRBTS-1/NRBTS-1/NRCELL-10": 2.97,
      "MRBTS-1/NRBTS-1/NRCELL-11": 2.98
    }
  }

'''

import pathlib
import argparse
import logging
import os
import traceback
import json
import collections

from testsuite.Ulm.ET.Performance_Test.resources.python import scripts
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_distnames
from testsuite.Ulm.ET.Performance_Test.resources.python import pmcounter_manager

from testsuite.Ulm.ET.Performance_Test.resources.python.kpi import kpi_nidd_fetcher

logger = logging.getLogger()


class KpiDataManager():
    '''
    This class is responsible for calculating KPI from PM Counter values based on data fetched from NIDD file
    '''

    DEFAULT_KPIS = [
        'NR_5192e',  # CB014680
        'NR_5193b',  # CB014680
    ]

    def __init__(self, pm_files_directory: str, kpi_list: list = None, active_cells: list = None, scf: str = None,
                 admin_api_connection: str = None):
        '''
        :pm_files_directory:         directory where pm counters are stored
        :kpi_list:                   list of kpis to calculate
        :active_cells:               filter cells for calculation
        :scf:                        optional scf path for better parsing
        :admin_api_connection:       admin_api_connection, creates a new one if none
        '''
        self.pm_files_directory = pm_files_directory
        self.active_cells = ['all'] if active_cells is None else active_cells
        self.kpi_nidd_fetcher = kpi_nidd_fetcher.KpiNiddFetcher()
        self.kpi_list = KpiDataManager.DEFAULT_KPIS if kpi_list is None else kpi_list
        self.kpis_nidd_info = self.kpi_nidd_fetcher.get_kpis_info(self.kpi_list)
        self.precision = 2
        self.scf = str(pathlib.Path(__file__).parent.joinpath('scfc_compactdist.xml')) if scf == 'test' else scf
        self.connection = admin_api_connection

    def calculate_all_kpi(self) -> dict:
        '''
        :return: dictionary with all kpi data
        {
            '< KPI ID >' : {
                "distnames" : {
                    < distname: STR > : < FLOAT >
                    ...
                },
                "description" : < STR >
            },
            ...
        }
        '''
        result = self.kpis_nidd_info
        for kpi_id in self.kpi_list:
            logger.info("[%s] Start Calculations", kpi_id)
            try:
                distnames = self.calculate(kpi_id)
            except ValueError as e:
                logger.error("KPI Error: %s, %s", kpi_id, e)
                distnames = [{'error': None}]
            result[kpi_id].update({
                'distnames': distnames
            })
        return result

    def calculate(self, kpi_id: str, index: int = -1) -> collections.OrderedDict:
        '''
        :return: a dictionary with calculated kpi
        {
            < distname: STR > : < FLOAT >
            ...
        }
        '''
        distnames = self._get_distnames(kpi_id)
        pm_counter_dictionary = self._get_pm_counter_dictionary(kpi_id, index=index)
        result_dictionary = KpiDataManager._initialize_kpi_dict(distnames)
        logger.debug("[KpiData] [%s] Formula: %s", kpi_id, self.kpis_nidd_info[kpi_id]['formula'])
        _sum = 0
        _count = 0
        for distname in distnames:
            try:
                if not scripts.is_cell_included_in_distname(distname, self.active_cells):
                    continue
                result_dictionary[distname] = round(self._calculate_using_nidd_formula(kpi_id,
                                                                                       pm_counter_dictionary,
                                                                                       distname),
                                                    self.precision)
            except ZeroDivisionError:
                result_dictionary[distname] = 0
            except TypeError:
                logger.warning(traceback.format_exc())
                result_dictionary[distname] = None
            except Exception as e:
                logger.warning("[KpiData] [%s] [%s] %s, %s", kpi_id, distname, e, traceback.format_exc())
                result_dictionary[distname] = None
            if result_dictionary[distname] is not None:
                _sum = _sum + result_dictionary[distname]
                _count = _count + 1
        result_dictionary.update({
            'mean': (_sum / _count) if _count > 0 else 0,
            'sum': _sum
        })
        return result_dictionary

    def _get_distnames(self, kpi_id: str):
        cell_regexp = KpiDataManager.format_active_cells_in_regex(self.active_cells)
        return self._distname_mapper(
            object_summary_levels=self.kpis_nidd_info[kpi_id]['object_summary_levels'],
            cell_regexp=cell_regexp,
        )

    def _get_pm_counter_dictionary(self, kpi_id: str, index: int = -1) -> dict:
        required_pm_counters = self.kpis_nidd_info[kpi_id]['required_pm_counters']
        return pmcounter_manager.get_counter_dictionary_using_pd(
            self.pm_files_directory, required_pm_counters, index=index, inactive_cells=None, ignore_zero=False
        )

    def _calculate_using_nidd_formula(self, kpi_id: str, pmcounter_dictionary: dict, distname: str) -> float | None:
        eval_formula_orig = self.kpis_nidd_info[kpi_id]['formula']
        eval_formula_sub = eval_formula_orig.replace('Sum', 'sum')
        try:
            for pmcounter in pmcounter_dictionary.keys():
                eval_formula_sub = eval_formula_sub.replace(
                    pmcounter,
                    str(pmcounter_dictionary[pmcounter]["distnames"][distname]))
            logger.debug("    - %s | %s", distname, eval_formula_sub)
        except KeyError as e:
            logger.error("Key Error: %s", e)
            logger.error("pmcounter_dictionary: %s", json.dumps(pmcounter_dictionary, indent=2))
            return None
        try:
            return eval(  # pylint: disable=locally-disabled, eval-used
                eval_formula_sub
            )
        except NameError as e:
            logger.error(e)
            return None

    def _distname_mapper(self, object_summary_levels: str, cell_regexp: str = r'[0-9]+'):
        distmap = {}
        if object_summary_levels in ['PLMN-MRBTS-NRBTS-NRCEL']:
            if distmap.get('nrcell_distnames', False) is False:
                distmap.update({
                    'nrcell_distnames': perf_distnames.get_nrcell_distnames(
                        scf=self.scf,
                        connection=self.connection,
                        cell=cell_regexp
                    )
                })
            return distmap['nrcell_distnames']
        if object_summary_levels in ['PLMN-MRBTS-NRBTS']:
            if distmap.get('nrbts_distnames', False) is False:
                distmap.update({
                    'nrbts_distnames': perf_distnames.get_nrbts_distnames(
                        scf=self.scf,
                        connection=self.connection
                    )
                })
            return distmap['nrbts_distnames']
        if object_summary_levels == 'err':
            raise KpiDataManager.Exc.ObjectSummaryLevelsError
        logger.error('DistNotMappedError: %s', object_summary_levels)
        raise KpiDataManager.Exc.DistNotMappedError

    @staticmethod
    def _initialize_kpi_dict(distnames: list) -> collections.OrderedDict:
        '''
        :return: a dictionary without kpi calculations
        {
            < distname: STR > : < NONETYPE >
            ...
        }
        '''
        result_dictionary = collections.OrderedDict()
        for dn in distnames:
            result_dictionary[dn] = None
        return result_dictionary

    @staticmethod
    def format_active_cells_in_regex(active_cells: list) -> str:
        '''
        Regex should be arranged in descending order first to avoid false matches
        '''
        if active_cells in ['all', ['all']]:
            return r'[0-9]+'
        int_cell = [int(x) for x in active_cells]
        int_cell.sort(reverse=True)
        return f"(?:{'|'.join([str(x) for x in int_cell])})"

    class Exc:  # pylint: disable=locally-disabled, too-few-public-methods
        '''Exceptions'''

        class DistNotMappedError(Exception):
            '''DistNotMappedError'''

        class ObjectSummaryLevelsError(Exception):
            '''ObjectSummaryLevelsError'''


####################
# RF INTERFACE
####################
def get_kpi_dictionary(pm_counter_directory: str, kpi_list: list, active_cells: list, scf: str = None):
    kpiman = KpiDataManager(pm_counter_directory, kpi_list=kpi_list, active_cells=active_cells, scf=scf)
    return kpiman.calculate_all_kpi()


def _parse_arguments():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pm_counter_directory', help='Location of the PM files', required=True)
    parser.add_argument('--kpi_list', help='csv format of kpi ex. (NR_5192e,NR_5193b)', default=None)
    parser.add_argument('--active_cells', help='csv format of cells', default='all')
    parser.add_argument('--scf', help='scf location', default='test')
    parser.add_argument('--log_level', default='WARNING')
    return parser.parse_args()


def _main():
    args = _parse_arguments()
    logging.basicConfig(
        format='[%(levelname)7s %(lineno)4s %(filename)-20s] %(message)s',
        datefmt='%H:%M:%S',
        level=getattr(logging, args.log_level)
    )
    try:
        logger.info("Start of %s", os.path.basename(__file__))
        kpiman = KpiDataManager(args.pm_counter_directory,
                                kpi_list=args.kpi_list.split(',') if args.kpi_list is not None else args.kpi_list,
                                active_cells=args.active_cells.split(','), scf=args.scf,
                                admin_api_connection='ignore')
        kpi_result = kpiman.calculate_all_kpi()
        print(json.dumps(kpi_result, indent=2))
    except kpi_nidd_fetcher.KpiNiddFetcher.Exc.NiddFileNotFoundError as e:
        logger.error('NiddFileNotFoundError: %s', e)
    except Exception:
        logger.exception(traceback.format_exc())
    finally:
        logger.info("End of %s", os.path.basename(__file__))


if __name__ == '__main__':
    _main()
