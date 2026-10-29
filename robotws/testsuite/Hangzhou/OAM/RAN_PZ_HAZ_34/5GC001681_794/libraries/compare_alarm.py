def compare_Alarm(alarmName=[], alarmNameNew=[]):
    a = [0]
    alarmName_M = []
    alarmNameNew_M = []
    for i in alarmName:
        if 'Appeared' in i.keys():
            i.pop('Appeared')
    alarmName_M = alarmName
    for i in alarmNameNew:
        if 'Appeared' in i.keys():
            i.pop('Appeared')
    alarmNameNew_M = alarmName

    for i in alarmNameNew_M:
        if i in alarmName_M:
            continue
        else:
            a.append(i)
            continue
    return a


def ignore_Alarm(alarmList, ignoreAlarm):
    for i in alarmList:
        valueAlarm = str(i.values())

        if valueAlarm.find(ignoreAlarm) > 0:
            alarmList.remove(i)

    return alarmList
