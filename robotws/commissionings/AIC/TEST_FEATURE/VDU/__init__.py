# -*- coding: utf-8 -*-

__maintainer__ = 'Jinbo Yu'
__team__ = 'VDU AIC CI'
__email__ = 'jinbo.yu@nokia-sbell.com'


from cloud5g.commissioning import CustomCommissioningBase


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        pass
