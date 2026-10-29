from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

bfd_parameters = [
    {
        'param_name': 'BFD session lost packets detection time multiplier',
        'param_abbr': 'bfdDetectMult',
        'message_regex': r'Detection Timer Multiplier:\s(?P<VALUE>\d+)\s.*'
    },
    {
        'param_name': 'Desired minimum BFD control word transmit interval',
        'param_abbr': 'desMinTxInt',
        'message_regex': r'.*Desired min Tx Interval:\s+(?P<VALUE>\d+)\sms'
    },
    {
        'param_name': 'Required minimum BFD control word receive interval',
        'param_abbr': 'reqMinRxInt',
        'message_regex': r'.*Required min Rx Interval:\s+(?P<VALUE>\d+)\sms'
    },
]

bfd_delta = [{
    'distName': "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1".format(bts_id),
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': "bfdDetectMult",
            'value': "10"
        },
        {
            'operation': 'update',
            'parameterName': "desMinTxInt",
            'value': "5000"
        },
        {
            'operation': 'update',
            'parameterName': "reqMinRxInt",
            'value': "4000"
        },
    ]}]

delta_tc_10 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id),
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEcpriMPlaneResilience",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "actECPRITransportForORANAndTSN",
                "value": "pointToPointNetwork",
                "operation": "update",
            }
        ],
    },
    {
        "parameters": [
            {
                "parameterName": "twampSenderMessageRate",
                "value": "RATE_10",
                "operation": "update",
            },
            {
                "parameterName": "ipAppId",
                "value": "1",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "bfdActivation",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdAdminUp",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdDestIpAddr",
                "value": "10.1.1.2",
                "operation": "update",
            },
            {
                "parameterName": "bfdDetectMult",
                "value": "5",
                "operation": "update",
            },
            {
                "parameterName": "bfdDscp",
                "value": "48",
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcIpAddrDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcUdpPort",
                "value": "65535",
                "operation": "update",
            },
            {
                "parameterName": "bfdType",
                "value": "singleHopBFD",
                "operation": "update",
            },
            {
                "parameterName": "desMinTxInt",
                "value": "500",
                "operation": "update",
            },
            {
                "parameterName": "reqMinRxInt",
                "value": "500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "bfdActivation",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdAdminUp",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdDestIpAddr",
                "value": "10.1.2.2",
                "operation": "update",
            },
            {
                "parameterName": "bfdDetectMult",
                "value": "3",
                "operation": "update",
            },
            {
                "parameterName": "bfdDscp",
                "value": "48",
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcIpAddrDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcUdpPort",
                "value": "3784",
                "operation": "update",
            },
            {
                "parameterName": "bfdType",
                "value": "singleHopBFD",
                "operation": "update",
            },
            {
                "parameterName": "desMinTxInt",
                "value": "500",
                "operation": "update",
            },
            {
                "parameterName": "reqMinRxInt",
                "value": "500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/BFD-2".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "interfaceDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1/VLANIF-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "ipMtu",
                "value": "1500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "ipAddressAllocationMethod",
                "value": "MANUAL",
                "operation": "update",
            },
            {
                "parameterName": "localIpAddr",
                "value": "10.1.1.1",
                "operation": "update",
            },
            {
                "parameterName": "localIpPrefixLength",
                "value": "24",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "interfaceDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2/VLANIF-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "ipMtu",
                "value": "1500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-2".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "ipAddressAllocationMethod",
                "value": "MANUAL",
                "operation": "update",
            },
            {
                "parameterName": "localIpAddr",
                "value": "10.1.2.1",
                "operation": "update",
            },
            {
                "parameterName": "localIpPrefixLength",
                "value": "24",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [{
            "value": [
                {
                    "destinationIpPrefixLength": "32",
                    "destIpAddr": "20.0.0.1",
                    "gateway": "10.1.1.2",
                    "preference": "1",
                    "triggerDN": "MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-1".format(bts_id)
                },
                {
                    "destinationIpPrefixLength": "32",
                    "destIpAddr": "20.0.0.1",
                    "gateway": "10.1.2.2",
                    "preference": "2",
                    "triggerDN": "MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-2".format(bts_id)
                }
            ],
            "parameterName": "staticRoutes",
            "operation": "update"
        }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPRT-1".format(bts_id),
        "operation": "create"

    },
    {
        "parameters": [
            {
                "parameterName": "false2TrueDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "parameterName": "logic",
                "value": "OR",
                "operation": "update",
            },
            {
                "parameterName": "true2FalseDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "value": [
                    {
                        "itemDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1".format(bts_id)
                    }],
                "parameterName": "itemList",
                "operation": "update"
            }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "false2TrueDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "parameterName": "logic",
                "value": "OR",
                "operation": "update",
            },
            {
                "parameterName": "true2FalseDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "value": [
                    {
                        "itemDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/BFD-2".format(bts_id)
                    }
                ],
                "operation": "update",
                "parameterName": "itemList"
            }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-2".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [{
            "parameterName": "twampSenderMessageRate",
            "value": "RATE_10",
            "operation": "update",
        }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPAPP-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "bfdActivation",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdAdminUp",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdDestIpAddr",
                "value": "10.3.1.2",
                "operation": "update",
            },
            {
                "parameterName": "bfdDetectMult",
                "value": "3",
                "operation": "update",
            },
            {
                "parameterName": "bfdDscp",
                "value": "48",
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcIpAddrDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcUdpPort",
                "value": "3784",
                "operation": "update",
            },
            {
                "parameterName": "bfdType",
                "value": "singleHopBFD",
                "operation": "update",
            },
            {
                "parameterName": "desMinTxInt",
                "value": "500",
                "operation": "update",
            },
            {
                "parameterName": "reqMinRxInt",
                "value": "500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPAPP-1/BFD-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "bfdActivation",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdAdminUp",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "bfdDestIpAddr",
                "value": "10.3.2.2",
                "operation": "update",
            },
            {
                "parameterName": "bfdDetectMult",
                "value": "3",
                "operation": "update",
            },
            {
                "parameterName": "bfdDscp",
                "value": "48",
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcIpAddrDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV4-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "bfdSrcUdpPort",
                "value": "3784",
                "operation": "update",
            },
            {
                "parameterName": "bfdType",
                "value": "singleHopBFD",
                "operation": "update",
            },
            {
                "parameterName": "desMinTxInt",
                "value": "500",
                "operation": "update",
            },
            {
                "parameterName": "reqMinRxInt",
                "value": "500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPAPP-1/BFD-2".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "interfaceDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "ipMtu",
                "value": "1500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1/IPIF-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "ipAddressAllocationMethod",
                "value": "MANUAL",
                "operation": "update",
            },
            {
                "parameterName": "localIpAddr",
                "value": "10.3.1.1",
                "operation": "update",
            },
            {
                "parameterName": "localIpPrefixLength",
                "value": "24",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "interfaceDN",
                "value": "MRBTS-{}/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-2/VLANIF-1".format(bts_id),
                "operation": "update",
            },
            {
                "parameterName": "ipMtu",
                "value": "1500",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1/IPIF-2".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "ipAddressAllocationMethod",
                "value": "MANUAL",
                "operation": "update",
            },
            {
                "parameterName": "localIpAddr",
                "value": "10.3.2.1",
                "operation": "update",
            },
            {
                "parameterName": "localIpPrefixLength",
                "value": "24",
                "operation": "update",
            }
        ],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV4-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [{
            "value": [
                {
                    "destinationIpPrefixLength": "32",
                    "destIpAddr": "20.0.0.3",
                    "gateway": "10.3.1.2",
                    "preference": "1",
                    "triggerDN": "MRBTS-{}/TNLSVC-1/TNL-4/TRIGGER-1".format(bts_id)
                },
                {
                    "destinationIpPrefixLength": "32",
                    "destIpAddr": "20.0.0.3",
                    "gateway": "10.3.2.2",
                    "preference": "2",
                    "triggerDN": "MRBTS-{}/TNLSVC-1/TNL-4/TRIGGER-2".format(bts_id)
                }
            ],
            "operation": "update",
            "parameterName": "staticRoutes"
        }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/IPNO-1/IPRT-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "false2TrueDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "parameterName": "logic",
                "value": "OR",
                "operation": "update",
            },
            {
                "parameterName": "true2FalseDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "value": [
                    {
                        "itemDN": "MRBTS-{}/TNLSVC-1/TNL-4/IPAPP-1/BFD-1".format(bts_id)
                    }
                ],
                "parameterName": "itemList",
                "operation": "update"
            }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/TRIGGER-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "parameterName": "false2TrueDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "parameterName": "logic",
                "value": "OR",
                "operation": "update",
            },
            {
                "parameterName": "true2FalseDelay",
                "value": "0",
                "operation": "update",
            },
            {
                "value": [
                    {
                        "itemDN": "MRBTS-{}/TNLSVC-1/TNL-4/IPAPP-1/BFD-2".format(bts_id)
                    }
                ],
                "operation": "update",
                "parameterName": "itemList"
            }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/TRIGGER-2".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [{
            "parameterName": "vlanId",
            "value": "1",
            "operation": "update",
        }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1/VLANIF-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [{
            "parameterName": "vlanId",
            "value": "1",
            "operation": "update",
        }],
        "distName": "MRBTS-{}/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1".format(bts_id),
        "operation": "create"
    },
    {
        "parameters": [
            {
                "value": [
                    {
                        "dscp": "18",
                        "pcp": "2",
                        "vlanId": "1"
                    },
                    {
                        "dscp": "18",
                        "pcp": "2",
                        "vlanId": "2"
                    }
                ],
                "parameterName": "interface",
                "operation": "update"
            },
            {
                "value": [
                    {
                        "vlanIdEnd": "4094",
                        "vlanIdStart": "1"
                    }
                ],
                "parameterName": "mPlaneVlanIdScanRange",
                "operation": "update"
            },
            {
                "value": [
                    {
                        "firstGwIPv4AddrDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1".format(bts_id),
                        "firstInterfaceIPv4Addr": "10.1.1.2",
                        "resiliencyMPlaneIPv4Addr": "20.0.0.1",
                        "rmodDN": "MRBTS-{}/EQM-1/APEQM-1/RMOD-1".format(bts_id),
                        "secondGwIPv4AddrDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1".format(bts_id),
                        "secondInterfaceIPv4Addr": "10.1.2.2"
                    }
                ],
                "parameterName": "rmodIpConfig",
                "operation": "update"
            }
        ],
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/MPLANEFHNW-1".format(bts_id),
        "operation": "create"
    }
]

