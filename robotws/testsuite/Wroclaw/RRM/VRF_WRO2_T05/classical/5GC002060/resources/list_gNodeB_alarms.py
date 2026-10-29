# Search a specific alarm ( string_to_search ) in a list of alarms ( alarm ) obtained by get_all_faults
# Result = True when alarm is found, False otherwise
# ##########################################################################################################

# [ {'additionalText1': u'4266 Failure in verifying the signature of a signed software release', 'specificProblem':
#  7109, 'alarmText': u'BASE STATION SECURITY PROBLEM', 'perceivedSeverity': u'minor'},
# # {'additionalText1': u'4490 No X2 link available',                   'specificProblem': 7107, 'alarmText':
#  u'BASE STATION CONNECTIVITY PROBLEM', 'perceivedSeverity': u'major'},
# # {'additionalText1': u'10 No connection to unit',                    'specificProblem': 7100, 'alarmText':
#  u'HARDWARE PROBLEM', 'perceivedSeverity': u'critical'},
# # {'additionalText1': u'1815 Not able to synchronize a baseband bus', 'specificProblem': 7100, 'alarmText':
#  u'HARDWARE PROBLEM', 'perceivedSeverity': u'critical'}]


def list_alarms(alarm):
    # Search alarms in Web UI gNodeB and write description and criticity
    # Faulty = True  if critical or majpr alamrs are present, False if only minor or no alarms are present
    nb_critical = 0
    nb_major = 0
    nb_minor = 0
    Faulty = False
    print("*** List of Alarma :")
    for item in alarm:
        for Key, Value in item.items():
            if Key == 'additionalText1':
                text = str(Value)
            if Key == 'perceivedSeverity':
                print("   " + text + " : " + Value + " alarm")
            if 'critical' in str(Value):
                nb_critical += 1
                Faulty = True
            if 'major' in str(Value):
                nb_major += 1
                Faulty = True
            if 'minor' in str(Value):
                nb_minor += 1
    print("*** Number of alarms : " + str(len(alarm)) + ", " + str(nb_critical) + " critical alarms, " +
          str(nb_major) + ' major alarms, ' + str(nb_minor) + "  minor alarms")
    print('Faulty state = ' + str(Faulty))
    return Faulty


def retrieve_alarm(alarm, string_to_search):
    for item in alarm:
        for Key, Value in item.items():
            if string_to_search in str(Value):
                print("Alarm '" + str(string_to_search) + "' is present")
                return True
    return False
