#!/usr/bin/python3
import argparse
import json
import os
import telnetlib

VERBOSE = False


class DummyConn:  # for debug purposes
    def __init__(self, host, port):
        self.host = host
        self.port = port

    @staticmethod
    def read_until(expected, timeout=0):
        return expected

    @staticmethod
    def write(to_write):
        print("DummyConn: {}".format(to_write))


class Attenuator:
    get_values_cmd = ""
    max_val = 90
    set_str = ""
    set_str_pattern = "{} {} "
    expected_return = ""
    logout_comm = ""
    default_port = -1

    def __init__(self, attanuator_data):
        self.addr = attanuator_data['ip']
        try:
            self.port = attanuator_data['port']
        except KeyError:
            self.port = self.default_port
        self.sector_ports = attanuator_data['sectors']
        try:
            self.vendor = attanuator_data['vendor']
        except KeyError:
            self.vendor = "Vendor not provided"
        self.conn = telnetlib.Telnet(host=self.addr, port=self.port)
        # self.conn = DummyConn(host=self.addr, port=self.port)

    def __del__(self):
        self.conn.write("{}\r\n".format(self.logout_comm).encode("utf-8"))

    def get_all_values(self):
        ret = self._send_command_and_read(self.get_values_cmd)
        return ret

    def set_values(self, sector, value):
        value = int(value)
        if value > self.max_val or value < 0:
            print("Value out of range (0-{})".format(self.max_val))
            if value > self.max_val:
                value = self.max_val
            elif value < 0:
                value = 0
        set_command = self._make_set_str(sector, value)
        buff = self._send_command_and_read(set_command)
        if VERBOSE:
            print(buff)

    def _make_set_str(self, sector, value):
        buff = self.set_str
        for el in self.sector_ports[sector]:
            buff = buff + self.set_str_pattern.format(el, value)
        if VERBOSE:
            print(buff)
        return buff

    def _send_command_and_read(self, command):
        self.conn.write("{}\r\n".format(command).encode("utf-8"))
        buff = self.conn.read_until(self.expected_return, timeout=1)
        return buff.decode("utf-8")

    def _generate_command_to_attenuate_all_configured_ports(self, sectors):
        cmd_el = []
        for key in sectors:
            for el in sectors[key]:
                if el not in cmd_el:
                    cmd_el.append(el)
        cmd_el.sort()
        cmd = self.set_str
        for el in cmd_el:
            cmd = cmd + " " + str(el) + " {att}"
        return cmd


class AttenuatorJFW(Attenuator):
    get_values_cmd = "raa"
    max_val = 63
    set_str = "sa "
    set_str_pattern = "{} {} "
    expected_return = b"JFW>> "
    logout_comm = "dis"
    default_port = 3001

    def __init__(self, attanuator_data):
        super().__init__(attanuator_data)
        self.att_all_cmd = self._generate_command_to_attenuate_all_configured_ports(attanuator_data['sectors'])
        buff = self.conn.read_until(self.expected_return, timeout=1)
        if buff and VERBOSE:
            print("Successfully logged to {}".format(self.addr))

    def get_sector_values(self, sector):
        ret = self._send_command_and_read(self.get_values_cmd).split()
        vals = [el[:-2] for el in ret if el.endswith("dB")]
        ret = []
        for el in self.sector_ports[sector]:
            ret.append(vals[el - 1])
        return ret

    def set_values_at_all(self, value):
        value = int(value)
        if value > self.max_val or value < 0:
            print("Value out of range (0-{})".format(self.max_val))
            if value > self.max_val:
                value = self.max_val
            elif value < 0:
                value = 0
        set_command = self.att_all_cmd.format(att=value)
        buff = self._send_command_and_read(set_command)
        if VERBOSE:
            print(buff)

    def set_full_att(self):
        set_command = self.att_all_cmd.format(att=self.max_val)
        buff = self._send_command_and_read(set_command)
        if VERBOSE:
            print(buff)

    def _send_command_and_read(self, command):
        self.conn.write("{}\r\n".format(command).encode("utf-8"))
        buff = self.conn.read_until(self.expected_return, timeout=1)
        return buff[:-6].decode("utf-8")


