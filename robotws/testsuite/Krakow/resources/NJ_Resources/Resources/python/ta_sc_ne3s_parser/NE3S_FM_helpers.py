"""
:copyright: Nokia Networks
:author: Mateusz Kurek
:contact: mateusz.kurek@nokia.com
"""
import robot.api.logger as logger
import ne3s_operations
import json
import re

# json_filepath= "/home/ute/logs/LATEST_ROBOT/POSTCONDITIONS/NE3S_parser_results_180906_1616.json"
json_filepath = "/home/ute/Desktop/NE3S_parser_results_180903_1810.json"


def import_json(json_filepath):
    with open(json_filepath, "r") as json_file:
        json_data = json.load(json_file)
    return json_data


def ne3s_fm_alarmEventNotification():
    keys = []
    counter = 0
    status = []
    notification = "transferNotification--notificationType"
    message = "ne3s_fm_alarmEventNotification"
    file_json = import_json(json_filepath)
    for key in file_json:
        key_temp = int(key)
        keys.append(key_temp)
    keys.sort()
    print(keys)
    for key in file_json.keys():
        # print(key)
        # print(file_json[key]["xml_data"][0].keys())
        # print(type(file_json[key]["xml_data"][0]))

        # print(file_json[key]["xml_data"][0].keys())
        # print(file_json[key]["xml_data"][0].values())

        # if message in file_json[key]["xml_data"][0][notification]:
        #     print("mam go")
        #     print(file_json[key]["xml_data"][0][notification])

        # print(type(file_json[key]["xml_data"][0]))
        # print(file_json[key]["xml_data"][0])

        # additional if, for running test script while waiting for resolve an issue
        if type(file_json[key]["xml_data"][0]) is not unicode:
            if notification in file_json[key]["xml_data"][0].keys():
                # print(file_json[key]["xml_data"][0][notification])
                if message == file_json[key]["xml_data"][0][notification]:
                    print(file_json[key]["xml_data"][0][notification])
                    counter += 1
            if counter == 2:
                dict_status = {"status": True}
                status.append(dict_status)
            else:
                dict_status = {"status": False}
                status.append(dict_status)

        else:
            continue

    print(counter)
    for status_x in status:
        if not status_x["status"]:
            logger.console("FINISHED: FALSE!!!!\n status: {}".format(status))
            dict_status = {"status": False}
            return dict_status
    logger.console("FINISHED: TRUE!!!!\n status: {}".format(status))
    dict_status = {"status": True}
    print(dict_status)
    return dict_status


ne3s_fm_alarmEventNotification()


def wszystko():

    file_json = import_json(json_filepath)
    # print'slownik:', (type(file_json))
    #
    # print 'lista wartosci:', type(file_json["227"].values())

    for dict_in_list in file_json["227"].values()[5]:
        # print'typ elementow listy wartosci:', type(dict_in_list)
        # print 'tutajjj:', (dict_in_list.keys())
        for x in file_json["227"].values()[5][1].values()[0][0]:
            # print "lol",(x),"-------------",
            pass
            # print x
            # print file_json["227"].values()[5][1].values()[0][0][x]
