import copy
import logging
import os
import re
import sys
from ta_emss import ta_emss
from ute_wtssim import ute_wtssim
import subprocess
import time
from ta_messaging.interface import ta_messaging, messaging_context, MessageManager
from ta_messaging.alias_factory import get_alias_factory
from ta_messaging.logger import core_logging  # configure_debug_level, get_logging_path


def _get_python_version():
    return sys.version_info


raw_input = input if _get_python_version() >= (3, 0) else raw_input

try:
    with open('/tmp/.manual_egate_out', 'r') as f:
        p = int(f.read().strip())
        p1 = p+1
        p2 = p+2
        subprocess.Popen('kill -9 {} {} {}'.format(p, p1, p2), shell=True)
except Exception:
    pass


cmd_sleep_time_default = 0.5
cmd = """xterm -T 'EPCSIM LOG' -geometry 200x30  -hold -e 'tail -f /opt/iphy/latest/egate_console.log | \
sed --unbuffered s"/\\[session.*/\\n\x1b[31m&\x1b[0m\\n\\n/g"'"""
yaml_root = '/home/ute/MN/UTE/robotws/'
p = subprocess.Popen(cmd, shell=True)
with open('/tmp/.manual_egate_out', 'w') as f:
    f.write(str(p.pid))
u = ute_wtssim()
t = ta_emss()
u.setup_egate(egate_port=20000)
u.execute_egate_command('state_sim_disp')
u.execute_egate_command('set_log flush')

csv_logger_prefixes = []


def kill_started_procs():
    to_kill = []
    try:
        with open('/tmp/.manual_proc_started', 'r') as f:
            procs = re.findall(r'\d+', f.read())
            for proc in procs:
                p0 = int(proc.strip())
                p1 = p + 1
                p2 = p + 2
                to_kill.append(str(p0))
                to_kill.append(str(p1))
                to_kill.append(str(p2))
            processes = " ".join(to_kill)
            subprocess.Popen('kill -9 {}'.format(processes), shell=True)
    except Exception:
        pass


def read_test_file():
    if len(sys.argv[1]) > 1:
        with open(sys.argv[1], 'r') as f:
            content_list = f.readlines()
    return content_list


def parse_cmd_line(cmd_line):
    if '#' in cmd_line:
        return -1, None
    elif 'exit' in cmd_line:
        return -2, None
    elif len(re.findall(r'sleep (\d+)', cmd_line)) > 0:
        return -3, re.findall(r'\d+', cmd_line)[0]
    elif '$' in cmd_line:
        return -4, re.findall(r'\S+\.yaml', cmd_line)[0]
    elif 'pause' in cmd_line:
        params = re.findall(r'\s*pause\s*;?\s*(\S?.*)', cmd_line)
        return -5, params[0] if params[0] != '' else None
    elif '%' in cmd_line:
        return -6, re.findall(r'\s*\%\s*(\S.*)', cmd_line)[0]
    elif '!' in cmd_line:
        return -7, re.findall(r'\s*!\s*(\S.*)', cmd_line)[0]
    elif '+parse' in cmd_line:
        return -8, re.findall(r'\+parse\s*;?\s*(\S?.*)', cmd_line)[0]
    elif '+clear' in cmd_line:
        return -9, None
    else:
        return 0, None


def setup_emss_and_configure_yaml(yaml_list):
    t.setup_emss(bts_id=1)
    full_yaml_path = []
    for yaml in yaml_list:
        yaml_path = os.sep.join([yaml_root, yaml])
        assert os.path.exists(yaml_path), 'Path: {} does not exists'.format(yaml_path)
        full_yaml_path.append(yaml_path)
    t.configure(full_yaml_path)


def setup_emss_and_reconfigure_param(delta_string):
    t.setup_emss(bts_id=1)
    t.configure(delta_string)


def create_messaging_aliases():
    ta_mess_inst = get_alias_factory()
    ta_mess_inst.create_ues_alias(alias='UE', id_type='wts_5g')
    ta_mess_inst.create_ap_protocols_alias(device='gNB', alias='gNB2', ids={'ip': '10.0.1.2'})
    ta_mess_inst.create_ap_protocols_alias(device='AMF', alias='AMF', ids={'ip': '10.0.1.1'})


def run_script(script):
    p = subprocess.Popen(script, shell=True)
    p.communicate()