class AttenuatorRadiorack(Attenuator):
    # newer version, no prompt
    get_values_cmd = "ATT"
    max_val = 440
    set_str = "ATT "
    set_str_pattern = "{} {} "
    expected_return = b"SYNTAX ERROR:"
    logout_comm = "QUIT"
    default_port = 23  # or 50000?

    def __init__(self, attanuator_data):
        super().__init__(attanuator_data)
        self.att_all_cmd = self._generate_command_to_attenuate_all_configured_ports(attanuator_data['sectors'])
        buff = self.conn.read_until(self.expected_return, timeout=1)
        if buff and VERBOSE:
            print("Successfully logged to {}".format(self.addr))

    def get_sector_values(self, sector):
        vals = self._send_command_and_read(self.get_values_cmd).split(";")
        ret = []
        for el in self.sector_ports[sector]:
            ret.append(vals[el - 1])
        return ret

    def set_values_at_all(self, value):
        value = int(value)
        if value > self.max_val or value < 0:
            print("Value out of range (0-{})".format(self.max_val))
            if value > self.max_val:
                value = self.max_val
            elif value < 0:
                value = 0
        set_command = self.att_all_cmd.format(att=value)
        buff = self._send_command_and_read(set_command)
        if VERBOSE:
            print(buff)

    def set_full_att(self):
        set_command = self.att_all_cmd.format(att=self.max_val)
        buff = self._send_command_and_read(set_command)
        if VERBOSE:
            print(buff)

    # def _send_command_and_read(self, command):
    #     self.conn.write("{}\r\n".format(command).encode("utf-8"))
    #     buff = self.conn.read_until(self.expected_return, timeout=1)
    #     return buff.decode("utf-8")


class AttenuatorRadiorackOld(AttenuatorRadiorack):
    # for older sw version, v1.4.150305
    # Has prompt Radio Rack>
    get_values_cmd = "ATT"
    number_of_ports = 8
    expected_return = b"Radio Rack> "

    def __init__(self, attanuator_data):
        super().__init__(attanuator_data)

    def _send_command_and_read(self, command):
        self.conn.write("{}\r\n".format(command).encode("utf-8"))
        buff = self.conn.read_until(self.expected_return, timeout=1)
        return buff[:-14].decode("utf-8")


class AttenuatorTopyoung(Attenuator):
    max_val = 90
    get_values_cmd = "raa"
    set_str = "sma "
    set_str_pattern = "{} {},"
    expected_return = b"Error1"
    default_port = 23  # or 50000?

    def __init__(self, attanuator_data):
        super().__init__(attanuator_data)
        buff = self.conn.read_until(self.expected_return, timeout=1)
        if buff and VERBOSE:
            print(buff)

    def get_sector_values(self, sector):
        # sector = int(sector)
        ret = self._send_command_and_read(self.get_values_cmd).split()
        vals = [el[:-2] for el in ret if el.endswith("dB")]
        ret = []
        for el in self.sector_ports[sector]:
            ret.append(vals[el - 1])
        return ret

    def set_full_att(self):
        set_command = "saa {}".format(self.max_val)
        # to check: set_command = self.att_all_cmd.format(att=self.max_val)
        buff = self._send_command_and_read(set_command)
        if VERBOSE:
            print(buff)

    # def _send_command_and_read(self, command):
    #     self.conn.write("{}\r\n".format(command).encode("utf-8"))
    #     buff = self.conn.read_until(self.expected_return, timeout=1)
    #     return buff.decode("utf-8")


supported_attenutors = {
    "AttenuatorTopyoung": AttenuatorTopyoung,
    "AttenuatorJFW": AttenuatorJFW,
    "AttenuatorRadiorack": AttenuatorRadiorack,
    "AttenuatorRadiorackOld": AttenuatorRadiorackOld
}


def fade_sector(fade, sec_mapping):
    from time import sleep
    [sector, start_value, stop_value, step, delay] = fade
    atts = sec_mapping[sector]
    if stop_value < start_value:
        step = -step

    for i in range(start_value, stop_value, step):
        for att in atts:
            att.set_values(sector, i)
        sleep(delay)
    for att in atts:
        att.set_values(sector, stop_value)


def map_sectors(att_datas):
    mapping = {}
    for el in att_datas:
        for sec in el.sector_ports:
            try:
                mapping[sec].append(el)
            except KeyError:
                mapping[sec] = [el]
    sorted_keys = sorted(mapping)
    mapping2 = {}
    for key in sorted_keys:
        mapping2[key] = mapping[key]

    return mapping2


