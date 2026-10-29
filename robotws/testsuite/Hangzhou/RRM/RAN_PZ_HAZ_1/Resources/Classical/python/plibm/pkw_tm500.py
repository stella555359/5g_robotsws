# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

import six
import sys
import time
from taf.internal.aliasing import aliasing_scope
import logging

from petbase import gv
kw = gv.kw
logger = gv.logger


class pkw_tm500(object):

    """
    本库提供 kw 用来控制 TM500

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def restart_tma(self, host, port, username=r'noklab\\csv5-tester', password='Nokia123!',
                    app_path='', os='windows'):
        """
        重启 TMA；如果是debug mode，不真正重启；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
        | port | 端口 | 是 |  | TMA 所在 PC 的 访问端口 |
        | username | 字符串 | 否 | noklab\\csv5-tester  | TMA 所在 windows 系统的用户名 |
        | password | 字符串 | 否 | Nokia123! | TMA 所在 windows 系统的密码 |
        | app_path | 字符串 | 是 |   | TMA.exe文件的全路径 |
        | os | 字符串 | 否 | windows  | TMA 所在的机器的操作系统 |

        *返回值:* 无

        *示例:*

        | restart_tma | host=10.69.2.27 | port=22 | app_path="C:\\Program Files (x86)\\VIAVI\\TM500\\TMA.exe" |

        """
        if gv.debug:
            kw('log to console', 'It is debug mode, will not restart TMA')
            return 0
        if not app_path.strip():
            raise Exception('App path does not specified.')

        alias = 'tm500_cpc'
        username = username.split('\\')[-1]
        app_path = gv.winpath(app_path)
        kw('cpc_setup', f'name={alias}', f'host={host}', f'username=noklab\\\\{username}', f'password={password}',
           f'os={os}')
        kw('cpc_exec_command', f'name={alias}', 'command=taskkill /f /im TmaApplication.exe')
        kw('cpc_exec_command', f'name={alias}', 'command=taskkill /f /im Tma.exe')
        kw('cpc_start_app', f'{alias}', f'"{app_path}"', '/u "Default User" /c y /p 5003 /a n')
        kw('cpc_teardown', f'name={alias}')

    def restart_asc(self, host, port, username='switch', password='switch', groupname='Units-1', powerbreak=[]):
        """
        重启 ASC

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 |  | ASC 的 ip 地址 |
        | port | 端口 | 是 |  | ASC 的访问端口 |
        | username | 字符串 | 否 | switch | ASC 的用户名 |
        | password | 字符串 | 否 | switch | ASC 的密码 |
        | groupname | 字符串 | 否 | Units-1 | 要操作的 ASC 的 Group Name，比如 Units-1 |
        | powerbreak | 列表 | 否 | 空列表 | 相关的 PB 的端口，用列表来保存多个端口 |

        *返回值:* 无

        *示例:*

        *Example:*
        | restart_asc | 10.69.2.27 | 3202 |
        | restart_asc | host=10.69.2.27 | port=3202 | username=switch | password=switch| groupname=Units-1 |

        *指定 APC 信息：*
        | @{asc_powerbreak} = | Create List | 10.69.9.23:3 | 10.69.9.23:5 |
        | restart_asc | host=10.69.2.27 | port=3202 | groupname=Units-1 | powerbreak=@{asc_powerbreak} |

        """

        if not powerbreak:
            raise Exception('powerbreak does not specified.')

        alias = 'tm500_asc'
        kw('asc_setup', f'name={alias}', f'host={host}', f'username={username}',
           f'password={password}', f'port={port}')
        kw('asc_poweroff_group',  f'name={alias}', f'groupname={groupname}')
        kw('asc_unlock_group',  f'name={alias}', f'groupname={groupname}')
        for pbinfo in powerbreak:
            kw('log to console', pbinfo)
            ip, port = pbinfo.split(':')
            kw('pet_pb_operator', 'factory=apc', f'host={ip}', f'port={port}', 'operation=poweroff')
            kw('Sleep', '15s', 'Delay between Power off and Power on')
            kw('pet_pb_operator', 'factory=apc', f'host={ip}', f'port={port}', 'operation=poweron')
        kw('Sleep', '300s', 'Wait for power on done')
        kw('asc_lock_group',  f'name={alias}', f'groupname={groupname}')
        kw('asc_poweron_group',  f'name={alias}', f'groupname={groupname}')
        kw('asc_execute_command', f'name={alias}', 'command=showgroups')
        kw('asc_teardown', f'name={alias}')

    def run_script_on_tm500(self, host, filename, logfile='', failed_keyword=['Assert'], timer=0):
        """
        通过 TMA 执行脚本

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
        | filename | 字符串 | 是 |  | 脚本文件的路径 |
        | logfile | 字符串 | 否 | 空 | 如果指定了文件，可以把脚本的输出写到logfile文件里面去 |
        | failed_keyword | 列表 | 否 | ["Assert"] | 判断命令失败的关键字，只要发现命令输出匹配到关键字，命令执行失败 |
        | timer | 整数 | 否 | 0 | 脚本执行结束后等待的时间，如果有输出可以收到输出 |

        *返回值:* 所有的命令输出

        *示例:*

        *Example:*
        | run_script_on_tm500 | host=10.69.2.27 | filename=${CURR_DIR}/attach.txt | logfile=tm500.log |

        """

        from lib_devices.pet_tma import c_pet_tma
        tma = c_pet_tma(host, logfile, self.logger)
        tma.connect()
        try:
            output = tma.run_script_file(filename, failed_keyword)
            if timer:
                output += tma.read_tm500_output(timeout=timer)
            return output
        finally:
            tma.disconnect()

    def execute_tm500_command(self, host, command, ignore_error=False, timeout=300, wait_response=True):
        """
        通过 TMA 执行命令

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
        | command | 字符串 | 是 |  | 执行的命令 |
        | ignore_error | 布尔值 | 否 | 否 | 是否无视错误 |
        | timeout | 整数 | 否 | 300秒 | 命令执行多久算超时 |
        | wait_response | 布尔值 | 否 | 是 | 是否要等命令的返回 |

        *返回值:* 所有的命令输出

        *示例:*

        | execute_tm500_command | host=10.69.2.27 | command=CHOW |

        """

        from lib_devices.pet_tma import c_pet_tma
        tma = c_pet_tma(host, '', self.logger)
        tma.connect()
        try:
            return tma.execute_tm500_command(command, ignore_error, timeout, wait_response)
        finally:
            tma.disconnect()

    def start_logging_on_tma(self, host, timeout=60):
        '''
        在 TMA 上执行 Start logging, 开始 TMA 的抓 log 动作

        stop logging 只需要调用 execute_tm500_command, command = #$$STOP_LOGGING

        转换 log 只需要调用  execute_tm500_command, command = #$$CONVERT_TO_TEXT 2 或者 #$$CONVERT_TO_TEXT

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
        | timeout | 数字 | 否 | 60s | 执行命令的超时时间 |

        *返回值:* log 文件所在的远程目录的名称

        *示例:*
        | ${remote_log_dire} = | start_logging_on_tma | host=10.69.2.27 |
        '''

        output = kw('execute_tm500_command', host, 'command=#$$START_LOGGING', f'timeout={timeout}')
        remote_tm500_log_dir = ''
        if 'CURRENT LOGGING FOLDER IS' in output:
            remote_tm500_log_dir = [x for x in output.splitlines() if 'CURRENT LOGGING FOLDER IS' in x.upper()]
            if remote_tm500_log_dir:
                remote_tm500_log_dir = remote_tm500_log_dir[0].split("'")[1]
                logger.info(f'TM500 LOG DIRECTORY: {remote_tm500_log_dir}')
                return remote_tm500_log_dir
        raise Exception('Could not find TM500 LOG DIRECTORY')

    # def stop_logging_on_tma(self, host, timeout=60):
    #     '''
    #     在 TMA 上执行 Start logging

    #     *输入参数:*
    #     | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
    #     | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
    #     | timeout | 数字 | 否 | 60s | 执行命令的超时时间 |

    #     *返回值:* log 文件所在的远程目录的名称

    #     *示例:*
    #     | stop_logging_on_tma | 10.69.2.27 |
    #     '''

    #     return kw('execute_tm500_command', host, 'command="#$$STOP_LOGGING"', f'timeout={timeout}')

    # def convert_to_text_on_tma(self, host, timeout=300):
    #     '''
    #     在 TMA 上执行 Convert to text 这个动作，从而将 TM500 的log 转换为 excel格式

    #     *输入参数:*
    #     | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
    #     | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
    #     | timeout | 数字 | 否 | 300s | 执行命令的超时时间 |

    #     *返回值:* log 文件所在的远程目录的名称

    #     *示例:*
    #     | ${remote_log_dire} = | start_logging_on_tma | 10.69.2.27 |
    #     '''

    #     return kw('execute_tm500_command', host, 'command="#$$CONVERT_TO_TEXT 2"', f'timeout={timeout}')

    def set_logtype_file_on_tma(self, host, logtype_file_path, log_option='ProtocolLog', number_of_ue='0'):
        '''
        在 TMA 上设置 TMA 所用的 log type文件；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
        | logtype_file_path | 字符串 | 是 |  | logtype的文件的路径 |
        | log_option | 字符串 | 否 | ProtocolLog | logtype 的选项 |
        | number_of_ue | 字符串 | 否 | 0 | UE 的数量 |

        *返回值:* log 文件所在的远程目录的名称

        *示例:*
        | ${remote_log_dire} = | start_logging_on_tma | host=10.69.2.27 |
        '''
        file_content = open(logtype_file_path).read()
        log_options = []
        if number_of_ue == '0':
            log_opt_cmds = ['#$$LC_CLEAR_ALL',
                            '#$$LC_UE_GROUP "" "0"',
                            '#$$LC_ITM 1 1 1 Manual']
            file_content_new = file_content.replace('UE All', 'UE 0')
        else:
            num = int(number_of_ue) - 1
            log_opt_cmds = ['#$$LC_CLEAR_ALL',
                            '#$$LC_UE_GROUP "" "0-%s"' % num,
                            '#$$LC_ITM 1 1 1 Manual']
            file_content_new = file_content.replace('UE All', 'UE 0-%s' % num)
        file_content = file_content_new.splitlines()
        if not isinstance(log_option, list):
            log_options.append(str(log_option))
        else:
            log_options = log_option

        for content in file_content:
            for log in log_options:
                if log in content:
                    log_opt_cmds.append(content.strip())
                    break

        log_opt_cmds.append('#$$LC_ITM 0 0 0 Automatic')
        log_opt_cmds.append('#$$LC_END')
        ret = ''
        try:
            for cmd in log_opt_cmds:
                ret += kw('execute_tm500_command', host, f'command={cmd}')
                time.sleep(0.5)
        finally:
            pass
        return ret

    def read_tm500_output(self, host, timer):
        '''
        获取TM500的输出

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | host | 字符串 | 是 |  | TMA 所在 PC 的 ip 地址 |
        | timer | 整数 | 是 |  | 等待的时间 |

        *返回值:* log 文件所在的远程目录的名称

        *示例:*
        | ${output} = | read_tm500_output | host=10.69.2.27 | timer=10 |
        '''
        from lib_devices.pet_tma import c_pet_tma
        tma = c_pet_tma(host, '', self.logger)
        tma.connect()
        try:
            tma.read_tm500_output(timer)
        finally:
            tma.disconnect()
