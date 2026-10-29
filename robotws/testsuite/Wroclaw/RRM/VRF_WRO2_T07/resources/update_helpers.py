import os
import re
from datetime import date, timedelta
from subprocess import call
import requests
from ute_common_admin.exception import AdminApiProcedureFailureException, AdminApiConnectionClosedException
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword, wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.timeouts import Timeouts

try:
    import urllib.request as urllib
except ImportError:
    import urllib as urllib

agent_tl_state = 'sw_uploaded'
agent_log_path = '/home/ute/agent_logs'
agent_output_path = '/home/ute/output'
agent_tl_label = tl.tl_cloud_topology
build_repo = 'http://files.ute.nsn-rdnet.net/builds/enb/base/'
artifactory = 'https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/'
z2_repo = 'https://lterel.es-si-s3-z2.eecloud.nsn-net.net/'
z4_repo = 'https://lterel.es-si-s3-z4.eecloud.nsn-net.net/'
trunk = '_ENB_9999_'
file_download_location = '/home/ute/.ute-ca/cache/bts/'
yesterday = (date.today() - timedelta(days=1)).strftime('%d-%b-%Y')


@logged_keyword
def agent5g_sw_downgrade_to_yesterday_candidate():
    run_agent5gclassical(sw_build=__get_last_candidate_number(from_date=yesterday,
                                                              release=__get_sw_release_name()),
                         log_path=agent_log_path, output_path=agent_output_path)


@logged_keyword
def reupload_current_sw():
    update_sw_using_admin(get_sw_version())


@wait_until_function_succeeds(retry_time_in_seconds=Timeouts.rollback, retry_interval_in_seconds=60,
                              exception=(AdminApiProcedureFailureException, AdminApiConnectionClosedException),
                              part_of_msg=('BTS is not ready', 'BTS is busy', 'Cannot establish socket connection'))
@logged_keyword
def sw_rollback():
    with AdminApi() as web_api:
        web_api.rollback_software(timeout=Timeouts.rollback)
    RequestsHandler().wait_until_server_is_unreachable()


@wait_until_function_succeeds(retry_time_in_seconds=Timeouts.admin_update, retry_interval_in_seconds=60,
                              exception=(AdminApiProcedureFailureException, AdminApiConnectionClosedException),
                              part_of_msg=('BTS is not ready', 'BTS is busy', 'Cannot establish socket connection'))
@logged_keyword
def update_sw_using_admin(sw_version):
    sw_path = download_sw_package(sw_version)
    with AdminApi() as web_api:
        admin_output = web_api.update_software(sw_package=sw_path, timeout=Timeouts.sw_update)
    return admin_output


@logged_keyword
def check_if_sw_is_downloaded(sw_version):
    file_to_search_1 = sw_version + '_release_BTSSM_downloadable'
    file_to_search_2 = sw_version + '_release_BTSSM_downloadable_A54'
    found_sw = None
    for root, _, files in os.walk(file_download_location):
        if file_to_search_2 in str(files):
            found_sw = file_to_search_2
        elif file_to_search_1 in str(files):
            found_sw = file_to_search_1

        if found_sw:
            blog('Found {sw_version} in local files, no need to download'.format(sw_version=sw_version))
            return os.path.join(root, found_sw + '.zip')


@logged_keyword
def download_sw_package(sw_version):
    sw_path = check_if_sw_is_downloaded(sw_version)
    if sw_path is None:
        blog('SW package {sw_version} NOT found locally, need to download'.format(sw_version=sw_version))
    else:
        return sw_path
    url = __get_download_link(str(sw_version))
    _file = file_download_location + sw_version + "/" + url.split('/')[-1]
    blog('Downloading {url} to {path}'.format(url=url, path=_file))
    path_to_download = "/".join(_file.split("/")[0:-1])
    os.system('wget ' + url + ' -t 5 -P ' + path_to_download)
    return _file


@logged_keyword
def __get_download_link(sw_version):
    if 'SBTS' in sw_version:
        link = __get_download_link_sbts(sw_version)
    else:
        link = __get_download_link_5g(sw_version)
    if not link:
        link = __get_download_link_sbts_old_release(sw_version, repo=z2_repo)
    if not link:
        link = __get_download_link_sbts_old_release(sw_version, repo=z4_repo)
    return link


@logged_keyword
def __get_download_link_sbts(sw_version):
    link = '{repo}{sw}/{sw}_release_BTSSM_downloadable.zip'.format(repo=build_repo, sw=sw_version)
    return check_link_availability(link)


