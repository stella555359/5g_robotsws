from robot.libraries.BuiltIn import BuiltIn

COMMAND_RTWP_HIST = "awk '/Item type: rtwp_histogram/{flag=1} flag; (match($0, \"Item type: \") && !match($0, \"Item " \
                    "type: rtwp_histogram\")){flag=0}' /mnt/runtime/BBOX5"

tl = BuiltIn().get_variable_value('${tl}')
BTS_ID = tl.gnbs[0].global_bts_id
DU_ID = tl.gnbs[0].global_bts_id
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
PASSWORD_GNB = tl.gnbs[0].cu.oam_ssh_connection_details.password
USER_GNB = tl.gnbs[0].cu.oam_ssh_connection_details.username

location_ahfig = tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].rus[1]
location_ahloa = tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].rus[0]

RUS_INFO = {
    "RMOD-4": {
        "name": "AHFIG",
        "cells": {
            21: {"cell_dist": "NR_5G_FDD_1905000000_20000000",
                 "antennas": [1, 2, 3, 4]},
        },
        "sn": location_ahfig.serial_number,
        "user": location_ahfig.default_ssh_connection_details.username,
        "password": location_ahfig.default_ssh_connection_details.password,
        "console_prompt": "#"
    },
    "RMOD-7": {
        "name": "AHLOA",
        "cells": {
            1: {"cell_dist": "NR_5G_FDD_678000000_20000000",
                "antennas": [1, 2, 3, 4]},
        },
        "sn": location_ahloa.serial_number,
        "user": location_ahloa.default_ssh_connection_details.username,
        "password": location_ahloa.default_ssh_connection_details.password,
        "console_prompt": "#"
    },
}
