# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Qi Rengang
:contact: rengang.qi@alcatel-sbell.com.cn
:maintainer: I_MN_RAN_L2_SW_3_CN_SG9_TA_GMS
:contact: i_mn_ran_l2_sw_3_cn_sg9_ta@internal.nsn.com
"""


from .pscli_imp import Macpscli


class Pscli_Control(object):

    def __init__(self):
        pass

    def set_rad_parameter(self, condition, node_type, cell_id, parameter, value="", hw_ver="fsmr4",
                          host_ip='127.0.0.1', port='22', **kwargs):
        """This keyword is used to set R&D parameters or log level by pscli tool.
        :param String condition:  Just like this: "setlog",setrd"
        :param String node_type:  The indicator of MAC core: UL, DL, ALL.
        :param String cell_id:  The cell id, eg: 11, 12, 13 or ALL
        :param String parameter:  Set item name, eg:FID_DLHARQ or ALL
        :param String value:  The value needed to set
        :param String hw_ver:  ** Deprecated parameter.
        :param String host_ip: Host ip of enb control pc
        :param String port: ssh port

         |

        :Full support for remote host is available via kwargs:
            * **enb_ip** (string)  - Enb ip. Default is 192.168.255.1.
            * **enb_port** (string)  - Enb port. Default is 15003.
            * **username** (string)  - Username for remote host authentication. Default is 'ute'.
            * **password** (string)  - Password for remote host authentication. Default is 'ute'.
            * **prompt** (string)    - SSH prompt received after logging in remote host. Default is '$ '.


        """
        Macpscli(host_ip, **kwargs).set_rad_parameter(condition, node_type, cell_id, parameter, value)

    def query_rad_parameter(self, condition, node_type, cell_id, parameter, hw_ver="fsmr4", host_ip='127.0.0.1',
                            port='22', **kwargs):
        """This keyword is used to query R&D parameters or log level by pscli tool.
        :param String condition:  Just like this: querylog","queryrd"
        :param String node_type:  The indicator of MAC core: UL, DL, ALL.
        :param String cell_id:    The cell id, eg: 11, 12, 13 or ALL
        :param String parameter:  Query item name, eg:FID_DLHARQ or ALL
        :param String hw_ver:  ** Deprecated parameter.
        :param String host_ip: Host ip of enb control pc
        :param String port:  ssh port
        :return:                      query value.
        :rtype:                       string

         |

        :Full support for remote host is available via kwargs:
            * **enb_ip** (string)  - Enb ip. Default is 192.168.255.1.
            * **enb_port** (string)  - Enb port. Default is 15003.
            * **username** (string)  - Username for remote host authentication. Default is 'ute'.
            * **password** (string)  - Password for remote host authentication. Default is 'ute'.
            * **prompt** (string)    - SSH prompt received after logging in remote host. Default is '$ '.


        """
        return Macpscli(host_ip, **kwargs).query_rad_parameter(condition, node_type, cell_id, parameter)

    def prepare_tools(self, host_ip='127.0.0.1'):
        """
        Prepare pstool.zip in /opt/TtiTracer folder
        """
        Macpscli(host_ip).ensure_pstool_existed()
