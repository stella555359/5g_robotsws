import sys
import os
from pathlib import Path
import shutil
from datetime import datetime
import re


__version__ = '2.4.1'
__date__ = '24/02/2022'


# List of robot libraries excluded from the documentation
list_of_excluded_libraries = ['AicTools.robot',
                              'SA_keywords_2.robot',
                              'UteTools.robot',
                              'UteWts.robot',
                              'Workaround.robot']

# List of python libraries to include in the documentation
list_of_python_libraries = ['ScfVendorOperations.py',
                            'MultiScf.py']

# Name of files to define global variable in SWENG
g_libname_of_global_var = 'Variables'
g_text_file_of_global_var = '%s.txt' % g_libname_of_global_var
g_robot_file_of_global_var = '%s.robot' % g_libname_of_global_var


def error(msg):
    """
    Prints an error message.
    :param msg: (str) Message
    :return: -
    """
    print("[ERROR] %s" % msg)


def ok(msg):
    """
    Prints an ok message.
    :param msg: (str) Message
    :return: -
    """
    print("[-OK-]  %s" % msg)


def info(msg):
    """
    Prints a simple message for information.
    :param msg: (str) Message
    :return: -
    """
    print(msg)


def title(msg):
    """
    Prints a title as:
      ----------------
      Example of title
      ---------------
    :param msg: (str) Title
    :return: -
    """
    print('-' * len(msg))
    print(msg)
    print('-' * len(msg))


def remove_file(filename):
    """
    Removes the file filename.
    :param filename: Filename
    :return: -
    """
    try:
        os.remove(filename)
    except OSError:
        pass


def exec_cmd(cmd):
    """
    Executes the command cmd. Returns True if no OS error otherwise False.
    :param cmd: (str) Command
    :return: (bool)
    """
    # print('exec_cmd( "%s" )' % cmd)
    try:
        os.system(cmd)
        return True
    except OSError:
        error('Cannot execute command [%s] : %s' % (cmd, sys.exc_info()[0]))
    return False


def open_file(filename, mode='r'):
    """
    Open the file filename in mode mode. Return a file object if no error otherwiser None.
    :param filename: (str) Filename
    :param mode: (str) File open mode: 'r' open in read only mode; 'w' open in write mode.
    :return: (file object)
    """
    try:
        f = open(filename, mode)
        return f
    except OSError:
        error("Cannot open '%s': [%s]" % (filename, sys.exc_info()[0]))
    return None


def get_sweng_version(filename):
    """
    Get the SWENG version in Version.py file.
    :param filename: (str) Filename of file containing the SWENG version
    :return: (str)
    """
    fileversion = open_file(filename=filename, mode='r')
    if not fileversion:
        return ''
    expression = r'SWENG_VERSION\ +=\ +['
    expression += r"'"
    expression += r'"](?P<version>[0-9]+\.[0-9]+\.[0-9]+)['
    expression += r"'"
    expression += r'"]'
    for ln in fileversion:
        line_match = re.match(expression, ln)
        if line_match:
            version = line_match.group('version')
            if version is not None:
                return version
    return ''


def copy_sweng_global_var_text_file_in_robot_file(path, txt_file, robot_file):
    shutil.copyfile(os.path.join(path, txt_file), os.path.join(path, robot_file))