def init_attens(config_path):
    with open(file=config_path) as json_str:
        data = json.load(json_str)

    ret_list = [supported_attenutors[data[el]['vendor']](data[el]) for el in data]
    return ret_list


def run(args, att_list):
    sector_mapping = map_sectors(att_list)

    if args.full:
        print("Set full attenuation")
        for att in att_list:
            att.set_full_att()

    if args.set_all:
        print("Set attenuation [{}] at all ports".format(args.set_all))
        for att in att_list:
            att.set_values_at_all(args.set_all)

    if args.set:
        calculated_len = (len(args.set) // 2) * 2  # to get lower even number if odd given
        if VERBOSE and calculated_len != len(args.set):
            print("Get odd number of arguments, ignoring last [{}].".format(args.set[-1]))
        for i in range(0, calculated_len, 2):
            sector = args.set[i]
            value = args.set[i + 1]
            print("Set sector {sec} to: {val}".format(sec=sector, val=value))
            atts = sector_mapping[sector]
            for att in atts:
                att.set_values(sector, value)

    if args.fade:
        fade_sector(args.fade, sector_mapping)

    if args.val:
        ret = []
        sector = args.val
        atts = sector_mapping[sector]
        for att in atts:
            ret1 = att.get_sector_values(sector)
            for el in ret1:
                ret.append(el.split(" ")[-1])
            print("Sector {} values: {}".format(args.val, ret))

    if args.get_all:
        for sector in sector_mapping.keys():
            atts = sector_mapping[sector]

            for att in atts:
                ret = []
                ret1 = att.get_sector_values(sector)
                for el in ret1:
                    ret.append(el.split(" ")[-1])
                print("Sector {} values: {}".format(sector, ret))

    if not (args.full or args.set or args.val or args.get_all or args.fade or args.set_all):
        for att in att_list:
            print(att.get_all_values())


def show_config(att_list):
    from pprint import pprint
    print("Printing configuration:")
    for el in att_list:
        print("{ven} at IP: {ip}:{port}".format(ven=el.vendor, ip=el.addr, port=el.port))
        pprint(el.sector_ports)
        print("")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--full", "-f", action="store_true", help="Set full attenuation on all ports")
    parser.add_argument("--set", "-s", help="Set attenuation values for sector [sector value]", nargs='+')
    parser.add_argument("--val", "-v", help="Get attenuation values for sector")
    parser.add_argument("--get_all", "-a", action="store_true", help="Get attenuation values for all sectors")
    parser.add_argument("--set_all", "-A", help="Set attenuation values for all sectors")
    parser.add_argument("--fade", help="Fade sector [sector start_value stop_value step delay]", nargs=5)
    parser.add_argument("--config", "-c", default="att_control_config.json", help="Get attenuation values for sector")
    parser.add_argument("--show_config", "-S", action="store_true", help="Print configuration")
    parser.add_argument("--verbose", "-V", action="store_true", help="Print more logs to console")
    arguments = parser.parse_args()
    if arguments.verbose:
        VERBOSE = True

    # FIXME 1: define ports
    example = {
        "cell/sector number": ["port numbers"],
        '3': [5, 6, 7, 8],
        '5': [13, 14, 15, 16],
        '6': [1, 2, 3, 4]
    }

    sector_radiorack_16 = {
        '2': [1, 2, 3, 4],
        '302': [5, 6, 7, 8]
    }

    # FIXME 2: define IP, ports and sectors

    # addr = "att-zf03-16-p04.p04-leg.ska-lab.nsn-rdnet.net"
    att1_data = {'ip': '10.255.13.188', 'port': 50000, 'sectors': sector_radiorack_16}

    if os.path.exists(arguments.config):
        atten_list = init_attens(arguments.config)
    else:
        print("Can't read confing file, using hardcoded.")
        # FIXME 3: initialize all the attenuators
        atten_list = [AttenuatorRadiorack(att1_data)]

    if arguments.show_config:
        show_config(atten_list)
        exit(0)

    run(arguments, atten_list)

    # TODO: before first run define values in FIXME 1-3
    # FIXME: change connection lines 93-94

    # TODO: add crossfade (range for one cell and between two)
