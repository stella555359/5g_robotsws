"""
:copyright: Nokia Networks
:author: Igor Binkowski
:contact: igor.binkowski@nokia.com
:maintainer: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:version: 0.2

This file uses pandas_gate.py and set_pandas.py scripts to install and import pandas.
pd = None at the beginning of this file was added for this purpose. Init pandas needs
to be called in test or testsuite for which there are files with pd = None i.e. files
which need pandas import.
"""

import os
import warnings
import glob

from robot.api import logger
from taf.converters.ttitracer import ttitracer

pd = None
warnings.simplefilter(action='ignore', category=FutureWarning)


class TtiSchedulingAnalysis(object):

    def verify_tti_trace_for_scheduling_outside_blanked_area(
            self, lte_cell_id, nr_cell_id, trace_dir, gnb_oam_ip, sw_version, param_dict, phys_cell_id=-1,
            check_lte=True, check_nr=False):
        """
        Keyword for verification of correctness of PRB scheduling in LTE and NR TTI traces in IWK tests.
        Obtains values of needed parameters from both eNB and gNB.
        Decodes LTE traces collected by 'Collect 4G TTI Trace' KW from ca_IWK resource.
        Checks scheduling in LTE and NR TTI traces according to rules described by Piotr Maj in
        https://jiradc.ext.net.nokia.com/browse/IWK-171.
        Raises an exception if invalid scheduling is detected in any of the traces.

        :param lte_cell_id: ID of LTE cell with DSS in use.
        :param nr_cell_id: ID of NR cell with DSS in use.
        :param trace_dir: Path to directory where traces for verification are located.
        :param gnb_oam_ip: OAM IP (mPlane address) of the gNB.
        :param phys_cell_id: Physical cell of NR cell with DSS in use. Set to -1 by default.
        It has to be specified when check_nr flag is set to True.
        :param check_lte: the flag indicating if scheduling for LTE should be checked, True is default.
        :param check_nr: the flag indicating if scheduling for NR should be checked, False is default.
        :param sw_version: Version of software for which 4G TTI Trace decoder will be downloaded
        :param param_dict: Dictionary with values of parameters related with blanking.
        Dictionary is created by ca_IWK.Check Parameters For TtiSchedulingAnalysis.
        """

        num_blank_dl_prbs_down = int(param_dict['num_blank_dl_prbs_down'])
        num_blank_dl_prbs_up = int(param_dict['num_blank_dl_prbs_up'])
        blanked_pucch = int(param_dict['blanked_pucch'])
        outer_pusch_region = param_dict['outer_pusch_region']
        dl_ch_bw = param_dict['dl_ch_bw']

        nbr_of_blanked_prbs_low_edge_dl = int(param_dict['nbr_of_blanked_prbs_low_edge_dl'])
        nbr_of_blanked_prbs_low_edge_ul = int(param_dict['nbr_of_blanked_prbs_low_edge_ul'])
        nbr_of_blanked_prbs_high_edge_dl = int(param_dict['nbr_of_blanked_prbs_high_edge_dl'])
        nbr_of_blanked_prbs_high_edge_ul = int(param_dict['nbr_of_blanked_prbs_high_edge_ul'])

        bw_prbs_lte = int(dl_ch_bw.split()[0]) * 5
        bw_prbs_nr = bw_prbs_lte + bw_prbs_lte / 25

        if check_lte:
            self._parse_dat_lte_tti_traces(trace_dir, sw_version)

            lte_dl_trace_result = self._check_scheduling_in_lte_dl_trace(
                trace_dir, num_blank_dl_prbs_up, num_blank_dl_prbs_down, bw_prbs_lte)

            lte_ul_trace_result = self._check_scheduling_in_lte_ul_trace(
                trace_dir, blanked_pucch, outer_pusch_region, bw_prbs_lte)

            assert lte_dl_trace_result and lte_ul_trace_result, 'Scheduling inside LTE blanked area detected!'
            logger.console('All scheduling for LTE was outside blanked area.')

        if check_nr:
            nr_dl_trace_result = self._check_scheduling_in_nr_trace(
                trace_dir, 'dl', nbr_of_blanked_prbs_high_edge_dl,
                nbr_of_blanked_prbs_low_edge_dl, bw_prbs_nr, nr_cell_id, phys_cell_id)
            nr_ul_trace_result = self._check_scheduling_in_nr_trace(
                trace_dir, 'ul', nbr_of_blanked_prbs_high_edge_ul,
                nbr_of_blanked_prbs_low_edge_ul, bw_prbs_nr, nr_cell_id, phys_cell_id)
            assert nr_dl_trace_result and nr_ul_trace_result, 'Scheduling inside NR blanked area detected!'
            logger.console('All scheduling for NR was outside blanked area.')

    @staticmethod
    def _parse_dat_lte_tti_traces(trace_dir, sw_version):
        """
        Parse LTE TTI traces collected by KW 'Collect 4G TTI Trace' from taf.collectors.ttitrace_4g
        library to text form. 4G TTI Tracer used in this method is downloaded
        under default path defined in taf.converters.ttitracer for install_ttitracer - '/opt/TtiTracer'.
        Please take note that due to argument 'force' set to True this directory
        will be forcefully cleared with (sudo) rm -rf command when this method is called.

        :param trace_dir: Path to directory where LTE traces are located
        :param sw_version: Version of software for which 4G TTI Trace decoder will be downloaded
        """

        logger.debug('TTI Tracer start')
        tti_decoder = ttitracer()
        logger.debug('TTI Tracer download')
        tti_decoder.install_ttitracer(version=sw_version, force=True)
        logger.info('TTI Tracer downloaded to /opt/TtiTracer.')
        ttitracer.create_ttitracer_converter(tti_decoder, 'tti_converter', os.path.join(trace_dir, 'tti_stream_*.dat'))

        try:
            logger.debug('TTI Tracer setup')
            tti_decoder.setup('tti_converter')
            logger.debug('TTI Tracer convert')
            tti_decoder.convert('tti_converter')
            logger.debug('TTI converted')
        finally:
            logger.debug('TTI Tracer teardown')
            tti_decoder.teardown('tti_converter')

        logger.info('All .dat files in directory ' + trace_dir + ' converted to .txt.')

    @staticmethod
    def _check_scheduling_in_nr_trace(
            trace_dir, direction, nbr_of_blanked_prbs_high_edge, nbr_of_blanked_prbs_low_edge,
            bw_prbs_nr, nr_cell_id, phys_cell_id):
        """
        Verifies correctness of PRB scheduling in NR TTI traces according to
        https://jiradc.ext.net.nokia.com/browse/IWK-171.

        :param trace_dir: Path to directory where traces for verification are located
        :param direction: Direction of traces to be analyzed. Accepted values are 'dl' and 'ul'
        :param nbr_of_blanked_prbs_high_edge: Value of parameter nbrOfBlankedPRBsHighEdge in tested NR cell
        :param nbr_of_blanked_prbs_low_edge: Value of parameter nbrOfBlankedPRBsLowEdge in tested NR cell
        :param bw_prbs_nr: Bandwidth of tested NR cell expressed in NR PRBs
        :param nr_cell_id: ID of NR cell with DSS in use.
        :param phys_cell_id: Physical cell of NR cell with DSS in use. Set to -1 by default.
        It has to be specified when check_nr flag is set to True.
        :return: True if scheduling in TTI trace is deemed correct; False otherwise
        """

        trace = pd.read_csv('{}/tcpdump_{}.csv'.format(trace_dir, direction))
        trace = trace[trace['physCellId'] == int(phys_cell_id)]
        prefix = direction + 'FdSchedData.'
        param_pairs = trace[[prefix + 'startPrb', prefix + 'numOfPrb']].drop_duplicates()\
            .dropna().astype(int).to_dict(orient='records')

        min_allowed_prb = nbr_of_blanked_prbs_low_edge
        max_allowed_prb = bw_prbs_nr - nbr_of_blanked_prbs_high_edge - 1

        logger.info('NR {} TTI trace check results:\n\nMin. allowed PRB: {}\nMax. allowed PRB: {}'.format(
            direction, min_allowed_prb, max_allowed_prb))

        scheduling_results = []

        for parameter_pair in param_pairs:
            min_used_prb = parameter_pair[prefix + 'startPrb']
            max_used_prb = parameter_pair[prefix + 'startPrb'] + parameter_pair[prefix + 'numOfPrb'] - 1

            parameter_pair_correct = (min_used_prb >= min_allowed_prb and
                                      max_used_prb <= max_allowed_prb)

            scheduling_results.append(parameter_pair_correct)

            logger.info('startPrb: {}\nnumOfPrb: {}\nMin. used PRB: {}\nMax. used PRB: {}\nPRBs used in allowed '
                        'spectrum: {}'.format(parameter_pair[prefix + 'startPrb'], parameter_pair[prefix + 'numOfPrb'],
                                              min_used_prb, max_used_prb, parameter_pair_correct))

        scheduling_correct = True if all(scheduling_results) and len(scheduling_results) else False

        logger.info('Scheduling in NR {} TTI trace correct: {}'.format(direction.upper(), scheduling_correct))
        logger.console('Scheduling in NR {} TTI trace correct: {}'.format(direction.upper(), scheduling_correct))
        return scheduling_correct

    def _check_scheduling_in_lte_dl_trace(self, trace_dir, num_blank_dl_prbs_up, num_blank_dl_prbs_down, bw_prbs_lte):
        """
        Verifies correctness of PRB scheduling in LTE DL TTI traces according to
        https://jiradc.ext.net.nokia.com/browse/IWK-171.

        :param trace_dir: Path to directory where traces for verification are located
        :param num_blank_dl_prbs_up: Value of parameter numBlankDlPRBsUp in tested LTE cell
        :param num_blank_dl_prbs_down: Value of parameter numBlankDlPRBsDown in tested LTE cell
        :param bw_prbs_lte: Bandwidth of tested LTE cell expressed in LTE PRBs
        :return: True if scheduling in DL TTI trace is deemed correct; False otherwise
        """

        trace = self._prepare_lte_trace_for_analysis('dl', trace_dir)
        hex_masks = trace['rbMasking'].unique().tolist()

        min_allowed_prb, max_allowed_prb = self._calculate_allowed_lte_prb_values(
            'dl', num_blank_dl_prbs_up=num_blank_dl_prbs_up, num_blank_dl_prbs_down=num_blank_dl_prbs_down,
            bw_prbs_lte=bw_prbs_lte)

        logger.info('LTE DL TTI trace check results:\n\nMin. allowed PRB: {}\nMax. allowed PRB: {}'.format(
            min_allowed_prb, max_allowed_prb))

        scheduling_results = []

        for hex_mask in hex_masks:
            try:
                bitmask = str(bin(int(hex_mask, 16))[2:].zfill(31))
            except (ValueError, TypeError):
                logger.info("Erratic bitmask value '{}' in LTE DL TTI trace was ignored".format(hex_mask))
                continue
            min_used_prb, max_used_prb = self._calculate_used_lte_dl_prb_values(bitmask, bw_prbs_lte)

            mask_correct = (min_used_prb >= min_allowed_prb and max_used_prb <= max_allowed_prb)

            scheduling_results.append(mask_correct)

            logger.info('Hex mask: {}\nBitmask: {}\nMin. used PRB: {}\nMax. used PRB: {}\nPRBs used in allowed '
                        'spectrum: {}'.format(hex_mask, bitmask, min_used_prb, max_used_prb, mask_correct))

        scheduling_correct = True if all(scheduling_results) and len(scheduling_results) else False

        logger.info('Scheduling in LTE DL TTI trace correct: {}'.format(scheduling_correct))
        logger.console('Scheduling in LTE DL TTI trace correct: {}'.format(scheduling_correct))
        return scheduling_correct

    def _check_scheduling_in_lte_ul_trace(self, trace_dir, blanked_pucch, outer_pusch_region, bw_prbs_lte):
        """
        Verifies correctness of PRB scheduling in LTE UL TTI traces according to
        https://jiradc.ext.net.nokia.com/browse/IWK-171.

        :param trace_dir: Path to directory where traces for verification are located
        :param blanked_pucch: Value of parameter blankedPucch in tested LTE cell
        :param outer_pusch_region: Value of parameter selectOuterPuschRegion in tested LTE cell
        :param bw_prbs_lte: Bandwidth of tested LTE cell expressed in LTE PRBs
        :return: True if scheduling in UL TTI trace is deemed correct; False otherwise
        """

        trace = self._prepare_lte_trace_for_analysis('ul', trace_dir)
        param_pairs = trace[['firstAllocPrb', 'numberOfPrsAlloc']].drop_duplicates().to_dict(orient='records')

        min_allowed_prb, max_allowed_prb = self._calculate_allowed_lte_prb_values(
            'ul', blanked_pucch=blanked_pucch, outer_pusch_region=outer_pusch_region, bw_prbs_lte=bw_prbs_lte)

        logger.info('LTE UL TTI trace check results\nMin. allowed PRB: {}\nMax. allowed PRB: {}'.format(
            min_allowed_prb, max_allowed_prb))

        scheduling_results = []

        for parameter_pair in param_pairs:
            try:
                min_used_prb = int(parameter_pair['firstAllocPrb'])
                max_used_prb = int(parameter_pair['firstAllocPrb']) + int(parameter_pair['numberOfPrsAlloc']) - 1
            except (ValueError, TypeError):
                logger.info('Erratic PRB allocation values in LTE UL TTI trace was ignored: {}'.format(parameter_pair))
                continue

            parameter_pair_correct = (min_used_prb >= min_allowed_prb and max_used_prb <= max_allowed_prb)

            scheduling_results.append(parameter_pair_correct)

            logger.info('firstAllocPrb: {}\nnumberOfPrsAlloc: {}\nMin. used PRB: {}\nMax. used PRB: {}\nPRBs used '
                        'in allowed spectrum: {}'.format(parameter_pair['firstAllocPrb'],
                                                         parameter_pair['numberOfPrsAlloc'],
                                                         min_used_prb, max_used_prb, parameter_pair_correct))

        scheduling_correct = True if all(scheduling_results) and len(scheduling_results) else False

        logger.info('Scheduling in LTE UL TTI trace correct: {}'.format(scheduling_correct))
        logger.console('Scheduling in LTE UL TTI trace correct: {}'.format(scheduling_correct))
        return scheduling_correct

    @staticmethod
    def _prepare_lte_trace_for_analysis(direction, trace_dir):
        """
        Reads relevant data from LTE TTI trace in .txt format to pandas dataframe.

        :param direction: Direction of LTE trace to be read. Accepted values are 'dl' and 'ul'
        :param trace_dir: Path to directory where traces for verification are located
        :return: Dataframe of relevant data from TTI trace
        """

        if direction == 'dl':
            columns = ['ETtiTraceDlParUe_cRnti', 'ETtiTraceDlParUe_rbMasking']
            glob_pattern = "[Dd][Ll]"
        elif direction == 'ul':
            columns = ['ETtiTraceUlParUe_cRnti', 'ETtiTraceUlParUe_numberOfPrsAlloc', 'ETtiTraceUlParUe_firstAllocPrb']
            glob_pattern = "_[Uu][Ll]"

        logger.debug('File list: {}'.format(glob.glob('{}/tti_stream*{}*.txt'.format(trace_dir, glob_pattern))))
        logger.debug('Used file: {}'.format(glob.glob('{}/tti_stream*{}*.txt'.format(trace_dir, glob_pattern))[0]))

        trace = pd.read_csv(
            glob.glob('{}/*{}*.txt'.format(trace_dir, glob_pattern))[0],
            header=1, usecols=columns, low_memory=False)

        trace.rename(columns={x: x.split('_')[-1] for x in columns}, inplace=True)
        trace = trace[trace['cRnti'] != '-']

        return trace

    @staticmethod
    def _calculate_allowed_lte_prb_values(
            direction, num_blank_dl_prbs_down=0, num_blank_dl_prbs_up=0, blanked_pucch=0,
            outer_pusch_region=None, bw_prbs_lte=0):
        """
        Calculates numbers of minimum and maximum allowed PRB used in LTE according to
        https://jiradc.ext.net.nokia.com/browse/IWK-171.

        :param direction: Direction of traffic for which to calculate values. Accepted values are 'dl' and 'ul'
        :param num_blank_dl_prbs_down: Value of parameter numBlankDlPRBsDown in tested LTE cell
        :param num_blank_dl_prbs_up: Value of parameter numBlankDlPRBsUp in tested LTE cell
        :param blanked_pucch: Value of parameter blankedPucch in tested LTE cell
        :param outer_pusch_region: Value of parameter outerPuschRegion in tested LTE cell
        :param bw_prbs_lte: Bandwidth of tested LTE cell expressed in LTE PRBs
        :return: Minimum and maximum allowed PRB used in LTE in given traffic direction
        """

        if direction == 'dl':
            if num_blank_dl_prbs_down:
                min_allowed_prb = num_blank_dl_prbs_down
            else:
                min_allowed_prb = 0

            if num_blank_dl_prbs_up:
                max_allowed_prb = bw_prbs_lte - num_blank_dl_prbs_up - 1
            else:
                max_allowed_prb = bw_prbs_lte - 1

        elif direction == 'ul':
            if outer_pusch_region == 'None':
                min_allowed_prb = blanked_pucch / 2
                max_allowed_prb = bw_prbs_lte - blanked_pucch / 2 - 1
            elif outer_pusch_region == 'UpperEdge':
                min_allowed_prb = blanked_pucch / 2
                max_allowed_prb = bw_prbs_lte - 1
            elif outer_pusch_region == 'LowerEdge':
                min_allowed_prb = 0
                max_allowed_prb = bw_prbs_lte - blanked_pucch / 2 - 1

        return min_allowed_prb, max_allowed_prb

    @staticmethod
    def _calculate_used_lte_dl_prb_values(bitmask, bw_prbs_lte):
        """
        Calculates miminum and maximum used PRBs in LTE in downlink according to
        https://jiradc.ext.net.nokia.com/browse/IWK-171.

        :param bitmask: Binary mask of used PRBs
        :param bw_prbs_lte: Bandwidth of tested LTE cell expressed in LTE PRBs. Accepted values are 50, 75 and 100
        :return: Minimum and maximum used PRB used in LTE downlink
        """

        first_prb_pos = bitmask.find('1')
        last_prb_pos = 31 - bitmask[::-1].find('1') - 1

        if bw_prbs_lte == 50:
            min_used_prb = first_prb_pos * 3
            if first_prb_pos == 16:
                max_used_prb = last_prb_pos * 3 + 1
            else:
                max_used_prb = last_prb_pos * 3 - 1

        elif bw_prbs_lte == 75:
            min_used_prb = first_prb_pos * 4
            if first_prb_pos == 18:
                max_used_prb = last_prb_pos * 4 + 2
            else:
                max_used_prb = last_prb_pos * 4 - 1

        elif bw_prbs_lte == 100:
            min_used_prb = first_prb_pos * 4
            if first_prb_pos == 24:
                max_used_prb = last_prb_pos * 4 + 4
            else:
                max_used_prb = last_prb_pos * 4 - 1

        return min_used_prb, max_used_prb