class LibPythonAsRobotDoc(object):
    """
    Class to create an equivalent Robot library file containing the documentation of a python library.
    """

    def __init__(self):
        self.NOTHING = 0
        self.CLASS = 1
        self.DEF = 2
        self.ITDEF = 3
        self.IN_DOC_CLASS = 4
        self.OUT_DOC_CLASS = 5
        self.IN_DOC_DEF = 6
        self.OUT_DOC_DEF = 7
        self.fin = None
        self.fout = None
        self.expression_object = r'class (?P<class_name>[0-9_A-Za-z]+)\(object\):'
        self.expression_def = r'    def (?P<def_name>[0-9_A-Za-z]+)\((?P<arguments>.*)\):'
        self.expression_def2 = r'    def (?P<def_name>[0-9_A-Za-z]+)\((?P<arguments>.*),'
        self.expression_def3 = r'(?P<arguments>.*)\):'
        self.expression_def4 = r'(?P<arguments>.*),'
        self.status = self.NOTHING
        self.def_init = False
        self.doc_done = False
        self.line = ''
        self.class_name = ''
        self.def_name = ''
        self.arguments = ''
        self.put_log_console = False

    def _is_number(self, s):
        """
        Returns True if the string s contains only digit.
        :param s: (str) String to check
        :return: (bool)
        """
        first = True
        for c in s:
            if c not in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']:
                if not first or (c != '-'):
                    return False
            first = False
        return True

    def _write_keyword_header(self):
        """
        Writes in Robot library file the header of a keyword.
        :return: -
        """
        self.fout.write('\n%s\n' % self.def_name)
        sargs = self.arguments.strip()
        if len(sargs) > 0:
            largs = sargs.split(',')
            first = True
            for arg in largs:
                a_arg = arg.strip()
                if (a_arg == 'self') or (a_arg == '**kwargs'):
                    continue
                else:
                    nv_arg = a_arg.split('=')
                    if first:
                        self.fout.write('    [Arguments]')
                    if len(nv_arg) == 1:
                        self.fout.write('    ${%s}' % a_arg)
                    else:
                        v_arg = nv_arg[1].strip()
                        if self._is_number(v_arg) or (a_arg[0] == '"') or (a_arg[0] == "'"):
                            self.fout.write('    ${%s}=%s' % (nv_arg[0].strip(), v_arg))
                        else:
                            self.fout.write('    ${%s}=${%s}' % (nv_arg[0].strip(), v_arg))
                    first = False
            if not first:
                self.fout.write('\n')

    def _open_files(self, python_filename, documentation_filename):
        """
        Opens the python library file in read only mode and the Robot library file in write mode.
        Returns True if the opening of the both files is without error otherwise False.
        :param python_filename: (str) File name of python library file
        :param documentation_filename: (str) File name of Robot library file
        :return: (bool)
        """
        self.fin = open_file(filename=python_filename, mode='r')
        if not self.fin:
            return False
        self.fout = open_file(filename=documentation_filename, mode='w')
        if not self.fout:
            self.fin.close()
            return False
        return True

    def _print_comment(self, s, indent, bullet=False):
        """
        Print the documentation line from python library to Robot library.
        :param s: (str) String to write as comment for documentation
        :param indent: (str) Indentation as a string
        :param bullet: (bool) If is True then add a '-' before the comment to indicate that is a bullet.
        :return: -
        """
        if not self.doc_done:
            if indent == '':
                self.fout.write('Documentation\n')
            else:
                self.fout.write('    [Documentation]\n')
        self.doc_done = True
        if bullet:
            self.fout.write('%s...     - %s\n' % (indent, s))
        else:
            if (len(s) > 2) and (s[0] == '|') and (s[-1] != '|'):
                space = False
                line = ''
                for e in s:
                    if space and (e == ' '):
                        line += '\\ '
                    else:
                        line += e
                    if e == ' ':
                        space = True
                    else:
                        space = False
                self.fout.write('%s...     %s\n' % (indent, line))
            else:
                self.fout.write('%s...     %s\n' % (indent, s))

    def _print_log_console(self):
        """
        For each keyword in Robot library, onle one instruction is put ('Log to Console') to avoid and
        empty keyword.
        :return: -
        """
        if not self.put_log_console:
            self.fout.write('    Log to Console    Inside Keyword\n')
        self.put_log_console = True

    def _def_detection(self):
        """
        Detects if the line corresponding to a header of python function interpreting as a robot keyword.
        :return: -
        """
        line_match = re.match(self.expression_def, self.line)
        if line_match:
            self.def_name = line_match.group('def_name')
            self.arguments = line_match.group('arguments')
            self.doc_done = False
            self.def_init = False
            if self.def_name[0] == '_':
                self.def_init = True
            else:
                self._print_log_console()
                self._write_keyword_header()
                self.put_log_console = False
                self.status = self.DEF
        else:
            line_match = re.match(self.expression_def2, self.line)
            if line_match:
                self.def_name = line_match.group('def_name')
                self.arguments = line_match.group('arguments')
                self.doc_done = False
                self.def_init = False
                if self.def_name[0] == '_':
                    self.def_init = True
                else:
                    self.status = self.ITDEF

    def _interface_def_case(self):
        """
        Detects if the line corresponding to a header of python function interpreting as a robot keyword in of
        a definition on several lines.
        :return: -
        """
        line_match = re.match(self.expression_def3, self.line)
        if line_match:
            self.arguments += ',' + line_match.group('arguments')
            if self.def_name[0] == '_':
                self.def_init = True
            else:
                self._print_log_console()
                self._write_keyword_header()
                self.put_log_console = False
                self.status = self.DEF
        else:
            line_match = re.match(self.expression_def4, self.line)
            if line_match:
                self.arguments += ',' + line_match.group('arguments')

    def _nothing_case(self):
        """
        Processing of NOTHING status
        :return: -
        """
        if (len(self.line) > 6) and (self.line[:6] == 'class '):
            line_match = re.match(self.expression_object, self.line)
            if line_match:
                self.class_name = line_match.group('class_name')
                self.status = self.CLASS

    def _class_case(self):
        """
        Processing of CLASS status
        :return: -
        """
        if (len(self.line) >= 7) and (self.line[:7] == '    """'):
            if len(self.line) > 7:
                self._print_comment(s=self.line[7:], indent='')
            self.status = self.IN_DOC_CLASS
        elif (len(self.line) > 8) and (self.line[:8] == '    def '):
            self._def_detection()

    def _in_doc_class_case(self):
        """
        Processing of IN_DOC_CLASS status
        :return: -
        """
        if (len(self.line) >= 7) and (self.line[:7] == '    """'):
            self.fout.write('\n*** Keywords ***\n')
            self.status = self.OUT_DOC_CLASS
        elif (len(self.line) >= 3) and (self.line[-3:] == '"""'):
            comment = self.line.strip()
            if len(comment) > 3:
                self._print_comment(s=comment[:-3], indent='')
                self.fout.write('\n*** Keywords ***\n')
                self.status = self.OUT_DOC_CLASS
        else:
            self._print_comment(s=self.line.strip(), indent='')

    def _out_doc_case(self):
        """
        Processing of OUT_DOC_CLASS or OUT_DOC_DEF status
        :return: -
        """
        if (len(self.line) > 8) and (self.line[:8] == '    def '):
            self._def_detection()

    def _def_case(self):
        """
        Processing of DEF status
        :return: -
        """
        if (len(self.line) >= 11) and (self.line[:11] == '        """'):
            if len(self.line) > 11:
                self._print_comment(s=self.line[11:], indent='    ')
            self.status = self.IN_DOC_DEF
        elif (len(self.line) > 8) and (self.line[:8] == '    def '):
            self._def_detection()

    def _in_doc_def_case(self):
        """
        Processing of IN_DOC_DEF status
        :return: -
        """
        if (len(self.line) >= 11) and (self.line[:1] == '        """'):
            self._print_log_console()
            self.status = self.OUT_DOC_DEF
        elif (len(self.line) >= 11) and (self.line[-3:] == '"""'):
            comment = self.line.strip()
            if len(comment) > 3:
                self._print_comment(s=comment[:-3], indent='    ')
            self._print_log_console()
            self.status = self.OUT_DOC_DEF
        else:
            if not self.def_init:
                comment = self.line.strip()
                if (len(comment) >= 7) and (comment[:7] == ':param '):
                    if len(comment) > 7:
                        self._print_comment(s=comment[7:], indent='    ', bullet=True)
                elif (len(comment) >= 9) and (comment[:9] == ':return: '):
                    self._print_comment(s='', indent='    ')
                    self._print_comment(s='Return: ' + comment[9:], indent='    ')
                else:
                    self._print_comment(s=comment, indent='    ')

    def create_robot_doc_of_lib_python(self, python_filename, documentation_filename):
        """
        Creates an equivalent Robot library file containing the documentation of a python library.
        :param python_filename: (str) File name of python library file
        :param documentation_filename: (str) File name of Robot library file
        :return: -
        """
        if not self._open_files(python_filename, documentation_filename):
            return
        self.fout.write('*** Settings ***\n')
        for ln in self.fin:
            self.line = ln.rstrip()
            if self.status == self.NOTHING:
                self._nothing_case()
            elif self.status == self.CLASS:
                self._class_case()
            elif self.status == self.IN_DOC_CLASS:
                self._in_doc_class_case()
            elif (self.status == self.OUT_DOC_CLASS) or (self.status == self.OUT_DOC_DEF):
                self._out_doc_case()
            elif self.status == self.DEF:
                self._def_case()
            elif self.status == self.ITDEF:
                self._interface_def_case()
            elif self.status == self.IN_DOC_DEF:
                self._in_doc_def_case()
        if self.status in [self.DEF, self.IN_DOC_DEF, self.OUT_DOC_DEF]:
            self._print_log_console()
        self.fin.close()
        self.fout.close()


