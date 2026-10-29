import json


def read_json(file):
    dist_obj = {}
    with open(file) as json_file:
        data = json.load(json_file)

        for item in data:
            # print(item['distName'])
            tmp = {}
            dist_obj[item['distName']] = {}
            # print(item['operation'])
            # print(item['parameters'])
            for para in item['parameters']:
                if para['operation'] != 'delete':
                    tmp[para['parameterName']] = para['value']

            dist_obj[item['distName']] = tmp
            # break
    return data, dist_obj


def get_value(moc, key):
    lst = []
    items = moc[key]
    for item in items:
        print("---->", item)
        tmp_dict = {}
        tmp_dict[item] = items[item]
        lst.append(tmp_dict)
        print(lst)
    return lst
    # return moc[key]


def chk_value(val, operation):

    nw_val = {}
    delim = '/'
    istdd = 1
    for p_key in val:
        if isinstance(val[p_key], list) and isinstance(val[p_key][0], dict):

            n_key = delim + p_key + delim + str(0) + delim
            print(n_key)
            if operation == 'create':
                nw_val[delim + p_key] = ''
            for x in val[p_key]:
                for c_key in x:
                    tmp_key = n_key
                    tmp_key += c_key
                    print(tmp_key, "==>", x[c_key])
                    nw_val[tmp_key] = x[c_key]
                    if x[c_key] == "semiStatic":
                        istdd = 0
            print(nw_val)
            return nw_val, istdd
        else:
            print(isinstance(val[p_key], list), isinstance(val[p_key], list))
            if operation == 'create':
                nw_val[delim+p_key] = ''
            if isinstance(val[p_key], list):
                for p_key in val:
                    nw_val[delim + p_key + delim + '0'] = val[p_key][0]
                    return nw_val, istdd
            else:
                return val, istdd


def make_paras_cu(file):
    lst = []
    dl = '/'
    x, y = read_json(file)

    dist_obj = {}
    for item in x:
        tmp = {}
        distName = item['distName']
        operation = item['operation']
        paras = y[distName]
        t_tmp = {}

        dist_obj[distName] = []
        # print(distName,'===>',operation,'====>',paras)
        for key in paras:
            tmp['operation_type'] = operation
            t_tmp['parameter_path'] = dl + key
            # print(isinstance(paras[key],list),"-->",paras[key])
            if isinstance(paras[key], list) and isinstance(paras[key][0], dict):
                if operation == 'create':
                    tmp['parameter_path'] = dl + key
                    tmp['operation_type'] = operation
                    dist_obj[distName].append(tmp)
                    tmp = {}
                for c_item in paras[key]:
                    for c_key in c_item:
                        tmp['operation_type'] = operation
                        # print(c_key,"===",c_item)
                        tmp['parameter_path'] = \
                            t_tmp['parameter_path'] + dl + '0' + dl + c_key
                        # print(tmp['parameter_path'])
                        tmp['value'] = c_item[c_key]
                        # lst.append(tmp)
                        dist_obj[distName].append(tmp)
                        tmp = {}
            elif isinstance(paras[key], list):
                if operation == 'create':
                    tmp['parameter_path'] = dl + key
                    tmp['operation_type'] = operation
                    dist_obj[distName].append(tmp)
                    tmp = {}
                    for item in paras[key]:
                        tmp['operation_type'] = operation
                        tmp['parameter_path'] = dl + key + dl + '0'
                        tmp['value'] = item
                        dist_obj[distName].append(tmp)
                        tmp = {}

            else:
                tmp['parameter_path'] = t_tmp['parameter_path']
                tmp['value'] = paras[key]
                # lst.append(tmp)
                dist_obj[distName].append(tmp)
                tmp = {}
    return dist_obj


