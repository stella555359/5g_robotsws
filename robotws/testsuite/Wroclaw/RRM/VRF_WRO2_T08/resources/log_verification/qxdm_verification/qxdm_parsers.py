import re


class DefaultMessageParser:
    def __init__(self, message):
        assert message or len(message) < 2, f"Parser initialised with invalid message: {message}"
        self._message = message
        self.values = {}
        self.msg_type = extract_message_name_from_message_header(message[0])
        self._parse()

    def _parse(self):
        generator = self._generate_lines()
        last_parent = ""
        for line in generator:
            if " = " in line:
                parts = line.split(" = ")
                if re.match(r"\s", parts[0]):
                    name = f"{last_parent}_{parts[0].strip()}"
                else:
                    name = parts[0].strip()
                if self.values.get(name, None) is None:
                    self.values[name] = []
                self.values[name].append(parts[1].strip())
            elif "------------------" in line:
                self._update_value_dict_with_tab(DefaultMessageParser._get_values_from_tab(generator))
            else:
                last_parent = line.strip()

    def _generate_lines(self):
        for line in self._message:
            yield line

    @staticmethod
    def _get_values_from_tab(message_gen):
        second_dashline_occured = False
        keys = []
        indexes = []
        values = []
        for line in message_gen:
            if not line.strip():
                break
            if "------------------" in line:
                second_dashline_occured = True
            else:
                if second_dashline_occured:
                    vals = [value.strip() for value in line.split("|")[1:-1]]
                    converted_vals = []
                    for val in vals:
                        try:
                            conv_val = float(val)
                        except ValueError:
                            conv_val = val
                        converted_vals.append(conv_val)
                    values.append(converted_vals)
                else:
                    indexes.append(DefaultMessageParser._find_indexes_of_tabular_dissectors(line))
                    keys.append([key.strip() for key in line.split("|")[1:-1]])
        DefaultMessageParser._add_dummy_columns_to_keys_if_needed(keys, indexes)
        keys_merged = [" ".join(key_part).strip() for key_part in zip(*keys)]
        values_merged = zip(*values)
        key_value_pairs = zip(keys_merged, values_merged)
        return DefaultMessageParser._make_dict_from_key_value_tuples(key_value_pairs)

    @staticmethod
    def _find_indexes_of_tabular_dissectors(line):
        return [index for index, character in enumerate(line) if character == "|"]

    @staticmethod
    def _add_dummy_columns_to_keys_if_needed(list_of_key_lists, list_of_index_lists):
        previous_indexes = None
        for i, indexes in enumerate(list_of_index_lists[::-1]):
            if previous_indexes is None:
                previous_indexes = indexes
                continue
            mismatch_index = None
            key_removed = False
            for j, index in enumerate(previous_indexes):
                if index != indexes[j if mismatch_index is None else mismatch_index]:
                    mismatch_index = j if mismatch_index is None else mismatch_index
                    if not key_removed:
                        list_of_key_lists[-1 * (i + 1)][mismatch_index - 1] = " "
                        key_removed = True
                    list_of_key_lists[-1 * (i + 1)].insert(mismatch_index, " ")
                    indexes.insert(mismatch_index, j)
                    mismatch_index += 1
                else:
                    key_removed = False
                    if mismatch_index is not None and len(indexes) > mismatch_index + 1:
                        mismatch_index += 1
            previous_indexes = indexes

    @staticmethod
    def _make_dict_from_key_value_tuples(key_value_pairs):
        out_dict = {}
        for key, value in key_value_pairs:
            if out_dict.get(key, None) is None:
                out_dict[key] = value
            else:
                i = 1
                while out_dict.get(key + "_" + str(i), None) is not None:
                    i += 1
                if i == 1:
                    out_dict[key + "_1"] = out_dict[key]
                    out_dict[key + "_2"] = value
                    out_dict[key] = ["Key ({k}) has a duplicate - look for 'key_nr' (example: {k}_1)".format(k=key)]
                else:
                    out_dict[key + "_" + str(i)] = value
        return out_dict

    def _update_value_dict_with_tab(self, new_values):
        for key, values in new_values.items():
            if self.values.get(key, None) is None:
                self.values[key] = []
                for value in values:
                    self.values[key].append([value])
            else:
                for ind, value in enumerate(values):
                    if len(self.values[key]) > ind:
                        self.values[key][ind].append(value)
                    else:
                        self.values[key].append([value])


class QTraceParser:
    def __init__(self, message):
        assert message or len(message) < 2, "Parser initialised with invalid message: {}".format(message)
        self._message = message
        self.values = {}
        self.msg_type = None
        self._parse_qtrace_by_type(message[1].lower())

    def _parse_qtrace_by_type(self, value_line):
        self._default_qtrace_parse(value_line)
        if (
            ("nr5g_mac_metric_qsh.c" in value_line or "nr5g_mac_qsh_analysis.c" in value_line)
            and "nr5gmac" in value_line
            and "avgphy" in value_line
        ):
            self._parse_as_nrmac_throughput_qtrace()
            if " | dl " in value_line:
                self.msg_type = "QTRACE_DL_NR_throughput"
            elif " | ul " in value_line:
                self.msg_type = "QTRACE_UL_NR_throughput"
            else:
                self.msg_type = "Unknown_throughput_QTRACE"
        elif "enl2_dl_qsh.c" in value_line and ":[phy:" in value_line and "mac:" in value_line:
            self._parse_as_nr_l2_throughput_qtrace()
            self.msg_type = "QTRACE_DL_L2_throughput"
        elif "nr5g_l2ul_qsh.c" in value_line and ":[ipa:" in value_line and "l2ul:" in value_line:
            self._parse_as_nr_l2_throughput_qtrace()
            self.msg_type = "QTRACE_UL_L2_throughput"
        else:
            self.msg_type = "Unknown_QTRACE"

    def _parse_as_nrmac_throughput_qtrace(self):
        if self.values["avgphy"][-1] == "s":
            self.values["avgphy"] = self.values["avgphy"].split(" ")[0]
        if self.values["bler"][-1] == "%":
            self.values["bler"] = self.values["bler"][:-1]

    def _parse_as_nr_l2_throughput_qtrace(self):
        for tput_param in self.values["tput"].split(";"):
            if ":" in tput_param:
                param_name, param_val = self._split_colon_param(tput_param)
                self.values[param_name] = param_val

    def _default_qtrace_parse(self, value_line):
        line_parts = [part.strip() for part in value_line.split("|")]
        for param in line_parts:
            if ":" in param:
                param_name, param_val = self._split_colon_param(param)
                self.values[param_name] = param_val

    def _split_colon_param(self, param):
        param_split = param.split(":", maxsplit=1)
        param_name = param_split[0].strip().split(".")[0]
        param_val = param_split[-1].strip()
        if "*" in param_name:
            param_name, divisor = param_name.split("*")
            param_val = str(float(param_val) / float(divisor))
        return param_name, param_val


parsers = {"QTrace Messages": QTraceParser}


def get_parser(message_name):
    return parsers.get(message_name, DefaultMessageParser)


def extract_message_name_from_message_header(message_header):
    return message_header.split("  ")[-1].strip()
