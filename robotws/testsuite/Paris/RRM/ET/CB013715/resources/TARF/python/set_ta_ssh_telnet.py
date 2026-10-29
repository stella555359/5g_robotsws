import importlib
import sys
import ta_ssh_telnet_gate
from robot.libraries.BuiltIn import BuiltIn
import logging


def init_ta_ssh_telnet():
    """
    Download/install (if needed) and import ta_ssh_telnet and set it in all modules where is needed
    Each module that requires ta_ssh_telnet should define a variable named pd and set it to None:
        pd = None
    If is not initialized to None, this keyword will not do anything to that module.
    It is only required to call this keyword once from the main robot script at the beginning
    """
    # get and install ta_ssh_telnet
    global tad
    tad = ta_ssh_telnet_gate.install_and_import_ta_ssh_telnet()

    # find all loaded modules/libs
    modulenames_set = list(set(sys.modules))
    modulenames_list = list(set([x.split('.')[0] for x in modulenames_set]))

    logging.info("=====> modulenames_set=%s" % modulenames_set)
    logging.info("=====> modulenames_list=%s" % modulenames_list)

    for modulename in modulenames_list:
        if not modulename == 'ta_ssh_telnet':
            module = importlib.import_module(modulename)
            if hasattr(module, 'tad') and module.tad is None:
                module.tad = tad
                BuiltIn().log_to_console('ta_ssh_telnet set in %s Library' % modulename)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    init_ta_ssh_telnet()
