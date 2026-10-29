# -*- coding: utf-8 -*
import re
import copy
import datetime
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


def Covert_BTS_Version(gnbnumber, version, if_gnb=True):
    package = version.split('_')[2]
    if if_gnb:
        if package == '9999':
            if gnbnumber == 1:
                scf_name = 'SCF_Trunk_gNB1.xml'
            else:
                scf_name = 'SCF_Trunk_gNB2.xml'
        else:
            package_version = version.split('_')[0]
            if gnbnumber == 1:
                scf_name = 'SCF_' + package_version + '_gNB1.xml'
            else:
                scf_name = 'SCF_' + package_version + '_gNB2.xml'
    else:
        if gnbnumber == 1:
            scf_name = 'SCF_Trunk_enb1.xml'
        else:
            scf_name = 'SCF_Trunk_enb2.xml'
    return scf_name


def return_structure_value(input_list, modify_list, keywords_list):
    output_dict_list = []
    for i in range(len(keywords_list)):
        for item_dict in input_list:
            if keywords_list[i] == item_dict['distName'].split('/')[-1]:
                output_dict = {}
                parameters_value = item_dict['parameters']
                modify_parameter = modify_list[i]['parameter']
                structure_value = parameters_value[modify_parameter]
                new_value = modify_list[i]['value']
                output_list = modify_structure_value(structure_value, new_value)
                output_dict['dist_name'] = modify_list[i]['dist_name']
                output_dict['parameter'] = modify_list[i]['parameter']
                output_dict['value'] = output_list
                output_dict_list.append(output_dict)
    return output_dict_list


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
        # print paths
        start_line = -1
        times = 1
        i, j, k, blankNumbers = 0, 0, 0, -1
        last_value = (i, j)
        while (i < len(lines) and j < len(paths)):
            current_blank_numbers = len(lines[i]) - len(lines[i].strip()) - 1
            if (lines[i].strip() == paths[j] or paths[j] + ":" in lines[i].strip()) \
                    and current_blank_numbers > blankNumbers:
                blankNumbers = current_blank_numbers
                j += 1
                if j == len(paths):
                    last_value = (i + 1, j)
                    if para.get('n', '1') != str(times):
                        j, blankNumbers = 0, -1
                        times += 1
            else:
                if current_blank_numbers <= blankNumbers:
                    j = 0
                    blankNumbers = -1
            i += 1
        i, j = last_value
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
                matches = list(set(re.findall(pattern, match_str, re.I)))
                match = str(matches[0]) if len(matches) == 1 else matches
                value = str(value[0]) if len(value) == 1 else value
                if value == '':
                    if len(matches) > 0:
                        para_match = True
                else:
                    if type(value) == list:
                        para_match = (para_match and value.sort() == match.sort())
                    else:
                        para_match = (para_match and value == match)
                print(para['xpath'] + '.' + str(key), 'excepted:' + str(value), 'actual:' + str(match),
                      'is match:' + str(value == match), 'result_reverse:' + str(para.get('result_reverse', False)))
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
    isSgnb = False
    isRRCconfig = False
    while (i < len(lines)):
        if lines[i].startswith(startLogo):
            isRRCconfig = False
            isSgnb = False
        if 'sgnbadditionrequestacknowledge' in lines[i].lower() or 'sgnbmodificationrequired' in lines[i].lower() \
                or 'sgnbmodificationrequestacknowledge' in lines[i].lower():
            isSgnb = True
        if isSgnb and 'rrcreconfiguration' in lines[i].lower():
            isRRCconfig = True
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
            if isSgnb and isRRCconfig:
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
    last_measConfigDic = copy.deepcopy(measConfigDic[str(last_key)])
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
        measDic_every = copy.deepcopy(measDic)
        objectDic_every = copy.deepcopy(objectDic)
        reportDic_every = copy.deepcopy(reportDic)
        new_meas_config_dic['measList'] = measDic_every
        new_meas_config_dic['object'] = objectDic_every
        new_meas_config_dic['report'] = reportDic_every
        last_key += 1
        measConfigDic[str(last_key)] = new_meas_config_dic
    if '0' in measConfigDic:
        del measConfigDic['0']
    return measConfigDic


def Get_Meas_Id(measConfigDic, ssbFrequency, eventId, ho_method, n=100):
    n_index = n if n < len(measConfigDic) else len(measConfigDic)
    measid = -1
    measlistDic = measConfigDic[str(n_index)]['measList']
    for key, value in measlistDic.items():
        get_value = [str(value[i]) for i in ['ssbFrequency', 'eventId', 'ho_method']]
        if [ssbFrequency, eventId, ho_method] == get_value:
            measid = key
            break
    return measid


