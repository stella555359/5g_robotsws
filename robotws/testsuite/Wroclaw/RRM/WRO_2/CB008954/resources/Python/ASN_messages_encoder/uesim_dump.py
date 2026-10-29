from __future__ import print_function

import sys

from builtins import str
from builtins import object
import re
import os
import pexpect
import importlib
from argparse import ArgumentParser, RawDescriptionHelpFormatter
import textwrap
import pprint

TMP_MESSAGE_FILE = '/tmp/message_to_encode.txt'
UESIM_DUMP_MESSAGE_TYPES = ['NGAP', 'XNAP', 'NRRRC']
UESIM_DUMP_PATH = '/opt/emssim/util/uesim-dump'
PATH_TO_MODULES = '.'
DEBUG_WRITE_TMP_FILES_PER_MESSAGE_TYPE = True


def create_arguments_parser():
    parser = ArgumentParser(prog='PROG',
                            formatter_class=RawDescriptionHelpFormatter,
                            description=textwrap.dedent('''\
                            =======================================================================================
                            Example usage:
                            =======================================================================================
                            -
                            =======================================================================================
                                            '''))
    parser.add_argument('-show_hex', '--show_hex', dest="show_hex", help="", action="store_true")
    parser.add_argument('-mod', '--mod', dest="mod", help="", default=None)
    options = parser.parse_args()
    return options


class uesim_dump(object):

    def _load_test_modules(self):
        message_modules = {}
        for filemodulename in os.listdir(PATH_TO_MODULES):
            if ('NGAP' in filemodulename or 'XNAP' in filemodulename) and \
                    ('pattern' not in filemodulename and 'pyc' not in filemodulename):
                module_name = re.sub('.py[c]*', '', filemodulename)
                message_modules[module_name] = {'module': importlib.import_module(module_name), 'func': []}

                for func in eval('dir(message_modules[module_name][\'module\'].%s)' % (str(module_name))):
                    if 'test_' in func:
                        message_modules[module_name]['func'].append(str(func))
        # import pprint
        # pprint.pprint(message_modules)
        return message_modules

    def test_modules(self, printouts=False, module_phrase=None):
        errors_in = []
        modules = self._load_test_modules()
        print('\n')
        for module in list(modules.keys()):
            if module_phrase and module_phrase not in module:
                continue
            print("=============================================")
            print('Testing module : {}'.format(module))
            print("=============================================\n")

            for func in modules[module]['func']:
                msg_obj = eval('modules[\'%s\'][\'module\'].%s()' % (module, module))
                eval('msg_obj.%s()' % func)
                msg = eval('msg_obj.fill()')
                try:
                    if 'RRC' in module:
                        module_name = '-'.join(module.split('_')[1:])
                        proto_name = module.split('_')[0]

                        hex = self.encode_message(msg, proto_name, module_name)
                    else:
                        hex = self.encode_message(msg, 'XNAP' if 'XNAP' in module else 'NGAP', module)  # to FIX!!!
                    if printouts:
                        print("-------------------------------------------")
                        print('Encoded %s %s\n' % (module, func))
                        print(hex)
                        print("-------------------------------------------\n")
                except Exception as e:
                    print('Failed %s %s' % (module, func))
                    new_temp_file = "/tmp/" + module + func + ".txt"
                    errors_in.append(new_temp_file)
                    print('Error: %s' % str(re.sub(TMP_MESSAGE_FILE, new_temp_file, str(e))))
                    open(new_temp_file, "w").write(self.add_message_prefix(msg, self.get_message_type(module), module))
        print('All tests done and PASSED \n' if len(errors_in) == 0 else 'Not all tests passed')
        print(pprint.pformat(errors_in) if len(errors_in) else '')

    def get_message_type(self, message_name):
        if 'NRRRC' in message_name:
            return 'NRRRC'
        elif 'NGAP' in message_name:
            return 'NGAP'
        elif 'XNAP' in message_name:
            return 'XNAP'

    def is_msg_type_supported(self, msg_type):
        msg_type = str(msg_type).upper()
        if msg_type not in UESIM_DUMP_MESSAGE_TYPES:
            raise Exception("Message type (%s) not used by uesim-dump" % msg_type)
        else:
            return msg_type

    def add_message_prefix(self, msg, msg_type, msg_name):
        if msg_type == 'RRC':
            prefix_to_message = "value %s ::= " % str(msg_name)
        elif msg_name and 'ontainer' in msg_name:
            msg_name_wo_proto = '-'.join(msg_name.split('_')[1:])
            prefix_to_message = "value %s ::= " % str(msg_name_wo_proto)
        elif 'AP' in msg_type:  # for 'X2AP' of 'S1AP'
            prefix_to_message = "value %s-PDU ::= " % str(msg_type)

        return prefix_to_message + msg

    def write_message_to_file(self, msg, msg_type, msg_name):
        # TODO, add msg type in front of message when needed
        msg_type = self.is_msg_type_supported(msg_type)
        prefix_to_message = None
        msg = self.add_message_prefix(msg, msg_type, msg_name)
        open(TMP_MESSAGE_FILE, "w").write(msg)
        if DEBUG_WRITE_TMP_FILES_PER_MESSAGE_TYPE:
            open(TMP_MESSAGE_FILE+"_"+str(msg_type)+"_"+str(msg_name), "w").write(msg)

    def encode_message(self, msg, msg_type, msg_name=None):
        encoded_hex = None
        self.write_message_to_file(msg=msg, msg_type=msg_type, msg_name=msg_name)
        msg_type = self.is_msg_type_supported(msg_type)
        uesim_dump = pexpect.spawn("%s -A %s -a %s" % (UESIM_DUMP_PATH, msg_type, TMP_MESSAGE_FILE))
        uesim_dump.expect(pexpect.EOF)
        if uesim_dump.before.find(b"encoded-values(1)") != -1:
            match = re.search(r'ASN1-VALUE value\s+\w+[-\w]*\s+(\w[\d,A,B,C,D,E,F]*)', uesim_dump.before.decode())
            if match:
                encoded_hex = str(match.group(1))
                return encoded_hex
        else:
            raise Exception("Encoding Error: %s" % str(uesim_dump.before))


if __name__ == '__main__':
    sys.path.insert(0, '/home/ute/MN/UTE/robotws')
    options = create_arguments_parser()
    uesim = uesim_dump()
    uesim.test_modules(printouts=True if options.show_hex else False, module_phrase=options.mod)
