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

from petbase import gv
logger = gv.logger
kw = gv.kw


class pkw_agent(object):

    """

    =  基本说明  =

    本库主要提供针对 ``Agent`` 的kw

    我们有很多的控制PC，有时候我们需要在控制PC上做一些事情，比如如果控制PC接模组，那么我们需要在这个控制PC上通过COM口发一些命令；

    而我们的case是执行在基站的控制PC,也就是VM上的，所以站在vm的角度上，我们是需要在一个远程的电脑上，执行AT命令；这样的操作是没有命令行支持的；

    为了实现这个功能，我们写了一个python的脚本，在case开始跑的时候，执行下面的操作：
    -   登录到远程的控制PC上；
    -   复制这个python脚本到远程控制pc的c:\\python27目录；
    -   如果这个脚本在运行，那么就杀掉它
    -   用psexec命令来启动这个python脚本

    这个python脚本启动后，就会在30000端口Listen，然后接受远程的命令； 这个时候我们只需要给这个控制PC的30003端口发生特定的命令，脚本就会帮助我们执行相应的操作；

    所以这个脚本就像是我们放在这个机器上的一个间谍；我们称之为 ``Agent``

    这里定义的kw就是来控制这个agent，让它来帮我们执行一些需要的操作，然后返回相应的信息；


    = 本库的引入方法: =

    Library  ../../Resources/python/plib2/pkw_agent.py


    = 所有keyword =

    | agent_setup |
    | agent_list_comports |
    | agent_exec_at_commmand |
    | agent_teardown |


    =  主要kw使用示例  =

    | agent setup | host=10.101.2.32 | username=noklab\\csv5-tester | password=Nokia123! | os=windows | name=agent |
    | agent_list_comports | name=agent |
    | agent_exec_at_commmand | agent | COM14 | AT+CIMI |
    | agent_teardown | name=agent |

    =  相关参考文档  =
    [http://10.56.17.117/work/fileserver/documents/Quectel_X65_AT.txt#truth|Spark模组常用AT命令]

    [http://10.56.17.117/work/fileserver/documents/Quectel_RG520N_RG5x0F_RM5x0N_Series_AT_Manual.pdf#truth|Spark
     RG520 AT命令]

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    proxy_port = 30000
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def agent_setup(self, name, *, host, username=r"noklab\\csv5-tester", password="Nokia123!", os="windows"):
        """
        准备agent

        agent是运行在一个控制PC上的，所以上面的参数主要是用来初始化一个控制PC；在准备一个控制PC之外，这个kw还完成以下动作：

        -   杀掉python运行的pet_proxy_server.py 进程；
        -   从本地复制pet_proxy_server.py 文件到控制PC，从而保证控制PC上运行的是最新的控制脚本；
        -   远程启动 pet_proxy_server.py 进程，
        -   等待 pet_proxy_server.py 进程启动成功（监控30000端口是否在Listen）；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |
        | host | 字符串 | 是 |  | Agent所在控制pc地址 |
        | username | 字符串 | 否 | noklab\\csv5-tester | Agent所在控制pc用户名 |
        | password | 字符串 | 否 | Nokia123! | Agent所在控制pc地址 |
        | os | 字符串 | 否 | windows  | Agent所在控制pc的系统，可能值: windows/linux |

        *返回值:* 无

        *示例:*
        | agent setup | name=agent | host=10.108.230.50 |
        | agent setup | host=10.101.2.32 | username=noklab\\csv5-tester | password=Nokia123! | os=windows | name=agent |

        """
        cpc_alias = f'cpc_{host}'
        kw('cpc_setup', f'name={cpc_alias}', f'host={host}',
            f'username={username}',
            f'password={password}',
            f'os={os}')

        kw('cpc_kill_process_by_keywords', cpc_alias, 'python,pet_proxy_server')
        import os
        server_file_path = os.path.join(gv.py_path, 'lib_devices', 'pet_proxy_server.py')
        kw('cpc_put_file', cpc_alias, server_file_path, r'"c:\\python27\\pet_proxy_server.py"')
        kw('cpc_start_app', cpc_alias, r'c:\\python27\\python.exe c:\\python27\\pet_proxy_server.py')
        from xmlrpc import client as xml_client
        self.server = xml_client.ServerProxy(f'http://{host}:{self.proxy_port}')
        kw('cpc_wait_until_port_is_listening', cpc_alias, self.proxy_port, 30)
        kw('cpc_teardown', cpc_alias)

        self.store.add(self.server, name)
        return self

    @lookup_handler.implicit_lookup
    def agent_exec_at_commmand(self, name, com_port, command, additional_data={}, ignore_error=False):
        """
        让指定的Agent执行AT命令；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |
        | com_port | 字符串 | 是 |  | COM端口名称，例如：COM14 |
        | command | 字符串 | 是 |  | 要执行的AT命令 |
        | ignore_error | 布尔值 | 否 | 否 | 是否要忽略错误 |

        *返回值:* 返回AT命令执行的命令输出，如果执行失败或者碰到error，会自动报错；

        *示例:*
        | agent_exec_at_commmand | name=agent | com_port=COM5 | command=AT+CIMI |
        | agent_exec_at_commmand | name=agent | com_port=COM5 | command=AT+CIMI | ignore_error=${TRUE} |

        """
        logger.info(f'Exec AT command on Agent: {command}')
        result = name.exec_at_command(com_port, command, additional_data)
        logger.info(f'AT Command Output: {result}')
        if result['succeed']:
            logger.info('Command Executed successfully.')
            msg = result['msg']
            if 'error' in msg.lower():
                if ignore_error:
                    logger.warn(f'Found error in command response: \n{msg}')
                else:
                    raise Exception(f'Found error in command response: \n{msg}')
            return msg
        else:
            if ignore_error:
                logger.warn('AT Command Execution failed: {}'.format(result['msg']))
                return result['msg']
            else:
                raise Exception('AT Command Execution failed: {}'.format(result['msg']))

    @lookup_handler.implicit_lookup
    def agent_list_comports(self, name):
        """
        列出远程控制PC上的所有的COM端口；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |

        *返回值:* 列表，每个元素是字典，字典有2个字段：name,description

        dict(description='Quectel USB AT Port (COM14)', name='COM14')

        *示例:*
        | ${info=} | agent_list_comports | name=agent |

        """
        return name.list_comports_of()

    @lookup_handler.implicit_lookup
    def agent_mtu_opration(self, name, ue_index, operation):
        """
        执行 MTU 操作，目前支持 poweron/poweroff

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |
        | ue_index | 整数 | 是 |  | UE 的索引号， 请参考 Spark 软件给定的UE 索引号 |
        | operation | 字符串 | 是 |   | poweron/poweroff |

        *返回值:* 无

        *示例:*
        | mtu_opration | name=sparkpc | ue_index=1 | operation=poweron |
        | mtu_opration | name=sparkpc | ue_index=1 | operation=poweroff |
        """

        if operation.lower() == 'poweron':
            name.spark_mtu_power_control(self.power_contrl_com_port, ue_index, 'on')
        if operation.lower() == 'poweroff':
            name.spark_mtu_power_control(self.power_contrl_com_port, ue_index, 'off')

    @lookup_handler.implicit_lookup
    def agent_attach_spark_ue(self, name, com_port):
        """
        Attach Spark UE

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |
        | com_port | 字符串 | 是 |  | UE的串口号，例如：COM12 |

        *返回值:* 无

        *示例:*
        | agent_attach_spark_ue | name=agent | com_port=COM12 |
        """
        resp = kw('agent_exec_at_command', f'name={name}', f'com_port={com_port}', f'command=AT+CFUN=0')
        attached = 'CFUN: 1,0' in resp
        if attached:
            logger.info('UE已经注册')
        else:
            return kw('agent_exec_at_command', f'name={name}', f'com_port={com_port}', f'command=AT+CFUN=1')

    @lookup_handler.implicit_lookup
    def agent_deattach_spark_ue(self, name, com_port):
        """
        Deattach Spark UE

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |
        | com_port | 字符串 | 是 |  | UE的串口号，例如：COM12 |

        *返回值:* 无

        *示例:*
        | agent_deattach_spark_ue | name=agent | com_port=COM12 |
        """
        resp = kw('agent_exec_at_command', f'name={name}', f'com_port={com_port}', f'command=AT+CFUN=0')
        attached = 'CFUN: 1,0' in resp
        if attached:
            return kw('agent_exec_at_command', f'name={name}', f'com_port={com_port}', f'command=AT+CFUN=0')
        else:
            logger.info('UE已经解注册')

    @lookup_handler.implicit_lookup
    def agent_add_apn_for_spark_ue(self, name, com_port, apn):
        """
        给 Spark UE 添加 APN

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |
        | com_port | 字符串 | 是 |  | UE的串口号，例如：COM12 |
        | apn | 字符串 | 是 |  | apn的名称 |

        *返回值:* 无

        *示例:*
        | agent_add_apn_for_spark_ue | name=agent | com_port=COM12 | apn=stdmbr |
        """
        return kw('agent_exec_at_command', f'name={name}', f'com_port={com_port}', f'AT+CGDCONT=1,"IP","{apn}"')

    @lookup_handler.implicit_lookup
    def agent_ip_for_spark_ue(self, name, com_port):
        """
        获取 Spark UE 的 IP 地址

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |
        | com_port | 字符串 | 是 |  | UE的串口号，例如：COM12 |

        *返回值:* 无

        *示例:*
        | ${ueip}= | agent_ip_for_spark_ue | name=agent | com_port=COM12 |
        """
        text = kw('agent_exec_at_command', f'name={name}', f'com_port={com_port}', f'AT+CGPADDR=1')
        import re
        pattern = r'\b((?!0|192|127)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b'
        matches = re.findall(pattern, text)
        if len(matches) == 1:
            return matches[0]
        elif len(matches) > 1:
            return matches
        else:
            return ''

    def agent_teardown(self, name):
        """
        清除agent

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | agent的名称 |

        *返回值:* 无

        *示例:*
        | agent_teardown | name=agent |

        """

        self.store.remove(name)
