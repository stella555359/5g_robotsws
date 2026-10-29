# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com

This module contains dictionary with mapping of console key (console name , or console name till `-``)
to validator and handler classes for it.


Example structure;

CONSOLES = {
    'console name key': {
        'validator': 'Class that will validate passed console',
        'handler': 'Class that will handle given console'
    },
    ...
}
"""

FSM_CREDENTIALS = {'user': 'toor4nsn', 'password': 'oZPS0POrRieRtu'}

ENB_IP = '192.168.255.129'
ENB_CREDENTIALS = FSM_CREDENTIALS

IPHY_IP = '192.168.200.1'
IPHY_CREDENTIALS = FSM_CREDENTIALS

CONSOLES = {
    'local': {
        'validator': 'BaseConsoleValidator',
        'handler': 'LocalConsole'
    },
    'fsm': {
        'validator': 'BaseConsoleValidator',
        'handler': 'FsmConsole'
    },
    'iphy': {
        'validator': 'BaseConsoleValidator',
        'handler': 'IphyConsole'
    },
    'bbmod': {
        'validator': 'BbmodConsoleValidator',
        'handler': 'BbmodConsole'
    },
    'fsp': {
        'validator': 'FspConsoleValidator',
        'handler': 'FspConsole',
    },
    'fspj': {
        'validator': 'FspConsoleValidator',
        'handler': 'FspConsole',
    },
    'aashell': {
        'validator': 'BaseConsoleValidator',
        'handler': 'AaShellConsole'
    },
    'ssh': {
        'validator': 'SshConsoleValidator',
        'handler': 'SshConsole'
    },
    'telnet': {
        'validator': 'TelnetConsoleValidator',
        'handler': 'TelnetConsole'
    }
}