def parse_messaging_logs(no_sleep=False, folder_suffix=None):
    if no_sleep is False:
        print('Sleeping 5s to allow logs to populate')
        time.sleep(5)
    for s in list(MessageManager()._sources.values()):
        for ss in s:
            for source_prefix in list(ss.additional_csv_loggers.keys()):
                if not os.path.exists(source_prefix):
                    timestamp_folder = source_prefix.split('_')[0]
                    if folder_suffix is not None:
                        timestamp_folder = "{}_{}".format(timestamp_folder, re.sub(r'\s+', '_', folder_suffix))
                    os.system('mkdir {}'.format(timestamp_folder))
                ss.release_additional_csv_logger(source_prefix)
                print('Parsing CSV logs for: {}'.format(s))
                ss.parse_csv_logs(source_prefix)
                parsed_log_filepaths = find_parsed_csv_logs(source_prefix)
                for parsed_log in parsed_log_filepaths:
                    os.system('mv {} {}/.'.format(parsed_log, timestamp_folder))


def find_parsed_csv_logs(prefix=None):
    '''
    find csv logs within path
    '''
    log_path = core_logging.get_logging_path()
    files = os.listdir(log_path)
    if prefix is None:
        csv_logs = [os.path.join(log_path, log) for log in files if 'PARSED' in log]
    else:
        csv_logs = [os.path.join(log_path, log) for log in files if 'PARSED' in log and prefix in log]
    return csv_logs


def clear_messaging_logs():
    for s in list(MessageManager()._sources.values()):
        for ss in s:
            prefix = str(int(time.time()))
            ss.setup_additional_csv_logger(prefix)
            csv_logger_prefixes.append(prefix)


def extract_cmd_params(param_list):
    all_params = {'output': None,
                  'sleep_time': None}
    param_list = copy.deepcopy(param_list)
    if 'o' in param_list:
        all_params['output'] = True
        param_list.remove('o')
    if len(param_list):
        try:
            for p in param_list:
                all_params['sleep_time'] = int(p.strip())
                break
        except Exception:
            pass
    return all_params


def execute_test_lines(list_of_lines):
    yaml_to_configure = []
    for cmd_line in list_of_lines:
        cmd_line = cmd_line.strip()
        if cmd_line:
            print("## {} ##".format(cmd_line))
            result, result_params = parse_cmd_line(cmd_line)
            if result == 0:
                if len(yaml_to_configure):
                    setup_emss_and_configure_yaml(yaml_to_configure)
                    yaml_to_configure = []
                cmd_and_params_list = cmd_line.split(';')
                cmd = cmd_and_params_list[0]
                all_params = extract_cmd_params(cmd_and_params_list[1:])
                sleep_time = all_params['sleep_time']
                if all_params['output'] is not None:
                    u.execute_egate_command_and_wait_for_data(cmd)
                else:
                    u.execute_egate_command(cmd)
                if sleep_time:
                    cmd_sleep_time = sleep_time
                else:
                    cmd_sleep_time = cmd_sleep_time_default
                time.sleep(cmd_sleep_time)
                u.execute_egate_command('set_log flush')
                time.sleep(cmd_sleep_time_default)
            elif result == -1:
                continue
            elif result == -2:
                exit(0)
            elif result == -3:
                time.sleep(int(result_params))
            elif result == -4:
                yaml_to_configure.append(result_params)
            elif result == -5:
                if len(yaml_to_configure):
                    setup_emss_and_configure_yaml(yaml_to_configure)
                    yaml_to_configure = []
                if result_params is not None:
                    prompt = "\nPausing, {}, press <enter> to continue...\n".format(result_params)
                else:
                    prompt = "'\nPausing, press <enter> to continue...\n'"
                raw_input(prompt)
            elif result == -6:
                setup_emss_and_reconfigure_param(result_params)
            elif result == -7:
                run_script(result_params)
            elif result == -8:
                if result_params is not None:
                    folder_suffix = result_params
                else:
                    folder_suffix = None
                parse_messaging_logs(folder_suffix=folder_suffix)
            elif result == -9:
                clear_messaging_logs()

        else:
            continue


if __name__ == '__main__':
    file_lines = read_test_file()
    core_logging.debug_level = 'TRACE'
    with messaging_context():
        create_messaging_aliases()
        print(core_logging.get_logging_path)
        execute_test_lines(file_lines)
    time.sleep(5)
