# -*- coding: utf-8 -*-
"""
2022/06/08 first version by @author: sheng.1.ye@nokia.com
    The InfoReader class is used to read and convert txt file to indent format.
2022/06/14 refactoring, by Ye Sheng
2022/07/28 update emil_reader, support multiple message under 'Message', by Ye Sheng
2022/09/15 update emil_reader, add indent to spaces * 4, by Ye Sheng
2023/04/04 add open function support 'utf8', by Ye Sheng
2024/06/05 support emil_json type, and update emil type, by Ye Sheng
"""

import re


class InfoReader:

    @staticmethod
    def open(filename):
        return open(filename, encoding='utf8')

    @staticmethod
    def _get_file_type_by_name(filename):
        if 'egate_console' in filename:
            return 'egate'
        elif 'emil' in filename:
            return 'emil_json' if filename.endswith('.json') else 'emil'
        elif 'swconfig' in filename or 'sw_config' in filename:
            return 'swconfig'
        elif filename.endswith('.xml'):
            return 'scf'
        elif filename.endswith('.csv'):
            return 'csv'
        else:
            return ''

    @staticmethod
    def _get_file_type_by_content(filename):
        try:
            with InfoReader.open(filename) as rf:
                for line in rf:
                    if line.startswith('Message:'):
                        return 'emil'
                    elif line.startswith('Simulator version'):
                        return 'egate'
                    elif line.startswith('<?xml'):
                        return 'scf'
                    else:
                        break
        except UnicodeDecodeError:
            pass
        return ''

    @classmethod
    def get_file_type(cls, filename):
        return (cls._get_file_type_by_name(filename) or
                cls._get_file_type_by_content(filename) or
                'other')

    @classmethod
    def read_egate_file(cls, filename):
        lines = []
        last_line = ''
        numbering = {}
        msg_body = False
        with cls.open(filename) as rf:
            for line in rf:
                if cls._egate_enter_msg_body(line):
                    lines.append("Arrival Time: " + last_line)
                    msg_body = True
                elif cls._egate_quit_msg_body(line):
                    lines.append("\n")
                    msg_body = False
                if msg_body:
                    result = cls._egate_handle_msg_body(line, last_line, numbering)
                    if result:
                        lines.append(result)
                last_line = line
        return "".join(lines)

    @staticmethod
    def _egate_enter_msg_body(line):
        return '::=' in line

    @staticmethod
    def _egate_quit_msg_body(line):
        return line and line[0] == '}'

    @staticmethod
    def _egate_handle_msg_body(line, last_line, numbering):
        m = re.match(r'^( *)(.*?)[\s,]*$', line)
        txt = m.group(2)
        spaces = m.group(1)
        if txt == '{':
            if '  ' + last_line == line:
                numbering[spaces] = 0
                txt = '#0'
            elif (last_line and last_line.replace('},', '{') == line and numbering.get(spaces) is not None):
                numbering[spaces] += 1
                txt = '#%d' % numbering[spaces]
        return spaces * 2 + txt + "\n" if not txt[0] in '{}' else None

    @classmethod
    def read_scf_file(cls, filename):
        lines = ["Arrival Time: 00:00:00.000  scf config:"]
        filter_items = ['distName=', 'name=', '<item>', '<p>']
        replace_items = [
            (r'.*?distName="([^"]*?)"(.|\n|\r)*', r"\g<1>"),
            (r'.*?name="([^"]*?)">(.*?)</p>(.|\n|\r)*', r"\g<1>: \g<2>"),
            (r'.*?name="([^"]*?)">\s*$', r"\g<1>"),
            (r'^\s*<item>\s*$', 'item'),
            (r'^\s*<p>(.*?)</p>\s*$', r"\g<1>")
        ]
        with cls.open(filename) as rf:
            for line in rf:
                if any(i in line for i in filter_items):
                    lines.append(cls._scf_handle_line(line, lines, replace_items))
        return "\n".join(lines)

    @staticmethod
    def _scf_handle_line(line, lines, replace_items):
        m = re.match('^( *)', line)
        spaces = m.group(1)
        for search, replace in replace_items:
            line = re.sub(search, replace, line)
        return spaces * 2 + line

    @classmethod
    def read_emil_file(cls, filename):
        lines = []
        last_line = ''
        numbering = {}
        msg_body = False
        with cls.open(filename) as rf:
            for line in rf:
                if not msg_body and cls._emil_enter_msg_body(line):
                    lines.append("Arrival Time: 00:00:00.000\n")
                    line = "emil message: " + line
                    msg_body = True
                elif msg_body and cls._emil_quit_msg_body(line):
                    lines.append("\n")
                    msg_body = False
                if msg_body:
                    result = cls._emil_handle_msg_body(line, last_line, numbering)
                    if result:
                        lines.append(result)
                last_line = line.rstrip()
        return "".join(lines)

    @staticmethod
    def _emil_enter_msg_body(line):
        return ':' in line and not line.startswith('Message:')

    @staticmethod
    def _emil_quit_msg_body(line):
        return re.match(r"^\s*$", line)

    @staticmethod
    def _emil_handle_msg_body(line, last_line, numbering):
        m = re.match(r'^( *)(.*?)[\s,{:]*$', line)
        txt = m.group(2)
        spaces = m.group(1)
        parent_txt = ""
        if not txt:
            if line.rstrip().endswith('{') and last_line:
                if last_line.endswith('{'):
                    numbering[spaces] = 0
                    txt = '#0'
                elif last_line.endswith(','):
                    numbering[spaces] += 1
                    txt = '#%d' % numbering[spaces]
        elif ' ' in txt and ' :' in line:  # double key, first should be parent
            parent, child = txt.split(' ', 1)
            if child and child[0] != ':':
                parent_txt = spaces * 4 + parent + "\n"
                txt = child
                spaces += ' '
        # return parent_txt + spaces * 4 + txt + "\n" if txt and not txt[0] in '{}' else None
        return parent_txt + spaces * 4 + txt.replace(' : ', ' ') + "\n" if txt and not txt[0] in '{}' else None

    @classmethod
    def read_emil_json_file(cls, filename):
        lines = []
        last_line = ''
        numbering = {}
        json_content_close_string = ''
        json_content = False
        msg_body = False
        base_indent = 0
        with cls.open(filename) as rf:
            for line in rf:
                if not json_content:
                    if json_content_close_string := cls._emil_json_enter_json_content(line):
                        json_content = True
                else:
                    if not msg_body:
                        if line.startswith(json_content_close_string):
                            json_content_close_string = ''
                            json_content = False
                        else:
                            if base_indent := cls._emil_json_enter_msg_body(line):
                                lines.append("Arrival Time: 00:00:00.000\n")
                                line = "emil message: " + line.split('"')[1] + "\n"
                                msg_body = True
                    elif cls._emil_json_quit_msg_body(line, base_indent):
                        lines.append("\n")
                        msg_body = False
                if msg_body:
                    result = cls._emil_json_handle_msg_body(line, last_line, numbering, base_indent)
                    if result:
                        lines.append(result)
                last_line = line.rstrip()
        return "".join(lines)

    @classmethod
    def _emil_json_enter_json_content(cls, line):
        json_content_close_string = ''
        if line.rstrip().endswith('"JsonContent": ['):
            json_content_close_string = re.sub('".*', ']', line.rstrip())
        elif line.rstrip().endswith('"JsonContent": {'):
            json_content_close_string = re.sub('".*', '}', line.rstrip())
        return json_content_close_string

    @staticmethod
    def _emil_json_enter_msg_body(line):
        if ':' in line and '{' in line and 'JsonContent' not in line:
            return line.index('"')
        return 0

    @staticmethod
    def _emil_json_quit_msg_body(line, base_indent):
        return line.startswith(' ' * base_indent + '}')

    @staticmethod
    def _emil_json_handle_msg_body(line, last_line, numbering, base_indent):
        m = re.match(r'^( *)(.*?)[\s,{:\[]*$', line)
        txt = m.group(2)
        spaces = m.group(1)[base_indent-4:]
        if not txt:
            if line.rstrip().endswith('{') and last_line:
                if last_line.endswith('['):
                    numbering[spaces] = 0
                    txt = '#0'
                elif last_line.endswith(','):
                    numbering[spaces] += 1
                    txt = '#%d' % numbering[spaces]
        return spaces + txt.replace(':', '').replace('"', '') + "\n" if txt and not txt[0] in '[]{}' else None

    @classmethod
    def read_swconfig_file(cls, filename):
        lines = ["Arrival Time: 00:00:00.000"]
        with cls.open(filename) as rf:
            for line in rf:
                m = re.match(r'^(0x\S+)\s*=\s*(\S+)', line)
                if m:
                    lines.append("%s %s" % (m.group(1), m.group(2)))
        return "\n".join(lines)

    @staticmethod
    def _default_reader(filename):
        with InfoReader.open(filename) as rf:
            return rf.read()

    @classmethod
    def read_file(cls, filename, file_type):
        file_type = file_type or cls.get_file_type(filename)
        parser_map = {'egate': cls.read_egate_file,
                      'scf': cls.read_scf_file,
                      'emil': cls.read_emil_file,
                      'emil_json': cls.read_emil_json_file,
                      'swconfig': cls.read_swconfig_file}
        return parser_map.get(file_type, cls._default_reader)(filename)
