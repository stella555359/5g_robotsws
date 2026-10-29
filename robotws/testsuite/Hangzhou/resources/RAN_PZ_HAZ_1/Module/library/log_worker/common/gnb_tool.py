# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""
from robot.api import logger

from rrm_gnb_tool import c_rrm_gnbtool
import time


class gnb_tool(object):
    """
    This library will provide keywords to capture bip/tti log with gnb_tool.

    *Usage:*

    -   *Import the library*
    Library  ../../Resources/python/gnb_tool.py

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

    def __init__(self):
        self.tool = c_rrm_gnbtool(logger=logger)

    def prepare_gnb_tool(self):
        """
        This keyword will prepare gnb_tool from gitlab2.

        It's here : https://gitlabe2.ext.net.nokia.com/p5li/gnb_logs_tool.git

        It will:
        -   clone the url to /tmp/gnb_log_tool
        -   unzip the tool
        -   grant execution right to the tool

        *Return:* None

        """
        self.tool.prepare_app()

    def start_to_capture_bip_log_with_gnb_tool(self, log_dire='', dest_ip='192.168.255.129',
                                               host='127.0.0.1', port=22, username='ute', password='uteUTE!',
                                               add_options=''):
        """
        This keyword will start to capture bip log with gnb_tool.

        | Parameter | Type | Man. | Default | Description |
        | log_dire | string | Y | None | directory used to save big log |
        | dest_ip | string | Y | 192.168.255.129 | interface used to capture log |
        | host | string | Y | 127.0.0.1 | the pc used to capture log |
        | port | int | Y | 22 | the ssh port to login in the host |
        | username | string | Y | ute | username to login local pc with ssh |
        | password | string | Y | uteUTE! | password to login local pc with ssh |
        | add_options | string | N |  | addition options for command, like: -c 2 |

        *Examples:*
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | password=ute |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | dest_ip=10.108.231.212 |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | add_options=-t5 -c 2 |

        *Return:* None
        """
        return self.tool._start_to_capture_log(
            'bip', log_dire, dest_ip, host, port, username, password, add_options)

    def stop_bip_log_with_gnb_tool(self):
        """
        This keyword will stop capturing bip log with gnb_tool and return log filename.

        *Examples:*
        | ${log_filename} = | Stop Bip Log With Gnb Tool |

        *Return:* The full path filename of zipped log file.
        """

        return self.tool.stop_log()

    def start_to_capture_tti_log_with_gnb_tool(self, log_dire='', dest_ip='192.168.255.129',
                                               host='127.0.0.1', port=22, username='ute', password='uteUTE!',
                                               add_options=''):
        """
        This keyword will start to capture tti log with gnb_tool.

        | Parameter | Type | Man. | Default | Description |
        | log_dire | string | Y | None | directory used to save big log |
        | dest_ip | string | Y | 192.168.255.129 | interface used to capture log |
        | host | string | Y | 127.0.0.1 | the pc used to capture log |
        | port | int | Y | 22 | the ssh port to login in the host |
        | username | string | Y | ute | username to login local pc with ssh |
        | password | string | Y | uteUTE! | password to login local pc with ssh |
        | add_options | string | N |  | addition options for command, like: -c 2 |

        *Examples*:
        | Start To Capture TTI Log With Gnb Tool | log_dire=/tmp/myttilog |
        | Start To Capture TTI Log With Gnb Tool | log_dire=/tmp/myttilog | password=ute |
        | Start To Capture TTI Log With Gnb Tool | log_dire=/tmp/myttilog | dest_ip=10.108.231.212 |

        *Return:* None
        """
        return self.tool._start_to_capture_log(
            'tti', log_dire, dest_ip, host, port, username, password, add_options)

    def stop_tti_log_with_gnb_tool(self):
        """
        This keyword will stop capturing tti log with gnb_tool and return log filename.

        *Examples:*
        | ${log_filename} = | Stop TTI Log With Gnb Tool |

        *Return:* The full path filename of zipped log file.
        """

        return self.tool.stop_log()

    def mkw(self, kwname, *args):
        from robot.libraries import BuiltIn
        builtin = BuiltIn.BuiltIn()
        return builtin.run_keyword(kwname, *args)

    def need_stop_and_fix(self, btshost='192.168.255.129'):

        def ip_is_reachable(ipaddr):
            import os
            return os.system(
                'ping -c 1 -W 5 {} >/dev/null'.format(ipaddr)) == 0

        need_stop = False
        fct_is_reachable = False
        if not ip_is_reachable('192.168.255.1'):
            self.mkw('log to console', 'LMP is not reachable')
            need_stop = True
            return need_stop
        else:
            fct_is_reachable = True
            self.mkw('log to console', 'LMP is reachable')
        self.mkw('Run keyword and ignore error', 'coam.teardown_admin', 'sf')
        admin = self.mkw(
            'coam.setup_admin',
            'bts_host=' + btshost,
            'name=sf',
            'use_ssl=True',
            'timeout=60')
        if not fct_is_reachable:
            self.mkw('Get current SCF File', 'local_dir_path=/tmp', 'file_name=scf.xml', 'export_type=configuration',
                     'connection=sf')
            from lxml import etree
            scfns = {'scfns': 'raml21.xsd'}
            tree = etree.parse('/tmp/scf.xml')
            distname = tree.xpath(
                '//scfns:p[@name="mPlaneIpv4AddressDN"]/text()',
                namespaces=scfns)[0]
            fstr = '//scfns:managedObject[@distName="{}"]/scfns:p[@name="localIpAddr"]/text()'.format(
                distname)
            s1_ip = tree.xpath(fstr, namespaces=scfns)[0]
            # s1_ip = tree.xpath('//scfns:p[@name="localIpAddr"]/text()', namespaces=scfns)[0]
            self.mkw('log to console', 'Found S1 IP: {}'.format(s1_ip))

            if not ip_is_reachable(s1_ip):
                self.mkw('log to console', 'S1 is not reachable')
                need_stop = True
                return need_stop
            else:
                self.mkw('log to console', 'S1 is reachable')

        alarms = self.mkw('coam.get_active_alarms', 'connection=sf')
        faulty_list = [x.faultId for x in alarms]
        self.mkw(
            'log to console',
            'Current alarm list {}'.format(
                str(faulty_list)))

        trunk_roll_alarms = ['0010', '1806', '4341', '4352', '4383']
        if [x for x in trunk_roll_alarms if x in faulty_list]:
            self.mkw('log to console', 'Found alarm that match stop&fix.')
            need_stop = True
            return need_stop

        info = self.mkw('coam.get_bts_info', 'connection=sf')
        bbmod_status = [x['status']['operationalState']
                        for x in info['basebandModules']]
        self.mkw(
            'log to console',
            'BB mod status: {}'.format(
                str(bbmod_status)))
        rfmod_status = [x['status']['operationalState']
                        for x in info['radioModules']['rmod']]
        self.mkw(
            'log to console',
            'RF mod status: {}'.format(
                str(rfmod_status)))
        sysmod_status = [x['status']['operationalState']
                         for x in info['systemModules']]
        self.mkw(
            'log to console',
            'System mod status: {}'.format(
                str(sysmod_status)))
        all_state = [x.lower().strip()
                     for x in bbmod_status + rfmod_status + sysmod_status]
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

    def send_email(self, receiver="",
                   cc_list="",
                   subject="stop and fix for ",
                   content="",
                   tlname=None):
        self.mkw('log to console', 'Send email to {}'.format(receiver))
        import json
        import os
        import traceback
        if content == "" or content is None:
            if os.path.exists("/opt/ute/execution.context.json"):
                try:
                    msg_file = "/opt/ute/execution.context.json"
                    with open(msg_file) as json_file:
                        f_content = json.dumps(json.load(json_file))
                        content = f_content["CM_EXECUTION_LINK"] + "/r/n"
                        content += f_content
                except Exception as e:
                    self.mkw("log to console", "get content failed")
                    print(traceback.format_exc())
        if tlname is None:
            subject += self.mkw("Get TestLine Name")
        api = MongooseApi()
        api.request_stop_fix(params={"reciever": receiver,
                                     "cc_list": cc_list,
                                     "subject": subject,
                                     "content": content})

    def get_tl_owner(self, tlname=None):
        import traceback
        try:
            if tlname is None:
                tlname = self.mkw("Get TestLine Name")
            api = MongooseApi()
            user, team = api.request_scout_tl_owner(tlname=tlname)
            if user and team:
                return user, team
            else:
                return "I_MN_RAN_1_HAZ_TAWG@internal.nsn.com", None
        except Exception as e:
            self.mkw(
                "Log to console",
                "failed to get test line owner, will use default TAWG email")
            print(traceback.format_exc())
            return "I_MN_RAN_1_HAZ_TAWG@internal.nsn.com", None

    def stop_and_fix(self, receiver=None, btshost='192.168.255.129',
                     cc_list=[],
                     subject="stop and fix for ",
                     content="",
                     tlname=None):
        """
        This keyword will implement stop and fix function.
        | Parameter | Type | Man. | Default | Description |
        | receiver | string | Y | None | if stop and fix happend ,will send email to the reciver,if is none, |
        | will get user from scout by tlname |
        | btshost | string | Y | 192.168.255.129 | interface to check |
        | cc_list | list | Y | []] | the email will cc to ... |
        | subject | string | Y | stop and fix for  | title of the email |
        | content | string | Y | "" | content of email |
        | tlname | string | Y | None | if is none, will get default tlname. |

        *Examples:*
        | Stop and Fix |

        *Return:* The full path filename of zipped log file.
        """
        import time
        self.mkw('log to console', '\n!!! Start to check stop&fix...')
        already_send_email = False
        # loop check about 2 hours, interval time is 2 min
        for i in range(60):
            if self.mkw('need_stop_and_fix', 'btshost=' + btshost):
                self.mkw(
                    'Run keyword and ignore error',
                    'coam.teardown_admin',
                    'sf')
                self.mkw('log to console', 'Stop&Fix happened')
                if already_send_email is False:
                    self.mkw('report_to_channel')
                    if receiver is None:
                        receiver, team = self.get_tl_owner(tlname=tlname)
                        cc_list += self.__get_stop_and_fix_interface(team)
                    self.mkw("run keyword and ignore error", 'send_email',
                             receiver, ";".join(cc_list), subject, content, tlname)
                    already_send_email = True
                self.mkw(
                    'log to console',
                    'wait for next check {} minutes...'.format(
                        i * 2))
                time.sleep(2 * 60)
            else:
                self.mkw('log to console', 'trunk roll be recovered')
                return False
        for i in range(24 * 60 * 3):
            self.mkw(
                'log to console',
                'stop and wait for fix check {} minutes...'.format(i))
            time.sleep(60)

    def __get_stop_and_fix_interface(self, team):
        interface_email_list = ["ning.du@nokia-sbell.com",
                                "huiqiong.yan@nokia-sbell.com",
                                "cici.wei@nokia-sbell.com",
                                "haixiu.zhang@nokia-sbell.com",
                                "guangyong.li@nokia-sbell.com",
                                "dacheng.zhang@nokia-sbell.com",
                                "huan.wang@nokia-sbell.com",
                                "wei.ren@nokia-sbell.com",
                                "ling.qin@nokia-sbell.com"]
        interface_email = dict(zip(["NSB MN RAN Pz 1 HAZ {} SG".format(i + 1) for i in range(7)],
                                   interface_email_list))

        if team in interface_email.keys():
            return [interface_email[team]]
        else:
            return []


class MongooseApi(object):
    """use to send request to mongoose or other RRM7 server"""

    def __init__(self):
        # self.url = "http://dev5.eecloud.dynamic.nsn-net.net"
        self.url = "http://10.109.1.216"
        self.__header = {
            "Content-Type": "application/json",
            "Accept": "application/json"
            # to do : add token
        }

    def add_token(self, token):
        self.__header["Authorization"] = token

    def request_stop_fix(self,
                         url_append="apis/stop_and_fix",
                         m="POST",
                         params={}):
        import requests
        params.setdefault("reciever", "I_MN_RAN_1_HAZ_TAWG@internal.nsn.com")
        params.setdefault("cc_list", "")
        params.setdefault("subject", "stop and fix")
        params.setdefault("content", "no msg")
        reponse = requests.request(url="{}/{}".format(self.url, url_append),
                                   method=m,
                                   data=params)
        if reponse.status_code == 200:
            return "success"
        else:
            raise Exception(
                "Can't send email to {}".format(
                    params["reciever"]))

    def request_scout_tl_owner(self, tlname):
        import requests
        token = "779b67c1f076465dbd0375cf51e39f87"
        url = 'https://scout.nsn-rdnet.net/api/v1/testlines/{}/'.format(tlname)
        params = {
            "fields[testline]": "name,user,team",
            'include': "user,team.user",
            "apitoken": token}
        reponse = requests.request(url=url, params=params, method='GET')
        import pprint
        pprint.pprint(reponse.json())
        pprint.pprint(reponse.status_code)
        if reponse.status_code == 200:
            users = []
            team = None
            for x in reponse.json()['included']:
                if x["type"] == "user":
                    users.append(x['attributes']["email"])
                if x["type"] == "team":
                    team = x['attributes']["name"]
            if len(users) and team:
                return ";".join(users), team
        raise Exception(
            "Can't get the user form scout of tl {}".format(tlname))
