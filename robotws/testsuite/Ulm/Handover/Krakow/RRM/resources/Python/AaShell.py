from robot.api import logger
from robot.api.deco import keyword
from ta5g_iphy import ta5g_iphy

AaShell_cmd = 'python3 /opt/UE_APP_OAM/service/OamTerm/oamTerm.py'
commands = ['help', 'mimo_muting_set', 'mimo_muting_get']
arguments = ['success_on_activation', 'success_on_deactivation',
             'deferred_result', 'response_delay']

commands_with_arguments = {
    'help': [
        None
    ],
    'mimo_muting_get': [
        None
    ],
    'mimo_muting_set': {
        'success_on_activation': [
            'true',
            'false'
        ],
        'success_on_deactivation': [
            'true',
            'false'
        ],
        'deferred_result': [
            'true',
            'false'
        ],
        'response_delay': [
            0,
            60
        ]
    }
}


class AaShell(object):
    def __init__(self):
        self.iphy = ta5g_iphy()
        self._rmod_count = None

    def _set_rmod_count(self):
        self._rmod_count = self.iphy.get_rmod_count_from_iphy()

    @property
    def rmod_count(self):
        if not self._rmod_count:
            self._set_rmod_count()
        return self._rmod_count

    def send_command_and_verify_response(self, cmd, expected_resp):
        resp = self.send_command(cmd)
        assert resp == expected_resp, "Wrong response: {} \n Should be: {}".format(
            resp, expected_resp)

    def send_command(self, cmd_to_execute):
        logger.console('Command to execute: {}'.format(cmd_to_execute))
        response = self.iphy.execute_wts_command(cmd_to_execute)
        if 'ERROR' in response:
            raise Exception('Error occurred')
        return response

    def prepare_command(self, rrh_id='1', command='help', arg=None, value=None):
        assert 0 < int(rrh_id) <= self.rmod_count, 'rrh_id out of range'
        assert command in commands_with_arguments.keys(), 'not supported command'
        cmd = AaShell_cmd + ' --db {} {}'.format(rrh_id, command)

        assert arg in commands_with_arguments[command], \
            'Wrong argument: {}, possible arguments: {}'.format(
                arg, commands_with_arguments[command])

        if arg is not None:
            cmd += ' {}'.format(arg)

        if value is not None:
            if type(value) is int:
                low, high = commands_with_arguments[command][arg]
                assert low <= value <= high, 'Wrong value: {}, should be in [{}-{}]'.format(
                    value, low, high)
                cmd += ' {}'.format(int(value))
            else:
                assert value in commands_with_arguments[command][arg], \
                    'Wrong value: {}, possible values: {}'.format(
                        value, commands_with_arguments[command][arg])
                cmd += ' {}'.format(value)

        return cmd

    @keyword("${action:(Enable|Disable)} TX ${opt:(de|)}activation failure for RRH-${rrh_id}")
    def manage_tx(self, action, opt, rrh_id):
        if action == 'Enable':
            value = 'false'
        else:
            value = 'true'

        if opt:
            arg = 'success_on_deactivation'
        else:
            arg = 'success_on_activation'

        cmd_to_send = self.prepare_command(
            rrh_id, 'mimo_muting_set', arg, value)
        self.send_command(cmd_to_send)

    @keyword("${action:(Enable|Disable)} TX activation failure for cell-${cell_id} on RRH-${rrh_id}")
    def manage_cell_tx(self, action, cell_id, rrh_id):
        if action == 'Enable':
            value = 'true'
        else:
            value = 'false'

        command = 'failure_on_carrier_activation {} {}'.format(cell_id, value)
        cmd_to_send = AaShell_cmd + ' --db {} {}'.format(rrh_id, command)
        self.send_command(cmd_to_send)

    @keyword("Set response delay for RRH-${rrh_id} to ${delay}")
    def set_response_delay(self, rrh_id, delay):
        cmd_to_send = self.prepare_command(
            rrh_id, 'mimo_muting_set', 'response_delay', int(delay))
        self.send_command(cmd_to_send)

    @keyword("Restore default values for RRH-${rrh_id}")
    def restore_defaults(self, rrh_id):
        cmds_to_send = [self.prepare_command(rrh_id, 'mimo_muting_set', 'success_on_activation', 'true'),
                        self.prepare_command(
                            rrh_id, 'mimo_muting_set', 'success_on_deactivation', 'true'),
                        self.prepare_command(
                            rrh_id, 'mimo_muting_set', 'deferred_result', 'true'),
                        self.prepare_command(rrh_id, 'mimo_muting_set', 'response_delay', 1)]

        for cmd in cmds_to_send:
            self.send_command(cmd)

    @keyword("Get current mimo_muting AaShell parameters for RRH-${rrh_id}")
    def get_mimo_muting_params(self, rrh_id):
        cmd_to_send = self.prepare_command(rrh_id, 'mimo_muting_get')
        response = self.send_command(cmd_to_send)

        d = [x.strip() for x in response.split('\n')]

        dictionary = {}

        for i in d[1:]:
            key, value = i.split(': ')
            if key == 'response_delay':
                value = int(value.split(' ')[0])
            dictionary[key] = value

        return dictionary
