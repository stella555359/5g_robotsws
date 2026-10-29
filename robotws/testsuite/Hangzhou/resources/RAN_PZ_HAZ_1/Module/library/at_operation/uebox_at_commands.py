# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Winnie.He
:contact: Winnie.He@nokia-sbell.com
:maintainer Winnie.He:
:contact Winnie.He@nokia-sbell.com
"""


# =======func=======
# AT+CFUN=<fun>[,<rst>]
# <fun> =0 least function, =1 most function,=4 Airplane, =5 Fast test mode, =6 Reset,7 Offline mode
# <rst> default is 0


class AtCommand_SetFunc():
    __Base_Set_Func_Str = 'AT+CFUN'
    # if disable_ue_most_func() + rst(),will effective affter reboot
    # if disable_ue_most_func(),will effective immediatly

    def rst(self):
        return '1'

    def disable_ue_most_func(self):
        return self.__Base_Set_Func_Str + '=0'

    def enable_ue_most_func(self):
        return self.__Base_Set_Func_Str + '=1'

    def enable_ue_airplane(self):
        return self.__Base_Set_Func_Str + '=4'

    def ue_fastmode(self):
        return self.__Base_Set_Func_Str + '=5'

    def ue_reset(self):
        return self.__Base_Set_Func_Str + '=1,1'

    def ue_offline(self):
        return self.__Base_Set_Func_Str + '=7'

    def ue_net_register_check(self):
        return "AT+COPS?"


# =======clock=======
class AtCommand_Clock():
    def set_clock(self, timestr):
        return 'AT+CCLK=' + timestr  # add time str  "20/02/21,14:27:46"

    def check_clock(self):
        return 'AT+CCLK?'


# =======Search Net=======
# AT+TCFG="nwscanmode"[,<scanmode>[,<effect>]]
# effect 0 重启生效 1 立即生效
class AtCommand_SearchNet():
    __Base_Search_Str = 'AT+TCFG="nwscanmode"'
    Effect_Reboot = "0"
    Effect_Immediate = "1"
    SEARCH_NET_AUTO = '0'
    SEARCH_2G_ONLY = '1'
    SEARCH_3G_ONLY = '2'
    SEARCH_4G_ONLY = '3'
    SEARCH_5G_ONLY = '4'

    def check_search_net_mode(self):
        return self.__Base_Search_Str

    def search_auto(self):
        return ','.join([self.__Base_Search_Str, AtCommands.SEARCH_NET_AUTO])

    def search_2g_only(self):
        return ','.join([self.__Base_Search_Str, AtCommands.SEARCH_2G_ONLY])

    def search_3g_only(self):
        return ','.join([self.__Base_Search_Str, AtCommands.SEARCH_3G_ONLY])

    def search_4g_only(self):
        return ','.join([self.__Base_Search_Str, AtCommands.SEARCH_4G_ONLY])

    def search_5g_only(self):
        return ','.join([self.__Base_Search_Str, AtCommands.SEARCH_5G_ONLY])


# =======Set Band=======
class _Band_Base():
    def __init__(self, maxband):
        self.maxband = maxband
        self.bandgroup = int(self.maxband/64)

    def __convert_one_band_to_at_command_param(self, band):
        band_param = 0x01
        for i in range(self.bandgroup):
            if (band > 0 + i*64) and (band < (64*(i+1)+1)):
                band_param = band_param << (band - 1 - 64*i)
                break
        return band_param

    def _convert_bandlist_to_at_command_param(self, bandlist):
        bandlist_list = []  # each 64 band as a list
        for i in range(self.bandgroup):
            bandlist_list.append([self.__convert_one_band_to_at_command_param(int(band))
                                 for band in bandlist if int(band) < (64*(i+1)+1) and int(band) > (64*i)])
        bandlist_str = []
        for bandlist in bandlist_list:
            bandlist_str.append(str(hex(sum(bandlist))).replace("0x", "").replace("L", ""))
        return bandlist_str


# =======LTE Band=======
class AtCommand_LTE_band(_Band_Base):
    Base_LTE_Band_Str = "AT+TCFG=\"band\""
    MAX_LTE_BAND = 128

    # AT+TCFG="band"[,<lteband1>,<lteband2>[,<effect>]]
    # lteband1: band 1 ... band 64,each bit means one band,like: band1: 0x1, band3:0x4, band4:0x8
    # lteband2: band 65 ... band 128,each bit means one band,like: band65: 0x1, band67:0x4, band68:0x8
    # if need band 2,3,65 then AT+TCFG="band",6,1  ,6 means 2+4
    def __init__(self):
        _Band_Base.__init__(self, self.MAX_LTE_BAND)

    def check_LTE_Band(self):
        return self.Base_LTE_Band_Str

    def set_band(self, bandlist):
        bandstrlist = self._convert_bandlist_to_at_command_param(bandlist)
        return ",".join([self.Base_LTE_Band_Str] + bandstrlist)


# =======5G Band=======
class AtCommand_5G_SA_band(_Band_Base):
    Base_5G_SA_Band_Str = "AT+TCFG=\"saband\""
    MAX_5G_SA_BAND = 512

    def __init__(self):
        _Band_Base.__init__(self, self.MAX_5G_SA_BAND)

    def check_LTE_Band(self):
        return self.Base_5G_SA_Band_Str

    # AT+TCFG="band"[,<lteband1>,<lteband2>[,<effect>]]
    # lteband1: band 1 ... band 64,each bit means one band,like: band1: 0x1, band3:0x4, band4:0x8
    # lteband2: band 65 ... band 128,each bit means one band,like: band65: 0x1, band67:0x4, band68:0x8
    # if need band 2,3,65 then AT+TCFG="band",6,1  ,6 means 2+4
    def set_band(self, bandlist):
        bandstrlist = self._convert_bandlist_to_at_command_param(bandlist)
        return ",".join([self.Base_5G_SA_Band_Str] + bandstrlist)


class AtCommand_5G_NSA_band(_Band_Base):
    Base_5G_NSA_Band_Str = "AT+TCFG=\"nsaband\""
    MAX_5G_NSA_BAND = 512

    def __init__(self):
        _Band_Base.__init__(self, self.MAX_5G_NSA_BAND)

    # AT+TCFG="band"[,<lteband1>,<lteband2>[,<effect>]]
    # lteband1: band 1 ... band 64,each bit means one band,like: band1: 0x1, band3:0x4, band4:0x8
    # lteband2: band 65 ... band 128,each bit means one band,like: band65: 0x1, band67:0x4, band68:0x8
    # if need band 2,3,65 then AT+TCFG="band",6,1  ,6 means 2+4

    def check_LTE_Band(self):
        return self.MAX_5G_NSA_BAND

    def set_band(self, bandlist):
        bandstrlist = self._convert_bandlist_to_at_command_param(bandlist)
        return ",".join([self.Base_5G_NSA_Band_Str] + bandstrlist)


# =======SIM card=======
class AtCommand_SIM_Card():
    Check_IMSI = 'AT+CIMI'

    def check_SIM_status(self):
        # return value : +SIMSTAT: <enable>,<inserted status>
        # <enable> SIM auto report status 1: open, 0: default value, close
        # <inserted status> 0: sim remove, 1 sim insert, 2 unknow
        return "AT+SIMSTAT?"

    def check_IMSI(self):
        return self.Check_IMSI


# =======Net service=======
class AtCommand_Net_Service_Fibocom():
    # return value :+CREG: <n>,<stat>[,<lac>,<ci>,<Act>]
    # <stat> 0: not registered
    #       1: already registered
    #       2：not registered but ongoing
    #       3: had registered but be rejected
    #       4：unknow
    #       5: has registed,roaming
    # <lac>  location area code (0x)
    # <ci> 28 bit cell id (0x)
    # <Act>
    #       7:E-UTRAN
    #       10:E-UTRAN connected to a 5GCN
    #       11:NR connected to 5GCN
    #       12:NG-RAN
    #       13:E-UTRAN-NR dual connectivity
    Net_ENDC = 'E-UTRAN-NR dual connectivity'
    Net_4G_Only = "E-UTRAN"
    Net_5G_Only = "NR connected to 5GCN"
    Check_Net_Service = "AT+CREG?"
    Close_SA_Net_Service = "AT+GTSET=\"5GSACTR\",0"
    Open_SA_Net_Service = "AT+GTSET=\"5GSACTR\",1"
    SA_Net_Service = "AT+GTACT=14"  # NR-RAN,SA Mode
    ENDC_Net_Service = "AT+GTACT=17"  # NR-RAN/LTE
    SA_First_Net_Service = "AT+GTACT=10"  # Auto mode,SA first
    SERVING_CELL = "AT+GTCCINFO?"

    def set_net_service(self, n):
        # n 0: default,disable
        #  1: enable
        #  2: enable, and get location infomation
        return "AT+CREG="+n

    def check_registered_net_information(self):
        # +TNWINFO: <Act>,<oper><band>,<channel>
        # <Act> current net
        # <oper> plmn id
        # <band> 'NR5G BAND n1' – 'NR5G BAND n260',"LTE BAND 1" … "LTE BAND 43"
        return "AT+TNWINFO"


class AtCommand_Net_Service_Quectel():
    # return value :+CREG: <n>,<stat>[,<lac>,<ci>,<Act>]
    # <stat> 0: not registered
    #       1: already registered
    #       2：not registered but ongoing
    #       3: had registered but be rejected
    #       4：unknow
    #       5: has registed,roaming
    # <lac>  location area code (0x)
    # <ci> 28 bit cell id (0x)
    # <Act>
    #       7:E-UTRAN
    #       10:E-UTRAN connected to a 5GCN
    #       11:NR connected to 5GCN
    #       12:NG-RAN
    #       13:E-UTRAN-NR dual connectivity
    Net_ENDC = 'E-UTRAN-NR dual connectivity'
    Net_4G_Only = "E-UTRAN"
    Net_5G_Only = "NR connected to 5GCN"
    Check_Net_Service = "AT+CREG?"
    Close_SA_Net_Service = "AT+QNWPREFCFG=\"nr5g_disable_mode\",1"
    Open_SA_Net_Service = "AT+QNWPREFCFG=\"nr5g_disable_mode\",2"
    SERVING_CELL = "AT+QENG=\"servingcell\""

    def set_net_service(self, n):
        # n 0: default,disable
        #  1: enable
        #  2: enable, and get location infomation
        return "AT+CREG=" + n

    def check_registered_net_information(self):
        # +TNWINFO: <Act>,<oper><band>,<channel>
        # <Act> current net
        # <oper> plmn id
        # <band> 'NR5G BAND n1' – 'NR5G BAND n260',"LTE BAND 1" … "LTE BAND 43"
        return "AT+TNWINFO"


class AtCommand_cell():

    def check_service_cell(self):
        # return value:
        # SA mode: +TENG:"servingcell",<state>,"NR5G",<PLMN>,<cellid>,<pcid>,<earfcn>,<f
        #         req_band_ind>,<dl_bandwidth>,<tac>,<rsrp>,<rsrq>,<sinr>
        # ENDC mode: +TENG:"servingcell",<state>,"LTE-NR"
        #            +TENG:"LTE",<is_tdd>,<mcc>,<mnc>,<cellid>,<pcid>,<earfcn>,<freq_band
        #                   _ind>,<dl_bandwidth>,<ul_bandwidth>,<tac>,<rsrp>,<rsrq>,<rssi>,<sinr>,<cqi>,<srxlev>
        #            +TENG:"NR5G-NSA",<mcc>,<mnc>,<pcid>,<rsrp>,<rsrq>,<sinr>
        # LTE mode: +TENG:"servingcell",<state>,"LTE",<is_tdd>,<mcc>,<mnc>,<cellid>,<pcid>,
        #           <earfcn>,<freq_band_ind>,<dl_bandwidth>,<ul_bandwidth>,<tac>,<rsrp>,<rsrq>,<rssi>,<sinr>,<srxlev>
        # WCDMA mode: +TENG:"servingcell",<state>,"WCDMA",<mcc>,<mnc>,<lac>,<cellid>,<uarf
        #             cn>,<psc>,<rac>,<rscp>,<ecio>,<phych>,<sf>,<slot>,<speech_code>,<comMod>
        # GSM mode: +TENG:"servingcell",<state>,"GSM",<mcc>,<mnc>,<lac>,<cellid>,<bsid>,<arfcn>
        #
        return "AT+TENG=\"servingcell\""

    def check_neighbour_cell(self):
        # SA mode : +TENG: "NR5G Neighbour Cell",<plmn>
        # SCC:<state>,<scc_id>,<band>,<channel>,<pcid>,<dl_bandwidth>,<sinr>
        # SCC:<state>,<scc_id>,<band>,<channel>,<pcid>,<dl_bandwidth>,<sinr>
        # LTE mode: +TENG:"neighbourcell intra","LTE",<earfcn>,<pcid>,<rsrq>,<rsrp>,<rssi>,
        #           <sinr>,<srxlev>,<cell_resel_priority>,<s_non_intra_search>,<thresh_serving_low>,<s_intra_search>
        #           +TENG:"neighbourcell inter","LTE",<earfcn>,<pcid>,<rsrq>,<rsrp>,<rssi>,
        #               <sinr>,<srxlev>,<cell_resel_priority>,<threshX_low>,<threshX_high>
        # +TENG:"neighbourcell","WCDMA",<uarfcn >,<cell_resel_priority>,<thresh_Xhigh>,<thresh_Xlow >,
        # <psc>,<rscp>,<ecio>,<srxlev>
        # +TENG:"neighbourcell","GSM",<arfcn>,<cell_resel_priority>,<thresh_gsm_high>,<thresh_gsm_low>,
        #      <ncc_permitted>,<band_1900 >,<bsic_id>,< srxlev >
        # example: AT +TENG="servingcell"
        # + TENG: "LTE", "FDD",460, 00,81EF7D0,78,1300,3,5,5,1806,-68,-8,-38,15
        # + TENG: "NR5G-NSA", 460, 00,570,-90,64,-11
        return "AT+TENG=\"neighbourcell\""


# for interface#
class AtCommands():
    """Module with AT commands for qualcomm prototypes"""
    ALIVE_CHECK = "AT"
    CHECK_IMEI = 'AT+GSN'
    CHECK_TA_FUNC = 'AT+GCAP'
    CHECK_ENDC = "AT+TENDC"
    CHECK_IP = "AT+CGPADDR"  # check all ip addr
    CHECK_CELL_TYPE = "AT+CGREG?"
    CHECK_ATTACH_STATUS = "AT+COPS?"
    CHECK_IMS = "AT+CGDCONT?"
    PPPOE_CALL = "AT$QCRMCALL=1,1"
    VONR_CALL_DEFAULT_NUMBER = "6688"
    VONR_CALL = f"ATD+{VONR_CALL_DEFAULT_NUMBER};"
    VONR_CALL_END = "ATH;"
    VONR_EMERGENCY_CALL = "911"
    RESET = "AT+CFUN=1,1"
    GET_ACTIVE_PDP = "AT+CGACT?"

    # getmodel
    set_UE_Func = AtCommand_SetFunc()
    clock = AtCommand_Clock()
    set_LTE_Band = AtCommand_LTE_band()
    set_5G_SA_Band = AtCommand_5G_SA_band()
    set_5G_NSA_Band = AtCommand_5G_NSA_band()
    sim_Card = AtCommand_SIM_Card()
    net_service = AtCommand_Net_Service_Fibocom()
    cell = AtCommand_cell()

    def __init__(self, vendor="Fibocom"):
        self.vendor = vendor
        if vendor == "Fibocom":
            self.net_service = AtCommand_Net_Service_Fibocom()
        elif vendor == "Quectel":
            self.net_service = AtCommand_Net_Service_Quectel()
