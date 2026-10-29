#!/usr/bin/env python

"""Script to run robot framework test cases in local environment."""

import socket
import random
import subprocess
import os
import sys
import argparse
import re
import warnings
import tempfile
import traceback
from abc import ABCMeta, abstractmethod
from shutil import rmtree, copytree
from os.path import expanduser
from xml.dom import minidom
from datetime import datetime


class CONFIGURATION:
    """Base Start Test tool configuration."""

    TESTLINE_CONFIGURATION_CLOUD_PATH = '/home/ute/testline_configuration'
    TESTLINE_CONFIGURATION_SG6_PATH = '/home/ute/Auto5G/robotws/testline_configuration'
    LOCAL_TC_LIST_PATH = 'test_lists'
    COMMON_QC_FILE_NAME = 'conf.qc'
    BTS_HOST_DEFAULT = '192.168.255.1'
    CONFIRM_LIST_OPTION_DEFAULT = False
    MERGE_OPTION_DEFAULT = False
    RUN_COMMISSIONING_OPTION_DEFAULT = False
    DRY_RUN_OPTION_DEFAULT = False
    SKIP_REPORT_OPTION_DEFAULT = False
    BTS_PORT_SSH_DEFAULT = 22
    BTS_USERNAME_SSH_DEFAULT = 'toor4nsn'
    BTS_PASSWORD_SSH_DEFAULT = 'oZPS0POrRieRtu'
    BTS_PORT_REST_DEFAULT = 443
    BTS_USERNAME_REST_DEFAULT = 'Nemuadmin'
    BTS_PASSWORD_REST_DEFAULT = 'nemuuser'
    BTS_CONNECTION_TIMEOUT = 25
    USE_SSH_OPTION_DEFAULT = False
    LABEL_OPTION_DEFAULT = 'regression'
    LOGLEVEL_OPTION_DEFAULT = 'TRACE'
    LOCALLOG_OPTION_DEFAULT = False
    OUTPUTDIR_OPTION_DEFAULT = '/home/ute/LOGS/CRT_MANUAL_RUNS/'
    MANUAL_RUNS = '/mnt/syve/WMP/manual_runs'
    SYVE_STORAGE_LOGS_OFFSET = 15
    SYVE_STORAGE_IP = 'https://10.83.176.100'


INTRO = r"""
  _   _                 _            _                              _   _
 | \ | | _____      __ | |_ ___  ___| |_    _____  _____  ___ _   _| |_(_) ___  _ __
 |  \| |/ _ \ \ /\ / / | __/ _ \/ __| __|  / _ \ \/ / _ \/ __| | | | __| |/ _ \| '_ \
 | |\  |  __/\ V  V /  | ||  __/\__ \ |_  |  __/>  <  __/ (__| |_| | |_| | (_) | | | |
 |_| \_|\___| \_/\_/    \__\___||___/\__|  \___/_/\_\___|\___|\__,_|\__|_|\___/|_| |_|
"""


WHO_USE_IT = r"""
                   _ ,___,-'",-=-.
       __,   _ _,-'_)_  (""`'-._\ `.
    _,' .   |,' ,-' __)  ,-     /. |
  ,'_,-'    |     -'  _)/         `\
,','      ,'       ,-'_,`           :
,'     ,-'       ,(,-(              :
     ,'       ,-' ,    _            ;
    /        ,-._/`---'            /
   /        (____)(----. )       ,'
  /         (      `.__,     /\ /,
 :           ;-.___         /__\/|
 |         ,'      `--.      -,\ |
 :        /            \    .__/
  \      (__            \    |_
   \       ,`-, *       /   _|,\
    \    ,'   `-.     ,'_,-'    \
   (_\,-'    ,'\")--,'-'       __\
    \       /  // ,'|      ,--'  `-.
     `-.    `-/ \'  |   _,'         `.
        `-._ /      `--'/             \
           ,'           |              \
          /             |               \
       ,-'              |               /
      /                 |             -'
"""


class logger:
    """Colored console logger."""

    class COLORS:
        """Available colors."""
        RED = '\x1b[31m'
        GREEN = '\x1b[32m'
        YELLOW = '\x1b[33m'
        BLUE = '\x1b[34m'
        MAGENTA = '\x1b[35m'
        CYAN = '\x1b[36m'
        WHITE = '\x1b[37m'
        NC = '\x1b[39m'

    @classmethod
    def error(cls, message):
        """Logs error message."""

        cls.log(message, cls.COLORS.RED)

    @classmethod
    def info(cls, message):
        """Logs info message."""

        cls.log(message, cls.COLORS.WHITE)

    @classmethod
    def warning(cls, message):
        """Logs warning message."""

        cls.log(message, cls.COLORS.YELLOW)

    @classmethod
    def success(cls, message):
        """Logs success message."""

        cls.log(message, cls.COLORS.GREEN)

    @classmethod
    def log(cls, message, color):
        """Logs message with given error."""

        print('{}{}{}'.format(color, message, cls.COLORS.NC))

    @classmethod
    def header(cls, message, color):
        """Logs given message with additional separator to cut above console data."""

        _, columns = os.popen('stty size', 'r').read().split()
        sep_size = int(columns)
        prefix = '\n[ {} ]'.format(message)
        prefix_size = len(prefix)
        sep = '=' * (sep_size - prefix_size) if sep_size > prefix_size else ''
        print('{}{}{}{}\n'.format(color, prefix, sep, cls.COLORS.NC))

    @classmethod
    def important_note(cls, title, message, title_left_alignment=0, message_left_alignment=0,
                       title_color=COLORS.WHITE, message_color=COLORS.CYAN):
        """Logs title and message in given colors in one line."""

        msg = '{}{:<{title_left_alignment}}{}{:<{message_left_alignment}}{}'.format(
            title_color, str(title), message_color, str(message), cls.COLORS.NC,
            title_left_alignment=title_left_alignment, message_left_alignment=message_left_alignment
        )
        print(msg)

    @classmethod
    def new_line(cls):
        """Logs one empty line."""

        print()


class State(metaclass=ABCMeta):
    """Base class for each state."""

    def __init__(self):
        self.context = Context()

    @property
    @abstractmethod
    def name(self):
        """Name of state."""

    @abstractmethod
    def run(self, machine):
        """Main state code."""

    @abstractmethod
    def update(self, machine):
        """Code executed in transition to next state."""


