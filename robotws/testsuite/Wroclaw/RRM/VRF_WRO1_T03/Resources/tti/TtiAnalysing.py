from taf.internal.aliasing import aliasing_scope
import os
from TtiDecoder import TtiDecoder
import pip
import re
# from testsuite.Wroclaw.RRM.VRF_WRO1_T03.Resources.other.others import import_with_auto_install
import logging


log = logging.getLogger()


def import_with_auto_install(package):
    pip.main(['install', package])
    return __import__(package)


pd = import_with_auto_install('pandas')


class TtiAnalysing(TtiDecoder):
    lookup_handler, store = aliasing_scope(lookup_arg='alias')

    def __init__(self):
        super().__init__()

    def setup_tti(self, input_file, output_folder, output_format='legacyCsv', sw_version=None, message_filter=None,
                  alias='default'):
        output_file_name = input_file.rsplit('/', 1)[1].rsplit('.', 1)[0]
        output_file = os.path.join(output_folder, output_file_name)
        new_decoded_pcap = output_file + '.' + 'dlAndUl.csv'
        if os.path.exists(new_decoded_pcap):
            pass
        else:
            self.decode_tti(input_file, output_file, output_format, message_filter, sw_version)
        new_decoded_pcap = ConvertDataToPandasDF(new_decoded_pcap)
        self.store.add(new_decoded_pcap, alias)
        return new_decoded_pcap

    @lookup_handler.implicit_lookup
    def count_average_tput(self, expected=None, group_by=None, tput_direction='dl', alias='default'):
        try:
            data = alias._get_parameter(['tbSize', 'rnti'], f'{tput_direction}FdSchedData', remove_duplicates=False,
                                        **group_by)
        except KeyError:
            raise MessageNotFoundInTti()
        rnti_list = data['rnti'].drop_duplicates()
        group_by = {}
        tput_per_rnti = {}
        for rnti in rnti_list:
            group_by['rnti'] = rnti
            for key, value in group_by.items():
                data_tmp = data.loc[data[key] == value]
            data_tmp = data_tmp.iloc[:].astype(int)
            tput_sum = data_tmp['tbSize'].sum()
            average_tput = tput_sum / 5
            tput_per_rnti[rnti] = average_tput
            log.info(f'rnti: {rnti} -> tput: {average_tput}')
        if expected is not None:
            tput_per_rnti = {k: v for k, v in sorted(tput_per_rnti.items(), key=lambda item: item[1])}
            for i, (k, v) in enumerate(tput_per_rnti.items()):
                expected_tput = expected[i]
                if float(abs(1 - (float(expected_tput) / float(v)))) > 0.1:
                    raise WrongAverageTput(expected_tput, v, k)
                else:
                    log.info(f'Tput value {v} as much as expected {expected_tput}')
        log.info(f'tput: {tput_per_rnti}')
        return tput_per_rnti

    @lookup_handler.implicit_lookup
    def check_status(self, parameter, value, message, tolerance=None, alias='default', **group_by):
        parameter_set = alias._get_parameter(parameter, message, remove_duplicates=False, **group_by)
        total = parameter_set.count()
        occur = parameter_set[parameter_set.iloc[:] == value].count()
        ratio = (int(occur) / int(total)) * 100
        if tolerance is not None:
            if ratio > float(tolerance.strip('%')):
                log.info(f'status checking passed with tolerance: {ratio}')
                pass
            else:
                raise ToleranceExceeded(int(occur), int(total), tolerance, float(ratio))
        log.info(f'occurence: {occur}, ratio: {ratio}')

    def check_subband_status(self, parameter='beamType', value='SUBBAND', message='dlFdSchedData', tolerance='90%',
                             group_by=None, alias='default'):
        self.check_status(parameter, value, message, tolerance, alias=alias, **group_by)

    def check_pairing_status(self, parameter='muStatus', value='MUPAIR', message='dlFdSchedData', tolerance='90%',
                             group_by=None, alias='default'):
        self.check_status(parameter, value, message, tolerance, alias=alias, **group_by)

    @lookup_handler.implicit_lookup
    def check_parameter_value_is_expected(self, condition, group_by=None, tolerance='90%', alias='default'):
        operator_map = {
            '=': 'eq',
            '>': 'gt',
            '>=': 'ge',
            '<': 'lt',
            '<=': 'le'}
        parameter, condition, expected_value = re.split('([=<>!]{1,})', condition)
        parameter, message = re.split(':', parameter)
        expected_value = expected_value.split('/')
        log.info(expected_value)
        log.info(f'parameter: {parameter}, message: {message}')
        try:
            data = alias._get_parameter(parameter, message, remove_duplicates=False, **group_by)
            log.info(data)
        except KeyError:
            raise MessageNotFoundInTti()
        operator = operator_map[condition]
        if expected_value is None:
            raise ValueError('Expected value is None, please provide expected value')
        if operator == 'eq':
            result = data.isin(expected_value)
        else:
            log.info(f'get attribut: {getattr(pd.Series([data.iloc[1]]), operator)}')
            result = pd.Series(
                [any(getattr(pd.Series([v]), operator)(ev).iloc[0] for ev in expected_value) for v in data])
        # if condition == '=':
        #     log.info('= condition')
        #     # log.info(data)
        #     result = data.eq(expected_value)
        # elif condition == '>':
        #     log.info('> condition')
        #     result = data.gt(expected_value)
        # elif condition == '>=':
        #     log.info('=> condition')
        #     result = data.ge(expected_value)
        # elif condition == '<':
        #     log.info("< condition")
        #     result = data.lt(expected_value)
        # elif condition == '<=':
        #     log.info('<= condition')
        #     result = data.le(expected_value)
        if tolerance is not None:
            log.info('start checking tolerance')
            self.tolerance_for_condition(result, tolerance, expected_value)
        else:
            return result

    def tolerance_for_condition(self, result, tolerance, parameter_l=None):
        total = result.count()
        pass_amount = result[result].count()
        ratio = (int(pass_amount) / int(total)) * 100
        if ratio >= float(tolerance.strip('%')):
            log.info(f'Expected tolerance: {tolerance}, current ratio: {ratio}%')
            pass
        else:
            log.info('start error of tolerance')
            # if plot_chart_if_failed:
            #     self.plot_prb(parameter_l, name=f'chart{randint(100, 1000)}')

            raise ToleranceExceeded(int(pass_amount), int(total), tolerance, float(ratio))

    # @lookup_handler.implicit_lookup
    def delete_alias(self, alias='default'):
        self.store._store[alias] = {}

    @lookup_handler.implicit_lookup
    def get_parameter(self, parameter, alias='default'):
        return alias._get_parameter(parameter, 'dlFdSchedData', remove_duplicates=False)


