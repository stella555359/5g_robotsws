all_5qi_ports = [45510, 45511, 45512, 45512, 45513, 45514, 45515, 45555, 45517, 45518, 45519, 45520]
five_qi = {
    "5qi1-port": 45510,
    "5qi2-port": 45511,
    "5qi3-ul-port": 45512,
    "5qi3-dl-port": 45512,
    "5qi4-port": 45513,
    "5qi5-port": 45514,
    "5qi6-port": 45515,
    "5qi7-port": 45555,
    "5qi8-port": 45517,
    "5qi9-port": 45518,
    "5qi80-port": 45520,
    "5qi128-port": 45519
}
UE1 = {
    "used_5qis": "1, 2, 5, 6, 7, 8, 9, 128",
    "same_profile_ues": ["UE4", "UE5", "UE6"],
    "ul": [{
        "port": 45510,
        "throughput": "19.7K",
        "size": "61"
    },
        {
            "port": 45511,
            "throughput": "692K",
            "size": "1212"
        },
        {
            "port": 45514,
            "throughput": "2.38K",
            "size": "127"
        },
        {
            "port": 45515,
            "throughput": "333K",
            "size": "951"
        },
        {
            "port": 45555,
            "throughput": "1.4M",
            "size": "343"
        },
        {
            "port": 45517,
            "throughput": "1.4M",
            "size": "951"
        },
        {
            "port": 45518,
            "throughput": "1.4M",
            "size": "951"
        },
        {
            "port": 45519,
            "throughput": "1.4M",
            "size": "951"
        }],
    "dl": [{
        "port": 45510,
        "throughput": "19.7K",
        "size": "61"
    },
        {
            "port": 45511,
            "throughput": "923K",
            "size": "1212"
        },
        {
            "port": 45514,
            "throughput": "23.8K",
            "size": "241"
        },
        {
            "port": 45515,
            "throughput": "428K",
            "size": "1078"
        },
        {
            "port": 45555,
            "throughput": "14.2M",
            "size": "1460"
        },
        {
            "port": 45517,
            "throughput": "14.2M",
            "size": "1078"
        },
        {
            "port": 45518,
            "throughput": "14.2M",
            "size": "1078"
        },
        {
            "port": 45519,
            "throughput": "14.2M",
            "size": "1078"
        }]
}
UE2 = {
    "used_5qis": "4, 6, 7, 80",
    "same_profile_ues": [],
    "ul": [{
        "port": 45513,
        "throughput": "90K",
        "size": "1212"
    },
        {
            "port": 45515,
            "throughput": "333K",
            "size": "951"
        },
        {
            "port": 45555,
            "throughput": "1.4M",
            "size": "343"
        },
        {
            "port": 45520,
            "throughput": "90K",
            "size": "1212"
        }],
    "dl": [{
        "port": 45513,
        "throughput": "900K",
        "size": "1212"
    },
        {
            "port": 45515,
            "throughput": "428K",
            "size": "1078"
        },
        {
            "port": 45555,
            "throughput": "14.2M",
            "size": "1460"
        },
        {
            "port": 45520,
            "throughput": "900K",
            "size": "1212"
        }]
}
UE3 = {
    "used_5qis": "3, 6, 7, 8, 9, 80",
    "same_profile_ues": [],
    "ul": [{
        "port": 45512,
        "throughput": "450K",
        "size": "430"
    },
        {
            "port": 45515,
            "throughput": "333K",
            "size": "951"
        },
        {
            "port": 45555,
            "throughput": "1.4M",
            "size": "343"
        },
        {
            "port": 45517,
            "throughput": "1.4M",
            "size": "951"
        },
        {
            "port": 45518,
            "throughput": "1.4M",
            "size": "951"
        },
        {
            "port": 45520,
            "throughput": "90K",
            "size": "1212"
        }],
    "dl": [{
        "port": 45512,
        "throughput": "900K",
        "size": "1212"
    },
        {
            "port": 45515,
            "throughput": "428K",
            "size": "1078"
        },
        {
            "port": 45555,
            "throughput": "14.2M",
            "size": "1460"
        },
        {
            "port": 45517,
            "throughput": "14.2M",
            "size": "1078"
        },
        {
            "port": 45518,
            "throughput": "14.2M",
            "size": "1078"
        },
        {
            "port": 45520,
            "throughput": "900K",
            "size": "1212"
        }]
}
UE7 = {
    "used_5qis": "1, 2, 5, 6, 7",
    "same_profile_ues": ["UE8"],
    "ul": [{
        "port": 45510,
        "throughput": "19.7K",
        "size": "61"
    },
        {
            "port": 45511,
            "throughput": "692K",
            "size": "1212"
        },
        {
            "port": 45514,
            "throughput": "2.38K",
            "size": "127"
        },
        {
            "port": 45515,
            "throughput": "333K",
            "size": "951"
        },
        {
            "port": 45555,
            "throughput": "1.4M",
            "size": "343"
        }],
    "dl": [{
        "port": 45510,
        "throughput": "19.7K",
        "size": "61"
    },
        {
            "port": 45511,
            "throughput": "923K",
            "size": "1212"
        },
        {
            "port": 45514,
            "throughput": "23.8K",
            "size": "241"
        },
        {
            "port": 45515,
            "throughput": "428K",
            "size": "1078"
        },
        {
            "port": 45555,
            "throughput": "14.2M",
            "size": "1460"
        }]
}