delta_tc_10_23R2 = {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/MPLANEFHNW-1".format(bts_id),
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEnableTLSv13",
                "value": "false",
                "operation": "update",
            },
            {
                "parameterName": "extKeyUsageBitsTlsAuth",
                "value": "false",
                "operation": "update",
            },
            {
                "parameterName": "reservedIpRange",
                "value": "Range A",
                "operation": "update",
            },
            {
                "parameterName": "tls12Enabled",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "tlsRenegotiationInterval",
                "value": "86400",
                "operation": "update",
            }
        ],
    }

delta_tc_10_23R1 = {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/MPLANEFHNW-1".format(bts_id),
        "operation": "update",
        "parameters": [
            {
                "parameterName": "reservedIpRange",
                "value": "Range A",
                "operation": "update",
            }
        ],
    }

current_release = str(BuiltIn().get_variable_value('${ENB_BRANCH}'))
releases = ['SBTS00', 'SBTS24R3', 'SBTS24R1', 'SBTS23R3', 'SBTS23R2', 'SBTS23R1']

if any(release in current_release for release in releases):
    delta = delta_tc_10_23R1 if 'SBTS23R1' in current_release else delta_tc_10_23R2
    next(item for item in delta_tc_10 if item["distName"] == delta['distName'])["parameters"]\
        .extend(delta['parameters'])
