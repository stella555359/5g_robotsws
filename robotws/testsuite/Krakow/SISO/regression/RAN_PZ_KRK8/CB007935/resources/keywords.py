import re
import time
from datetime import datetime
from robot.api import logger
import pexpect
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import AdminConnection
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations
from taf.rfrl.bts.devices.ru.ru_operations import GenericRuOperations
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK8.CB007935.resources.variables import parameter_distnames

ru_type = BuiltIn().get_variable_value(f"${{{'ru_type'}}}")


def check_cells_statuses(availability_status):
    cells = {"rmod": ['21', '22'], "asirmod": ['27']}
    cells_ru = cells[ru_type]
    cell_ops = GenericCellOperations()
    for cell in cells_ru:
        cell_ops.verify_cell_statuses(cell_id=cell, availability_status=availability_status)


def verify_cells_statuses(availability_status="degraded"):
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s", "check_cells_statuses", availability_status)


def get_last_5min_interval_timestamp():
    now = datetime.now()
    minute = (now.minute // 5) * 5
    rounded = now.replace(minute=minute, second=0, microsecond=0)
    return int(rounded.timestamp())


def get_last_deepest_key_value(d):
    last_key = None
    while isinstance(d, dict) and d:
        last_key = list(d)[-1]
        d = d[last_key]
    return last_key, d


def check_counter_doesnt_exist(counter_id):
    coam_admin = AdminConnection()
    counters_and_expected_values = {counter_id: int(0), }
    counters_to_get = ','.join(counters_and_expected_values.keys())
    cnt_resp = coam_admin.get_pm_counters(counter_ids=counters_to_get, timeout=600)
    key, curr_val = get_last_deepest_key_value(cnt_resp)
    curr_time = get_last_5min_interval_timestamp()
    assert int(curr_time - 300) != int(key), 'counter does exist'


def verify_counter_doesnt_exist(counter_id):
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s", "check_counter_doesnt_exist",
                          counter_id[ru_type])


def verify_pm_counter_value(counter_id, verification, expected_value):
    coam_admin = AdminConnection()
    counters_and_expected_values = {counter_id: int(expected_value), }
    counters_to_get = ','.join(counters_and_expected_values.keys())
    cnt_resp = coam_admin.get_pm_counters(counter_ids=counters_to_get, timeout=600)
    key, curr_val = get_last_deepest_key_value(cnt_resp)
    curr_time = get_last_5min_interval_timestamp()
    assert int(curr_time - 300) == int(key), 'counter doesnt exist'
    if verification == 'is not':
        assert int(curr_val) != int(expected_value), f"Expected not {expected_value}, but got {curr_val}"
    else:
        assert int(curr_val) == int(expected_value), f"Expected {expected_value}, but got {curr_val}"


def verify_pm_counter_last_value(counter_id, verification, expected_value):
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s", "verify_pm_counter_value", counter_id[ru_type],
                          verification, expected_value)


def read_measurement_file():
    ru = GenericRuOperations()
    ru_id = 0 if ru_type == 'asirmod' else 1
    ru_dev = ru.get_ru_device(ru_id=ru_id)
    cat_frips = ru_dev.get_cmd(cmd_name="cat", cmd_params={"path": '/rpram/hwapi/sync/SyncE_MTIE_measurements.txt'})
    output = cat_frips()['LINES']
    file_content = "\n".join(output)
    logger.info(f'\nmeasurement file content:\n{file_content}\n')
    return file_content


def check_measuremet_file_length(expected_lines):
    def count_numeric_lines(text):
        pattern = re.compile(r'^-?\d+(\.\d+)?$')
        return sum(1 for line in text.splitlines() if pattern.fullmatch(line.strip()))

    file_content = read_measurement_file()
    number_of_num_lines = count_numeric_lines(file_content)
    assert abs(
        number_of_num_lines - expected_lines) <= 1, f"Expected {expected_lines} lines, but got {number_of_num_lines}"


def verify_measurement_file_length(expected_lines=5):
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s", "check_measuremet_file_length", expected_lines)


