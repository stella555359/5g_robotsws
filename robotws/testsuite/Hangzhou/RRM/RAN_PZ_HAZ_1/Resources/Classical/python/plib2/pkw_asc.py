# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

from taf.internal.aliasing import aliasing_scope
import logging


class pkw_asc(object):

    """
    This library will provide keywords to operate ASC.

    *Usage:*

    -   *Import the library*
    Library  ../../Resources/python/plib2/pkw_asc.py

    -   *Example for using :*

    | ASC Setup | name=asc65 |

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('PetTA')

    def asc_setup(self, host, port, username, password, name='asc', ):
        """
        This keyword will create a ASC object

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | host | string | Y | None |  ip of ASC |
        | port | integer | Y | None |  access port for ASC |
        | username | string | Y | switch | Username for access ASC |
        | password | string | Y | switch | Password for access ASC |

        *Return:* ASC Object

        *Example:*
        | ASC Setup| host=10.21.41.22 | port=2202 | username=switch| password=switch | name=asc65 |

        """
        from lib_devices.pet_asc import c_pet_asc
        asc = c_pet_asc(host, port, username, password)
        self.store.add(asc, name)
        return asc

    @lookup_handler.implicit_lookup
    def asc_execute_command(self, command, name='ucs'):
        """
        This keyword will execute command on ASC

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | command | string | Y |  | Your command |
        | name | string | Y | None | alias name for ASC object |

        *Return:* None

        *Example:*
        | ASC Execute Command | command=show groups | name=asc65 |

        """
        return name.execute_command(command)

    @lookup_handler.implicit_lookup
    def asc_lock_group(self, groupname, name='ucs'):
        """
        This keyword will lock a goup

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | username | string | Y | tm500 | username used to lock group |
        | groupname | string | Y |  | group name to be locked |
        | name | string | Y | None | alias name for ASC object |

        *Return:* None

        *Example:*
        | ASC Lock Group | username=tm500 | groupname=Units-1 | name=asc65 |

        """
        username = name.get_resource_map()[groupname].user
        name.execute_command('username {}'.format(username))
        return name.execute_command('lockgroup "{}"'.format(groupname))

    @lookup_handler.implicit_lookup
    def asc_unlock_group(self, groupname, name='ucs'):
        """
        This keyword will unlock a goup

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | username | string | Y | tm500 | username used to lock group |
        | groupname | string | Y |  | group name to be unlocked |
        | name | string | Y | None | alias name for ASC object |

        *Return:* None

        *Example:*
        | ASC Unlock Group | username=tm500 | groupname=Units-1 | name=asc65 |

        """
        username = name.get_resource_map()[groupname].user
        name.execute_command('username {}'.format(username))
        return name.execute_command('unlockgroup "{}"'.format(groupname))

    @lookup_handler.implicit_lookup
    def asc_poweroff_group(self, groupname, name='ucs'):
        """
        This keyword will poweroff a goup

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | username | string | Y | tm500 | username used to poweroff group |
        | groupname | string | Y |  | group name to be poweroff |
        | name | string | Y | None | alias name for ASC object |

        *Return:* None

        *Example:*
        | ASC Poweroff Group | username=tm500 | groupname=Units-1 | name=asc65 |

        """
        username = name.get_resource_map()[groupname].user
        name.execute_command('username {}'.format(username))
        return name.execute_command('setpower OFF "{}"'.format(groupname))

    @lookup_handler.implicit_lookup
    def asc_poweron_group(self, groupname, name='ucs'):
        """
        This keyword will poweron a goup

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | username | string | Y | tm500 | username used to poweron group |
        | groupname | string | Y |  | group name to be poweron |
        | name | string | Y | None | alias name for ASC object |

        *Return:* None

        *Example:*
        | ASC Poweron Group | username=tm500 | groupname=Units-1 | name=asc65 |

        """
        username = name.get_resource_map()[groupname].user
        name.execute_command('username {}'.format(username))
        return name.execute_command('setpower ON "{}"'.format(groupname))

    def asc_teardown(self, name):
        """
        This keyword will teardown a ASC object

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | name | string | Yes |  | name for asc |

        *Return:* None

        *Example:*
        | asc_teardown | name=asc |

        """
        self.store.remove(name)
