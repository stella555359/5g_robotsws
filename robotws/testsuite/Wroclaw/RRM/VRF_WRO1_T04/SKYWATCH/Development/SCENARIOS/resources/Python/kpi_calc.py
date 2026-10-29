import math
from robot.libraries.BuiltIn import BuiltIn
import re
import random
import time

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def calculate_NR_5101b(M55309C02001, M55308C02002, M55308C00009, M55308C00006):
    return ((8 * M55309C02001) / (M55308C02002 * M55308C00009 / M55308C00006))


def calculate_NR_5400b(M55124C00510, M55124C00511, M55124C00512, M55124C00515,
                       M55124C00503, M55124C00504, M55124C00505):
    return ((100 * (M55124C00510 + M55124C00511 + M55124C00512 + M55124C00515)) /
            (M55124C00503 + M55124C00504 + M55124C00505))
