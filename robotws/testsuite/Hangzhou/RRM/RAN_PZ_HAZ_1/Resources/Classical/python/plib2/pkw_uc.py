# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

from taf.internal.aliasing import aliasing_scope
import logging

from petbase import gv
kw = gv.kw
logger = gv.logger


class pkw_uc(object):

    """
    本库提供对 ``UltraCaller Server`` 访问的 keyword
    手机如果要做 TCP 业务，有两种办法：
        -   用 iperf 命令，但是这种方法需要安卓手机能够执行adb root命令，有些手机，比如华为是不支持的；
        -   用 Ultracaller 的 APP NAA 来实现，通过 NAA 来做业务
    所以这里主要提供 UltracallerServer 相关的 keyword；

    *本库引入方法:*

    -   *Import the library*
    Library  ../../Resources/python/plib2/pkw_uc.py

    -   *使用示例 :*

    | Ucs Setup | name=myucs |
    | Ucs start test | name=myucs | imei=1234456 | test=testnameinuc |

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def ucs_setup(self, name='ucs', *, host='10.21.41.22'):
        """
        准备 UltraCaller Server

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | UltraCallerServer 的别名 |
        | host | 字符串 | 否 | 10.21.41.22 | UltraCallerServer 的ip地址 |

        *返回值:* 无

        *示例:*

        | UCS Setup | host=10.21.41.22 | name=ucs |

        """
        from lib_devices.pet_ultracaller import UltraCallerServer
        uc = UltraCallerServer(host, logger)
        self.store.add(uc, name)

    @lookup_handler.implicit_lookup
    def ucs_start_test(self, name='ucs', imei='', test=''):
        """
        在 UltraCallerServer 上启动 IMEI 指定的 UE 的 test

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | UltraCallerServer 的别名 |
        | imei | 字符串 | 是 |  | UE 的 IMEI |
        | test | 字符串 | 是 |  | UltraCallerServer 里面配置的 test 的名称 |

        *返回值:* 无

        *示例:*

        | UCS Start Test | name=ucs | imei=123456 | test=FTP_UL_20M |

        """
        return name.start_test(imei, test)

    @lookup_handler.implicit_lookup
    def ucs_stop_test(self, name='ucs', imei='', test=''):
        """
        在 UltraCallerServer 停止 IMEI 指定的 UE 的 test

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | UltraCallerServer 的别名 |
        | imei | 字符串 | 是 |  | UE 的 IMEI |
        | test | 字符串 | 是 |  | UltraCallerServer 里面配置的 test 的名称 |

        *返回值:* 无

        *示例:*

        | UCS Start Test | name=ucs | imei=123456 | test=FTP_UL_20M |

        """
        return name.stop_test(imei, test)

    @lookup_handler.implicit_lookup
    def ucs_start_testsequence(self, name='ucs', imei='', testsequence=''):
        """
        在 UltraCallerServer 上启动 IMEI 指定的 UE 的 test sequence

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | UltraCallerServer 的别名 |
        | imei | 字符串 | 是 |  | UE 的 IMEI |
        | testsequence | 字符串 | 是 |  | UltraCallerServer 里面配置的 test sequence 的名称 |

        *返回值:* 无

        *示例:*

        | UCS Start TestSequence | name=ucs | imei=123456 | testsequence=jufei_test |

        """
        return name.start_test_sequence(imei, testsequence)

    @lookup_handler.implicit_lookup
    def ucs_stop_testsequence(self, name='ucs', imei='', testsequenceid=''):
        """
        在 UltraCallerServer 停止 IMEI 指定的 UE 的 test

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | UltraCallerServer 的别名 |
        | imei | 字符串 | 是 |  | UE 的 IMEI |
        | testsequenceid | 字符串 | 是 |  | UltraCallerServer 里面配置的 test sequence 的 id |

        *返回值:* 无

        *示例:*

        *Example:*
        | UCS stop TestSequence | name=ucs | imei=123456 | testsequenceid=xxxxxx |

        """
        return name.stop_test_sequence(imei, testsequenceid)

    @lookup_handler.implicit_lookup
    def ucs_stop_all(self, name='ucs', imei=''):
        """
        在 UltraCallerServer 停止 IMEI 指定的 UE 的 所有业务

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | UltraCallerServer 的别名 |
        | imei | 字符串 | 是 |  | UE 的 IMEI |

        *返回值:* 无

        *示例:*

        | UCS Stop All | name=ucs | imei=123456 |

        """
        return name.stop_all(imei)

    @lookup_handler.implicit_lookup
    def ucs_ue_is_idle(self, name='ucs', imei=''):
        """
        判断 IMEI 指定的 UE 在 UltraCaller Server 是否是Idle

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | name | 字符串 | 是 |  | UltraCallerServer 的别名 |
        | imei | 字符串 | 是 |  | UE 的 IMEI |

        *返回值:* 布尔值 True/False

        *示例:*

        *Example:*
        | ${state}= | UCS ue is idle | name=ucs | imei=123456 |

        """
        return name.is_idle(imei)