class StateMachine(object):
    """State machine to split sequential code in separated states (classes)."""

    def __init__(self):
        self.state = None
        self.states = {}
        self.context = {}
        self.RUNNING = False

    def add_state(self, state):
        """Add new state to machine."""

        self.states[state.name] = state

    def go_to_state(self, state_name):
        """Jumps to given state and sets it as current state."""

        self.state = self.states[state_name]
        self.state.run(self)

    def update_state(self):
        """Updates states by execute `update` method in current state."""

        if self.state:
            self.state.update(self)

    def start(self):
        """Sets flag indicating that machine is running."""

        self.RUNNING = True

    def stop(self):
        """Clears flag indicating that machine is running."""

        self.RUNNING = False

    def is_running(self):
        """Checks if flag indicating that machine is running is set."""

        return self.RUNNING


class Context:
    """Start Test container for data. It is singleton."""

    _instance = None

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls, *args, **kwargs)
        return cls._instance

    def __init__(self):
        self.test_list = []
        self.executed_tests = []
        self.execution_target = []
        self.merge_targets = None
        self.label = None
        self.report_test_line = None
        self.software = None
        self.detect_software_by_ssh = None
        self.release = None
        self.output_dir = None
        self.log_level = None
        self.local_logs = None
        self.dry_run = None
        self.bts_host = None
        self.bts_port = None
        self.username = None
        self.password = None
        self.variables = None
        self.variable_files = None
        self.testline_configuration_path = None
        self.robotws_path = None
        self.skip_commissioning = None
        self.skip_report = None
        self.test_line_hostname = None


class Test:
    """Test to execute."""

    def __init__(self, name, path):
        self.path = path
        self.name = name
        self.result = None
        self.duration = None
        self.logs_path = None
        self.qc_file_path = self.set_defaults_qc_file(self.path)
        self.qc_report_url = '-'
        self.qc_report_command = '-'

    def __repr__(self):
        return self.name

    @property
    def path(self):
        """Returns path to file where test is located."""

        return self._path

    @property
    def name(self):
        """Returns name of test."""

        return self._name

    @path.setter
    def path(self, value):
        """Sets path with it validation."""

        if not os.path.exists(value):
            logger.error('Error: Robot test suite "{}" does not exist.'.format(value))
            logger.new_line()
            sys.exit(1)
        self._path = value

    @name.setter
    def name(self, value):
        """Sets name with it validation."""

        if value not in self.collect_tests_from_suite(self._path):
            logger.error('Error: Test name "{}" is not present in the test suite.'.format(value))
            logger.new_line()
            sys.exit(2)
        self._name = value

    @staticmethod
    def set_defaults_qc_file(robot_file_path):
        """Sets default path to QC file based on robot suite path."""

        qc_file_path = os.path.splitext(robot_file_path)[0] + '.qc'
        if not os.path.exists(qc_file_path):
            test_runner_directory = os.path.dirname(os.path.abspath(__file__))
            qc_file_path = os.path.join(test_runner_directory, CONFIGURATION.COMMON_QC_FILE_NAME)
        if not os.path.exists(qc_file_path):
            qc_file_path = None
        return qc_file_path

    @staticmethod
    def _load_robot_file(path):
        """Loads robot file and inspects test suite."""

        if hasattr(robot_api, 'TestData'):
            suite = robot_api.TestData(source=path)
            tests = [test.name for test in suite.testcase_table]
        else:

            class TestCasesFinder(robot_api.SuiteVisitor):
                def __init__(self):
                    self.tests = []

                def visit_test(self, test):
                    self.tests.append(test)

            builder = robot_api.TestSuiteBuilder()
            testsuite = builder.build(path)
            finder = TestCasesFinder()
            testsuite.visit(finder)
            tests = [test.name for test in finder.tests]

        return tests

    @classmethod
    def collect_tests_from_suite(cls, suite_path):
        """Finds all tests in given robot suite."""

        try:
            tests = cls._load_robot_file(suite_path)
        except robot_errors.DataError as error:
            logger.error('Error: File "{}" file could not be loaded as robot file: {}'.format(suite_path, str(error)))
            logger.new_line()
            sys.exit(3)
        return tests


class SSHManager:
    """Creates object to manage ssh connection."""

    def __init__(self, bts_host, bts_port, username, password, timeout=15):
        self.bts_host = bts_host
        self.bts_port = bts_port
        self.username = username
        self.password = password
        self.timeout = timeout
        self.error = None

        self._client = None

    def __enter__(self):
        try:
            self.connect()
        except paramiko.ssh_exception.NoValidConnectionsError as err:
            self.error = err
            self._client = None
        return self

    def __exit__(self, exc_type, exc_value, exc_tb):
        self.disconnect()

    def connect(self):
        """Opens ssh session."""

        try:
            self._client = paramiko.SSHClient()
            self._client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self._client.connect(hostname=self.bts_host, port=self.bts_port, username=self.username,
                                 password=self.password, timeout=self.timeout, allow_agent=False,
                                 look_for_keys=False)
        except (paramiko.AuthenticationException, paramiko.SSHException, socket.timeout, socket.gaierror) as err:
            self.error = err
            self._client = None

    def is_connected(self):
        """Checks if manager is connected."""

        return bool(self._client)

    def disconnect(self):
        """Closes ssh session."""

        if self._client is not None:
            self._client.close()
            self._client = None

    def execute_command(self, command):
        """Executes single command via opened ssh session."""

        _, stdout, stderr = self._client.exec_command(command)
        stdout = stdout.read()
        stderr = stderr.read()
        stdout = stdout if isinstance(stdout, six.string_types) else stdout.decode()
        stderr = stderr if isinstance(stderr, six.string_types) else stderr.decode()
        if stdout:
            return True, stdout
        return False, stderr


