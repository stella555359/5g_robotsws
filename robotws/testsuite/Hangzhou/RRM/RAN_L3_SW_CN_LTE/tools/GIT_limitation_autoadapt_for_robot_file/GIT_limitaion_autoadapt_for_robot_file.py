# -*- coding: utf-8 -*-
import os
import io
import re

limitation = 150
limitation2 = 120
# directory = r'C:\testsuite_hangzhou\trunk_sbts\4G_RAN_ASL3_HZH\CIT'
directory = r'C:\D\TA\robotws5g\testsuite\migration\Hangzhou\RRM\5G_ASL3_HZH\SBTS22R1'


def collect_robot_files(dir):
    robot_files = []
    for root, dirs, files in os.walk(dir):
        for file in files:
            if file.endswith('.robot'):
                robot_files.append((root, file))
    return robot_files


def auto_variable(separated_part, new_lines, trigger='', limitation=limitation2):
    global auto_variable_count
    auto_variable_count += 1
    auto_variable_content = []
    variable_name = '${' + 'V_' + str(auto_variable_count) + '}'
    if trigger == '#':
        auto_variable_content_temp = re.match(r'#(.*)', separated_part).group(1)
    else:
        auto_variable_content_temp = re.search(trigger, separated_part).group(1)
    separated_part = separated_part.replace(auto_variable_content_temp, variable_name)
    auto_variable_content.append('  '.join([variable_name, 'SEPARATOR=\n']))
    auto_variable_content_temp = '...  ' + auto_variable_content_temp
    while len(auto_variable_content_temp) >= limitation:
        auto_variable_content.append(auto_variable_content_temp[:limitation - 1] + '\n')
        auto_variable_content_temp = '...  ' + auto_variable_content_temp[limitation - 1:]
    auto_variable_content.append(auto_variable_content_temp + '\n')

    for line in new_lines:
        if '*** Test Case' in line:
            line_Variable_index = new_lines.index(line) - 1
    for line in auto_variable_content:
        new_lines.insert(line_Variable_index, line)
        line_Variable_index += 1
    return separated_part