class ToleranceExceeded(Exception):
    def __init__(self, occur, total, tolerance, ratio):
        self.occur = occur
        self.total = total
        self.tolerance = tolerance
        self.ratio = ratio

    def __str__(self):
        return f"Tolerance {self.tolerance} is exceeded, \n total number of rows: {self.total}, " \
               f"\n occurrence: {self.occur}, \n current ratio: {round(self.ratio, 2)}%"


class WrongAverageTput(Exception):
    def __init__(self, expected, current, rnti):
        self.expected = expected
        self.current = current
        self.rnti = rnti

    def __str__(self):
        return f"Expected Average Tput: {self.expected} and current tput: {self.current} are not similar for rnti: " \
               f"{self.rnti}"


class MessageNotFoundInTti(Exception):
    def __str__(self):
        return 'Check tti logs manually, probably given message does not exist in tti logs.'


class ConvertDataToPandasDF:
    def __init__(self, data):
        self.base_df = pd.read_csv(data, sep=';', header=None)

    def _get_parameter(self, parameter, message, remove_duplicates=False, **group_by):
        df = self.base_df[self.base_df[0].str.contains(message)]
        df = df[0].str.split(':', n=1, expand=True)[1]
        number_of_parameters = df.iloc[1].count(',') + 1
        number_of_parameters = number_of_parameters / 2
        columns_name = df.iloc[1].split(',')[:int(number_of_parameters)]
        df = df.apply(lambda x: x.split(',')[int(number_of_parameters):])
        df = pd.DataFrame(df.tolist(), columns=columns_name)
        if group_by is not None:
            for key, value in group_by.items():
                df = df.loc[df[key] == value]
        if remove_duplicates:
            df = df.drop_duplicates(subset=[parameter])
        if isinstance(parameter, str) or isinstance(parameter, list):
            df = df[parameter]
        return df
