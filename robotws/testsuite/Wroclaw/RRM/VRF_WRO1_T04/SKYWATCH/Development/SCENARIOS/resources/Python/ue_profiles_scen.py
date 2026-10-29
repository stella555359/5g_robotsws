import math
from robot.libraries.BuiltIn import BuiltIn
import re
import random
import time

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def activate_beam_profile(ue_id, profile_id):
    if profile_id == "random":
        profile_id = random.randint(1, 9)
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_testmode_set_nr id={} testmode=beam_control \
                                                                action=activate profile_id={} beamaction=attach'
                                                                .format(ue_id, profile_id))
