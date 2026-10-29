import os
import re
import time
import argparse
from taf.sbts.oam.coam.admin import admin
from robot.api import logger

skip_bts_upgrade_faults = [10,]
white_faults_list = [23, 49, 4592, 2922, 2923, 4459, 4655, 4654, 61524, 61652, 61631, 61649]
black_faults_list = [4590, 2087, 6450]
build_information = '/home/ute/Downloads/BTS_BUILD_INFORMATION'
latest_version_file = '/home/ute/Downloads/VERSIONS_INFORMATION'
api = admin()


def get_build_information_file(build_information):
    if os.path.exists(build_information):
        os.popen('cat {}'.format(build_information)).read()
    else:
        print(os.popen('touch {}'.format(build_information))).read()


def update_build_information_file(bts_id, build_version, build_information):
    get_build_information_file(build_information)
    isExisted = os.popen('cat {} | grep {}'.format(build_information, str(bts_id))).read().strip()
    logger.console('The last version  :  {}'.format(isExisted))
    if isExisted:
        os.popen("sed -i 's/{}/MRBTS-{}={}/g' {}".format(isExisted, str(bts_id), build_version, build_information))
    else:
        os.popen("echo MRBTS-{}={} >> {}".format(str(bts_id), build_version, build_information))


def bts_upgrade(bts_host, build_file, build_information):
    assert os.path.isfile(build_file), '[ERROR]Not Found: {}'.format(build_file)
    build_version = build_file[build_file.rfind('SBTS'):].strip('.zip')
    result = os.popen('ping -c 5 {}'.format(bts_host)).read().strip()
    print(result)
    if '100% packet loss' in result:
        return ('Not Pingable or wrong bts ip.', 'MRBTS-?')
    try:
        connection = api.setup_admin(bts_host, name='upgrade')
        btsinfo = connection.get_bts_info()
        bts_id = btsinfo['mrbtsID']
        update_build_information_file(bts_id, '', build_information)  # init build_information to None for bts

        get_bts_alarms(connection, bts_id, alarm_management='active', check_alarm=False)

        cur_build = connection.get_sw_version()
        logger.console("\n[MRBTS-{}] SW updating ... ...\n".format(str(bts_id)) + '-'*(65+len(cur_build)))
        logger.console("[{}] Current Build Version    :    {}".format(current_time(), cur_build))
        logger.console("[{}] Upgrade Build Version    :    {}".format(current_time(), build_version))
        logger.console("[{}] BTS upgrade              :    Starting".format(current_time()))
        connection.update_software(sw_package=build_file, timeout=3000)
        logger.console("[{}] BTS upgrade              :    Downloaded and activated".format(current_time()))
        time.sleep(90)
        logger.console("[{}] Waiting BTS onair        :    Ongoing".format(current_time()))
        execution_and_wait('ping -c 5 {}'.format(bts_host), '5 received, 0% packet loss')

        # check admin api status_and_reconnection if needed
        api_status = os.popen('ps -ef | grep node').read()
        if bts_host not in api_status:
            logger.console('[1]api.setup_admin reconnection ...')
            connection = api.setup_admin(bts_host, name='upgrade')
        isOnair = wait_bts_onair(bts_connection=connection, timeout=900, sleep_time=30)
        assert isOnair, '[ERROR]BTS is NOT OnAir after upgraded.'
        new_build = connection.get_sw_version()
        update_build_information_file(bts_id, new_build, build_information)

        logger.console("\n[MRBTS-{}] Check faults after sw upgrade ... ...".format(str(bts_id)))
        get_bts_alarms(connection, bts_id, alarm_management='active', check_alarm=True)
        get_bts_alarms(connection, bts_id, alarm_management='history', check_alarm=True)
        return (None, 'MRBTS-{}'.format(bts_id))
    except Exception as e:
        logger.console(repr(e))
        if 'http sessionId invalid' in str(e):
            logger.console('[2]api.setup_admin reconnection ...')
            connection = api.setup_admin(bts_host, name='upgrade')
        else:
            logger.console('[ERROR][MRBTS-{}] Saving snapshot ... ...'.format(str(bts_id)))
            snapshot = api.get_snapshot(
                target_file_name=(
                    r'/home/ute/Downloads/Snapshot_MRBTS-{}_{}_{}.zip'.format(
                        str(bts_id),
                        build_version,
                        time.strftime("%Y%m%d-%H%M", time.localtime())
                    )
                ),
                connection=connection
            )
            logger.console(snapshot)
        return (repr(e), 'MRBTS-{}'.format(bts_id))
    finally:
        # UnboundLocalError: local variable 'connection' referenced before assignment
        # api.teardown_admin before connection execute and assignment
        try:
            api.teardown_admin(connection)
        except UnboundLocalError as e:
            logger.console(repr(e))
            return ('Not Pingable or wrong bts ip', 'MRBTS-{}'.format(bts_id))