class FindingRepositoriesState(State):
    """Creates state to find repositories."""

    name = 'FindingRepositoriesState'

    def run(self, machine):
        """
        Searches 'robotws' and 'testline_configuration' in local system.
        It checks 'UTE cloud' and 'Auto5G' repository locations.
        """

        logger.header('FINDING REPOSITORIES', logger.COLORS.MAGENTA)

        self.context.robotws_path = self._get_robotws_repository_path()
        self.context.testline_configuration_path = self._get_testline_configuration_repository_path(
            'UTE' in self.context.robotws_path
        )

        logger.info('robotws repository path: {}'.format(self.context.robotws_path))
        logger.info('testline_configuration repository path: {}'.format(self.context.testline_configuration_path))

    def update(self, machine):
        """In next step all arguments passed in command will be parsed."""

        machine.go_to_state(ArgumentParsingState.name)

    @staticmethod
    def _get_testline_configuration_repository_path(is_cloud):
        """Returns path depending on the provided parameter (UTE cloud or Auto5g)."""

        if is_cloud:
            return os.path.abspath(CONFIGURATION.TESTLINE_CONFIGURATION_CLOUD_PATH)
        return os.path.abspath(CONFIGURATION.TESTLINE_CONFIGURATION_SG6_PATH)

    @staticmethod
    def _get_robotws_repository_path():
        """Returns path to 'robotws' depending on localisation current script."""

        test_runner_directory = os.path.dirname(os.path.abspath(__file__))
        resources_directory = os.path.dirname(test_runner_directory)
        krakow_directory = os.path.dirname(resources_directory)
        testsuite_directory = os.path.dirname(krakow_directory)
        robotws_directory = os.path.dirname(testsuite_directory)
        return robotws_directory


class CheckingEnvironmentState(State):
    """Creates state to checking venv activation status."""

    name = 'CheckingEnvironmentState'

    def run(self, machine):
        """Checks if current script is executed in virtual environment and imports required modules if it is."""

        logger.header('CHECKING ENVIRONMENT', logger.COLORS.MAGENTA)

        if not self._is_virtual_environment_active():
            logger.error('Error: Virtual environment is not active.')
            logger.new_line()
            logger.info('Please activate it before running (try "source bootstrap -l" command).')
            logger.info('The following packages are required: tomli, robot, six, paramiko, taf.gnb.oam.coam.admin, '
                        'taf.internal.sbts.admin, taf.rfrl.bts.helpers.')
            logger.new_line()
            sys.exit(4)

        logger.info("Detected virtual environment: {}".format(sys.prefix))
        self._import_required_modules()

    def update(self, machine):
        """In next step repositories paths will be collected."""

        machine.go_to_state(FindingRepositoriesState.name)

    @staticmethod
    def _is_virtual_environment_active():
        """Checks if virtual environment is activated."""

        prefix = getattr(sys, "base_prefix", None) or getattr(sys, "real_prefix", None) or sys.prefix
        return sys.prefix != prefix

    def _import_required_modules(self):
        """Imports modules required by Start Test."""

        self._disable_paramiko_warnings()
        global paramiko
        global six
        global robot_api
        global robot_errors
        global tomli
        global admin_api
        global admin_exceptions
        global sw_versions
        paramiko = self.import_module('paramiko')
        six = self.import_module('six')
        robot_api = self.import_from('robot', 'api')
        robot_errors = self.import_from('robot', 'errors')
        tomli = self.import_module('tomli')
        admin_api = self.import_from('taf.sbts.oam.coam.admin.interface', 'admin')
        admin_exceptions = self.import_from('taf.internal.sbts.admin', 'exceptions')
        sw_versions = self.import_from('taf.rfrl.bts.helpers', 'sw_versions')

    @staticmethod
    def _disable_paramiko_warnings():
        """Disables warnings."""

        warnings.filterwarnings(action='ignore', module='.*paramiko.*')
        warnings.filterwarnings(action='ignore', module='.*requests.*')

    @staticmethod
    def import_from(module, name):
        """Equivalent of 'from <package> import <sth>'."""

        module = __import__(module, fromlist=[name])
        return getattr(module, name)

    @staticmethod
    def import_module(module):
        """Equivalent of 'import <sth>'."""

        return __import__(module)


