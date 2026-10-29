import time
import datetime
import re
import csv
import os
import random
import copy


def generate_correct_rmod_distname(distname_before, rmodid):
    distname = ""
    if "_R-" in distname_before:
        distname = str(distname_before.split("RMOD_R")[0])+"RMOD_R-"+str(rmodid)
    elif "_A-" in distname_before:
        distname = str(distname_before.split("RMOD_A")[0])+"RMOD_A-"+str(rmodid)
    return distname


def get_file_name(file_path):
    basename = os.path.basename(file_path)
    basename, extention = os.path.splitext(basename)
    print(basename)
    return basename


def get_some_info_from_file_path(xml_file_path, prefix, suffix="</p>"):
    match_nums = set()
    with open(xml_file_path, "r") as f:
        pattern_str = r"%s\s*(.*?)\s*%s" % (prefix, suffix)
        pattern = re.compile(pattern_str)
        matches = re.findall(pattern, f.read())
#        print(matches)
        for match in matches:
            match_nums.add(int(match))
    return list(match_nums)


def get_errors_common_part(error_msg, module, msg):
    if not error_msg:
        return False
    error_list = error_msg[module]
    for error in error_list:
        if type(msg) is list:
            for item in msg:
                if item in error:
                    return True
        else:
            if msg in error:
                return True
    return False


def get_last_txarraycarrier_num(xml_file_path):
    with open(xml_file_path, "r") as f:
        pattern = re.compile(r'<managedObject class="TxArrayCarrier"\s*(.*?)\s*><operation>create_mo</operation>')
        matches = re.findall(pattern, f.read())
        print(matches)
        match_nums = []
        for match in matches:
            name, val = match.split("=")
            val = val.replace('"', "")
            num = val.split("_")[-1]
            match_nums.append(num)
        if match_nums:
            return match_nums[-1]
        else:
            return 0


def get_average_list(output_info_list):
    if isinstance(output_info_list, str):
        output_info_list = eval(output_info_list)

    averages = []
    for output_infos in output_info_list:
        for output_info in output_infos:
            average = output_info["average"]
            averages.append(average)
    return averages


def get_nrcell_distname(dist_before, cellid):
    distname = ""
    if "_R-" in dist_before:
        distname = str(dist_before.split("NRCELL_R")[
                       0]) + "NRCELL_R-" + str(cellid)
    elif "_A-" in dist_before:
        distname = str(dist_before.split("NRCELL_A")[
                       0]) + "NRCELL_A-" + str(cellid)
    return distname


def get_ltecell_distname_sg08(dist_before, cellid):
    distname = ""
    if "_R-" in dist_before:
        distname = str(dist_before.split("LNCEL_R")[
                       0]) + "LNCEL_R-" + str(cellid)
    elif "_A-" in dist_before:
        distname = str(dist_before.split("LNCEL_A")[
                       0]) + "LNCEL_A-" + str(cellid)
    return distname


def get_lbps_current_week_and_time():
    weekday = datetime.datetime.now().strftime("%a")
    hour = time.strftime('%H', time.localtime())
    minute = time.strftime('%M', time.localtime())
    return weekday, hour, minute


def get_deepsleep_start_time(hour, minute, addonehour=False):
    now = datetime.datetime.now()
    week_day = datetime.datetime.now().strftime("%a")
    if addonehour:
        hour = int(hour) + 1
        if hour == 24:
            hour = 0
            tomorrow = now + datetime.timedelta(days=1)
            week_day = datetime.datetime.date(tomorrow).strftime("%a")
        return week_day, '%02d:%s' % (hour, minute)
    else:
        return week_day, "%s:%s" % (hour, minute)


def check_availability_not_in_dict(availability, key_in_dict):
    if availability in key_in_dict.keys():
        return False
    else:
        return True


def get_current_time_after_add_several(hour, minute, several):
    minute = int(minute) + int(several)
    if minute >= 60:
        minute = minute - 60
        hour = int(hour) + 1
        if hour == 24:
            hour = 0
    return hour, minute


def get_day_of_week():
    return datetime.datetime.now().strftime("%a")


def get_SMOD_type(SMOD_info):
    list1 = SMOD_info.split('\n')
    Type = re.search(r'value=(.*)\r', list1[1]).group(1)
    return Type


def get_LTE_cell_distname(cell_id, objects):
    cell_distname = ''
    check_content = 'LNCEL_R-' + str(cell_id)
    for object in objects:
        cell_index = object['distName'].split("/")[-1]
        if check_content == cell_index:
            cell_distname = object['distName']
            break
    return cell_distname


def get_bbmod_distname(bbmod_index, objects):
    bb_distname = ''
    check_content = 'BBMOD_R-' + str(bbmod_index)
    for object in objects:
        bbmod_index = object['distName'].split("/")[-1]
        if check_content == bbmod_index:
            bb_distname = object['distName']
            break
    return bb_distname


