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


def check_prb_for_paired_json(s_prb=0, n_prb=273):
    print(f"Checking for s_prb: {s_prb}, n_prb: {n_prb}.")
    tti_content = read_json_tti()
    numOfUEs = 2
    rntis, numOfPRBs, startPrbs = [], [], []
    count, startprb = {}, {}
    count_all, count_correct = 0, 0
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            rnti = tti_event['dlFdSchedData']['body']['eventHeader']['rnti']
            physCellId = tti_event['dlFdSchedData']['body']['eventHeader']['physCellId']
            if physCellId == 501:
                if rnti not in rntis:
                    rntis.append(rnti)
                count[rnti] = count.get(rnti, 0) + 1
    sorted_count = sorted(count.items(), key=lambda x: x[1], reverse=True)
    print("Counted found RNTIs: ", sorted_count)
    used_rntis = [rnti[0] for rnti in sorted_count[:numOfUEs]]
    print("used_rntis: ", used_rntis)
    for tti_event in tti_content['events']:
        for rnti in used_rntis:
            if 'dlFdSchedData' in tti_event:
                if rnti == tti_event['dlFdSchedData']['body']['eventHeader']['rnti']:
                    count_all = count_all + 1
                    start_prb = tti_event['dlFdSchedData']['body']['startPrb']
                    numOf_Prb = tti_event['dlFdSchedData']['body']['numOfPrb']
                    if start_prb == s_prb and numOf_Prb >= n_prb:
                        count_correct += 1
                        if numOf_Prb not in numOfPRBs:
                            numOfPRBs.append(numOf_Prb)
                        if start_prb not in startPrbs:
                            startPrbs.append(start_prb)
                        startprb[start_prb] = startprb.get(start_prb, 0) + 1
    print("numOfPRBs: ", numOfPRBs)
    print("startPrbs:", startPrbs)
    print("count_all: ", count_all)
    print("count_correct: ", count_correct)
    sorted_startprb = sorted(startprb.items(), key=lambda x: x[1], reverse=True)
    print("sorted_startprb: ", sorted_startprb)
    assert (count_correct / count_all) * 100 > 40, f"dlFdSchedData startPrb and numOfPrb need to be checked"
    return True


def count_occurrences(lst):
    occurrences = {}
    for item in lst:
        if item in occurrences:
            occurrences[item] += 1
        else:
            occurrences[item] = 1
    return occurrences


def check_ue_mupaired():
    mupair = []
    not_mupair = []
    tti_content = read_json_tti()
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            rnti = tti_event['dlFdSchedData']['body']['eventHeader']['rnti']
            physCellId = tti_event['dlFdSchedData']['body']['eventHeader']['physCellId']
            if physCellId == 501:
                muStatus = tti_event['dlFdSchedData']['body']['muStatus']
                mupair.append(muStatus) if muStatus == "MUPAIR" else not_mupair.append(muStatus)
    print("muPair: ", len(mupair))
    print("not_mupair: ", len(not_mupair))
    print("not_mupair %: ", ((len(not_mupair) / (len(mupair) + len(not_mupair)) * 100)))
    not_mupair_counter = count_occurrences(not_mupair)
    print("Not_mupair details:")
    for status, count in not_mupair_counter.items():
        print(f"Status: {status}, Number of occurrences: {count}")
    assert (len(mupair) / (len(not_mupair) + len(mupair)) * 100) >= 80, f"MUPAIR below 80%"
    return True