class ArgumentParsingState(State):
    """Creates state to parse all options and arguments provided by user."""

    name = 'ArgumentParsingState'

    def __init__(self, args):
        super().__init__()
        self.args = args

    def run(self, machine):
        """Sets arguments passed by user in common context."""

        logger.header('COLLECTING TEST CASES', logger.COLORS.MAGENTA)

        self.context.test_list = self._get_test_list(self.args)
        self.context.output_dir = self._validate_output_dir(self.args.outputdir)
        self.context.software = self.args.software
        self.context.dry_run = self.args.dryrun
        self.context.log_level = self.args.loglevel
        self.context.local_logs = self.args.locallogs
        self.context.label = self.args.label
        self.context.detect_software_by_ssh = self.args.usessh
        self.context.merge_targets = self.args.merge
        self.context.skip_report = self.args.skipreport
        self.context.test_line_hostname = self._find_test_line_hostname()
        self.context.report_test_line = self._get_report_test_line(self.args.reporttestline)
        self.context.variables = self._add_variables(self.args.variable, self.args.runcommissioning,
                                                     self.context.report_test_line)
        self.context.variable_files = self._add_tl_variable_directory_path(
            self.args.variablefile, self.context.testline_configuration_path
        )
        self.context.bts_host = self.args.btshost
        if self.args.usessh:
            if self.args.btsport is None:
                self.context.bts_port = CONFIGURATION.BTS_PORT_SSH_DEFAULT
            else:
                self.context.bts_port = self.args.btsport
            if self.args.username is None:
                self.context.username = CONFIGURATION.BTS_USERNAME_SSH_DEFAULT
            else:
                self.context.username = self.args.username
            if self.args.password is None:
                self.context.password = CONFIGURATION.BTS_PASSWORD_SSH_DEFAULT
            else:
                self.context.password = self.args.password
        else:
            if self.args.btsport is None:
                self.context.bts_port = CONFIGURATION.BTS_PORT_REST_DEFAULT
            else:
                self.context.bts_port = self.args.btsport
            if self.args.username is None:
                self.context.username = CONFIGURATION.BTS_USERNAME_REST_DEFAULT
            else:
                self.context.username = self.args.username
            if self.args.password is None:
                self.context.password = CONFIGURATION.BTS_PASSWORD_REST_DEFAULT
            else:
                self.context.password = self.args.password
        self._validate_qc_file(self.args.qcfile, self.context.test_list)

    def update(self, machine):
        """In next step current software will be checked on BTS."""

        machine.go_to_state(GettingCurrentSoftwareState.name)

    def _get_test_list(self, args):
        """
        Returns list of tests based on user passed arguments like path to TOML list, path to robot suite
        or based on searching TOML list.
        """

        if args.testlist is None:

            if args.robotsuite is None:
                test_list_path = self._find_test_list_file()
                if args.confirmlist:
                    self._confirm_test_list(test_list_path)
                else:
                    logger.info('You confirmed following test list: {}.'.format(test_list_path))
                    logger.new_line()
                test_list = self._load_toml_test_list(test_list_path)

            else:
                test_list = self._load_robot_test_list(args.robotsuite)

        else:

            if args.robotsuite is not None:
                logger.warning('Warning: Only test defined in toml file will be executed.')
                logger.new_line()
                logger.info('Toml file has higher priority over robot file.')
                logger.new_line()
            test_list = self._load_toml_test_list(args.testlist)

        if args.testname:
            test_list = self._choose_tests(args.testname, test_list)

        logger.log('Chosen test cases:', logger.COLORS.CYAN)
        for test in test_list:
            logger.important_note(' * Test:', test.name, 14, message_color=logger.COLORS.CYAN)
            logger.important_note('   Location:', test.path, 14, message_color=logger.COLORS.CYAN)
        logger.new_line()

        return test_list

    def _find_test_list_file(self):
        """Searches TOML test list."""

        test_runner_directory = os.path.dirname(os.path.abspath(__file__))
        test_list_directory = os.path.join(test_runner_directory, CONFIGURATION.LOCAL_TC_LIST_PATH)

        if not os.path.exists(test_list_directory):
            logger.error('Error: Not found "test_lists" directory.')
            logger.new_line()
            logger.info('Please create "test_lists" directory in directory where Start Test is located.')
            logger.info('Add <hostname of my test line>.toml in it with list of tests to execute.')
            logger.new_line()
            sys.exit(5)

        test_lists = os.listdir(test_list_directory)
        test_line_hostname = self._find_test_line_hostname()
        expected_test_list = test_line_hostname + '.toml'
        test_list = next(iter([tl for tl in test_lists if expected_test_list in str(tl)]), None)

        if test_list is None:
            logger.error('Error: Start Test did not find any test list. Expected file: {}.'.format(expected_test_list))
            logger.new_line()
            logger.info('Did you create file with your test cases in toml format?')
            logger.new_line()
            logger.info('If the file is still not found, use one of the solutions:')
            logger.info('- pass path to tests list:'
                        '    start_test.py -tl <path to toml file with test cases>')
            logger.info('- pass robot suite path:'
                        '    start_test.py -rs <path to robot file>')
            logger.info('- pass robot suite path and chosen test case name: '
                        '    start_test.py -tn <test name from given robot file> -rs <path to robot file>')
            logger.new_line()
            sys.exit(6)

        return os.path.join(test_list_directory, test_list)

    @staticmethod
    def _confirm_test_list(test_list_path, answer_limit=3):
        """Asking for confirmation of test list."""

        answers = {'refusal': ['n', 'no'], 'confirmation': ['y', 'yes']}

        logger.info('Start Test found following test list: {}'.format(test_list_path))
        logger.new_line()

        while True:

            user_answer = input('Is it correct? [y/n]: ')
            answer = user_answer.lower().strip()

            logger.new_line()

            if answer in answers['confirmation']:
                return True

            elif answer in answers['refusal']:
                logger.warning('Warning: Invalid test list was rejected by You.')
                logger.new_line()
                logger.info('You can pass path to Your file by options too too:')
                logger.info('- pass path to tests list:'
                            '    start_test.py -tl <path to toml file with test cases>')
                logger.info('- pass robot suite path:'
                            '    start_test.py -rs <path to robot file>')
                logger.info('- pass robot suite path and chosen test case name: '
                            '    start_test.py -tn <test name from given robot file> -rs <path to robot file>')
                logger.new_line()
                sys.exit(7)

            else:
                msg = 'Warning: Please respond with {} to confirm, or {} to reject.'.format(answers['confirmation'][0],
                                                                                            answers['refusal'][0])
                logger.warning(msg)
                logger.new_line()

            answer_limit -= 1

            if answer_limit == 0:
                logger.info(WHO_USE_IT)
                logger.new_line()
                logger.error('Error: You entered invalid answer 3 times.')
                logger.new_line()
                logger.info('Please check help of Start Test tool.')
                logger.new_line()
                sys.exit(8)

    @staticmethod
    def _find_test_line_hostname():
        """Returns test line hostname."""

        return socket.gethostname().upper().rstrip('-INTEGRATION')

    def _load_toml_test_list(self, file_path):
        """Loads TOML file."""

        try:
            with open(file_path, mode="rb") as fh:
                test_list = tomli.load(fh)
        except tomli.TOMLDecodeError:
            logger.error("Error: Invalid tests definitions {}.".format(file_path))
            logger.new_line()
            logger.info('Please check following requirements:')
            logger.info(' * your test list TOML file should contain "[test_cases]" header')
            logger.info(' * test names should be unique')
            logger.info(' * each test should has assigned path to file')
            logger.new_line()
            sys.exit(9)
        except OSError:
            logger.error("Error: File {} could not be loaded.".format(file_path))
            logger.new_line()
            logger.info('Please check existence of file and file access rights.')
            logger.new_line()
            sys.exit(10)
        else:
            return self._validate_toml_test_list(test_list, file_path)

    @staticmethod
    def _validate_toml_test_list(test_list, file_path):
        """Validates content of TOML file."""

        if 'test_cases' not in test_list or not isinstance(test_list['test_cases'], dict):
            logger.error('Error: Wrong format of file {}.'.format(file_path))
            logger.new_line()
            logger.info('Please keep following file format:')
            logger.info('[test_cases]')
            logger.info('"Test A" = "/path/to/suite_A.robot"')
            logger.info('"Test B" = "/path/to/suite_B.robot"')
            logger.new_line()
            sys.exit(11)

        if len(test_list['test_cases']) == 0:
            logger.error('Error: List of tests is empty.')
            logger.new_line()
            logger.info('Please add Your tests in toml file:')
            logger.info('[test_cases]')
            logger.info('"Test A" = "/path/to/suite_A.robot"')
            logger.new_line()
            sys.exit(12)

        desired_test_list = [Test(name, path) for name, path in test_list['test_cases'].items()]

        return desired_test_list

    @staticmethod
    def _load_robot_test_list(file_path):
        """Loads robot file."""

        test_names = Test.collect_tests_from_suite(file_path)
        desired_test_list = [Test(name, file_path) for name in test_names]

        return desired_test_list

    def _choose_tests(self, expected_tests, test_list):
        """Filters list of test based on user arguments."""

        desired_test_list = []

        for name in expected_tests:
            test = self._find_test_by_name_in_test_list(name, test_list)

            if test is None:
                logger.warning('Warning: Not found test "{}" in loaded tests.'.format(name))
                logger.new_line()
                continue

            desired_test_list.append(test)

        if len(desired_test_list) == 0:
            logger.error('Error: No tests to execute.')
            logger.new_line()
            sys.exit(13)

        return desired_test_list

    @staticmethod
    def _find_test_by_name_in_test_list(name, test_list):
        """Returns test by name from list of test."""

        return next(iter(test for test in test_list if test.name == name), None)

    @staticmethod
    def _validate_output_dir(dir_path):
        """Checks if passed by user output directory exists."""

        if not os.path.exists(dir_path):
            try:
                os.makedirs(dir_path)
                logger.info('Directory {} was created.'.format(dir_path))
            except OSError as err:
                logger.error('Error: Output directory cannot be created: {}'.format(err))
                logger.new_line()
                sys.exit(14)
        else:
            try:
                rmtree(dir_path)
                logger.info('Content of {} directory deleted.'.format(dir_path))
            except OSError as err:
                logger.error('Error: Content of {} directory cannot be deleted: {}'.format(dir_path, err))
                logger.new_line()
                sys.exit(14)
        return dir_path

    def _add_tl_variable_directory_path(self, variable_files, testline_configuration_path):
        """Adds path to directory with __init__.py file to robot variables"""

        tl_variable_directory_path = next(
            filter(lambda vf: testline_configuration_path in vf, variable_files), None
        )

        if tl_variable_directory_path is None:
            tl_variable_directory_path = os.path.join(testline_configuration_path,
                                                      self._get_tl_variable_directory_name())

            if not os.path.exists(tl_variable_directory_path):
                logger.error('Error: Not found "tl" variable directory: {}.'.format(tl_variable_directory_path))
                logger.new_line()
                logger.info('Please set path to "tl" variable by option -vf: '
                            '-fv {}/<directory name>'.format(testline_configuration_path))
                logger.new_line()

            variable_files.append(tl_variable_directory_path)

        logger.info('Using "tl" variable file: {}'.format(tl_variable_directory_path))

        return variable_files

    def _get_tl_variable_directory_name(self):
        """Creates name of directory with __init__.py file."""

        test_line_hostname = self._find_test_line_hostname()
        return '_'.join(test_line_hostname.split('-')[:3])

    @staticmethod
    def _add_variables(variables, run_commissioning, test_line_hostname):
        """Adds extra variables (run_commissioning) to robot variables."""

        variables.append('{}:{}'.format('skip_commissioning', str(not run_commissioning).lower()))
        variables.append('{}:Krakow.{}'.format('CONFIGURATION', test_line_hostname))
        return variables

    @staticmethod
    def _validate_qc_file(user_qc_file, test_list):
        """Checks if each test case has valid QC file."""
        if user_qc_file is not None:

            if not os.path.exists(user_qc_file):
                logger.error('Error: QC file does not exist: {}'.format(user_qc_file))
                logger.new_line()
                sys.exit(20)
            logger.warning('Warning: All test cases will be reported according with file: {}'.format(user_qc_file))
            logger.new_line()

            for test in test_list:
                test.qc_file_path = user_qc_file

        else:

            for test in test_list:
                if test.qc_file_path is None:
                    logger.error('Error: Common QC file was not found.')
                    logger.new_line()
                    logger.info('Please crete QC file with name same as executed suite name or use -qc option.')
                    logger.new_line()
                    sys.exit(20)

    def _get_report_test_line(self, report_test_line):
        """Returns test line label for Quality Center reporting command (option -tl)."""

        return self._get_tl_variable_directory_name() if report_test_line is None else report_test_line