def check_cell_type(nrlist, ltelist):
    if not nrlist:
        return 'lte_only'
    if not ltelist:
        return 'nr_only'
    return 'nr_lte'


def check_special_fault(fault_list, btstype):
    str1 = 'integratedtoran'
    if btstype == 'SA':
        str1 = 'configured'
        return str1
    for fault in fault_list:
        if fault == 7300:
            str1 = 'configured'
            break
    return str1


def get_add_delete_list(define_list):
    if not define_list:
        define_list = [1]
    return define_list


def read_csv_file(file_path, delimiter=","):
    with open(file_path) as csvfile:
        reader = csv.reader(csvfile, delimiter=str(delimiter))
        lines = []
        for line in reader:
            if line:
                lines.append(line)
    return lines


def get_lines_by_type(tti_log_list, type):
    lines = []
    for line in tti_log_list:
        if type == line[0]:
            lines.append(line)
    return lines


def get_lines_by_cell_id(tti_log_list, cell_id_index, cell_id=None):
    if cell_id is None:
        return tti_log_list
    else:
        lines = []
        for line in tti_log_list:
            if int(line[cell_id_index]) == cell_id:
                lines.append(line)
        return lines


def get_index_for_parameter(tti_log_list, parameter):
    for index in range(len(tti_log_list[0])):
        if parameter == tti_log_list[0][index]:
            break
    return index


def get_lines_by_type_and_paramter(file_path, type, parameter, delimiter=",", rnti=None, cell_id=None):
    lines_all = read_csv_file(file_path=file_path, delimiter=delimiter)
    rnti_index = get_index_for_parameter(tti_log_list=lines_all, parameter="rnti")
    cell_id_index = get_index_for_parameter(tti_log_list=lines_all, parameter="lcrId")
    index_parameter = get_index_for_parameter(tti_log_list=lines_all, parameter=parameter)
    lines_filtered = get_lines_by_type(tti_log_list=lines_all, type=type)
    lines_filtered = get_lines_by_cell_id(tti_log_list=lines_filtered, cell_id=cell_id, cell_id_index=cell_id_index)
    if rnti is None:
        rnti = get_rnti_for_ue(tti_log_list=lines_filtered, rnti_index=rnti_index)
    result = []
    for line in lines_filtered:
        if line[rnti_index] == rnti:
            result.append(line[index_parameter])
    return result, rnti


def get_lines_by_type_and_paramter_new(file_path, type, parameter, delimiter=",", rnti=None, cell_id=None):
    lines_all = read_csv_file(file_path=file_path, delimiter=delimiter)
    rnti_index = get_index_for_parameter(tti_log_list=lines_all, parameter="rnti")
    rtBeamFailureReason_index = get_index_for_parameter(tti_log_list=lines_all, parameter="rtBeamFailureReason")
    cell_id_index = get_index_for_parameter(tti_log_list=lines_all, parameter="lcrId")
    index_parameter = get_index_for_parameter(tti_log_list=lines_all, parameter=parameter)
    lines_filtered = get_lines_by_type(tti_log_list=lines_all, type=type)
    lines_filtered = get_lines_by_cell_id(tti_log_list=lines_filtered, cell_id=cell_id, cell_id_index=cell_id_index)
    if rnti is None:
        rnti = get_rnti_for_ue(tti_log_list=lines_filtered, rnti_index=rnti_index)
    result = []
    for line in lines_filtered:
        if type != 'srsSwitchMeasData':
            if line[rnti_index] == rnti and line[rtBeamFailureReason_index] != 'BFSBOCCUPIED':
                result.append(line[index_parameter])
        else:
            line = line[index_parameter]
            rnti_this_line = line.split("\'rnti\':")[1].split(",")[0].strip()
            if rnti_this_line == rnti:
                srsState = line.split("'srsState':")[1].split(",")[0].strip().strip("'")
                result.append(srsState)
    return result, rnti


def get_rnti_for_ue(tti_log_list, rnti_index):
    rnti_list = []
    for line in tti_log_list[1:]:
        rnti = line[rnti_index]
        if rnti not in rnti_list:
            rnti_list.append(rnti)
    rnti_count_list = []
    for rnti in rnti_list:
        number = 0
        for line in tti_log_list[1:]:
            if line[5] == rnti:
                number = number+1
        rnti_count_list.append(number)
    index = 0
    max = rnti_count_list[0]
    for i in range(1, len(rnti_count_list)):
        if rnti_count_list[i] > max:
            max = rnti_count_list[i]
            index = i
    print("rnti is: "+str(rnti_list[index]))
    return rnti_list[index]


def open_udp_port_on_VM(port=51000):
    cmd = "sudo iptables -I INPUT -i eth0 -p udp --destination-port "+str(port)+" -j ACCEPT"
    os.system(cmd)


