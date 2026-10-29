# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


def import_ucl():
    """
    An internal function which helps to indetify keyword(s) from Ulm's Common Library
    which are not yet called via "kwrun".
    Steps:
    1. comment out 'Resource' lines in common_keywords.robot
    2. add the 'import_ucl()' call at the end of this file
    3. run dryrun
    4. analyse the exceptions, note that some keywords called from feature related .robot files
    """
    BuiltIn().import_resource("../../../resources/Common/connect.robot")
    BuiltIn().import_resource("../../../resources/Common/core.robot")
    BuiltIn().import_resource("../../../resources/Common/ttitrace.robot")
    BuiltIn().import_resource("../../../resources/Common/testline.robot")
    BuiltIn().import_resource("../../../resources/Common/gnb.robot")
    BuiltIn().import_resource("../../../resources/Common/util.robot")
    BuiltIn().import_resource("../../../resources/Common/commissioning.robot")
    BuiltIn().import_resource("../../../resources/Common/pmcounters.robot")
    BuiltIn().import_resource("../../../resources/Common/tcpdump.robot")
    BuiltIn().import_resource("../../../resources/Common/btslog.robot")
    BuiltIn().import_resource("../../../resources/Common/ute_workarounds.robot")
    BuiltIn().import_resource("../../../resources/Common/wts_ue.robot")
    BuiltIn().import_resource("../../../resources/Common/snapshot.robot")
    BuiltIn().import_resource("../../../resources/Common/reporting.robot")


def kwrun(kwname, *args):
    """
    WARNING: please avoid usage of this KW outside of the TEAL Framework .robot files
    A wrapper function that takes in a keyword from Ulm's Common Library and
    its arguments and returns the result of the function call.
    """
    return BuiltIn().run_keyword(kwname, *args)