class GettingCurrentSoftwareState(State):
    """Creates state to download current software version uploaded on gNB."""

    name = 'GettingCurrentSoftwareState'

    def __init__(self):
        super().__init__()
        self._channel = None

    def run(self, machine):
        """Gets versions of software uploaded on gNB."""

        logger.header('GETTING CURRENT SOFTWARE VERSION', logger.COLORS.MAGENTA)

        if self.context.software is None:
            logger.info('Checking software on bts ({})...'.format(self.context.bts_host))
            self.context.software = self._detect_bts_sw_version(
                self.context.detect_software_by_ssh, self.context.bts_host, self.context.bts_port,
                self.context.username, self.context.password
            )
            logger.info('Detected software: {}'.format(self.context.software))
            logger.new_line()

        try:
            self.context.software = self._unify_bts_sw_version(self.context.software)
        except IndexError:
            msg = 'Warning: Unsupported software version. Sending report to Reporting Portal service can failed.'
            logger.warning(msg)
            logger.new_line()

        logger.important_note('Unified software: ', self.context.software, message_color=logger.COLORS.CYAN)
        logger.new_line()

        self.context.variables.append('{}:{}'.format('ENB_BUILD', self.context.software))

    def update(self, machine):
        """In next step Start Test will chose test cases to execute."""

        machine.go_to_state(DispatchingTestsState.name)

    def _detect_bts_sw_version(self, use_ssh, bts_host, bts_port, username, password):
        """Returns gNB software version depends on connection type."""

        if use_ssh:
            return self._detect_bts_sw_version_by_ssh(bts_host, bts_port, username, password)
        return self._detect_bts_sw_version_by_rest_api(bts_host, bts_port, username, password)

    @staticmethod
    def _detect_bts_sw_version_by_ssh(bts_host, bts_port, username, password):
        """Detects gNB software version by ssh."""

        with SSHManager(bts_host, bts_port, username, password,
                        timeout=CONFIGURATION.BTS_CONNECTION_TIMEOUT) as ssh_manager:
            if not ssh_manager.is_connected():
                logger.new_line()
                logger.error('Error: Can not check SSH software via SSH: {}'.format(str(ssh_manager.error)))
                logger.new_line()
                sys.exit(15)
            status, output = ssh_manager.execute_command('ls -1 /rom/')
            if not status:
                logger.new_line()
                logger.error('Error: Can not check SSH software via SSH: {}'.format(output))
                logger.new_line()
                sys.exit(16)
            match = re.search(r'TargetBD_(\w+)\.xml', output)
            sw_version = match.group(1)
            return sw_version

    @staticmethod
    def _detect_bts_sw_version_by_rest_api(bts_host, bts_port, username, password):
        """Detects gNB software version by REST API."""

        admin = admin_api()
        connection = None
        try:
            connection = admin.connect_to(bts_host, bts_port, username, password,
                                          timeout=CONFIGURATION.BTS_CONNECTION_TIMEOUT)
            sw_version = connection.get_sw_version()
        except (admin_exceptions.AdminApiConnectionClosedException, admin_exceptions.AdminApiProcedureFailureException,
                admin_exceptions.AdminApiNoResponseException, admin_exceptions.AdminApiTerminatedException) as error:
            logger.new_line()
            logger.error('Error: Connection to BTS is not possible via REST API: {}'.format(str(error)))
            logger.new_line()
            sys.exit(17)
        finally:
            if connection is not None:
                admin.teardown()

        return sw_version

    @staticmethod
    def _unify_bts_sw_version(software):
        """Unifies software string (for trunk)."""

        software_chunks = software.split('_')
        if software_chunks[2] == '9999':
            return software.replace(software_chunks[0], 'SBTS00')
        return software


