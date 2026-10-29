import re


def get_pmtu(output_str):
    pattern = re.compile(r'Resume: pmtu (\w+)')
    result = re.search(pattern, output_str)
    return result.group(1)


def GET_test_RU_IP(file_path):
    with open(file_path, 'r') as f:
        data = f.readline()
        data_list = data.split(';')
        return data_list[2]


def GET_lxc_active(file_path):
    with open(file_path, 'r') as f:
        data = f.readline()
        data_list = data.split(' ')
        return data_list[0]


def GET_attach_PID(file_path):
    fp = open(file_path, 'r')
    N_lines = 5
    while N_lines > 0:
        data = fp.readline()
        N_lines -= 1
        data_list = data.split(' ')
        if '/opt/CCS/CCSDaemonExe' in data_list:
            start_pid = data_list[5]
            break
    return start_pid
    fp.close()


def read_log_alarm(file_path, alarm_id):
    fp = open(file_path, 'r')
    read = fp.read()
    regex = re.compile(alarm_id)
    alarm_list = regex.findall(read)
    return alarm_list