def compare_tp(filename, start_ue_idx, non_gbr_ue_tp, ue_tp, qos_profile, qos_profile_speed_ul, qos_profile_speed_dl,
               vonr_codec_rate,
               qos_profile_unit, dirct="both"):
    print("Default dirct", dirct)

    if dirct == 'both':
        (non_gbr_tp_ul_x, expected_non_gbr_tp_ul_x, non_gbr_tp_dl_x, expected_non_gbr_tp_dl_x, gbr_tp_ul_x,
         expected_gbr_tp_ul_x, gbr_tp_dl_x, expected_gbr_tp_dl_x, qfi_details,
         total_gfbr_active_ul, total_gfbr_active_dl) = get_tp(filename,
                                                              start_ue_idx,
                                                              non_gbr_ue_tp,
                                                              qos_profile,
                                                              qos_profile_speed_ul,
                                                              qos_profile_speed_dl,
                                                              vonr_codec_rate,
                                                              qos_profile_unit,
                                                              dirct="both")

        print("1st Actual non_gbr_tp_ul in UL ", non_gbr_tp_ul_x)
        print("1st expected_non_gbr_tp_ul", expected_non_gbr_tp_ul_x)
        print("1st Actual non_gbr_tp_dl in DL ", non_gbr_tp_dl_x)
        print("1st expected_non_gbr_tp_dl", expected_non_gbr_tp_dl_x)
        print("1st Actual gbr_tp_ul in UL ", gbr_tp_ul_x)
        print("1st expected_gbr_tp_ul", expected_gbr_tp_ul_x)
        print("1st Actual gbr_tp_dl in DL ", gbr_tp_dl_x)
        print("1st expected_gbr_tp_dl", expected_gbr_tp_dl_x)
        print("qfi_details", qfi_details)
        print("total_gfbr_active_ul", total_gfbr_active_ul)
        print("total_gfbr_active_dl", total_gfbr_active_dl)

        (non_gbr_tp_ul, expected_non_gbr_tp_ul, non_gbr_tp_dl, expected_non_gbr_tp_dl, gbr_tp_ul, expected_gbr_tp_ul,
         gbr_tp_dl, expected_gbr_tp_dl, qfi_details_x,
         total_gfbr_active_ul, total_gfbr_active_dl) = get_tp(filename,
                                                              start_ue_idx, ue_tp,
                                                              qos_profile,
                                                              qos_profile_speed_ul,
                                                              qos_profile_speed_dl,
                                                              vonr_codec_rate,
                                                              qos_profile_unit,
                                                              dirct="both")

        print("Actual non_gbr_tp_ul in UL ", non_gbr_tp_ul)
        print("Expected_non_gbr_tp_ul", expected_non_gbr_tp_ul)
        print("Actual non_gbr_tp_dl in DL ", non_gbr_tp_dl)
        print("Expected_non_gbr_tp_dl", expected_non_gbr_tp_dl)
        print("Actual gbr_tp_ul in UL ", gbr_tp_ul)
        print("Expected_gbr_tp_ul", expected_gbr_tp_ul)
        print("Actual gbr_tp_dl in DL ", gbr_tp_dl)
        print("Expected_gbr_tp_dl", expected_gbr_tp_dl)
        print("qfi_details", qfi_details_x)
        print("total_gfbr_active_ul", total_gfbr_active_ul)
        print("total_gfbr_active_dl", total_gfbr_active_dl)

        print(" Below should be DIP from  the Non GBR reading ")

        flag = 0
        print("GBR TP should be ~=1st reading of the non gbr tp - 2nd reading non gbr tp")

        if abs(non_gbr_tp_ul_x - non_gbr_tp_ul) <= total_gfbr_active_ul:
            print("UL: GBR TP:{0} Reading 1 NonGBR TP: {1}   2nd NonGBR TP: {2} ".format(total_gfbr_active_ul,
                                                                                         non_gbr_tp_ul_x,
                                                                                         non_gbr_tp_ul))
            flag = flag + 1
        else:
            flag = 0
            print("Failure UL: GBR TP:{0} Reading 1 NonGBR TP:{1}   2nd NonGBR TP:{2} ".format(total_gfbr_active_ul,
                                                                                               non_gbr_tp_ul_x,
                                                                                               non_gbr_tp_ul))

        if abs(non_gbr_tp_dl_x - non_gbr_tp_dl) <= total_gfbr_active_dl:
            print("DL: GBR TP: {0} Reading 1 NonGBR TP: {1}   2nd NonGBR TP: {2} ".format(total_gfbr_active_dl,
                                                                                          non_gbr_tp_dl_x,
                                                                                          non_gbr_tp_dl))
            flag = flag + 1
        else:
            flag = 0
            print("Failure DL: GBR TP{0} Reading 1 NonGBR TP: {1}   2nd NonGBR TP: {2} ".format(total_gfbr_active_dl,
                                                                                                non_gbr_tp_dl_x,
                                                                                                non_gbr_tp_dl))
        if flag == 2:
            return "Pass"
        else:
            return "Fail"

    elif dirct == 'ul':
        (non_gbr_tp_ul_x, expected_non_gbr_tp_ul_x, gbr_tp_ul_x, expected_gbr_tp_ul_x, qfi_details,
         total_gfbr_active_ul) = get_tp_ulordl(filename, start_ue_idx, non_gbr_ue_tp, qos_profile,
                                               qos_profile_speed_ul, vonr_codec_rate, qos_profile_unit)

        print("1st Actula non_gbr_tp_ul in UL ", non_gbr_tp_ul_x)
        print("1st expected_non_gbr_tp_ul", expected_non_gbr_tp_ul_x)
        print("1st Actual gbr_tp_ul in UL ", gbr_tp_ul_x)
        print("1st expected_gbr_tp_ul", expected_gbr_tp_ul_x)
        print("qfi_details", qfi_details)
        print("total_gfbr_active_ul", total_gfbr_active_ul)

        (non_gbr_tp_ul, expected_non_gbr_tp_ul, gbr_tp_ul, expected_gbr_tp_ul, qfi_details,
         total_gfbr_active_ul) = get_tp_ulordl(filename, start_ue_idx, ue_tp, qos_profile,
                                               qos_profile_speed_ul, vonr_codec_rate, qos_profile_unit)

        print("1st Actula non_gbr_tp_ul in UL ", non_gbr_tp_ul)
        print("1st expected_non_gbr_tp_ul", expected_non_gbr_tp_ul)
        print("1st Actual gbr_tp_ul in UL ", gbr_tp_ul)
        print("1st expected_gbr_tp_ul", expected_gbr_tp_ul)
        print("qfi_details", qfi_details)
        print("total_gfbr_active_ul", total_gfbr_active_ul)

        print(" Below should be DIP from  the Non GBR reading ")

        flag = 0
        print("GBR TP should be ~=1st reading of the non gbr tp - 2nd reading non gbr tp")

        if abs(non_gbr_tp_ul_x - non_gbr_tp_ul) <= total_gfbr_active_ul:
            print("UL: GBR TP:{0} Reading 1 NonGBR TP: {1}   2nd NonGBR TP: {2} ".format(total_gfbr_active_ul,
                                                                                         non_gbr_tp_ul_x,
                                                                                         non_gbr_tp_ul))
            flag = flag + 1
        else:
            flag = 0
            print("Failure UL: GBR TP:{0} Reading 1 NonGBR TP:{1}   2nd NonGBR TP:{2} ".format(total_gfbr_active_ul,
                                                                                               non_gbr_tp_ul_x,
                                                                                               non_gbr_tp_ul))
        if flag == 1:
            return "Pass"
        else:
            return "Fail"
    elif dirct == 'dl':
        (non_gbr_tp_dl_x, expected_non_gbr_tp_dl_x, gbr_tp_dl_x, expected_gbr_tp_dl_x, qfi_details,
         total_gfbr_active_dl) = get_tp_ulordl(filename, start_ue_idx, non_gbr_ue_tp, qos_profile,
                                               qos_profile_speed_dl, vonr_codec_rate, qos_profile_unit)

        print("1st Actual non_gbr_tp_dl in DL ", non_gbr_tp_dl_x)
        print("1st expected_non_gbr_tp_Dl", expected_non_gbr_tp_dl_x)
        print("1st Actual gbr_tp_ul in DL ", gbr_tp_dl_x)
        print("1st expected_gbr_tp_Dl", expected_gbr_tp_dl_x)
        print("qfi_details", qfi_details)
        print("total_gfbr_active_ul", total_gfbr_active_dl)

        (non_gbr_tp_dl, expected_non_gbr_tp_dl, gbr_tp_dl, expected_gbr_tp_dl, qfi_details,
         total_gfbr_active_dl) = get_tp_ulordl(filename, start_ue_idx, ue_tp, qos_profile,
                                               qos_profile_speed_ul, vonr_codec_rate, qos_profile_unit)

        print("1st Actual non_gbr_tp_dl in DL ", non_gbr_tp_dl)
        print("1st expected_non_gbr_tp_dl", expected_non_gbr_tp_dl)
        print("1st Actual gbr_tp_dl in DL ", gbr_tp_dl)
        print("1st expected_gbr_tp_dl", expected_gbr_tp_dl)
        print("qfi_details", qfi_details)
        print("total_gfbr_active_dl", total_gfbr_active_dl)

        print(" Below should be DIP from  the Non GBR reading ")

        flag = 0
        print("GBR TP should be ~=1st reading of the non gbr tp - 2nd reading non gbr tp")

        if abs(non_gbr_tp_dl_x - non_gbr_tp_dl) <= total_gfbr_active_dl:
            print("UL: GBR TP:{0} Reading 1 NonGBR TP: {1}   2nd NonGBR TP: {2} ".format(total_gfbr_active_dl,
                                                                                         non_gbr_tp_dl_x,
                                                                                         non_gbr_tp_dl))
            flag = flag + 1
        else:
            flag = 0
            print("Failure UL: GBR TP:{0} Reading 1 NonGBR TP:{1}   2nd NonGBR TP:{2} ".format(total_gfbr_active_dl,
                                                                                               non_gbr_tp_dl_x,
                                                                                               non_gbr_tp_dl))
        if flag == 1:
            return "Pass"
        else:
            return "Fail"


