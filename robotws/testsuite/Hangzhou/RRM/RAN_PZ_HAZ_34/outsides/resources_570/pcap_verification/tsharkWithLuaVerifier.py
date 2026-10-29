import os
import subprocess


class TSharkCommandAssembler(object):
    luashark_from_ute = '/home/ute/luashark/generated_luashark/luashark.lua'

    def __init__(self, tshark_path="tshark"):
        self.parameters = []
        self.grep = ""
        self.parameters.extend([tshark_path, "-V"])

    def __get_luapath(self):
        assert os.path.isfile(self.luashark_from_ute), "{} not found".format(self.luashark_from_ute)
        return self.luashark_from_ute

    def __parse_log(self, input_string):
        return [str(line) for line in input_string.splitlines() if self.grep in line]

    def with_lua_scripts(self, lua_path):
        self.parameters.extend(["-X", "lua_script:" + lua_path])
        return self

    def with_attached_lua_scripts(self):
        self.parameters.extend(["-X", "lua_script:" + self.__get_luapath()])
        return self

    def with_filter(self, wireshark_filter):
        self.parameters.extend(["-Y", wireshark_filter])
        return self

    def with_pcap_file(self, pcap_file):
        self.parameters.extend(["-r", pcap_file])
        return self

    def with_specified_parameter(self, parameter_name):
        self.parameters.extend(["-o", parameter_name])
        return self

    def grep_log(self, grep_filter):
        self.grep = grep_filter
        return self

    def inject_additional_parameters(self, params):
        self.parameters.extend(params.split(' '))
        return self

    def build(self):
        params = self.parameters
        print(' '.join(i for i in params))
        self.parameters = []
        try:
            return self.__parse_log(subprocess.check_output(params).decode("utf-8"))
        except subprocess.CalledProcessError as e:
            return [str(line) for line in e.output.splitlines()]


def get_parameter_value_from_command_output(output, parameter):
    return get_value_from_log_line(get_log_line_from_output(output, parameter))


def get_value_from_log_line(log_line):
    assert log_line, 'Log is missing'
    tmp = [i for i in log_line if ":" in i]
    if tmp[0]:
        return tmp[0].split(":", 1)[1].strip()


def get_log_line_from_output(output, pattern):
    return filter(lambda x: pattern in x, output)


def get_log_line_number_from_output(output, pattern):
    return [x[0] for x in filter(lambda y: pattern in y[1], enumerate(output))]


def remove_luashark_loading_from_output(output):
    tmp = [i for i, e in enumerate(output) if '-----------' in e]
    if len(tmp) == 2:
        last_idx = [i for i, e in enumerate(output) if '-----------' in e][-1]
        return output[last_idx + 1:]
    return output


def get_count_of_each_parameter_from_list(param_list, percent_margin_of_error=0):
    params_count = {}
    for param in set(param_list):
        count = param_list.count(param)
        if count > ((float(percent_margin_of_error) * len(param_list)) / 100):
            params_count[param] = count
    return params_count


def split_output_into_frames(output):
    indexes = []
    ret = []
    for idx, line in enumerate(output):
        if all(substr in line for substr in ["Frame", "bytes on wire", "bytes captured"]):
            indexes.append(idx)
    assert len(indexes), "output does not contain any frames"
    for i in range(len(indexes) - 1):
        ret.append(output[indexes[i]:indexes[i+1] - 1])
    ret.append(output[indexes[-1]:])
    return ret


def get_filtered_tshark_output_as_frames(pcap_file, tshark_filter):
    output = TSharkCommandAssembler() \
        .with_attached_lua_scripts() \
        .with_filter(tshark_filter) \
        .with_pcap_file(pcap_file) \
        .build()
    output = remove_luashark_loading_from_output(output)
    return split_output_into_frames(output)


def get_msg_sent_in_given_slot_from_output(output, frame_msgtype, sfn, slot):
    i = 0
    while i < len(output):
        if get_icom_5g_frame_msgtype(output[i]) == frame_msgtype:
            if get_parameter_value_from_command_output(output[i], "slot (") == slot and \
               get_parameter_value_from_command_output(output[i], "sfn (") == sfn:
                return output[i]
        i += 1
    return None


def get_icom_5g_frame_msgtype(frame):
    line = get_log_line_number_from_output(frame, "ICOM 5G Protocol")
    if not line or line[0] + 1 >= len(frame):
        return None
    return frame[line[0] + 1].strip().split()[0]


'''
usage:
    test = TSharkCommandAssembler()
    output = test.with_attached_lua_scripts()\
        .with_filter("itf_l2_ps_SystemInfoConfigurationReq_t.encodedL3MsgPayloadValues.encodedL3MsgPayloadValues")\
        .with_pcap_file("/tmp/cprt14_06.pcap")\
        .grep_log("Block")\
        .build()
    print output
'''


def get_tshark_output(pcap_file,
                      lua_path=False,
                      lua_attached=False,
                      ts_filter=False,
                      additional_parameters=False):
    ''' builds tshark command and returns its output '''
    command = TSharkCommandAssembler().with_pcap_file(pcap_file)
    if lua_path:
        command.with_lua_scripts(lua_path)
    if lua_attached:
        command.with_attached_lua_scripts()
    if ts_filter:
        command.with_filter(ts_filter)
    if additional_parameters:
        command.inject_additional_parameters(additional_parameters)
    output = command.build()
    return output


def get_all_frames(pcap_file, lua_attached, ts_filter):
    """
    returns all frames from pcap,
    """
    return split_output_into_frames(
        get_tshark_output(
            pcap_file=pcap_file,
            lua_attached=lua_attached,
            ts_filter=ts_filter
        )
    )


def get_parameter(parameter, frame):
    try:
        return get_parameter_value_from_command_output(frame, parameter)
    except Exception:
        return False


def filter_frames(by=None, val=None, frames=None):
    '''
    filters frames by 'parameter' | 'string' with value
    for 'parameter' like: ('slot', '0x22')
    for 'string'    like: 'xqwzts'
    '''
    if by == 'parameter':
        return get_frames_containing_param(param=val[0], val=val[1], frames=frames)
    elif by == 'string':
        return get_frames_containing_string(pattern=val, frames=frames)


def get_frames_containing_param(param, val, frames):
    ''' filters frames by parameter with value '''
    def f(frame):
        if get_parameter(parameter=param, frame=frame) == val:
            return True
        return False
    return filter(f, frames)


def get_frames_containing_string(pattern, frames):
    """ returns frames that contain string """
    out = []
    for frame in frames:
        for line in frame:
            if pattern in str(line):
                out.append(frame)
                break
    return out
