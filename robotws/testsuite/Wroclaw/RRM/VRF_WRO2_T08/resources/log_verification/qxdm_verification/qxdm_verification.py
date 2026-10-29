from .qxdm_parsers import extract_message_name_from_message_header, get_parser


def extract_raw_values_from_qxdm_log(filepath, msg_name_list=None):
    messages = get_messages_from_qxdm_log(filepath, msg_name_list)
    for message in messages:
        message_name = extract_message_name_from_message_header(message[0])
        parser = get_parser(message_name)
        parser = parser(message)
        yield parser.msg_type, parser.values


def analyze_qxdm_log(filepath, msg_name_list, param_names, filters=None):
    """
    :param filepath: string holding path to .txt log from qcat
    :param msg_name_list: list of message names
    :param param_names:   list of parameter names to analyze
    :param filters: list of tuple elements with structure: (param, comparison, value)
                    where: param -> string with parameter name
                           comparison -> string with proper sign, such as '==', '<', '>=' etc.
                           value -> value to compare to
                    example:  ('Is Msg3', '==', '1.0')
    :return: dict with analysis
    """
    analysis = {}
    filters = filters if filters is not None else []
    raw_data = extract_raw_values_from_qxdm_log(filepath, msg_name_list)
    for message_type, message_values in raw_data:
        filters_passed = True
        for filter_param in filters:
            if message_values.get(filter_param[0], None) is None:
                continue
            value_list = message_values[filter_param[0]]
            for ind, value in enumerate(value_list):
                if isinstance(value, list):
                    if eval("any([val for val in value if val {} {}])".format(filter_param[1], filter_param[2])):
                        filters_passed = True
                        break
                else:
                    if eval("value {} {}".format(filter_param[1], filter_param[2])):
                        filters_passed = True
                        break
                filters_passed = False
        if not filters_passed:
            continue
        for param_name in param_names:
            param_val = message_values.get(param_name, None)
            if param_val is not None:
                if analysis.get(message_type, None) is None:
                    analysis[message_type] = {}
                if analysis[message_type].get(param_name, None) is None:
                    analysis[message_type][param_name] = [] if isinstance(param_val, list) else {}
                _update_measurements(analysis[message_type][param_name], param_val)
    return analysis


def get_messages_from_qxdm_log(filepath, name_list=None):
    with open(filepath, "rb") as ue_log:
        start_flag = False
        message_buffer = []
        for line in ue_log:
            try:
                line = line.decode()
            except UnicodeDecodeError:
                continue
            if _is_message_indicator(line):
                if not start_flag:
                    start_flag = True
                else:
                    yield message_buffer
                message_buffer = []
                if name_list is not None and not any([name in line for name in name_list]):
                    start_flag = False
            message_buffer.append(line)
        yield message_buffer


def _is_message_indicator(line):
    parts = line.split("  ")
    if len(parts) < 5 or not line[0].isdigit():
        return False
    if len(parts[1]) == 1 and parts[1].isdigit():
        del parts[1]
    if ":" not in parts[1] or "[" not in parts[2] or "]" not in parts[2] or "0x" not in parts[3]:
        return False
    return True


