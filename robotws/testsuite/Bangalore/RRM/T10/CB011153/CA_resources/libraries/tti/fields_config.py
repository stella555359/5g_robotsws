# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
# >>> COMMON <<<
TIME = 'Time'
DRX_BIT_MASK = 'ETtiTraceDlParUe_drxTimersControl'

# >>> UL <<<
UL_CRNTI = 'ETtiTraceUlParUe_cRnti'
UL_THROUGHPUT = ['EHarqParUl_dataRcvdLcg3']
UL_ULLA = 'ETtiTraceUlParUe_ullaItem1'
UL_DELTAC = 'ETtiTraceUlParUe_rrmDeltaC'
UL_HARQ_NACK = ['EHarqParUl_ackNackDtxCw1']
UL_IS_CATM_UE = 'ETtiTraceUlParUe_isCatMUe'
UL_TRANS_MODE = 'ETtiTraceUlParUe_transmMode'

# >>> DL <<<
DL_CRNTI = 'ETtiTraceDlParUe_cRnti'
DL_THROUGHPUT = ['ETtiTraceDlParUe_dataTakenDrb1', 'ETtiTraceDlParUe_dataTakenDrb2']
DL_MIMO = 'ETtiTraceDlParUe_mimoMode'
DL_DYNAMIC_MIMO = 'ETtiTraceDlParUe_dynamicMimoMode'
DL_MIMO_CQI = 'ETtiTraceDlParUe_rrmMimoCqi'
DL_DELTA_CQI = 'ETtiTraceDlParUe_rrmDeltaCqi'
DL_CQI_SHIFT = 'ETtiTraceDlParUe_rrmPdcchCqiShift'
DL_MIMO_RI = 'ETtiTraceDlParUe_rrmMimoRi'
DL_AMBR = 'ETtiTraceDlParUe_rrmAmbrSchedDl'
DL_OFDM = 'ETtiTraceDlParCell_totalOFDMsymbols'
DL_HARQ_NACK = ['EHarqParDl_ackNackDtxCw1', 'EHarqParDl_ackNackDtxCw2']
DL_TRS_MODE = 'ETtiTraceDlParUe_transmMode'
DL_IS_CATM_UE = 'ETtiTraceDlParUe_isCatMUe'
DL_TRANS_MODE = 'ETtiTraceDlParUe_transmMode'
