# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

from robot.api import logger


class gnb_tool(object):

    """
    This library will provide keywords to capture bip/tti log with gnb_tool.

    *Usage:*

    -   *Import the library*
    Library  ../../resources/python/gnb_tool.py
    -   *Example for Capture Bip Log:*
    | `Prepare Gnb Tool` |
    | `Start To Capture Bip Log With Gnb Tool` | log_dire=/tmp/mybiplog |
    | Sleep | 10 |
    | ${log_filename} = | `Stop Bip Log With Gnb Tool` |

    -   *Example for Capture Tti Log:*
    | `Prepare Gnb Tool` |
    | `Start To Capture Tti Log With Gnb Tool` | log_dire=/tmp/myttilog |
    | Sleep | 10 |
    | ${log_filename} = | `Stop Tti Log With Gnb Tool` |
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    # ROBOT_LIBRARY_DOC_FORMAT = 'reST'
    __version__ = '0.1'

    def mkw(self, kwname, *args):
        from robot.libraries import BuiltIn
        builtin = BuiltIn.BuiltIn()
        return builtin.run_keyword(kwname, *args)

    def need_stop_and_fix(self, btshost='192.168.255.129'):

        def ip_is_reachable(ipaddr):
            import os
            return os.system('ping -c 1 -W 5 {} >/dev/null'.format(ipaddr)) == 0

        need_stop = False
        fct_is_reachable = False
        if not ip_is_reachable('192.168.255.129'):
            self.mkw('log to console', 'LMP is not reachable')
            need_stop = True
            return need_stop
        else:
            fct_is_reachable = True
            self.mkw('log to console', 'LMP is reachable')

        self.mkw('Run keyword and ignore error', 'teardown_admin', 'sf')
        admin = self.mkw('setup_admin', 'bts_host=' + btshost, 'name=sf', 'use_ssl=True', 'timeout=60')

        if not fct_is_reachable:
            self.mkw('Get current SCF File', 'local_dir_path=/tmp', 'file_name=scf.xml', 'export_type=configuration',
                     'connection=sf')
            from lxml import etree
            scfns = {'scfns': 'raml21.xsd'}
            tree = etree.parse('/tmp/scf.xml')
            s1_ip = tree.xpath('//scfns:p[@name="localIpAddr"]/text()', namespaces=scfns)[0]
            self.mkw('log to console', 'Found S1 IP: {}'.format(s1_ip))

            if not ip_is_reachable(s1_ip):
                self.mkw('log to console', 'S1 is not reachable')
                need_stop = True
                return need_stop
            else:
                self.mkw('log to console', 'S1 is reachable')

        alarms = self.mkw('coam.get_active_alarms', 'connection=sf')
        faulty_list = [x.faultId for x in alarms]
        self.mkw('log to console', 'Current alarm list {}'.format(str(faulty_list)))

        trunk_roll_alarms = ['0010', '0016', '1806', '1868', '4341', '4352', '4383']
        if [x for x in trunk_roll_alarms if x in faulty_list]:
            self.mkw('log to console', 'Found alarm that match stop&fix.')
            need_stop = True
            return need_stop

        info = self.mkw('get_bts_info', 'connection=sf')
        bbmod_status = [x['status']['operationalState'] for x in info['basebandModules']]
        self.mkw('log to console', 'BB mod status: {}'.format(str(bbmod_status)))
        rfmod_status = [x['status']['operationalState'] for x in info['radioModules']['rmod']]
        self.mkw('log to console', 'RF mod status: {}'.format(str(rfmod_status)))
        sysmod_status = [x['status']['operationalState'] for x in info['systemModules']]
        self.mkw('log to console', 'System mod status: {}'.format(str(sysmod_status)))
        all_state = [x.lower().strip() for x in bbmod_status + rfmod_status + sysmod_status]
        if [x for x in all_state if x != 'enabled']:
            self.mkw('log to console', 'Found BBU or RRU status error')
            need_stop = True
            return need_stop

        return need_stop

    def report_to_channel(self):
        self.mkw('log to console', 'Report to channel')
        import json
        import subprocess
        import os
        if os.path.exists('/opt/ute/execution.context.json'):
            with open('/opt/ute/execution.context.json') as json_file:
                result = json.load(json_file)
            cm_execution_id = result['CM_EXECUTION_ID']
            cmd = r'echo "put /opt/ute/execution.context.json %s.json"' % cm_execution_id \
                + r' | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
            p = subprocess.check_output(cmd, shell=True)
            self.mkw('log to console', p)

    def stop_and_fix(self, btshost='192.168.255.129'):
        """
        This keyword will implement stop and fix function.

        *Examples:*
        | Stop and Fix |

        *Return:* The full path filename of zipped log file.
        """
        import time
        self.mkw('log to console', '\n!!! Start to check stop&fix...')
        if self.mkw('need_stop_and_fix', 'btshost=' + btshost):
            self.mkw('Run keyword and ignore error', 'teardown_admin', 'sf')
            self.mkw('log to console', 'Stop&Fix happened')
            self.mkw('report_to_channel')
            for i in range(60 * 24 * 3):
                self.mkw('log to console', 'wait for check')
                time.sleep(60)
