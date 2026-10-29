import os
import json
import csv
import time
from math import radians, degrees, sin, asin
import re
import pprint
from datetime import datetime, timedelta
import xml.etree.ElementTree as ET


class jsonBeamObject():
    def __init__(self):
        pass

    def setParameters(self, jsonPath, actDynSsbBeamGen=True, actNrLBmMimoRTXPowerSaving=True):
        self.jsonFormat = 14
        self.jsonPath = jsonPath
        self.actDynSsbBeamGen = actDynSsbBeamGen
        self.actNrLBmMimoRTXPowerSaving = actNrLBmMimoRTXPowerSaving
        self.checkJsonResult = {'integrityCheck': [True, 'integrity checked PASS'],
                                'mutedSSBCheck': [True, 'dyn muted ssb checked PASS'],
                                'JsonWith5gmaxCheck': [True, 'json vs 5gmax PASS'],
                                'dynSsbPatternIdCheck': [True, 'dyn ssb checked PASS']}

    def _calculateBeamWeight(self, elements):
        element_list = []
        for element in elements:
            im_dec = int(element['im'])
            re_dec = int(element['re'])
            im_floating = im_dec / (2 ** self.jsonFormat)
            re_floating = re_dec / (2 ** self.jsonFormat)
            element_list.extend([re_floating, im_floating])
        return element_list

    def jsonToDict(self):
        self.json_dict = {}
        try:
            with open(self.jsonPath, 'r', encoding='utf-8') as f:
                self.json_dict = json.load(f)
        except Exception as e:
            print(f'BWF json File Error: {self.jsonPath}\n{e}')

    def _dictCheck(self, keys, checkedDict):
        for key in keys:
            self.integrity[key] = key in checkedDict

    def integrityCheck(self):
        self.integrity = {}
        if self.json_dict:
            try:
                self._dictCheck(['header', 'payload'], self.json_dict)
                self._dictCheck(['complex_fixed16_vectors', 'payload_info'], self.json_dict['payload'])
                payload_info_keys = [
                    'antenna_topology',
                    'beam_pattern_meta',
                    'format',
                    'identical_polarization_beams',
                    'pattern_id_info_list',
                    'vector_element_to_antenna_port_map',
                ]
                self._dictCheck(payload_info_keys, self.json_dict['payload']['payload_info'])
                patternid_info = self.json_dict['payload']['payload_info']['pattern_id_info_list']
                beamTypes = [x['beamset_type'] for x in patternid_info]
                if self.actDynSsbBeamGen:
                    self.integrity['dynamicssb'] = 'dynamicssb' in beamTypes
                    if self.actNrLBmMimoRTXPowerSaving:
                        self.integrity['dynamicssbmuted'] = 'dynamicssbmuted' in beamTypes
                    # else:
                    #     self.integrity['dynamicssbmuted'] = 'dynamicssbmuted' not in beamTypes
                else:
                    self.integrity['dynamicssb'] = 'dynamicssb' not in beamTypes
                    # self.integrity['dynamicssbmuted'] = 'dynamicssbmuted' not in beamTypes
            except Exception as e:
                print(f'Error: {e}')
        check_result = False if False in self.integrity.values() else True
        print(f'Json integrity check result: {self.integrity}')
        self.checkJsonResult['integrityCheck'] = [check_result, f'Json integrity check result: {self.integrity}']
        # return check_result

    def patternIdRangeCheck(self):
        patternid_info = self.json_dict['payload']['payload_info']['pattern_id_info_list']
        print('patternid_info: ', patternid_info)
        for beam in patternid_info:
            beam_type = beam['beamset_type']
            current_pattern_id_min = beam['pattern_id_min']
            current_pattern_id_max = beam['pattern_id_max']
            if beam_type == 'dynamicssb':
                dynssb_patternid_num_check = (current_pattern_id_max - current_pattern_id_min + 1) == 65
                # if multi cell in BTS, patternid doesn't always start from 1024 for cell.
                # dynssb_patternid_range_check = current_pattern_id_min == 1024 and current_pattern_id_max == 1088
                # tips1 = f'dynamicssb pattern id should in (1024-1088): {dynssb_patternid_range_check}'
                dynssb_patternid_range_check = True
                tips1 = (f'but if multi cell in BTS, patternid does not always start from 1024 for cell.'
                         f'need check manually')
                tips2 = f'dynamicssb pattern id should have 65: {dynssb_patternid_num_check}'
                tips = tips1 + ' \n' + tips2
                print(tips)
                self.checkJsonResult['dynSsbPatternIdCheck'] = \
                    [dynssb_patternid_range_check and dynssb_patternid_num_check, tips]
                return

    def getSSBandMutedSSBInfo(self):
        self.jsonBeamWeightData = ['basicBeamSet,beamType,leftEdgeAngle,rightEdgeAngle,ssbBeamType,index,patternId,']
        self.jsonBeamWeightData[0] += ','.join([f'0_{n}_re,0_{n}_im' for n in range(0, 8)]) + ','
        self.jsonBeamWeightData[0] += ','.join([f'1_{n}_re,1_{n}_im' for n in range(0, 8)])
        self.beamWeightDict = {'dynamicssb': {}, 'dynamicssbmuted': {}}
        self.beamWeightNonDynSsb = {}
        self.patternIdAndSsbIndexDict = {}
        patternid_info = self.json_dict['payload']['payload_info']['pattern_id_info_list']
