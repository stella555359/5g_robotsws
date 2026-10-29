from json import dumps


def get_delta_commissioning_with_site_reset_required(node):
    dist_name = f"MRBTS-{node['testline_object'].instance_id}"
    delta = [{
        "distName": dist_name,
        "operation": "update",
        "parameters": [{
            "parameterName": "dnPrefix",
            "value": f"CN={dist_name}",
            "operation": "update"}
        ]}]
    return dumps(delta)


def get_delta_commissioning_with_online_parameter_modification(node):
    dist_name = f"MRBTS-{node['testline_object'].instance_id}"
    delta = [{
        "distName": dist_name,
        "operation": "update",
        "parameters": [{
            "parameterName": "priorityLabel",
            "value": 21,
            "operation": "update"}
        ]}]
    return dumps(delta)


def get_delta_commissioning_with_lte_rat_reset(node):
    tl = node['testline_object']
    dist_name = f"MRBTS-{tl.instance_id}/LNBTS-{tl.global_bts_id}/SCTP-1"
    delta = [{
        "distName": dist_name,
        "operation": "update",
        "parameters": [{
            "parameterName": "rtoMax",
            "value": 30000,
            "operation": "update"}
        ]}]
    return dumps(delta)


def get_delta_commissioning_with_nr_rat_reset(node):
    tl = node['testline_object']
    dist_name = f"MRBTS-{tl.instance_id}/NRBTS-{tl.global_bts_id}/NRPLMN-1"
    delta = [{
        "distName": dist_name,
        "operation": "update",
        "parameters": [{
            "parameterName": "userLabel",
            "value": f"Public Land Mobile Network",
            "operation": "update"}
        ]}]
    return dumps(delta)


def get_delta_commissioning_with_gsm_rat_reset(node):
    dist_name = f"MRBTS-{node['testline_object'].instance_id}/GNBTS-1/GNBCF-1"
    delta = [{
        "distName": dist_name,
        "operation": "update",
        "parameters": [{
            "parameterName": "sctpRtoMaxOmuSig",
            "value": 4000,
            "operation": "update"}
        ]}]
    return dumps(delta)
