import re
from robot.libraries.BuiltIn import BuiltIn

COLORS = {
    'RESET': '\033[0m',
    'RED': '\033[91m',
    'GREEN': '\033[92m',
}

expected_load = {"GBR": ['>0', '>=0', '>0', '>=0'],
                 "nGBR": ['0', '>0', '>0', '>0'],
                 "GBR+nGBR": ['>0', '>0', '>0', '>0'],
                 "CB008745_OFF": ['0', '>0', '>0', '0']  # there is no distinction between GBR and nGBR traffic
                 }


def verify_energy_saving_measurement(cell_id, traffic_type, gnb_syslog):
    if traffic_type not in expected_load:
        raise Exception("Traffic type not expected, use one of {}".format(expected_load.keys()))

    with open(gnb_syslog, 'r') as syslog:
        for line in syslog:
            pattern = r"EnergySavingAlgorithm.*nrCellIdentity:{}.*average=\[\d+, \d+, \d+, \d+\]".format(cell_id)
            if re.search(pattern, line):
                # print(line)
                expression = re.search(r"\[\d+, \d+, \d+, \d+]", line)
                received_measurement = re.findall(r'\d+', expression.group(0))
                expected_measurements = expected_load[traffic_type]
                zipped = zip(received_measurement, expected_measurements)

                for received, expected in zipped:
                    if is_received_measurement_not_expected(received, expected):
                        BuiltIn().log(COLORS['RED'] + "expected: {}".format(expected_measurements)
                                      + COLORS['RESET'], console=True)
                        BuiltIn().log(COLORS['RED'] + "received: {}".format(received_measurement)
                                      + COLORS['RESET'], console=True)
                        raise Exception("received {} and expected {} measurements are not equal"
                                        .format(received_measurement, expected_measurements))
                BuiltIn().log(COLORS['GREEN'] + "received: {}".format(received_measurement)
                              + COLORS['RESET'], console=True)
                break


def is_received_measurement_not_expected(received, expected):
    is_received_not_eq_zero = bool(int(received))
    if is_received_not_eq_zero and expected == '0':
        return True
    if not is_received_not_eq_zero and expected == '>0':
        return True
    return False


if __name__ == "__main__":
    syslog_file = '/home/ute/results/test/AdmCon_EnhancedVoNR_EnhVoNR_True_CB008379_False_GBR'
    verify_energy_saving_measurement(16386, "nGBR", syslog_file)