def get_tput_in_syslog(syslog_path=None, iplist=[]):
    with open(syslog_path, 'r') as f:
        lines = f.readlines()
        DLtputDataDic = {}
        ULtputDataDic = {}
        timeRe = re.compile(r'\d{2}:\d{2}:\d{2}')
        ipRe = re.compile(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
        for line in lines:
            ip = ipRe.search(line).group(0)
            if ip in iplist:
                if ('DataPdu' in line) and ('nrCellId' in line):
                    lineTime = timeRe.search(line).group(0)
                    dlTp = line.split('DataPdu: ')[1].split('|')[0]
                    DLtputDataDic[lineTime] = DLtputDataDic.get(lineTime, 0) + int(dlTp)*8/1024/1024
                if ('UlCounterUpdate' in line) and ('nrCellIdentity' in line):
                    lineTime = timeRe.search(line).group(0)
                    ulTp = line.split(' Bytes received')[0].split('UL: ')[1]
                    ULtputDataDic[lineTime] = ULtputDataDic.get(lineTime, 0) + int(ulTp)*8/1024/1024
    return DLtputDataDic, ULtputDataDic


def check_ho_bts_tput(tputDataDic=None, ignoreBoundaryZero=True, minTput=1, minTputRateAllow=0.15):
    tputDataList = [(x, y) for x, y in tputDataDic.items()]
    # sort by time
    tputDataList.sort(key=lambda x: x[0], reverse=False)
    start, end = 0, len(tputDataList)-1
    countLessMinTput, totalCount = 0, len(tputDataList)
    if ignoreBoundaryZero:
        for i in range(0, len(tputDataList)):
            if int(tputDataList[i][1]) != 0:
                start = i
                break
        for i in range(len(tputDataList)-1, -1, -1):
            if int(tputDataList[i][1]) != 0:
                end = i
                break
    for i in range(start, end+1):
        tput = tputDataList[i][1]
        if tput < minTput:
            countLessMinTput += 1
        totalCount += 1
    rate = countLessMinTput / totalCount
    if rate < minTputRateAllow:
        return True
    else:
        return False


def get_counter_data_in_syslog(syslog_path=None, celllist=[], type='DL'):
    celllist = list(map(str, celllist))
    if type == 'UL':
        celllist = celllist[:2]
    with open(syslog_path, 'r') as f:
        lines = f.readlines()
        DLtputDataDic = {}
        ULtputDataDic = {}
        timeRe = re.compile(r'\d{2}:\d{2}:\d{2}')
        dlCellidRe = re.compile(r'nrCellId (\d+)')
        ulCellidRe = re.compile(r'nrCellIdentity (\d+)')
        for line in lines:
            if ('DataPdu' in line) and ('nrCellId' in line) and type == 'DL':
                cellid = dlCellidRe.search(line).group(1)
                if cellid in celllist:
                    lineTime = timeRe.search(line).group(0)
                    dlTp = int(line.split('DataPdu: ')[1].split('|')[0])*8/1024/1024
                    dlTp = 0 if int(dlTp) <= 1 else int(dlTp)
                    DLtputDataDic.setdefault(lineTime, [0, 0, 0, 0])
                    DLtputDataDic[lineTime][celllist.index(cellid)] = dlTp
            if ('UlCounterUpdate' in line) and ('nrCellIdentity' in line) and type == 'UL':
                cellid = ulCellidRe.search(line).group(1)
                if cellid in celllist:
                    lineTime = timeRe.search(line).group(0)
                    ulTp = int(line.split(' Bytes received')[0].split('UL: ')[1])*8/1024/1024
                    ulTp = 0 if int(ulTp) <= 1 else int(ulTp)
                    ULtputDataDic.setdefault(lineTime, [0, 0])
                    ULtputDataDic[lineTime][celllist.index(cellid)] = ulTp
    if DLtputDataDic:
        DLtputData = sorted(DLtputDataDic.items(), key=lambda x: x[0])
        i = 0
        waitStart, waitEnd = True, False
        for time, tputlist in DLtputData:
            if (tputlist == [0, 0, 0, 0] or i == len(DLtputData)) and waitEnd:
                end = time
                break
            if 0 not in tputlist and waitStart:
                start = time
                waitStart, waitEnd = False, True
        return getSeconds(start, end)
    if ULtputDataDic:
        i = 0
        ULtputData = sorted(ULtputDataDic.items(), key=lambda x: x[0])
        waitStart, waitEnd = True, False
        for time, tputlist in ULtputData:
            i += 1
            if (tputlist == [0, 0] or i == len(ULtputData)) and waitEnd:
                end = time
                break
            if sum(tputlist) > 11 and waitStart:
                start = time
                waitStart, waitEnd = False, True
        return getSeconds(start, end)


def getSeconds(time1, time2):
    start_time = datetime.datetime.strptime(time1, '%H:%M:%S')
    end_time = datetime.datetime.strptime(time2, '%H:%M:%S')
    return (end_time - start_time).seconds


def remove_repeat_measurement_report(txt_file_path=None):
    with open(txt_file_path, "r") as f:
        lines = f.readlines()
    startLogo = 'Frame '
    lines.append(startLogo)
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
                message_list.append(message_str)
                startLine = i
                waitForStartLine, waitForEndLine = False, True
        i += 1
    remove_index_list = []
    i = 0
    findMr = False
    continus_mr_count = 0
    for m in message_list:
        if 'measurementReport' in m:
            findMr = True
            continus_mr_count += 1
        else:
            if findMr and continus_mr_count > 1:
                for j in range(0, continus_mr_count-1):
                    remove_index_list.append(i-2-j)
            findMr = False
            continus_mr_count = 0
        i += 1
    if remove_index_list:
        reversed(remove_index_list)
        for index in remove_index_list:
            del (message_list[index])
        with open(txt_file_path, 'w') as f:
            f.write(''.join(message_list))


def getDedicatedStringWithParameter(txt_file_path=None, para=None):
    with open(txt_file_path, 'r') as f:
        lines = f.readlines()
        lines.append('end')
    paths = para['xpath'].split('/')
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
    match_str = ''
    if path_match:
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
    return match_str


def getBandconbinationIndexDict(txt_file_path=None):
    para = {'xpath': 'SgNBAdditionRequest/UE-MRDC-Capability/rf-ParametersMRDC'}
    match_str = getDedicatedStringWithParameter(txt_file_path, para)
    match_re = re.findall(r'Item (\d+)\s+BandCombination[\s\S]+?bandNR: (\d+)', match_str, re.I)
    match_dict = dict(match_re)
    return match_dict


def getRestrictBandcombinationList(txt_file_path=None):
    para = {'xpath': 'SgNBAdditionRequest/configRestrictInfo'}
    match_str = getDedicatedStringWithParameter(txt_file_path, para)
    match_combination_list = \
        re.findall(r'Item \d+\s+BandCombinationInfo\s+bandCombinationIndex: (\d+)', match_str, re.I)
    return match_combination_list


def checkBandResrictionfr1Andfr2(txt_filename=None):
    uecapcombinaDict = getBandconbinationIndexDict(txt_filename)
    nrresrictBandList = getRestrictBandcombinationList(txt_filename)
    print('UEcap:', uecapcombinaDict)
    print('Allow band list:', nrresrictBandList)
    match_result = True
    if uecapcombinaDict and nrresrictBandList:
        FR1, FR2 = False, False
        for item, band in uecapcombinaDict.items():
            if int(band) > 250:
                FR2 = True
            else:
                FR1 = True
        for combinaIndex in nrresrictBandList:
            cmbindex = str(int(combinaIndex)-1)
            if cmbindex not in uecapcombinaDict:
                match_result = False
    else:
        match_result = False
    return match_result and FR1 and FR2


def checkb1report(txt_filename=None):
    para = {'xpath': 'SgNBAdditionRequest/cg-ConfigInfo/candidateCellInfoListMN'}
    match_str = getDedicatedStringWithParameter(txt_filename, para)
    match_re = \
        re.findall(r'ssbFrequency: (\d+)[\s\S]+?physCellId: (\d+)[\s\S]+?rsrp:[\s\S]+?\((\d+)\)', match_str, re.I)
    print('MeasResult2NR: ', match_re)
    if match_re:
        freq_list = [x[0] for x in match_re]
        freq_list.sort()
        match_result = (freq_list == ['125810', '2071387'])
    else:
        match_result = False
    return match_result


def checkCGIreport(txt_file_path=None):
    para = {'xpath': 'measurementReport/cgi-Info/'}
    match_str = getDedicatedStringWithParameter(txt_file_path, para)
    opuse_check, plmn_check = True, True
    match_result_list = \
        re.findall(r'Item \d+\s+PLMN-IdentityInfo[\s\S]+?cellReservedForOperatorUse: .+? ', match_str, re.I)
    plmn_check_dict_1 = {'1': '46002', '2': '4500526203'}
    plmn_check_dict_2 = {'1': '46002', '2': '2620345005'}
    if match_result_list:
        for i, item in enumerate(match_result_list, start=1):
            opuse_re = re.search(r'cellReservedForOperatorUse: reserved', item)
            if not opuse_re:
                opuse_check = False
            plmn_re = re.findall(r'MCC-MNC-Digit: (\d+)', item)
            if not plmn_re:
                plmn_check = False
            else:
                plmn_str = ''.join(plmn_re)
                if plmn_check_dict_1[str(i)] != plmn_str and plmn_check_dict_2[str(i)] != plmn_str:
                    plmn_check = False
    else:
        plmn_check, opuse_check = False, False
    return opuse_check and plmn_check
