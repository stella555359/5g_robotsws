import re


def checkb1report(txt_filename=None):
    para = {'xpath': 'SgNBAdditionRequest/cg-ConfigInfo/candidateCellInfoListMN'}
    match_str = getDedicatedStringWithParameter(txt_filename, para)
    match_re = \
        re.findall(r'ssbFrequency: (\d+)[\s\S]+?physCellId: (\d+)[\s\S]+?rsrp:[\s\S]+?\((\d+)\)', match_str, re.I)
    print('MeasResult2NR: ', match_str)
    print('MeasResult2NR: ', match_re)
    if match_re:
        print('dupa123')
        freq_list = [x[0] for x in match_re]
        print(f'freq_list1: {freq_list}')
        freq_list.sort()
        print(f'freq_list2: {freq_list}')
        match_result = (freq_list == ['387850'])
    else:
        match_result = False
    return match_result


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


def Check_Wireshark_Parameter_From_Txt(txt_file_path, parameters=[], xpath_split_char='/'):
    with open(txt_file_path, 'r') as f:
        lines = f.readlines()
        lines.append('end')
    return_dic = dict(resultList=[], resultSearch=[])
    return_list = []
    print(f'parameters: {parameters}')
    for para in parameters:
        print(f'para: {para}, type: {type(para)}')
        while (para['xpath'].count(xpath_split_char * 2)):
            para['xpath'] = para['xpath'].replace(
                xpath_split_char * 2, xpath_split_char)
        paths = para['xpath'].split(xpath_split_char)
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
                    if isinstance(value, list):
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
            cmbindex = str(int(combinaIndex) - 1)
            if cmbindex not in uecapcombinaDict:
                match_result = False
    else:
        match_result = False
    return match_result and FR1 and FR2


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
