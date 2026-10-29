import time
from datetime import datetime
import random
from robot.api import logger
try:
    from inspect import getfullargspec as argspec
except ImportError:
    logger.warn("Script incompatible with PY2! [WA] Importing getargspec")
    from inspect import getargspec as argspec


from taf.transport.ssh import ssh

from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id

CBC_HOST = '10.9.202.153'
CBC_USER = 'cbctest'
CBC_PASS = 'cbctest'


class CbcConnection:
    def __init__(self, hostname, user, password):
        self.ssh = ssh()
        self.hostname = hostname
        self.user = user
        self.password = password
        self.alias = 'CBC'

    def __enter__(self):
        self.ssh.connect_to(self.hostname, self.user, self.password, alias=self.alias)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.ssh.disconnect(self.alias)

    def execute_script_on_cbc(self, filepath, params):
        args = self.__prepare_command_args(params)
        logger.info("Executing script {} with arguments: {}".format(filepath, args))
        output = self.ssh.execute('WRO_RRM/testcase {} {}'.format(filepath, args), connection=self.alias)
        logger.info(output)
        assert not any(status in output for status in ("FAIL", 'error')), 'Sending WriteReplaceWarningRequest failed!'
        return params

    @staticmethod
    def __prepare_command_args(params):
        return ' '.join(['--{} {}'.format(param, value) for param, value in params.items()])


class EtwsBroadcaster:
    ETWS_DEFAULT_PARAMS = {
        'msg-id': 4352,
        'no-of-bcast': 5,
        'period': 5,
        'msg-content': 'ETWS test message.',
        'gnb': mrbts_id

    }
    ETWS_SCRIPT = 'WRO_RRM/ETWS_50861.py'
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        pass

    def primary(self, **kwargs):
        params = self.__prepare_etws_parameters(**kwargs)
        params.update({'primary': ''})
        params.update({'warn-type': kwargs.get('warn_type', 0)})
        return params

    def secondary(self, **kwargs):
        params = self.__prepare_etws_parameters(**kwargs)
        params.update({'secondary': ''})
        return params

    def start_etws_primary_notification(self, **kwargs):
        with CbcConnection(CBC_HOST, CBC_USER, CBC_PASS) as cbc:
            params = cbc.execute_script_on_cbc(self.ETWS_SCRIPT, self.primary(**kwargs))
            self.wait_for_broadcast()
        return params.get('sn')

    def start_etws_secondary_notification(self, **kwargs):
        with CbcConnection(CBC_HOST, CBC_USER, CBC_PASS) as cbc:
            params = cbc.execute_script_on_cbc(self.ETWS_SCRIPT, self.secondary(**kwargs))
            self.wait_for_broadcast()
        return params.get('sn')

    def start_etws_secondary_notification_twice(self, **kwargs):
        with CbcConnection(CBC_HOST, CBC_USER, CBC_PASS) as cbc:
            params1 = cbc.execute_script_on_cbc(self.ETWS_SCRIPT, self.secondary(msg_id=4352, **kwargs))
            self.wait_for_broadcast()
            params2 = cbc.execute_script_on_cbc(self.ETWS_SCRIPT, self.secondary(msg_id=4353, **kwargs))
            self.wait_for_broadcast()
        return params1.get('sn'), params2.get('sn')

    def start_primary_and_secondary_notification(self, **kwargs):
        with CbcConnection(CBC_HOST, CBC_USER, CBC_PASS) as cbc:
            params1 = cbc.execute_script_on_cbc(self.ETWS_SCRIPT, self.primary(**kwargs))
            self.wait_for_broadcast(2)
            params2 = cbc.execute_script_on_cbc(self.ETWS_SCRIPT, self.secondary(msg_id=4352, **kwargs))
            self.wait_for_broadcast()
        return params1.get('sn'), params2.get('sn')

    @staticmethod
    def wait_for_broadcast(period=4):
        time.sleep(float(period))

    @staticmethod
    def generate_sn():
        random.seed(int(datetime.now().timestamp()))
        return random.randint(1, 9999)

    @staticmethod
    def __validate_target(*args):
        set_arguments = list(filter(None, args))
        if not set_arguments:
            raise RuntimeError("Missing target area! Please provide at least one from: cells, tai or emergency_area")
        if len(set_arguments) != 1:
            raise RuntimeError("Too many arguments passed! Please provide only one: cells or tai or emergency_area")

    def __prepare_etws_parameters(self, msg_id=None, msg_content=None, cells=None, tai=None, emergency_area=None,
                                  period=None, no_of_bcast=None, sn=None):
        def adapt_key(name):
            return name.replace('_', '-')
        if not sn:
            sn = self.generate_sn()
        params = self.ETWS_DEFAULT_PARAMS.copy()
        self.__validate_target(cells, tai, emergency_area)
        for param in list(locals()):
            if locals()[param] is not None and param in argspec(self.__prepare_etws_parameters).args[1:]:
                params[adapt_key(param)] = locals()[param]
        params['sn'] = sn
        return params

    def start_cmas_notification(self, **kwargs):
        params = self.__prepare_etws_parameters(**kwargs)
        params.update({'cmas': ''})
        params.update({'msg-content': 'cmas test'})
        with CbcConnection(CBC_HOST, CBC_USER, CBC_PASS) as cbc:
            params = cbc.execute_script_on_cbc(self.ETWS_SCRIPT, params)
            self.wait_for_broadcast()
        return params.get('sn')

    def cancel_cmas_notification(self, **kwargs):
        params = self.__prepare_etws_parameters(msg_id=4396, **kwargs)
        params.update({'cancel-cmas': ''})
        params.update({'msg-content': 'cmas test'})
        with CbcConnection(CBC_HOST, CBC_USER, CBC_PASS) as cbc:
            cbc.execute_script_on_cbc(self.ETWS_SCRIPT, params)
            self.wait_for_broadcast()
        return params.get('sn')
