class FdSchedDataProcessor(object):
    def __init__(self, message, direction='ul'):
        direction = direction.lower()
        self.message = message
        self.rank = message['numOfLayers']
        self.ptrs = message['ptrsFlagUlProposedMcs'] if direction == 'ul' else message['ptrsFlagDlProposedMcs']
        self.sinr = message['reScaledCorrAvgSinrAtb'] if direction == 'ul' else message['rrmCorrAvgCqi']
        self.sinr = float(self.sinr)
        self.is_valid = message['isValidWhatIsProposed']
        self.used_mcs = message['rrmUlUsedMcs'] if direction == 'ul' else message['rrmDlUsedMcs']
        self.proposed_mcs = message['rrmUlProposedMcs'] if direction == 'ul' else message['rrmDlProposedMcs']
        self.derived_mcs = message['sinrDerivedMcs'] if direction == 'ul' else message['cqiDerivedMcs']


class UlFdSchedData(FdSchedDataProcessor):
    def __init__(self, message):
        super(UlFdSchedData, self).__init__(message, direction='ul')


class DlFdSchedData(FdSchedDataProcessor):
    def __init__(self, message):
        super(DlFdSchedData, self).__init__(message, direction='dl')