def get_bts_alarms(connection, bts_id, alarm_management='active', check_alarm=False):
    if alarm_management == 'active':
        faults = connection.get_active_alarms()
    else:
        faults = connection.get_historic_alarms(load_history=True, timeout=60)
    if not faults:
        logger.console('\n[MRBTS-{}] No {} Alarms ...\n'.format(bts_id, alarm_management) + '-' * 95)
        return
    faults = sorted(faults, key=lambda x: x['btsObservationTime'])
    logger.console(
        '\n[MRBTS-{}] {} Alarms ...\n'.format(bts_id, alarm_management) + '-' * 95
    )
    GMT = faults[0]['btsObservationTime'].split('+')[-1]
    logger.console(
        '| faultId | faultName%40s  | severity | Appeard GMT+%s\n' % (' ', GMT) + '-' * 95
    )
    for fault in faults:
        appeard = fault['btsObservationTime'].split('+')[0]
        logger.console(
            '| %-7d | %-50s | %-8s | %s' % (fault['faultId'], fault['faultName'], fault['severity'], appeard)
        )
        if fault['faultId'] in skip_bts_upgrade_faults:
            raise Exception(
                '[ERROR]Skip the sw upgrade because of some active faults{}'.format(fault['faultId'])
            )
        if fault['faultId'] in black_faults_list:
            raise Exception(
                '[ERROR]Black list fault {} in {} faults'.format(fault['faultId'], alarm_management)
            )
        if check_alarm:
            assert fault['faultId'] in white_faults_list, (
                f"[ERROR] {fault['faultId']} in {alarm_management} faults"
            )


def current_time():
    return time.strftime("%Y-%m-%d %X", time.localtime())


def wait_bts_onair(bts_connection, timeout=60, sleep_time=30):
    start_time = time.time()
    isOnAir = False
    logger.console("\nBTS Status:\n" + '-'*95)
    while isOnAir or (time.time() - start_time) <= timeout:
        try:
            bts_status = bts_connection.get_mrbts_state()
        except Exception as e:
            logger.console(repr(e))
            bts_status = 'Querying ... ...'
        if bts_status == 'OnAir':
            logger.console('[{}] BTS proceduralState      :    {}'.format(current_time(), bts_status))
            isOnAir = True
            break
        else:
            logger.console('[{}] BTS proceduralState      :    {}'.format(current_time(), bts_status))
            time.sleep(sleep_time)
    return isOnAir


def execution_and_wait(command, pass_tag, timeout=60, sleep_time=20):
    start_time = time.time()
    while (time.time() - start_time) <= timeout:
        result = os.popen(command).read().strip()
        if pass_tag in result:
            break
        else:
            time.sleep(sleep_time)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Personal information')
    parser.add_argument('-ip', '--bts_host', dest='bts_host', type=str, default='192.168.255.1',
                        help='bts host ip address. default is 192.168.255.1')
    parser.add_argument('-b', '--build_file', dest='build_file', type=str, default='', help='build file path')
    args = parser.parse_args()
    if args.build_file:
        build = args.build_file
    else:
        build = os.popen('cat {} | grep build='.format(latest_version_file)).read().strip().strip('build=')
    assert build, '[ERROR]build is null'
    build_zip = build if build.endswith('.zip') else build + '.zip'
    build_file = build_information.rsplit('/', 1)[0] + '/' + build_zip
    isFailed_dict = {}
    for ip in re.split(r'[,;]', args.bts_host.strip().replace(' ', '')):
        logger.console('><' * 58)
        logger.console('bts_host          : {}'.format(ip))
        logger.console('build             : {}'.format(build))
        logger.console('path              : {}'.format(build_file))
        logger.console('build_information : {}'.format(build_information))
        if not ip:
            logger.console('[ERROR]wrong_ipaddr: {}'.format(ip))
            continue
        result = bts_upgrade(ip, build_file, build_information)
        isFailed_dict[ip] = result
    print(isFailed_dict)
    logger.console("\nBTS update summary:\n" + '-'*95)
    logger.console("| bts id%-6s | host ip%-8s | sw update%s | failed reason\n" % (' ', ' ', ' ') + '-'*95)
    for bts, state in isFailed_dict.items():
        upgrade_stat = 'Updated' if state[0] is None else 'Not update'
        logger.console("| %-12s | %-15s | %-9s | %-s" % (state[1], bts, upgrade_stat, state[0]))
    if None not in set(map(lambda x: x[0], isFailed_dict.values())):
        logger.console("\n[ERROR] All gNB is failed to upgrade")
        raise FutureWarning
    isLatest_init = os.popen("sed -i 's/isLatest=.*/isLatest=/g' {}".format(build_information)).read().strip()
    logger.console(isLatest_init)