@logged_keyword
def __get_download_link_sbts_old_release(sw_version, repo=z2_repo):
    release = sw_version.split('_')[0]
    link = '{repo}build/{release}/{sw}_release_BTSSM_downloadable_A54.zip'.format(
        repo=repo,
        release=release,
        sw=sw_version)
    return check_link_availability(link)


@logged_keyword
def __get_download_link_5g(sw_version):
    sw = '.'.join([x.lstrip('0') if x.lstrip('0') != '' else '0' for x in sw_version.split('_')[-3:]])
    link = '{repo}{sw}/AirScale-{sw}.zip'.format(repo=artifactory, sw=sw)
    return check_link_availability(link)


def check_link_availability(link):
    try:
        if urllib.urlopen(link).code != 200:
            blog('Link not valid {}'.format(link))
        else:
            return link
    except IOError:
        blog('Link not valid {}'.format(link))


@wait_until_function_succeeds(retry_time_in_seconds=600, retry_interval_in_seconds=30)
@logged_keyword
def get_sw_version():
    with AdminApi(timeout=600) as web_api:
        sw_version = web_api.get_sw_version()
        assert sw_version, "Admin returns empty sw version"
        return sw_version if trunk not in sw_version \
            else '_'.join(['SBTS00' if 'SBTS' in x else x for x in sw_version.split('_')])


@logged_keyword
def run_agent5gclassical(sw_build, tl_state='sw_uploaded',
                         log_path='/home/ute/agent_logs', output_path='/home/ute/output'):
    assert call(__prepare_agent_command(sw_build=sw_build, tl_state=tl_state,
                                        log_path=log_path, output_path=output_path,
                                        label=agent_tl_label), shell=True) == 0, \
        'Update was not successful, for details check logs in {}'.format(log_path)
    __wait_for_bbmod()


@logged_keyword
def __prepare_agent_command(sw_build, tl_state, log_path, output_path, label):
    agent_init_cmd = 'cd /home/ute;' \
                     'export RUNBY=ROBOT;' \
                     '. /opt/ute/agent_env/bin/activate && agent_5g_classical ' \
                     'init -l {label} -b {sw_build} -s {tl_state} -R {log_path} -o {output_path}'
    return agent_init_cmd.format(label=label, sw_build=sw_build, tl_state=tl_state,
                                 log_path=log_path, output_path=output_path)


@logged_keyword
def __get_last_candidate_number(from_date, release):
    return [re.search('href="(.*)/">', candidate).group(1)
            for candidate in requests.get(build_repo).text.splitlines()
            if from_date in candidate and release in candidate][-1]


@logged_keyword
def __get_sw_release_name():
    with AdminApi() as web_api:
        if trunk in web_api.get_sw_version():
            return 'SBTS00'
        return web_api.get_sw_release_name()


@wait_until_function_succeeds(retry_time_in_seconds=Timeouts.bbmod_available, retry_interval_in_seconds=1)
@logged_keyword
def __wait_for_bbmod():
    with AdminApi() as web_api:
        for bbmod in web_api.get_detected_hw_info()['basebandModules']:
            assert bbmod['status']['availabilityStatus'] == 'Online', \
                '\n'.join(['{message}', 'Expected: {expected}', 'But was: {current}']).format(
                    message='BBMOD is not operational', expected='availabilityStatus: Online',
                    current=bbmod['status']['availabilityStatus'])


class RequestsHandler(object):
    def __init__(self):
        pass

    @staticmethod
    @logged_keyword
    def is_reachable(url, timeout=2):
        try:
            response = requests.get(url, verify=False, timeout=timeout)
            return response.ok
        except requests.exceptions.ConnectionError:
            return False
        except requests.exceptions.ReadTimeout:
            return False

    @wait_until_function_succeeds(retry_time_in_seconds=Timeouts.webui, retry_interval_in_seconds=5)
    @logged_keyword
    def wait_until_server_is_reachable(self, url='https://192.168.255.1'):
        assert self.is_reachable(url), '{} is not reachable'.format(url)

    @wait_until_function_succeeds(retry_time_in_seconds=Timeouts.webui, retry_interval_in_seconds=5)
    @logged_keyword
    def wait_until_server_is_unreachable(self, url='https://192.168.255.1'):
        assert not self.is_reachable(url), '{} is still reachable'.format(url)