class ListLib:
    """
    Class to manage the library list.
    self.list_lib = [ {'Name': '<robot library name>',
                       'Purpose': '<small text giving the purpose library>',
                       'Filename': '<filename of library adapted for documentation generation>',
                       'Doc HTML': <'filename of library documentation in HTML format'>
                      }
                      ...
                    ]
    """

    def __init__(self):
        self.list_lib = []

    def add_lib(self, name, purpose, filename, doc_html):
        """
        Adds a robot library to the list
        :param name: (str) Robot library name
        :param purpose: (str) Small text giving the purpose library
        :param filename: (str) Filename of library adapted for documentation generation
        :param doc_html: (str) Filename of library documentation in HTML format
        :return: -
        """
        self.list_lib.append({'Name': name, 'Purpose': purpose, 'Filename': filename, 'Doc HTML': doc_html})

    def get_list(self):
        """
        Returns the libray list.
        :return: (list)
        """
        return self.list_lib

    def get_list_sorted(self):
        """
        Returns the sorted library list.
        :return: (list)
        """
        llist = self.list_lib
        n = len(llist)
        element_echange = True
        while element_echange:
            element_echange = False
            for i in range(0, n - 1):
                if llist[i]['Name'].lower() > llist[i + 1]['Name'].lower():
                    element_echange = True
                    llist[i], llist[i + 1] = llist[i + 1], llist[i]
        return llist

    def display(self):
        """
        Prints the library list. Used for debug.
        :return:
        """
        for lib in self.list_lib:
            print('Name: %s    [%s]     Filename: %s    Doc_HTML: %s' %
                  (lib['Name'], lib['Purpose'], lib['Filename'], lib['Doc HTML']))


