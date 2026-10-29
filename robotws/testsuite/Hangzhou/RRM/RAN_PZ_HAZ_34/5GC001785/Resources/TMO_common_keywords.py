import os

import openpyxl
from TMO_VoNR_variables import counter_SFE_case_001, counter_SFE_case_002, counter_SFE_case_003, counter_SFE_case_004, \
    counter_SFE_case_005, counter_SFE_case_006


class Calculate:
    def __init__(self, filename, sheetname):
        self.filename = filename
        self.sheetname = sheetname
        self.wb = openpyxl.load_workbook(filename=self.filename)
        self.table = self.wb[self.sheetname]
        self.nrows = self.table.max_row
        self.ncols = self.table.max_column

    def get_data(self, counter_prop):
        for row in self.table.iter_rows():
            for cell in row:
                if cell.value is not None:
                    info = str(cell.value).find(counter_prop)
                    if info == 0:
                        counter_col = cell.column
        sum_value = []
        for i in range(2, self.nrows + 1):
            sum_value.append(self.table.cell(row=i, column=counter_col).value)
        return sum(sum_value)

    def sum_data(self):
        counter_names_value = []
        for i in range(1, self.ncols + 1):
            counter_names_value.append(self.table.cell(row=1, column=i).value)
        list_counters_name = list(set(counter_names_value[1:]))

        list_sum_counters_value = []
        for counter in list_counters_name:
            counter_values_variable = self.get_data(counter_prop=counter)
            list_sum_counters_value.append(counter_values_variable)

        dict_sum_counter_name_and_value = dict(zip(list_counters_name, list_sum_counters_value))
        print(dict_sum_counter_name_and_value)

        return dict_sum_counter_name_and_value

    def calculate_data(self):
        pass


def get_dict_counter_and_name(filename, sheetname):
    calculate = Calculate(filename=filename, sheetname=sheetname)
    dict_sum_counter_name_and_value = calculate.sum_data()
    return dict_sum_counter_name_and_value


