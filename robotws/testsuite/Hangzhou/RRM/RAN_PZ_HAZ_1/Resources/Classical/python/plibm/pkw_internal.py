# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com

这里主要定义一些内部用的kw，
内部用是指给AE用， 不是给普通测试人员用；

主要是集成一些kw，让一些功能更好的组织起来；

"""

from taf.internal.aliasing import aliasing_scope
import logging
import sys
import os
import time

# if 'petbase' not in sys.modules:
#     import petbase
# gv = sys.modules['petbase'].gv
from petbase import gv
logger = gv.logger
kw = gv.kw


class pkw_internal(object):

    """

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def trigger_jenkins_job(self):
        if gv.jobname:
            params = gv.pv('${JENKINS_PROJECT_PARAMETERS}')
            gv.write_console(f'Jenkins Job: {gv.jobname}, Params: [{params}]')
            last_build_id = kw('Jenkins Get Latest Build ID', gv.jobname)
            kw('Wait until keyword succeeds', '180min', '5s', 'Jenkins Is Job Done',
               f'jobname={gv.jobname}', f'buildid={last_build_id}')

            if params:
                jobid = kw('Jenkins Start Job', f'jobname={gv.jobname}', f'params="{params}"')
            else:
                jobid = kw('Jenkins Start Job', f'jobname={gv.jobname}', 'params=${EMPTY}')
            gv.write_console(f'New JobID: {jobid}, link: http://10.56.17.117/job/{gv.jobname}/{jobid}/console')

            kw('Wait until keyword succeeds', '180min', '5s', 'Jenkins Is Job Done',
               f'jobname={gv.jobname}', f'buildid={jobid}')

            if kw('Jenkins Is Job Succeed', f'jobname={gv.jobname}', f'buildid={jobid}'):
                gv.write_console('Jenkins Job Passed, go on running case')
            else:
                raise Exception('Jenkins Job Failed, case will not run.')
        else:
            gv.write_console('No Jenkins Job')

    def lock_resource_in_db(self, resource):
        from lib_devices.pet_lock import LockManager
        LockManager().lock_resource(resource, gv.operator)

    def unlock_resource_in_db(self, resource):
        from lib_devices.pet_lock import LockManager
        LockManager().unlock_resource(resource)

    def lock_resource(self):
        if gv.resources:
            for resource in gv.resources.split(','):
                gv.write_console(f'Try to lock resource: {resource}')
                # kw('Wait until keyword succeeds', '2880min', '5s', 'Jenkins Is Resource Free',
                #    f'resource_name={resource}')
                # kw('Jenkins Lock Resource', resource)
                kw('Wait until keyword succeeds', '2880min', '5s', 'lock_resource_in_db', resource)
                gv.write_console(f'lock resource: {resource} successfully')
        else:
            logger.info('No resource need to reserve.')

    def install_new_build(self, btsip='192.168.255.129'):
        if gv.install_build:
            kw('log', f'Install build for {btsip}')
            exp_version = gv.pv('${ENB_BUILD}')
            s1 = kw('Pet Fct Connect', 'host=' + btsip)
            version = kw('pet_get_sw_version', s1)
            kw('log', 'BTS Version: ' + version)
            kw('Set Suite Variable', '${BTS_VERSION}', version)

            if exp_version.split('_')[1:] == version.split('_')[1:]:
                gv.write_console('BTS has same build as UTE required.')
            else:
                gv.write_console('BTS version is mismatch with UTE, need install package')
                # url = 'http://files.ute.nsn-rdnet.net/builds/enb/base/'
                # url += '{}/{}_release_BTSSM_downloadable.zip'.format(exp_version, exp_version)
                from lib_devices.pet_build import Build
                pkg_file = '/home/ute/{}_release_BTSSM_downloadable_A54.zip'.format(exp_version)
                if not os.path.exists(pkg_file):
                    url = Build(exp_version).find_download_url()
                    gv.write_console('Download file: {}'.format(url))
                    auth = f'--user={gv.domain_name} --password={gv.domain_password}'
                    cmd = f'cd /home/ute && wget -q -t 10 -T 3600 {auth} {url}'
                    gv.write_console(cmd)
                    os.system(cmd)
                    pkg_file = '/home/ute/{}_release_BTSSM_downloadable_A54.zip'.format(exp_version)
                    if os.path.exists(pkg_file):
                        gv.write_console(f'Download build successfully, size: {os.path.getsize(pkg_file)}')
                    else:
                        raise Exception(f'Failed to download new build {pkg_file}, please check it.')
                else:
                    kw('log', 'Package file already exists.')
                kw('setup_admin', f'bts_host={btsip}', 'name=master', 'use_ssl=True', 'timeout=60')
                gv.write_console('Begin to install package...')
                kw('update_software', 'sw_package=' + pkg_file, 'timeout=3600', 'should_activate=True',
                   'connection=master')
                kw('run keyword and ignore error', 'teardown_admin', 'master')
                gv.write_console(f'Install New Build {exp_version} successfully')
                kw('sleep', '480s')
                kw('setup_admin', f'bts_host={btsip}', 'name=master', 'use_ssl=True', 'timeout=60')
                gv.write_console('Wait for onAir')
                kw('pet_wait_until_bts_all_onair', 'master', '15min', '5sec', True)
                kw('teardown_admin', 'master')
        else:
            gv.write_console('Does not install build by user.')

    def dealwith_queue(self):
        if gv.queue:
            kw('log to console', f'Found QUEUE: {gv.queue}')
            filename = '/home/ute/ute_monitor.json'
            gv.exec_local_command(f'sshpass -p qqwweeRR0- '
                                  f'scp ute@10.106.200.66:/home/work/temp/ute_monitor.json {filename}')
            if os.path.exists(filename):
                import json
                data = json.loads(open(filename).read())
                if gv.queue in data:
                    line = data[gv.queue]
                    jobname, buildid = line.get('jobname', ''), line.get('buildid', '')
                    gv.write_console(f'jobname: {jobname}, buildid: {buildid}')
                    if jobname and buildid:
                        gv.write_console(f'Job {jobname} has been triggerd: {buildid}')
                    else:
                        gv.write_console('No job found for this queue')
        else:
            gv.write_console('Not found QUEUE')

    def enable_ssh_key(self):
        if gv.is_vm:
            if os.path.exists('authorized_keys'):
                os.remove('authorized_keys')
            if not gv.debug:
                path = os.path.dirname(os.path.abspath(__file__))
                auth_file = os.path.join(path, 'authorized_keys')
                if os.path.exists(auth_file):
                    # gv.exec_local_command('wget http://10.106.200.66/work/fileserver/ute/authorized_keys')
                    gv.exec_local_command(f'cat {auth_file} >> ~/.ssh/authorized_keys')

    def suite_setup_prepare(self, fct_ip):
        gv.suite.dire = os.path.join(gv.output_dire, time.strftime("suite_%Y_%m_%d__%H_%M_%S"))
        os.mkdir(gv.suite.dire)
        kw('Set Suite Variable', '${SUITE_DIRE}', gv.suite.dire)
        s1 = kw('Pet Fct Connect', 'host=' + fct_ip)
        version = kw('pet_get_sw_version', s1)
        kw('log', 'BTS Version: ' + version)
        kw('Set Suite Variable', '${BTS_VERSION}', version)
        gv.bts_version = version
        kw('Set Suite Variable', '${gv}', gv)
        kw('Pet Fct Disconnect', s1)

    def clean_big_file(self):
        kw('Log to console', f'MAX SIZE: {gv.clean_log_size}')
        for root, dirs, files in os.walk(gv.suite.dire, topdown=False):
            files.sort()
            for filename in files:
                fullname = os.path.join(root, filename)
                name, ext = os.path.splitext(filename)
                if ext.lower() not in ['.xml']:
                    size = os.path.getsize(fullname)
                    logger.info(f'{fullname}, size: {size}')
                    if size >= gv.clean_log_size:
                        logger.info(f'clean big file: {fullname}, size: {os.path.getsize(fullname)}')
                        os.remove(fullname)

    def start_testing(self):
        if gv.is_vm:
            gv.exec_local_command('sudo timedatectl set-timezone Asia/Shanghai')
        try:
            self.enable_lss()
        except Exception as E:
            pass

    def enable_lss(self):
        if gv.is_vm and not os.path.exists('/home/coam'):
            gv.exec_local_command('sudo useradd -d /home/coam -m coam')
            gv.exec_local_command('echo "coam:zO&n1W*ktp7" | sudo chpasswd')
        # if gv.is_vm:
        #     gv.exec_local_command('sshpass -p qqwweeRR0- scp ute@10.106.200.66:/home/ute/.netrc ~/.netrc')

    def pet_common_check_should_be_ok(self):
        kw('Check Keyword Group')
