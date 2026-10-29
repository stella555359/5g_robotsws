from ta_emss import ta_emss
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed

COUNTER_IDS = {'GNB_SA_DU_ADM_SUCC_BWP': {'1': 'M55139C02501', '2': 'M55139C02502', '3': 'M55139C02504'},
               'SGNB_NSA_DU_ADM_SUCC_BWP': {'1': 'M55115C02001', '2': 'M55115C02002', '3': 'M55115C02004'},
               'NRRC_RRC_RECONF_BWP_SENT': {'1': 'M55166C00001', '2': 'M55166C00002', '3': 'M55166C00511'},
               'NRRC_RCFG_CMP_BWP_RCVD': {'1': 'M55166C00003', '2': 'M55166C00004', '3': 'M55166C00512'},
               'GNB_DU_SCELL_ADM_BWP_SUCC': {'1': 'M55139C04511', '2': 'M55139C04512', '3': 'M55139C04513'},
               'SGNB_DU_SCELL_ADM_BWP_SUCC': {'1': 'M55115C00024', '2': 'M55115C00025', '3': 'M55115C00026'},
               'GNB_DU_SCELL_ADM__BWP_SUCC': {'S': 'M55139C04001', 'L': 'M55139C04002'},
               'SGNB_DU_SCELL_ADM__BWP_SUCC': {'S': 'M55115C03001', 'L': 'M55115C03002'},
               'SUM_UE_SCELL_CONF__BWP': {'S': 'M55167C00002', 'L': 'M55167C00003'},
               'SA_DU_ADM_ATT_GBR_BWP': {'1': 'M55139C04505', '2': 'M55139C04507', '3': 'M55139C04509'},
               'SA_DU_ADM_SUCC_GBR_BWP': {'1': 'M55139C04506', '2': 'M55139C04508', '3': 'M55139C04510'},
               }

NRCELLS_MOID = ['PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1',
                'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2',
                'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3',
                'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4']


@keyword("Verify that counters ${counters} are equal [${values}] in NRCELL-${cell_id} in gNB2")
def check_rtpm_bwp_counters(counters, values, cell_id):
    emss = ta_emss(host='10.0.1.1', port=4001)
    nrcell = "NRCELL-" + cell_id
    values_list = values.split(',')
    counter_id_list = get_counter_ids(counters)

    for value, counter in zip(values_list, counter_id_list):
        if value[0] == '>':
            expected_value = [int(value[1:]), 99999999]
        elif value[0] == '<':
            expected_value = [0, int(value[1:])]
        else:
            if '-' in value:
                expected_value = [int(n) for n in values.split('-')]
            else:
                expected_value = int(value)
        try:
            emss.verify_that_rtpm_counter_value_is_equal_to(nrcell, counter, expected_value)
        except Exception as err:
            raise ExecutionFailed(message=str(err), continue_on_failure=True)


@keyword('Verify that RD counter ${counter} is equal ${value} in NRCELL-${cell_id} in gNB2')
def check_rd_counter_value(counter, value, cell_id):
    pm_counters_file = BuiltIn().get_variable_value('${pm_counters_filepath}')
    ta_5g_pm_lib = BuiltIn().get_library_instance('ta5g_pm_counters')

    ta_5g_pm_lib.verify_if_latest_pm_counter_has_exact_value(counter, int(value),
                                                             NRCELLS_MOID[int(cell_id) - 1],
                                                             pm_counters_file)


@keyword('Verify that RD counters ${counters} are equal [${values}] in NRCELL-${cell_id} in gNB2')
def check_multiple_rd_counters_values(counters, values, cell_id):
    values_list = values.split(',')
    counter_names = get_counter_names(counters)

    pm_counters_file = BuiltIn().get_variable_value('${pm_counters_filepath}')
    ta_5g_pm_lib = BuiltIn().get_library_instance('ta5g_pm_counters')

    for value, counter in zip(values_list, counter_names):
        act_value = ta_5g_pm_lib.get_latest_pm_counter_value(counter, NRCELLS_MOID[int(cell_id) - 1],
                                                             pm_counters_file)
        print('{} actual value: {}, expected value: {}'.format(counter, act_value, value))
        if value[0] == '>':
            assert act_value > int(value[1:]), '{} actual value {} not greater than {}'.format(
                counter, act_value, value[1:])
        elif value[0] == '<':
            assert act_value < int(value[1:]), '{} actual value {} not lower than {}'.format(
                counter, act_value, value[1:])
        else:
            if '-' in value:
                assert int(value[:value.find('-')]) >= act_value <= int(
                    value[value.find('-') + 1:]), '{} actual value {} not in range {}'.format(
                    counter, act_value, value)
            else:
                assert act_value == int(value), '{} actual value {} not equal {}'.format(counter,
                                                                                         act_value,
                                                                                         value)


def get_counter_ids(counter):
    alias = counter[:counter.find('[')] + counter[counter.find(']') + 1:]
    bwp_list = counter[counter.find('[') + 1:counter.find(']')].split(',')
    counter_id_list = []
    for bwp in bwp_list:
        counter_id_list.append(COUNTER_IDS[alias][bwp])
    print('Checking counters: {}'.format(counter_id_list))
    return counter_id_list


def get_counter_names(counter):
    bwp_list = counter[counter.find('[') + 1:counter.find(']')].split(',')
    counter_names_list = []
    for bwp in bwp_list:
        counter_names_list.append(counter[:counter.find('[')] + str(bwp) + counter[counter.find(']') + 1:])
    return counter_names_list
