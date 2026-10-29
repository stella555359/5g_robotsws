import re
from robot.api import logger

mcs_table_mapping = {
    '0': '64QAM',
    '1': '256QAM'
}


class Frame:
    def __init__(self, frame):
        self.frame_str = "".join(frame)
        self.mcs = self.get_mcs(self.frame_str)
        self.mcs_table = self.get_mcs_table_num(self.frame_str)
        self.rnti = self.get_mcs_c_rnti(self.frame_str)

    def __str__(self):
        return 'McsFrame, mcs: {}, mcs_table: {}, rnti: {}'.format(self.mcs, self.mcs_table, self.rnti)

    @staticmethod
    def get_mcs(frame):
        try:
            mcs_hex = re.findall(r"mcs.*?\:\s([0-9]+)", frame)[0]
            mcs = int(mcs_hex, 0)
        except IndexError:
            mcs = None
        return mcs

    @staticmethod
    def get_mcs_table_num(frame):
        """
        Returns MCS table string: '64QAM' or '256QAM'
        """
        try:
            mcs_table_num = re.findall(r"mcsTable.*:\s+.*QAM\s+\((\d)\)", frame)[0]
            mcs_table = mcs_table_mapping[mcs_table_num]
        except IndexError:
            mcs_table = None
        return mcs_table

    @staticmethod
    def get_mcs_c_rnti(frame):
        try:
            rnti_hex = re.findall(r"rnti.*?:\s([0-9]+)", frame)[0]
            rnti = int(rnti_hex, 0)
        except IndexError:
            rnti = None
        return rnti


class PuschFrame(Frame):
    def __init__(self, frame):
        super().__init__(frame)


class PdschFrame(Frame):
    def __init__(self, frame):
        super().__init__(frame)
        self.scrambling_int = self.get_scrambling(self.frame_str)

    @staticmethod
    def get_scrambling(frame):
        return int(re.findall(r"dmrsScramblingSequenceInt.*?:\s+(\d+)\s+", frame)[0])
