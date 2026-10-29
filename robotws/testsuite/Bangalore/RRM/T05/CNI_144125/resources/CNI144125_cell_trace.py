import time
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
import ta_pdml_parser.interface as hex_parser


class MessageNotFound(Exception):
    def __init__(self, message):
        self.message = 'Message {} was not present in cell trace'.format(message)
        super(MessageNotFound, self).__init__(self.message)


class UnexpectedMessageFound(Exception):
    def __init__(self, message):
        self.message = 'Message {} was present in cell trace'.format(message)
        super(UnexpectedMessageFound, self).__init__(self.message)


class CNI144125_cell_trace:
    def __init__(self):
        self.emss = BuiltIn().get_library_instance('ta_emss')

    def get_traced_messages(self, enb_id=1):
        parse_func = getattr(hex_parser, 'parse_s1ap_container')
        parsed_messages = []
        events = self.emss.cell_trace_get(enb_id=enb_id)
        for event in events:
            for message in event['Trace Messages']:
                parsed_message = {}
                parsed_message['title'] = message['Message Title']
                parsed_message['content'] = parse_func('S1AP-PDU', message['NAS Message'])
                parsed_messages.append(parsed_message)
        return parsed_messages

    @keyword('Verify that ${exp_message_title} was present in cell trace')
    def verify_message_was_present_in_trace(self, exp_message_title):
        time.sleep(1)
        messages = self.get_traced_messages()
        for message in messages:
            if message['title'] == exp_message_title:
                print('Message content:\n{}'.format(message['content']))
                return
        raise MessageNotFound(exp_message_title)

    @keyword('Verify that ${exp_message_title} was not present in cell trace')
    def verify_message_was_not_present_in_trace(self, exp_message_title):
        time.sleep(1)
        messages = self.get_traced_messages()
        for message in messages:
            if message['title'] == exp_message_title:
                print('Message content:\n{}'.format(message['content']))
                raise UnexpectedMessageFound(exp_message_title)
        return
