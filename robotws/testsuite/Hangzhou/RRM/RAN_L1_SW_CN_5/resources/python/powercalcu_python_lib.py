# -*- coding:utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lei Jia
:contact: lei.jia@nokia-sbell.com
:maintainer: Lei Jia
:contact: lei.jia@nokia-sbell.com
"""
import math


def get_maxRe(chbw, rballocation):
    """
    :param chbw is channel bandwidth with PRB, rballocation is rbAllocation
    nbREMimo =CEILING(chbw/4,1)*4*2
    nbRETracking =CEILING(rballocation/4,1)*4*3
    maxRe =MAX(nbRESSB, nbREMimo, nbRETracking)
    :return: maxRe
    """
    nbRESSB = 240
    nbREMimo = math.ceil(float(chbw) / 4) * 4 * 2
    nbRETracking = math.ceil(float(rballocation) / 4) * 4 * 3
    return int(max(nbRESSB, nbREMimo, nbRETracking))


def get_power_control_offset_from_org(para):
    """
    :param para is powerControlOffset_org
    :return: IF(OR(B21<-8, B21>15), IF(B21<-8, -8, 15), B21)
    """
    para = int(para)
    if para < -8:
        para = -8
    if para > 15:
        para = 15

    return para


def get_ssb_power_calculation(**kwargs):
    """
    :param kwargs: A dict to receive B25, B3, B6, B4, B36, B7 values
    B25 = maxRe, B3 = RU Beamforming Type, B6 = NIDD: pMax(dBm/TRX)
    B4 = DBF RU specific: numOfTrx/numOfPolarization
    B36 = MU-MIMO offset, B7 = NIDD: ssPbchBlockPower(dBm/EPRE)
    maxSSBlockPower = FLOOR(-10*LOG10(B25),1)
    powerBudgetPerPolar(dBm) = =IF(B3="DBF",FLOOR(B6+10*LOG10(B4),1)+B36,B6)
    ssBlockPowerFromNidd (dB) = B7 - powerBudgetPerPolar(dBm)
    :return:
    """
    paras = PowerParasPre(**kwargs)
    maxSSBlockPower = math.floor(-10 * math.log(paras["maxRe"], 10))
    if paras["ruBeamformingType"] == "DBF":
        powerBudgetPerBeam = (
            math.floor(paras["pmax"] + 10 * math.log(paras["numofTRX"], 10))
            + paras["mumimoOffset"]
        )
    else:
        powerBudgetPerBeam = paras["pmax"]
    ssblockpowerfromnidd = paras["sspbchBlcokPower"] - powerBudgetPerBeam
    ssBlockPower = min(maxSSBlockPower, ssblockpowerfromnidd) * 10
    max_ssPbchBlockPower = maxSSBlockPower + powerBudgetPerBeam
    return (
        maxSSBlockPower,
        powerBudgetPerBeam,
        ssblockpowerfromnidd,
        ssBlockPower,
        max_ssPbchBlockPower,
    )


def get_dl_trans_power(para1, para2):
    """
    :param list: para1 is channel bandwidth with PRB, para2 is dlQam256PowerBackoff(if 256QAM enabled)
    :return:
    """
    para = (-10 * math.log(para1 * 12, 10) - para2) * 10
    return round(para, 0)


def get_power_control_offset(*paras):
    """
    :param paras[0] is actDl256Qam, paras[1] is dl256qam_power_backoff
     paras[2] is powerBudgetPerBeam, paras[3] is Channel bandwidth with PRB, paras[4] is sspbch_blcok_power
    :return: ROUND(E3-10*LOG10(B4*12)-B22,0)
    """
    if paras[0] == "true":
        dlQam256PowerBackoff_result = paras[1]
    else:
        dlQam256PowerBackoff_result = 0
    pdsch = round(
        (paras[2] - 10 * math.log((paras[3] * 12), 10) - dlQam256PowerBackoff_result), 0
    )
    powerControlOffset_org = pdsch - paras[4]
    powerControlOffset = get_power_control_offset_from_org(powerControlOffset_org)
    return powerControlOffset


def get_pdschPowerOffset(**kwargs):
    """
    :param kwargs: A dict to receive B3, B12, B16, B19. values
    B3 = "RU Beamforming Type", B12 = "NIDD: 4*4/4*2MIMO Enabled"
    B16 = "L2: rdPdschPrecodingOption4X4(Default 2) 605-T"
    B19 = "DL Scheduled Rank( run time value)"
    pdschPowerOffset =IF(AND($B$3="DBF",$B$12=TRUE,OR(B16=0, $B$19>2)),-3,0)
    :return: pdschPowerOffset
    """
    paras = PowerParasPre(**kwargs)
    if (
        paras["ruBeamformingType"] == "DBF"
        and paras["MIMO4X4Enabled"]
        and (paras["rdPdschPrecodingOption4X4"] == 0 or paras["dlScheduledRank"] > 2)
    ):
        pdschPowerOffset = -3
    else:
        pdschPowerOffset = 0
    return int(pdschPowerOffset * 10)


def get_pdcchPowerOffset(**kwargs):
    """
    :param kwargs: A dict to receive B3, B12, B16, B19 values
    B3 = "RU Beamforming Type", B12 = "NIDD: 4*4/4*2MIMO Enabled"
    B15 = "L2: rdPdcchPrecodingOption4X4(Default 2) 605-L"
    pdcchPowerOffset =IF(AND($B$3="DBF",$B$12=TRUE,$B$15<2),-3,0)
    :return: pdcchPowerOffset
    """
    paras = PowerParasPre(**kwargs)
    if (
        paras["ruBeamformingType"] == "DBF"
        and paras["MIMO4X4Enabled"]
        and paras["rdPdcchPrecodingOption4X4"] < 2
    ):
        pdcchPowerOffset = -3
    else:
        pdcchPowerOffset = 0
    return int(pdcchPowerOffset * 10)


def get_csirsTrackingPowerControlOffsetSS(**kwargs):
    """
    :param kwargs: A dict to receive B13, B3, B9, B25, B12, B7 values
    B13 = "NIDD: numberOfTransmittedSsBlocks"
    B3 = "RU Beamforming Type", B9 = "NIDD: CSI-RS for tracking:rbAllocation"
    B25 = "maxRe", B7 = "NIDD: ssPbchBlockPower(dBm/EPRE)"
    B12 = "NIDD: 4*4/4*2MIMO Enabled"
    csirsTrackingPowerControlOffsetSS =IF(AND(B13>1,B3="DBF",CEILING(B9/4,1)*4*6>B25,\
    ROUNDDOWN(B7+10*LOG10(CEILING(B9/4,1)*4*6)-10*LOG10(B25),0)>E5),-3,(IF(AND(B3="NONE",B12=TRUE,B2="19A"),6,0)))
    :return: csirsTrackingPowerControlOffsetSS
    """
    paras = PowerParasPre(**kwargs)
    condition1 = math.ceil(float(paras["rballocation"]) / 4) * 4 * 6
    condition2 = math.floor(
        paras["sspbchBlcokPower"]
        + 10 * math.log(condition1, 10)
        - 10 * math.log(paras["maxRe"], 10)
    )
    if (
        paras["numberOfTransmittedSsBlocks"] > 1
        and paras["ruBeamformingType"] == "DBF"
        and condition1 > paras["maxRe"]
        and condition2 > paras["maxssPbchBlockPower"]
    ):
        csirsTrackingPowerControlOffsetSS = -3
    else:
        csirsTrackingPowerControlOffsetSS = 0
    return int(csirsTrackingPowerControlOffsetSS * 10)


def get_csiPowerOffset(**kwargs):
    """
    :param kwargs: A dict to receive B3, B12 values.
    B3 = "RU Beamforming Type", B12 = "NIDD: 4*4/4*2MIMO Enabled"
    csiPowerOffset =IF(AND($B$3="DBF",$B$12=TRUE),-3,0)
    :return: csiPowerOffset
    """
    paras = PowerParasPre(**kwargs)
    if paras["ruBeamformingType"] == "DBF" and paras["MIMO4X4Enabled"]:
        csiPowerOffset = -3
    else:
        csiPowerOffset = 0
    return int(csiPowerOffset * 10)


def PowerParasPre(**kwargs):
    """
    :param kwargs: A dict to receive power calculation parameters.
    :return: A dict with received values.
    """
    dict_power_paras = dict(
        chbw=None,
        rballocation=None,
        sspbchBlcokPower=None,
        maxRe=None,
        numofTRX=None,
        pmax=None,
        ruBeamformingType=None,
        mumimoOffset=None,
        powerBudgetPerBeam=None,
        rdPdschPrecodingOption4X4=None,
        dlScheduledRank=None,
        rdPdcchPrecodingOption4X4=None,
        numberOfTransmittedSsBlocks=None,
        maxssPbchBlockPower=None,
        dlQam256PowerBackoff=None,
        actDl256Qam=None,
        MIMO4X4Enabled=None,
    )
    dict_power_paras.update(kwargs)
    return dict_power_paras
