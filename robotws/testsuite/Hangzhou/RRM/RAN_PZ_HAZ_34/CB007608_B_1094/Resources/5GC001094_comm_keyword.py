import re


def Covert_BTS_Version(version, gnbnumber):
    scf_name = ''
    package = version.split('_')[2]
    if package == '9999':
        if str(gnbnumber) == '1':
            scf_name = 'SCF_Trunk_gNB1.xml'
        else:
            scf_name = 'SCF_Trunk_gNB2.xml'
    elif package == '0000':  # uncertain
        if str(gnbnumber) == '2':
            scf_name = 'SCF_SBTS22R1_gNB2.xml'
        else:
            scf_name = 'SCF_SBTS22R1_gNB1.xml'
    return scf_name


def Check_Wireshark_Message_Flow_From_Txt(txt_file_path, message_dict={}):
    with open(txt_file_path, "r") as f:
        lines = f.readlines()
    startLogo = 'Frame '
    lines.append(startLogo)
    order_message_list = message_dict.setdefault('order_list', [])
    not_order_message_list = message_dict.setdefault('not_order_list', [])
    should_not_include_list = message_dict.setdefault('should_not_include', [])
    i = 0
    waitForStartLine, waitForEndLine = True, False
    message_list = []
    while (i < len(lines)):
        if lines[i].startswith(startLogo):
            if waitForStartLine:
                startLine = i
                waitForStartLine, waitForEndLine = False, True
                i += 1
                continue
            if waitForEndLine:
                endLine = i
                waitForStartLine, waitForEndLine = True, False
                message_str = ''.join(lines[startLine:endLine])
                message_list.append(message_str.lower())
                startLine = i
                waitForStartLine, waitForEndLine = False, True
        i += 1
    x, y = 0, 0
    total_message_contain_list = []
    if len(order_message_list) > 0:
        while (x < len(message_list) and y < len(order_message_list)):
            order_message = order_message_list[y]
            if order_message.lower() in message_list[x]:
                total_message_contain_list.append((order_message, True))
                y += 1
            x += 1
    order_message_result = True if y == len(order_message_list) else False
    if not order_message_result:
        slit1 = order_message_list[y:]
        slit2 = [False] * (len(order_message_list) - y)
        comb = zip(slit1, slit2)
        total_message_contain_list.extend(comb)
    not_order_message_result = True
    for m in not_order_message_list:
        contain = True in [m.lower() in n for n in message_list]
        total_message_contain_list.append((m, contain))
        not_order_message_result = not_order_message_result and contain
    not_include_message_result = True
    for m in should_not_include_list:
        contain = True in [m.lower() in n for n in message_list]
        total_message_contain_list.append((m, not contain))
        not_include_message_result = not_include_message_result and (not contain)

    print(total_message_contain_list)
    return order_message_result and not_order_message_result and not_include_message_result


def Get_MeasConfig_Value_From_Dictionary(n, measid, para1, para2, measConfigDic):
    measDic = measConfigDic[str(n)]['measList'][str(measid)]
    para1id = measDic[para1 + 'id']
    return measConfigDic[str(n)][para1][para1id][para2]


