from set_pandas import *
from robot.libraries.BuiltIn import BuiltIn
import re

pd = None
np = None


ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def get_ue_stats_for_given_cc(ue_id, cc, direction):
    stats_type = 'pdsch' if direction == 'dl' else 'pusch'
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type={} scell={}'
                                                                       .format(ue_id, stats_type, cc),
                                                                       pass_regexp='UE-{}: NR {} Throughput'
                                                                       .format(ue_id, stats_type.upper()))


def get_avg_data_traffic_for_given_cc(ue_id, cc, direction, unit):
    ue_stats = get_ue_stats_for_given_cc(ue_id, cc, direction)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(ue_stats)[-1][0]
    return float(avg_tput)


def analyze_csv_for_ri_bits(path, expected_ri_bits):
    init_pandas()
    numofribits = 'csiSrReportData.csiReport.numOfRiBits'
    whole_data = pd.read_csv(r'{}/output_dl.csv'.format(path))
    output_data = pd.DataFrame(whole_data, columns=['timeStamp', 'rnti', 'physCellId', numofribits])
    output_data.dropna(subset=['csiSrReportData.csiReport.numOfRiBits'], inplace=True)
    output_data['RI bits as expected'] = np.where(output_data[numofribits] == expected_ri_bits, 'YES', 'NO')
    print(output_data[numofribits])
    print(type(expected_ri_bits))
#    print(output_data)
    output_data.to_csv(r'{}/analyzed_data.csv'.format(path), index=False)
    not_expected_values = ((output_data['RI bits as expected'] == 'NO').sum())
    if not_expected_values == 0:
        print('There are only expected values! Success.')
        return True
    else:
        print('There are some unexpected values,')
        print('check manually in TTI traces if only value {} is present'.format(expected_ri_bits))
        return False
