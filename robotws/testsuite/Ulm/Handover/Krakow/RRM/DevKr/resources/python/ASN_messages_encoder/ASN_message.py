from __future__ import print_function
from builtins import str
from builtins import range
from builtins import object
__author__ = 'krawczuk'

import re
import importlib
import os
import pprint
INDENT = "  "
PATH_TO_ASN_MESSAGES = "testsuite.Ulm.Handover.Krakow.RRM.DevKr.resources.python.ASN_messages_encoder"
LOG = False
RAISE_ON_NOT_DEFINED = False


def log(data):
    if LOG:
        print(data)


class ASN_message(object):
    def __init__(self):
        self.patternlib = importlib.import_module(PATH_TO_ASN_MESSAGES + '.'
                                                  + str(self.__class__.__name__)+"_patterns")
        self.msg_name = str(self.__class__.__name__)
        self.msg_container = getattr(
            self.patternlib, str(self.msg_name)+'_container')
        self.logger = log
        self._needed_patterns_dict = {}
        self._declared_patterns_dict = {}

    def fill(self):
        if not hasattr(self, 'fill_used'):
            to_substitute = self.find_unfilled_patterns()
            for sub in to_substitute:
                if LOG:
                    self._needed_patterns_dict[sub] = 1 if sub not in self._needed_patterns_dict \
                        else self._needed_patterns_dict[sub]+1
                if hasattr(self, sub):
                    to_overwrite = getattr(self, sub)
                    log('To overwrite value')
                    log(pprint.pformat(to_overwrite))
                    if type(to_overwrite) is list:
                        if LOG:
                            self._declared_patterns_dict[sub] = len(to_overwrite) \
                                if sub not in self._declared_patterns_dict else self._declared_patterns_dict[sub]
                        log('Getting %s from the list' % (str(sub)))
                        if len(to_overwrite):
                            new_pattern = to_overwrite.pop(0)
                        else:
                            if RAISE_ON_NOT_DEFINED:
                                raise
                            else:
                                print('[WARN] Lack of definition for %s, using value from PATTERNLIB,'
                                      'you probably DO NOT WANT this!' % str(sub))
                                new_pattern = getattr(self.patternlib, sub)
                    else:
                        if LOG:
                            self._declared_patterns_dict[sub] = 1 if sub not in self._declared_patterns_dict \
                                else self._declared_patterns_dict[sub]
                        new_pattern = to_overwrite
                else:
                    try:
                        new_pattern = getattr(self.patternlib, sub)
                    except AttributeError:
                        new_pattern = sub[1:-1]
                        raise

                if new_pattern is None:
                    match = re.search(sub+r'\s*,', self.msg_container)
                    if match:
                        # if not the last container on list, do not remove ','
                        pattern_to_find = ".*?"+sub+".*"
                    else:
                        pattern_to_find = "[\n,]*.*?"+sub+".*"
                    self.msg_container = re.sub(
                        pattern_to_find, "", self.msg_container, 1)
                else:
                    # log(str(sub)+"->"+str(new_pattern))
                    self.msg_container = re.sub(
                        sub, new_pattern, self.msg_container, 1)
            log('DICT of NEEDED')
            log(pprint.pformat(self._needed_patterns_dict))
            log('DICT of DECLARED')
            log(pprint.pformat(self._declared_patterns_dict))
            if LOG:
                log(self.msg_container)

            if len(self.find_unfilled_patterns()):
                self.fill()
            self.fill_used = True
            return self.add_indents(self.msg_container)
        else:
            raise Exception(
                "fill method can be only used once per object lifetime!")

    def find_unfilled_patterns(self):
        found_patterns = re.findall(r'(_\w+[_\w]*_)', self.msg_container)
        log(found_patterns)
        return found_patterns

    def set_field(self, field, value):
        field_name = re.sub('-', '_', field)
        field_name = ("_"+field_name) if field_name[0] != '_' else field_name
        field_name = (
            field_name + "_") if field_name[-1] != '_' else field_name

        if not hasattr(self, field_name):
            setattr(self, field_name, value)
            return
        # if it exists, convert it to list and append
        if type(getattr(self, field_name)) is list:
            getattr(self, field_name).append(value)
        else:
            setattr(self, field_name, [getattr(self, field_name), value])
        log(getattr(self, field_name))

    def get_field(self, field_name):
        if not hasattr(self, field_name):
            return getattr(self.patternlib, field_name)
        # if it exists, convert it to list and append
        if type(getattr(self, field_name)) is list:
            return getattr(self, field_name)[-1]
        else:
            return getattr(self, field_name)

    def add_container(self, src_container, added_container):
        if src_container:
            src_container += ',\n'
        return src_container + added_container

    def append_to_list(self, list_name, item_to_add=None):
        to_add = item_to_add if item_to_add is not None else list_name
        if hasattr(self, list_name):
            setattr(self, list_name, self.add_container(
                getattr(self, list_name), getattr(self.patternlib, to_add)))
        else:
            setattr(self, list_name, getattr(self.patternlib, to_add))

    def multiply_container(self, src_container, times=1):
        for i in range(0, times):
            src_container = self.add_container(src_container, src_container)
        return src_container

    def add_indents(self, msg):
        msg_list_of_lines = msg.split('\n')
        msg_indented_lines = []
        current_indent_level = 0
        indent = INDENT
        for line in msg_list_of_lines:
            if line:
                msg_indented_lines.append(
                    str(indent)*current_indent_level + str(line))
                current_indent_level += 1 if ('{' or '[') in line else 0
                current_indent_level -= 1 if ('}' or ']') in line else 0
        msg_indented = "\n".join(msg_indented_lines)
        return msg_indented

    def encode_cell_ECI(self, eNB_id, cell_id):
        return self.convert_int_to_bin_with_fixed_length(eNB_id, 20) + \
            self.convert_int_to_bin_with_fixed_length(cell_id, 8)

    def encode_plmn_id(self, mcc, mnc):
        mcc = str(mcc)
        mnc = str(mnc)
        if len(mnc) == 2 and len(mcc) == 3:
            plmn_id = mcc[1] + mcc[0] + 'F' + mcc[2] + mnc[1] + mnc[0]
            return plmn_id
        elif len(mnc) == 3 and len(mcc) == 3:
            plmn_id = mcc[1] + mcc[0] + mnc[2] + mcc[2] + mnc[1] + mnc[0]
            return plmn_id
        else:
            return None

    def convert_int_to_bin_with_fixed_length(self, int_number, length):
        return str(bin(int_number))[2:].zfill(length)