class ReadRobot:
    """
    Class to convert a raw robot library into a converted library adapted to generate the documentation.

    Example on the following robot library:
        /CinqG/sweng5G/master/robotws/testsuite/Paris/resources/SWENG/robot/Backup.robot

     - self.robot_filename: Full filename of robot library (path + basename)
         [/CinqG/sweng5G/master/robotws/testsuite/Paris/resources/SWENG/robot/Backup.robot]

     - self.lib_name: Library name
         [Backup]

     - self.robot_name: Basename of robot library file
         [Backup.robot]

     - self.robot_dir: Path of robot library file
         [/CinqG/sweng5G/master/robotws/testsuite/Paris/resources/SWENG/robot]

     - self.converted_robot_name: Basename of robot library converted file
         [DOC_Backup.robot]

     - self.converted_robot_filename: Full filename of robot library converted
         [/CinqG/sweng5G/master/robotws/testsuite/Paris/resources/SWENG/robot/DOC_Backup.robot]

     - self.purpose_string: Purpose of robot library
    """

    def __init__(self, robot_filename):
        self.robot_filename = robot_filename
        self.lib_name = Path(robot_filename).stem
        self.robot_name = os.path.basename(robot_filename)
        self.robot_dir = os.path.dirname(robot_filename)
        self.converted_robot_name = 'DOC_' + self.robot_name
        self.converted_robot_filename = os.path.join(self.robot_dir, self.converted_robot_name)
        self.purpose_string = ''

    def convert_robot(self, kw_list_filename):
        """
        Converts a raw robot library into a converted library adapted to generate the documentation.
        Returns True if no error on file opening otherwise False.
        :param kw_list_filename: (str) Filename of file containing the list of all robot keywords.
        :return: (bool)
        """
        original_robot_file = open_file(filename=self.robot_filename, mode='r')
        if not original_robot_file:
            return False
        doc_robot_file = open_file(filename=self.converted_robot_filename, mode='w')
        if not doc_robot_file:
            original_robot_file.close()
            return False
        kw_list_file = open_file(filename=kw_list_filename, mode='a')
        if not kw_list_file:
            original_robot_file.close()
            doc_robot_file.close()
            return False
        state = 'START'
        kw = ''
        kw_ln = ''
        kw_internal = False
        for ln in original_robot_file:
            line = ln.rstrip()
            do_write = True
            if line.lower()[0:16] == '*** settings ***':
                state = 'SETTINGS'
            elif line.lower()[0:17] == '*** variables ***':
                state = 'VARIABLES'
            elif line.lower()[0:16] == '*** keywords ***':
                state = 'KEYWORDS'
            elif state == 'SETTINGS':
                if line.lower()[0:13] == 'documentation':
                    state = 'DOCUMENTATION'
                    if '= purpose =' in line.lower():
                        state = 'PURPOSE'
            elif state == 'DOCUMENTATION':
                if ln.strip()[0:3] == '...':
                    if '= purpose =' in line.lower():
                        state = 'PURPOSE'
                else:
                    state = 'SETTINGS'
            elif state == 'PURPOSE':
                if ln.strip()[0:3] == '...':
                    if '= description =' in line.lower():
                        state = 'SETTINGS'
                    else:
                        lstr = ln.strip()[3:].strip()
                        if lstr != '':
                            if self.purpose_string != '':
                                self.purpose_string += ' '
                            self.purpose_string += lstr
                else:
                    state = 'SETTINGS'
            elif state == 'KEYWORDS':
                if len(line) > 0:
                    if line[0] not in ['#', ' ', '\t']:
                        if (kw != '') and not kw_internal:
                            if kw_ln != '':
                                kw_list_file.write('%s:%s\n' % (self.lib_name, kw_ln))
                            doc_robot_file.write(kw)
                            kw_ln = ''
                        state = 'IN_KW'
                        kw_internal = False
                        kw_ln = line
                        kw = ln
                        do_write = False
            elif state == 'IN_KW':
                if len(line) > 0:
                    do_write = False
                    if line[0] not in ['#', ' ', '\t']:
                        if (kw != '') and not kw_internal:
                            if kw_ln != '':
                                kw_list_file.write('%s:%s\n' % (self.lib_name, kw_ln))
                            doc_robot_file.write(kw)
                            kw_ln = ''
                        state = 'IN_KW'
                        kw_internal = False
                        kw_ln = line
                        kw = ln
                    else:
                        kw += ln
                        if ln.strip().lower()[0:15] == '[documentation]':
                            state = 'DOC_KW'
                            if 'internal usage' in ln.lower():
                                kw_ln = ''
                                kw_internal = True
            elif state == 'DOC_KW':
                if len(line) > 0:
                    do_write = False
                    if line[0] not in ['#', ' ', '\t']:
                        if (kw != '') and not kw_internal:
                            if kw_ln != '':
                                kw_list_file.write('%s:%s\n' % (self.lib_name, kw_ln))
                            doc_robot_file.write(kw)
                            kw_ln = ''
                        state = 'IN_KW'
                        kw_internal = False
                        kw_ln = line
                        kw = ln
                    else:
                        kw += ln
                        if ln.strip()[0:3] == '...':
                            if 'internal usage' in ln.lower():
                                kw_ln = ''
                                kw_internal = True
                        else:
                            state = 'IN_KW'
            if do_write:
                if kw_ln != '':
                    kw_list_file.write('%s:%s\n' % (self.lib_name, kw_ln))
                doc_robot_file.write(ln)
                kw_ln = ''
        if (kw != '') and not kw_internal:
            if kw_ln != '':
                kw_list_file.write('%s:%s\n' % (self.lib_name, kw_ln))
            doc_robot_file.write(kw)
        original_robot_file.close()
        doc_robot_file.close()
        kw_list_file.close()
        return True

    def get_purpose_string(self):
        """
        Returns the purpose of robot library.
        :return: (str)
        """
        return self.purpose_string

    def get_converted_robot_filename(self):
        """
        Full filename of robot library converted.
        :return: (str)
        """
        return self.converted_robot_filename

    def get_lib_name(self):
        """
        Returns the library name.
        :return: (str)
        """
        return self.lib_name

    def get_robot_name(self):
        """
        Returns basename of robot library file.
        :return: (str)
        """
        return self.robot_name

    def get_converted_robot_name(self):
        """
        Returns basename of robot library converted file.
        :return: (str)
        """
        return self.converted_robot_name


def create_doc_directory(directory):
    """
    Create the directory (directory). If it already exists then it removes before.
    :param directory: (str) Directory name.
    :return: -
    """
    if os.path.isdir(directory):
        shutil.rmtree(directory)
    if os.path.isfile(directory):
        os.remove(directory)
    os.makedirs(directory)


