# -*- coding: utf-8 -*-
from robot.api import logger

from rrm_gnb_tool import c_rrm_gnbtool


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

    def start_to_capture_log_with_gnb_tool(self, log_dire, log_type='bip', add_options='-c 1',
                                           dest_ip='192.168.255.129', host='127.0.0.1', port=22,
                                           username='ute', password='L1PZ-hangzhou'):
        """
        This keyword will start to capture bip log with gnb_tool.

        | Parameter | Type | Man. | Default | Description |
        | log_dire | string | Y | None | directory used to save big log |
        | log_type | string | Y | None | directory used to save big log |
        | dest_ip | string | Y | 192.168.255.129 | interface used to capture log |
        | host | string | Y | 127.0.0.1 | the pc used to capture log |
        | port | int | Y | 22 | the ssh port to login in the host |
        | username | string | Y | ute | username to login local pc with ssh |
        | password | string | Y | uteUTE! | password to login local pc with ssh |
        | add_options | string | N |  | addition options for command, like: -c 2 #log of all cells on BBMOD-2|

        *Examples:*
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | password=ute |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | dest_ip=10.108.231.212 |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | add_options=-t5 -c 2 |

        *Return:* None
        """
        return self.tool._start_to_capture_log(log_type, log_dire, dest_ip, host,
                                               port, username, password, add_options)

    def stop_bip_log_with_gnb_tool(self):
        """
        This keyword will stop capturing bip log with gnb_tool and return log filename.

        *Examples:*
        | ${log_filename} = | Stop Bip Log With Gnb Tool |

        *Return:* The full path filename of zipped log file.
        """

        return self.tool.stop_log()

    def mkw(self, kwname, *args):
        from robot.libraries import BuiltIn
        builtin = BuiltIn.BuiltIn()
        return builtin.run_keyword(kwname, *args)