#        patternid_info.sort(key=lambda x: x['pattern_id_min'])
        beamm_weights = self.json_dict['payload']['complex_fixed16_vectors']
        print('beamm_weights length:', len(beamm_weights))
        leftEdgeAngle = self.json_dict['payload']['payload_info']['beam_pattern_meta']['left_edge_angle']
        rightEdgeAngle = self.json_dict['payload']['payload_info']['beam_pattern_meta']['right_edge_angle']
        index = 0
        for beam in patternid_info:
            beam_type = beam['beamset_type']
            current_pattern_id_min = beam['pattern_id_min']
            current_pattern_id_max = beam['pattern_id_max']
            ssb_index, refine_index, otherIndex = -1, -1, -1
            ssb_beam_num = [1, 2, 4, 6]
            refine_beam_num = [4, 8, 16, 24]
            beamset = 'beamSet_1'
            print(beam_type, current_pattern_id_min, current_pattern_id_max)
            for patternid in range(current_pattern_id_min, current_pattern_id_max+1):
                beamElements = self._calculateBeamWeight(beamm_weights[index]['elements'])
                beamElements_str = ','.join([str(x) for x in beamElements])
                if beam_type in ['default', 'predefined']:
                    break
                if beam_type in ['dynamicssb', 'dynamicssbmuted']:
                    if beam_type == 'dynamicssb':
                        beamName = "SSB" if (patternid - current_pattern_id_min) % 5 == 0 else "Refine"
                    if beam_type == 'dynamicssbmuted':
                        beamName = 'SSB'
                    if beamName == 'SSB':
                        if ssb_index < ssb_beam_num[0] - 1:
                            ssb_index += 1
                        else:
                            del ssb_beam_num[0]
                            ssb_index = 0
                            beamset = f'beamSet_{ssb_beam_num[0]}'
                        cur_index = ssb_index
                    elif beamName == 'Refine':
                        if refine_index < refine_beam_num[0] - 1:
                            refine_index += 1
                        else:
                            del refine_beam_num[0]
                            refine_index = 0
                        cur_index = refine_index
                    self.jsonBeamWeightData.append(f'{beamset},{beam_type},{leftEdgeAngle},{rightEdgeAngle},'
                                                   f'{beamName},{cur_index},{patternid},{beamElements_str}')
                    new_key = f'{beamset},{leftEdgeAngle},{rightEdgeAngle},{beamName},{cur_index}'
                    self.beamWeightDict[beam_type][new_key] = beamElements
                    self.patternIdAndSsbIndexDict[str(patternid)] = str(ssb_index)
                    print(f'patternid: {patternid}, ssb: {ssb_index}')
                elif beam_type != 'ulssbcorrelatedbeam':
                    otherIndex += 1
                    self.jsonBeamWeightData.append(f'L{leftEdgeAngle}_R{rightEdgeAngle},{beam_type},{leftEdgeAngle},'
                                                   f'{rightEdgeAngle},,{otherIndex},{patternid},{beamElements_str}')
                    new_key = f'L{leftEdgeAngle}_R{rightEdgeAngle},{beam_type},{otherIndex}'
                    self.beamWeightNonDynSsb[new_key] = beamElements
                index += 1

    def checkPatternIdAndSsbIndexInBip(self, bip_json_path, expectedSSB=0):
        bip_json_str = ''
        bip_json_list = []
        result_list = []
        result = False
        print(self.patternIdAndSsbIndexDict)
        try:
            with open(bip_json_path, 'r', encoding='utf-8') as f:
                bip_json_list = json.load(f)
            with open(bip_json_path, 'r', encoding='utf-8') as f:
                bip_json_str = f.read()
        except Exception as e:
            tips = 'BIP json File Error: {bip_json_path}\n{e}'
            print(tips)
            return [False, tips]
        regexp = re.compile(r'"DlData_PdschGrantL1sw.patternId_item": "(\d+)"')
        patternid_list = regexp.findall(bip_json_str)
        if patternid_list:
            for index, message in enumerate(bip_json_list):
                dl_pdsch = message['_source']['layers']['icom_5g']['nr_l1dl_l2ps']['dldata_pdschsendreql1sw']
                sfn = dl_pdsch['nr_l1dl_l2ps_dldata_pdschsendreql1sw_t']['3gpp.sfn']
                slot = dl_pdsch['nr_l1dl_l2ps_dldata_pdschsendreql1sw_t']['3gpp.slot']
                patternid1 = int(patternid_list[2 * index])
                patternid2 = int(patternid_list[2 * index + 1])
                patternid1_maptossb = self.patternIdAndSsbIndexDict.get(patternid1, -1)
                patternid2_maptossb = self.patternIdAndSsbIndexDict.get(patternid2, -1)
                if patternid1_maptossb != -1:
                    if patternid1_maptossb == expectedSSB:
                        patternid1_check = True
                    else:
                        patternid1_check = False
                    print(f'sfn:{sfn}, slot:{slot}, '
                          f'{patternid1}->ssb:{patternid1_maptossb} VS ssb:{expectedSSB} '
                          f'--------------matched:{patternid1_check}')
                    result_list.append(patternid1_check)
                else:
                    print(f'sfn:{sfn}, slot:{slot}, {patternid1} not a ssb or refine patternid')

                if patternid2_maptossb != -1:
                    if patternid2_maptossb == expectedSSB and patternid2_maptossb != -1:
                        patternid2_check = True
                    else:
                        patternid2_check = False
                    print(f'sfn:{sfn}, slot:{slot}, '
                          f'{patternid2}->ssb:{patternid2_maptossb} VS ssb:{expectedSSB} --matched:{patternid2_check}')
                    result_list.append(patternid2_check)
                else:
                    print(f'sfn:{sfn}, slot:{slot}, {patternid2} not a ssb or refine patternid')
            if result_list:
                result = False if False in result_list else True
                if result:
                    tips = 'patternid check PASS'
                else:
                    tips = 'patternid check failed, some patternid mismatched, pls check !!!'
            else:
                result = False
                tips = 'no ssb or refine patternid found, pls check'
            return [result, tips]
        else:
            tips = 'Empty Bip File, Pls check'
            print(tips)
            return [False, tips]

    def writeToCsv(self):
        path = os.path.split(self.jsonPath)
        filename = path[1].replace('.json', '')
        output_path = path[0] + fr'/{filename}.csv'
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(self.jsonBeamWeightData))
        print(f'json->csv saved in: {output_path}')
        return output_path

    def checkMutedDynSSB(self):
        if not self.actNrLBmMimoRTXPowerSaving:
            tips = 'actNrLBmMimoRTXPowerSaving = False, not need to check muted SSB'
            print(tips)
            self.checkJsonResult['mutedSSBCheck'] = [True, tips]
            return
        mutedSsbBeamWeight = self.beamWeightDict['dynamicssbmuted']
        ssbBeamWeight = self.beamWeightDict['dynamicssb']
        result_dict = {}
        for key, value in mutedSsbBeamWeight.items():
            beforeHalf = ssbBeamWeight[key][:16] == value[:16]
            afterHalf = value[16:] == [0] * 16
            result_dict[key] = beforeHalf and afterHalf
            print('mutedSSB vs ssb: ', key, result_dict[key])
        result = False if False in result_dict.values() else True
        self.checkJsonResult['mutedSSBCheck'] = [result, str(result_dict)]

    def checkNonDynSsbMutedBeamWeight(self):
        if not self.beamWeightNonDynSsb:
            tips = 'There is no non-dynssb beam in json'
            self.checkJsonResult['mutedNonDynSsbCheck'] = [True, tips]
            return
        result_dict = {}
        for key, value in self.beamWeightNonDynSsb.items():
            if 'dynamicmuted' in key or 'dftnormalmuted' in key:
                afterHalf = value[16:] == [0] * 16
                result_dict[key] = afterHalf
                print('muted beam last half check: ', key, afterHalf)
        result = False if False in result_dict.values() else True
        if result:
            nok_list = []
        else:
            nok_list = [x for x in result_dict if result_dict[x] is False]
        self.checkJsonResult['mutedNonDynSsbCheck'] = [result, nok_list]

    def get5gMaxBeamWeight(self, csvPath):
        self.beamWeight5gMaxDict = {}
        with open(csvPath, 'r', encoding='utf-8') as f:
            csv_reader = csv.reader(f)
            next(csv_reader)
            for row in csv_reader:
                beamset = row[0]
                leftEdgeAngele = row[1]
                rightEdgeAngele = row[2]
                beamName = row[3]
                cur_index = row[4]
                beamElements = row[5:]
                PR850509_config = (leftEdgeAngele == '60' and rightEdgeAngele == '60'
                                   and beamset == 'beamSet_1' and beamName == 'Refine')
                if not PR850509_config:
                    new_key = f'{beamset},{leftEdgeAngele},{rightEdgeAngele},{beamName},{cur_index}'
                    self.beamWeight5gMaxDict[new_key] = beamElements

    def checkDynSSBwith5gMax(self, gap=0.00011):
        result_dict = {}
        check_result = False
        ssbBeamWeight = self.beamWeightDict['dynamicssb']
        beamWeight5gMax = self.beamWeight5gMaxDict
        for key, value_json in ssbBeamWeight.items():
            if key in beamWeight5gMax:
                value_5gmax = beamWeight5gMax[key]
                for x, y in zip(value_json, value_5gmax):
                    diff = float(x) - float(y)
                    if diff > gap:
                        print(f'{key}, json:{x}, 5gmax:{y}, diff:{diff}')
                diffs = [(float(x) - float(y)) < gap for x, y in zip(value_json, value_5gmax)]
                check_result = False if False in diffs else True
                result_dict[key] = check_result
                print('json vs 5gmax: ', key, check_result)
        result = False if False in result_dict.values() else True
        self.checkJsonResult['JsonWith5gmaxCheck'] = [result, str(result_dict)]

    def genneraterSsbAngle(self, beamConfig, mcs_type='topyong'):
        print('beamConfig: ', beamConfig)
        angles = []
        beam_config_split = beamConfig.split('_')
        Nbeam = int(beam_config_split[1])
        leftEdgeAngle = -int(beam_config_split[2][1:])
        rightEdgeAngle = int(beam_config_split[3][1:])
        Dssb_h = (sin(radians(rightEdgeAngle)) - sin(radians(leftEdgeAngle))) / Nbeam
        beamWidth_ssb_h = round(degrees(asin(Dssb_h)), 2) if Nbeam > 1 else rightEdgeAngle - leftEdgeAngle
        print(f'ssb beam width:{beamWidth_ssb_h}')
        for i in range(Nbeam):
            beamIdx = i + 1
            azimuthAngle_ssb = (
                int(round(degrees(asin(sin(radians(leftEdgeAngle)) + (beamIdx - 1) * Dssb_h + Dssb_h / 2)), 0)))
            evevationAngle = -7 if mcs_type == 'topyong' else 97
            print(f'ssb_index:{i}, ssb center angle:({azimuthAngle_ssb}, {evevationAngle})')
            angles.append({'h_angle': azimuthAngle_ssb, 'v_angle': evevationAngle, 'expected_ssb': i})
        return {beamConfig: angles}

    def checkJsonFile(self, jsonPath, actDynSsbBeamGen=True, actNrLBmMimoRTXPowerSaving=True, csv5gMaxPath=None):
        self.setParameters(jsonPath, actDynSsbBeamGen, actNrLBmMimoRTXPowerSaving)
        self.jsonToDict()
        self.integrityCheck()
        self.getSSBandMutedSSBInfo()
        self.writeToCsv()
        self.checkMutedDynSSB()
        self.get5gMaxBeamWeight(csvPath=csv5gMaxPath)
        self.checkDynSSBwith5gMax()
        self.patternIdRangeCheck()
        self.checkNonDynSsbMutedBeamWeight()
        result_list = [value[0] for value in self.checkJsonResult.values()]
        result = True if False not in result_list else False
        return [result, self.checkJsonResult, self.patternIdAndSsbIndexDict]

    def getNonDynSsbBeamWeight(self):
        return self.beamWeightNonDynSsb


