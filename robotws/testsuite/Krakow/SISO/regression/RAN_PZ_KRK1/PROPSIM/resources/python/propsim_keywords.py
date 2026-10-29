"""

Set of PROPSIM Keywords used for setting IN/OUT ports and reading current values.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""

import logging
from taf.hw.propsim import propsim


class CustomPropsimKeywords(object):
    __instance = None
    __initialized = None

    def __new__(cls, *args, **kwargs):
        if CustomPropsimKeywords.__instance is None:
            CustomPropsimKeywords.__instance = super(CustomPropsimKeywords, cls).__new__(cls)

        return CustomPropsimKeywords.__instance

    def __init__(self, ip=None, port=3334, alias='propsim'):
        if self.__initialized:
            return

        self.ip = ip
        self.port = port
        self.alias = alias
        self.propsim = propsim()

        self._config = []
        self._current_output_gain = {}

        CustomPropsimKeywords.__initialized = True

    def __del__(self):
        self.teardown_keysight_propsim()

    @property
    def config(self):
        if not self._config:
            self._config = self._get_current_propsim_configuration()

        return self._config

    def setup_keysight_propsim(self, ip=None, port=None, alias=None):
        """
        Setup connection to PROPSIM
        :param ip:      IP address to propsim. If not passed then is get from self.ip
        :param port:    port to propsim. If not passed then is get from self.port
        :param alias:   Alias for propsim. If not passed then is get from self.alias
        :return: None
        """
        self.ip = ip if ip else self.ip
        self.port = port if port else self.port
        self.alias = alias if alias else self.alias

        config = {
            'vendor': 'Keysight',
            'product': 'Propsim',
            'propsim_ip': self.ip,
            'propsim_port': self.port
        }
        self.propsim.setup(channel_emulator_config=config, alias=self.alias)

    def teardown_keysight_propsim(self):
        """
        Teardown connection to propsim.
        """
        self.propsim.teardown(emulator=self.alias)

    def start_propsim_emulation(self, emulation_file_path):
        """
        Load and start PROPSIM emulation.
        :param emulation_file_path: absolute path to emulation file located on windows propsim machine
        :return: None
        """
        current_state = self.propsim.query_emulation_state(emulator=self.alias)
        if current_state == 'RUNNING':
            self.propsim.stop_emulation(emulator=self.alias)
            self.propsim.close_emulation(emulator=self.alias)
        self.propsim.load_emulation_file(file_path=emulation_file_path, emulator=self.alias)
        self.propsim.start_emulation(emulator=self.alias)

    def stop_propsim_emulation(self):
        """
        Stop and close propsim emulation.
        """
        self.propsim.query_emulation_state(emulator=self.alias)
        self.propsim.stop_emulation(emulator=self.alias)
        self.propsim.close_emulation(emulator=self.alias)

    def set_output_gain(self, downlink_gain=None, uplink_gain=None):
        """
        Set Downlink and Uplink gain for all defined outputs in propsim.
        :param downlink_gain:
        :param uplink_gain:
        :return:
        """
        for channel_group_config in self.config:
            channel_group_name = channel_group_config['name']
            gain_value = downlink_gain if channel_group_name.lower() == 'downlink' else uplink_gain
            if gain_value is not None:
                self._set_output_gain_for_channel_group(channel_group_config, gain_value)
                self._current_output_gain[channel_group_name] = gain_value
            else:
                logging.debug("Gain value for CHANNEL_GROUP: '{}' not defined - Cannot set output gain. Details:\n {}".
                              format(channel_group_name, channel_group_config))

    def _set_output_gain_for_channel_group(self, channel_group_config, gain_value):
        for output in channel_group_config['outputs']:
            self.propsim.set_output_gain(output_number=output['id'], gain=gain_value, emulator=self.alias)

    def get_current_values(self):

        """
            data = {
                'Downlink': {
                    'gain': -4.9,
                    'outputs': {
                        '5G MS 1-RX1': 15.2,
                        '5G MS 1-RX2': 13.1
                    },
                    'inputs': {
                        '5G BS 1-TX1': -2.4,
                        '5G BS 1-TX2': 2.3,
                        '5G BS 1-TX3': -2.5,
                        '5G BS 1-TX4': -1.8
                    },
                    'channels': [14, 14.2, 13.8, 14.1]
                },
                'Uplink': {
                    'gain': 2.8,
                    'outputs': {
                        '5G BS 1-RX1': -29.8,
                        '5G BS 1-RX2': -29.7,
                        '5G BS 1-RX3': -29.6,
                        '5G BS 1-RX4': -29.9,
                    },
                    'inputs': {
                        '5G MS 1-TX1': 15.5,
                    },
                    'channels': [12.3, 14.2, 13.8, 14.1]
                }
            }
        :return:
        """
        current_values = {}
        for channel_group_config in self.config:
            channel_group_name = channel_group_config['name']
            current_values[channel_group_name] = {}
            current_output_values = self._get_current_expected_output_level_for_channel_group(channel_group_config)
            current_input_values = self._get_current_input_level_for_channel_group(channel_group_config)
            current_channel_values = self._get_current_channel_gain_for_channel_group(channel_group_config)
            current_values[channel_group_name]['outputs'] = current_output_values
            current_values[channel_group_name]['inputs'] = current_input_values
            current_values[channel_group_name]['channels'] = current_channel_values
            current_values[channel_group_name]['gain'] = self._current_output_gain.get(channel_group_name, None)
        return current_values

    def _get_current_expected_output_level_for_channel_group(self, channel_group_config):
        current_values = {}
        for output in channel_group_config['outputs']:
            value = self.get_expected_output_level(output_number=output['id'])
            current_values[output['name']] = value

        return current_values

    def _get_current_input_level_for_channel_group(self, channel_group_config):
        current_values = {}
        for _input in channel_group_config['inputs']:
            value = self.get_current_input_level(input_number=_input['id'])
            current_values[_input['name']] = value

        return current_values

    def _get_current_channel_gain_for_channel_group(self, channel_group_config):
        current_values = []
        for channel_number in channel_group_config['channels']:
            value = self.get_channel_gain(channel_number)
            current_values.append(value)

        return current_values

    def _get_current_propsim_configuration(self):
        """
        Get current channel/input/output ports configuration.
            [
                {
                    'id': 1,
                    'name': 'Downlink'
                    channels: [1, 2, 3, 4, 5, 6, 7, 8],
                    outputs: [
                        {
                            'id': 1,
                            'name': '5G MS 1-RX1'
                         }
                         ...
                         ...
                    ]
                    inputs: [
                        {
                            'id': 1,
                            'name': '5G BS 1-TX1'
                         }
                         ...
                         ...
                    ]
                },
                {
                    'id': 2,
                    'name': 'Uplink'
                    channels: [9, 10, 11, 12],
                    outputs: [
                        {
                            'id': 3,
                            'name': '5G MS 1-RX2'
                         }
                         ...
                         ...
                    ]
                    inputs: [
                        {
                            'id': 5,
                            'name': '5G MS 1-TX1'
                         }
                         ...
                         ...
                    ]
                },
            ]
        :return: generated configuration
        """
        config = []
        number_of_channel_groups = self.propsim.query_number_of_channel_groups(emulator=self.alias)
        for channel_group_index in range(1, number_of_channel_groups + 1):
            params = {'group_number': channel_group_index, 'emulator': self.alias}
            channels_of_channel_group = self.propsim.query_channels_of_channel_group(**params)
            channel_group_name = self.propsim.query_name_of_channel_group(**params)
            channel_group_outputs = self.propsim.query_outputs_of_channel_group(**params)
            if not isinstance(channel_group_outputs, list):
                channel_group_outputs = [channel_group_outputs]
            channel_group_inputs = self.propsim.query_inputs_of_channel_group(**params)
            if not isinstance(channel_group_inputs, list):
                channel_group_inputs = [channel_group_inputs]

            channel_group_config = {
                'id': channel_group_index,
                'name': channel_group_name,
                'channels': channels_of_channel_group,
                'outputs': [{'id': _id, 'name': self.get_output_name(_id)} for _id in channel_group_outputs],
                'inputs': [{'id': _id, 'name': self.get_input_name(_id)} for _id in channel_group_inputs],
            }

            config.append(channel_group_config)

        return config

    # Below keywords need to add to taf.hw.propsim library
    def get_current_input_level(self, input_number):
        return self.propsim.send(command='inp:meas:res:get? {}'.format(input_number), emulator=self.alias)

    def get_expected_output_level(self, output_number):
        return self.propsim.send(command='outp:meas:res:get? {}'.format(output_number), emulator=self.alias)

    def get_channel_model_gain(self, channel_number):
        return self.propsim.send(command='ch:mod:gain:mod? {}'.format(channel_number), emulator=self.alias)

    def get_channel_gain(self, channel_number):
        return self.propsim.send(command='ch:mod:gain:tot? {}'.format(channel_number), emulator=self.alias)

    def get_input_name(self, input_number):
        return self.propsim.send(command='inp:name? {}'.format(input_number), emulator=self.alias)

    def get_output_name(self, output_number):
        return self.propsim.send(command='outp:name? {}'.format(output_number), emulator=self.alias)
