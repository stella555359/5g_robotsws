# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

from taf.internal.aliasing import aliasing_scope
import logging
import sys
import os
import time
import re
import json

from petbase import gv
logger = gv.logger
kw = gv.kw


class pkw_l2(object):

    """
    这里主要是提供L2的一些kw

    *定义：*
        -   L1的kw，是我们自己提供的和外部提供的kw，这些kw是common kw，所有的team都可以使用；
        -   L2的kw，是我们组提供的只适用于RRM5/RRM6组的kw，这些kw用了一些私有的数据，让RRM5/RRM6用起来更方便，但是外部的人不方便使用；
        -   L2的kw一般第一个参数是设备的id，这个设备的id来自HAZ5/config目录下各种设备的配置文件；

    这些kw都是以l2 开头，以示区分，

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def l2_restart_tma(self, tm500_id):
        """
        这个kw会到TM500的控制PC上，用命令行重启TMA。
        如果是debug模式，不重启TMA

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | tm500_id | 字符串 | 是 |  | id of TM500 |

        *返回值:* 无

        *示例:*
        | l2_restart_tma | tm500_id=27 |

        """
        if gv.debug:
            kw('log to console', 'It is debug mode, will not restart TMA')
            return 0

        tm500 = kw('load_device_config', 'tm500', tm500_id)
        cpc = tm500.cpc
        alias = f'tm500_cpc_{tm500_id}'
        username = cpc.username.split('\\')[-1]
        app_path = gv.winpath(tm500.tma.app_path)
        kw('restart_tma', f'host={cpc.host}', f'port={cpc.port}', f'username=noklab\\\\{username}',
           f'password={cpc.password}',
           f'app_path={app_path}')

    def l2_restart_tm500(self, tm500_id):
        """
        这个kw会重启TM500
        根据TM500的配置，如果此TM500是ASC相关，那么会调用执行重启ASC的相关动作；否则只是给TM500上下电；
        debug模式下不重启TM500

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | tm500_id | 字符串 | 是 |  | id of TM500 |

        *返回值:* 无

        *示例:*
        | l2_restart_tm500 | tm500_id=27 |

        """

        if gv.debug:
            kw('log to console', 'It is debug mode, will not restart tm500')
            return 0
        tm500 = kw('load_device_config', 'tm500', tm500_id)
        if tm500.use_asc:
            kw('log to console', 'TM500 Use ASC, need to restart ASC config')
            kw('l2_restart_asc', tm500_id)
        else:
            kw('log to console', 'TM500 does not use ASC, just restart TM500 itself')
            for pbinfo in tm500.powerbreak:
                ip, port = pbinfo.split(':')
                kw('pet_pb_operator', 'factory=apc', f'host={ip}', f'port={port}', 'operation=poweroff')
                kw('Sleep', '15s', 'Delay between Power off and Power on')
                kw('pet_pb_operator', 'factory=apc', f'host={ip}', f'port={port}', 'operation=poweron')
            kw('Sleep', '300s', 'Wait for power on done')

    def l2_restart_asc(self, tm500_id):
        """
        这个kw会重启ASC
        根据TM500的配置，它会poweroff,unlock此TM500的group，然后下电，上电，然后再lock, poweron group

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | tm500_id | 字符串 | 是 |  | id of TM500 |

        *返回值:* 无

        *示例:*
        | l2_restart_asc | tm500_id=27 |

        """

        tm500 = kw('load_device_config', 'tm500', tm500_id)
        asc = tm500.asc
        kw('restart_asc', f'host={asc.host}', f'port={asc.port}', f'username={asc.username}',
           f'password={asc.password}', f'groupname={asc.groupname}',
           f'powerbreak={tm500.powerbreak}')

    def l2_stop_shenick_running_group(self, tm500_id):
        """
        这个kw会检查TM500的shenick上是否有正在运行的group，如果有，就把它停了；否则会造成tm500脚本失败；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | tm500_id | 字符串 | 是 |  | id of TM500 |

        *返回值:* 无

        *示例:*
        | l2_stop_shenick_running_group | tm500_id=27 |

        """
        tm500 = kw('Load Device Config', 'tm500', tm500_id)
        if tm500.use_shenick:
            shenick = tm500.shenick
            alias = 'tm500_shenick'
            kw('shenick_setup', f'host={shenick.host}', f'port={shenick.port}',
               f'partition={shenick.partition}', f'name={alias}')
            kw('shenick_stop_running_test_group', f'name={alias}')
            kw('shenick_teardown', f'name={alias}')
        else:
            kw('log to console', 'Does not use shenick')

    def l2_run_script_on_tm500(self, tm500_id, filename, logfile='', failed_keyword=['Assert']):
        """
        这个kw会在指定的TM500的TMA上执行tm500的脚本；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | tm500_id | 字符串 | 是 |  | id of TM500 |
        | filename | 字符串 | 是 |  | 脚本文件的名称 |
        | logfile | 字符串 | 否 |  | log文件的名称，如果指定了，那么命令的输出就保存到这个文件里面 |
        | failed_keyword | 列表 | 否 | ['Assert'] | 判断脚本执行失败的关键字列表 |

        *返回值:* 无

        *示例:*
        | l2_run_script_on_tm500 | tm500_id=27 | filename=attach.txt | logfile=attach_output.log |

        """
        tm500 = kw('Load Device Config', 'tm500', tm500_id)
        kw('run_script_on_tm500', tm500.tma.host, filename, logfile, failed_keyword)

    def l2_execute_tm500_command(self, tm500_id, command='', ignore_error=False, timeout=300, wait_response=True):
        """
        这个kw会在指定的TM500的TMA上执行tm500命令；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | tm500_id | 字符串 | 是 |  | id of TM500 |
        | command | 字符串 | 是 |  | TMA 命令 |
        | ignore_error | 布尔值 | 否 | False | 是否要无视命令发深错误 |
        | timeout | 整数 | 否 | 300秒 | 命令执行多久算超时 |
        | wait_response | 布尔值 | 否 | True | 是否要等待命令的返回，TMA的命令的返回通常是 C + 命令 |

        *返回值:* 命令输出

        *示例:*
        | l2_execute_tm500_command | tm500_id=27 | command=CHOW |
        """

        tm500 = kw('Load Device Config', 'tm500', tm500_id)
        kw('execute_tm500_command', tm500.tma.host, command, ignore_error, timeout, wait_response)

    def l2_prepare_tm500(self, tm500id):
        """
        这个kw集成了TM500准备阶段的所有动作；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | tm500_id | 字符串 | 是 |  | id of TM500 |

        *返回值:* 命令输出

        *示例:*
        | l2_prepare_tm500 | tm500id=27 |
        """

        kw('l2_restart_tma', tm500id)
        kw('l2_restart_tm500', tm500id)
        kw('l2_stop_shenick_running_group', tm500id)

    def l2_restart_ipsl_with_config(self, ipslid, cfgpath):
        """
        这个kw会在利用指定的配置文件，重启IPSL

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | ipsl_id | 字符串 | 是 |  | id of ipsl |
        | cfgpath | 字符串 | 是 |  | 配置文件的路径 |

        *返回值:* 无

        *示例:*
        | l2_restart_ipsl_with_config | ipslid=56 | cfgpath="C:\\IpslTools\\5.2.1.2.2_YSF_ARP9-CQI2\\IPS.cfg" |

        """

        cfg = kw('load_device_config', 'ipsl', ipslid)
        alias = f'ipsl_{ipslid}'
        cfg.username = r'noklab\\' + cfg.username.split('\\')[-1]
        kw('ipsl_setup', f'name={alias}', f'host={cfg.host}', f'username={cfg.username}',
            f'password={cfg.password}', f'os={cfg.os}')
        kw('ipsl_stop_app', f'name={alias}')
        kw('ipsl_start_app', alias, gv.winpath(cfg.app_path), gv.winpath(cfgpath))
        kw('wait_until_ipsl_is_ready', alias, cfg.exp_conn, cfg.smflist, cfg.smfusername, cfg.smfpassword)
        kw('ipsl_teardown', alias)

    def l2_pa_change_signal(self, paid, points, signal, clear_all=False):
        """
        这个kw会给指定的PA/Matrix调节信号

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | paid | 字符串 | 是 |  | id of pa |
        | points | 字符串 | 是 |  | 例如: A1B2,A3B4 |
        | signal | 字符串 | 是 | 93 | 期望调节到的信号值 |
        | clear_all | 布尔值 | 否 | False | 是否要clear all，这个对 RFswitch很有用，会把所有相关的端口清除 |

        *返回值:* 无

        *示例:*
        | l2_pa_change_signal | paid=73 | points=A1B2,A3B4 | signal=10 |
        | l2_pa_change_signal | paid=73 | points=A1B2,A3B4 | signal=10 | clear_all=${TRUE} |

        """
        from lib_devices.pet_pa import change_pa_signal2
        change_pa_signal2(paid, points, signal, clear_all, logger)

        # if clear_all:
        #     from lib_devices.pet_pa import change_pa_signal2
        #     change_pa_signal2(paid, points, signal, clear_all, logger)
        # else:
        #     kw('pet_change_pa_signal', f'devicetype={pa.devicetype}',
        #     f'model={pa.model}',
        #     f'host={pa.host}',
        #     f'port={pa.port}',
        #     f'totalinport={pa.inport}',
        #     f'totaloutport={pa.outport}',
        #     f'points={points}',
        #     f'signal={signal}')

    def l2_search_com_port_by_imsi(self, agentname, imsi, keyword='Quectel USB AT Port'):
        """
        在UE PC上搜索 UE 的COM口信息；

        在PC上插了多个UE后，这些UE是可以通过COM口发命令的，我们需要首先区分出UE对应的COM口是多少，这个kw就是实现这个功能

        这个kw要用到agent，所以在此之前必须先用agent setup 来准备agent；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | agentname | 字符串 | 是 |  | agent的名称 |
        | imsi | 字符串 | 是 |  | Spark UE的imsi |
        | keyword | 字符串 | 否 | Quectel USB AT Port | 用来判定Spark UE的COM口的关键字 |

        *返回值:* COM口名称，例如：COM65；

        *示例:*
        | ${port=} | l2_search_com_port_by_imsi | agentname=agent | imsi=460023100010567 |

        """
        ports = kw('agent_list_comports', agentname)
        ports = [x['name'] for x in ports if keyword.lower() in x['description'].lower()]
        logger.info(f'Found COM Ports: {ports}')
        for port in ports:
            resp = kw('agent_exec_at_commmand', agentname, port, 'AT+CIMI')
            pimsi = re.findall(r'[\d]{7,}', resp)
            if pimsi and pimsi[0] == imsi:
                return port
        raise Exception(f'Could not find COM port for {imsi}')

    def l2_get_spark_ue_ip(self, agentname, com_port):
        """
        通过AT命令获取Spark UE的ip地址；

        这个kw要用到agent，所以在此之前必须先用agent setup 来准备agent；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | agentname | 字符串 | 是 |  | agent的名称 |
        | com_port | 字符串 | 是 |  | spark UE对应的COM口 |

        *返回值:* 字符串

        *示例:*
        | ${ueip} | l2_get_spark_ue_ip | agentname=agent | com_port=COM14 |

        """

        resp = kw('agent_exec_at_commmand', f'name={agentname}', f'com_port={com_port}', 'command="AT+CGPADDR=1"')
        line = [x.strip() for x in resp.splitlines() if x.strip()][0]
        ip_addr = re.findall(r'([\d]{1,3}[.][\d]{1,3}[.][\d]{1,3}[.][\d]{1,3})', line)
        if ip_addr:
            return ip_addr[0]
        else:
            raise Exception('Could not find UE ip address')

    def l2_restart_spark_ue_and_wait_until_it_is_ready(self, agentname, com_port):
        """
        重启Spark UE，然后一直等到它重启好（通过查询IMSI来判断）

        这个kw要用到agent，所以在此之前必须先用agent setup 来准备agent；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | agentname | 字符串 | 是 |  | agent的名称 |
        | com_port | 字符串 | 是 |  | spark UE对应的COM口 |

        *返回值:* 字符串

        *示例:*
        | l2_restart_spark_ue_and_wait_until_it_is_ready | agentname=agent50 | com_port=COM24 |

        """

        resp = kw('agent_exec_at_commmand', f'name={agentname}', f'com_port={com_port}', 'command="at+cfun=1,1"')
        time.sleep(10)
        for i in range(100):
            resp = kw('agent_exec_at_commmand', f'name={agentname}', f'com_port={com_port}', 'command="at+cimi"',
                      'ignore_error=${TRUE}')
            if re.findall(r'[\d]{15,}', resp):
                logging.info('Successfully found IMSI')
                return
            else:
                time.sleep(10)
        raise Exception('Could not find imsi after ue resart in 500s.')

    def l2_setup_dcap(self, dcap_host, port=443, username='dcapuser', password='dcapadmin!', alias='mydcap'):
        """
        准备到 DCAP 服务器的连接
        ---
        *我们的抓 emil 的大体步骤是：*

           -   l2 setup dcap
           -   l2 start capture log by dcap
           -   l2 stop capture log from dcap
           -   l2 download emil log

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | dcap_host | 字符串 | 是 |  | DCAP 服务器的ip地址， RRM5组的DCAP 服务器地址是：10.56.111.38 |
        | port | 字符串 | 否 | 443 | DCAP 服务器的访问端口 |
        | username | 字符串 | 否 | dcapuser | DCAP 服务器的用户名 |
        | password | 字符串 | 否 | dcapadmin! | DCAP 服务器的用户密码 |
        | alias | 字符串 | 否 | mydcap | DCAP 连接的别名，强烈建议自己定义 |
        ---
        *返回值:* 无

        *示例:*
        | l2 setup dcap | dcap_host=10.56.111.38 | alias=mydcap |
        ---
        """

        return kw('DCAP.connect_to', f'host={dcap_host}', f'port={port}',
                  f'username={username}', f'password={password}', 'rd_version=dcapv3', 'secure=${TRUE}',
                  f'alias={alias}')

    def _log(self, msg):
        kw('log to console', msg)

    def _get_bts(self, btsip, alias):
        btsinfo = kw('DCAP.get_all_bts_info', f'connection={alias}')
        bts = [x for x in btsinfo if x['host'] == btsip]
        if bts:
            return bts[0]
        else:
            return None

    def _get_bts_trace_status(self, btsip, alias):
        bts = self._get_bts(btsip, alias)
        if bts:
            last_trace = bts.get('latest_trace', None)
            if last_trace:
                return bts.get('latest_trace', ).get('status', '').lower()
        return 'ready'

    def _get_bts_trace_id(self, btsip, alias):
        bts = self._get_bts(btsip, alias)
        if bts:
            return bts['latest_trace']['id']
        else:
            return ''

    def _wait_for_bts_trace_status(self, btsip, exp_status, alias, timeout=120):
        bts = self._get_bts(btsip, alias)
        trace_id = bts['latest_trace']['id']
        for i in range(timeout):
            trace_info = kw('DCAP.get_trace_info_by_id', f'trace_id={trace_id}', f'connection={alias}')
            self._log(f'Current Status: {trace_info["status"]}')
            if trace_info["status"].lower() == exp_status.lower():
                return 0
            else:
                time.sleep(5)
        raise Exception(f'BTS Latest Trace Status could not reach {exp_status} in {timeout}s')

    def _make_sure_bts_is_ready(self, btsip, alias):
        self._log('make sure bts is ready')
        bts = self._get_bts(btsip, alias)
        if not bts:
            kw('DCAP.create_bts', f'host={btsip}', f'connection={alias}')
            return 0
        status = self._get_bts_trace_status(btsip, alias)
        if status == 'ready':
            self._log('BTS is ready')
        if status == 'starting':
            self._wait_for_bts_trace_status(btsip, 'running', alias)
            status = self._get_bts_trace_status(btsip, alias)
        if status == 'running':
            self._log('Stop running trace first.')
            trace_id = self._get_bts_trace_id(btsip, alias)
            kw('DCAP.stop_trace', f'trace_id={trace_id}', f'connection={alias}')
            kw('Sleep', '5s')
        self._log('make sure bts is ready done')

    def _get_btsdict(self, btsip):
        return dict(host=btsip, port=443, username='Nemuadmin', password='nemuuser')

    def l2_start_capture_log_by_dcap(self, btsip: str, alias: str,
                                     msg_types: str = '') -> None:

        """
        通过 DCAP 抓 各种各样的log
        ---
        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | btsip | 字符串 | 是 |  | 基站的 S1 地址 |
        | alias | 字符串 | 是 |  | 通过 L2 Setup DCAP 建立的别名 |
        | msg_types | 字符串 | 否 | 空 | 指定要抓取哪些log，可以指定多种，用逗号隔开 |
        ---
        *说明*

        msg_types 可以指定3类msg，分别是：4g, 5g, bts, 然后用类似：4g_emil这种方式指定具体的消息类型；

        4g/5g/bts的log类型如下表，请一定要从下表中选取log类型；大小写敏感！

        | *msg_type_for_4g* 可能值 | *msg_type_for_5g* 可能值 | *msg_type_for_bts* 可能值 |
        | pmfile | pmfile | pmfile |
        | snapshot | snapshot | snapshot |
        | scf | scf | scf |
        | syslog | syslog | |
        | emil | emil | |
        | tti | cellTrace | |
        | lteTracer | l1IQtrace | |
        | l2 | l2Stream | |
        | 4gAa | bip | |
        | | | ipcapture |
        ---
        *返回值:* 无

        *示例:*
        | l2 start capture log by dcap | 10.56.201.67 | alias=mydcap | msg_types=4g_tti |
        | l2 start capture log by dcap | 10.56.201.67 | alias=mydcap | msg_types=4g_tti,4g_emil |
        | l2 start capture log by dcap | 10.56.201.67 | alias=mydcap | msg_types=4g_tti,5g_emil,5g_syslog |
        | l2 start capture log by dcap | 10.56.201.67 | alias=mydcap | msg_types=4g_emil,bts_ipcapture,bts_snapshot |
        ---
        """
        self._make_sure_bts_is_ready(btsip, alias)

        msg_type_4g = {
            'lteTracer': 'lteTracer_4g',
            'l2': 'condor4gL2',
            'tti': 'condor4gTti',
            'emil': 'cp_4g',
            '4gAa': 'condor4gAa',
            'syslog': 'condor4gSyslog',
            'snapshot': 'immediateSnapshot_4g',
            'pmfile': 'pmFiles4g',
            'scf': 'scf4g'
        }

        msg_type_5g = {
            'emil': 'cp_5g',
            'snapshot': 'immediateSnapshot_5g',
            'pmfile': 'pmFiles5g',
            'l1IQtrace': 'l1IqTracer',
            'l2Stream': 'L1stream',
            'bip': 'bip_interface_mirroring',
            'syslog': 'condor5gSyslog',
            'cellTrace': 'Tracer_5g',
            'scf': 'SCF5g'
        }

        msg_type_bts = {
            'snapshot': 'immediateSnapshot',
            'pmfile': 'pmFiles',
            'scf': 'scf',
            'ipcapture': 'ipCapture',
        }

        msg_types = [x.strip() for x in msg_types.lower().replace(';', ',').split(',') if x.strip()]
        cm4g = [msg_type_4g[msg.split('_')[-1]] for msg in msg_types if msg.startswith('4g_')]
        cm5g = [msg_type_5g[msg.split('_')[-1]] for msg in msg_types if msg.startswith('5g_')]
        cmbts = [msg_type_bts[msg.split('_')[-1]] for msg in msg_types if msg.startswith('bts_')]

        # def _parse_items(inmsg, msgdict):
        #     result = []
        #     if inmsg:
        #         result = [x for x in inmsg.split(',') if x not in msgdict]
        #         if result:
        #             raise Exception(f'Invalid message type : {result}')
        #         result = [msgdict[x] for x in inmsg.split(',')]
        #     return result

        btsdict = self._get_btsdict(btsip)
        # cm4g = _parse_items(msg_type_for_4g, msg_type_4g)
        # cm5g = _parse_items(msg_type_for_5g, msg_type_5g)
        # cmbts = _parse_items(msg_type_for_bts, msg_type_bts)

        params = ['DCAP.start_trace', btsdict]
        if cm4g:
            kw('Set Suite Variable', '${TMP_4GPROFILE}', cm4g)
            params.append('enb_custom_profile=@{TMP_4GPROFILE}')
        if cm5g:
            kw('Set Suite Variable', '${TMP_5GPROFILE}', cm5g)
            params.append('gnb_custom_profile=@{TMP_5GPROFILE}')
        if cmbts:
            kw('Set Suite Variable', '${TMP_BTSPROFILE}', cmbts)
            params.append('bts_custom_profile=@{TMP_BTSPROFILE}')
        params += [f'connection={alias}']
        info = kw(*params)

        kw('log to console', info)
        time.sleep(5)
        self._wait_for_bts_trace_status(btsip, 'running', alias, 300)

    def l2_stop_capture_log_by_dcap(self, btsip, alias):
        """
        停止 DCAP上指定基站的 log 抓取；
        ---
        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | btsip | 字符串 | 是 |  | 基站的 S1 地址 |
        | alias | 字符串 | 是 |  | 通过 L2 Setup DCAP 建立的别名 |
        ---
        *返回值:* trace_id

        *示例:*
        | ${trace_id} | l2 stop capture log by dcap | ${btsdict} | alias=mydcap |
        ---
        """
        trace_id = self._get_bts_trace_id(btsip, alias)
        kw('DCAP.stop_trace', f'trace_id={trace_id}', f'connection={alias}')
        return trace_id

    def l2_download_log_from_dcap(self, btsip, target_dir, alias):
        """
        下载已经抓好的 emil log

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | btsip | 字符串 | 是 |  | 基站的 S1 地址 |
        | target_dir | 字符串 | 是 |  | 用来保存 log 文件的本地目录名的全路径 |
        | alias | 字符串 | 是 |  | 通过 L2 Setup DCAP 建立的别名 |

        *返回值:* 下载后的 log 文件的全路径；注意这个文件是一个zip文件；

        *示例:*
        | ${logfile} | l2 download log from dcap | ${btsip} | ${CASE_DIRE} | mydcap |

        """

        self._wait_for_bts_trace_status(btsip, 'ready', alias)
        trace_id = self._get_bts_trace_id(btsip, alias)
        kw('DCAP.get_results', f'result_id={trace_id}', f'target_dir={target_dir}', f'connection={alias}')
        files = [x for x in os.listdir(target_dir) if x.endswith('.zip')]
        if files:
            log_filename = os.path.join(target_dir, files[0])
            logging.info(f'Emil Log file: {log_filename}')
            return log_filename
        else:
            raise Exception(f'Could not find the emil log file, please check it. {files}')

    def l2_unpack_dcap_emil_log(self, dcap_emil_zip_ifle):
        """
        解压 dcap 上抓到的 zip 文件，然后从里面提取出 emil 文件的路径；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | dcap_emil_zip_ifle | 字符串 | 是 |  | emil log文件名，从 l2_download_emil_log 返回而来 |

        *返回值:* 解压后的 emil 文件的全路径

        *示例:*
        | ${emilfile}= | l2 unpack dcap emil log | /home/ute/dcap_start_trace_2023-06-29T03_02_45.907Z.zip |

        """

        dire = os.path.dirname(os.path.abspath(dcap_emil_zip_ifle))
        fname = os.path.basename(dcap_emil_zip_ifle)
        cmd = f'cd {dire} && unzip -o {fname}'
        kw('Run', cmd).splitlines()
        lines = kw('Run', f'more {dire}/contents.json|grep emil|grep path').splitlines()
        fname = [x.strip().split(':')[-1].replace('"', '').strip() for x in lines if '"path"' in x]
        if fname:
            return os.path.join(dire, fname[0].replace(',', ''))
        else:
            raise Exception('Could not find the emil file path.')

    def l2_parse_emil_log(self, emil_file, output_file, cpc_ip,
                          cpc_username, cpc_password, sack="LN34.0_Cell_Trace",
                          profile=''):
        """
        把抓到的emil文件送到 emil 服务器上解析成 csv 格式 ；

        * 说明 *
        为了解析 emil，需要有一个windows的控制PC，在上面安装好emil，

        case会把.emil文件上传到这个控制PC上，通过命令行解析.emil 为 .csv 格式的文件，然后再拿回来；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | emil_file | 字符串 | 是 |  | emil log文件名，从 l2_unpack_dcap_emil_log 返回而来 |
        | output_file | 字符串 | 是 |  | csv 输出文件全路径 |
        | cpc_ip | 字符串 | 是 |  | emil 服务器的ip地址 |
        | cpc_username | 字符串 | 是 |  | emil 服务器的用户名 |
        | cpc_password | 字符串 | 是 |  | emil 服务器的密码 |
        | sack | 字符串 | 否 | LN34.0_Cell_Trace | 指定用来解析的Sack |
        | profile | 字符串 | 否 |  | 指定解析的profile，缺省是自动匹配 |

        *返回值:* 无

        *示例:*
        | l2 parse emil log | /home/ute/temp/new.emil | ${CASE_DIRE}/ta.csv | 10.56.111.131 |
        | ... | noklab\\\\csv5-tester | Nokia123! |

        """

        domain, user = cpc_username.split(r'\\')
        ds = r'\\\\'
        bname = os.path.basename(emil_file)
        kw('Cpc Setup', 'name=emil_server', f'host={cpc_ip}',
           f'username={cpc_username}', f'password={cpc_password}', 'os=windows')
        kw('Cpc Exec Command', 'name=emil_server', r'command=del c:\\ta\\ta.emil')
        kw('Cpc Exec Command', 'name=emil_server', r'command=del c:\\ta\\ta.csv')
        kw('Run', f'sshpass -p {cpc_password} scp {emil_file} {domain}{ds}{user}@{cpc_ip}:c:/ta/{bname}')
        kw('Cpc Exec Command', 'name=emil_server', r'command=dir c:\\ta\\' + bname)
        kw('Cpc Exec Command', 'name=emil_server', r'command=dir c:\\ta\\ta.csv')
        cmd = r'cmd /c ""C:\\Program Files\\Emil\\Emil.exe" c:\\ta\\' + bname + ' -tocsv onefile -autoclose'
        cmd += r' -destination C:\\ta\\ta.csv'
        cmd += f' -Sack "{sack}"'
        if profile:
            cmd += f' -Profile "{profile}"'
        cmd += '"'
        output = kw('Cpc Exec Command', 'name=emil_server', f'command={cmd}')
        kw('Cpc Exec Command', 'name=emil_server', r'command=dir c:\\ta\\ta.csv')
        kw('log to console', output)
        kw('Cpc Exec Command', 'name=emil_server', r'command=dir c:\\ta\\*.csv')
        kw('Cpc Teardown', 'name=emil_server')
        ssh_option = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
        kw('Run', f'sshpass -p {cpc_password} scp {ssh_option} {domain}{ds}{user}@{cpc_ip}:c:/ta/ta.csv {output_file}')

    def _get_cpc(self, host):
        cpc = gv.mo['ssh'].get(host, None)
        if not cpc:
            gv.logger.info(f'ssh to {host} 连接尚未初始化')
            curr_path = os.path.dirname(os.path.abspath(__file__))
            config_path = os.path.join(os.sep.join(curr_path.split(os.sep)[:-4]), 'HAZ5', 'config')
            ssh_list = json.load(open(os.path.join(config_path, 'ssh.json'), 'r', encoding='utf-8'))
            if host in ssh_list:
                item = ssh_list[host]
                cpc_os = item.get('os', 'windows')
                if 'window' in cpc_os.lower():
                    username = item.get('username', 'noklab\\csv5-tester')
                    password = item.get('password', 'Nokia123!')
                else:
                    username = item.get('username', 'ute')
                    password = item.get('password', 'qqwweeRR0-')

                from lib_devices.pet_ssh import cpc_factory
                kwargs = dict(host=host, username=username, password=password, os=cpc_os)
                cpc = cpc_factory(**kwargs)
                cpc.setup()
                gv.mo['ssh'].update({host: cpc})
            else:
                raise Exception(f'ssh.json文件里面没有 {host} 的配置')
        return cpc

    def l2_ssh_exec_command(self, host, command, use_shell='NO', in_backgroud='NO'):
        """
        ssh到远程的主机上执行命令；

        注意：这里的host的详细信息，比如用户名密码等，保存在config/ssh.json文件里面，这样这里就不需要带相关信息了；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 | 无 | 远程主机的ip地址 |
        | command | 字符串 | 是 |  | 要执行的命令 |
        | use_shell | 字符串 | 否 | NO | 是否用shell模式执行，shell模式只发送命令，其他都不管 |
        | in_backgroud | 字符串 | 否 | NO | 是否要后台执行 |

        *返回值:* 命令的输出；

        *示例:*
        | l2_ssh_exec_command | 10.69.9.58 | iperf -s -d -D |
        """
        cpc = self._get_cpc(host)
        if gv.mybool(use_shell):
            return cpc.exec_shell_command(command)
        elif gv.mybool(in_backgroud):
            return cpc.exec_command_background(command=command)
        else:
            return cpc.exec_command(command=command)

    def l2_ssh_get_file(self, host, remote_file, local_file):
        """
        ssh到远程的主机上获取文件

        注意：这里的host的详细信息，比如用户名密码等，保存在config/ssh.json文件里面，这样这里就不需要带相关信息了；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 | 无 | 远程主机的ip地址 |
        | remote_file | 字符串 | 是 |  | 要下载的文件名 |
        | local_file | 字符串 | 是 |  | 保存到本地的文件名 |

        *返回值:* 无

        *示例:*
        | l2_ssh_get_file | 10.69.9.58 | /tmp/iperf3.pcap | iperf3.pcap |
        """
        cpc = self._get_cpc(host)
        cpc.get_file_from_cpc(remote_file, local_file)

    def l2_setup_android_ue(self, serialno):
        """
        准备一个UE

        这个 keyword 和 Pet Setup UE的区别是：这里只需要一个serialno作为参数；

        所有手机的信息，都被保存到了andriod.json文件里面；这样可以统一管理所有的安卓手机

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | serialno | 字符串 | 是 | 无 | 安卓手机的序列号 |

        *返回值:* Andriod UE对象

        *示例:*
        | ${ue1}= | l2_setup_android_ue | 0123456789 |
        """
        ue = gv.mo['android'].get(serialno, None)
        if ue is None:
            gv.logger.info(f'安卓手机 {serialno} 尚未初始化')
            curr_path = os.path.dirname(os.path.abspath(__file__))
            config_path = os.path.join(os.sep.join(curr_path.split(os.sep)[:-4]), 'HAZ5', 'config')
            ue_list = json.load(open(os.path.join(config_path, 'android.json'), 'r', encoding='utf-8'))

            if serialno in ue_list:
                from lib_devices.pet_android_ue import c_android_ue
                item = ue_list[serialno]
                cpc_os = item.get('os', 'windows')
                if 'window' in cpc_os.lower():
                    username = item.get('username', 'noklab\\csv5-tester')
                    password = item.get('password', 'Nokia123!')
                else:
                    username = item.get('username', 'ute')
                    password = item.get('password', 'qqwweeRR0-')
                ueinfo = dict(logger=logger)
                ueinfo.update(item)
                ueinfo.update(username=username, password=password, model=item.get('model', 'xiaomi'))
                ue = c_android_ue(**ueinfo)
                ue.serialno = serialno
                ue.setup()
                gv.mo['android'].update({serialno: ue})
                return ue
            else:
                raise Exception(f'android.json文件里面没有 {serialno} 的配置')
        return ue

    def l2_call_ue(self, serialno, method, **kwargs):
        """
        调用安卓UE的某个方法

        注意：这里的UE的详细信息，比如用户名密码等，保存在config/android.json文件里面，这样这里就不需要带相关信息了；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | serialno | 字符串 | 是 | 无 | ue的序列号 |
        | method | 字符串 | 是 |  | 要调用的方法 |
        | kwargs | 列表 | 否 |  | 调用方法需要的参数 |

        *返回值:* 无

        *示例:*
        | l2_call_ue | 77bbd1f4 | exec_adb_shell_command | command=ls /sdcard |
        """
        if isinstance(serialno, str):
            ue = self.l2_setup_android_ue(serialno)
        else:
            ue = serialno
        return kw('call method', ue, method, *[f'{x}={kwargs[x]}' for x in kwargs])
