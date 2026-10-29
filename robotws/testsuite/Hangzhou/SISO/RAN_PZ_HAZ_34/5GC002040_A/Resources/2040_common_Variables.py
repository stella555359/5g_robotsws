# -*- coding: utf-8 -*
import os

ATTENUATION_VALUE_DEFAULT = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}
# good
ATTENUATION_VALUE_DL_GOOD_1 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

# middle
ATTENUATION_VALUE_DL_MID_1 = {
    'atten_value_of_port0': 25,
    'atten_value_of_port1': 45,
    'atten_value_of_port2': 25,
    'atten_value_of_port3': 45
}

# bad
ATTENUATION_VALUE_DL_BAD_1 = {
    'atten_value_of_port0': 45,
    'atten_value_of_port1': 75,
    'atten_value_of_port2': 45,
    'atten_value_of_port3': 75
}

ATTENUATION_VALUE_DL_GOOD_3 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

# middle
ATTENUATION_VALUE_DL_MID_3 = {
    'atten_value_of_port0': 25,
    'atten_value_of_port1': 45,
    'atten_value_of_port2': 25,
    'atten_value_of_port3': 45
}

# bad
ATTENUATION_VALUE_DL_BAD_3 = {
    'atten_value_of_port0': 45,
    'atten_value_of_port1': 75,
    'atten_value_of_port2': 45,
    'atten_value_of_port3': 75
}

# good
ATTENUATION_VALUE_DL_GOOD_4 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

# middle
ATTENUATION_VALUE_DL_MID_4 = {
    'atten_value_of_port0': 35,
    'atten_value_of_port1': 35,
    'atten_value_of_port2': 35,
    'atten_value_of_port3': 35
}

# bad
ATTENUATION_VALUE_DL_BAD_4 = {
    'atten_value_of_port0': 65,
    'atten_value_of_port1': 65,
    'atten_value_of_port2': 65,
    'atten_value_of_port3': 65
}

ATTENUATION_VALUE_DL_GOOD_5 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

# middle
ATTENUATION_VALUE_DL_MID_5 = {
    'atten_value_of_port0': 8,
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 8,
    'atten_value_of_port3': 20
}

# bad
ATTENUATION_VALUE_DL_BAD_5 = {
    'atten_value_of_port0': 25,
    'atten_value_of_port1': 45,
    'atten_value_of_port2': 25,
    'atten_value_of_port3': 45
}

# good
ATTENUATION_VALUE_DL_GOOD_6 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

# middle
ATTENUATION_VALUE_DL_MID_6 = {
    'atten_value_of_port0': 25,
    'atten_value_of_port1': 45,
    'atten_value_of_port2': 25,
    'atten_value_of_port3': 45
}

# bad
ATTENUATION_VALUE_DL_BAD_6 = {
    'atten_value_of_port0': 45,
    'atten_value_of_port1': 75,
    'atten_value_of_port2': 45,
    'atten_value_of_port3': 75
}

ATTENUATION_VALUE_DL_GOOD_8 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

ATTENUATION_VALUE_DL_GOOD_9 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

# good
ATTENUATION_VALUE_DL_GOOD = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15
}

# middle
ATTENUATION_VALUE_DL_MID = {
    'atten_value_of_port0': 45,
    'atten_value_of_port1': 45,
    'atten_value_of_port2': 45,
    'atten_value_of_port3': 45
}

# bad
ATTENUATION_VALUE_DL_BAD = {
    'atten_value_of_port0': 75,
    'atten_value_of_port1': 75,
    'atten_value_of_port2': 70,
    'atten_value_of_port3': 70
}

ATTENUATION_VALUE_UL_GOOD = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20
}

ATTENUATION_VALUE_UL_MID = {
    'atten_value_of_port0': 5,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 30,
    'atten_value_of_port3': 30
}

ATTENUATION_VALUE_UL_BAD = {
    'atten_value_of_port0': 5,
    'atten_value_of_port1': 5,
    'atten_value_of_port2': 35,
    'atten_value_of_port3': 20
}

ATTENUATION_VALUE_DL_DEBUG = {
    'atten_value_of_port0': 5,
    'atten_value_of_port1': 5,
    'atten_value_of_port2': 5,
    'atten_value_of_port3': 5
}
