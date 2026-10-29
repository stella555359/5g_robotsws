try:
    from StringIO import StringIO  # for Python 2
except ImportError:
    from io import StringIO  # for Python 3
from testsuite.Krakow.RRM.RAN_PZ.resources.pcap_verification.tsharkWithLuaVerifier import \
    TSharkCommandAssembler
from testsuite.Krakow.RRM.RAN_PZ.resources.decorators import logged_keyword


class FieldHelper:

    def __init__(self, pcap_filter, field_name, pcap_file):
        self.pcap_file = pcap_file
        self.output = self.__get_field_from_pcap(pcap_filter, field_name)
        self.tree = self.__parse_message_to_tree(self.output)

    @logged_keyword
    def __get_field_from_pcap(self, pcap_filter, field_name):
        output = TSharkCommandAssembler() \
            .with_pcap_file(self.pcap_file) \
            .with_filter(pcap_filter) \
            .build()
        assert output, 'Output from tshark is blank. Check tshark command or filters.'
        output = [x.replace('    ', ' ') for x in output if x != '']
        output = self.__get_output_below_field(output, field_name)
        return '\n'.join(output)

    def __get_output_below_field(self, output, field_name):
        start_out = output[self.__get_index_containing_substring(output, field_name):]
        end_out = []
        spaces = start_out[0].split(field_name)[0]
        if spaces == '':
            for line in start_out:
                if line == start_out[0] or line.startswith(' '):
                    end_out.append(line)
            return end_out

        for line in start_out:
            if line.startswith(spaces + ' ') or line == start_out[0]:
                end_out.append(line)
            else:
                break

        return [x[len(spaces):] for x in end_out]

    @staticmethod
    def __get_index_containing_substring(table, substring):
        for idx, item in enumerate(table):
            if substring in item:
                return idx
        return None

    def __parse_message_to_tree(self, message):
        buf = StringIO.StringIO(message)
        return self.__parse_message_to_tree_helper(buf, 0, None)[0]

    def __parse_message_to_tree_helper(self, buf, prev, prevline):
        ret = {}
        index = -1
        for line in buf:
            line = line.rstrip()
            index = len(line) - len(line.lstrip())
            if index > prev:
                ret[prevline.strip()], prevline, index = self.__parse_message_to_tree_helper(buf, index, line)
                if index < prev:
                    return ret, prevline, index
                continue
            elif not prevline:
                ret[line.strip()] = {}
            else:
                ret[prevline.strip()] = {}
            if index < prev:
                return ret, line, index
            prevline = line
        if index == -1:
            ret[prevline.strip()] = {}
            return ret, None, index
        if prev == index:
            if prevline:
                ret[prevline.strip()] = {}
        return ret, None, 0


class TreeWalker:

    def __init__(self, tree):
        self.tree = tree
        self.search_result = []

    @logged_keyword
    def find_first(self, search_value):
        self.search_result = []
        found = self.__tree_walker_one(self.tree, search_value)
        self.search_result.append(found)
        return found

    @logged_keyword
    def find_all(self, search_value):
        self.search_result = []
        self.__tree_walker_all(self.tree, search_value)
        return self.search_result

    def get_found_elements(self):
        ret_val = []
        for key_path in self.search_result:
            walker = self.tree
            for key in key_path:
                walker = walker[key]
            ret_val.append(walker)
        return ret_val

    def __tree_walker_one(self, indict, search_value, pre=None):
        pre = pre if pre else []
        for key, value in indict.items():
            if search_value in key:
                return pre + [key]
            if isinstance(value, dict) and value != {}:
                result = self.__tree_walker_one(value, search_value, pre + [key])
                if result:
                    return result

    def __tree_walker_all(self, indict, search_value, pre=None):
        pre = pre if pre else []
        for key, value in indict.items():
            if search_value in key:
                self.search_result.append(pre + [key])
            if isinstance(value, dict) and value != {}:
                self.__tree_walker_all(value, search_value, pre + [key])
