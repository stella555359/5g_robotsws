"""
:copyright: Nokia Networks
:authors:
arkadiusz.sobejko@nokia.com
michal.obszarny@nokia.com

:maintainers:
arkadiusz.sobejko@nokia.com
michal.obszarny@nokia.com

"""
import csv
from robot.errors import ExecutionFailed
from robot.api import logger
from ta5g_pm_counters import ta5g_pm_counters
from taf.rfrl.utilities.robot.general import get_builtin_value
from ta_egate_cmd_parser import ta_egate_cmd_parser
from ta_messaging.message_flows import get_flow
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers

csv_bip = csv_verifiers()
ta_egate = ta_egate_cmd_parser()


def verify_dc_state(ue_id, state):
    """
        Check on egate console NR-DC state
        :param ue_id: ue id
        :param state: wanted NR-DC state
    """
    cmd = ta_egate.get_command('ue_disp')
    dc_state = cmd(id=ue_id).execute_and_parse()['DC state']['Value']
    assert dc_state == state, f"UE {ue_id} is not in expected NR-DC expected:{state}, but is {dc_state}"


def get_sn_remote_host_ip():
    tl_cfg = get_builtin_value(param_name="tl")
    try:
        return tl_cfg.test_pcs[1].default_ssh_connection_details.addr
    except IndexError:
        pass


