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


class pkw_cpc(object):

    """
    本库主要是提供对控制pc的访问的keyword。目前大部分的控制pc都是windows的，不过这下keyword也是支持linux的控制pc的。

    对控制PC主要有以下功能的keyword：
    -   执行命令；
    -   推送文件到控制pc
    -   从控制pc上拿文件
    -   在控制pc上杀带有关键字的进程
    -   启动控制PC上带GUI的程序，比如TMA；
    -   等到控制PC上有指定的端口在LISTEN

    *使用方法:*

    -   *引入本库*
    Library  ../../Resources/python/plib2/pkw_cpc.py

    -   *使用示例:*

    | cpc setup | name=cpc | host=10.101.2.32 | username=noklab\\csv5-tester | password=Nokia123! | os=windows |
    | cpc_exec_command | name=cpc | command=dir c:\\ |

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def cpc_setup(self, name, *, host, username=r"noklab\csv5-tester", password="Nokia123!", os="windows"):
        """
        准备控制PC

        *输入参数:
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | 控制PC的名称 |
        | host | 字符串 | 是 |  | 控制pc地址 |
        | username | 字符串 | 否 | noklab\\csv5-tester | 控制pc用户名 |
        | password | 字符串 | 否 | Nokia123! | 控制pc地址 |
        | os | 字符串 | 否 | windows  | 控制pc的系统，可能值: windows/linux |

        *返回值:* 无

        *示例:*
        | cpc_setup | name=agent | host=10.108.230.50 |
        | cpc_setup | host=10.101.2.32 | username=noklab\\\\csv5-tester | password=Nokia123! |
        | ...  | os=windows | name=agent |

        """
        from lib_devices.pet_ssh import cpc_factory
        kwargs = dict(name=name, host=host, username=username, password=password, os=os)
        cpc = cpc_factory(**kwargs)
        cpc.setup()
        self.store.add(cpc, name)
        return self

    @lookup_handler.implicit_lookup
    def cpc_exec_command(self, name, command):
        """

        在控制PC上执行指定的命令

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | 控制PC的名称 |
        | command | 字符串 | 是 |  | 要执行的命令 |

        *返回值:* 返回命令执行的命令输出，

        *示例:*

        | cpc_exec_command | name=cpc | command=dir c:\\ |

        """
        return name.exec_command(command)

    @lookup_handler.implicit_lookup
    def cpc_get_file(self, name, remote_file, local_file):
        """

        从控制PC上拿文件过来

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | 控制PC的名称 |
        | remote_file | 字符串 | 是 |  | 控制PC上的文件全路径 |
        | local_file | 字符串 | 是 |  | 复制到本地的文件的全路径 |

        *返回值:* 无

        *示例:*

        | cpc_get_file | name=cpc | remote_file=c:\\ta\\a.txt | local_file=a.txt |

        """
        return name.get_file_from_cpc(remote_file, local_file)

    @lookup_handler.implicit_lookup
    def cpc_put_file(self, name, remote_file, local_file):
        """

        把本地文件推送到控制PC上

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | 控制PC的名称 |
        | remote_file | 字符串 | 是 |  | 控制PC上的文件全路径 |
        | local_file | 字符串 | 是 |  | 复制到本地的文件的全路径 |

        *返回值:* 无

        *示例:*

        | cpc_put_file | name=cpc | remote_file=c:\\ta\\a.txt | local_file=a.txt |

        """
        return name.put_file_to_cpc(remote_file, local_file)

    @lookup_handler.implicit_lookup
    def cpc_start_app(self, name, *args):
        """

        在控制PC上启动进程；由于windows的限制，远程启动程序需要用psexec，

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | 控制PC的名称 |
        | args | 多个参数 | 否 |  | 启动程序命令的各个部分 |

        *返回值:* 无

        *示例:*

        | cpc_start_app | name=cpc | "${tma_path}" | /u | "Default User"  | /c y /p 5003 /a n |

        """
        return name.start_application(*args)

    @lookup_handler.implicit_lookup
    def cpc_kill_process_by_keywords(self, name, keywords):
        """

        杀掉控制pc上的带指定关键字的进程；

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | cpc的名称 |
        | keywords | 字符串 | 是 | 关键字，用来标识进程，多个用逗号隔开 |

        *返回值:* 无

        *示例:*

        | cpc_kill_process_by_keywords | name=cpc | keywords=python,pet_pet_proxy_server |

        """
        return name.kill_process_by_keywords(keywords.split(','))

    @lookup_handler.implicit_lookup
    def cpc_wait_until_port_is_listening(self, name, port_num, timeout=30):
        """

        等cpc上的某个端口进入listen；

        通常我们启动某个进程后，如果这个进程会在某个指定端口listen，那么通过查看此端口是否在listen来判断进程启动成功；

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | cpc的名称 |
        | port_num | 整数 | 是 |  | 监控的端口 |
        | timeout | 整数 | 否 | 监控超时的时常，default是30s |

        *返回值:* 无

        *示例:*

        | cpc_wait_until_port_is_listening | name=cpc | port_num=30003 | timeout=30 |

        """
        return name.wait_until_port_is_listening(port_num, timeout)

    @lookup_handler.implicit_lookup
    def cpc_exec_shell_command(self, name, command):
        """

        在控制PC上用Shell模式执行指定的命令

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | 控制PC的名称 |
        | command | 字符串 | 是 |  | 要执行的命令 |

        *返回值:* 返回命令执行的命令输出，

        *示例:*

        | cpc_exec_command | name=cpc | command=dir c:\\ |

        """
        return name.exec_shell_command(command)

    def cpc_teardown(self, name):
        """

        清除控制pc

        *输入参数:*

        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | 控制PC的名称 |

        *返回值:* 无

        *示例:*

        | cpc_teardown | name=cpc |

        """
        self.store.remove(name)
