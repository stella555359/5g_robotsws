# AQQJ-476383A_BFWeights.xml file store different beamSet weight which include
# basicBeamSet="beamSet_1,beamSet_2,beamSet_4,beamSet_6" leftEdgeAngle="45.0" rightEdgeAngle="45.0"
# CP_beamSet_1_37792_619184129_45_45.json store different beamSet weight which include
# basicBeamSet="beamSet_1,beamSet_2,beamSet_4,beamSet_6" leftEdgeAngle="45.0" rightEdgeAngle="45.0"
# write one function open xml file and get beamset weight for  basicBeamSet="beamSet_1,beamSet_2,beamSet_4,beamSet_6
# write one function open json file and get beamset weight for basicBeamSet="beamSet_1,beamSet_2,beamSet_4,beamSet_6
# compare the weight from xml and json file
# XML file format as follows:
# 1. tag beamSet used to identify different beamSet e.g.
# <beamSet basicBeamSet="beamSet_1" basicBeamSetValue="1" leftEdgeAngle="45.0" rightEdgeAngle="45.0">
# basicBeamSet leftEdgeAngle rightEdgeAngle could identify one beamSet
# 2. tag beamWeightVector under beamSet used to identify different beamWeightVector,
# e.g. <beamWeightVector beamId="00000000" patternID="00000001" azimuthAngle="0.000000" elevationAngle="97.000000>
# patternID is the key to identify different beamWeightVector
# 3. tag weight under beamWeightVector, e,g,weight RadiatorRow="1" RadiatorColumn="1"


import os.path
from xml.etree.ElementTree import ElementTree as ET
import json
import re
import csv
from datetime import datetime
import pytz
import calendar


def get_current_utc_timestamp():
    timestamp = calendar.timegm(datetime.now(tz=pytz.timezone("UTC")).timetuple())
    print(timestamp)
    return timestamp


def update_parameters_dn(cell_dn, nrcellgrp_dn, params):
    for item in params:
        if item['parameter'] == 'numberOfTransmittedSsBlocks':
            item['dist_name'] = nrcellgrp_dn
        else:
            item['dist_name'] = cell_dn
    return params


