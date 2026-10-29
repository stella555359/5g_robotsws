import importlib
import sys
import ta_xml_gate
from robot.libraries.BuiltIn import BuiltIn
import logging


def init_ta_xml():
    """
    Download/install (if needed) and import ta_xml and set it in all modules where is needed
    Each module that requires ta_ssh_telnet should define a variable named pd and set it to None:
        pd = None
    If is not initialized to None, this keyword will not do anything to that module.
    It is only required to call this keyword once from the main robot script at the beginning
    """
    # get and install ta_xml
    global tax
    tax = ta_xml_gate.install_and_import_ta_xml()

    # find all loaded modules/libs
    modulenames_set = list(set(sys.modules))
    modulenames_list = list(set([x.split('.')[0] for x in modulenames_set]))

    logging.info("=====> modulenames_set=%s" % modulenames_set)
    logging.info("=====> modulenames_list=%s" % modulenames_list)

    for modulename in modulenames_list:
        if not modulename == 'ta_xml':
            module = importlib.import_module(modulename)
            if hasattr(module, 'tax') and module.tax is None:
                module.tax = tax
                BuiltIn().log_to_console('\nta_xml set in %s Library\n' % modulename)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    init_ta_xml()
