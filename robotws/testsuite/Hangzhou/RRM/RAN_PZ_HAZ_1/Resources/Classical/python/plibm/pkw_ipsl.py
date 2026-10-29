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


class pkw_ipsl(object):

    """
    This library will provide keywords for IPSL.

    *Usage:*

    -   *Import the library*
    Library  ../../Resources/python/plib2/pkw_ipsl.py

    -   *Example for using :*

    | ipsl setup | host=10.101.2.32 | username=noklab\\csv5-tester | password=Nokia123! | os=windows | name=ipsl32 |
    | ipsl stop app | name=ipsl32 |
    | ipsl start app | name=ipsl32 | app_path=c:\\IpslTools\\ips32.exe |
    | ... | config_path=C:\\IpslTools\\5.2.1.2.2_8931_Tim_QCI7_modify_QCI\\IPS.cfg |
    | wait_until_ipsl_is_ready | name=ipsl32 | exp_conn=1 | smflist=10.70.123.2,10.110.163.34 |
    | ... | smfusername=ipsl | smfpassword=system123 |
    | ipsl teardown | name=ipsl32 |
    | restart_ipsl_with_config | 56 | "C:\\IpslTools\\5.2.1.2.2_YSF_ARP9-CQI2\\IPS.cfg" |

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def ipsl_setup(self, name, **kwargs):
        """
        This keyword will create a IPSL object

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes |  | name for the ipsl object |
        | host | string | Yes |  | ip of ipsl control ip |
        | username | string | Yes |  | username for ipsl control pc |
        | password | string | Yes |  | password for ipsl control pc |
        | os | string | Yes |  | os for ipsl control pc, like: windows/linux |

        *Return:* None

        *Example:*
        | ipsl setup | host=10.101.2.32 | username=noklab\\csv5-tester | password=Nokia123! | os=windows | name=ipsl32 |

        """
        from lib_devices.pet_ssh import cpc_factory
        self.cpc = cpc_factory(host=kwargs.get('host'),
                               username=kwargs.get('username'),
                               password=kwargs.get('password'),
                               os=kwargs.get('os', 'windows'))
        self.cpc.setup()
        self.store.add(self, name)
        return self

    def ipsl_teardown(self, name='ipsl'):
        """
        This keyword will teardown a IPSL object

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes |  | name for the ipsl object |

        *Return:* None

        *Example:*
        | ipsl teardown | name=ipsl32 |

        """
        self.store.remove(name)

    @lookup_handler.implicit_lookup
    def ipsl_stop_app(self, name):
        """
        This keyword will stop ipsl process

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes | |  | name for the ipsl object |

        *Return:* None

        *Example:*
        | ipsl Stop App | name=ipsl32 |


        """
        return name.cpc.exec_command('taskkill /f /im ips32.exe')

    @lookup_handler.implicit_lookup
    def ipsl_start_app(self, name, app_path, config_path):
        """
        This keyword will start ipsl app

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes |  | name for ipsl object |
        | app_path | string | Yes |  | ipsl application path |
        | config_path | string | Yes | | config file path for ipsl |

        *Return:* None

        *Example:*
        | ipsl start app | name=ipsl32 | app_path="c:\\IpslTools\\ips32.exe" |
        | ... | config_path="C:\\IpslTools\\5.2.1.2.2_8931_Tim_QCI7_modify_QCI\\IPS.cfg" |

        """
        self.app_path = app_path
        self.config_path = config_path
        name.cpc.start_application(app_path, config_path)
        import time
        time.sleep(5)
        lines = name.cpc.exec_command('more "{}"|findstr L_PORT'.format(config_path)).splitlines()
        lines = [x for x in lines if 'L_PORT' in x]
        import re
        self.app_port = re.findall(r'L_PORT=([\d]+)', lines[0])[0]
        logger.info('IPSL Port: ' + self.app_port)
        return self.app_port

    @lookup_handler.implicit_lookup
    def ipsl_all_mme_connected(self, name, exp_conn):
        """
        This keyword will check the connections between ipsl and smf is ready

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes |  | name for ipsl object |
        | exp_conn | integer | Yes |  | expected ipsl connection count |

        *Return:* None

        *Example:*
        | ipsl_all_mme_connected | name=ipsl32 | exp_conn=2 |

        """

        port = name.app_port
        logger.info('Check if port is connected by MME')
        lines = name.cpc.exec_command('netstat -nao|findstr {}|findstr ESTABLISHED'.format(port)).splitlines()
        lines = [x for x in lines if x.strip()]
        logger.info(lines)
        if len(lines) >= int(exp_conn):
            logger.info('IPSL has been connected with MME')
        else:
            logger.info('IPSL has not been connected with MME')
        return len(lines) >= int(exp_conn)

    @lookup_handler.implicit_lookup
    def ipsl_restart_in_smf(self, name, smfip, username, password):
        """
        This keyword will restart ipsl config in smf

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes |  | name for ipsl object |
        | smfip | string | Yes |  | ip address of smf |
        | username | string | Yes | | username used to login smf |
        | password | string | Yes | | password used to login smf |

        *Return:* None

        *Example:*
        | ipsl_restart_in_smf | name=ipsl32 | smfip=10.70.123.2 | username=ipsl | password=system123 |

        """

        from lib_devices.pet_smf import c_smf_client
        smf = c_smf_client(smfip, 22, username, password, name.cpc.host)
        smf.restart_ipsl()

    def wait_until_ipsl_is_ready(self, name, exp_conn, smflist, smfusername, smfpassword):
        """
        This keyword will check and wait until ipsl is ready

        After ipsl app start, it will check if the connections between ipsl and smf is ok;

        if not, it will restart ipsl in smf

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes |  | name for ipsl object |
        | exp_conn | integer | Yes |  | expected ipsl connection count |
        | smflist | string | Yes | | multiple smf ip address |
        | smfusername | string | Yes | | username used to login smf |
        | smfpassword | string | Yes | | password used to login smf |

        *Return:* None

        *Example:*
        | wait_until_ipsl_is_ready | name=ipsl32 | exp_conn=1 | smflist=10.70.123.2,10.110.163.34 |
        | ... | smfusername=ipsl | smfpassword=system123 |

        """

        for i in range(24):  # default is 60, should be change back
            if kw('ipsl_all_mme_connected', f'name={name}', f'exp_conn={exp_conn}'):
                return 0
            else:
                kw('sleep', '5s', 'Repeat check if smf connected')
        kw('log to console', 'IPSL could not ready in first 1 minustes')
        for smfip in smflist.split(','):
            kw('ipsl_restart_in_smf', f'name={name}', f'smfip={smfip.strip()}', f'username={smfusername}',
               f'password={smfpassword}')

        for i in range(12):
            if kw('ipsl_all_mme_connected', f'name={name}', f'exp_conn={exp_conn}'):
                return 0
            else:
                kw('sleep', '5s', 'Repeat check if smf connected')

        raise Exception('IPSL could not be reached in 5 minutes.')
