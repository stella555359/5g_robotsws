__author__ = 'lukasz.rumak@nokia.com'
__contact_person__ = 'lukasz.rumak@nokia.com'

from os import path
import random
import re
import time
import subprocess
import xml.etree.ElementTree as ET
import datetime


def verify_faults_history_with_allowed_list(faults_dict, faults_allowed):
    faults_list = []
    for element_dict in faults_dict:
        faults_list.extend([element_dict['FAULT ID']])
    for element in faults_allowed:
        if element in faults_list:
            for attempt in range(1, faults_list.count(element) + 1):
                faults_list.remove(element)
    print('Not allowed faults IDs found: ' + str(faults_list))
    if len(faults_list) == 1:
        raise Exception('Not allowed fault has been found!')
    elif len(faults_list) > 1:
        raise Exception('Not allowed faults have been found!')
    else:
        return print('Alles gut')


def check_files_extension(files_list, files_extention):
    files_list = files_list.split("\n")
    files_list_error = []
    for file in files_list:
        if file[-len(files_extention):] == files_extention:
            print('OK: ' + str(file))
        else:
            files_list_error.append(str(file))
            print('NOT OK: ' + str(file))
    if len(files_list_error) == 0:
        return print('Alles gut')
    else:
        print('The following file(s) did not match to pattern: ' + str(files_list_error))
        raise Exception('File extension did not match to pattern')


def check_if_raw_pm_reports_are_deleted(filesToCheck):
    filesToCheck = filesToCheck.split("\n")
    allowed = ['xz', 'xml']
    notAllowedEXT = []
    for element in filesToCheck:
        elementExt = element.split('.')[5]

        if elementExt in allowed:
            print(True)
        else:
            notAllowedEXT.append(element)

    if len(notAllowedEXT) == 0:
        return print('Alles gut')
    else:
        print('Not allowed file has been found: ' + str(notAllowedEXT))
        raise Exception('Not allowed file has been found')


# Checking if raw are deleted after changes on trunk:
# delete n.raw file automatically when n.raw has been merged to result file and next n+1.raw has already been created
def check_if_raw_pm_reports_are_deleted_on_trunk(filesToCheck):
    filesToCheck = filesToCheck.split("\n")
    allowed = ['xz', 'xml']
    notAllowedEXT = []
    allowedRaw = []
    for element in filesToCheck:
        elementExt = element.split('.')[5]

        if elementExt in allowed:
            print(True)
        else:
            notAllowedEXT.append(element)
            allowedRaw.append(elementExt)

    # count if there is only 1 raw file
    if allowedRaw.count('raw') == 1:
        return print('Alles gut')
    # count if there is no raw file
    elif allowedRaw.count('raw') == 0:
        return print('Alles gut')
    else:
        print('Not allowed file has been found: ' + str(notAllowedEXT))
        raise Exception('Not allowed file has been found')


def compare_two_lists_and_return_difference(list1, list2):
    diff_list1 = []
    diff_list2 = []
    diff_all = []
    for item1 in list1:
        if item1 in list2:
            print(True)
        else:
            diff_list1.append(item1)
            diff_all.append(item1)
    for item2 in list2:
        if item2 in list1:
            print(True)
        else:
            diff_list2.append(item2)
            diff_all.append(item2)
    if len(diff_all) == 0:
        return 'Lists are equal'
    else:
        print('Items from *list1* not available in *list2*: ' + str(diff_list1))
        print('Items from *list2* not available in *list1*: ' + str(diff_list2))
        print('The following difference have been found: ' + str(diff_all))
        raise Exception('Lists are different')