class DispatchingTestsState(State):
    """Creates state to indicate next test candidate to execute"""

    name = 'DispatchingTestsState'

    def run(self, machine):
        """Creates list with execution targets."""

        if self.context.execution_target:
            self.context.executed_tests.extend(self.context.execution_target)
            self.context.execution_target = []

        try:
            execution_target = [self.context.test_list.pop(0)]
        except IndexError:
            execution_target = []
            rest_of_tests = self.context.test_list
        else:
            rest_of_tests = []
            for test in self.context.test_list:
                if test.path == execution_target[0].path and self.context.merge_targets:
                    execution_target.append(test)
                else:
                    rest_of_tests.append(test)

        self.context.execution_target = execution_target
        self.context.test_list = rest_of_tests

    def update(self, machine):
        """In next step Start Test will run test or show final report if there is no tests to execute."""

        if len(self.context.execution_target) > 0:
            machine.go_to_state(TestRunState.name)
        else:
            machine.go_to_state(PreparingFinalReportState.name)


class PreparingFinalReportState(State):
    """Creates state to prepare test execution summary"""

    name = 'PreparingFinalReportState'

    def run(self, machine):
        """Shows summary of tests execution."""

        logger.header('FINAL REPORT', logger.COLORS.MAGENTA)

        logger.info('Execution summary:')
        logger.new_line()

        number_of_passed_tests = 0
        number_of_tests = len(self.context.executed_tests)

        for test in self.context.executed_tests:
            logger.important_note(' * Test:', test.name, 20)
            logger.important_note('   Location:', test.path, 20)
            result_color = logger.COLORS.GREEN if test.result == 'PASS' else logger.COLORS.RED
            test_result = test.result + ' [DRYRUN]' if self.context.dry_run else test.result
            logger.important_note('   Result:', test_result, 20, message_color=result_color)
            duration = str(round(test.duration, 3)) + ' min'
            logger.important_note('   Duration:', duration, 20, message_color=logger.COLORS.WHITE)
            logger.important_note('   Logs:', test.logs_path, 20, message_color=logger.COLORS.WHITE)
            if test.result == 'PASS':
                qc_report_url = test.qc_report_url
                test_report_command = test.qc_report_command
                if 'PASS_FAIL_' in test.logs_path and not self.context.skip_report:
                    test_report_command += '  # !!! Some test cases failed in test suite execution !!!'
                number_of_passed_tests += 1
            else:
                qc_report_url = '-'
                test_report_command = '-'
            logger.important_note('   Report URL:', qc_report_url, 20)
            logger.important_note('   Report command:', test_report_command, 20, message_color=logger.COLORS.WHITE)
            logger.new_line()

        logger.new_line()
        number_of_failed_tests = number_of_tests - number_of_passed_tests
        logger.important_note('Number of PASSED tests: ', number_of_passed_tests, message_color=logger.COLORS.GREEN)
        logger.important_note('Number of FAILED tests: ', number_of_failed_tests, message_color=logger.COLORS.RED)
        logger.important_note('Number of all tests:    ', number_of_tests, message_color=logger.COLORS.WHITE)
        logger.new_line()

        if random.randint(0, 500) == 111 and number_of_tests == number_of_failed_tests:
            logger.info(WHO_USE_IT)
            logger.new_line()

    def update(self, machine):
        """Stops state machine."""

        machine.stop()


class TestRunState(State):
    """Creates state to run single test"""

    name = 'TestRunState'

    def run(self, machine):
        """Runs robot test case (single test or tests in one suite)."""

        logger.header('RUNNING TEST CASES', logger.COLORS.MAGENTA)

        number_of_targets = len(self.context.execution_target)
        if number_of_targets > 0 and self.context.merge_targets:
            logger.warning('Running {} test cases in ONE execution.'.format(number_of_targets))
            logger.new_line()
        for test in self.context.execution_target:
            logger.info('Test name:  {}'.format(test.name))
        logger.info('Test suite: {}'.format(self.context.execution_target[0].path))
        logger.new_line()

        command = self._build_command_robot(self.context)

        logger.important_note('Robot command:', command, 15)
        logger.new_line()

        subprocess.call(command, shell=True, cwd=self.context.robotws_path)

        self.context.execution_target = self._parse_test_output(self.context.output_dir, self.context.execution_target)

    def update(self, machine):
        """In next step logs will be saved on SYVe storage."""

        machine.go_to_state(TestLogsSendingToNewDirectoryState.name)

    def _build_command_robot(self, context):
        """Builds robot command which runs test cases."""

        command = ['robot']

        # command.extend(['--prerunmodifier taf.internal.robot.prerunmodifier.tc_id.AddIdForTCs'])

        if context.dry_run:
            command.extend(['--dryrun'])
        if context.output_dir is not None:
            command.extend(['--outputdir',  context.output_dir])
        if context.log_level is not None:
            command.extend(['--loglevel', context.log_level])

        for variable in context.variables:
            command.extend(['--variable', variable])
        for file in context.variable_files:
            command.extend(['--variablefile', file])
        for test in context.execution_target:
            command.extend(['--test', '"{}"'.format(self._build_regex_test_name(test.name))])

        command.extend([context.execution_target[0].path])

        return ' '.join(command)

    @staticmethod
    def _build_regex_test_name(test_name):
        for char in ['[', ']', '(', ')', '"', "'", '!', '#', '$', '@', '-', '?']:
            test_name = test_name.replace(char, '?')
        return test_name

    def _parse_test_output(self, output_dir, executed_tests):
        """Parses output of output.xml file generated by robot command."""

        output_xml_path = os.path.join(output_dir, "output.xml")
        if os.path.exists(output_xml_path):
            tree = minidom.parse(output_xml_path)
            tests_trees = tree.getElementsByTagName('test')
            for test_tree in tests_trees:
                status_trees = test_tree.getElementsByTagName('status')
                test = next(filter(lambda t: t.name == test_tree.getAttribute('name'), executed_tests), None)
                test.result = status_trees[-1].getAttribute('status')
                test.duration = self._calculate_duration(status_trees[-1].getAttribute('endtime'),
                                                         status_trees[-1].getAttribute('starttime'))
                test.logs_path = output_dir
        return executed_tests

    @staticmethod
    def _calculate_duration(end_time, start_time):
        """Calculate duration of test."""

        end_time_dt = datetime.strptime(end_time, '%Y%m%d %H:%M:%S.%f')
        start_time_dt = datetime.strptime(start_time, '%Y%m%d %H:%M:%S.%f')
        return (end_time_dt - start_time_dt).total_seconds() / 60


