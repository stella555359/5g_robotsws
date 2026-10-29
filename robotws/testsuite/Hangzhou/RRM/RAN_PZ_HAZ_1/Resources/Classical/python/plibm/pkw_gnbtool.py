# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""


from taf.internal.aliasing import aliasing_scope
import logging


class pkw_gnbtool(object):

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
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def gnbtool_setup(self, name='gnbtool', **kwargs):
        """
        This keyword will prepare gnbtool
        It will get gnbtool from /home/ute/store/gnb_logs_tool/gnb_logs.zip
        *Input Param:* None

        *Return:* gnbtool object

        *Example:*
        | Setup gnbtool | name=gnbtool |
        """
        from lib_devices.pet_gnb_tool import gnb_tool
        tool = gnb_tool(logger=self.logger)
        tool.setup()
        self.store.add(tool, name)
        return tool

    @lookup_handler.implicit_lookup
    def gnbtool_start_capture(self, name='gnbtool', **kwargs):
        """
        This keyword will start capture gnblog

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Y | gnbtool | alias for gnb tool |
        | host | string | N | 127.0.0.1 | ip of local vm |
        | port | integer | N | 22 | ssh port for connect |
        | username | string | N | ute | local username |
        | password | string | N | uteUTE! | local password |
        | dest_ip | string | N | 192.168.255.129 | dest ip, 192.168.255.129 or s1 ip |
        | log_dire | string | Y | None | the log path for gnb_logs |
        | option | string | Y | None | option for gnb_logs |
        | stop_keyword | string | N | Press <Enter> | when found this keyword, TA will think the start is ok |

        *Example:*
        *Capture sherpa log*
        | pet_start_capture_gnblog | name=${gnbtool} | password=uteUTE! | option=-O l2ps |

        *Capture sherpa log and tti log*
        | pet_start_capture_gnblog | name=${gnbtool} | password=uteUTE! | option=-O l2ps -ts |

        """
        return name.start(host=kwargs.get('host', '127.0.0.1'),
                          port=kwargs.get('port', 22),
                          username=kwargs.get('username', 'ute'),
                          password=kwargs.get('password', 'uteUTE!'),
                          dest_ip=kwargs.get('dest_ip', '192.168.255.129'),
                          log_dire=kwargs.get('log_dire'),
                          option=kwargs.get('option'),
                          stop_keyword=kwargs.get('stop_keyword', 'Press <Enter>'))

    @lookup_handler.implicit_lookup
    def gnbtool_stop(self, name='gnbtool'):
        """
        This keyword will stop capture gnblog

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | gnbtool | object | Y | None | gnbtool object |

        *Return:* None

        *Example:*
        | gnbtool_stop | name=${gnbtool} |

        """
        return name.stop()