def check_if_startTimes_are_correct(startTimeReport, listCorrect):
    allStartTimes = ['00', '15', '30', '45']
    counterCorrect = 0
    counterIncorrect = 0
    startTimeReportSplited = []
    allowed = []
    notAllowed = []
    for element in startTimeReport:
        element = element.split(':')[1]
        startTimeReportSplited.append(element)
    listCorrect = listCorrect.split('-')
    print('Correct startTimes: ' + str(listCorrect))
    print('StartTimes from report: ' + str(startTimeReportSplited))
    for startTime in allStartTimes:
        if startTime in listCorrect:
            if startTime in startTimeReportSplited:
                counterCorrect = counterCorrect + 1
            else:
                allowed.append(startTime)
        else:
            if startTime in startTimeReportSplited:
                counterIncorrect = counterIncorrect + 1
                notAllowed.append(startTime)
    if counterCorrect == len(listCorrect) and counterIncorrect == 0:
        return print('Alles gut')
    elif counterCorrect == len(listCorrect) and counterIncorrect != 0:
        print('The following NOT ALLOWED startTime has been found: ' + str(notAllowed))
        raise Exception('NOT ALLOWED startTime has been found!')
    elif counterCorrect != len(listCorrect) and counterIncorrect == 0:
        print('The following ALLOWED startTime has NOT been found: ' + str(allowed))
        raise Exception('ALLOWED startTime has NOT been found!')
    elif counterCorrect != len(listCorrect) and counterIncorrect != 0:
        print('The following ALLOWED startTime has NOT been found: ' + str(allowed))
        print('The following NOT ALLOWED startTime has been found: ' + str(notAllowed))
        raise Exception('ALLOWED startTime has NOT been found, and also NOT ALLOWED startTime has been found!')


def validate_intervals_of_measurment_in_scf(attribNameList, correctValue, xmlPath, filePath):
    errorList = []
    tree = ET.parse(filePath)
    root = tree.getroot()
    for managedObject in root.findall(xmlPath):
        if managedObject.attrib['name'] in attribNameList:
            if managedObject.text == correctValue:
                print(True)
            else:
                errorList.append(managedObject.attrib['name'])
    if len(errorList) == 0:
        return print('Alles gut')
    else:
        print('The following SCF parameter does not match:', errorList)
        raise Exception('Some mismatch has been found!')


def check_if_pm_report_does_not_contain_measurements(intervalSetup, startTimes, filePath):
    tree = ET.parse(filePath)
    root = tree.getroot()
    counterMeas = 0
    counterCounter = 0
    startTimes = startTimes.split('-')
    for managedObject in root.findall(intervalSetup):
        for time in startTimes:
            if managedObject.attrib['startTime'].split(":")[1] == time:
                for measurementType in managedObject.findall("PMMOResult/NE-WBTS_1.0"):
                    counterMeas += 1
                for counterElement in managedObject.findall("PMMOResult/NE-WBTS_1.0/*"):
                    counterCounter += 1
    if counterMeas == 0 and counterCounter == 0:
        return print('Alles gut')
    else:
        print('Counter for measurements:', counterMeas)
        print('Counter for counters:', counterCounter)
        raise Exception('Not allowed startTime has been found!')


def check_if_proper_time_intervals_are_present_in_pm_report(filePath):
    tree = ET.parse(filePath)
    root = tree.getroot()
    counterGeneral = 0
    counterInterval = 0
    counterStartTime = 0
    startTimeList = ['00', '15', '30', '45']
    legalCounterIntervals = ['15', '30', '60', '360']
    for managedObject in root.findall(".//PMSetup"):
        counterGeneral += 1
        if managedObject.attrib['interval'] in legalCounterIntervals:
            counterInterval += 1
        if managedObject.attrib['startTime'].split(":")[1] in startTimeList:
            counterStartTime += 1
    if counterGeneral == counterInterval == counterStartTime:
        return True
    else:
        print('Counter all PMSetup:', counterGeneral)
        print('Counter correct interval:', counterInterval)
        print('Counter correct startTime:', counterStartTime)
        raise Exception('Not allowed interval or startTime has been found!')


def check_oam_link_type_and_status(linkState, filePath):
    tree = ET.parse(filePath)
    root = tree.getroot()
    if root.find('SiteConfMgmDB/Links/Link/_linkType').text == 'OAM':
        if root.find('SiteConfMgmDB/Links/Link/_linkState').text == linkState:
            return print('Alles gut')
        else:
            print('OAM link state is:', root.find('SiteConfMgmDB/Links/Link/_linkState').text)
            raise Exception('Invalid OAM link state has been found')
    else:
        raise Exception('Link type is not OAM')