NUM_SSB_BLOCKS = {"beamSet_1": "1 beam", "beamSet_2": "2 beams", "beamSet_4": "4 beams", "beamSet_6": "6 beams"}


def updateParemeterList(actDynSsbBeamGen, actNrLBmMimoRTXPowerSaving, NRCELL_DN, NRCELLGRP_DN, NRBTS_DN,
                        beamConfig, other_parameter=[], nrBtsBeamRefinementP2='false', beamsMuted=0,
                        release='SBTS26R1'):
    actDynSsbBeamGen_str = str(actDynSsbBeamGen).lower()
    actNrLBmMimoRTXPowerSaving_str = str(actNrLBmMimoRTXPowerSaving).lower()
    beam_config_split = beamConfig.split('_')
    basicBeamSet = beam_config_split[0] + '_' + beam_config_split[1]
    leftEdgeAngle = beam_config_split[2][1:]
    rightEdgeAngle = beam_config_split[3][1:]
    ssbBlock = NUM_SSB_BLOCKS[basicBeamSet]
    beamset = [{
        'basicBeamSet': basicBeamSet,
        'leftEdgeAngle': leftEdgeAngle,
        'rightEdgeAngle': rightEdgeAngle,
        'lowerEdgeAngle': '120',
        'upperEdgeAngle': '60',
        'tiltOffset': '0',
        'nrBtsBeamRefinementP2': nrBtsBeamRefinementP2,
        'beamsMuted': beamsMuted
    }]
    new_list = [
        dict(dist_name=NRCELL_DN, parameter='beamSet', value=beamset, operation='update'),
        dict(dist_name=NRCELLGRP_DN, parameter='numberOfTransmittedSsBlocks', value=ssbBlock, operation='update'),
        dict(dist_name=NRBTS_DN, parameter='actNrLBmMimoRTXPowerSaving', value=actNrLBmMimoRTXPowerSaving_str,
             operation='update'),
    ]
    flag_non_25R3 = dict(dist_name=NRCELL_DN, parameter='actDynSsbBeamGen', value=actDynSsbBeamGen_str,
                         operation='update')
    if actDynSsbBeamGen_str == "true":
        flag_25R3 = dict(dist_name=NRCELL_DN, parameter='tmpActFeat1', value=2048, operation='update')
    else:
        flag_25R3 = dict(dist_name=NRCELL_DN, parameter='tmpActFeat1', value=0, operation='update')
    if release == 'SBTS25R3':
        if not actDynSsbBeamGen:
            flag_25R3['operation'] = 'delete'
        new_list.append(flag_25R3)
    else:
        new_list.append(flag_non_25R3)
    for other in other_parameter:
        dist_name = other['dist_name']
        para_list = dist_name.split('/')
        if 'NRCELL-' in para_list[-1]:
            other['dist_name'] = NRCELL_DN
    new_list.extend(other_parameter)
    return new_list


