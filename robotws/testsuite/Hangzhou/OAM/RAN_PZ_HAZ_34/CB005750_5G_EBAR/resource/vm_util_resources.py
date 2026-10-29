# ----------------------------------------------------------------------
#
# File: vm_util_resources.py
#
# Set of keywords for general purpose.
#
# ----------------------------------------------------------------------

import os
import sys
import re
import json
import requests
import datetime
import glob

from shutil import copyfile
from jsonpointer import resolve_pointer
from robot.utils import (is_falsy)
from robot.api import logger as streamer
from requests.packages.urllib3.exceptions import InsecureRequestWarning


# ----------------------------------------------------------------------
# CLASS vm_util_resources
# ----------------------------------------------------------------------

class vm_util_resources(object):

    # ------------------------------------------------------------------
    # Robot Framework keywords.
    # ------------------------------------------------------------------

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0'

    # ------------------------------------------------------------------
    # Constructor / initializer.
    # ------------------------------------------------------------------

    def __init__(self):
        pass

    # ------------------------------------------------------------------
    # METHOD puts
    # ------------------------------------------------------------------

    def puts(self, message, stream='STDOUT', no_newline=False):
        streamer.console(message, newline=is_falsy(no_newline), stream=stream)


# End of CLASS vm_util_resources.


# ----------------------------end-of-file-------------------------------