def header_index(index_file, version):
    """
    Writes in the index.html file, the HTML header.
    :param index_file: (file object) Filename of file index.html.
    :param version: (str) SWENG version.
    :return: -
    """
    index_file.write('<!DOCTYPE html>\n')
    index_file.write('<html lang="en">\n')
    index_file.write('<head>\n')
    index_file.write(' <meta charset="UTF-8">\n')
    index_file.write('    <title>%s</title>\n' % version)
    index_file.write('<style media="all" type="text/css">'
                     ' body { background: white; color: black; font-size: small; font-family: sans-serif;'
                     ' padding: 0 0.5em; }'
                     ' .metadata th { text-align: left; padding-right: 1em; }'
                     ' a.name, span.name { font-style: italic; }'
                     ' a, a:link, a:visited { color: #c30; }'
                     ' a img { border: 1px solid #c30 !important; }'
                     ' a:hover, a:active { text-decoration: underline; color: black; }'
                     ' a:hover { text-decoration: underline !important; }'
                     ' .shortcuts { margin: 1em 0; font-size: 0.9em; }'
                     ' .shortcuts a { display: inline-block; text-decoration: none;'
                     ' white-space: nowrap; color: black; }'
                     ' .shortcuts a::first-letter { font-weight: bold; letter-spacing: 0.1em; }'
                     ' .normal-first-letter::first-letter { font-weight: normal !important;'
                     ' letter-spacing: 0 !important; }'
                     ' .keywords { border: 1px solid #ccc; border-collapse: collapse;'
                     ' empty-cells: show; margin: 0.3em 0; width: 100%; }'
                     ' .keywords th, .keywords td { border: 1px solid #ccc; padding: 0.2em; vertical-align: top; }'
                     ' .keywords th { background: #ddd; color: black; }'
                     ' .kw, .args, .tags { min-width: 100px; max-width: 20%; }'
                     ' td.kw a { color: inherit; text-decoration: none; font-weight: bold; }'
                     ' .args span { font-style: italic; padding: 0 0.1em; }'
                     ' .tags a { color: inherit; text-decoration: none; padding: 0 0.1em; }'
                     ' .footer { font-size: 0.9em; }'
                     ' /* Docs originating from HTML and reST are wrapped to divs. */ .doc div > *:first-child'
                     ' { margin-top: 0; }'
                     ' .doc div > *:last-child { /* Does not work with IE8. */ margin-bottom: 0; }'
                     ' #search, #open-search { position: fixed; bottom: 5px; right: 5px; z-index: 1000; }'
                     ' #search { width: 30em; display: none; }'
                     ' #open-search { border: 2px solid #ccc; border-radius: 4px; width: 40px; height: 40px;'
                     ' background-color: white; background-repeat: no-repeat; background-position: center;'
                     ' background-image: url(data:image/png;base64,'
                     'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACx'
                     'MBAJqcGAAAAY5JREFUSImt1LtrFGEUBfCfURsFHwEr29UNkS3MFklrQK0EIYUk/5IQ0FSmCCKW1mpAommToCKoK'
                     '+lsLUKeSFbXFLuT3B13Hjt64INvOPeec+fOnUs2mpjHBrbRwQE+YQFTObm5qGMZf0qct7gxjPgM9kqKJ+cAs2XFf'
                     '4fEX3iOe7iKsxjFHTxFO8R2ikzqqcq/oVFQUANfUm8ynhUce97qVVoGo/gaclcGBTVDQDuvigw09Lfrr+maD+TSk'
                     'OIJngWNx2lyI5C3KxrcDRof0+R2IC9XNLgSNPbTZDKa7YricFr/v3EqIUZ0xxPO4FxFg0vhnoz7scFmICcqGjTDv'
                     'RWJEayG57mKBg/C/U2anHDSu5+oDSlex6GTlTE2KOhVMPmACyXFL+qOZZL7Xf/3OMY17KZMrheI13px6e26nmVyX'
                     '3eDxnYt4lav0qTiaTzp8VkrPNdkNyOpkyM4lEkNL0uK/CjgXw8ySHATD7GGLd0/fgfv8QiTOI93BSb/jCKT/4Isk1'
                     'ZOTiWTF0H8M8aPANvFyARlADGFAAAAAElFTkSuQmCC);'
                     ' background-image: url(data:image/svg+xml;base64,'
                     'PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4IiBoZWlnaHQ9IjgiIHZpZXdCb'
                     '3g9IjAgMCA4IDgiPgogIDxwYXRoIGQ9Ik0zLjUgMGMtMS45MyAwLTMuNSAxLjU3LTMuNSAzLjVzMS41NyAzLjUgMy'
                     '41IDMuNWMuNTkgMCAxLjE3LS4xNCAxLjY2LS40MWExIDEgMCAwIDAgLjEzLjEzbDEgMWExLjAyIDEuMDIgMCAxIDA'
                     'gMS40NC0xLjQ0bC0xLTFhMSAxIDAgMCAwLS4xNi0uMTNjLjI3LS40OS40NC0xLjA2LjQ0LTEuNjYgMC0xLjkzLTEu'
                     'NTctMy41LTMuNS0zLjV6bTAgMWMxLjM5IDAgMi41IDEuMTEgMi41IDIuNSAwIC42Ni0uMjQgMS4yNy0uNjYgMS43M'
                     'i0uMDEuMDEtLjAyLjAyLS4wMy4wM2ExIDEgMCAwIDAtLjEzLjEzYy0uNDQuNC0xLjA0LjYzLTEuNjkuNjMtMS4zOS'
                     'AwLTIuNS0xLjExLTIuNS0yLjVzMS4xMS0yLjUgMi41LTIuNXoiCiAgLz4KPC9zdmc+),'
                     ' none; background-size: 24px 24px; } #open-search:hover { background-color: #ccc; }'
                     ' fieldset { background: white; border: 2px solid #ccc; border-radius: 4px; padding: 6px 8px; }'
                     ' fieldset fieldset { border: 1px solid #ccc; margin: 4px 0; }'
                     ' #search-title { font-size: 1.1em; font-weight: bold; letter-spacing: 1px; }'
                     ' #search-string { box-sizing: border-box; width: 100%; }'
                     ' #hide-unmatched { margin: 0.5em 0 0 1em; }'
                     ' #search-buttons { float: right; }'
                     ' .highlight { background: yellow; }'
                     ' .no-match { color: gray !important; }'
                     ' tr.no-match.hide-unmatched'
                     ' { display: none; } </style> <style media="all" type="text/css"> /* '
                     'Pygments \'default\' style sheet.'
                     ' Generated with Pygments 2.1.3 using: pygmentize -S default -f html -a .code >'
                     ' src/robot/htmldata/libdoc/pygments.css */ .code .hll { background-color: #ffffcc }'
                     ' .code { background: #f8f8f8; } .code .c { color: #408080; font-style: italic }'
                     ' /* Comment */ .code .err { border: 1px solid #FF0000 } /* Error */ .code .k'
                     ' { color: #008000; font-weight: bold }'
                     ' /* Keyword */ .code .o { color: #666666 } /* Operator */ .code .ch'
                     ' { color: #408080; font-style: italic }'
                     ' /* Comment.Hashbang */ .code .cm { color: #408080; font-style: italic }'
                     ' /* Comment.Multiline */'
                     ' .code .cp { color: #BC7A00 } /* Comment.Preproc */ .code .cpf'
                     ' { color: #408080; font-style: italic }'
                     ' /* Comment.PreprocFile */ .code .c1 { color: #408080; font-style: italic }'
                     ' /* Comment.Single */'
                     ' .code .cs { color: #408080; font-style: italic } /* Comment.Special */ .code .gd'
                     ' { color: #A00000 }'
                     ' /* Generic.Deleted */ .code .ge { font-style: italic } /* Generic.Emph */ .code .gr'
                     ' { color: #FF0000 }'
                     ' /* Generic.Error */ .code .gh { color: #000080; font-weight: bold } /* Generic.Heading */'
                     ' .code .gi { color: #00A000 }'
                     ' /* Generic.Inserted */ .code .go { color: #888888 } /* Generic.Output */ .code .gp'
                     ' { color: #000080; font-weight: bold }'
                     ' /* Generic.Prompt */ .code .gs { font-weight: bold } /* Generic.Strong */ .code .gu'
                     ' { color: #800080; font-weight: bold }'
                     ' /* Generic.Subheading */ .code .gt { color: #0044DD } /* Generic.Traceback */ '
                     '.code .kc { color: #008000; font-weight: bold }'
                     ' /* Keyword.Constant */ .code .kd { color: #008000; font-weight: bold } /* '
                     'Keyword.Declaration */ .code .kn { color: #008000; font-weight: bold }'
                     ' /* Keyword.Namespace */ .code .kp { color: #008000 } /* Keyword.Pseudo */ '
                     '.code .kr { color: #008000; font-weight: bold }'
                     ' /* Keyword.Reserved */ .code .kt { color: #B00040 } /* Keyword.Type */ '
                     '.code .m { color: #666666 } /* Literal.Number */'
                     ' .code .s { color: #BA2121 } /* Literal.String */ .code .na { color: #7D9029 }'
                     ' /* Name.Attribute */'
                     ' .code .nb { color: #008000 } /* Name.Builtin */ .code .nc { color: #0000FF;'
                     ' font-weight: bold } /* Name.Class */'
                     ' .code .no { color: #880000 } /* Name.Constant */ .code .nd { color: #AA22FF }'
                     ' /* Name.Decorator */'
                     ' .code .ni { color: #999999; font-weight: bold } /* Name.Entity */ .code .ne'
                     ' { color: #D2413A; font-weight: bold }'
                     ' /* Name.Exception */ .code .nf { color: #0000FF } /* Name.Function */ .code .nl'
                     ' { color: #A0A000 }'
                     ' /* Name.Label */ .code .nn { color: #0000FF; font-weight: bold } /* Name.Namespace */ '
                     '.code .nt { color: #008000; font-weight: bold }'
                     ' /* Name.Tag */ .code .nv { color: #19177C } /* Name.Variable */ .code .ow'
                     ' { color: #AA22FF; font-weight: bold }'
                     ' /* Operator.Word */ .code .w { color: #bbbbbb } /* Text.Whitespace */ .code .mb'
                     ' { color: #666666 } /* Literal.Number.Bin */'
                     ' .code .mf { color: #666666 } /* Literal.Number.Float */ .code .mh { color: #666666 }'
                     ' /* Literal.Number.Hex */'
                     ' .code .mi { color: #666666 } /* Literal.Number.Integer */ .code .mo { color: #666666 }'
                     ' /* Literal.Number.Oct */'
                     ' .code .sb { color: #BA2121 } /* Literal.String.Backtick */ .code .sc { color: #BA2121 }'
                     ' /* Literal.String.Char */'
                     ' .code .sd { color: #BA2121; font-style: italic } /* Literal.String.Doc */ .code .s2'
                     ' { color: #BA2121 } /* Literal.String.Double */'
                     ' .code .se { color: #BB6622; font-weight: bold } /* Literal.String.Escape */ .code .sh'
                     ' { color: #BA2121 } /* Literal.String.Heredoc */'
                     ' .code .si { color: #BB6688; font-weight: bold } /* Literal.String.Interpol */ .code .sx'
                     ' { color: #008000 } /* Literal.String.Other */'
                     ' .code .sr { color: #BB6688 } /* Literal.String.Regex */ .code .s1 { color: #BA2121 }'
                     ' /* Literal.String.Single */ .code .ss { color: #19177C }'
                     ' /* Literal.String.Symbol */ .code .bp { color: #008000 } /* Name.Builtin.Pseudo */ '
                     '.code .vc { color: #19177C } /* Name.Variable.Class */'
                     ' .code .vg { color: #19177C } /* Name.Variable.Global */ .code .vi { color: #19177C }'
                     ' /* Name.Variable.Instance */'
                     ' .code .il { color: #666666 } /* Literal.Number.Integer.Long */ </style>'
                     ' <style media="print" type="text/css"> body { margin: 0;'
                     ' padding: 0; font-size: 8pt; } a { text-decoration: none; } #search, #open-search'
                     ' { display: none; } </style> <style media="all" type="text/css">'
                     ' #javascript-disabled { width: 600px; margin: 100px auto 0 auto; padding: 20px;'
                     ' color: black; border: 1px solid #ccc; background: #eee; }'
                     ' #javascript-disabled h1 { width: 100%; float: none; } #javascript-disabled ul'
                     ' { font-size: 1.2em; } #javascript-disabled li { margin: 0.5em 0; }'
                     ' #javascript-disabled b { font-style: italic; } </style> <style media="all" type="text/css">'
                     ' .doc > * { margin: 0.7em 1em 0.1em 1em; padding: 0; }'
                     ' .doc > p, .doc > h1, .doc > h2, .doc > h3, .doc > h4 { margin: 0.7em 0 0.1em 0; } .doc >'
                     ' *:first-child { margin-top: 0.1em; }'
                     ' .doc table { border: 1px solid #ccc; background: transparent; border-collapse: collapse;'
                     ' empty-cells: show; font-size: 0.9em; } .doc table th,'
                     ' .doc table td { border: 1px solid #ccc; background: transparent; padding: 0.1em 0.3em;'
                     ' height: 1.2em; } .doc table th { text-align: center; letter-spacing: 0.1em; }'
                     ' .doc pre { font-size: 1.1em; letter-spacing: 0.05em; background: #f4f4f4; } .doc code'
                     ' { padding: 0 0.2em; letter-spacing: 0.05em; background: #eee; }'
                     ' .doc li { list-style-position: inside; list-style-type: square; } .doc img '
                     '{ border: 1px solid #ccc; } .doc hr { background: #ccc; height: 1px; border: 0; } </style>\n')
    index_file.write('</head>\n')


