import os
import zipfile
import time
import shutil

parameteDict = {
    "snapshotContentCoverage": ['Basic', 'Important', 'All'],
    "snapshotProfile": ['All', 'CrashAndRecovery', 'UserAndControlPlane',
                        'ControlPlane', 'HwSwConfiguration', 'RuOnly'],
    "snapshotTargetArea": ['CuOnly', 'DuOnly', 'CuAndDu'],
    "triggerType": ['onFaultDetection', 'onAlarmSend', 'onFaultCancellation']
}


def get_parameters(param_name):
    if param_name in parameteDict:
        return parameteDict[param_name]
    else:
        print("Wrong param name")
        raise LookupError


def checkParamete(param_name, paraList):
    expected = get_parameters(param_name)
    for item in expected:
        if item not in paraList:
            print("Parameters are different")
            return False
    print("Parameters are the same")
    return True


def checkSnapshotContent(snapshotPath):
    snapshot_path = snapshotPath.strip('\r\n')
    snapshot_content = os.listdir(snapshot_path)
    return snapshot_content


def listShouldContain(check_list, check_word):
    for i in check_list:
        if check_word not in i:
            continue
        elif check_word in i:
            print("true")
            return 'true'
            break


def alarmMatch(alarmList, fault_name):
    flag = 'False'
    for i in alarmList:
        if i['Fault name'] != fault_name:
            continue
        if i['Fault name'] == fault_name:
            flag = 'True'
            print(i['Fault name'])
            print(fault_name)
            break
    return flag


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


def get_Dir(fileName):
    filePath = os.path.dirname(fileName)
    return filePath


def get_Filename(fileName):
    file = os.path.basename(fileName)
    return file


def unZip(fileName):
    if os.path.splitext(fileName)[1] == '.zip':
        file_zip = zipfile.ZipFile(fileName, 'r')
        file_exist = str(os.path.exists('./tmp'))
        if file_exist == 'True':
            shutil.rmtree('./tmp')
            print(os.path.exists('./tmp'))
            time.sleep(15)
            os.makedirs('./tmp')
        if file_exist == 'False':
            os.makedirs('./tmp')
        for file in file_zip.namelist():
            file_zip.extract(file, './tmp')
        file_zip.close()
