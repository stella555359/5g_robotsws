def compare_Alarm(alarmName=[], alarmNameNew=[]):
    a = [0]
    for i in alarmNameNew:
        if i in alarmName:
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