def get_tp(filename, start_ue_idx, ue_tp, qos_profile, qos_profile_speed_ul, qos_profile_speed_dl, vonr_codec_rate,
           qos_profile_unit, dirct="both"):
    #   [id,fiveqi,ul,dl]
    print("UE Index starts from", start_ue_idx)
    qfi_details = {}
    fp = open(filename, "r")
    for line in fp:
        if "gfbr" in line and ("set_qosflow" in line or "qosflow_set" in line):
            q_idx = line.split()[1].split("=")[1]
            fiveqi = line.split()[2].split("=")[1]
            gfbr_ul = line.split()[3].split("=")[1]
            gfbr_dl = line.split()[3].split("=")[1]
            qfi_details[q_idx] = list((fiveqi, gfbr_ul, gfbr_dl))
    fp.close()

    # q_idx_list = qfi_details.keys()  # GFBR QFI list 1 ==> five
    q_idx_list = list(qfi_details.keys())
    expected_gbr_tp_ul = 0
    expected_gbr_tp_dl = 0
    expected_non_gbr_tp_ul = 0
    expected_non_gbr_tp_dl = 0
    gbr_tp_ul = 0
    gbr_tp_dl = 0
    non_gbr_tp_ul = 0
    non_gbr_tp_dl = 0
    ue_id = start_ue_idx
    indx = 0
    print("dummy indx and ue_id", indx, ue_id)
    # 0 UL 1 DL
    # read_dir = 0
    total_gfbr_active_ul = 0
    total_gfbr_active_dl = 0
    ue_profile_spd_dl = []
    ue_profile_spd_ul = []
    print("To avoid error", ue_profile_spd_dl, ue_profile_spd_ul)

    read_dir = 0  # 0 UL 1 DL
    for tp in ue_tp:
        print(tp)

        if dirct == "both":
            for ue_id in tp:
                ue_profile = qos_profile[ue_id]
                print(ue_id, "UE Profile is", ue_profile)
                length = len(ue_profile)
                for i in range(length):
                    ue_profile_unit = qos_profile_unit[ue_id]
                    if "mbps" in ue_profile_unit[i]:
                        unit = 1024
                    else:
                        unit = 1

                    if read_dir == 0:
                        ue_profile_spd_ul = qos_profile_speed_ul[ue_id]
                        act_tp = tp[ue_id]  # nex

                        if ue_profile[i] in q_idx_list:
                            cfg_gfbr_ul = float(qfi_details[ue_profile[i]][1])
                            print("cfg_gfbr_ul", cfg_gfbr_ul)
                            total_gfbr_active_ul += cfg_gfbr_ul

                            if ('amr' in ue_profile_spd_ul[i] or 'g7' in ue_profile_spd_ul[i] or 'custom' in
                                    ue_profile_spd_ul[i]):
                                spd = vonr_codec_rate[ue_profile_spd_ul[i]]
                                expected_gbr_tp_ul += float(spd) * unit
                            else:
                                expected_gbr_tp_ul += float(ue_profile_spd_ul[i]) * unit
                            gbr_tp_ul = gbr_tp_ul + act_tp[i]
                        else:
                            expected_non_gbr_tp_ul += float(ue_profile_spd_ul[i]) * unit
                            non_gbr_tp_ul = non_gbr_tp_ul + act_tp[i]

                    else:  # DL Direction
                        act_tp = tp[ue_id]
                        ue_profile_spd_dl = qos_profile_speed_dl[ue_id]

                        if ue_profile[i] in q_idx_list:
                            cfg_gfbr_dl = float(qfi_details[ue_profile[i]][2])
                            print("cfg_gfbr_dl", cfg_gfbr_dl)
                            total_gfbr_active_dl += cfg_gfbr_dl

                            if ('amr' in ue_profile_spd_dl[i] or 'g7' in ue_profile_spd_dl[i] or 'custom' in
                                    ue_profile_spd_dl[i]):
                                spd = vonr_codec_rate[ue_profile_spd_dl[i]]
                                expected_gbr_tp_dl += (float(spd) * unit)
                            else:
                                expected_gbr_tp_dl += (float(ue_profile_spd_dl[i]) * unit)
                            gbr_tp_dl = gbr_tp_dl + act_tp[i]
                        else:
                            print(ue_id, "-->", i, ue_profile[i], "GBR QFI", q_idx_list)
                            expected_non_gbr_tp_dl += (float(ue_profile_spd_dl[i]) * unit)
                            non_gbr_tp_dl = non_gbr_tp_dl + act_tp[i]

            read_dir = 1

    # Diff is
    return (non_gbr_tp_ul, expected_non_gbr_tp_ul, non_gbr_tp_dl, expected_non_gbr_tp_dl, gbr_tp_ul,
            expected_gbr_tp_ul, gbr_tp_dl, expected_gbr_tp_dl, qfi_details, total_gfbr_active_ul, total_gfbr_active_dl)


