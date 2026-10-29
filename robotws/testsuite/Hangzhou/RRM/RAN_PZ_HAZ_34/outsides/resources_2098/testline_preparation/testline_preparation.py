import socket
import time
import os
import urllib
from taf.sbts.oam.coam.admin import admin
import testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.rrm_fixture as fixture

admin = admin()
current_trunk_branch = '22R1'


def check_tl_type(tl_type):
    assert tl_type in ['sa', 'nsa', 'concurrent'], 'Please state if the testline is of sa, nsa or concurrent type'


def prepare_lte(scf_path, enb_scf):
    mplane = fixture.get_robot_variable('${tl.enbs[0].x2_link_addr.v4}')
    connection = admin.connect_to(bts_host=mplane)
    scf_path = scf_path.replace('_5g.xml', '_4g.xml') if not enb_scf else enb_scf
    upload_scf(scf_path, connection=connection)
    time.sleep(300)

    incompatible_rmod_sw_found = check_lte_alarms(connection=connection)
    if incompatible_rmod_sw_found:
        update_lte_rmod_sw(connection=connection)
        is_alarm_still_up = check_lte_alarms(connection=connection)
        assert not is_alarm_still_up, 'RMOD software is still incompatible'

    connection.disconnect()
    admin.teardown(connection=connection)


def check_lte_alarms(connection):
    alarms = admin.get_active_alarms(connection=connection)
    return check_alarms(alarms)


def update_lte_rmod_sw(connection):
    sw_version = admin.get_sw_version(connection=connection).replace(current_trunk_branch, '00')
    sw_dir = download_sw_package(sw_version)
    for _ in range(2):
        try:
            admin.update_software(sw_dir, timeout=1200, connection=connection)
            break
        except Exception as e:
            print(e)
    time.sleep(180)
    os.remove(sw_dir)


def get_config_dir():
    return 'custom-config/Wroclaw/{}'.format(socket.gethostname().replace('-', '_'))


def get_branch(software_name):
    return 'trunk' if current_trunk_branch in software_name else software_name.replace("SBTS", "").replace("5G", "")


def get_scf_path(execdir, sw_name, config_dir):
    return str(execdir + '/' + config_dir + '/' + get_branch(sw_name) + '/' +
               config_dir.split('/')[-1] + '_' + get_branch(sw_name) + '_5g.xml')


def upload_scf(scf_path, connection):
    admin.perform_commissioning(scf_path, skip_parameter_relation_errors=False, connection=connection)


def check_alarms(alarms):
    for alarm in alarms:
        if str(alarm['alarmId']) == '7111':
            return True
    return False


def download_sw_package(sw_version):
    url = get_download_link(str(sw_version))
    _file = '/tmp/' + url.split('/')[-1]
    if os.path.isfile(_file):
        return _file
    print("Downloading {url} to {path}".format(url=url, path=_file))
    urllib.urlretrieve(url, _file)
    return _file


def get_download_link(sw_version):
    link = _get_download_link_sbts(sw_version) if 'SBTS' in sw_version else _get_download_link_5g(sw_version)
    assert urllib.urlopen(link).code == 200, "Link not valid {}".format(link)
    return link


def _get_download_link_sbts(sw_version):
    link = 'https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/{branch}/{sw}_release_BTSSM_downloadable_A54.zip'
    return link.format(branch=sw_version.split("_")[0].replace(current_trunk_branch, '00'),
                       sw=sw_version.replace(current_trunk_branch, '00'))


def _get_download_link_5g(sw_version):
    repo_5g = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/"
    sw = ".".join([x.lstrip('0') if x.lstrip('0') is not '' else '0' for x in sw_version.split('_')[-3:]])
    link = "{repo}{sw}/AirScale-{sw}.zip"
    return link.format(repo=repo_5g, sw=sw)


def update_software_for_rmods(software, connection):
    sw_path = download_sw_package(sw_version=software)
    admin.update_software(sw_package=sw_path, timeout=1200, connection=connection)


def check_if_x2_alarm_is_gone(alarms):
    return False if [alarm for alarm in alarms if str(alarm['alarmId']) == '7107'] else True
