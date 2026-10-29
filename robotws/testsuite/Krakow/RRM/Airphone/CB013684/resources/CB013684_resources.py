import taf.rfrl.utilities.logger.custom_logger as logger
import ta5g_pm_counters


def verify_counters_division(counter_val, counter_denom, min_val, max_val):
    try:
        div_val = float(counter_val) / float(counter_denom)
    except ZeroDivisionError:
        logger.log_warn_to_console(f" Division by 0 ({counter_val}/{counter_denom})!")
        div_val = 0

    if float(min_val) <= div_val <= float(max_val):
        logger.log_info_to_console(f"Value {div_val} in range ({min_val}-{max_val})", log_hierarchy=2)
    else:
        raise Exception(f"Value {div_val} not in range ({min_val}-{max_val})")


class CounterValidationNotSucceed(Exception):
    pass


class ValueNotGreaterOrEqual(Exception):
    pass


def verify_counters_division_list(counters_tab, filepath):
    pm_counters = ta5g_pm_counters.ta5g_pm_counters()
    counter_status = []
    validation_fail = 0
    for counter in counters_tab:
        print(counter)

        num = counter["num"]
        denom = counter["denom"]
        low = float(counter["low"])
        high = float(counter["high"])
        tmp_stat = {"name": f'{num["name"]}/{denom["name"]}', "low": low, "high": high}
        try:
            num_val = pm_counters.get_pm_counter_value(
                counter=num["id"], localmoid=num["mo_id"], filepath=filepath)[0]
            denom_val = pm_counters.get_pm_counter_value(
                counter=denom["id"], localmoid=denom["mo_id"], filepath=filepath)[0]
        except IndexError:
            logger.log_warn_to_console(f' {num["name"]} or {denom["name"]} empty!')
            validation_fail += 1

        try:
            div_val = float(num_val) / float(denom_val)
        except ZeroDivisionError:
            logger.log_warn_to_console(f" Division by 0 ({num_val}/{denom_val})!")
            div_val = 0
        tmp_stat["val"] = div_val
        if float(low) <= div_val <= float(high):
            logger.log_info_to_console(f"Value {div_val} in range ({low}-{high})", log_hierarchy=2)
            tmp_stat["result"] = True
        else:
            tmp_stat["result"] = False
            validation_fail += 1
            logger.log_warn_to_console(f"Value {div_val} not in range ({low}-{high})", log_hierarchy=2)
        counter_status.append(tmp_stat)
    print(counter_status)
    if validation_fail:
        raise CounterValidationNotSucceed(f"Some counters ({validation_fail}) are not in expected range")


def my_counters_validator(counters_tab, filepath):
    pm_counters = ta5g_pm_counters.ta5g_pm_counters()
    counter_status = []
    validation_fail = 0
    for cntr in counters_tab:
        tmp_stat = {"id": cntr["id"], "name": cntr["name"], "low": cntr["low"], "high": cntr["high"]}
        cnt_val = pm_counters.get_pm_counter_value(counter=cntr["id"], localmoid=cntr["mo_id"], filepath=filepath)
        try:
            if float(cntr["low"]) <= float(cnt_val[0]) <= float(cntr["high"]):
                logger.log_info_to_console(
                    f'{cntr["name"]} value {cnt_val} in range ({cntr["low"]}-{cntr["high"]})', log_hierarchy=2)
                tmp_stat["value"] = float(cnt_val[0])
                tmp_stat["result"] = True
            else:
                logger.log_warn_to_console(
                    f'{cntr["name"]} value {cnt_val} not in range ({cntr["low"]}-{cntr["high"]})',
                    log_hierarchy=2)
                tmp_stat["value"] = float(cnt_val[0])
                tmp_stat["result"] = False
                validation_fail += 1
        except IndexError:
            logger.log_warn_to_console(f'{cntr["name"]} empty', log_hierarchy=2)
            tmp_stat["value"] = False
            tmp_stat["result"] = False
            validation_fail += 1
        counter_status.append(tmp_stat)

    print(counter_status)
    if validation_fail:
        raise CounterValidationNotSucceed(f"Some counters ({validation_fail}) are not in expected range")


def check_if_greater_or_equal(to_check, value, name=None):
    disp_name = ""
    if name:
        disp_name = f"{name}: "
    if float(to_check) >= float(value):
        logger.log_info_to_console(f"{disp_name}{to_check} is greater or equal than {value}", log_hierarchy=2)
        return True
    else:
        raise ValueNotGreaterOrEqual(f"{disp_name}{to_check} is not greater or equal than {value}")