def get_tp_ulordl(filename, start_ue_idx, ue_tp, qos_profile, qos_profile_speed, vonr_codec_rate, qos_profile_unit):
    #   [id,fiveqi,ul,dl]
    qfi_details = {}
    fp = open(filename, "r")
    for line in fp:
        if "gfbr" in line and ("set_qosflow" in line or "qosflow_set" in line):
            q_idx = line.split()[1].split("=")[1]
            fiveqi = line.split()[2].split("=")[1]
            gfbr_ul = line.split()[3].split("=")[1]
            gfbr_dl = line.split()[3].split("=")[1]
            qfi_details[q_idx] = list((fiveqi, gfbr_ul, gfbr_dl))
    fp.close()
    # q_idx_list = qfi_details.keys()  # GFBR QFI list 1 ==> five
    q_idx_list = list(qfi_details.keys())
    expected_gbr_tp = 0
    expected_non_gbr_tp = 0
    gbr_tp = 0
    non_gbr_tp = 0
    total_gfbr_active = 0
    ue_id = start_ue_idx
    print(ue_id)
    indx = 0
    print(indx)
    ue_profile_spd = []
    print(ue_profile_spd)
    read_dir = 0  # 0 UL 1 DL
    print(read_dir)
    for ue_id in ue_tp:

        ue_profile = qos_profile[ue_id]
        print(ue_id, "UE Profile is", ue_profile)
        length = len(ue_profile)
        for i in range(length):
            ue_profile_unit = qos_profile_unit[ue_id]
            if "mbps" in ue_profile_unit[i]:
                unit = 1024
            else:
                unit = 1

            ue_profile_spd = qos_profile_speed[ue_id]
            act_tp = ue_tp[ue_id]  # nex

            if ue_profile[i] in q_idx_list:
                cfg_gfbr = float(qfi_details[ue_profile[i]][1])
                print("cfg_gfbr_ul", cfg_gfbr)
                total_gfbr_active += cfg_gfbr
                if ('amr' in ue_profile_spd[i] or 'g7' in ue_profile_spd[i] or
                        'custom' in ue_profile_spd[i]):
                    spd = vonr_codec_rate[ue_profile_spd[i]]
                    expected_gbr_tp += float(spd) * unit
                else:
                    expected_gbr_tp += float(ue_profile_spd[i]) * unit
                gbr_tp = gbr_tp + act_tp[i]
            else:
                expected_non_gbr_tp += float(ue_profile_spd[i]) * unit
                non_gbr_tp = non_gbr_tp + act_tp[i]

    return non_gbr_tp, expected_non_gbr_tp, gbr_tp, expected_gbr_tp, qfi_details, total_gfbr_active