def body_index(index_file, title_lib, version, introduction, tool_name, execution_date, lib_robot):
    """
    Writes in the index.html file, the HTML body and ender.
    :param index_file: (file object) Filename of file index.html.
    :param title_lib: (str) Title of the HTML page.
    :param version: (str) SWENG version.
    :param introduction: (str) Text to introduce the library documentation.
    :param tool_name: (str) Tool name that generated the documentation.
    :param execution_date: (str) Date of documentation generation
    :param lib_robot: (list) Listr of libraries
    :return: -
    """
    index_file.write('<body>\n')
    index_file.write('<h1>%s</h1>\n' % title_lib)
    index_file.write('<table class="metadata">\n')
    index_file.write('    <tbody><tr><th>Library version:</th><td>%s</td></tr></tbody></table>\n' % version)
    index_file.write('    <div id="introduction-container">\n')
    index_file.write('        <h2 id="Introduction">Introduction</h2>\n')
    index_file.write('        <div class="doc">\n')
    for s in introduction:
        index_file.write('            <p>%s</p>\n' % s)
    index_file.write('        </div>\n')
    index_file.write('    </div>\n')
    index_file.write('<div><h2>Available libraries</h2>\n')
    index_file.write('<table class="keywords" border="1">    <tbody>\n')
    index_file.write('<tr>    <th class="kw">Library</th>    <th class="doc">Documentation</th>    </tr>\n')
    for llib in lib_robot:
        index_file.write('        <tr><td class="kw">\n')
        index_file.write('        <a href="%s" title="Link to this library documentation">%s</a>\n' %
                         (llib['Doc HTML'], llib['Name']))
        index_file.write('        </td><td class="doc">\n')
        index_file.write('        <p>%s</p></td></tr>\n' % llib['Purpose'])
    index_file.write('</tbody></table></div>\n')
    index_file.write('<div id="footer-container"><p class="footer">\n')
    index_file.write('    <br>\n')
    index_file.write('<body>\n')
    index_file.write('    Generated by %s on %s.\n' % (tool_name, execution_date))
    index_file.write('</p></div>\n')
    index_file.write('</body>\n')
    index_file.write('</html>\n')


