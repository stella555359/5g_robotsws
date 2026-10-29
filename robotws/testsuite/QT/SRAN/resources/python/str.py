from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime
import re
import os

ssh = ssh()


def handle_error_message_in_syslog(isCloud, pattern, file_path, grep_command, skip_regex_str):
    cmd = "grep {} -m 15 '{}' {}".format(grep_command, pattern, file_path)
    res = os.popen(cmd).read()
    res = re.sub(skip_regex_str, '', res).strip()
    if len(res) > 0:
        res_ful_cmd = "grep {} '{}' {}".format(grep_command, pattern, file_path)
        res_ful = os.popen(res_ful_cmd).read()
        if not isCloud:
            res_limit = re.sub(r'{}/[\w]+.LOG:[\d]+'.format(file_path), '', res)
            res_ful = re.sub(r'{}/[\w]+.LOG:[\d]+'.format(file_path), '', res_ful)
        pattern = re.compile(r'<[\d|\s|\S].*')
        res_limit = '\n'.join(pattern.findall(res))
        return res_limit, res_ful
    return False, False


def handle_error_message_in_site(pattern, file_path, skip_regex_str, alias):
    file_format = ssh.execute('ls {}*'.format(file_path), connection=alias).strip()
    if "xz" in file_format:
        xz_file = ssh.execute('readlink {}.xz'.format(file_path), connection=alias).strip()
        outcome = ssh.execute('xz -d {}'.format(xz_file), connection=alias)
        file_path = xz_file[0:-3]
    if ssh.file_exists(file_path, connection=alias):
        cmd = "grep -m 15 '{}' {}".format(pattern, file_path)
        res_limit = ssh.execute(cmd, connection=alias)
        res_limit = re.sub(skip_regex_str, '', res_limit).strip()
        if len(res_limit) > 0:
            res_ful_cmd = "grep '{}' {}".format(pattern, file_path)
            res_ful = ssh.execute(res_ful_cmd, connection=alias)
            res_ful = re.sub(skip_regex_str, '', res_ful).strip()
            return res_limit, res_ful
    return False, False


def handle_last_line_check(file_path, kw_regex, checkpoint_regex):
    cmd = "grep -i '{}' {}|tail -1".format(kw_regex, file_path)
    res = os.popen(cmd).read()
    print("lastline is {}".format(res))
    if len(res) > 0:
        match = re.search(checkpoint_regex, res)
        if match:
            print("match is {}".format(match.group()))
            return True, True
        else:
            ful_cmd = "grep '{}' {}|tail -1".format(kw_regex, file_path)
            res_ful = os.popen(ful_cmd).read()
            pattern = re.compile(r'<[\d|\s|\S].*')
            res = '\n'.join(pattern.findall(res))
            return res, res_ful
    return True, True


def check_container_state_via_supervisors(node, alias):
    cmd = "export PYTHONPATH=/opt/hwmt/python && python3 /opt/hwmt/python/hwapi/SupervisorS.py \
    -n {} -o list_cbts".format(node)
    output = ssh.execute(cmd, connection=alias)
    print(output)
    try:
        if 'timeout' not in output:
            contaiers_list = output.split('\r\n\r\n')
            if len(contaiers_list) < 4:
                msg = 'Get container Failed: {}'.format(output)
                return False, msg
            for i in range(2, len(contaiers_list)-1):
                node_name = contaiers_list[i].split('nodeName:')[1]
                if 'nodeState:3' in contaiers_list[i]:
                    msg = '{} check SUCCESS'.format(node_name)
                    return True, msg
                else:
                    msg = 'Container Failed: {}'.format(node_name)
                    return False, msg
        else:
            msg = 'SupervisorS command time out: {}'.format(output)
            return False, msg
    except Exception as err:
        msg = 'Decode container status failed due to error {}'.format(err)
        return False, msg


def log_scf_validation_error_details_from_log(pattern, file_path):
    cmd = "grep '{}' {}".format(pattern, file_path)
    res = os.popen(cmd).read()
    if len(res) > 0:
        regex = r'{}[\S]{{2}}\[[\s\S]+'.format(pattern)
        match = re.search(regex, res.splitlines()[0])
        if match:
            print("match is {}".format(match.group()))
            err_list = match.group().split('],')
            for err in err_list:
                print('err is {}'.format(err))
                if "errorDescription" in err:
                    err_name = err.split('":[')[0].replace('"', '')
                    err_desc = re.search(r'errorDescription[\s\S]+', err).group()
                    err_desc = err_desc.split('},{')[0].replace('"', '')
                    BuiltIn().log("Pls check SCF {}! {}".format(err_name, err_desc), "WARN")


def add_quotes_to_list(string):
    return ['"' + item + '"' for item in string.split()]


def compare_l3call_timestamp(l3call_failure_msg, traffic_end_timestamp_str, is_cloud):
    log_timestamp_str = ''
    try:
        if is_cloud:
            pattern = re.compile(r'\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')
            date_pattern = "%m-%dT%H:%M:%S"
        else:
            pattern = re.compile(r'\d{2}\.\d{2}\s[\d{2}:]+')
            date_pattern = "%d.%m %H:%M:%S"
        log_timestamp_str = pattern.findall(l3call_failure_msg)[0]
        print("log time stamp is {}".format(log_timestamp_str))
        print("traffic end timestamp is {}".format(traffic_end_timestamp_str))
        log_timestamp = datetime.strptime(log_timestamp_str, date_pattern)
        traffic_end_timestamp = datetime.strptime(traffic_end_timestamp_str, "%d.%m %H:%M:%S")
        if traffic_end_timestamp > log_timestamp or traffic_end_timestamp_str == "00:00:00":
            return [True, log_timestamp_str]
        else:
            return [False, log_timestamp_str]
    except Exception as err:
        print("compare l3call timestamp failed due to {}".format(err))
        return [True, log_timestamp_str]


def get_short_name_of_sbts_build(build):
    index = build.find('_')
    if index != -1:
        build = build[index+1:]
    return build


def get_apn_from_ue_info(info_dict):
    info_dict_standard = dict(info_dict)
    apn_dict = {k: v for k, v in info_dict_standard.items() if len(v) < 2}
    if not apn_dict:
        print("apn_dict is empty")
        return None
    else:
        apn = list(apn_dict.keys())[0]
        return apn


def remove_duplicate_lines(output, max_line_number=50):
    output_lines = output.splitlines()
    # Remove duplicate lines
    unique_lines = list(dict.fromkeys(output_lines))

    # Join the unique lines back into a single string
    unique_output = "\n".join(unique_lines[:max_line_number])

    return unique_output


if __name__ == '__main__':
    print(get_short_name_of_sbts_build('SBTS24R3_ENB_9999_240509_000017'))
    print(get_short_name_of_sbts_build('SBTS00_ENB_9999_240509_000017'))
