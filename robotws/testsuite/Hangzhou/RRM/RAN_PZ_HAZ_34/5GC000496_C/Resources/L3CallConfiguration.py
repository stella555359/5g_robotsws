#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import argparse
import requests
import re
import string
import time
import sys
import os

STREAM_INFOs = {
    "9.1800": {
        "StreamPrefix": "20A",
        "GoldenSCF": "/20A/SCF_TDD_CPRI_ASIB_AEQB_TL103_3CELL.xml",
    },
    "10.1800": {"StreamPrefix": "20B", "GoldenSCF": "/20B/GoldenSCF_6Cell_v30.xml"},
    "11.800": {"StreamPrefix": "21A", "GoldenSCF": "/21A/GoldenSCF_6Cell_v24.xml"},
    "0.800": {"StreamPrefix": "TRUNK", "GoldenSCF": "/Trunk/GoldenSCF_6Cell.xml"},
    "0.300": {"StreamPrefix": "TRUNK", "GoldenSCF": ""},
    "CNF00_0.300": {"StreamPrefix": "TRUNK", "GoldenSCF": ""},
    "CNF00_0.250": {"StreamPrefix": "TRUNK", "GoldenSCF": ""},
    "CNF25R1_24.300": {"StreamPrefix": "25R1", "GoldenSCF": ""},
    "CNF25R1_24.250": {"StreamPrefix": "25R1", "GoldenSCF": ""},
    "17.300": {"StreamPrefix": "23R1", "GoldenSCF": ""},
    "18.300": {"StreamPrefix": "23R2", "GoldenSCF": ""},
    "20.300": {"StreamPrefix": "23R4", "GoldenSCF": ""},
    "SBTS21B_ENB_0000": {
        "StreamPrefix": "SBTS21B",
        "GoldenSCF": "/21B/GoldenSCF_6Cell_v20.xml",
    },
    "SBTS22R1_ENB_0000": {
        "StreamPrefix": "SBTS22R1",
        "GoldenSCF": "/Trunk/GoldenSCF_6Cell_v4.xml",
    },
    "SBTS00_ENB_9999": {
        "StreamPrefix": "SBTSTRUNK",
        "GoldenSCF": "/Trunk/GoldenSCF_6Cell_v4.xml",
    },
}

TLCommonConfig = {
    "MultiUECFG": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "0": {
            "detach_request": True,
            "power_reset": "false",
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "call_loop": 2,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5MKbits/sec", "duration": "600"},
            "ul": {"target_throughput": "5MKbits/sec", "duration": "600"},
            "target_percent": "0.95",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_1",
            "protocol": "udp",
            "connection_type": "app",
        },
        "ue_index_for_call": ["0"],
    },
    "PAGroups": {
        "1": {
            "ports": [
                {"port_id": 1, "default_value": 60},
                {"port_id": 2, "default_value": 60},
                {"port_id": 3, "default_value": 60},
                {"port_id": 4, "default_value": 60},
            ]
        },
        "2": {
            "ports": [
                {"port_id": 5, "default_value": 60},
                {"port_id": 6, "default_value": 60},
            ]
        },
    },
    "rus": {
        "0": {
            "host": "",
            "username": "ute",
            "password": "iW_K#8.ute%A10h0m0ra",
            "lmi_ip": "192.168.102.100",
            "ru_ip": "192.168.102.1",
            "ru_index": "1",
            "ru_username": "rfsw",
            "ru_password": "bdS%ztWG3v7%SjreCVA79wTPb",
            "position": "primary",
        },
    },
}
