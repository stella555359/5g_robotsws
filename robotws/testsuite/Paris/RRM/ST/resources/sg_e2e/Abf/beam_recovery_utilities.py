#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""

import csv
import json

recovery_headers = ['msg_id',
                    'date_time',
                    'timestamp',
                    'Version',
                    'Num_Attempt',
                    'SSB_ID',
                    'CSI_RS_ID',
                    'RACH_Result',
                    'Contention_Type',
                    'Trigger_CRNTI',
                    'Att_CRNTI',
                    'Rach_Reason',
                    'Trigger_Carrier_Id',
                    'Attempt_Carrier_Id',
                    'RACH_Contention']

Abfrbeams = [4, 5, 6, 7, 12, 13, 14, 15, 20, 21, 22, 23, 28, 29, 30, 31, 36, 37, 38, 39, 44, 45, 46, 47,
             52, 53, 54, 55, 60, 61, 62, 63]

l1l2_headers = ['info',
                'slot',
                'occasion',
                'sfn',
                'peakMetric',
                'initialTa']

pRach_occ = [{'ssb': 4, 'sfn': 1, 'slot': 9, 'occasion': 0},
             {'ssb': 5, 'sfn': 1, 'slot': 9, 'occasion': 1},
             {'ssb': 6, 'sfn': 1, 'slot': 9, 'occasion': 2},
             {'ssb': 7, 'sfn': 1, 'slot': 19, 'occasion': 0},
             {'ssb': 12, 'sfn': 1, 'slot': 19, 'occasion': 1},
             {'ssb': 13, 'sfn': 1, 'slot': 19, 'occasion': 2},
             {'ssb': 14, 'sfn': 1, 'slot': 29, 'occasion': 0},
             {'ssb': 15, 'sfn': 1, 'slot': 29, 'occasion': 1},
             {'ssb': 20, 'sfn': 1, 'slot': 29, 'occasion': 2},
             {'ssb': 21, 'sfn': 1, 'slot': 39, 'occasion': 0},
             {'ssb': 22, 'sfn': 1, 'slot': 39, 'occasion': 1},
             {'ssb': 23, 'sfn': 1, 'slot': 39, 'occasion': 2},
             {'ssb': 28, 'sfn': 1, 'slot': 49, 'occasion': 0},
             {'ssb': 29, 'sfn': 1, 'slot': 49, 'occasion': 1},
             {'ssb': 30, 'sfn': 1, 'slot': 49, 'occasion': 2},
             {'ssb': 31, 'sfn': 1, 'slot': 59, 'occasion': 0},
             {'ssb': 36, 'sfn': 1, 'slot': 59, 'occasion': 1},
             {'ssb': 37, 'sfn': 1, 'slot': 59, 'occasion': 2},
             {'ssb': 38, 'sfn': 1, 'slot': 69, 'occasion': 0},
             {'ssb': 39, 'sfn': 1, 'slot': 69, 'occasion': 1},
             {'ssb': 44, 'sfn': 1, 'slot': 69, 'occasion': 2},
             {'ssb': 45, 'sfn': 1, 'slot': 79, 'occasion': 0},
             {'ssb': 46, 'sfn': 1, 'slot': 79, 'occasion': 1},
             {'ssb': 47, 'sfn': 1, 'slot': 79, 'occasion': 2},
             {'ssb': 52, 'sfn': 3, 'slot': 9, 'occasion': 0},
             {'ssb': 53, 'sfn': 3, 'slot': 9, 'occasion': 1},
             {'ssb': 54, 'sfn': 3, 'slot': 9, 'occasion': 2},
             {'ssb': 55, 'sfn': 3, 'slot': 19, 'occasion': 0},
             {'ssb': 60, 'sfn': 3, 'slot': 19, 'occasion': 1},
             {'ssb': 61, 'sfn': 3, 'slot': 19, 'occasion': 2},
             {'ssb': 62, 'sfn': 3, 'slot': 29, 'occasion': 0},
             {'ssb': 63, 'sfn': 3, 'slot': 29, 'occasion': 1}]