with open('log.txt', 'w') as log:
    file_count = 0
    file_need_manual_check_count = 0
    for root, file in collect_robot_files(directory):
        file_count += 1
        os.chdir(root)
        robot_file = '\\'.join([root, file])
        log.write('\nprocessing robot file:\n' + robot_file + '\n')
        print('\nprocessing robot file:\n' + robot_file + '\n')
        lines_of_long_setting_name = []
        lines_of_long_variable_name = []
        lines_of_long_case_name = []
        lines_of_long_keyword_name = []
        auto_variable_count = 0
        further_adaption = False
        with io.open(robot_file, 'r', encoding='gb18030', errors='ignore') as original_file, open(
                '{}.bak'.format(robot_file), 'w') as newfile:
            line_index = 0
            ori_lines = original_file.readlines()
            new_lines = []
            paragraph = ''
            Doc = False
            for line in ori_lines:
                line_index += 1
                if line.strip() == '':
                    new_lines.append(line)
                else:
                    if re.match(r'\*\*\*\s(.*)\s\*\*\*', line):  # 分段落，有可能是复数s
                        paragraph = re.match(r'\*\*\*\s(.*)\s\*\*\*', line).group(1)
                    if re.match(r'Documentation', line.strip()) or re.match(r'\[Documentation',
                                                                            line.strip()):  # 判断是不是documentation段落
                        Doc = True
                    else:
                        if not re.match(r'\.\.\.', line.strip()):
                            Doc = False
                    blanks_prefixed = re.match(r'[\s]{0,}', line).group()  # 行开头空格数
                    if 'Variable' in paragraph:
                        blanks_prefixed = ''
                    separated_parts = re.split('[ ]{2,}', line.strip())  # 两个空格以上分割的为整体
                    # if 'Setting' not in paragraph:
                    # 除了'setting'外，2空格以上替换成2空格，因为TA review工具限制，移除此功能
                    #     line=blanks_prefixed+'  '.join(separated_parts)+'\n'
                    if len(line) <= limitation:  # 不超限的处理,variable list部分全部换行
                        if 'Variable' in paragraph:
                            while '\\' in separated_parts:
                                separated_parts.remove('\\')
                            if re.match(r'\$\{', line) or re.match(r'#', line.strip()):
                                new_lines.append(line)
                            else:
                                if separated_parts[0] == '':
                                    del separated_parts[0]
                                if separated_parts[0] == '...':
                                    separated_parts[0] = blanks_prefixed + separated_parts[0] + '  ' + separated_parts[
                                        1]
                                    del separated_parts[1]
                                new_lines.append(blanks_prefixed + separated_parts[0] + '\n')
                                for separated_part in separated_parts[1:]:
                                    if re.match(r'#', separated_part):
                                        new_lines.append(separated_part + '\n')
                                    else:
                                        new_lines.append(blanks_prefixed + '...  ' + separated_part + '\n')
                        elif len(re.split('[ ]{2,}', line.strip())) == 1 and 'Keyword' in paragraph and len(
                                line) > limitation - 4:  # 超限keyword后续处理
                            lines_of_long_keyword_name.append(line)
                            new_lines.append(line)
                        else:
                            new_lines.append(line)
                    else:  # 处理超限的行
                        if re.match(r'#', line.strip()):
                            while len(line) > limitation:
                                new_lines.append(line[:limitation - 1] + '\n')
                                line = '#' + blanks_prefixed + '...  ' + line[limitation - 1:]
                            new_lines.append(line)
                        elif Doc:  # documentation直接分割
                            if 'Setting' in paragraph:
                                while len(line) > limitation:
                                    new_lines.append(line[:limitation - 1] + '\n')
                                    line = '...               ' + line[limitation - 1:]
                                new_lines.append(line)
                            else:
                                while len(line) > limitation:
                                    new_lines.append(line[:limitation - 1] + '\n')
                                    line = blanks_prefixed + '...  ' + line[limitation - 1:]
                                new_lines.append(line)
                        else:
                            if separated_parts[0] == '\\':
                                blanks_prefixed = blanks_prefixed + '\\' + '  '
                                separated_parts[0] = ''
                            if len(separated_parts) == 1:  # 一行只有一个整体部分，可能是case name 或者keyword
                                if len(blanks_prefixed) < 2:
                                    if 'Test Case' in paragraph:
                                        lines_of_long_case_name.append(line)  # 长case name不处理，处理完其他行限制后单独处理
                                        further_adaption = True
                                    elif 'Keyword' in paragraph:
                                        lines_of_long_keyword_name.append(line)  # 长keyword不处理,处理完其他行限制后单独处理
                                        further_adaption = True
                                    new_lines.append(line)
                                else:  # 可能是case中使用了一个长keyword
                                    new_lines.append(line)
                            else:
                                separated_parts[0] = blanks_prefixed + separated_parts[0]
                                if 'Variable' in paragraph:
                                    while '\\' in separated_parts:
                                        separated_parts.remove('\\')
                                    if separated_parts[0] == '':
                                        del separated_parts[0]
                                    if separated_parts[0] == '...':
                                        separated_parts[0] = blanks_prefixed + separated_parts[0] + '  ' + \
                                                             separated_parts[1]
                                        del separated_parts[1]
                                    if len(blanks_prefixed + '...  ' + separated_parts[1]) >= \
                                            limitation2:  # 处理长variable
                                        if separated_parts[0] == '@{PARAMS_IN_EMIL}':
                                            separated_parts[0] = '${PARAMS_IN_EMIL}'
                                        new_lines.append('  '.join([separated_parts[0], 'SEPARATOR=\n']))
                                        line_temp = blanks_prefixed + '...  ' + separated_parts[1]
                                        while len(line_temp) >= limitation2:
                                            new_lines.append(line_temp[:limitation2 - 1] + '\n')
                                            line_temp = blanks_prefixed + '...  ' + line_temp[limitation2 - 1:]
                                        new_lines.append(line_temp + '\n')
                                        if len(separated_parts) > 2:
                                            for separated_part in separated_parts[2:]:
                                                if re.match(r'#', separated_part):
                                                    while len(separated_part) >= limitation:
                                                        new_lines.append(separated_part[:limitation - 1] + '\n')
                                                        separated_part = '#' + line_temp[limitation - 1:]
                                                    new_lines.append(separated_part + '\n')
                                                else:
                                                    new_lines.append('...  ' + separated_part + '\n')
                                    else:
                                        new_lines.append(separated_parts[0] + '\n')
                                        new_lines.append('...  ' + separated_parts[1] + '\n')
                                        for separated_part in separated_parts[2:]:
                                            if re.match(r'#', separated_part):
                                                while len(separated_part) >= limitation:
                                                    new_lines.append(separated_part[:limitation - 1] + '\n')
                                                    separated_part = '#' + line_temp[limitation - 1:]
                                                new_lines.append(separated_part + '\n')
                                            else:
                                                new_lines.append('...  ' + separated_part + '\n')
                                else:
                                    # previous_line = False
                                    current_line_index = len(new_lines)
                                    if len(separated_parts[0]) >= limitation:
                                        new_lines.append(separated_parts[0] + '\n')
                                        further_adaption = True
                                        line_temp = blanks_prefixed + '...'
                                        # previous_line = True
                                    else:
                                        line_temp = separated_parts[0]
                                    for separated_part in separated_parts[1:]:
                                        if len(blanks_prefixed + '...  ' + separated_part) >= limitation:
                                            further_adaption = True
                                            if re.match(r'#', separated_part):
                                                separated_part = auto_variable(separated_part, new_lines, trigger='#')
                                            if re.search(r'\w{0,}hex\w{0,}=(\w+)|\$\{hex_code\}=(\w+)',
                                                         separated_part):
                                                separated_part = auto_variable(separated_part, new_lines,
                                                                               trigger=r'.{0,}hex.{0,}=(\w+)')
                                            if re.search(r'\w{0,}ue_nr_capabilities\w{0,}=(\w+)', separated_part):
                                                separated_part = auto_variable(
                                                    separated_part,
                                                    new_lines,
                                                    trigger=r'\w{0,}ue_nr_capabilities\w{0,}=(\w+)')
                                            if re.search(r'\w{0,}ue_eutra_nr_capabilities\w{0,}=(\w+)',
                                                         separated_part):
                                                separated_part = auto_variable(
                                                    separated_part,
                                                    new_lines,
                                                    trigger=r'\w{0,}ue_eutra_nr_capabilities\w{0,}=(\w+)')
                                            if re.search(r'\w{0,}ue_eutra_capabilities\w{0,}=(\w+)', separated_part):
                                                separated_part = auto_variable(
                                                    separated_part,
                                                    new_lines,
                                                    trigger=r'\w{0,}ue_eutra_capabilities\w{0,}=(\w+)')
                                            # if re.search(r'\w{0,}wait_string\w{0,}=(.*)',separated_part):
                                            #     separated_part=auto_variable(separated_part,new_lines,
                                            #     trigger='\w{0,}wait_string\w{0,}=(.*)')
                                            # if re.search(r'\w{0,}pass_regexp\w{0,}=(.*)',separated_part):
                                            #     separated_part=auto_variable(separated_part,new_lines,
                                            #     trigger='\w{0,}pass_regexp\w{0,}=(.*)')
                                            if len(blanks_prefixed + '...  ' + separated_part) >= limitation:
                                                auto_variable_count += 1
                                                variable_name = '${' + 'V_' + str(auto_variable_count) + '}'
                                                if re.search(r'\w{0,}wait_string\w{0,}=(.*)', separated_part):
                                                    deep_seperated_parts = re.split('[ ]', re.search(
                                                        r'\w{0,}wait_string\w{0,}=(.*)', separated_part).group(1))
                                                    separated_part = separated_part.replace(
                                                        re.search(r'\w{0,}wait_string\w{0,}=(.*)',
                                                                  separated_part).group(1), variable_name)
                                                elif re.search(r'\w{0,}pass_regexp\w{0,}=(.*)', separated_part):
                                                    deep_seperated_parts = re.split('[ ]', re.search(
                                                        r'\w{0,}pass_regexp\w{0,}=(.*)', separated_part).group(1))
                                                    separated_part = separated_part.replace(
                                                        re.search(r'\w{0,}pass_regexp\w{0,}=(.*)',
                                                                  separated_part).group(1), variable_name)
                                                # auto_variable_content = separated_part
                                                else:
                                                    deep_seperated_parts = re.split('[ ]', separated_part)
                                                    separated_part = variable_name
                                                temp = []
                                                temp.append(blanks_prefixed + variable_name + '  ' + 'catenate' + '\n')
                                                auto_variable_content_temp = \
                                                    blanks_prefixed + '...  ' + deep_seperated_parts[0]
                                                for i in deep_seperated_parts[1:]:
                                                    if len(auto_variable_content_temp + ' ' + i) < limitation:
                                                        auto_variable_content_temp = \
                                                            auto_variable_content_temp + ' ' + i
                                                    else:
                                                        temp.append(auto_variable_content_temp + '\n')
                                                        auto_variable_content_temp = blanks_prefixed + '...  ' + i
                                                temp.append(auto_variable_content_temp + '\n')
                                                # if previous_line:
                                                if re.match(r'\.\.\.', line.strip()):
                                                    temp_line = ''
                                                    for ll in reversed(new_lines):
                                                        if not re.match(r'\.\.\.', ll.strip()):
                                                            temp_line = ll
                                                            break
                                                    insert_line_index = new_lines.index(temp_line)
                                                    for i in reversed(temp):
                                                        new_lines.insert(insert_line_index, i)
                                                else:
                                                    for i in reversed(temp):
                                                        new_lines.insert(current_line_index, i)
                                                # else:
                                                #     for i in temp:
                                                #      new_lines.append(i)
                                        if len(line_temp + '  ' + separated_part) < limitation:
                                            line_temp = line_temp + '  ' + separated_part
                                        else:
                                            if re.match(r'#', separated_part):
                                                separated_part = separated_part.replace('#', '', 1)
                                                blanks_prefixed = '#' + blanks_prefixed
                                            new_lines.append(line_temp + '\n')
                                            line_temp = blanks_prefixed + '...  ' + separated_part
                                    new_lines.append(line_temp + '\n')
            if lines_of_long_case_name:  # 处理长case名
                case_name_count = 0
                for line in lines_of_long_case_name:
                    case_name_count += 1
                    case_name_content = line.strip()
                    long_case_name_index = new_lines.index(line)
                    new_lines[long_case_name_index] = 'Auto_case_name_' + str(case_name_count) + '\n'
                    if '[Documentation]' in new_lines[long_case_name_index + 1]:
                        doc_line = new_lines[long_case_name_index + 1]
                        blanks_prefixed = re.match(r'[\s]{0,}', doc_line).group()
                        separated_parts = re.split('[ ]{2,}', doc_line.strip())
                        separated_parts.insert(1, 'case name was:' + '[' + case_name_content + ']')
                        line = blanks_prefixed + '  '.join(separated_parts)
                        del new_lines[long_case_name_index + 1]
                        newline = []
                        while (len(line) >= limitation):
                            newline.append(line[:limitation - 1] + '\n')
                            line = blanks_prefixed + '...  ' + line[limitation - 1:]
                        newline.append(line + '\n')
                        index = long_case_name_index + 1
                        for line in newline:
                            new_lines.insert(index, line)
                            index += 1
                    else:
                        line = '    [Documentation]' + '  ' + 'case name was:' + '[' + case_name_content + ']'
                        newline = []
                        while (len(line) >= limitation):
                            newline.append(line[:limitation - 1] + '\n')
                            line = '    ' + '...  ' + line[limitation - 1:]
                        newline.append(line + '\n')
                        index = long_case_name_index + 1
                        for line in newline:
                            new_lines.insert(index, line)
                            index += 1
            if lines_of_long_keyword_name:
                keyword_name_count = 0
                for line in lines_of_long_keyword_name:
                    keyword_name_count += 1
                    keyword_name_content = line.strip()
                    long_keyword_name_index = new_lines.index(line)
                    auto_keyword_name = 'Auto_keyword_name_' + str(keyword_name_count)
                    for i in new_lines:
                        index = new_lines.index(i)
                        new_lines[index] = i.replace(keyword_name_content, auto_keyword_name)

                    if '[Documentation]' in new_lines[long_keyword_name_index + 1]:
                        doc_line = new_lines[long_keyword_name_index + 1]
                        blanks_prefixed = re.match(r'[\s]{0,}', doc_line).group()
                        separated_parts = re.split('[ ]{2,}', doc_line.strip())
                        separated_parts.insert(1, 'keyword name was:' + '[' + keyword_name_content + ']')
                        temp = blanks_prefixed + '  '.join(separated_parts)
                        newline = []
                        while (len(temp) >= limitation):
                            newline.append(temp[:limitation - 1] + '\n')
                            temp = blanks_prefixed + '...  ' + temp[limitation - 1:]
                        newline.append(temp + '\n')
                        index = long_keyword_name_index + 1
                        for i in newline:
                            new_lines.insert(index, i)
                            index += 1
                    else:
                        temp = '    [Documentation]' + '  ' + 'keyword name was:' + '[' + keyword_name_content + ']'
                        newline = []
                        while (len(temp) >= limitation):
                            newline.append(temp[:limitation - 1] + '\n')
                            temp = '    ' + '...  ' + temp[limitation - 1:]
                        newline.append(temp + '\n')
                        index = long_keyword_name_index + 1
                        for i in newline:
                            new_lines.insert(index, i)
                            index += 1
            line_count = 0
            flag = False
            for line in new_lines:
                line_count += 1
                if len(line) > limitation:
                    flag = True
                    print('\tline {} still exceed limitation'.format(line_count))
                    print('\t' + line.strip())
                    log.write('\tline {} still exceed limitation'.format(line_count))
                    log.write('content:' + line)
                newfile.write(line)
            if flag:
                file_need_manual_check_count += 1
                print('please manually check file:{}\n'.format(robot_file))
                log.write('please manually check file:{}\n'.format(robot_file))
        os.remove(robot_file)
        os.rename('{}.bak'.format(robot_file), robot_file)
    print('*' * 20 + '\n' + 'mission complete,{} robot files converted,{} '
                            'need manually check'.format(file_count,
                                                         file_need_manual_check_count) + '\n' + '*' * 20)
    log.write('*' * 20 + '\n' + 'mission complete,{} robot files converted,{} '
                                'need manually check'.format(file_count,
                                                             file_need_manual_check_count) + '\n' + '*' * 20)
