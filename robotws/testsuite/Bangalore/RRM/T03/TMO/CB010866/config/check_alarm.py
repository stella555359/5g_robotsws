from taf.sbts.oam.coam.admin import admin


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_alarm_description(faultid, fault_name, description=None, cellid='MRBTS-5507/NRBTS-5507/NRCELL-302'):
    api = admin()
    connection = api.connect_to("192.168.255.129")
    result = connection.get_active_alarms()
    cellist = AutoDict()
    count = 0
    for alarms in result:
        indx = AutoDict()
        indx[alarms['faultId']] = count
        cell = alarms["alarmingObjectIds"]
        try:
            cellist[cell[0]['configuration']].append(indx)
        except Exception:
            cellist[cell[0]['configuration']] = [indx]
        count += 1
    alarmIds = cellist.get(cellid)
    if alarmIds is None:
        print("*WARN* No Alarms found in the cell")
        return False
    print(alarmIds)
    id = None
    for item in alarmIds:
        id = item.get(faultid)
        if id is not None:
            break
    if id is None:
        print("*WARN*  Alarm is not present in the cell")
        return False
    _fault_name = result[id]['faultName']
    _description = result[id]['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']
    if _fault_name != fault_name:
        print(f"fault name mismatched, expected:{fault_name}, current:{_fault_name}")
        return False
    if _description != description:
        print(f"fault discription mismatched, expected:{description}, current:{_description}")
        return False
    return True