def check_op(output):
    try:
        if output is not None:
            return 1
        else:
            return 0
    except SyntaxError:
        print("Exception\n")
        return 1


def get_qfi(qoslist_ue, ue_qfi, idx):
    print(qoslist_ue, "========>", ue_qfi, "=============>", idx)
    # [1,2,3,4,5]    ue_qfi=0,1,2,3,4
    if str(2) == qoslist_ue[ue_qfi] or str(3) == qoslist_ue[ue_qfi] or str(4) == qoslist_ue[ue_qfi]:
        return qoslist_ue[ue_qfi]
    else:
        return idx


def verify_tp_on_dr_modif(bearer_stats_ul, remained_dur, delta_time, qos_profile_speed_ul,
                          updated_qos_profile_speed_ul, qos_profile_unit, vonr_codec_rate, updated_ue_list):
    expected_volume_of_data = 0
    total_duration = float(remained_dur)
    print(expected_volume_of_data, total_duration)
    flag = 1
    for ue_id in updated_ue_list:
        length = len(qos_profile_speed_ul[ue_id])
        for profile_idx in range(length):
            # since recv and sen should be equla check is there so pick any one
            actual_volume_of_data = bearer_stats_ul[ue_id][profile_idx][0]
            if qos_profile_unit[ue_id][profile_idx] == "mbps":
                factor = 1048576
            else:
                factor = 1024

            total_duration = float(remained_dur) + float(delta_time[ue_id][profile_idx])

            if 'amr' in qos_profile_speed_ul[ue_id][profile_idx] or 'g7' in qos_profile_speed_ul[ue_id][
                profile_idx] or 'custom' in \
                    qos_profile_speed_ul[ue_id][profile_idx]:

                spd = vonr_codec_rate[qos_profile_speed_ul[ue_id][profile_idx]]
                updated_spd = vonr_codec_rate[updated_qos_profile_speed_ul[ue_id][profile_idx]]

                if spd != updated_spd:
                    print("DIff Leg", spd, updated_spd)
                    expected_volume_of_data = (((float(spd) * float(delta_time[ue_id][profile_idx])) +
                                                (float(updated_spd) * (float(total_duration) - float(
                                                    delta_time[ue_id][profile_idx])))) * factor) / 8
                    print(expected_volume_of_data)
                else:
                    # print("No diff")
                    expected_volume_of_data = (float(spd) * (float(total_duration) * factor)) / 8
                    print(expected_volume_of_data)
            else:
                if qos_profile_speed_ul[ue_id][profile_idx] != updated_qos_profile_speed_ul[ue_id][profile_idx]:

                    expected_volume_of_data = (((float(qos_profile_speed_ul[ue_id][profile_idx]) * float(
                        delta_time[ue_id][profile_idx])) +
                                                (float(updated_qos_profile_speed_ul[ue_id][profile_idx]) *
                                                 (float(total_duration) - float(
                                                     delta_time[ue_id][profile_idx])))) * factor) / 8
                else:
                    # print("No diff")
                    expected_volume_of_data = (float(qos_profile_speed_ul[ue_id][profile_idx]) * (
                            float(total_duration) * factor)) / 8
                print(actual_volume_of_data, "<==Actual   expected==>", expected_volume_of_data)
                dif = max(float(expected_volume_of_data), float(actual_volume_of_data)) - min(
                    float(expected_volume_of_data), float(actual_volume_of_data))
                deviation = (dif / expected_volume_of_data) * 100
                print("% of deviation ", deviation)
                if float(expected_volume_of_data) < float(actual_volume_of_data):
                    if deviation > 10:
                        print("Failed High deviation between Actual TP{1} and expected deviation{0}"
                              .format(expected_volume_of_data, actual_volume_of_data))
                        flag = 0
                else:
                    if deviation > 10:
                        flag = 0
                        print(" Failed High deviation between Actual TP{1} and expected deviation{0}"
                              .format(expected_volume_of_data, actual_volume_of_data))

    if flag == 0:
        return 'Fail'
    else:
        return 'Pass'


def get_gbr_list_cfg(filename):
    qfi_details = {}
    fp = open(filename, "r")
    for line in fp:
        if "gfbr" in line and ("set_qosflow" in line or "qosflow_set" in line):
            q_idx = line.split()[1].split("=")[1]
            fiveqi = line.split()[2].split("=")[1]
            gfbr_ul = line.split()[3].split("=")[1]
            gfbr_dl = line.split()[3].split("=")[1]
            qfi_details[q_idx] = list((fiveqi, gfbr_ul, gfbr_dl))
    fp.close()

    # q_idx_list = qfi_details.keys()
    q_idx_list = list(qfi_details.keys())
    return q_idx_list