def check_measurement_file_doesnt_exist():
    file_content = read_measurement_file()
    assert "No such file or directory" in file_content, 'File does exist'


def verify_measurement_file_doesnt_exist():
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s", "check_measurement_file_doesnt_exist")


def execute_commands_on_switch(commands):
    if ru_type == 'asirmod':
        host = '10.253.176.155'
    else:
        host = "10.255.27.97"
    ssh_user = "cli"
    username = "admin"
    password = "Admin@1830"
    child = pexpect.spawn(f"ssh {ssh_user}@{host}", encoding='utf-8')
    child.expect("Username:")
    child.sendline(username)
    child.expect("Password:")
    child.sendline(password)
    child.expect(r"Do you acknowledge\? \(Y/N\)\s*")
    child.sendline("Y")
    child.expect("#")
    for cmd in commands[ru_type]:
        child.sendline(cmd)
        child.expect("#")
    child.sendline("exit")
    child.close()


def check_existance_of_nan_values_in_measurement_file(should_exist, minutes):
    file_content = read_measurement_file()
    lines = file_content.strip().splitlines()
    numeric_lines = []
    for line in lines:
        line = line.strip()
        try:
            float(line)
            numeric_lines.append(line)
        except ValueError:
            if line.lower() == 'nan':
                numeric_lines.append(line)
    last_x = numeric_lines[-int(minutes):]
    if should_exist:
        assert any(
            line.lower() == 'nan' for line in last_x), f'There are no Nan values in meas file last {minutes} minutes'
    else:
        assert not any(
            line.lower() == 'nan' for line in last_x), f'There are Nan values in meas file last {minutes} minutes'


def verify_existance_of_nan_values_in_measurement_file(should_exist=True, minutes=60):
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s",
                          "check_existance_of_nan_values_in_measurement_file", should_exist, minutes)


def verify_radio_unit_availability_status(availability_status='offline'):
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s",
                          "ru_operations.verify_radio_unit_statuses", f"availability_status={availability_status}",
                          f"radio_type={ru_type}")


def reset_radio_unit():
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s",
                          "ru_operations.reset_radio_unit_from_GUI", f"radio_type={ru_type}")


def verify_radio_unit_is_online():
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s",
                          "ru_operations.verify_radio_unit_is_online", f"radio_type={ru_type}")


def verify_alarms_not_active(alarms_to_be_verified):
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s",
                          "Alarms.Verify Alarms Are Not Active", f"alarms_to_be_verified={alarms_to_be_verified}")


def check_syncestatus_not_exist():
    builtin = BuiltIn()
    du_operations = GnbDuOperations()
    distname = {parameter_distnames[ru_type]['synceStatus']: {'synceStatus': 'OK'}}
    try:
        return du_operations.verify_configuration_parameters_values(param_dict=distname)
    except Exception as e:
        error_message = str(e)
        if f"'synceStatus' doesn't exist in bts configuration" in error_message:
            builtin.log(f"Ignoring known error: {error_message}", level='WARN')
            return
        raise AssertionError(f"synceStatus should not exist")


def verify_syncestatus_not_exist():
    BuiltIn().run_keyword("Wait Until Keyword Succeeds", "40x", "20s", "check_syncestatus_not_exist")


def retry_until_success(func, attempts, interval_seconds, *args, **kwargs):
    last_exception = None

    for attempt in range(1, attempts + 1):
        try:
            result = func(*args, **kwargs)
            print(f"Attempt {attempt}: Success")
            return result
        except Exception as e:
            print(f"Attempt {attempt} failed: {e}")
            last_exception = e
            if attempt < attempts:
                time.sleep(interval_seconds)

    print(f"All {attempts} attempts failed.")
    raise last_exception


def verify_parameter_value(parameter, value):
    du = GnbDuOperations()
    param_dict = {parameter_distnames[ru_type][parameter]: {parameter: str(value)}}
    retry_until_success(du.verify_configuration_parameters_values,
                        attempts=40, interval_seconds=20, param_dict=param_dict)