class TestLogsSendingToNewDirectoryState(State):
    """Creates state to save logs on SyVe storage"""

    name = 'TestLogsSendingToNewDirectoryState'

    def __init__(self):
        super().__init__()
        self.should_be_reported = False

    def run(self, machine):
        """Sends logs to SyVe storage."""

        logger.header('SAVING LOGS', logger.COLORS.MAGENTA)

        destination_directory = self._get_destination_directory_name(self.context.execution_target)
        self.should_be_reported = 'PASS' in destination_directory and \
                                  not self.context.dry_run and \
                                  not self.context.skip_report

        if self.context.local_logs:

            logger.warning('Warning: SyVe storage is not connected.')
            logger.new_line()
            logs_path = os.path.join(expanduser('~'), destination_directory)
            self._copy_logs_tree(logs_path)

        else:

            if self._syve_storage_is_connected():
                release = self._get_release(self.context.software)
                feature = self._get_feature(self.context.execution_target[0].path)
                if self.context.merge_targets:
                    executed_target = self._get_suite_name(self.context.execution_target[0].path)
                else:
                    executed_target = self._get_test_name(self.context.execution_target[0].name)
                executed_target = '{}_{}'.format(executed_target, self.context.test_line_hostname.replace('-', '_'))
                logs_path = os.path.join(CONFIGURATION.MANUAL_RUNS, release, feature, executed_target,
                                         destination_directory)
                self._copy_logs_tree(logs_path)
                self._delete_logs_on_syve_store(os.path.dirname(logs_path))
            else:
                logger.warning('Warning: SyVe storage is not connected.')
                logger.new_line()
                logs_path = os.path.join(expanduser('~'), destination_directory)
                self._copy_logs_tree(logs_path)

    def update(self, machine):
        """
        In next state Start Test will choose next test to execution if current failed
        or will report current test if it passed.
        """

        if self.should_be_reported:
            machine.go_to_state(TestReportingToQCState.name)
        else:
            machine.go_to_state(DispatchingTestsState.name)

    def _copy_logs_tree(self, destination):
        """Copies output logs to given directory."""

        logger.info('Logs will be saved in: {}'.format(destination))
        logger.new_line()

        copytree(self.context.execution_target[0].logs_path, destination)

        for test in self.context.execution_target:
            test.logs_path = destination

        logger.info('Logs saved successfully.')
        logger.new_line()

    @staticmethod
    def _get_release(software):
        """Gets release from software string."""

        try:
            release = sw_versions.SbtsSwVersion(software).release
        except ValueError:
            release = 'UNKNOWN'
        return release

    @staticmethod
    def _get_feature(testsuite_path):
        """Gets feature (directory name) from robot file path."""

        parent_path = os.path.abspath(os.path.join(testsuite_path, os.pardir))
        parent = os.path.basename(os.path.normpath(parent_path))
        return parent.replace('-', '_')

    @staticmethod
    def _get_suite_name(testsuite_path):
        """Gets robot fail name without extension."""

        file = os.path.basename(os.path.normpath(testsuite_path))
        return os.path.splitext(file)[0]

    @staticmethod
    def _get_test_name(test_name):
        """Get safe test name."""

        return "".join([c if c.isalpha() or c.isdigit() or c in '_-' else '_' for c in test_name]).rstrip()

    @staticmethod
    def _get_destination_directory_name(tests):
        """Creates destination directory for logs."""

        timestamp = datetime.now().strftime('%m_%d_%Y_%H_%M_%S')
        no_tests = len(tests)
        no_failed_tests = len(list(filter(lambda test: test.result == 'FAIL', tests)))
        np_passed_tests = len(list(filter(lambda test: test.result == 'PASS', tests)))
        if no_tests == no_failed_tests:
            return 'FAIL_' + timestamp
        if no_tests == np_passed_tests:
            return 'PASS_' + timestamp
        return 'PASS_FAIL_' + timestamp

    @staticmethod
    def _syve_storage_is_connected():
        """Checks if storage is connected."""

        return os.path.exists(CONFIGURATION.MANUAL_RUNS)

    def _delete_logs_on_syve_store(self, logs_path):
        """Deletes logs on SyVe storage if number of logs exceeds specified offset."""

        if CONFIGURATION.MANUAL_RUNS in logs_path:
            destination_directories = os.listdir(logs_path)
            if len(destination_directories) > CONFIGURATION.SYVE_STORAGE_LOGS_OFFSET:
                destination_directories.sort(key=self._deletion_filter, reverse=True)
                destination_directories = [os.path.join(logs_path, directory) for directory in destination_directories]
                directories_to_delete = destination_directories[CONFIGURATION.SYVE_STORAGE_LOGS_OFFSET:]
                for directory in directories_to_delete:
                    try:
                        rmtree(directory)
                    except FileNotFoundError:
                        logger.warning(f'Warning: Directory deletion failed: {directory}')

    @staticmethod
    def _deletion_filter(directory):
        """Returns datetime cut from log directory name."""

        return datetime.strptime('_'.join(directory.split('_')[-6:]), '%m_%d_%Y_%H_%M_%S')


