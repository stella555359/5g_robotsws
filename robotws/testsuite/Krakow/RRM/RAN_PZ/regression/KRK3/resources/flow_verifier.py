# -*- coding: utf-8 -*-
"""
Keywords for verifying the order of messages in pcap file. See 5GC002481 feature for example usage.

Keywords contained in this module require the definition of expected messages.
Follow the rules when defining these messages:

1. Your messages should be defined as strings.
   Each awaited message should be in format like:
     SgNBAdditionRequestAcknowledge
   In addition you can add parameters to verify, like:
     SgNBAdditionRequestAcknowledge(contains(physCellId=164),not_contains(John=Kennedy))

2. Remember that each parameter should be in format:
   contains(...parameter name......)
   or contains(......parameter name....=...parameter value.....)

3. You can use replace contains() by not_contains():
   not_contains(.....parameter name...)
   or not_contains(...parameter name......=..parameter value...)

!!! PARAMETER NAME AND VALUE SHOULD BE SEPARATED BY AN EQUAL SIGN (=) !!!

:copyright: Nokia Networks
:author: Marcin Wachacki
:contact: marcin.wachacki@nokia.com
:maintainer: Marcin Wachacki
:contact: marcin.wachacki@nokia.com
"""

from robot.api import logger

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.log.helper import LogHelper
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.log.matchers import PcapMessageMatcher as PM


class MissingMessage(Exception):
    """Exception for no messages in the flow."""
    pass


class InvalidMessageParameter(Exception):
    """Exception for mismatching message parameters."""
    pass


class InvalidUserDefinedMessageFormat(Exception):
    """Exception for invalid definition of a message to catch."""
    pass