def generating_index(doc_dir, version, title_lib, introduction, tool_name, exec_date, lib_robot_list):
    """
    Generates the index.html file.
    Returns True if no error on opening index.html file otherwise False.
    :param doc_dir: (str) path name where index.html file is created.
    :param version: (str) SWENG version
    :param title_lib: (str) Title of the HTML page.
    :param introduction: (str) Text to introduce the library documentation.
    :param tool_name: (str) Tool name that generated the documentation.
    :param exec_date: (str) Date of documentation generation
    :param lib_robot_list: (list) List of libraries
    :return: (bool)
    """
    doc_index_file = open_file(os.path.join(doc_dir, 'index.html'), mode='w')
    if not doc_index_file:
        return False
    header_index(index_file=doc_index_file, version=version)
    body_index(index_file=doc_index_file, title_lib=title_lib, version=version,
               introduction=introduction, tool_name=tool_name, execution_date=exec_date,
               lib_robot=lib_robot_list)
    doc_index_file.close()
    return True


def generating_lib_list(doc_dir, version, lib_robot_list):
    """
    Generates lib_list.txt file.
    Returns True if no error on opening lib_list.txt file otherwise False.
    :param doc_dir: (str) path name where lib_list.txt file is created.
    :param version: (str) SWENG version
    :param lib_robot_list: (list) List of libraries
    :return: (bool)
    """
    lib_list_file = open_file(os.path.join(doc_dir, 'lib_list.txt'), mode='w')
    if not lib_list_file:
        return False
    for llib in lib_robot_list:
        if llib['Purpose'] != '':
            lib_list_file.write('%s:%s:%s\n' % (llib['Name'], llib['Doc HTML'], llib['Purpose']))
        else:
            lib_list_file.write('%s:%s:-\n' % (llib['Name'], llib['Doc HTML']))
    lib_list_file.close()
    return True


def modfy_python_lib(doc_dir, doc_html, lib_name, debug):
    """
    Modify the HTML file of the python library documentation to change the extension of the library name
    from .robot to .py.
    :param doc_dir: (str) Path name of library HTML documentation directory.
    :param doc_html: (str) Filename of python library HTML documentation
    :param lib_name: (str) Library name
    :return: -
    """
    new_doc = doc_html + '.modified'
    fin = open_file(os.path.join(doc_dir, doc_html), mode='r')
    if not fin:
        return
    fout = open_file(os.path.join(doc_dir, new_doc), mode='w')
    if not fout:
        fin.close()
        return
    s = '"name": "%s.robot"' % lib_name
    for line in fin:
        if s in line:
            fout.write(line.replace(s, '"name": "%s.py"' % lib_name))
        else:
            fout.write(line)
    fin.close()
    fout.close()
    if not debug:
        remove_file(os.path.join(doc_dir, doc_html))
    exec_cmd('mv %s %s' % (os.path.join(doc_dir, new_doc), os.path.join(doc_dir, doc_html)))