def Check_Wireshark_Parameter_From_Txt(txt_file_path, parameters=[], xpath_split_char='/'):
    with open(txt_file_path, 'r') as f:
        lines = f.readlines()
        lines.append('end')
    return_dic = dict(resultList=[], resultSearch=[])
    return_list = []
    for para in parameters:
        while (para['xpath'].count(xpath_split_char * 2)):
            para['xpath'] = para['xpath'].replace(
                xpath_split_char * 2, xpath_split_char)
        paths = para['xpath'].split(xpath_split_char)
        start_line = -1
        times = 1
        i, j, k, blankNumbers = 0, 0, 0, -1
        while (i < len(lines) and j < len(paths)):
            current_blank_numbers = len(lines[i]) - len(lines[i].strip()) - 1
            if (lines[i].strip() == paths[j] or paths[j] + ":" in lines[i].strip()) \
                    and current_blank_numbers > blankNumbers:
                blankNumbers = current_blank_numbers
                j += 1
                if j == len(paths):
                    if para.get('n', '1') != str(times):
                        j, blankNumbers = 0, -1
                        times += 1
            else:
                if current_blank_numbers <= blankNumbers:
                    j = 0
                    blankNumbers = -1
            i += 1
        path_match = True if j == len(paths) else False
        para_match = True
        print('xpath match result:', path_match)
        if len(para.get('expected_value', {})) > 0 and path_match:
            start_line, end_line = i - 1, -1
            i += 1
            while (i < len(lines)):
                current_blank_numbers = len(
                    lines[i]) - len(lines[i].strip()) - 1
                if current_blank_numbers <= blankNumbers:
                    end_line = i
                    break
                i += 1
            match_str = ''.join(lines[start_line:end_line])
            for key, value in para['expected_value'].items():
                para.setdefault('actual_value', {})
                pattern = '{}: (.+?)\n'.format(key)
                matches = re.findall(pattern, match_str, re.I)
                match = str(matches[0]) if len(matches) == 1 else matches
                value = str(value[0]) if len(value) == 1 else value
                print(para['xpath'] + '.' + str(key), 'excepted:' + str(value), 'actual:' + str(match),
                      'is match:' + str(value == match), 'result_reverse:' + str(para.get('result_reverse', False)))
                para_match = (para_match and value == match)
                result_match = path_match and (not para_match if para.get(
                    'result_reverse', False) else para_match)
                para['actual_value'][key] = match
        else:
            tmp = para['xpath'], 'is match:' + \
                str(path_match), 'result_reverse:' + \
                str(para.get('result_reverse', False))
            print(tmp)
            result_match = not path_match if para.get(
                'result_reverse', False) else path_match
        return_list.append(result_match)
    return_dic['resultList'] = return_list
    return_dic['resultSearch'] = parameters
    return return_dic