def get_cell_with_call(tput_define):
    with_release = False
    keys = tput_define.keys()
    for key in keys:
        if str(key) == 'common' or str(key).startswith("SBTS"):
            with_release = True
            break
    if with_release is False:
        return list(tput_define.keys())
    else:
        return list(list(tput_define.values())[0].keys())


def get_ru_cell_mapping_with_call(ru_cell_all, nr_not_used, lte_not_used):
    ru_ids = ru_cell_all.keys()
    for id in ru_ids:
        ru_cells = ru_cell_all[id]
        nr_cells = ru_cells['nr']
        nr_cells_tmp = copy.deepcopy(nr_cells)
        for cell in nr_cells:
            if cell in nr_not_used:
                nr_cells_tmp.remove(cell)
        ru_cells['nr'] = nr_cells_tmp
        lte_cells = ru_cells['lte']
        lte_cells_tmp = copy.deepcopy(lte_cells)
        for cell in lte_cells:
            if cell in lte_not_used:
                lte_cells_tmp.remove(cell)
        ru_cells['lte'] = lte_cells_tmp
        nr_cells_number = len(ru_cell_all[id]['nr'])
        lte_cells_number = len(ru_cell_all[id]['lte'])
        if nr_cells_number == 0 and lte_cells_number == 0:
            ru_cell_all[id] = None
    ru_cell_all_tmp = copy.deepcopy(ru_cell_all)
    for id in ru_ids:
        ru_cells = ru_cell_all[id]
        if ru_cells is None:
            del ru_cell_all_tmp[id]
    ru_cell_call = ru_cell_all_tmp
    return ru_cell_call


def get_cell_for_call_from_ru(cells_all_info):
    cells_call = {}
    if (len(cells_all_info['nr'])) != 0:
        nr_cell_id = random.choice(cells_all_info['nr'])
        cells_call['nr'] = nr_cell_id
    if (len(cells_all_info['lte'])) != 0:
        lte_cell_id = random.choice(cells_all_info['lte'])
        cells_call['lte'] = lte_cell_id
    return cells_call


def get_all_cells_id_with_call(ru_cells_mapping_with_call):
    cell_lists = []
    keys = ru_cells_mapping_with_call.keys()
    for key in keys:
        cells = ru_cells_mapping_with_call[key]
        nr_cells = cells['nr']
        for nr_cell in nr_cells:
            cell_lists.append('nr_'+str(nr_cell))
        lte_cells = cells['lte']
        for lte_cell in lte_cells:
            cell_lists.append('lte_'+str(lte_cell))
    cell_nums = len(cell_lists)
    return cell_nums, cell_lists


def get_attenuator_and_port(carrierList, rus_config_info):
    ru_index = int(carrierList[0]['antennaLineId']['configuration'].split("RMOD-")[1].split('/')[0]) - 1
    attenuator = rus_config_info[ru_index].attenuation_ports[0].attenuator
    attenuation_ports = rus_config_info[ru_index].attenuation_ports
    port_list = []
    if carrierList[0]['antennaLineId']['configuration'].split("/")[-1].startswith("PHYANT-"):
        for attenuation_port in attenuation_ports:
            if attenuation_port.port_no not in port_list:
                port_list.append(attenuation_port.port_no)
    else:
        for cell in carrierList:
            port_index = int(cell['antennaLineId']['configuration'].split("/")[-1].split("-")[-1]) - 1
            if attenuation_ports[port_index].port_no not in port_list:
                print(attenuation_ports[port_index].port_no)
                port_list.append(attenuation_ports[port_index].port_no)
    return attenuator, port_list


def get_attenuator(carrierList, rus_config_info):
    ru_index = int(carrierList[0]['antennaLineId']['configuration'].split("RMOD-")[1].split('/')[0]) - 1
    attenuator = rus_config_info[ru_index].attenuation_ports[0].attenuator
    return attenuator


def pa_value_convert(pa_value, port_list):
    if type(pa_value) is list:
        pass
    else:
        port_num = len(port_list)
        pa_value = [pa_value] * port_num
    return pa_value


def generate_new_fault_trigger(original_trigger, operation, modify_trigger):
    original_tmp = copy.deepcopy(original_trigger)
    for item in modify_trigger:
        flag = 0
        for trigger in original_trigger:
            if item['faultNumber'] == trigger['faultNumber'] and item['triggerType'] == trigger['triggerType']:
                flag = 1
                break
        if flag == 1:
            if operation == 'add':
                pass
            elif operation == 'delete':
                item['snapshotFilterKeywords'] = trigger['snapshotFilterKeywords']
                original_tmp.remove(item)
        elif flag == 0:
            if operation == 'add':
                original_tmp.append(item)
            elif operation == 'delete':
                pass
    return original_tmp
