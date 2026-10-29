"""
JSON editor. Replaces placeholders with provided MRBTSID, NRBTSID  and Ves Node IP address.
Needs base JSON file with placeholders in the value or Object DistNames:
"distName": "MRBTS-BTS_ID/MNL-1/CERTH-1/CMP-1"
"distName": "MRBTS-BTS_ID/NRBTS-NR_ID"
"value": "VES_ADD"
"""


def edit_json(base_json, output_json, bts_id, nrbts_id, worker_ip):
    """
    :param base_json:   eg. /testsuite/OAM/Wroclaw/cOAM1/5GC001104/resources/deltaIPv6.json
    :param output_json: eg. /testsuite/OAM/Wroclaw/cOAM1/5GC001104/resources/ready_delta.json
    :param bts_id:      eg. 50357
    :param nrbts_id:    eg. 50357
    :param worker_ip:   eg. 2a00:8a00:6000:607c::1:b62c
    :return: None. Saves output_json in the provided path
    """

    output = open(output_json, "w+")
    with open(base_json, 'r+') as delta:
        content = delta.read()
        delta.seek(0)
        content = content.replace('BTS_ID', str(bts_id))
        content = content.replace('VES_ADD', str(worker_ip))
        content = content.replace('NR_ID', str(nrbts_id))
        output.write(content)
    output.close()
