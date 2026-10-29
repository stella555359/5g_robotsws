def proper_NetAct_mapping(id):
    netact_id = {
        "srnclab33":
            {"node_ip": "10.53.80.138",
             "user": "omc",
             "password": "Nokia_150",
             "lbjbi": "10.53.80.147"
             },

        "srnclab1002":
            {"node_ip": "10.41.128.59",
             "user": "omc",
             "password": "Nokia_150",
             "lbjbi": "10.41.128.67"
             },

        "srnclab1028":
            {"node_ip": "10.41.148.139",
             "user": "omc",
             "password": "Nokia_150",
             "lbjbi": "10.41.148.147"
             },

        "srnclab1050":
            {"node_ip": "10.63.2.98",
             "user": "omc",
             "password": "Nokia_150",
             "lbjbi": "10.63.2.106"
             },

        "srnclab1055":
            {"node_ip": "10.68.122.16",
             "user": "omc",
             "password": "Nokia_150",
             "lbjbi": "10.68.122.22"
             }
    }

    try:
        na_parm_dict = netact_id[id]
    except KeyError:
        raise AssertionError("Netact data not found in resoureces file")
    else:
        return na_parm_dict
