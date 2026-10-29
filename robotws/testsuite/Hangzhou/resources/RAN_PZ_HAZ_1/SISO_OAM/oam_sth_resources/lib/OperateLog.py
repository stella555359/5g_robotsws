# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Li Amaand
:contact: amaand.li@nokia-sbell.com.cn
"""

import logging
import re
import mmap
import sys
import six


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
        buffer = ""
        chunk_size = 1024*1024
        with open(source_file_path, "r", errors='ignore') as file_obj:
            while True:
                content = file_obj.read(chunk_size)
                if not content:
                    break
                buffer += content
                for keyword in target_msgs:
                    pattern = re.compile(re.escape(keyword), re.DOTALL)
                    search_result = pattern.findall(buffer)
                    if search_result:
                        self._log.debug("Find '%s' in line <%s>" % (keyword, search_result))
                        contain_lines.extend(search_result)
                        try:
                            unfound_msgs.remove(keyword)
                        except ValueError:
                            pass
                # Keep the last part of len(target_msgs), to make sure handle the next chunk, keep the multiline match
                # content. To avoid loss the opportunity to match across lines.
                buffer = buffer[-len(target_msgs):]
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
        print(unfound_msgs, target_msgs)
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
        if isinstance(regexp, six.string_types):
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
            if isinstance(ue_id, bytes):
                ue_id = ue_id.decode('utf-8')
            frame_content = []
            new_file_path = self._src_path.replace('.log', '_%s.log' % ue_id)

            for num in range(len(start_index) - 1):
                if ue_id in self.file_content[start_index[num]]:
                    tmp = self.file_content[start_index[num]:start_index[num + 1]]
                    frame_content.extend(tmp)
            with open(new_file_path, 'a') as fw:
                fw.writelines(frame_content)
