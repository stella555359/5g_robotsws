# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

from taf.internal.aliasing import aliasing_scope
import logging


class pkw_shenick(object):

    """
    This library will provide keywords to operate shenick.

    *Usage:*

    -   *Import the library*
    Library  ../../Resources/python/plib2/pkw_shenick.py


    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def shenick_setup(self, host, port, partition, username='cli', password='diversifEye', name='shenick'):
        """
        This keyword will create a shenick object

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | host | string | Y | None |  ip of shenick |
        | port | integer | Y | None |  access port for shenick |
        | partition | integer | Y | None |  partition for shenick |
        | username | string | N | cli | Username for access shenick |
        | password | string | N | diversifEye | Password for shenick |
        | alias | string | Y | shenick | name for the shenick object |

        *Return:* ASC Object

        *Example:*
        | Shenick Setup| host=10.21.41.22 | port=2202 | partition=1 | name=shenick |

        """
        from lib_devices.pet_shenick import c_pet_shenick
        obj = c_pet_shenick(host, port, partition, username, password)
        self.store.add(obj, name)
        return obj

    def shenick_teardown(self, name):
        self.store.remove(name)

    @lookup_handler.implicit_lookup
    def shenick_stop_running_test_group(self, name='shenick'):
        """
        This keyword will stop the running test group of shenick

        *Input Param:* None
        | Parameter | Type | Man. | Default | Description |
        | name | string | Y | shenick | name for the shenick object |

        *Return:* None

        *Example:*
        | Shenick Stop Running Test Group | name=shenick |

        """
        return name.stop_running_test_group()

    @lookup_handler.implicit_lookup
    def shenick_start_test_group(self, test_group_name, name='shenick', ):
        """
        This keyword will start a test group

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | test_group_name | string | Y |  | test group name to start |
        | name | string | Y | None | alias name for ASC object |

        *Return:* None

        *Example:*
        | Shenick Start Test Group | test_group_name=TG | name=shenick |

        """
        return name.start_test_group(test_group_name)
