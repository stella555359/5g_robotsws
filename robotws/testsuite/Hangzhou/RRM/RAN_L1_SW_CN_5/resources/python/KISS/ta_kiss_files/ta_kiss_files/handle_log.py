# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import logging
import re
import mmap
import os
import glob
import io
import sys
from .exception import KissFileException


class OperateLog(object):
    """find and modify value in .txt file
    """
    def __init__(self):
        """src_file: the log file you want parser
        """
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        try:
            reload(sys)
            sys.setdefaultencoding('utf8')
        except Exception as err:
            pass

    def _check_msg_in_file(self, source_file_path, target_msgs):
        contain_lines = []

        if not isinstance(target_msgs, list):
            target_msgs = [target_msgs]

        unfound_msgs = [msg for msg in target_msgs]
        with io.open(source_file_path, "r", errors='ignore') as file_obj:
            for line in file_obj:
                for keyword in target_msgs:
                    search_result = re.search(keyword, line)
                    if search_result:
                        self._log.debug("Find '%s' in line <%s>" % (keyword, line))
                        contain_lines.append(line)
                        try:
                            unfound_msgs.remove(keyword)
                        except ValueError:
                            pass
        return unfound_msgs, target_msgs, contain_lines

    def file_should_contain(self, source_file_path, target_msgs):
        """This keyword checks whether file contains specified messages.
        :param source_file_path: Source file path
        :param target_msgs: type as list or string
        :return: lines which contain given messages
        """

        unfound_msgs, target_msgs, contain_lines = self._check_msg_in_file(
            source_file_path, target_msgs)

        if len(unfound_msgs) != 0:  # some messages was not found
            self._log.info('*HTML*<a href = "%s">fail log</a>' % source_file_path)
            raise Exception(
                "Not find '%s' in '%s'" %
                (unfound_msgs, source_file_path))

        return contain_lines

    def file_should_not_contain(self, source_file_path, target_msgs):
        """This keyword checks file does not contain specified messages.
        :param source_file_path: Source file path
        :param target_msgs: type as list or string
        """

        unfound_msgs, target_msgs, _ = self._check_msg_in_file(
            source_file_path, target_msgs)
        self._log.info(unfound_msgs, target_msgs)
        if len(unfound_msgs) != len(target_msgs):  # some messages was found
            self._log.info('*HTML*<a href = "%s">fail log</a>' % source_file_path)
            raise Exception(
                "Find '%s' in '%s'" %
                (list(
                    set(target_msgs).difference(
                        set(unfound_msgs))),
                    source_file_path))

    def file_match_all(self, source_file_path, regexp):
        """This keyword return all matched regexp list
        :param source_file_path: Source file path
        :param regexp: match regexp
        :return: matched list, [] if match nothing.
        """
        if type(regexp) is str:
            regexp = regexp.encode('utf-8')

        with open(source_file_path, 'r+') as self._file_obj:
            data = mmap.mmap(self._file_obj.fileno(), 0)
            result = re.findall(regexp, data)
            return result

    def split_iphy_log_by_ueid(self, src_file):
        """split iphy log by ueid
        :param src_file: Source file path
        """
        self._src_path = src_file
        with open(src_file, 'r+') as self._file_obj:
            self.file_content = self._file_obj.readlines()

        ue_id_list = self.file_match_all(
            self._src_path, r'\d{2}:\d{2}:\d{2}.\d{3}.*\s(UE\d+).*\[')
        ue_id_list = set(ue_id_list)

        start_index = []
        for line in range(len(self.file_content)):
            if re.match(r'^\d{2}:\d{2}:\d{2}.\d{3}', self.file_content[line]):
                start_index.append(line)

        start_index.append(len(self.file_content))
        for ue_id in ue_id_list:
            if type(ue_id) is bytes:
                ue_id = ue_id.decode('utf-8')
            frame_content = []
            new_file_path = self._src_path.replace('.log', '_%s.log' % ue_id)

            for num in range(len(start_index) - 1):
                if ue_id in self.file_content[start_index[num]]:
                    frame_content.extend(self.file_content[
                                    start_index[num]:start_index[num + 1]])
            with open(new_file_path, 'a') as fw:
                fw.writelines(frame_content)

    def _check_msg_in_targz_file(self, source_files_path, target_msgs):
        file_path = []
        if not os.path.exists(source_files_path):
            for files in glob.glob(source_files_path):
                file_path.append(files)
        else:
            file_path.append(source_files_path)

        contain_lines = []

        if not isinstance(target_msgs, list):
            target_msgs = [target_msgs]

        unfound_msgs = [msg for msg in target_msgs]
        import fileinput
        f = fileinput.input(file_path, openhook=fileinput.hook_compressed)
        for line in f:
            if f.isfirstline():
                rows, columns = os.popen('stty size', 'r').read().split()  # get windows width
                width_length = int(((int(columns) - len(f.filename().split('/')[-1])) / 2))
                filename = '=' * width_length + f.filename().split('/')[-1] + '=' * width_length + '\n'
                contain_lines.append(filename)
            for keyword in target_msgs:
                if re.search(keyword, line):
                    self._log.debug("Find '%s' in line <%s>" % (keyword, line))
                    contain_lines.append(line.decode('utf-8'))
                    try:
                        unfound_msgs.remove(keyword)
                    except ValueError:
                        pass
        f.close()
        return unfound_msgs, target_msgs, contain_lines

    def targz_file_should_contain(self, source_file_path, target_msgs):
        """This keyword checks whether targz file contains specified messages.
        :param source_file_path: Source file path
        :param target_msgs: type as list or string
        :return: lines which contain given messages
        """

        unfound_msgs, target_msgs, contain_lines = self._check_msg_in_targz_file(
            source_file_path, target_msgs)
        if len(unfound_msgs) != 0:  # some messages was not found
            self._log.info('*HTML*<a href = "%s">fail log</a>' % source_file_path)
            raise Exception(
                "Not find '%s' in '%s'" %
                (unfound_msgs, source_file_path))

        return contain_lines

    def targz_file_should_not_contain(self, source_file_path, target_msgs):
        """This keyword checks targz file does not contain specified messages.
        :param source_file_path: Source file path
        :param target_msgs: type as list or string
        """

        unfound_msgs, target_msgs, _ = self._check_msg_in_targz_file(
            source_file_path, target_msgs)
        if len(unfound_msgs) != len(target_msgs):  # some messages was found
            self._log.info('*HTML*<a href = "%s">fail log</a>' % source_file_path)
            raise Exception(
                "Find '%s' in '%s'" %
                (list(
                    set(target_msgs).difference(
                        set(unfound_msgs))),
                    source_file_path))

    def _parse_title(self, log_path, key_info):
        with io.open(log_path, 'r', errors='ignore') as fw:
            content = fw.readlines()
        rough = ('\n'.join(content)).split('\n\n\n')
        title = []
        for tmp in rough:
            if key_info in tmp:
                valid = tmp.split('--------\n')[-2].split('\n')
                for v in valid:
                    if '|' in v:
                        title.append(v)
                break
        import copy
        pos_title = title[-1].strip().strip('|').split('|')
        source_title = copy.copy(pos_title)
        pos = 0
        index = -2
        test = [f.strip().lower() for f in pos_title]
        while len(source_title) != len(set(test)) and abs(index) <= len(title):
            for p in range(len(source_title)):
                pstart = pos
                pstop = pos+len(source_title[p])

                last = title[index].strip().strip('|')[pstart:pstop].strip()
                if last:
                    pos_title[p] = last + '_' + pos_title[p].strip()
                else:
                    pos_title[p] = pos_title[p].strip()
                pos = pstop + 1
            index += -1
            test = [f.strip().lower() for f in pos_title]
            pos = 0
        return pos_title

    def filter_qcat_report(self, log_path, key_info, new_file_path):
        ret = self.file_should_contain(log_path, key_info)
        title = self._parse_title(log_path, key_info)
        content = [','.join(title) + '\n']

        for i in range(len(ret)):
            new = [i.strip() for i in ret[i].strip().strip('|').split('|')]
            content.append(','.join(new)+'\n')
        with open(new_file_path, 'w+') as fw:
            fw.writelines(content)

    def filter_qcat_record(self, log_path, key_info, new_file_path):
        with io.open(log_path, 'r', errors='ignore') as fw:
            content = fw.readlines()
        rough = (''.join(content)).split('\n\n\n')
        w_content = []
        for tmp in rough:
            if key_info in tmp:
                for valid in tmp.split('--------\n')[-1].splitlines():
                    if not valid:
                        continue
                    new = [i.strip() for i in valid.strip().strip('|').split('|')]
                    w_content.append(','.join(new)+'\n')
        title = self._parse_title(log_path, key_info)

        with open(new_file_path, 'w') as fw:
            fw.write(','.join(title)+'\n')
            fw.writelines(w_content)

    def filter_qcat_message(self, log_path, key_info, new_file_path):
        with io.open(log_path, 'r', errors='ignore') as fw:
            content = fw.readlines()
        rough = (''.join(content)).split('\n\n')
        w_content = []
        time = '00:00:00:00.000 time'
        for i in range(len(rough)):
            if key_info in rough[i]:
                try:
                    time = re.search('(\\d+:\\d+:\\d+.\\d+)', rough[i-2]).group(1)
                except Exception as _err:
                    time = time
                info = rough[i].split('Interpreted PDU:')
                w_content.append('\n' + time + ' time\n' + info[-1])
        with open(new_file_path, 'w') as fw:
            fw.writelines(w_content)


if __name__ == '__main__':
    a = OperateLog()
    # a.targz_file_should_contain("/home/ute/logs/testabc.log.tar.gz", 'ERR/.*')
    # a.targz_file_should_not_contain("/home/ute/logs/testabcc*.tar.gz", 'ERR/.*')
    pass
