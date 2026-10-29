import resources.Macro.Python.utilities as utilities
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
import os
from collections import Counter


def pucch_resource_num(pucch_Resource):
    resource_num = list(set(pucch_Resource))
    return len(resource_num)
