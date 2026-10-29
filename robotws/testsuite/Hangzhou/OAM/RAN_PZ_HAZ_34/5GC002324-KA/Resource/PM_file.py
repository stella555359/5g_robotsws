import re
import taf.gnb.oam.ne3s.ws as netact
import taf.config.scf as scf


def connect_using_netact(
        ip_address, netact_server_address=None, netact_server_port=10000, **kwargs):
    na_instance = netact.ws()
    na_instance.configure_connection(ip_address, netact_server_address=netact_server_address,
                                     netact_server_port=netact_server_port, **kwargs)
    if 'alias' in kwargs:
        na_instance.connect(kwargs['alias'])
    else:
        na_instance.connect()
    return na_instance


def fetch_latest_pm_report(pm_file_path, na_instance):
    na_instance.fetch_latest_pm_report(pm_file_path=pm_file_path)


def Check_pm_files_on_oam(output):
    re_command = '[0-5]\\d:[0-5]\\d'
    result = re.findall(re_command, output)
    result_1 = ','.join(result)
    result_2 = re.split(',', result_1)
    time_list = []
    for item in result_2:
        data = item.split(':')
        time_data = data[1].split(':')
        time_value2 = time_data[0].strip()
        time_value2 = int(time_value2)
        time_list.append(time_value2)
    return time_list


def Check_config_is_correct(pmtime_list, time_value):
    time_value = time_value.split('min')[0]
    if len(pmtime_list) >= 2:
        for i in range(len(pmtime_list) - 1):
            if int(pmtime_list[i + 1]) - int(pmtime_list[i]) == int(time_value) or int(
                    pmtime_list[i + 1]) - int(pmtime_list[i]) == int(time_value) - 60:
                print ('check pass, exit loops')
                break
            elif i < len(pmtime_list) - 2:
                print ('continue check')
                continue
            else:
                print (
                    'check failed, please check reportingIntervalPm is correct or not')
                raise
    else:
        print ('PM files not enough to check')
        raise