def modfy_global_var_lib(doc_dir, doc_html, lib_name, debug):
    """
    Modify the HTML file of the SWENG global variable documentation.
    :param doc_dir: (str) Path name of library HTML documentation directory.
    :param doc_html: (str) Filename of python library HTML documentation
    :param lib_name: (str) Library name
    :return: -
    """
    new_doc = doc_html + '.modified'
    fin = open_file(os.path.join(doc_dir, doc_html), mode='r')
    if not fin:
        return
    fout = open_file(os.path.join(doc_dir, new_doc), mode='w')
    if not fout:
        fin.close()
        return
    s1 = '"name": "%s.robot"' % lib_name
    s2 = '      <h4>Keywords'
    s3 = '    <h2 id="Keywords">Keywords</h2>'
    for line in fin:
        if s1 in line:
            fout.write(line.replace(s1, '"name": "%s"' % lib_name))
        elif s2 in line:
            fout.write(line.replace(s2, '      <h4>Libraries'))
        elif s3 in line:
            fout.write(line.replace(s3, '    <h2 id="Keywords">Libraries</h2>'))
        else:
            fout.write(line)
    fin.close()
    fout.close()
    if not debug:
        remove_file(os.path.join(doc_dir, doc_html))
    exec_cmd('mv %s %s' % (os.path.join(doc_dir, new_doc), os.path.join(doc_dir, doc_html)))


"""
MAIN of tool
"""

# management of command line
nb_arg = len(sys.argv)
if nb_arg > 2:
    print("usage:  python  %s  [-debug]" % sys.argv[0])
    exit(1)
debug_flag = False
if nb_arg == 2:
    if sys.argv[1] != '-debug':
        print("usage:  python  %s  [-debug]" % sys.argv[0])
        exit(1)
    debug_flag = True

# Path where are located the robot libraries
robot_path = os.path.join(os.getcwd(), '../robot')

# Path where are located the python modules
python_lib_path = os.path.join(os.getcwd(), '../python')

# Path where the documentation is generated
doc_directory = os.path.join(robot_path, 'NPS_SWENG_robot_documentation')

# Creation of the directory where the documentation is generated
create_doc_directory(doc_directory)

# Obtaining the SWENG version
sweng_version = get_sweng_version(os.path.join(os.getcwd(), '../python/Version.py'))

# Filename of file that contains the keyword list
g_kw_list_filename = os.path.join(doc_directory, 'kw_list.txt')

# Creation of object to manage the library list
lib_list = ListLib()

title('GENERATION OF SWENG DOCUMENTATION (version %s)' % sweng_version)

# Translate python libraries in robot libraries for documentation only
for python_lib in list_of_python_libraries:
    source_python_lib = os.path.join(python_lib_path, python_lib)
    target_python_lib = os.path.join(robot_path, python_lib[:-3] + '.robot')
    my_doc_python = LibPythonAsRobotDoc()
    my_doc_python.create_robot_doc_of_lib_python(python_filename=source_python_lib,
                                                 documentation_filename=target_python_lib)

# Copy the text file of SWENG global variables in robot file
copy_sweng_global_var_text_file_in_robot_file(path=robot_path,
                                              txt_file=g_text_file_of_global_var,
                                              robot_file=g_robot_file_of_global_var)

# Generating documentation of each lib
for f in os.listdir(robot_path):
    if os.path.isfile(os.path.join(robot_path, f)) and (f[0:4] != 'DOC_') and (f[-6:] == '.robot') and\
            (f not in list_of_excluded_libraries):
        # title(f)
        robot_reading = ReadRobot(os.path.join(robot_path, f))
        if robot_reading.convert_robot(g_kw_list_filename):
            # info('Successful convert robot file [%s]' % robot_reading.get_robot_name())
            doc_html = 'NPS_AF_robot_doc_%s.html' % robot_reading.get_lib_name()
            lib_list.add_lib(name=robot_reading.get_lib_name(),
                             purpose=robot_reading.get_purpose_string(),
                             filename=robot_reading.get_converted_robot_filename(),
                             doc_html=doc_html)
            if exec_cmd('python -m robot.libdoc --quiet -f HTML -F ROBOT -n %s -v %s -P %s %s %s' %
                        (robot_reading.get_robot_name(),
                         sweng_version,
                         robot_path,
                         robot_reading.get_converted_robot_name(),
                         os.path.join(doc_directory, doc_html))):
                ok('Library %s' % f)
            else:
                error('Library %s : Cannot generate HTML documentation' % f)
        else:
            error('Library %s : Cannot convert robot file' % f)
        if not debug_flag:
            remove_file(robot_reading.get_converted_robot_filename())
# Specific case for python library
for lib in lib_list.get_list():
    if (lib['Name'] + '.py') in list_of_python_libraries:
        modfy_python_lib(doc_dir=doc_directory, doc_html=lib['Doc HTML'], lib_name=lib['Name'], debug=debug_flag)
        if not debug_flag:
            remove_file(os.path.join(robot_path, lib['Name'] + '.robot'))
# Specific case for SWENG global variables documentation
for lib in lib_list.get_list():
    if lib['Name'] == g_libname_of_global_var:
        modfy_global_var_lib(doc_dir=doc_directory, doc_html=lib['Doc HTML'], lib_name=lib['Name'], debug=debug_flag)
        if not debug_flag:
            remove_file(os.path.join(robot_path, g_robot_file_of_global_var))
        break

main_return = 0

# Generating of index file (index.html)
if generating_index(
        doc_dir=doc_directory,
        version=sweng_version,
        title_lib='NPS Test CRT/CIT Automation Framework',
        introduction=["AF team provides a list of robot libraries to be used in test suite.",
                      "You'll find here the detailed interface and how to use those libraries.",
                      "Please refer to best practice described in each library documentation."],
        tool_name='SWENG_generate_documentation.py (' + __version__ + ')',
        exec_date=str(datetime.now()),
        lib_robot_list=lib_list.get_list_sorted()):
    ok('Index file')
else:
    error('Index file : Cannot generate HTML documentation')
    main_return = 1

# Generating of lib_list file
if generating_lib_list(doc_dir=doc_directory, version=sweng_version, lib_robot_list=lib_list.get_list_sorted()):
    ok('Library list file')
else:
    error('Library list file : Cannot generate text file')
    main_return = 1

exit(main_return)