def _update_measurements(history_values, new_values):
    # TODO: Spaghetti - Refactor the shit out of this
    if isinstance(new_values, list) or isinstance(history_values, list):
        assert isinstance(new_values, list) and isinstance(
            history_values, list
        ), "Error! Mismatch in list parameter recognition"
    if isinstance(new_values, list):
        for ind, value in enumerate(new_values):
            # TODO: 'value' may be list
            if isinstance(value, list):
                for nested_val in value:
                    try:
                        nested_val = float(nested_val)
                        float_convertible = True
                    except ValueError:
                        float_convertible = False
                    if len(history_values) > ind:
                        if float_convertible:
                            _update_entry_for_float_value(history_values[ind], nested_val)
                        else:
                            _update_entry_for_non_float_value(history_values[ind], nested_val)
                    else:
                        if float_convertible:
                            history_values.append(
                                {
                                    "min": nested_val,
                                    "max": nested_val,
                                    "avg": nested_val,
                                    "sum": nested_val,
                                    "count": 1,
                                    "values": {"non_floats": {"count": 0}, nested_val: {"count": 1, "ratio": 1.0}},
                                }
                            )
                        else:
                            history_values.append(
                                {
                                    "min": float("inf"),
                                    "max": float("-inf"),
                                    "count": 1,
                                    "sum": 0.0,
                                    "avg": 0.0,
                                    "values": {"non_floats": {nested_val: {"count": 1, "ratio": 1.0}, "count": 1}},
                                }
                            )
            else:
                try:
                    value = float(value)
                    float_convertible = True
                except ValueError:
                    float_convertible = False
                if len(history_values) > ind:
                    if float_convertible:
                        _update_entry_for_float_value(history_values[ind], value)
                    else:
                        _update_entry_for_non_float_value(history_values[ind], value)
                else:
                    if float_convertible:
                        history_values.append(
                            {
                                "min": value,
                                "max": value,
                                "avg": value,
                                "sum": value,
                                "count": 1,
                                "values": {"non_floats": {"count": 0}, value: {"count": 1, "ratio": 1.0}},
                            }
                        )
                    else:
                        history_values.append(
                            {
                                "min": float("inf"),
                                "max": float("-inf"),
                                "count": 1,
                                "sum": 0.0,
                                "avg": 0.0,
                                "values": {"non_floats": {value: {"count": 1, "ratio": 1.0}, "count": 1}},
                            }
                        )
    else:
        try:
            new_value = float(new_values)
            float_convertible = True
        except ValueError:
            float_convertible = False
            new_value = new_values
        if not history_values:
            if float_convertible:
                _initialize_entry_for_new_float_value(history_values, new_value)
            else:
                _initialize_entry_for_new_non_float_value(history_values, new_value)
        else:
            if float_convertible:
                _update_entry_for_float_value(history_values, new_value)
            else:
                _update_entry_for_non_float_value(history_values, new_value)


def _initialize_entry_for_new_float_value(dict_to_fill, new_value):
    dict_to_fill["count"] = 1
    dict_to_fill["min"] = new_value
    dict_to_fill["max"] = new_value
    dict_to_fill["avg"] = new_value
    dict_to_fill["sum"] = new_value
    dict_to_fill["values"] = {new_value: {"count": 1, "ratio": 1.0}, "non_floats": {"count": 0}}


def _initialize_entry_for_new_non_float_value(dict_to_fill, new_value):
    dict_to_fill["count"] = 1
    dict_to_fill["min"] = float("inf")
    dict_to_fill["max"] = float("-inf")
    dict_to_fill["avg"] = 0.0
    dict_to_fill["sum"] = 0.0
    dict_to_fill["values"] = {"non_floats": {"count": 1, new_value: {"count": 1, "ratio": 1.0}}}


def _update_entry_for_float_value(dict_to_update, new_value):
    dict_to_update["count"] += 1
    dict_to_update["min"] = min(new_value, dict_to_update["min"])
    dict_to_update["max"] = max(new_value, dict_to_update["max"])
    dict_to_update["sum"] += new_value
    if dict_to_update["values"].get(new_value, None) is None:
        dict_to_update["values"][new_value] = {"count": 1}
    else:
        dict_to_update["values"][new_value]["count"] += 1
    _update_float_average(dict_to_update)
    _update_value_ratios(dict_to_update["values"], dict_to_update["count"])


def _update_entry_for_non_float_value(dict_to_update, new_value):
    dict_to_update["count"] += 1
    dict_to_update["values"]["non_floats"]["count"] += 1
    if dict_to_update["values"]["non_floats"].get(new_value, None) is None:
        dict_to_update["values"]["non_floats"][new_value] = {"count": 1}
    else:
        dict_to_update["values"]["non_floats"][new_value]["count"] += 1
    _update_value_ratios(dict_to_update["values"], dict_to_update["count"])


def _update_float_average(dict_to_update):
    dict_to_update["avg"] = dict_to_update["sum"] / (
        dict_to_update["count"] - dict_to_update["values"]["non_floats"]["count"]
    )


def _update_value_ratios(values, all_count):
    for key, value in values.items():
        if key == "non_floats":
            _update_value_ratios(values[key], all_count)
            continue
        if key == "count":
            continue
        value["ratio"] = float(value["count"]) / all_count
