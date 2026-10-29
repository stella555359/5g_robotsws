#############################################################################
#               Script is made for power managment of BTS PDU               #
#                      Supported PDU types: FPFH, HPE                       #
#                     Author: szymon.mastalski@nokia.com                    #
#                       (c) Copyright 2023 Nokia                            #
#############################################################################
import sys
import socket
import importlib
import argparse
from taf.hw.pdu import pdu


TESTLINE_CONFIGURATION_DIR = "/home/ute/Auto5G/robotws/testline_configuration/"


class bcolors(object):
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKCYAN = "\033[96m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"


def parser():
    """
    Gets arguments provided in command line and return them
    :return: Parsed arguments
    """
    args_parser = argparse.ArgumentParser(
        prog="SPM.py",
        description="Script for managing BTS PDUs, "
        "BTS configuration file is taken from __init__.py at: "
        "home/ute/Auto5G/robotws/testline_configuration/"
        "[current_testline]\nTo work porperly init.py should"
        "have common unit and radio unit objects "
        "with configurated pdu_port atribute.\n"
        "Example usage:\n"
        "python ./SPM.py -g on (Turn on all gNB units)\n"
        "python ./SPM.py -e -r off (Turn off all radio units on eNB)\n"
        "python ./SPM.py check_status (Show current FPFH configuration imported from __init__.py) \n",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    args_parser.add_argument(
        "-g", "--gnb", help="Manage gNB PDU(Common unit + RUs)", action="store_true"
    )
    args_parser.add_argument(
        "-e", "--enb", help="Manage eNB PDU(Common unit + RUs)", action="store_true"
    )
    args_parser.add_argument(
        "-r",
        "--radio_units",
        help="Manage only Radio units conected to BTS",
        action="store_true",
    )
    args_parser.add_argument(
        "action",
        choices=["on", "off", "status", "check_config"],
        help="Operation to perform on selected BTS part, check_config - show imported pdu configuration",
    )
    args = args_parser.parse_args()
    return args


def print_message(message):
    """
    Print passed string

    :param message: message to print
    """
    print(message)


class SPM:
    """
    Site power menager class, for menaging PDUs specyfied
    in __init__.py testline configuration file

    :param vm_name: virtual machine hostname
    :param tl_name: testline name
    :param tl: imported testline configuration
    :param tl_dict: dictionary with units and their PDUs
    :type tl_dict: dictionary with unit object and pdu object

    """

    def __init__(self):
        self.vm_name = self.get_vm_hostname()
        self.tl_name = self.get_tl_name(self.vm_name)
        self.tl = self.import_tl_config(self.tl_name)
        self.tl_dict = self.get_tl_dict()

    def get_vm_hostname(self):
        """
        Get virtual machine hostname

        :return: virtual machine hostname
        """
        return socket.gethostname().upper()

    def get_tl_name(self, vm_name):
        """
        Get testline name based on vm hostname

        :param vm_name - virtual machine hostname
        :return: Testline name
        """
        return "_".join(vm_name.split("-")[:3])

    def import_tl_config(self, tl_name):
        """
        Import testline configuration from specified path as module

        :return: imported testline configuration
        """
        sys.path.append(TESTLINE_CONFIGURATION_DIR)
        tl_config = importlib.import_module(tl_name)
        return tl_config.tl

    def _get_ru_pdu(self, ru):
        """
        Get PDU object connected to passed radio unit

        :ru radio unit object
        :return: Dictionary element with ru object and pdu or none
        """
        if ru.pdu_port:
            return {ru: self.pdu_setup(ru.pdu_port.pdu)}
        else:
            print_message("PDU port not configured for RUs")

    def _get_common_unit_pdu(self, c_unit):
        """
        Get PDU object and common unit connected to passed Bts object

        :c_unit common unit object
        :return: Dictionary element with ru object and pdu or none
        """
        if c_unit.pdu_port:
            return {c_unit: self.pdu_setup(c_unit.pdu_port.pdu)}
        else:
            print_message("PDU port not configured for Common Unit")

    def _get_gnb_config(self):
        """
        Get dictionary with gNB units and related PDU object

        :return: dictionary with gNB configuration or None
        """
        gnb_dict = {}
        if self.tl.gnbs:
            if self.tl.gnbs[0].dus[0].airscale.common_units:
                c_units = self.unify_values(
                    self.tl.gnbs[0].dus[0].airscale.common_units
                )
                for c_unit in c_units:
                    gnb_dict.update(self._get_common_unit_pdu(c_unit))
            else:
                print_message(
                    f"{bcolors.FAIL}No Common Unit config for gNB{bcolors.ENDC}"
                )
            if self.tl.gnbs[0].dus[0].rus:
                rus = self.unify_values(self.tl.gnbs[0].dus[0].rus)
                for ru in rus:
                    gnb_dict.update(self._get_ru_pdu(ru))
            if gnb_dict:
                return gnb_dict
        else:
            return None

    def _get_enb_config(self):
        """
        Get dictionary with eNB units and related PDU object

        :return: dictionary with eNB configuration or None
        """
        enb_dict = {}
        if self.tl.enbs:
            if self.tl.enbs[0].system_module:
                if self.tl.enbs[0].system_module.common_units:
                    smods = self.unify_values(
                        self.tl.enbs[0].system_module.common_units
                    )
                    for smod in smods:
                        enb_dict.update(
                            self._get_common_unit_pdu(
                                smod,
                            )
                        )
            if self.tl.enbs[0].rms:
                rus = self.unify_values(self.tl.enbs[0].rms)
                for ru in rus:
                    enb_dict.update(
                        self._get_ru_pdu(
                            ru,
                        )
                    )
            if enb_dict:
                return enb_dict
        else:
            return None

    def unify_values(self, values):
        """
        Get values passed as list or int and turn them into list

        :values value to convert
        :return: return value turned into a list
        """
        if not isinstance(values, list):
            values = [values]
        unified_values = []
        for value in values:
            unified_values.append(value)
        if len(unified_values) == 0:
            return None
        else:
            return unified_values

    def get_tl_dict(self):
        """
        Get gNB and eNB configuration as dictionary and save it to dictionary

        :return: Dictionary with bts type string and bts dictionary
        """
        tl_dict = {}
        gnb = self._get_gnb_config()
        enb = self._get_enb_config()
        if gnb:
            tl_dict["gnb"] = gnb
        if enb:
            tl_dict["enb"] = enb

        return tl_dict

    def pdu_setup(self, pdu_):
        """
        Setup pdu object based on config from testline configuration file

        :param pdu_ pdu object from testline configuration
        :return: pdu object
        """
        if pdu_.vendor == "HPE":
            pdu_o = pdu()
            pdu_o.setup_pdu(
                model=pdu_.vendor,
                host=pdu_.addr,
                snmp_user=pdu_.snmp_user,
                alias=pdu_.addr,
            )
            return pdu_o
        else:
            pdu_o = pdu()
            pdu_o.setup_pdu(model=pdu_.vendor, host=pdu_.addr, alias=pdu_.addr)
            return pdu_o

    def port_status_get(self, pdu_, ports, alias):
        """
        Get status of passed ports on pdu

        :pdu_ pdu object
        :ports port numbers as list
        :alias pdu name
        :return: Dictionary with statuses port_numonber : status
        """
        status_dict = {}
        for port in ports:
            status_dict[port] = pdu_.get_port_status(port, pdu_device=alias)
        return status_dict

    def port_turn_off(self, pdu_, ports, alias):
        """
        Turn off passed port on pdu
        :pdu_ pdu object
        :ports port number as list
        :alias pdu name
        :return: None
        """
        for port in ports:
            if pdu_.get_port_status(port, pdu_device=alias) == "on":
                pdu_.power_off(port, pdu_device=alias)
                print_message(f"Port {port} is now off")
            else:
                print_message(f"Port {port} is already turned off")

    def port_turn_on(self, pdu_, ports, alias):
        """
        Turn on passed port on pdu

        :pdu_ pdu object
        :ports port number
        :alias pdu name
        :return: None
        """
        for port in ports:
            if pdu_.get_port_status(port, pdu_device=alias) == "off":
                pdu_.power_on(port, pdu_device=alias)
                print_message(f"Port {port} is now on")
            else:
                print_message(f"Port {port} is already turned on")

    def bts_turn_off(self, bts):
        """
        Turn off pdus for passed bts

        :bts bts name as string
        :return: None
        """
        for device, pdu_ in self.tl_dict[bts].items():
            print_message(f"Turning off {device.__class__.__name__} on {bts}:")
            ports = self.unify_values(device.pdu_port.port_no)
            alias = device.pdu_port.pdu.addr
            self.port_turn_off(pdu_, ports, alias)

    def bts_turn_on(self, bts):
        """
        Turn on pdus for passed bts

        :bts bts name as string
        :return: None
        """
        for device, pdu_ in self.tl_dict[bts].items():
            print_message(f"Turning on {device.__class__.__name__} on {bts}: ")
            ports = self.unify_values(device.pdu_port.port_no)
            alias = device.pdu_port.pdu.addr
            self.port_turn_on(pdu_, ports, alias)

    def bts_get_status(self, bts):
        """
        Get pdu status for passed bts

        :bts bts name as string
        :return: None
        """
        for device, pdu_ in self.tl_dict[bts].items():
            print_message(f"Status of {device.__class__.__name__} on {bts}:")
            ports = self.unify_values(device.pdu_port.port_no)
            alias = device.pdu_port.pdu.addr
            if ports:
                print_message(self.port_status_get(pdu_, ports, alias))

    def ru_turn_on(self, bts):
        """
        Turn on pdus for all Radio units on bts

        :bts bts name as string
        :return: None
        """
        if any(
            device.__class__.__name__ == "RU" for device in self.tl_dict[bts].keys()
        ):
            for device, pdu_ in self.tl_dict[bts].items():
                if device.__class__.__name__ == "RU":
                    print_message("turning on all radio units...")
                    ports = self.unify_values(device.pdu_port.port_no)
                    alias = device.pdu_port.pdu.addr
                    self.port_turn_on(pdu_, ports, alias)
        else:
            print_message(f"{bcolors.FAIL}No RUs configuration{bcolors.ENDC}")

    def ru_turn_off(self, bts):
        """
        Turn off pdus for all Radio units on bts

        :bts bts name as string
        :return: None
        """
        if any(
            device.__class__.__name__ == "RU" for device in self.tl_dict[bts].keys()
        ):
            for device, pdu_ in self.tl_dict[bts].items():
                if device.__class__.__name__ == "RU":
                    print_message("turning off all radio units...")
                    ports = self.unify_values(device.pdu_port.port_no)
                    alias = device.pdu_port.pdu.addr
                    self.port_turn_off(pdu_, ports, alias)
        else:
            print_message(f"{bcolors.FAIL}No RUs configuration{bcolors.ENDC}")

    def show_config(self):
        """
        Show current configuration importet from __init.py__

        :return: None
        """
        print_message("Imported configuration:")
        for bts, pdu in self.tl_dict.items():
            for key in pdu:
                print_message(
                    f"{bts}, {key.__class__.__name__} --> port:{key.pdu_port.port_no} on {key.pdu_port.pdu.addr}"
                )


def main():
    """
    Main program funcion, call funcion based on arguments
    passed in command line

    :return: None
    """
    smp = SPM()
    args = parser()

    if args.action == "check_config":
        smp.show_config()
        exit(0)

    if args.gnb:
        bts = "gnb"
        try:
            smp.tl_dict[bts]
        except KeyError:
            print_message(f"{bcolors.FAIL}Wrong or no gNB configuration!{bcolors.ENDC}")
            exit(1)
    elif args.enb:
        bts = "enb"
        try:
            smp.tl_dict[bts]
        except KeyError:
            print_message(f"{bcolors.FAIL}Wrong or no eNB configuration!{bcolors.ENDC}")
            exit(1)
    elif args.enb and args.gnb:
        print_message(f"{bcolors.FAIL}Choose one BTS at a time!{bcolors.ENDC}")
        exit(1)
    elif not (args.enb and args.gnb):
        print_message(
            f"{bcolors.FAIL}Choose BTS to manage (with using -g or -e flag, use -h for more information){bcolors.ENDC}"
        )
        exit()
    if args.radio_units:
        if args.action == "on":
            smp.ru_turn_on(bts)
        if args.action == "off":
            smp.ru_turn_off(bts)
        if args.action == "status":
            smp.bts_get_status(bts)
    else:
        if args.action == "on" and bts:
            smp.bts_turn_on(bts)
        if args.action == "off" and bts:
            smp.bts_turn_off(bts)
        if args.action == "status" and bts:
            smp.bts_get_status(bts)


if __name__ == "__main__":
    main()
