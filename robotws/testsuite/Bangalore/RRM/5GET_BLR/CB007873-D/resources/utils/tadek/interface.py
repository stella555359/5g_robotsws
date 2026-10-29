# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_TADEK_DEVS_GMS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from robot.api import logger

from . import __version__
from .validators import validate_string

from .console import Console
from .console.validators import ConsoleValidator

from .smuggler import Smuggler
from .smuggler.validators import BaseSmugglerValidator, SmugglerValidator


class ta_tadek(object):
    """
    ta_tadek class
    """

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = __version__

    @staticmethod
    def execute_command_in_console(console, command, **kwargs):
        """Executes command in given console

        :param str console: name of console where the command will be executed.
        :param str command: console command to be executed
        :param kwargs: additional parameters
        :return: output of executed command
        :rtype: str

        **Acceptable consoles**:

            - local
            - fsm
            - iphy
            - bbmod-[1-3]
            - fsp(j)-[1-7][a-d]
            - fsp(j)-[1-3]
            - aashell
            - ssh
            - telnet

        :Additional parameters:
            - **address** (str) - address of remote host. Used only with consoles: ssh, telnet.
            - **port** (int) - port of remote host. Used only with consoles: ssh, telnet. Defaults: ssh: 22, telnet: 23
            - **prompt** (str) - telnet prompt. Used only with console: telnet
            - **authenticator** (dict) - dictionary with parameters used to connect to remote host:
                - 'key' - path to rsa key
                - 'user' - user on remote host
                - 'password' - password used to establish connection.

                If key and password are set, then key is used as authentication method.

        """
        validate_string(command)
        ConsoleValidator(console).validate(kwargs)
        console_handler = Console(console, **kwargs)
        logger.info('Executing command: `{}` in {} console'.format(command, console))
        return console_handler.execute_command(command).strip()

    @staticmethod
    def copy_file(source, destination, **kwargs):
        """Copies file from source to destination

        :param str source: path to the source file
        :param str destination: path to the copy destination
        :param kwargs: additional parameters
        :return: output of executed copy command
        :rtype: str

        :Additional parameters:
            - **token** (str) - git user private_token to be used in wget command
            - **authenticator** (str) - dictionary with credentials (user, vm etc.)
                - 'user' - user on remote host
                - 'password' - password used to establish connection

        **Acceptable directions of copy**:

        +--------+-------+----------------------------------------------------------+
        |        |       |                        DESTINATION                       |
        +--------+-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | TYPE  | local | git | svn | web | fsm | iphy | fsp | bbmod | scp |
        +--------+-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | local |   OK  |  -  |  -  |  -  |  OK |  OK  |  OK |   OK  |  OK |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | git   |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | svn   |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | web   |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        | SOURCE | fsm   |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | iphy  |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | fsp   |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | bbmod |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +        +-------+-------+-----+-----+-----+-----+------+-----+-------+-----+
        |        | scp   |   OK  |  -  |  -  |  -  |  -  |   -  |  -  |   -   |  -  |
        +--------+-------+-------+-----+-----+-----+-----+------+-----+-------+-----+

        **Acceptable source paths**:

        +-------+-----------------------+----------------------------------------------------------------------------+
        |                                                VALID SOURCE PATH                                           |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  TYPE |         PREFIX        |                                    EXAMPLE                                 |
        +-------+-----------------------+----------------------------------------------------------------------------+
        | local | /                     | /home/ute/Downloads/                                                       |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  git  | git://                | git://https://wrgitlab.int.net.nokia.com/user/project/raw/master/README.md |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  svn  | svn://                | svn://https://svne1.access.nsn.com/isource/svnroot/cpln_ca/scripts         |
        |       |                       | /pronto_prompt/qc.py                                                       |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  web  | web://                | web://http://files.ute.inside.nsn.com/builds/enb/base/                     |
        |       |                       | FL00_FSM3_9000_180491_000024/BTSSiteEM-FL00-0000_000452_000000_x64.bin     |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  fsm  | fsm://                | fsm://rom/config/SCFC_*                                                    |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  iphy | iphy://               | iphy://rom/simmode/iphy.xml                                                |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  fsp  | fsp://fsp-[1-3]       | fsp://fsp-1a/user/toor4nsn/.ssh/authorized_keys                            |
        +       +-----------------------+----------------------------------------------------------------------------+
        |       | fsp://fspj-[1-7][a-d] | fsp://fspj-1a/user/toor4nsn/.ssh/authorized_keys                           |
        +-------+-----------------------+----------------------------------------------------------------------------+
        | bbmod | bbmod://bbmod-[1-3]   | bbmod://bbmod-1/user/toor4nsn/.ssh/authorized_keys                         |
        +-------+-----------------------+----------------------------------------------------------------------------+
        |  scp  | scp://                | scp://ute@10.42.96.177:/home/ute/Downloads/file1                           |
        +-------+-----------------------+----------------------------------------------------------------------------+

        **Acceptable destination paths**:

        +-------+-----------------------+-----------------------------------------------------+
        |                              VALID DESTINATION PATH                                 |
        +-------+-----------------------+-----------------------------------------------------+
        |  TYPE |         PREFIX        |                      EXAMPLE                        |
        +-------+-----------------------+-----------------------------------------------------+
        | local | /                     | /home/ute/Downloads                                 |
        +-------+-----------------------+-----------------------------------------------------+
        |  fsm  | fsm://                | fsm://rom/config/SCFC_*                             |
        +-------+-----------------------+-----------------------------------------------------+
        |  iphy | iphy://               | iphy://rom/simmode/iphy.xml                         |
        +-------+-----------------------+-----------------------------------------------------+
        |  fsp  | fsp://fsp-[1-3]       | fsp://fsp-1a/user/toor4nsn/.ssh/authorized_keys     |
        +       +-----------------------+-----------------------------------------------------+
        |       | fsp://fspj-[1-7][a-d] | fsp://fspj-1a/user/toor4nsn/.ssh/authorized_keys    |
        +-------+-----------------------+-----------------------------------------------------+
        | bbmod | bbmod://bbmod-[1-3]   | bbmod://bbmod-1/user/toor4nsn/.ssh/authorized_keys  |
        +-------+-----------------------+-----------------------------------------------------+
        |  scp  | scp://                | scp://ute@10.42.96.177:/home/ute/Downloads/file1    |
        +-------+-----------------------+-----------------------------------------------------+

        """
        # name is misleading, BaseSmugglerValidator sets paths and their types
        bs = BaseSmugglerValidator()
        source_type, source_path = bs.validate_source_path(source)
        destination_type, destination_path = bs.validate_destination_path(destination)

        smuggler_type = destination_type if source_type == 'local' else source_type

        validator = SmugglerValidator(smuggler_type)
        validator.validate_destination_path(destination, source_type)
        validator.validate_kwargs(smuggler_type, kwargs)

        smuggler_handler = Smuggler(smuggler_type, **kwargs)
        return smuggler_handler.copy_file(source_path, destination_path)