def recovery_analysis_ue(ue_csv_file):
    """
    this function return successfully internal beamId recovrery after beam fealure
    """
    rachAttempts = {}           # 'include all rach attempts due to beam failure
    rachAttempts_cnxReq = {}    # 'include all connexion request attempts
    recovery_suxx = {}          # 'include only rach attempts success after beam failure

    with open(ue_csv_file, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        columns = {}
        for i, col in enumerate(reader.fieldnames):
            columns.update({recovery_headers[i]: col})
        msg_id = ''
        CRNTI = ''
        Rach_Reason = ''
        RACH_Contention = ''
        for row in reader:
            if row[columns['msg_id']] == '0xB889':
                msg_id = '0xB889'
                Rach_Reason = row[columns['Rach_Reason']]
                RACH_Contention = row[columns['RACH_Contention']]
                CRNTI = row[columns['Trigger_CRNTI']]
            elif row[columns['msg_id']] == '0xB88A' and msg_id == '0xB889':
                if row[columns['RACH_Result']] == 'SUCCESS' and row[columns['Att_CRNTI']] == CRNTI:
                    ssb = int(row[columns['SSB_ID']])
                    ibeam = Abfrbeams.index(ssb) + 1
                    if 'PDCCH' in row[columns['Contention_Type']] and 'PDCCH' in RACH_Contention and \
                            'BEAM_FAILURE' in Rach_Reason:
                        if ibeam not in rachAttempts.keys():
                            rachAttempts.update({ibeam: int(row[columns['Num_Attempt']])})
                            recovery_suxx.update({ibeam: 1})
                        else:
                            rachAttempts[ibeam] += int(row[columns['Num_Attempt']])
                            recovery_suxx[ibeam] += 1
                    elif 'UL_GRANT' in row[columns['Contention_Type']] and 'UL_GRANT' in RACH_Contention and \
                            'CONNECTION_REQUEST' in Rach_Reason:
                        if ibeam not in rachAttempts_cnxReq.keys():
                            rachAttempts_cnxReq.update({ibeam: int(row[columns['Num_Attempt']])})
                        else:
                            rachAttempts_cnxReq[ibeam] += int(row[columns['Num_Attempt']])
                    msg_id = ''
                    CRNTI = ''
                    Rach_Reason = ''
                    RACH_Contention = ''
    return {
        'rachAttempts': rachAttempts,
        'rachAttempts_cnxReq': rachAttempts_cnxReq,
        'recovery_suxx': recovery_suxx
        }


def recovery_analysis_pmCounters(pmcounter_json, nrcell='NRCELL-1'):
    """
    this function return recovery failure/success eNB counters
    sum by ointernal beam Id.
    """
    result = {}
    with open(pmcounter_json, 'r') as csvfile:
        beamCounters = json.load(csvfile)
        for pmdics in beamCounters:
            for pmdic in pmdics.values():
                for kpm, vpm in pmdic.items():
                    for k, v in vpm.items():
                        if nrcell in k:
                            if kpm not in result.keys():
                                result.update({kpm: int(v)})
                            else:
                                result[kpm] += int(v)
    return result


def recovery_analysis_l1l2(l1l2_traces):
    """
        this function compare between counted Ue beam recovery successfully and l1l2 attach success counters
    """
    columns = {}
    ibeams = {}

    with open(l1l2_traces, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for i, col in enumerate(reader.fieldnames):
            columns.update({l1l2_headers[i]: col})
        for row in reader:
            slot = int(row[columns['slot']], 16)
            sfn = int(row[columns['sfn']], 16) % 4
            occasion = int(row[columns['occasion']], 16)
            for pRach in pRach_occ:
                if pRach['slot'] == slot and pRach['sfn'] == sfn and pRach['occasion'] == occasion:
                    ibeam = Abfrbeams.index(pRach['ssb']) + 1
                    if ibeam not in ibeams.keys():
                        ibeams.update({ibeam: 1})
                    else:
                        ibeams[ibeam] += 1
                    break
    return ibeams


def gnbCouters_vs_UeLogs(gNB_pmCounters, ue_prach):
    """
    this function compare between counted Ue beam recovery successfully and eNB counters
    """
    msgErr = ''
    if not bool(ue_prach['recovery_suxx']):
        msgErr = "Error a problem occured with Ue logs\n"

    # First compare with Ue as refrence
    for k, v in ue_prach['recovery_suxx'].items():
        pmkey = 'M55305C100{:02d}'.format(k)
        if pmkey not in gNB_pmCounters.keys():
            msgErr += "Ue Reported internal beam {} not reported by eNB counters\n".format(pmkey)
        else:
            if v != gNB_pmCounters[pmkey]:
                msgErr += "Error on Reported internal beam {} gNB: {} vs Ue: {}\n".format(
                    pmkey, gNB_pmCounters[pmkey], v)

    # Second compare with eNB pmcounters as ref
    for k, v in gNB_pmCounters.items():
        if 'M55305C100' in k:
            pmkey = int(k[-2:])
            if pmkey not in ue_prach.keys() and v > 0:
                msgErr += "Reported gNB counter {} not reported by Ue logs\n".format(k)
    return msgErr


def gNBL1L2_vs_UeLogs(l1l2_prach, ue_prach):
    msgErr = ''
    if not bool(ue_prach):
        msgErr = "Error a problem occured with Ue logs\n"

    ue_cnt = ue_prach['rachAttempts'].copy()

    for k, v in ue_prach['rachAttempts_cnxReq'].items():
        if k not in ue_cnt.keys():
            ue_cnt.update({k: v})
        else:
            ue_cnt[k] += v

    for k, v in ue_cnt.items():
        if k in l1l2_prach:
            if v != l1l2_prach[k]:
                msgErr += "Error on Reported internal beam {} gNB trace: {} vs Ue: {}\n".format(k, l1l2_prach[k], v)
        else:
            msgErr += "Ue Reported internal beam {} not reported by eNB traces\n".format(k)

    for k, v in l1l2_prach.items():
        if k in ue_cnt:
            if v != ue_cnt[k]:
                msgErr += "Error on Reported internal beam {} gNB trace: {} vs Ue: {}\n".format(k, v, ue_cnt[k])
        else:
            msgErr += "gNB traces Reported internal beam {} not reported by Ue traces\n".format(k)
    return msgErr