def calculate_kpis(kpi_id, filename, sheetname):
    dict_sum_counter_name_and_value = get_dict_counter_and_name(filename=filename, sheetname=sheetname)
    if kpi_id == 'NR_5237a':
        # Sum([M55138C01001]) (Sum([The number of GBR DRB radio admission requests for SA user]))
        sum_m55138c01001_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[0])
        sum_m55138c01001_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[1])
        result = [sum_m55138c01001_0, sum_m55138c01001_1]
    elif kpi_id == 'NR_5238a':
        # NR_5238a 5G SA GBR DRB setup success ratio
        # 100* Sum([M55145C01501]) / sum([M55138C01001]) (100* Sum([SUCC_GBR_DRB_SETUP_SA_PLMN]) /
        # sum([SA_GBR_DRB_REQ]))
        sum_m55145c01501_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[2])
        sum_m55145c01501_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[3])
        sum_m55145c01501_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[4])
        sum_m55145c01501_3 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[5])
        sum_m55145c01501_4 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[6])
        sum_m55145c01501_5 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[7])
        sum_m55138c01001_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[0])
        sum_m55138c01001_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[1])
        try:
            # kpi_value1 = (sum_m55145c01501_0 + sum_m55145c01501_1 + sum_m55145c01501_2) / sum_m55138c01001_0
            kpi_value2 = (sum_m55145c01501_3 + sum_m55145c01501_4 + sum_m55145c01501_5) / sum_m55138c01001_1
        except ZeroDivisionError:
            print('please check sum_m55125c03002 why is 0')
        finally:
            # result = [kpi_value1, kpi_value2]
            result = [kpi_value2]
    elif kpi_id == 'NR_5239a':
        # NR_5239a 5G SA GBR traffic load in Erlang
        # Sum([M55138C01005]) / 3600 (Sum([Average number of SA GBRs]) / 3600)
        sum_m55138c01005_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[8])
        sum_m55138c01005_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[9])
        result = [sum_m55138c01005_0/3600, sum_m55138c01005_1/3600]
    elif kpi_id == 'NR_5240a':
        # NR_5240a 5G SA Average GBR call holding time per cell
        # Sum([M55138C01008]/1000) / Sum([M55138C01009]) (Sum([AVE_SA_GBR_HOLDING_TIME]/1000) /
        # Sum([AVE_SA_GBR_HOLDING_TIME_DEN]))
        # M55320C19002 DL_VOL_ROHC_COMP_HEADER
        # M55319C12001 DL_VOL_TX_SA_QOS_GRP_01
        sum_m55138c01008_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[10])
        sum_m55138c01008_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[11])
        sum_m55138c01009_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[12])
        sum_m55138c01009_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[13])
        sum_m55320c19002 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[14])
        sum_m55319c12001 = dict_sum_counter_name_and_value.get(counter_SFE_case_001[15])
        try:
            kpi_value1 = (sum_m55138c01008_0 / 1000) / sum_m55138c01009_0
            kpi_value2 = (sum_m55138c01008_1 / 1000) / sum_m55138c01009_1
        except ZeroDivisionError:
            print('please check sum_m55125c03002 why is 0')
        finally:
            result = [kpi_value1, kpi_value2, sum_m55320c19002, sum_m55319c12001]
    elif kpi_id == 'NR_5241a':
        # Sum([M55124C02501])  (Sum([NR_RRC_RELEASE_REDIR_VFB_LTE]))
        sum_m55124c02501 = dict_sum_counter_name_and_value.get(counter_SFE_case_002[0])
        sum_m55124c01502 = dict_sum_counter_name_and_value.get(counter_SFE_case_002[1])
        result = [sum_m55124c02501, sum_m55124c01502]
    elif kpi_id == 'NR_600b':
        # Sum(m55124c01017)   Sum(nrrcc_rrc_stpreq_mo_videocal)
        sum_m55124c01017 = dict_sum_counter_name_and_value.get(counter_SFE_case_003[0])
        result = [sum_m55124c01017]
    elif kpi_id == 'NR_5155':
        # NR_5155 5G SA PDU session setup success ratio for IMS Emergency calls
        # 100 * Sum([M55125C05506]) / Sum([M55125C05505]) (100 * Sum([NNGCC_PDU_SES_STP_RESP_EC_SENT])
        # / Sum([NNGCC_PDU_SES_STP_REQ_EC_RECD]))
        sum_m55125c05506_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[0])
        sum_m55125c05506_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[1])
        sum_m55125c05505_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[2])
        sum_m55125c05505_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[3])
        try:
            # kpi_value1 = 100 * sum_m55125c05506_0 / sum_m55125c05505_0
            kpi_value2 = int(100 * sum_m55125c05506_1 / sum_m55125c05505_1)
        except ZeroDivisionError:
            print('please check sum_m55125c03002 why is 0')
        finally:
            # result = [kpi_value1, kpi_value2]
            result = [kpi_value2]
    elif kpi_id == 'NR_1273a':
        # NR_1273a SA PDU sess stp reqs Emg
        # Sum(m55125c05505) Sum(nngcc_pdu_ses_stp_req_ec_recd)
        sum_m55125c05505_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[2])
        sum_m55125c05505_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[3])
        result = [sum_m55125c05505_0, sum_m55125c05505_1]
    elif kpi_id == 'NR_1275a':
        # NR_1275a 5G SA Number of PDU session modify requests for IMS Emergency calls
        # Sum(m55125c05509) Sum(nngcc_pdusesmodreq_ec_recd)
        sum_m55125c05509_0 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[4])
        sum_m55125c05509_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_004[5])
        result = [sum_m55125c05509_0, sum_m55125c05509_1]
    elif kpi_id == 'NR_5435':
        # NR_5435 5G Number of UE redirections to E-UTRAN due to IMS Emergency call voice fallback to LTE
        # Sum([M55124C04002]) (Sum([NR_RRC_RELEASE_REDIR_EC_LTE]))
        sum_m55124c04002 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[0])
        result = [sum_m55124c04002]
    elif kpi_id == 'NR_985a':
        # NR_985a 5G SA Number of initial context setup requests for emergency fallback
        # Sum(m55125c03001) Sum(nngcc_ue_ctxt_stp_req_ef_recd)
        sum_m55125c03001 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[1])
        result = [sum_m55125c03001]
    elif kpi_id == 'NR_986a':
        # NR_986a 5G SA Initial context setup success ratio for emergency fallback
        # 100 * Sum(m55125c03002)/Sum(m55125c03001)
        # 100 * Sum(nngcc_ue_ctxt_stp_resp_ef_sent)/Sum(nngcc_ue_ctxt_stp_req_ef_recd)
        sum_m55125c03001 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[1])
        sum_m55125c03002 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[2])
        try:
            kpi_value = 100 * sum_m55125c03001 / sum_m55125c03002
        except ZeroDivisionError:
            print('please check sum_m55125c03002 why is 0')
        finally:
            result = [kpi_value]
    elif kpi_id == 'NR_990a':
        # NR_990a 5G SA UE context modification success ratio for emergency fallback
        # 100 * Sum(m55125c03008)/Sum(m55125c03007)
        # 100 * Sum(nngcc_ue_ctxt_mod_resp_ef_sent)/Sum(nngcc_ue_ctxt_mod_req_ef_recd)
        sum_m55125c03008 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[3])
        sum_m55125c03007 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[4])
        try:
            kpi_value = 100 * sum_m55125c03008 / sum_m55125c03007
        except ZeroDivisionError:
            print('please check sum_m55125c03007 why is 0')
        finally:
            result = [kpi_value]
    elif kpi_id == 'NR_1269a':
        # NR_1269a 5G SA Emergency voice call fallback to LTE ratio
        # 100 * Sum(m55124c04002) / Sum(m55124c01004)
        # 100 * Sum(nr_rrc_release_redir_ec_lte) / Sum(nrrcc_rrc_stpreq_emergency)
        sum_m55124c04002 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[0])
        sum_m55124c01004 = dict_sum_counter_name_and_value.get(counter_SFE_case_005[5])
        try:
            kpi_value = 100 * sum_m55124c04002 / sum_m55124c01004
        except ZeroDivisionError:
            print('please check sum_m55124c01004 why is 0')
        finally:
            result = [kpi_value]
    elif kpi_id == 'NR_1435a':
        # NR_1435a 5G SA RoHC compression configuration success ratio
        # 100 * Sum(m55124c06002) / Sum(m55124c06001)
        # 100 * Sum(nrrcc_rohc_drb_ctx_cmp_recd) / Sum(nrrcc_rohc_drb_ctx_req_sent)
        sum_m55124c06002_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[0])
        sum_m55124c06001_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[1])
        sum_m55124c06002_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[6])
        sum_m55124c06001_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[7])
        try:
            kpi_value_1 = int(100 * sum_m55124c06002_1 / sum_m55124c06001_1)
            # kpi_value_2 = 100 * sum_m55124c06002_2 / sum_m55124c06001_2
        except ZeroDivisionError:
            print('please check sum_m55124c06001 why is 0')
        finally:
            # result = [kpi_value_1, kpi_value_2]
            result = [kpi_value_1]
    elif kpi_id == 'NR_1436a':
        # NR_1436a 5G SA Number of RoHC compression configuration requests
        # Sum(m55124c06001)  Sum(nrrcc_rohc_drb_ctx_req_sent)
        sum_m55124c06001_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[1])
        sum_m55124c06001_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[7])
        result = [sum_m55124c06001_1, sum_m55124c06001_2]
    elif kpi_id == 'NR_1476a':
        # NR_1476a  5G SA RoHC compression configuration success ratio (gNB perspective)
        # 100 * Sum(m55135c01002)/Sum(m55135c01001)
        # 100 * Sum(ne1cs_rohc_drb_ctx_resp_recd) / Sum(ne1cs_rohc_drb_ctx_req_sent)
        # M55320C19004 M55319C16001
        sum_m55135c01002_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[2])
        sum_m55135c01001_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[3])
        sum_m55135c01002_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[8])
        sum_m55135c01001_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[9])
        sum_m55320c19004_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[4])
        sum_m55320c19004_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[5])
        sum_m55319c16001_1 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[10])
        sum_m55319c16001_2 = dict_sum_counter_name_and_value.get(counter_SFE_case_006[11])
        try:
            kpi_value_1 = 100 * sum_m55135c01002_1 / sum_m55135c01001_1
            # kpi_value_2 = 100 * sum_m55135c01002_2 / sum_m55135c01001_2
        except ZeroDivisionError:
            print('please check sum_m55135c01001 why is 0')
        finally:
            # result = [kpi_value_1, kpi_value_2, sum_m55320c19004_1, sum_m55320c19004_2,
            #           sum_m55319c16001_1, sum_m55319c16001_2]
            result = [kpi_value_1, sum_m55320c19004_1, sum_m55320c19004_2,
                      sum_m55319c16001_1, sum_m55319c16001_2]
    return result


def get_result_with_voice_operation(path, file_name):
    file_path = os.path.join(path, '{}.txt'.format(file_name))
    print(file_path)
    try:
        f = open(file_path, 'r')
    except Exception as e:
        print(e)
    else:
        result = f.read()
        num = result.count('success!!!!')
    finally:
        f.close()
    # with open(file_path, 'r') as f:
    #     result = f.read()
    #     num = result.count('success!!!!')
    return num