def getDataFromSparkCsvLog(csvPath, beamConfig, actDynSsbBeamGen='', h_angle='', v_angle='', ue_index=1):
    dataList = []
    resultList = []
    with open(csvPath, 'r', encoding='utf-8') as f:
        csvReader = csv.DictReader(f)
        for row in csvReader:
            if '' not in row.values():
                dataList.append(row)
        beamid_list = sorted(list(set([x['NR Serving Beam ID'] for x in dataList])))
        for beamid in beamid_list:
            rsrp_list = [float(x['NR SSB RSRP[dBm]']) for x in dataList if x['NR Serving Beam ID'] == beamid]
            sinr_list = [float(x['NR SSB SINR[dB]']) for x in dataList if x['NR Serving Beam ID'] == beamid]
            dl_list = [float(x['NR MAC Thr. DL [Mbps]']) for x in dataList if x['NR Serving Beam ID'] == beamid]
            ul_list = [float(x['NR MAC Thr. UL [Mbps]']) for x in dataList if x['NR Serving Beam ID'] == beamid]
            dl_bler_list = [float(x['NR PDSCH iBLER[%]']) for x in dataList if x['NR Serving Beam ID'] == beamid]
            ul_bler_list = [float(x['NR PUSCH iBLER[%]']) for x in dataList if x['NR Serving Beam ID'] == beamid]
            resultList.append({
                'beamConfig': beamConfig,
                'beamid': beamid,
                'RSRP': avgList(rsrp_list),
                'SINR': avgList(sinr_list),
                'DL(Mps)': avgList(dl_list),
                'UL(Mps)': avgList(ul_list),
                'DL_Bler(%)': avgList(dl_bler_list),
                'UL_Bler(%)': avgList(ul_bler_list),
                'Samples': len(rsrp_list),
                'log_path': csvPath,
                'actDynSsbBeamGen': str(actDynSsbBeamGen).lower(),
                'H_angle(MCS)': h_angle,
                'V_angle(MCS)': v_angle,
                'UE': 'UE-' + str(ue_index)})
    return resultList