def check_if_old_and_new_bts_port_are_diff(btsPorts):
    btsPorts = btsPorts.split("\n")
    btsPortsFiltered = []
    if len(btsPorts) == 0:
        raise Exception('List with ports is empty!')
    else:
        for port in btsPorts:
            if port != 'ssh' and port != 'x11':
                btsPortsFiltered.append(port)
    if len(btsPortsFiltered) == 2:
        if btsPortsFiltered[0] != btsPortsFiltered[1]:
            return print('Alles gut')
        else:
            raise Exception('Ports are the same!')
    else:
        raise Exception('Something went wrong!')


def compare_elements_from_lists_with_pattern(first_list, second_list, x, y):
    counter = 0
    for i in zip(first_list, second_list):
        if i == (x, y):
            counter += 1
    return counter


def verify_type_of_reset(path_to_file, pattern, line_number=-6):
    lines = []
    with open(path_to_file, 'r') as file:
        lines.append(file.readlines())
    print(lines[0][line_number])
    lines[0][line_number] = lines[0][line_number].replace("(", "'").replace(")", "'")
    pattern = pattern.replace("(", "'").replace(")", "'")
    if not re.search(pattern, lines[0][line_number]):
        raise Exception('Pattern has not been found!')


def convert_epoch_to_datetime(epoch_time):
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(epoch_time))


def check_if_each_startTime_contains_the_same_items(list_to_compare):
    for i in range(len(list_to_compare)):
        for j in range(i + 1, len(list_to_compare)):
            if list_to_compare[i] == list_to_compare[j]:
                print(True)
            else:
                raise Exception('Lists are not equal!')
    return True


def generate_random_number():
    return random.randint(1, 30)


def fix_variable_exit2_hour_if_it_is_out_of_range(exit2_hour):
    if (exit2_hour == 24):
        return 0
    if (exit2_hour == 25):
        return 1
    else:
        return exit2_hour


def evaluate_variable_current_hour_for_360min_interval(actual_hour):
    if (actual_hour == '23'):
        return '18'
    if (actual_hour == '05'):
        return '00'
    if (actual_hour == '11'):
        return '06'
    if (actual_hour == '17'):
        return '12'
    else:
        return actual_hour


def evaluate_variable_current_hour_for_720min_interval(actual_hour):
    if (actual_hour == '23'):
        return '12'
    if (actual_hour == '11'):
        return '00'
    else:
        return actual_hour


def start_netcat_process():
    # subprocess.Popen(["nohup", "nc", "-l", "-p", "60000", ">", "/opt/ute/python/bin/trace.bin"], shell=True,
    #  stdout=subprocess.PIPE)
    command = 'nohup nc -l -p 60000 > /opt/ute/python/bin/trace.bin'
    subprocess.check_output(command, shell=True)
    # check_trace_bin = 'ls -lh | grep \'trace.bin\' | awk \'{print $9}\''
    check_trace_bin = 'ls -lh \'/opt/ute/python/bin\' | grep \'trace.bin\' | awk \'{print $9}\''
    output = subprocess.check_output(check_trace_bin, shell=True)
    if output == 'trace.bin':
        return True
    else:
        raise Exception('The file is not exist')


# takes piids from the report and checks if each is in the bl file
# possibilities:
# piid on baselineCounterList not on counterList (report) - problem
# piid on counterList (report) not on baselineCounterList - irrelevant
# piid on counterList (report) AND on baselineCounterList - required
def check_if_piid_from_report_are_in_baseline(bl, report, ignored_piids):
    missing_piids = [i for i in bl if i not in report and i not in ignored_piids]
    if (len(missing_piids)) > 0:
        raise Exception('The following PIIDs are missing in the PM.BTS* report file', missing_piids)
    else:
        print(True)


def verify_if_measurementTypes_are_not_overlapping(meas60, meas360):
    if ((len(meas60)) - 2) == (len(meas360)):
        return True
    else:
        raise Exception('The number of measurementTypes is incorrect')
        # 5 for each of the counters you want to check, find if it is on the list of counters in the report


def check_counters_are_missing_in_the_report(list_measurements_to_check, result_list):
    missingMeasurementslist = [i for i in list_measurements_to_check if i not in result_list]

    if len(missingMeasurementslist) != 0:
        raise Exception('The following pm counters are missing', missingMeasurementslist)