def verify_tadv_in_bip_logs(csv_path, expected_value, diff=1, tc_res=128):
    """
    Function that verifies initialTa and initialUlEcidTAdv from BIP logs to expected value
    +------------------+---------+------------+------------+------------+
    |     Example                                                       |
    +==================+=========+============+============+============+
    | Verify tadv in BIP logs    csv_path=${csv_path}  expected_value=25|
    +------------------+---------+------------+------------+------------+
    :param csv_path:        path to csv file
    :param expected_value:  expected values from BIP logs to which initialTa and initialUlEcidTAdv will be compared
    :param diff:            accepted error in results
    :param tc_res:          Tc resolution for timing advance. 128 Tc resolution for timing advance less than 262144 Tc
                            and 512 Tc for timing advance greater than or equal to 262144 Tc
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    initialTa = csv_bip.filter_csv_by_column_value(
        csv_list=csv_list,
        column_name='UlData_detectedPrachPreambles_t.initialTa',
        condition='==',
        value=expected_value)
    logger.info(f"Number of occurences with UlData_detectedPrachPreambles_t.initialTa=={expected_value} is equal to"
                f" {len(initialTa[1:])}")
    assert len(initialTa[1:]) == 1, f'Only One occurance of UlData_detectedPrachPreambles_t.initialTa' \
                                    f'=={expected_value} should be found'

    initialUlEcidTAdv = csv_bip.filter_csv_by_column_value(
        csv_list=csv_list,
        column_name='UlData_detectedPrachPreambles_t.initialUlEcidTAdv',
        condition='>=',
        value=0)

    logger.info(f'Filtered list={initialUlEcidTAdv}')
    assert len(initialUlEcidTAdv[1:]) == 1, f'Only one occurance of UlData_detectedPrachPreambles_t.' \
                                            f'initialUlEcidTAdv should be found'
    assert tc_res*int(expected_value)*(1+diff/100) >= float(initialUlEcidTAdv[1][-1]) >=\
           tc_res*int(expected_value)*(1-diff/100), f'initialUlEcidTAdv={initialUlEcidTAdv[1][-1]} should be ' \
                                                    f'in range ({tc_res*int(expected_value)*(1+diff/100)}, ' \
                                                    f'{tc_res*int(expected_value)*(1+diff/100)})'


def verify_counter(counter, gnb_counters, expected_value, margin=3, local_moid='PLMN-PLMN/MRBTS-1/NRBTS-1'):
    """
    Verify counter - compare expected value and gnb counter
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                                 |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    | Verify counter  counter=M55320C07001  gnb_counters=${pm_counters}  expected_value=${bip_counters}  margin=3 |
    | Verify counter  counter=M55320C07001  gnb_counters=${pm_counters}  expected_value=100  margin=2             |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    :param counter:         id of counter
    :param gnb_counters:    path to pm counters
    :param expected_value:  expected value as dict or string
    :param margin:          allowed error between expected and pm counters
    :local_moid:            local moid
    :return:
    """
    if isinstance(gnb_counters, dict):
        gnb_counter = gnb_counters[counter]
        print(gnb_counter)
    else:
        gnb_counter = get_counter_value_from_pm_counters(counter, local_moid, gnb_counters)
    if isinstance(expected_value, dict):
        expected_value = get_rtwp_counter(counter, expected_value)
    assert float(expected_value)*(1-margin/100) >= gnb_counter >= float(expected_value)*(1+margin/100), \
        f'{counter}: {round(float(expected_value)*(1-margin/100), 3)} >= {gnb_counter}' \
        f' >= {round(float(expected_value)*(1+margin/100), 3)}'


def get_counter_value_from_pm_counters(counter_id, local_moid, pm_counter_file):
    """
    Get counter value from pm counters - get value of single counter from pm counters
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                                 |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    | counters = get_counter_value_from_pm_counters(counter, NR_RTWP_COUNTERS_MOID, high_int_counters)            |
    +------------------+------------+------------+------------+------------+------------+------------+------------+
    :param counter_id:       id of counter
    :local_moid:             local moid
    :param pm_counter_file:  path to pm counters
    :return:                 value of counter
    """
    counter_value = ta5g_pm_counters().get_pm_counter_value(counter_id, local_moid, pm_counter_file)
    if len(counter_value) == 0:
        raise ExecutionFailed(
            message=f'The PM counter {counter_id} doesn\'t have value',
            continue_on_failure=True,
        )
    else:
        return counter_value[0]


def get_rtwp_counter(counter, bip_counters):
    """
    Get rtwp counter - get value of single counter from bip counters
    +------------------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                    |
    +------------------+------------+------------+------------+------------+------------+------------+
    | ${M55320C07001}=  get rtwp counter  M55320C07001  ${counters}                                  |
    +------------------+------------+------------+------------+------------+------------+------------+
    :param counter_id:       id of counter
    :local_moid:             local moid
    :param pm_counter_file:  path to pm counters
    :return:                 value of counter
    """
    return bip_counters[counter]


def check_if_next_data_starts_from_fmc(bip_csv_filepath):
    fmc_dl_pdcp = 0
    fmc_ul_pdcp = 0
    skipped_dl_data = 0
    ul_pdcp_checked = 0
    dl_pdcp_checked = 0
    seq_num_ul_data_between_status = []
    indexes_to_remove = []
    collected_values = {"uldata_puschreceiveresplol1sw": [], "dldata_pdschpayloadtbsendreql1sw": [],
                        "pdcp-nr.fmc": [], "pdcp-nr.seq-num": []}
    collected_bip = csv_bip.create_list_of_lists_from_csv(bip_csv_filepath)
    collected_file_values = csv_bip.get_multiple_columns_values('uldata_puschreceiveresplol1sw',
                                                                'dldata_pdschpayloadtbsendreql1sw',
                                                                'pdcp-nr.fmc', 'pdcp-nr.seq-num',
                                                                input_list=collected_bip, as_dict=True)

    collected_values["uldata_puschreceiveresplol1sw"].extend(collected_file_values["uldata_puschreceiveresplol1sw"])
    (collected_values["dldata_pdschpayloadtbsendreql1sw"].
     extend(collected_file_values["dldata_pdschpayloadtbsendreql1sw"]))
    collected_values["pdcp-nr.fmc"].extend(collected_file_values["pdcp-nr.fmc"])
    collected_values["pdcp-nr.seq-num"].extend(collected_file_values["pdcp-nr.seq-num"])
    collected_values["pdcp-nr.seq-num"] = [[s] for s in collected_values["pdcp-nr.seq-num"]]

    for row in range(len(collected_values["uldata_puschreceiveresplol1sw"])):
        if (collected_values["pdcp-nr.fmc"][row] == '') and (collected_values["pdcp-nr.seq-num"][row][0] == ''):
            indexes_to_remove.append(row)

    for i in sorted(indexes_to_remove, reverse=True):
        for message in collected_values.values():
            del message[i]

    if not (any(x.strip() != "" for x in collected_values["pdcp-nr.fmc"])):
        logger.info("No FMC in BIP LOGS")
        return False

    for seq_num_list in range(len(collected_values["pdcp-nr.seq-num"])):
        collected_values["pdcp-nr.seq-num"][seq_num_list].extend(collected_bip[seq_num_list+1][4:])

    for row in range(len(collected_values["uldata_puschreceiveresplol1sw"])):
        if collected_values['pdcp-nr.fmc'][row] and collected_values['uldata_puschreceiveresplol1sw'][row]:
            fmc_value = collected_values['pdcp-nr.fmc'][row]
            if ',' in fmc_value:
                fmc_list = fmc_value.split(',')
                fmc_dl_pdcp = int(fmc_list[0].rstrip("\\"))
            else:
                fmc_dl_pdcp = int(fmc_value.rstrip("\\"))
            if (collected_values["pdcp-nr.seq-num"][row][0] != "" and
                    int(collected_values["pdcp-nr.seq-num"][row][0]) == fmc_dl_pdcp):
                logger.info("2 times FMC for DL PDCP status")
                del collected_values["pdcp-nr.seq-num"][row][0]

            if fmc_ul_pdcp and not dl_pdcp_checked:
                logger.info("DL PDCP status after UL PDCP status without data between")
                skipped_dl_data = 0
            elif fmc_ul_pdcp and dl_pdcp_checked:
                logger.info("DL PDCP status after UL PDCP status with DL data between not needed check DL data")
                continue
            else:
                continue

        elif collected_values['pdcp-nr.fmc'][row] and collected_values['dldata_pdschpayloadtbsendreql1sw'][row]:
            fmc_value = collected_values['pdcp-nr.fmc'][row]
            if ',' in fmc_value:
                fmc_list = fmc_value.split(',')
                fmc_ul_pdcp = int(fmc_list[0].rstrip("\\"))
            else:
                fmc_ul_pdcp = int(fmc_value.rstrip("\\"))

        if fmc_dl_pdcp and not skipped_dl_data and collected_values['dldata_pdschpayloadtbsendreql1sw'][row]:
            collected_values['pdcp-nr.seq-num'][row] = [s.rstrip("\\") for s
                                                        in collected_values['pdcp-nr.seq-num'][row]]
            if collected_values['pdcp-nr.seq-num'][row][0]:
                first_seq_num = int(collected_values['pdcp-nr.seq-num'][row][0])
            else:
                logger.info("UL PDCP without SEQ NUMBER")
                continue
            if first_seq_num < 20 and collected_values["pdcp-nr.fmc"][row] == '':
                logger.info("This is control packet or RRC")
                continue
            assert fmc_ul_pdcp != 0, "DL data before UL PDCP status"
            assert first_seq_num == fmc_dl_pdcp, \
                (f"First seq number must be equal FMC, FMC for DL PDCP equal {fmc_dl_pdcp}, "
                 f"SEQ NUMB eq {first_seq_num} fo DL DATA")
            if first_seq_num == fmc_dl_pdcp:
                logger.info("DL PDCP checked")
                fmc_dl_pdcp = 0
                dl_pdcp_checked = 1
                continue

        if fmc_ul_pdcp and collected_values['uldata_puschreceiveresplol1sw'][row]:
            seq_num_ul_data_between_status = [int(s) for s in seq_num_ul_data_between_status if s != ""]
            if fmc_ul_pdcp in seq_num_ul_data_between_status:
                logger.info("UL data started before DL PDCP status and FMC in SEQ NUMBER")
                logger.info("UL PDCP checked")
                seq_num_ul_data_between_status = []
                fmc_ul_pdcp = 0
                ul_pdcp_checked = 1
                continue
            collected_values['pdcp-nr.seq-num'][row] = [s.rstrip("\\") for s in
                                                        collected_values['pdcp-nr.seq-num'][row]]
            if collected_values['pdcp-nr.seq-num'][row][0]:
                first_seq_num = int(collected_values['pdcp-nr.seq-num'][row][0])
            else:
                logger.info("DL PDCP without SEQ NUMBER")
                continue
            if first_seq_num < 20 and collected_values["pdcp-nr.fmc"][row] == '':
                logger.info("This is control packet or RRC")
                continue
            assert first_seq_num == fmc_ul_pdcp, \
                (f"First seq number must be equal FMC, FMC for UL PDCP equal {fmc_ul_pdcp}, "
                 f"SEQ NUMB equal {first_seq_num} for UL DATA, possible when using AP")
            if first_seq_num == fmc_ul_pdcp:
                logger.info("UL PDCP checked")
                fmc_ul_pdcp = 0
                ul_pdcp_checked = 1
                continue

        if (fmc_ul_pdcp and not fmc_dl_pdcp and not dl_pdcp_checked
                and collected_values['dldata_pdschpayloadtbsendreql1sw'][row]):
            logger.info("First UL PDCP status, DL data can start earlier, not needed check FMC and SEQ NUM for DL DATA")
            logger.info("DL PDCP checked")
            skipped_dl_data = 1
            dl_pdcp_checked = 1
            continue

        if (fmc_dl_pdcp and not fmc_ul_pdcp and not ul_pdcp_checked
                and collected_values['uldata_puschreceiveresplol1sw'][row]):
            logger.info("UL DATA BETWEEN DL and UL PDCP status, it is possible")
            collected_values['pdcp-nr.seq-num'][row] = [s.rstrip("\\") for s
                                                        in collected_values['pdcp-nr.seq-num'][row]]
            if collected_values['pdcp-nr.seq-num'][row]:
                seq_num_ul_data_between_status.extend(collected_values['pdcp-nr.seq-num'][row])

        if ul_pdcp_checked and dl_pdcp_checked:
            fmc_dl_pdcp = 0
            fmc_ul_pdcp = 0
            skipped_dl_data = 0
            ul_pdcp_checked = 0
            dl_pdcp_checked = 0