class flow_verifier:

    DEFINITION_OF_EXPECTED_MESSAGES = """

    [*] Your messages should be defined as strings.
        Each awaited message should be in format like:
          SgNBAdditionRequestAcknowledge
        In addition you can add parameters to verify, like:
          SgNBAdditionRequestAcknowledge(contains(physCellId=164),not_contains(John=Kennedy))

    [*] Remember that each parameter should be in format:
        contains(...parameter name......)
        or contains(......parameter name....=...parameter value.....)

    [*] You can use replace contains() by not_contains():
        not_contains(.....parameter name...)
        or not_contains(...parameter name......=..parameter value...)

    [*] !!! PARAMETER NAME AND VALUE SHOULD BE SEPARATED BY AN EQUAL SIGN (=) !!!

    """

    def expect_messages_in_flow(self, awaited_messages, pcap_file):
        """
        The method verifies message flow. Method checks the order of messages too.
        :param awaited_messages: list of expected messages in flow (optionally with parameters), e.g.:
            [ 'SgNBAdditionRequest(contains(UEAggregateMaximumBitRate))',  'SgNBAdditionRequestAcknowledge' ]
        :param pcap_file: path to pcap file
        :return: None
        """
        parsed_awaited_messages = self._parse_awaited_messages(awaited_messages)
        with LogHelper() as LH:
            finder = self._get_message_finder(LH, pcap_file)
            for parsed_awaited_message in parsed_awaited_messages:
                pm = PM(parsed_awaited_message['name'], name_line_pattern='empty')
                message = finder.find_next(pm)
                if not pm(message):
                    continue
                parsed_awaited_message['verified_result'] = True
                parsed_awaited_message['params'] = self._verify_message_params(parsed_awaited_message['params'],
                                                                               pm, message)
            self._verify_results(parsed_awaited_messages)

    def count_message_in_the_flow(self, awaited_message, pcap_file):
        """
        The method counts all messages in the flow.
        :param awaited_message: expected message in flow (optionally with parameters), e.g.:
            'SgNBAdditionRequest(contains(UEAggregateMaximumBitRate))'
        :param pcap_file: path to pcap file
        :return: number of matched messages
        """
        parsed_awaited_message = self._parse_awaited_message(awaited_message)
        with LogHelper() as LH:
            finder = self._get_message_finder(LH, pcap_file)
            pm = PM(parsed_awaited_message['name'], name_line_pattern='empty')
            messages = finder.find_all(pm)
            verified_messages = self._match_founded_messages(messages, parsed_awaited_message, pm)
            return len(verified_messages)

    def check_if_message_is_in_flow(self, awaited_message, pcap_file):
        """
        The method check if message exists in the flow.
        :param awaited_message: expected message in flow (optionally with parameters), e.g.:
            'SgNBAdditionRequest(contains(UEAggregateMaximumBitRate))'
        :param pcap_file: path to pcap file
        :return: Ture if message exists with defined parameters otherwise, False
        """
        founded_messages = self.count_message_in_the_flow(awaited_message, pcap_file)
        logger.info('Message flow contains {} awaited messages'.format(founded_messages))
        return bool(founded_messages)

    def _get_message_finder(self, log_helper, pcap_file):
        """
        The method returns finder object to find expected messages.
        :param log_helper: finder object to find expected messages
        :param pcap_file: path to pcap file
        :return:
        """
        finder = log_helper.add_pcap(pcap_file)
        logger.info('Pcap file was opened successfully.')
        return finder

    def _parse_awaited_messages(self, messages):
        """
        The method parses messages with parameters defined by user.
        :param messages: messages defined by user, e.g.:
            [ 'SgNBAdditionRequest(contains(UEAggregateMaximumBitRate))',  'SgNBAdditionRequestAcknowledge' ]
        :return: list consisting of dictionaries with message name and message parameters
        """
        parsed_messages = []
        for message in messages:
            parsed_message = self._parse_awaited_message(message)
            parsed_messages.append(parsed_message)
        return parsed_messages

    def _parse_awaited_message(self, message):
        """
        The method parses single message with parameters defined by user.
        :param message: message defined by user, e.g.:
            'SgNBAdditionRequest(contains(UEAggregateMaximumBitRate))'
        :return: dictionary consisting of message name and message parameters, e.g.:
            {'name': 'SgNBAdditionRequest',
             'params': [{'action': 'contains', 'body': ['UEAggregateMaximumBitRate'], 'verified_result': False}],
             'verified_result': False}
        """
        parsed_message = {
            'name': self._get_awaited_message_name(message),
            'params': self._get_awaited_message_params(message),
            'verified_result': False,
        }
        return parsed_message

    def _get_awaited_message_name(self, message):
        """
        The method cuts message name from message defined by user.
        :param message: message defined by user, e.g.:
            'SgNBAdditionRequest(contains(UEAggregateMaximumBitRate))'
        :return: name of message
        """
        try:
            left_bracket_param_index = message.index('(')
            message_name = message[:left_bracket_param_index]
        except ValueError:
            message_name = message
        return message_name.strip()

    def _get_awaited_message_params(self, message):
        """
        The method cuts awaited message parameters.
        :param message: message defined by user, e.g.:
            'SgNBAdditionRequest(contains(UEAggregateMaximumBitRate))'
        :return: list of raw parameters, e.g.:
            [ 'contains(UEAggregateMaximumBitRate)' ]
        """
        try:
            left_bracket_param_index = message.index('(')
            right_bracket_param_index = message.rindex(')')
            raw_params = message[left_bracket_param_index + 1:right_bracket_param_index].strip().split(',')
        except ValueError:
            return []
        return self._parse_awaited_message_parameter(raw_params)

    def _parse_awaited_message_parameter(self, raw_params):
        """
        The method parses parameters of message defined by user.
        :param raw_params: list of raw parameters, e.g.:
            [ 'contains(UEAggregateMaximumBitRate)' ]
        :return: list of parameters, e.g.:
            [{'action': 'contains', 'body': ['UEAggregateMaximumBitRate'], 'verified_result': False}]
        """
        self._verify_awaited_message_raw_params(raw_params)
        parsed_params = []
        for p in raw_params:
            try:
                left_bracket_param_index = p.index('(')
                right_bracket_param_index = p.rindex(')')
                action = p[0:left_bracket_param_index].strip()
                param_body = p[left_bracket_param_index + 1:right_bracket_param_index]
            except ValueError:
                msg_err = "\nError in '{}' parameter.".format(p)
                logger.error(msg_err + self.DEFINITION_OF_EXPECTED_MESSAGES)
                raise InvalidUserDefinedMessageFormat(msg_err)
            parsed_param_structure = {'action': action, 'body': param_body.split('='), 'verified_result': False}
            parsed_params.append(parsed_param_structure)
        return parsed_params

    def _verify_awaited_message_raw_params(self, raw_params):
        """
        The method checks if the user has correctly defined the parameters of awaited message.
        :param raw_params: list of raw parameters, e.g.:
            [ 'contains(UEAggregateMaximumBitRate)' ]
        :return: None
        """
        for raw_param in raw_params:
            param_striped = raw_param.strip()
            if not (param_striped.startswith('contains(') or param_striped.startswith('not_contains(')) \
                    or not param_striped.endswith(')'):
                msg_err = "\nError in '{}' parameter.".format(raw_param)
                logger.error(msg_err + self.DEFINITION_OF_EXPECTED_MESSAGES)
                raise InvalidUserDefinedMessageFormat(msg_err)

    def _verify_message_params(self, parsed_awaited_message_params, pm, message):
        """
        The method verifies caught message parameters.
        :param parsed_awaited_message_params: list of parsed message parameters, e.g.:
            [ {'action': 'contains', 'body': ['UEAggregateMaximumBitRate'], 'verified_result': False} ]
        :param pm: object to verify message parameters
        :param message: message founded by message finder
        :return: list of parsed message parameters with changed 'verified_result' field, e.g.:
            [ {'action': 'contains', 'body': ['UEAggregateMaximumBitRate'], 'verified_result': False} ]
        """
        for param in parsed_awaited_message_params:
            if param['action'] == 'contains':
                param['verified_result'] = bool(pm.containing(*param['body'])(message))
            if param['action'] == 'not_contains':
                param['verified_result'] = bool(pm.not_containing(*param['body'])(message))
        return parsed_awaited_message_params

    def _match_founded_messages(self, founded_messages, parsed_awaited_message, pm):
        """
        The method verifies if all messages matched by finder are valid.
        :param founded_messages: messages founded by message finder
        :param parsed_awaited_message: list of parsed message
        :param pm: object to verify message parameters
        :return: list of verified messages
        """
        verified_messages = []
        for message in founded_messages:
            if pm(message):
                parsed_awaited_message['params'] = self._verify_message_params(parsed_awaited_message['params'],
                                                                               pm, message)
                if self._get_message_parameters_verification_result(parsed_awaited_message):
                    verified_messages.append(message)
                    logger.info('{} message has been matched.'.format(parsed_awaited_message['name']))
        return verified_messages

    def _verify_results(self, verified_awaited_messages):
        """
        The method analyses result of message verification procedure until the first discrepancy occurs.
        :param verified_awaited_messages: parsed messages with result of message verification procedure
        :return: None
        """
        for message in verified_awaited_messages:
            self._verify_missing_message(message)
            if message['params']:
                self._verify_missing_message_parameter(message['params'], message['name'])
            logger.info('Message {} is valid.'.format(message['name']))

    def _verify_missing_message(self, message):
        """
        The method will log and throw an exception when there is no awaited message in the flow.
        :param message: parsed message with result of message verification procedure
        :return: None
        """
        if not message['verified_result']:
            err_msg = "{} message did not occur (no message in flow).".format(message['name'])
            logger.error(err_msg)
            raise MissingMessage(err_msg)

    def _verify_missing_message_parameter(self, message_params, message_name):
        """
        The method will log and throw an exception in the case of a missing parameter or an incorrect parameter value.
        :param message_params: list of message parameters with verification results
        :param message_name: name of message
        :return: None
        """
        for param in message_params:
            if not param['verified_result']:
                err_msg = "{} message occurred, but parameter is invalid: {}".format(
                    message_name, param['body'][0]
                )
                if len(param['body']) == 2:
                    err_msg += ' == {}'.format(param['body'][1])
                logger.error(err_msg)
                raise InvalidMessageParameter(err_msg)

    def _get_message_parameters_verification_result(self, parsed_awaited_message):
        """
        The method sums up verification of parameters without throwing an exception.
        :param parsed_awaited_message: parsed message with result of message verification procedure
        :return: True if all parameters are valid otherwise, False
        """
        params_verify_result = all([p['verified_result'] for p in parsed_awaited_message['params']])
        if params_verify_result:
            logger.info("{} message occurred.".format(parsed_awaited_message['name']))
            return True
        logger.info("{} message occurred but without defined parameter.".format(parsed_awaited_message['name']))
        return False
