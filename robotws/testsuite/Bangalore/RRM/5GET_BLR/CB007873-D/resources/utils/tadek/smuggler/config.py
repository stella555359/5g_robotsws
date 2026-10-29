# -*- coding: utf-8 -*-
"""
:author: Bartosz Bugaj
:contact: bartosz.bugaj@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com

This module contains dictionary with mapping of smuggler key (smuggler name , or smuggler name till `-``)
to validator and handler classes for it.


Example structure;

SMUGGLERS = {
    'smuggler name key': {
        'validator': 'Class that will validate passed smuggler',
        'handler': 'Class that will handle given smuggler'
    },
    ...
}
"""

ENB_IP = '192.168.255.129'
ENB_CREDENTIALS = {'user': 'toor4nsn', 'password': 'oZPS0POrRieRtu'}

IPHY_IP = '192.168.200.1'
IPHY_CREDENTIALS = {'user': 'toor4nsn', 'password': 'oZPS0POrRieRtu'}

JUMP_HOST_ENB = {'host': ENB_IP, 'port': 22, 'authenticator': ENB_CREDENTIALS}

SMUGGLERS = {
    'local': {
        'validator': 'LocalSmugglerValidator',
        'handler': 'LocalSmuggler'
    },
    'scp': {
        'validator': 'ScpSmugglerValidator',
        'handler': 'ScpSmuggler'
    },
    'fsm': {
        'validator': 'FsmSmugglerValidator',
        'handler': 'FsmSmuggler'
    },
    'iphy': {
        'validator': 'IphySmugglerValidator',
        'handler': 'IphySmuggler',
    },
    'fsp': {
        'validator': 'FspSmugglerValidator',
        'handler': 'FspSmuggler'
    },
    'bbmod': {
        'validator': 'BbmodSmugglerValidator',
        'handler': 'BbmodSmuggler'
    },
    'svn': {
        'validator': 'SvnSmugglerValidator',
        'handler': 'SvnSmuggler'
    },
    'git': {
        'validator': 'GitSmugglerValidator',
        'handler': 'GitSmuggler'
    },
    'web': {
        'validator': 'WebSmugglerValidator',
        'handler': 'WebSmuggler'
    }
}

VALID_SOURCE_PREFIXES = {
    'local': '/',
    'fsm': 'fsm://',
    'iphy': 'iphy://',
    'fsp': 'fsp://',
    'bbmod': 'bbmod://',
    'git': 'git://',
    'svn': 'svn://',
    'web': 'web://',
    'scp': 'scp://'
}

VALID_DESTINATION_PREFIXES = {
    'local': '/',
    'fsm': 'fsm://',
    'iphy': 'iphy://',
    'fsp': 'fsp://',
    'bbmod': 'bbmod://',
    'scp': 'scp://'
}
