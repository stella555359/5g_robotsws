import re
import os
import subprocess

# TSharkCommandAssembler class is migreted from robotws repository
# robotws/testsuite/Wroclaw/TRS/common_resources/rrm_keywords/resources_mem/pcap_verification/tsharkWithLuaVerifier.py
# Author Blazej Michalik; Gitlab user: @michalik


class TSharkCommandAssembler(object):
    luashark_from_ute = '/opt/luashark/luashark.lua'

    def __init__(self, tshark_path="tshark"):
        self.parameters = []
        self.grep = ""
        self.parameters.extend([tshark_path, "-V"])

    def __get_luapath(self):
        assert os.path.isfile(self.luashark_from_ute), "{} not found".format(
            self.luashark_from_ute)
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


def check_rrcReconfig_pci_cell(pcap, pci):
    """Return true if nr-rrc.physCellId is same as provided as argument of function"""
    try:
        frames = get_all_frames(
            pcap_file=pcap, lua_attached=False, ts_filter='nr-rrc.physCellId')
        rrcReconfig_pci = [get_rrcReconfiguration_pci(
            frame, pci) for frame in frames]
    except Exception:
        return False
    return True if rrcReconfig_pci[0] else False


def get_rrcReconfiguration_pci(frame, pci):
    """Return all frames containing physCellId same as provided as argument of function"""
    try:
        rrcReconfig_pci = re.findall(
            r"physCellId: {}".format(pci), str(frame))[0]
    except Exception:
        rrcReconfig_pci = False
    return rrcReconfig_pci


def check_rrcReconfigurationComplete(pcap):
    """Return true if pcap contains rrcReconfigurationComplete msg"""
    try:
        frames = get_all_frames(pcap_file=pcap,
                                lua_attached=False,
                                ts_filter='nr-rrc.RRCReconfigurationComplete_element')
        rrcReconfiguration = get_rrcReconfigurationComplete(frames)
    except Exception:
        return False
    return True if rrcReconfiguration else False


def get_rrcReconfigurationComplete(frame):
    """Return all rrcReconfigurationComplete and sgnbReconfigurationCompletion frames from pcap """
    rrcReconfigurationCompletion = re.findall(
        r"sgNBReconfigurationCompletion", str(frame))[0]
    rrcReconfigurationComplete = re.findall(
        r"rrcReconfigurationComplete", str(frame))[0]
    return rrcReconfigurationComplete, rrcReconfigurationCompletion