class TestReportingToQCState(State):
    """Creates state to report single test to Quality Center"""

    name = 'TestReportingToQCState'

    def run(self, machine):
        """Sends report to Reporting Portal service."""

        logger.header('SENDING REPORT TO QUALITY CENTER SERVICE', logger.COLORS.MAGENTA)

        command = self._build_command_rp(self.context)

        logger.important_note('Report command:', command, 16)
        logger.new_line()

        with tempfile.NamedTemporaryFile() as fp:
            tee_command = '{} 2>&1 | tee {}'.format(command, fp.name)
            subprocess.call(tee_command, shell=True)
            report_url = self._get_report_url(fp.name)
            for test in self.context.execution_target:
                test.qc_report_url = report_url
                test.qc_report_command = command

    def update(self, machine):
        """In next step Start Test chose next test case(s) to execute."""

        machine.go_to_state(DispatchingTestsState.name)

    def _build_command_rp(self, context):
        """Creates reporting command."""

        command = ['ute_reporting_portal send']

        execution_logs = os.path.join(context.execution_target[0].logs_path, 'output.xml')

        command.extend(['-ro', execution_logs])
        command.extend(['-tl', context.report_test_line])
        command.extend(['-l', context.label])
        command.extend(['--sw_version', context.software])
        command.extend(['-qc', context.execution_target[0].qc_file_path])

        if CONFIGURATION.MANUAL_RUNS in context.execution_target[0].logs_path:
            logs_url = self._create_log_url(context.execution_target[0].logs_path)
            command.extend(['--log_link', logs_url])

        return ' '.join(command)

    @staticmethod
    def _create_log_url(logs_path):
        """Creates URL to SyVe logs."""

        return logs_path.replace('/mnt/syve', CONFIGURATION.SYVE_STORAGE_IP)

    @staticmethod
    def _get_report_url(report_log_path):
        """Returns report URL returned by reporting command."""

        with open(report_log_path) as fh:
            report_log = fh.read()
            urls = re.findall(r'(https?://[^\s]+)', report_log)
            return next(iter(urls), None)


def parse_arguments():
    """Parses command line arguments."""

    parser = argparse.ArgumentParser()

    parser.add_argument('-tl', '--testlist',
                        default=None,
                        help='Path to TOML file with test cases list.')
    parser.add_argument('-rs', '--robotsuite',
                        default=None,
                        help='Path to ROBOT file with test cases.')
    parser.add_argument('-tn', '--testname',
                        action='append',
                        help='Name of test case to run.')
    parser.add_argument('-m', '--merge',
                        default=CONFIGURATION.MERGE_OPTION_DEFAULT,
                        action='store_true',
                        help='Merge execution of test cases from one suite. '
                             'Suite setup and teardown will be called once.')
    parser.add_argument('-cl', '--confirmlist',
                        default=CONFIGURATION.CONFIRM_LIST_OPTION_DEFAULT,
                        action='store_true',
                        help='Require test list confirmation which start test found before running.')
    parser.add_argument('-rc', '--runcommissioning',
                        default=CONFIGURATION.RUN_COMMISSIONING_OPTION_DEFAULT,
                        action='store_true',
                        help='Run test cases commissioning by set ${skip_commissioning} variable on "false".')
    parser.add_argument('-sw', '--software',
                        default=None,
                        help='Bts software version for report sent to Reporting Portal service.')
    parser.add_argument('-l', '--label',
                        default=CONFIGURATION.LABEL_OPTION_DEFAULT,
                        help='Test line label for report sending to Reporting Portal service (-l).')
    parser.add_argument('-sr', '--skipreport',
                        default=CONFIGURATION.SKIP_REPORT_OPTION_DEFAULT,
                        action='store_true',
                        help='Skip sending report to Reporting Portal service.')
    parser.add_argument('-qc', '--qcfile',
                        default=None,
                        help='Path to QC file with reporting details.')
    parser.add_argument('-rt', '--reporttestline',
                        default=None,
                        help='Label which marks test line during sending to Reporting Portal service option (-tl).')
    parser.add_argument('-ll', '--locallogs',
                        default=CONFIGURATION.LOCALLOG_OPTION_DEFAULT,
                        action='store_true',
                        help='Logs will be stored only on local virtual machine.')
    parser.add_argument('-lo', '--loglevel',
                        default=CONFIGURATION.LOGLEVEL_OPTION_DEFAULT,
                        help='Robot logging level. Check robot -L option.')
    parser.add_argument('-dr', '--dryrun',
                        default=CONFIGURATION.DRY_RUN_OPTION_DEFAULT,
                        action='store_true',
                        help='Verifies test data and runs tests so that library keywords are not executed.')
    parser.add_argument('-d', '--outputdir',
                        default=CONFIGURATION.OUTPUTDIR_OPTION_DEFAULT,
                        help='Where to create output files. Check robot -d option.')
    parser.add_argument('-vf', '--variablefile',
                        action='append',
                        default=[],
                        help='Python or YAML file file to read variables from. Check robot -V option.')
    parser.add_argument('-v', '--variable',
                        action='append',
                        default=[],
                        help='Set variables in the test data. Check robot -v option. E.g: -v name:value')
    parser.add_argument('-us', '--usessh',
                        action='store_true',
                        default=None,
                        help='Start Test will use SSH to detect BTS software (REST API is default method).')
    parser.add_argument('-bh', '--btshost',
                        default=CONFIGURATION.BTS_HOST_DEFAULT,
                        help='BTS IP address for SSH or REST connection (-us/--usessh for ssh, default is REST).')
    parser.add_argument('-bp', '--btsport',
                        default=None,
                        help='BTS port for SSH or REST connection (-us/--usessh for ssh, default is REST).')
    parser.add_argument('-bu', '--username',
                        default=None,
                        help='Username for SSH or REST connection (-us/--usessh for ssh, default is REST).')
    parser.add_argument('-bs', '--password',
                        default=None,
                        help='Password for SSH or REST connection (-us/--usessh for ssh, default is REST).')

    return parser.parse_args()


def main():
    """Main function."""

    args = parse_arguments()

    logger.info(INTRO)

    sm = StateMachine()
    sm.add_state(CheckingEnvironmentState())
    sm.add_state(FindingRepositoriesState())
    sm.add_state(ArgumentParsingState(args))
    sm.add_state(GettingCurrentSoftwareState())
    sm.add_state(DispatchingTestsState())
    sm.add_state(TestRunState())
    sm.add_state(TestLogsSendingToNewDirectoryState())
    sm.add_state(TestReportingToQCState())
    sm.add_state(PreparingFinalReportState())

    sm.go_to_state(CheckingEnvironmentState.name)

    sm.start()

    while sm.is_running():
        sm.update_state()


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt as error:
        logger.new_line()
        logger.warning('Warning: You stopped execution.')
        logger.new_line()
        sys.exit(18)
    except Exception as error:
        logger.new_line()
        logger.error('Error: Check ./start_test_error.log for details.')
        logger.new_line()
        with open('start_test_error.log', 'w') as fh:
            fh.write(traceback.format_exc())
        sys.exit(19)
