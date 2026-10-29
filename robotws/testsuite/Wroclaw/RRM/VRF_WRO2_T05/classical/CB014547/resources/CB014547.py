from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import os
import re
import json


def read_json_tti(tti_collector_name='TTI', decoded_output_file=None):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = os.path.join(tti_collector_name, testname) if decoded_output_file is None \
        else os.path.join(tti_collector_name, '{}_{}'.format(testname, decoded_output_file))
    file_json = os.path.join(outputdir, decoded_output_file + '.json')
    print("file_json: ", file_json)
    with open(file_json, 'r') as json_content:
        content = json.load(json_content)
    return content


def count_occurrences(lst):
    occurrences = {}
    for item in lst:
        if item in occurrences:
            occurrences[item] += 1
        else:
            occurrences[item] = 1
    return occurrences


def check_beamtype(cellId, should_be_subband):
    tti_content = read_json_tti()
    numOfUEs = 4
    rntis, beamtype, wrong_beamType = [], [], []
    count = {}
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            rnti = tti_event['dlFdSchedData']['body']['eventHeader']['rnti']
            physCellId = tti_event['dlFdSchedData']['body']['eventHeader']['physCellId']
            if str(physCellId) == str(cellId):
                if rnti not in rntis:
                    rntis.append(rnti)
                count[rnti] = count.get(rnti, 0) + 1
    sorted_count = sorted(count.items(), key=lambda x: x[1], reverse=True)
    print("Counted found RNTIs: ", sorted_count)
    used_rntis = [rnti[0] for rnti in sorted_count[:numOfUEs]]
    print("used_rntis: ", used_rntis)
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            rnti = tti_event['dlFdSchedData']['body']['eventHeader']['rnti']
            physCellId = tti_event['dlFdSchedData']['body']['eventHeader']['physCellId']
            if str(physCellId) == str(cellId) and rnti == used_rntis[0]:
                bt = tti_event['dlFdSchedData']['body']['beamType']
                beamtype.append(bt) if str(bt) == "SUBBAND" else wrong_beamType.append(bt)
    print("beamType: ", len(beamtype))
    print("wrong_beamType: ", len(wrong_beamType))
    print("wrong_beamType %: ", ((len(wrong_beamType) / (len(beamtype) + len(wrong_beamType)) * 100)))
    not_mupair_counter = count_occurrences(wrong_beamType)
    print("Not_mupair details:")
    for status, count in not_mupair_counter.items():
        print(f"Status: {status}, Number of occurrences: {count}")
    if should_be_subband == 'True':
        assert (len(beamtype) / (len(wrong_beamType) + len(beamtype)) * 100) == 100, \
              f"Not all beamType equal to SUBBAND for cell " + str(cellId)
    else:
        assert (len(beamtype) / (len(wrong_beamType) + len(beamtype)) * 100) == 0, \
            f"Some beamType equal to SUBBAND for cell " + str(cellId)
    return True