def Get_MeasConfig_From_Txt_N(txt_file_path, measConfigDic={}):
    with open(txt_file_path, "r") as f:
        lines = f.readlines()
    startLogo = 'Frame'
    lines.append(startLogo)
    i = 0
    waitForStartLine, waitForEndLine = True, False
    message_list = []
    blankNumbers = 0
    while (i < len(lines)):
        current_blank_numbers = len(lines[i]) - len(lines[i].strip()) - 1
        if lines[i].strip().lower() == 'measconfig' and waitForStartLine:
            startLine = i
            waitForStartLine, waitForEndLine = False, True
            blankNumbers = current_blank_numbers
            i += 1
            continue
        if current_blank_numbers <= blankNumbers and waitForEndLine:
            endLine = i
            waitForStartLine, waitForEndLine = True, False
            message_str = ''.join(lines[startLine:endLine])
            message_list.append(message_str)
        i += 1
    measCombineRe = \
        re.compile(r'MeasIdToAddMod\s+?measId: (\d+)\s+?measObjectId: (\d+)\s+?reportConfigId: (\d+)', re.I)
    objectFreqRe = \
        re.compile(r'MeasObjectToAddMod\s+?measObjectId: (\d+)[\s\S]+?ssbFrequency: (\d+)', re.I)
    reportEventRe = \
        re.compile(r'ReportConfigToAddMod\s+?reportConfigId: (\d+)[\s\S]+?eventId: (.+?)\s+?[\s\S]+?: (.+?)\s', re.I)
    measCombineRemoveRe = \
        re.compile(r'measIdToRemoveList[\s\S]+?(?:Item \d+\s+MeasId: \d+\s+)+', re.I)
    objectFreqRemoveRe = \
        re.compile(r'measObjectToRemoveList[\s\S]+?(?:Item \d+\s+MeasObjectId: \d+\s+)+', re.I)
    reportEventRemoveRe = re.compile(r'reportConfigToRemoveList[\s\S]+?(?:Item \d+\s+ReportConfigId: \d+\s+)+', re.I)
    measidRe = re.compile(r'MeasId: (\d+)', re.I)
    objectidRe = re.compile(r'MeasObjectId: (\d+)', re.I)
    reportidRe = re.compile(r'ReportConfigId: (\d+)', re.I)
    x = {'report': {}, 'object': {}, 'measList': {}, 'removeMeasList': [],
         'removeObjectList': [], 'removeReportList': []}
    measConfigDic.setdefault('0', x)
    last_key = max([int(k) for k in measConfigDic.keys()])
    last_measConfigDic = measConfigDic[str(last_key)].copy()
    measConfigDic = {}
    measDic = last_measConfigDic.get('measList', {})
    objectDic = last_measConfigDic.get('object', {})
    reportDic = last_measConfigDic.get('report', {})
    for x in range(0, len(message_list)):
        contents = message_list[x]
        meas_ids = measCombineRe.findall(contents)
        object_ids = objectFreqRe.findall(contents)
        report_ids = reportEventRe.findall(contents)
        meas_ids_remove = measCombineRemoveRe.findall(contents)
        object_ids_remove = objectFreqRemoveRe.findall(contents)
        report_ids_remove = reportEventRemoveRe.findall(contents)
        new_meas_config_dic = {}
        new_meas_config_dic['removeMeasList'] = []
        new_meas_config_dic['removeObjectList'] = []
        new_meas_config_dic['removeReportList'] = []
        for measidlist in meas_ids:
            tmp_dic = {}
            tmp_dic['objectid'], tmp_dic['reportid'] = measidlist[1], measidlist[2]
            measDic[measidlist[0]] = tmp_dic
        for objid in object_ids:
            tmp_dic = {}
            tmp_dic['ssbFrequency'] = objid[1]
            objectDic[objid[0]] = tmp_dic
        for repid in report_ids:
            tmp_dic = {}
            tmp_dic['eventId'], tmp_dic['ho_method'] = repid[1], repid[2]
            reportDic[repid[0]] = tmp_dic
        for measidlist in meas_ids:
            measid = measidlist[0]
            objectid, reportid = measidlist[1], measidlist[2]
            measDic[measid].update(reportDic.get(reportid, {}))
            measDic[measid].update(objectDic.get(objectid, {}))
        for remove_meas in meas_ids_remove:
            measRemoveList = measidRe.findall(remove_meas)
            new_meas_config_dic['removeMeasList'].extend(measRemoveList)
            for m_id in measRemoveList:
                if m_id in measDic:
                    del measDic[m_id]
        for remove_object in object_ids_remove:
            objectRemoveList = objectidRe.findall(remove_object)
            new_meas_config_dic['removeObjectList'].extend(objectRemoveList)
            for o_id in objectRemoveList:
                if o_id in objectDic:
                    del objectDic[o_id]
        for remove_report in report_ids_remove:
            reportRemoveList = reportidRe.findall(remove_report)
            new_meas_config_dic['removeReportList'].extend(reportRemoveList)
            for r_id in reportRemoveList:
                if r_id in reportDic:
                    del reportDic[r_id]
        measDic_every = measDic.copy()
        objectDic_every = objectDic.copy()
        reportDic_every = reportDic.copy()
        new_meas_config_dic['measList'] = measDic_every
        new_meas_config_dic['object'] = objectDic_every
        new_meas_config_dic['report'] = reportDic_every
        measConfigDic[str(x+1)] = new_meas_config_dic
    if '0' in measConfigDic:
        measConfigDic['0']
    return measConfigDic


def Get_Meas_Id(measConfigDic, ssbFrequency, eventId, ho_method, n=100):
    n_index = n if n < len(measConfigDic) else len(measConfigDic)
    measid = -1
    measlistDic = measConfigDic[str(n_index)]['measList']
    for key, value in measlistDic.items():
        get_value = [str(value[i])
                     for i in ['ssbFrequency', 'eventId', 'ho_method']]
        if [ssbFrequency, eventId, ho_method] == get_value:
            measid = key
            break
    return measid


def Get_Viavi_CSV_Log_Path(log_str):
    log_list = []
    replace_list = [[r'\\', r'/'], ["'", ""],
                    ['C:', '/cygdrive/c'], [r'\r', '']]
    log = re.search('Current logging folder is .*', log_str).group()
    log = re.search('C:.*', log).group()
    for sub_list in replace_list:
        log = re.sub(sub_list[0], sub_list[1], log)
    dir_name = log.split(r'/')[-1]
    log_list = [log, dir_name]
    return log_list


def Get_csv_is_exsit(input_list):
    return_list = []
    for i in input_list:
        if len(i) != 0:
            if 'L1DLSTATS' in i and i.split('.')[-1] == 'csv':
                return_list.append(i)
            if 'L1ULSTATS' in i and i.split('.')[-1] == 'csv':
                return_list.append(i)
    return return_list
