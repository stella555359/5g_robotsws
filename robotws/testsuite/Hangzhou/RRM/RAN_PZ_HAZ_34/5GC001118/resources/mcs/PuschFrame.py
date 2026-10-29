import re


mcs_table_mapping = {
    '0': '64QAM',
    '1': '256QAM'
}


class PuschFrame():
    def __init__(self, frame):
        frame = "".join(frame)
        self.mcs = self.get_mcs(frame)
        self.mcs_table = self.get_mcs_table_num(frame)
        self.rnti = self.get_mcs_c_rnti(frame)

    def __str__(self):
        return 'McsFrame, mcs: {}, mcs_table: {}, rnti: {}'.format(self.mcs, self.mcs_table, self.rnti)

    @staticmethod
    def get_mcs(frame):
        try:
            # mcs_hex = re.findall(r"mcs.*?(0x[A-Fa-f0-9]+)", frame)[0]
            mcs_hex = re.findall(r"mcs.*?:\s*(\d+)", frame)[0]
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
            # mcs_table_num = re.findall(r"mcsTable.*?(\d)", frame)[0]
            mcs_table = re.findall(r"mcsTable.*?max(\d+QAM)", frame)[0]
            # mcs_table = mcs_table_mapping[mcs_table_num]
        except IndexError:
            mcs_table = None
        return mcs_table

    @staticmethod
    def get_mcs_c_rnti(frame):
        try:
            # rnti_hex = re.findall(r"rnti.*?(0x[A-Fa-f0-9]+)", frame)[0]
            rnti_hex = re.findall(r"rnti.*?:\s*(\d+)", frame)[0]
            rnti = int(rnti_hex, 0)
        except IndexError:
            rnti = None
        return rnti
