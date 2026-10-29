# -*- coding: utf-8 -*
def Get_Number_And_Ip_In_String(input_String):
    res = []
    temp = ''
    for item in input_String:
        if (ord(item) >= 48 and ord(item) <= 57) or item == '.':
            temp += item
        else:
            if len(temp) != 0:
                res.append(temp)
                temp = ''
    if len(temp) != 0:
        res.append(temp)
    return res


def Get_txt_file_content(file_path, content, id):
    import re
    pattern = re.compile(r'(.*)ID: (\d+)')
    file = open(file_path, 'r')
    for line in file.readlines():
        if content in line:
            result = re.search(pattern, line)
            if result and str(result.group(2)) == str(id):
                return True
    else:
        return False


def get_piority_dscp_content(file_path):
    import re
    pattern = re.compile(r'Priority:(.*) [(](\d+)[)]$')
    pattern1 = re.compile(r'Differentiated Services Codepoint: Default [(](\d+)[)]$')
    file = open(file_path, 'r')
    priority_list = []
    dscp_list = []
    for line in file.readlines():
        if re.search(pattern, line):
            priority_result = re.search(pattern, line).group(2)
            priority_list.append(priority_result)
        if re.search(pattern1, line):
            dscp_result = re.search(pattern1, line).group(1)
            dscp_list.append(dscp_result)
    return priority_list, dscp_list


def Covert_BTS_Version(version):
    package = version.split('_')[-2]
    package_21B = version.split('_')[-3]
    if package == '000400':
        scf_name = 'SCF_0.400_DU.xml'
    elif package == '001100':
        scf_name = 'SCF_10.1100_DU.xml'
    if package_21B == '0012':
        scf_name = 'SCF_12.400_DU.xml'
    return scf_name