def avgList(numList):
    if numList:
        return str(sum(numList) / len(numList))
    else:
        return 'N/A'


fieldnames = ['beamConfig', 'beamid', 'RSRP', 'SINR', 'DL(Mps)', 'UL(Mps)', 'DL_Bler(%)', 'UL_Bler(%)',
              'Samples', 'log_path', 'actDynSsbBeamGen', 'H_angle(MCS)', 'V_angle(MCS)', 'UE']


def ueDataSaveToNewCsv(output_filename, data):
    with open(output_filename, 'a', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writerows(data)


def initUeDataFile(output_filename):
    with open(output_filename, 'w', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()


def compareFeatureDisableAndEnabledFromNewCsv(csvPath, checkedItem=['RSRP', 'beamid', 'DL']):
    newDict = {}
    with open(csvPath, 'r', encoding='utf-8') as f:
        csvReader = csv.DictReader(f)
        for row in csvReader:
            # print(row)
            key = "{}_({}_{})".format(row['beamConfig'], row['H_angle(MCS)'], row['V_angle(MCS)'])
            newDict.setdefault(key, {'beamid': {}, 'RSRP': {}, 'SINR': {}, 'DL': {}, 'UL': {}})
            newDict[key]['beamid'][row['actDynSsbBeamGen']] = row['beamid']
            newDict[key]['RSRP'][row['actDynSsbBeamGen']] = row['RSRP']
            newDict[key]['SINR'][row['actDynSsbBeamGen']] = row['SINR']
            newDict[key]['DL'][row['actDynSsbBeamGen']] = row['DL(Mps)']
            newDict[key]['UL'][row['actDynSsbBeamGen']] = row['UL(Mps)']
    if newDict:
        result_false_list = []
        for key, value in newDict.items():
            for item in checkedItem:
                # print(key, value)
                false_value = float(value[item]['false'])
                true_value = float(value[item]['true'])
                if item == 'beamid':
                    result = false_value == true_value
                else:
                    if abs(true_value) > 0:
                        result = True if ((
                            (false_value / true_value) >= 0.98 or abs(false_value - true_value) < 1.5)
                                          or false_value <= true_value) else False
                    else:
                        result = False
                if not result:
                    print(f'[failed]{key}_{item}_({false_value}, {true_value})')
                    result_false_list.append(f'[failed]{key}_({false_value}, {true_value})')
                else:
                    print(f'[ok]{key}_{item}_({false_value}, {true_value})')
        if result_false_list:
            return [False, result_false_list]
        else:
            return [True, 'check success']
    else:
        return [False, f'check failed, no data in {csvPath} !!!']


def checkSparkUeDataSsbIndex(csvPath, expectedSsbDict):
    result_false_list = []
    newExpectedDict = {}
    for beamConfig, angles in expectedSsbDict.items():
        for angle in angles:
            key = "{}_({}_{})".format(beamConfig, angle['h_angle'], angle['v_angle'])
            newExpectedDict[key] = angle['expected_ssb']
    with open(csvPath, 'r', encoding='utf-8') as f:
        csvReader = csv.DictReader(f)
        for row in csvReader:
            key = "{}_({}_{})".format(row['beamConfig'], row['H_angle(MCS)'], row['V_angle(MCS)'])
            if key in newExpectedDict:
                actual_ssb = int(row['beamid'])
                expected_ssb = int(newExpectedDict[key])
                if actual_ssb != expected_ssb:
                    print(f'[failed]{key}_actual_ssb:{actual_ssb}_expected:{expected_ssb}')
                    result_false_list.append(f'[failed]{key}_actual_ssb:{actual_ssb}_expected:{expected_ssb}')
                else:
                    print(f'[ok]{key}_actual_ssb:{actual_ssb}_expected:{expected_ssb}')
    if result_false_list:
        return [False, result_false_list]
    else:
        return [True, 'check success']


emfFieldames = ['distName', 'beamPatternId', 'ssbId', 'beamType', 'gainConfDirection',
                'maxGainAndDirection', 'minGainAndDirection', 'nrBeamEmfId', 'note']


def emfInfoToCsv(output_filename, beamEmf, note, patternIdAndSsbMapDict):
    data = []
    with open(output_filename, 'a', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=emfFieldames)
        writer.writeheader()
        for beamEmfItem in beamEmf:
            beamEmfItem['parameters']['distName'] = beamEmfItem['distName']
            beamEmfItem['parameters']['note'] = note
            patternId = beamEmfItem['parameters']['beamPatternId']
            beamEmfItem['parameters']['ssbId'] = ''
            if patternIdAndSsbMapDict:
                if patternId in patternIdAndSsbMapDict:
                    beamEmfItem['parameters']['ssbId'] = patternIdAndSsbMapDict[patternId]
            data.append(beamEmfItem['parameters'])
        writer.writerows(data)


Weekday_Dict = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'}


def getFiveMinuteAgoTimeInfo():
    now = datetime.now()
    print("current time:", now.strftime('%Y-%m-%d %H:%M:%S'))
    five_minutes_ago = now - timedelta(minutes=5)
    print("five_minutes_ago:", five_minutes_ago.strftime('%Y-%m-%d %H:%M:%S'))
    hour = five_minutes_ago.hour
    minute = five_minutes_ago.minute
    weekday_number = five_minutes_ago.isoweekday()
    weekday = Weekday_Dict[weekday_number]
    return hour, minute, weekday


def checkUeDlRank(csvPath):
    dataList = []
    with open(csvPath, 'r', encoding='utf-8') as f:
        csvReader = csv.DictReader(f)
        for row in csvReader:
            if '' not in row.values():
                dataList.append(row)
    Rank_List = [x['NR Rank Most DL'] for x in dataList]
    print('Rank DL:', Rank_List)
    rank2_check_list = Rank_List[5:105]
    rank4_check_list = Rank_List[-105:-5]
    expected_rank2_list = ['2'] * 100
    expected_rank4_list = ['4'] * 100
    result = (expected_rank2_list == rank2_check_list) and (expected_rank4_list == rank4_check_list)
    return result


def checkUeTputData(csvPath, if_dl, if_ul, expected_dl_tput=700, expected_ul_tput=100):
    dataList = []
    result_dl, result_ul = True, True
    with open(csvPath, 'r', encoding='utf-8') as f:
        csvReader = csv.DictReader(f)
        for row in csvReader:
            if '' not in row.values():
                dataList.append(row)
    if if_dl:
        Tput_List_dl = [float(x['NR MAC Thr. DL [Mbps]']) for x in dataList]
        Rank_List_dl = [float(x['NR Rank Most DL']) for x in dataList]
        Tput_List_dl = filterTputData(Tput_List=Tput_List_dl, expected_tput=expected_dl_tput, gap=300)
        dl_avg = float(avgList(Tput_List_dl))
        dl_rank_avg = float(avgList(Rank_List_dl))
        if dl_rank_avg < 4:
            expected_dl_tput = expected_dl_tput / 4 * dl_rank_avg
        result_dl = dl_avg >= expected_dl_tput
        print('DL_tput: ', dl_avg)
        if not result_dl:
            print(f'dl tput not reached expected {dl_avg}Mbps < {expected_dl_tput}Mbps')
        else:
            print(f'actual dl tput is {dl_avg}Mbps > {expected_dl_tput}Mbps')
    if if_ul:
        Tput_List_ul = [float(x['NR MAC Thr. UL [Mbps]']) for x in dataList]
        Tput_List_ul = filterTputData(Tput_List=Tput_List_ul, expected_tput=expected_ul_tput, gap=30)
        ul_avg = float(avgList(Tput_List_ul))
        result_ul = ul_avg >= expected_ul_tput
        print('UL_tput: ', ul_avg)
        if not result_ul:
            print(f'ul tput not reached expected: {ul_avg}Mbps < {expected_ul_tput}Mbps')
        else:
            print(f'actual ul tput is {ul_avg}Mbps > {expected_ul_tput}Mbps')
    return result_dl and result_ul


def filterTputData(Tput_List, expected_tput, gap):
    isLargerThanExpectedGap = False
    resultList = []
    for index, tput in enumerate(Tput_List):
        if tput > expected_tput - gap:
            isLargerThanExpectedGap = True
            resultList = Tput_List[index:]
    if isLargerThanExpectedGap:
        return resultList
    else:
        return Tput_List[20:]


def update_imsi_in_xml(file_path, new_imsi):
    """
    Updates the IMSI value in the given XML file.

    :param file_path: Path to the XML file.
    :param new_imsi: New IMSI value to set.
    """
    # Parse the XML file
    tree = ET.parse(file_path)
    root = tree.getroot()

    # Find the <msid> element with type="IMSI"
    msid_element = root.find(".//msid[@type='IMSI']")
    if msid_element is not None:
        # Update the IMSI value
        msid_element.text = new_imsi
        # Save the updated XML back to the file
        tree.write(file_path, encoding="UTF-8", xml_declaration=True)
        print(f"IMSI updated to {new_imsi} in {file_path}")
    else:
        print("IMSI element not found in the XML file.")


if __name__ == '__main__':
    curPath = os.path.split(os.path.realpath(__file__))[0]
    jsonName = '2025_09_16_13_27_55_868_CP_beamSet_4_37790_619151362.json'
    # beamObj = jsonBeamObject()
    # beamObj.setParameters(jsonPath=f'{curPath}/../Log/[2]CNI-147150_2/{jsonName}')
    # beamObj.jsonToDict()
    # beamObj.integrityCheck()
    # beamObj.getSSBandMutedSSBInfo()
    # beamObj.writeToCsv()
    # beamObj.checkMutedDynSSB()
    # beamObj.get5gMaxBeamWeight(csvPath=f'{curPath}/AQQJ_SSB_Weight_5G_MAX.csv')
    # beamObj.checkDynSSBwith5gMax()
    # beamObj.patternIdRangeCheck()