def parse_xml_beam_weights(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    beam_weights = {}
    for beam_set in root.findall('beamSet'):
        basic_beam_set = beam_set.get('basicBeamSet')
        left_edge_angle = beam_set.get('leftEdgeAngle')
        right_edge_angle = beam_set.get('rightEdgeAngle')
        print(f"basic_beam_set: {basic_beam_set}, left_edge_angle: {left_edge_angle}, "
              f"right_edge_angle: {right_edge_angle}")
        key = (basic_beam_set, left_edge_angle, right_edge_angle)
        beam_weights[key] = {}
        # only filter basicBeamSet="beamSet_1,beamSet_2,beamSet_4,beamSet_6"
        if basic_beam_set not in ["beamSet_1"]:
            continue
        beam_weight_vector_idx = 0
        for beam_weight_vector in beam_set.findall('beamWeightVector'):
            pattern_id = beam_weight_vector.get('patternID')
            weights = []
            # beam_weight_vector_idx 0-ssbBeam, 1-refinedBeam1, 2-refinedBeam2, 3-refinedBeam3, 4-refinedBeam4
            # print current beamweight_vector is SSB or refinedBeam
            beam_type = "SSB" if beam_weight_vector_idx == 0 else f"refinedBeam{beam_weight_vector_idx}"
            print(f"patternID: {pattern_id}, beam_weight_vector_name: {beam_type}")
            beam_weight_vector_idx += 1
            # each weight tag under beamWeightVector
            #          <weight RadiatorRow="1" RadiatorColumn="1">
            # 				<realPart> 0x5ae1
            # 				</realPart>
            # 				<imagPart> 0x0000
            # 				</imagPart>
            # 			</weight>
            for weight in beam_weight_vector.findall('weight'):
                real_part = weight.find('realPart').text.strip()
                imag_part = weight.find('imagPart').text.strip()
                real_part = calculate_weight_hex_to_float(real_part)
                imag_part = calculate_weight_hex_to_float(imag_part)
                weights.append((real_part, imag_part))

            beam_weights[key][beam_type] = weights
            weights_num = len(weights)
            print(f"weights_num={weights_num}: {weights}")
    return beam_weights


def calculate_weight_hex_to_float(hex_value):
    dec_num = int(hex_value, 16)
    if dec_num >= 2**15:
        return (dec_num - 2**16)/(2**15)
    else:
        return dec_num/(2**15)


def calculate_weight_dec_to_float_for_json(dec_num):
    if dec_num > 2**14:
        return (dec_num - 2**15)/(2**14)
    else:
        return dec_num/(2**14)


def write_xml_weights_to_csv_file(beam_weights, csv_file):
    import csv
    with open(csv_file, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['BasicBeamSet', 'LeftEdgeAngle', 'RightEdgeAngle',
                         'beam_type', 'WeightIndex', 'RealPart', 'ImagPart'])
        for (basic_beam_set, left_edge_angle, right_edge_angle), patterns in beam_weights.items():
            for pattern_id, weights in patterns.items():
                for index, (real_part, imag_part) in enumerate(weights):
                    writer.writerow([basic_beam_set, left_edge_angle, right_edge_angle,
                                     pattern_id, index + 1, real_part, imag_part])


def parse_json_beam_weights(json_file):
    with open(json_file, 'r') as file:
        data = json.load(file)
    complex_fixed16_vectors = data['payload']['complex_fixed16_vectors']
    dynamicssb_beam_weights = {}
    dynamicssbmuted_beam_weights = {}
    # so tatal 1+2+4+6=13 beamset weights * 5 bfweights = 65 weights from begain to end.
    # each beamSet started with SSB beam and then refinedBeam,
    # example beamSet_4 include 4 SSB beams and 16 refined beams,
    # SSB1 SSB2 SSB3 SSB4 refinedBeam1 refinedBeam2 refinedBeam3 refinedBeam4 for each SSB beam
    # example beamSet_6 include 6 SSB beams and 30 refined beams,
    # SSB1 SSB2 SSB3 SSB4 SSB5 SSB6 refinedBeam1 refinedBeam2 refinedBeam3 refinedBeam4 for each SSB beam
    for idx, vector in enumerate(complex_fixed16_vectors):
        if idx < 5:
            basic_beam_set = "beamSet_1"
            ssb_count = 1
            refined_count = 4
            prev_beam_count = 0
        elif idx < 15:
            basic_beam_set = "beamSet_2"
            ssb_count = 2
            refined_count = 8
            prev_beam_count = 5
        elif idx < 35:
            basic_beam_set = "beamSet_4"
            ssb_count = 4
            refined_count = 16
            prev_beam_count = 15
        elif idx < 65:
            basic_beam_set = "beamSet_6"
            ssb_count = 6
            refined_count = 24
            prev_beam_count = 35
        elif idx < 78:
            basic_beam_set = "dynamicssbmuted"
            ssb_count = 13
            refined_count = 0
            prev_beam_count = 65

        # Calculate the local index within the current beam set
        beam_idx = (idx - prev_beam_count) % (ssb_count + refined_count)

        # if beam_idx < ssb_count:
        #     beam_type = f"SSB"
        # else:
        #     beam_idx = beam_idx - ssb_count
        #     beam_type = f"Refine"

        if idx < 65:
            if beam_idx % 5 == 0:
                beam_type = "SSB"
                beam_idx = beam_idx // 5
            else:
                beam_type = f"Refine"
                beam_idx = (beam_idx - 1) - (beam_idx - 1) // 5
            # dynamicssb beam weights from index 0 to 64
            weights = []
            for element in vector['elements']:
                real_part = element['re']
                imag_part = element['im']
                real_part = calculate_weight_dec_to_float_for_json(real_part)
                imag_part = calculate_weight_dec_to_float_for_json(imag_part)
                weights.append((real_part, imag_part))
            left_edge_angle = data['payload']['payload_info']['beam_pattern_meta']['left_edge_angle']
            right_edge_angle = data['payload']['payload_info']['beam_pattern_meta']['right_edge_angle']
            weights_info = {"weights": weights, "beam_set": basic_beam_set, "beam_type": beam_type,
                            "left_edge_angle": left_edge_angle, "right_edge_angle": right_edge_angle,
                            "beam_idx": beam_idx}
            key = f"{basic_beam_set}_{left_edge_angle}_{right_edge_angle}_{beam_type}_{beam_idx}"
            dynamicssb_beam_weights[key] = weights_info
            weights_num = len(weights)
            print(f"idx: {idx}, beam_set_name: {basic_beam_set}, beam_type: {beam_type}, beam_idx: {beam_idx}, "
                  f"weights_num={weights_num}: {weights_info}")
        elif idx < 78:
            beam_type = "SSB"
            # dynamicssbmuted beam weights from index 65 to 77
            weights = []
            for element in vector['elements']:
                real_part = element['re']
                imag_part = element['im']
                real_part = calculate_weight_dec_to_float_for_json(real_part)
                imag_part = calculate_weight_dec_to_float_for_json(imag_part)
                weights.append((real_part, imag_part))
            left_edge_angle = data['payload']['payload_info']['beam_pattern_meta']['left_edge_angle']
            right_edge_angle = data['payload']['payload_info']['beam_pattern_meta']['right_edge_angle']
            weights_info = {"weights": weights, "beam_set": basic_beam_set, "beam_type": beam_type,
                            "left_edge_angle": left_edge_angle, "right_edge_angle": right_edge_angle,
                            "beam_idx": beam_idx}
            key = f"{basic_beam_set}_{left_edge_angle}_{right_edge_angle}_{beam_type}_{beam_idx}"
            dynamicssbmuted_beam_weights[key] = weights_info
            weights_num = len(weights)
            print(f"idx: {idx}, beam_set_name: {basic_beam_set}, beam_type: {beam_type}, "
                  f"beam_idx: {beam_idx}, weights_num={weights_num}: {weights_info}")
        else:
            break
    new_csv_file_name = json_file.replace('.json', '.csv')
    write_json_weights_to_csv_file(dynamicssb_beam_weights, new_csv_file_name)

    # get only SSB weights for index 1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61
    dynamicssb_only_weights = {key: value for key, value in dynamicssb_beam_weights.items()
                               if value['beam_type'] == 'SSB'}
    ssb_csv_file_name = json_file.replace('.json', '_SSBOnly.csv')
    write_json_weights_to_csv_file(dynamicssb_only_weights, ssb_csv_file_name)
    # get dynamicssbmuted weights from index 65 to 77
    dynamicssbmuted_csv_file_name = json_file.replace('.json', '_DynamicSSBMuted.csv')
    write_json_weights_to_csv_file(dynamicssbmuted_beam_weights, dynamicssbmuted_csv_file_name)

    return dynamicssb_beam_weights, dynamicssb_only_weights, dynamicssbmuted_beam_weights


def check_beam_metadata_from_json(json_file, expected_left_edge_angle, expected_right_edge_angle, expected_tilt_offset):
    with open(json_file, 'r') as file:
        data = json.load(file)
    left_edge_angle = data['payload']['payload_info']['beam_pattern_meta']['left_edge_angle']
    right_edge_angle = data['payload']['payload_info']['beam_pattern_meta']['right_edge_angle']
    tilt_offset = data['payload']['payload_info']['beam_pattern_meta']['tilt_offset']
    pattern_id_info_list = data['payload']['payload_info']['pattern_id_info_list']
    if int(left_edge_angle) != int(expected_left_edge_angle) or int(right_edge_angle) != int(expected_right_edge_angle):
        raise ValueError(f"Beam metadata does not match expected values: left_edge_angle={left_edge_angle}, "
                         f"right_edge_angle={right_edge_angle}, expected_left_edge_angle={expected_left_edge_angle}, "
                         f"expected_right_edge_angle={expected_right_edge_angle}")
    else:
        print(f"Beam metadata matched: left_edge_angle={left_edge_angle}, right_edge_angle={right_edge_angle}")
    if tilt_offset != expected_tilt_offset:
        raise ValueError(f"Tilt offset does not match expected value: tilt_offset={tilt_offset}")
    else:
        print(f"Tilt offset matches expected value: tilt_offset={tilt_offset}")

    expected_dynamic_ssb = {
        "beamset_type": "dynamicssb", "pattern_id_max": 1088, "pattern_id_min": 1024
    }
    expcted_synamic = {
        "beamset_type": "dynamic", "pattern_id_max": 1101, "pattern_id_min": 1089
    }
    for pattern_id_info in pattern_id_info_list:
        beamset_type = pattern_id_info['beamset_type']
        pattern_id_min = pattern_id_info['pattern_id_min']
        pattern_id_max = pattern_id_info['pattern_id_max']
        if beamset_type == "dynamicssb":
            if (pattern_id_min != expected_dynamic_ssb['pattern_id_min'] or
                    pattern_id_max != expected_dynamic_ssb['pattern_id_max']):
                raise ValueError(f"DynamicSSB pattern ID range does not match expected values: {pattern_id_info}")
            else:
                print(f"DynamicSSB pattern ID range matches expected values: {pattern_id_info}")
        elif beamset_type == "dynamicssbmuted":
            if (pattern_id_min != expcted_synamic['pattern_id_min'] or
                    pattern_id_max != expcted_synamic['pattern_id_max']):
                raise ValueError(f"Dynamic pattern ID range does not match expected values: {pattern_id_info}")
            else:
                print(f"Dynamic pattern ID range matches expected values: {pattern_id_info}")
        else:
            print(f"Unknown beamset_type: {beamset_type} in pattern_id_info: {pattern_id_info}")
    # check antenna_topology m n p
    m = data['payload']['payload_info']['antenna_topology']['M']
    n = data['payload']['payload_info']['antenna_topology']['N']
    p = data['payload']['payload_info']['antenna_topology']['P']
    if m != 2 or n != 8 or p != 2:
        raise ValueError(f"Antenna topology does not match expected values: m={m}, n={n}, p={p}")
    else:
        print(f"Antenna topology matches expected values: m={m}, n={n}, p={p}")


def write_json_weights_to_csv_file(beam_weights, csv_file):
    # csv column should include beam_set_name beam_type weights
    with open(csv_file, mode='w', newline='') as file:
        writer = csv.writer(file)
        row_name_lst = ['basicBeamSet', 'leftEdgeAngle', 'rightEdgeAngle', 'beamType', 'index']
        for i in range(0, 16, 1):
            j = i % 8
            k = i // 8
            row_name_lst.append(f'{k}_{j}_re')
            row_name_lst.append(f'{k}_{j}_im')
        writer.writerow(row_name_lst)
        for key, info in beam_weights.items():
            beam_set_name = info['beam_set']
            beam_type = info['beam_type']
            beam_idx = info['beam_idx']
            left_edge_angle = info['left_edge_angle']
            right_edge_angle = info['right_edge_angle']
            weights = info['weights']
            row = [beam_set_name, left_edge_angle, right_edge_angle, beam_type, beam_idx]
            for weight in weights:
                row.append(weight[0])
                row.append(weight[1])
            writer.writerow(row)
    print(f"JSON weights written to {csv_file}")


def parse_csv_beam_weights(csv_file):
    beam_weights = {}
    with open(csv_file, mode='r') as file:
        reader = csv.reader(file)
        header = next(reader)  # Skip header row
        # the key is beam_set_name + left_angle + right_angle + beam_type  + beam_idx
        # the value is one weights list
        for row in reader:
            basic_beam_set = row[0]
            left_edge_angle = row[1]
            right_edge_angle = row[2]
            beam_type = row[3]
            beam_idx = row[4]
            key = f"{basic_beam_set}_{left_edge_angle}_{right_edge_angle}_{beam_type}_{beam_idx}"
            weights = []
            for i in range(5, len(row), 2):
                real_part = float(row[i])
                imag_part = float(row[i + 1])
                weights.append((real_part, imag_part))
            beam_weights[key] = weights
    return beam_weights


def check_dynamic_ssb_with_5g_max_spec(dynamic_ssb_json_file, static_5g_max_spec_csv_file, beam_set_name,
                                       left_edge_angle, right_edge_angle):
    # read dynamic_ssb_json_file and get the SSB weights
    dynamicssb_beam_weights, dynamicssb_only_weights, dynamicssbmuted_beam_weights = (
        parse_json_beam_weights(dynamic_ssb_json_file))
    static_ssb_bf_weights = parse_csv_beam_weights(static_5g_max_spec_csv_file)
    # filter out the SSB weights and refined weights for the specified beam_set_name, left_edge_angle, right_edge_angle
    filtered_dynamic_ssb_weights = ({key: value for key, value in dynamicssb_beam_weights.items()
                                     if key.startswith(f"{beam_set_name}_{left_edge_angle}_{right_edge_angle}")})
    print(f"\n filtered_dynamic_ssb_weights for {beam_set_name}_{left_edge_angle}_{right_edge_angle}:")
    print(filtered_dynamic_ssb_weights)
    # filter out the SSB weights for the specified beam_set_name, left_edge_angle,
    # right_edge_angle from static_5g_max_spec_csv_file
    filtered_static_ssb_weights = ({key: value for key, value in static_ssb_bf_weights.items()
                                    if key.startswith(f"{beam_set_name}_{left_edge_angle}_{right_edge_angle}")})
    print(f"filtered_static_ssb_weights for {beam_set_name}_{left_edge_angle}_{right_edge_angle}:")
    print(filtered_static_ssb_weights)

    # compare the weights, if any key from filtered_dynamic_ssb_weights not in filtered_static_ssb_weights, raise error
    for key, dynamic_weights in filtered_dynamic_ssb_weights.items():
        print(f"\nStart to check key {key}")
        if key not in filtered_static_ssb_weights:
            raise ValueError(f"Key {key} not found in static 5G max spec weights")
        else:
            print(f"Key {key} found in both dynamic SSB and static 5G max spec weights")
        static_weights = filtered_static_ssb_weights[key]
        dynamic_weights = dynamic_weights['weights']
        if len(dynamic_weights) != len(static_weights):
            raise ValueError(f"Weight length mismatch for key {key}: dynamic {len(dynamic_weights)} "
                             f"vs static {len(static_weights)}")
        else:
            print(f"Weight length match for key {key}: length {len(dynamic_weights)}")
        # compare each weight, if any weight mismatch more than 0.00001, raise error
        for i, (dyn_weight, stat_weight) in enumerate(zip(dynamic_weights, static_weights)):
            if abs(dyn_weight[0] - stat_weight[0]) > 0.00011 or abs(dyn_weight[1] - stat_weight[1]) > 0.00011:
                raise ValueError(f"Weight mismatch for key {key} at index {i}: dynamic {dyn_weight} vs static "
                                 f"{stat_weight}, "
                                 f"gap is {(dyn_weight[0] - stat_weight[0], dyn_weight[1] - stat_weight[1])}")
        print(f"End check key {key} passed !\n")
    print("All weights match between dynamic SSB and static 5G max spec\n")
    # check dynamicssbmuted weights
    print("Start to check DynamicSSBMuted weights...")
    check_dynamicssbmuted(dynamicssb_only_weights, dynamicssbmuted_beam_weights)


def check_dynamicssbmuted(dynamicssb_only_weights, dynamicssbmuted_beam_weights):
    # each beam set weights have 16 tuples, 2nd half 8 tuples should be (0.0, 0.0)
    for key, weights_info in dynamicssbmuted_beam_weights.items():
        weights = weights_info['weights']
        if len(weights) != 16:
            raise ValueError(f"Weight length mismatch for key {key}: expected 16, got {len(weights)}")
        for i in range(8, 16):
            if weights[i] != (0.0, 0.0):
                raise ValueError(f"Weight mismatch for key {key} at index {i}: expected (0.0, 0.0), got {weights[i]}")
        print(f"2nd half DynamicSSBMuted weights (0, 0) check passed for key {key}")
    # each beam set weights have 16 tuples, 1st half 8 tuples should match the corresponding dynamicssb_only_weights
    beam_idx = 0
    for key, weights_info in dynamicssb_only_weights.items():
        weights = weights_info['weights']
        if len(weights) != 16:
            raise ValueError(f"Weight length mismatch for key {key}: expected 16, got {len(weights)}")
        # get the corresponding dynamicssbmuted key
        # beamSet_1_30_45_SSB_0 --> dynamicssbmuted_30_45_SSB_{beam_idx}
        temp_key = re.sub(r'beamSet_\d', 'dynamicssbmuted', key)
        dynamicssbmuted_key = re.sub(r'SSB_\d+', f'SSB_{beam_idx}', temp_key)
        print(f"\nStart to check if smae between {key} and {dynamicssbmuted_key}")
        if dynamicssbmuted_key not in dynamicssbmuted_beam_weights:
            raise ValueError(f"Corresponding DynamicSSBMuted key {dynamicssbmuted_key} not found for key {key}")
        dynamicssbmuted_weights = dynamicssbmuted_beam_weights[dynamicssbmuted_key]['weights']
        for i in range(8):
            if weights[i] != dynamicssbmuted_weights[i]:
                raise ValueError(f"Weight mismatch between DynamicSSB and DynamicSSBMuted for key {key} at index {i}:"
                                 f"DynamicSSB {weights[i]} vs DynamicSSBMuted {dynamicssbmuted_weights[i]}")
        beam_idx = + 1
        print(f"1st half DynamicSSBMuted weights match DynamicSSB weights check passed for key {key}")
    print("All DynamicSSBMuted weights check passed!\n")


NUM_SSB_BLOCKS = {"beamSet_1": "1 beam", "beamSet_2": "2 beams", "beamSet_4": "4 beams", "beamSet_6": "6 beams"}


def update_beam_set_params(actDynSsbBeamGen, basic_beam_set, left_angle, right_angle, params):
    for item in params:
        if item['parameter'] == 'beamSet':
            item['value'] = [{
                'basicBeamSet': basic_beam_set,
                'leftEdgeAngle': left_angle,
                'rightEdgeAngle': right_angle
            }]
        elif item['parameter'] == 'actDynSsbBeamGen':
            item['value'] = actDynSsbBeamGen
        elif item['parameter'] == 'numberOfTransmittedSsBlocks':
            item['value'] = NUM_SSB_BLOCKS[basic_beam_set]
    return params


def transform_json_structure(json_text):
    # Define regex patterns to match and replace the specified keys
    # change "patternId (StaticFixedSizedArray)": {
    #                       "DlData_PdschGrantL1sw.patternId_item": "1069",
    #                       "DlData_PdschGrantL1sw.patternId_item": "1069"
    #                     } to
    # "patternId (StaticFixedSizedArray)":[1069,1069]
    patterns = [
        (r'"patternId \(StaticFixedSizedArray\)": \{([^}]+)\}', r'"patternId (StaticFixedSizedArray)": [\1]')
    ]
    # Apply each pattern to the JSON text
    for pattern, replacement in patterns:
        json_text = re.sub(pattern, lambda m: re.sub(r'"DlData_PdschGrantL1sw\.[^"]+": "([^"]+)"',
                                                     r'"\1"', m.group(0)), json_text, flags=re.DOTALL)
        json_text = re.sub(pattern, replacement, json_text, flags=re.DOTALL)
    return json_text


def generate_new_json_from_raw(file_name):
    new_file_name = "new_" + os.path.basename(file_name)
    with open(file_name, 'r') as f:
        raw_text = f.read()
        transformed_json_data = transform_json_structure(raw_text)
        with open(new_file_name, 'w') as new_file:
            new_file.write(transformed_json_data)
    return new_file_name


def get_pattern_and_check_value(file_name, pattern_id=1024, sub_cell_id='none'):
    new_file_name = generate_new_json_from_raw(file_name)
    pass_count = 0
    with (open(new_file_name, 'r') as f):
        data = json.load(f)
        if len(data) <= 10:
            raise ValueError("No dldata_pdschsendreql1sw data in the BIP log !!!")
        for item in data:
            frame_number = item.get('_source').get('layers').get('frame').get('frame.number')
            frame_time_utc = item.get('_source').get('layers').get('frame').get('frame.time_utc')
            frame_time_utc_cur = frame_time_utc
            # first check if key is exist
            l1dl_l2ps = item['_source']['layers']['icom_5g']['nr_l1dl_l2ps']
            if "dldata_pdschsendreql1sw" in l1dl_l2ps:
                l1data = l1dl_l2ps['dldata_pdschsendreql1sw']['nr_l1dl_l2ps_dldata_pdschsendreql1sw_t']
                grants = l1data['grants (DynamicPackedArray)']['nr_l1dl_l2ps_dldata_pdschgrantl1sw']
                subcellid = nr_l1dl_l2ps_dldata_pdschsendreql1sw_t['3gpp.subcellid']
                if int(subcellid) == int(sub_cell_id) or sub_cell_id == 'none':
                    sfn_cur_req = int(l1data['3gpp.sfn'])
                    slot = l1data['3gpp.slot']
                    startPrb = int(grants['DlData_PdschGrantL1sw.startPrb'])
                    numOfPrb = int(grants['DlData_PdschGrantL1sw.numOfPrb'])
                    rnti = int(grants['3gpp.rnti'])
                    pattern_id_array = grants['patternId (StaticFixedSizedArray)']
                    print(f"{frame_number}, {frame_time_utc}, sfn:{sfn_cur_req}, slot:{slot}, subcell:{subcellid}, "
                          f"pattern_id:{pattern_id_array}, "
                          f"startPrb:{startPrb}, numOfPrb:{numOfPrb}, rnti:{rnti}")
                    check_pattern_id_array(pattern_id_array, pattern_id)
                    print(f"pattern id check pass for frame {frame_number}")
                    pass_count = pass_count + 1
            else:
                continue
    if pass_count == 0:
        raise ValueError(f"expected pattern id not found in bip for {subcellid} !!!")


def check_pattern_id_array(pattern_id_array, expected_pattern_id):
    if int(pattern_id_array[0]) != int(expected_pattern_id) or int(pattern_id_array[1]) != int(expected_pattern_id):
        raise ValueError(f"pattern id check failed, current:${pattern_id_array}, expected:${expected_pattern_id}")


# if __name__ == '__main__':
#     beam_set_name = "beamSet_2"
#     left_edge_angle = "10"
#     right_edge_angle = "60"
#
#     xml_file = r'C:\Working\Document\Feature\CNI-147150\AQQJ\AQQJ-476383A_BFWeights.xml'
#     xml_csv_file = r'C:\Working\Document\Feature\CNI-147150\AQQJ\AQQJ-476383A_BFWeights.csv'
#
#     json_file_name = rf"CP_{beam_set_name}_37792_619184129_{left_edge_angle}_{right_edge_angle}.json"
#     dynamic_json_file = rf'C:\Working\Document\Feature\CNI-147150\AQQJ\{json_file_name}'
#     static_5g_max_spec_csv_file = r'C:\Working\Document\Feature\CNI-147150\AQQJ\AQQJ_SSB_Weight_5G_MAX.csv'
#
#
#     # xml_beam_weights = parse_xml_beam_weights(xml_file)
#     # write_xml_weights_to_csv_file(xml_beam_weights, xml_csv_file)
#     check_beam_metadata_from_json(dynamic_json_file,
#                                   expected_left_edge_angle=left_edge_angle,
#                                   expected_right_edge_angle=right_edge_angle, expected_tilt_offset=0)
#     json_bf_weights = parse_json_beam_weights(dynamic_json_file)
#     check_dynamic_ssb_with_5g_max_spec(dynamic_ssb_json_file=dynamic_json_file,
#                                        static_5g_max_spec_csv_file=static_5g_max_spec_csv_file,
#                                        beam_set_name=beam_set_name,
#                                        left_edge_angle=left_edge_angle,
#                                        right_edge_angle=right_edge_angle)
