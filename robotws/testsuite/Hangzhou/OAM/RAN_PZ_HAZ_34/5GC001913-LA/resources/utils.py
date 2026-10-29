import re
import json


def _change_mrbtsid(distName, id):
    pattern = re.compile(r'MRBTS-(\d)+')
    target = 'MRBTS-' + str(id)
    return pattern.sub(target, distName)


def _read_json_and_change_bts_id(delta, id):
    mos = []
    with open(delta, 'r') as f:
        mos = json.load(f)
        for mo in mos:
            mo['distName'] = _change_mrbtsid(mo['distName'], id)
    return mos


def change_bts_id_in_json(delta, id, output='/tmp/delta.json'):
    mos = _read_json_and_change_bts_id(delta, id)
    with open(output, 'w') as f:
        json.dump(mos, f)
    return output
