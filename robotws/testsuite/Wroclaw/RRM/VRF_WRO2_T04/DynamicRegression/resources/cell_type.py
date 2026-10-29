import re


class CellType:
    NRCELL_DISTNAME = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'
    BWP_PROFILE_FORMAT = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/BWP_PROFILE-{bwp_id}'

    def __init__(self, cell_setup):
        self.cell_setup = cell_setup

    def _get_cell_id(self):
        return str(self.cell_setup['globalCellId'])

    def _get_cell_band(self):
        return self.cell_setup['band']

    @property
    def cell_id(self):
        return self._get_cell_id()

    @property
    def technology(self):
        return self.cell_setup['technology']

    @property
    def bwp_distname(self):
        return self.BWP_PROFILE_FORMAT

    @staticmethod
    def distname_format():
        raise NotImplementedError

    @property
    def band(self):
        return self._get_cell_band()

    @property
    def chbw(self):
        raise NotImplementedError

    @property
    def rmod_id(self):
        return self.cell_setup['carrierList'][0]['antennaLineId']['internal'].split('/')[-2]

    def __str__(self):
        return self.cell_id

    def __lt__(self, other):
        return self.cell_id < other.cell_id

    def __iter__(self):
        return self

    def __repr__(self):
        return f'{self.technology} CELL: {self.cell_id}'


class FddCell(CellType):
    def __init__(self, cell_setup):
        super().__init__(cell_setup)

    @staticmethod
    def distname_format():
        return 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}/NRCELL_FDD-1'

    @property
    def chbw(self):
        bandwidth = self.cell_setup['chBwDl']
        return re.match(r"\d+", bandwidth).group(0)


class TddCell(CellType):
    def __init__(self, cell_setup):
        super().__init__(cell_setup)

    @staticmethod
    def distname_format():
        return 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'

    @property
    def chbw(self):
        bandwidth = self.cell_setup['chBw']
        return re.match(r"\d+", bandwidth).group(0)
