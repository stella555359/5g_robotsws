import json
import logging
from prettytable import PrettyTable
from bearer_stats_analysis import get_tp_dict


def normalize_cell_names(pmc_dict):
    for scenario_name, scenario_data in pmc_dict.items():
        scenario_data = {key[-1]: value for key, value in scenario_data.items()}
        pmc_dict.update({scenario_name: scenario_data})
    return pmc_dict


def get_value_with_margin(value, margin=30, mode='percent'):
    if mode == 'percent':
        return value - (value * margin/100), value + (value * margin/100)
    elif mode == 'fixed':
        return value - margin, value + margin
    logging.error('incorrect margin type. returning input value twice')
    return value, value


def validate_traffic_for_scenario(scenario: str, pmc_throughput_path: str,
                                  expected_throughput: dict, margin={'percent': 15, 'fixed': 0.5}) -> dict[str, bool]:
    logging.info('Checking if Traffic was achieved. Using a margin of +- %s', margin)
    with open(pmc_throughput_path, 'r', encoding='utf-8') as throughput_file:
        json_dict = normalize_cell_names(json.load(throughput_file))
        scenario_throughput = json_dict[scenario]
    for cell, traffic_values in scenario_throughput.items():
        scenario_throughput[cell] = {key: value for key, value in traffic_values.items() if 'unit' not in key}
    table = PrettyTable()
    table.field_names = ['cell', 'expected_throughput', 'actual_throughput']
    for cell in expected_throughput.keys():
        table.add_row([cell, expected_throughput[cell], scenario_throughput[cell]])
        ul_ok = validate_against_margin(expected_throughput[cell]['ul'],
                                        scenario_throughput[cell]['throughput_ul'], margin)
        dl_ok = validate_against_margin(expected_throughput[cell]['dl'],
                                        scenario_throughput[cell]['throughput_dl'], margin)
    logging.info(table)
    return {'ul': ul_ok, 'dl': dl_ok, 'test_result': ul_ok and dl_ok}


def validate_against_margin(expected_throughput, actual_throughput, margin):
    lower_throughput, higher_throughput = get_value_with_margin(expected_throughput, margin['percent'], mode='percent')
    result = lower_throughput < actual_throughput < higher_throughput
    if result:
        return result
    logging.warning('The throughput does not match the expected throughput.'
                    '\n\texpected_throughput: %s\n\tactual_throughput:%s',
                    expected_throughput, actual_throughput)
    lower_throughput, higher_throughput = get_value_with_margin(expected_throughput, margin['fixed'], mode='fixed')
    result = lower_throughput < actual_throughput < higher_throughput
    logging.info('after checking with a fixed margin the result is %s', 'pass' if result else 'fail')
    return result


def validate_bearer_stats_traffic(log_path, ex_throughput, margin={'percent': 15, 'fixed': 0.5}):
    actual_throughput = get_tp_dict(log_path)
    logging.info('actual throughput found: %s', actual_throughput)
    if not actual_throughput:
        logging.warning('There was no data collected from bearer stats for this scenario. '
                        'Test will be passed by default.')
        return {}, True
    table = PrettyTable()
    table.field_names = ['UE', 'expected throughput', 'actual throughput']
    per_ue_result = {}
    overall_result = True
    for ue, ex_throughput in ex_throughput.items():
        if ex_throughput['ul'] == 0 and ex_throughput['dl'] == 0:
            logging.info('no thorughput in bearer stats for ue %s, skipping', ue)
            continue
        per_ue_result.update({ue: {'ul': False, 'dl': False}})
        try:
            per_ue_result[ue]['ul'] = validate_against_margin(ex_throughput['ul'],
                                                              actual_throughput[f'UE_{ue}']['UL'], margin)
            per_ue_result[ue]['dl'] = validate_against_margin(ex_throughput['dl'],
                                                              actual_throughput[f'UE_{ue}']['DL'], margin)
            table.add_row([ue, ex_throughput, actual_throughput[f'UE_{ue}']])
            if not per_ue_result[ue]['ul'] or not per_ue_result[ue]['dl']:
                overall_result = False
                logging.error('traffic is not correct on AP for UE %s!', ue)
        except KeyError as e:
            logging.warning('key error for: %s', e)
    logging.info(table)
    return per_ue_result, overall_result


if __name__ == "__main__":
    print(get_value_with_margin(300))
    log_path = '/home/ute/logs/test_TEAL_template/2024-01-25T15-45-19-P/'\
        'test_TEAL_template/SBTS00_ENB_9999_240124_000012/20240125_154540/Logs/'\
        'PMC/gnb_pm_counters/pmc_average_tp_per_scenario_per_cell.json'
    expected_throughput = {'1': {'dl': 200, 'ul': 100}}
    print(validate_traffic_for_scenario('scenario_1', log_path, expected_throughput))