def get_time_variables():
    now = datetime.datetime.now()
    t = (now.year, now.month, now.day, now.hour, now.minute)
    return t


def verify_pm_counters_children(parents_to_check, ignored_parents, branchVersion, t):
    # problem with time

    with open("missing_counters_report.txt", 'w') as the_file:
        path_to_report = path.join(
            '/tmp/PM/PM.BTS-1.' + str(t[0]) + str(t[1]) + str(t[2]) + '.' + str(t[3]) + str(t[4]) + '00.LTE.xml')
        # tree =
        # ET.parse('/tmp/PM/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.LTE.xml')
        tree = ET.parse(path_to_report)
        root = tree.getroot()
        piids_from_the_report = []
        for newbts in root.iter('NE-WBTS_1.0'):
            measurementType_dict = newbts.attrib
            parent = measurementType_dict.get('measurementType')
            if parent in parents_to_check and parent not in ignored_parents:
                for child in newbts:
                    piids_from_the_report.append(child.tag)
        piids_from_the_report = list(set(piids_from_the_report))

        path_to_bl = path.join('/home/ute/test_repository/testsuite/WMP/DevWro2/CRT', str(branchVersion), 'PM',
                               str(branchVersion) + '_FSMr3_PM_BL.xml')
        # tree =
        # ET.parse('/home/ute/robotlte/testsuite/WMP/DevWro2/CRT/${branchVersion}/PM/${branchVersion}_FSMr3_PM_BL.xml')
        tree = ET.parse(path_to_bl)
        root = tree.getroot()
        piids_from_the_bl = []
        for Measurement in root.iter('Measurement'):
            Name = Measurement.find("Name").text
            if Name in parents_to_check:
                for pi in Measurement.iter('PI_ID'):
                    piids_from_the_bl.append(pi.text)
        final_list = [i for i in piids_from_the_bl if i not in piids_from_the_report]
        print("missing PIIDs: \n", file=the_file)
        print(final_list, file=the_file)
        if len(final_list) != 0:
            raise Exception('The following pi_ids are missing', final_list)
        else:
            print("no missing PIIDs", file=the_file)


def check_om_messages_and_acks_for(om_message_type, tshark_string_capture):
    '''
    :param string om_message_type:          the legal names are: 'supervision', 'alarmStatusRequest', 'alarmStatusReply'
    :param string tshark_string_capture:    the pcap file converted to text presenting all the traffic on eth3 interface
    '''

    d = {'supervision': 'supervision(12)', 'alarmStatusRequest': 'alarmStatusRequest(10)',
         'alarmStatusReply': 'alarmStatusReply(15)'}
    # d = {'supervision': 'supervision\(12\)', 'alarmStatusRequest': 'alarmStatusRequest\(10\)',
    # 'alarmStatusReply': 'alarmStatusReply\(15\)'}
    msg_text = d[om_message_type]
    tshark_string_capture = re.sub('[ \n]', '',
                                   tshark_string_capture)  # delete "\n" and " " from the string,
    message_object = re.search(om_message_type, tshark_string_capture)  # msg found
    if bool(message_object) is False:
        raise Exception('message was not found!')
    index = message_object.end()  # find the end index
    messageSequence = (re.search('messageSequence:[0-9]+', tshark_string_capture[index:index + 100])).group()
    print('the message sequence is ', messageSequence)
    # check the message sequence
    if bool(messageSequence) is False:
        raise Exception('ack message not found!')

    # find ack meessage for the respective messageSequence and evaluate the results
    if msg_text != 'alarmStatusReply(15)':  # alarmStatusReply msg has no ack, orgi: 'alarmStatusReply\(15\)'
        # the_respective_ack_msg = re.findall("ackNack\(0\)[a-zA-Z0-9:]+" + messageSequence, tshark_string_capture, )
        the_respective_ack_msg = re.findall("ackNack(0)[a-zA-Z0-9:]+" + messageSequence, tshark_string_capture, )
        print(the_respective_ack_msg)
        if bool(the_respective_ack_msg) is False:
            raise Exception('ack message was not found!')

    return messageSequence
