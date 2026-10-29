# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia.com
:maintainer: Civen Chen
:contact: civen.chen@nokia.com
"""
import logging
import os
import plotly.offline as py
import plotly.graph_objs as go
from taf.analyzer.aasyslog_throughput import aasyslog_throughput
from plotly import subplots
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.throughput.translator import (
    transfer_aasyslog_tput_format, translate_percentage)

aatput = aasyslog_throughput()


__all__ = ["check_aasyslog_throughput", "check_bi_aasyslog_throughput", "get_aasyslog_throughput"]


def check_aasyslog_throughput(direction, log, cells, target_throughput,
                              target_avg_percent=0.95, min_percent=0.85, actCarrierAggregation=False,
                              output_dir=None, customized_log_name=None, cell_indiv_tput=None,
                              actImgGeneration=True):
    """
    used for checking single direction throughput data from aasyslog file.
    Can also be used for analyze each direction data individually in bi-direction traffic.

    :param direction: (str) "UL" / "DL"
    :param log: (str) full path of aasyslog file
    :param cells: (list) list of on taffic cell id.  E.G: ['16385', '16386']
    :param target_throughput: (str) target throughput value.(theory value) unit in Mbps!! E.G 2048.0
    :param target_avg_percent: (str) acceptable percent. Default use 95%.
                               use in varify: tput > target_throughput * target_avg_percent
    :param min_percent: (str) minimum percentage, default use 85%.
    :param actCarrierAggregation: (bool) actCarrierAggregation in configuration.
    :param output_dir: (str) image file output directory, if None, will use current dir.
    :return:
    """
    origin_tput, origin_record = get_aasyslog_throughput(
        direction=direction,
        log=log,
        cells=cells,
        actCarrierAggregation=actCarrierAggregation,
    )
    tput = transfer_aasyslog_tput_format(origin_tput)
    logging.info("Getting origin tput result: {}".format(origin_tput))
    if actImgGeneration:
        try:
            _image_generation(
                direction=direction,
                origin_record=origin_record,
                actCarrierAggregation=actCarrierAggregation,
                target_throughput=target_throughput,
                target_avg_percent=target_avg_percent,
                output_dir=output_dir,
                min_percent=min_percent,
                customized_log_name=customized_log_name,
                time_interval=origin_tput[0]["min_time_interval"],
            )
        except Exception as err:
            logging.exception(err)
            logging.exception("Can't generate {} image.".format(direction))
    if actCarrierAggregation:
        _validate_tput_values(tput[None], target_throughput,
                              target_avg_percent, min_percent, "all")
        if cell_indiv_tput:
            i_cells = list(cell_indiv_tput.keys())
            origin_indiv_tput, indiv_record = get_aasyslog_throughput(
                direction=direction,
                log=log,
                cells=i_cells,
            )
            indiv_tput = transfer_aasyslog_tput_format(origin_indiv_tput)
            cell_failed = False
            error_print = []
            for cid in i_cells:
                try:
                    _validate_tput_values(indiv_tput[str(cid)], cell_indiv_tput[cid],
                                          target_avg_percent, min_percent, str(cid))
                except ValueError as err:
                    logging.exception("failed on Cell:{}, err: {}".format(cid, err))
                    error_print.append(str(err))
                    cell_failed = True
            else:
                if cell_failed:
                    raise ValueError("Failed during checking all cell. Errors below:\n{}".format(
                        "\n".join(error_print)
                    ))
    else:
        cell_failed = False
        error_print = []
        for cid in cells:
            try:
                _validate_tput_values(tput[str(cid)], target_throughput,
                                      target_avg_percent, min_percent, str(cid))
            except ValueError as err:
                logging.exception("failed on Cell:{}, err: {}".format(cid, err))
                error_print.append(str(err))
                cell_failed = True
        else:
            if cell_failed:
                raise ValueError("Failed during checking all cell. Errors below:\n{}".format(
                    "\n".join(error_print)
                ))


def check_bi_aasyslog_throughput(log, cells, ultarget_throughput, dltarget_throughput,
                                 target_avg_percent=0.95, min_percent=0.85, actCarrierAggregation=False,
                                 output_dir=None, customized_log_name=None, actImgGeneration=True):
    """
    used for checking bi-direction throughput data from aasyslog file.

    :param log: (str) full path of aasyslog file
    :param cells: (list) list of on taffic cell id.  E.G: ['16385', '16386']
    :param ultarget_throughput: (str) target throughput value.(theory value) unit in Mbps!! E.G 2048.0
    :param dltarget_throughput: (str) target throughput value.(theory value) unit in Mbps!! E.G 2048.0
    :param target_avg_percent: (str) acceptable percent. Default use 95%.
                               use in varify: ultput > ultarget_throughput * target_avg_percent
                                              dltput > dltarget_throughput * target_avg_percent
    :param min_percent: (str) minimum percentage, default use 85%.
    :param actCarrierAggregation: (bool) actCarrierAggregation in configuration.
    :param output_dir: (str) image file output directory, if None, will use current dir.
    :return:
    """
    origin_tput, ul_origin_record, dl_origin_record = get_bi_direction_aasyslog_tput(
        log=log,
        cells=cells,
        actCarrierAggregation=actCarrierAggregation
    )
    ultp = transfer_aasyslog_tput_format(origin_tput["ul"])
    dltp = transfer_aasyslog_tput_format(origin_tput["dl"])
    logging.info("Getting origin tput result: {}".format(origin_tput))
    if actImgGeneration:
        try:
            _image_generation(
                direction='ul',
                origin_record=ul_origin_record,
                actCarrierAggregation=actCarrierAggregation,
                target_throughput=ultarget_throughput,
                target_avg_percent=target_avg_percent,
                output_dir=output_dir,
                min_percent=min_percent,
                customized_log_name=customized_log_name,
                time_interval=origin_tput["ul"][0]["min_time_interval"],
            )
        except Exception as err:
            logging.exception(err)
            logging.exception("Can't generate {} image.".format(direction))
        try:
            _image_generation(
                direction='dl',
                origin_record=dl_origin_record,
                actCarrierAggregation=actCarrierAggregation,
                target_throughput=dltarget_throughput,
                target_avg_percent=target_avg_percent,
                output_dir=output_dir,
                min_percent=min_percent,
                customized_log_name=customized_log_name,
                time_interval=origin_tput["dl"][0]["min_time_interval"],
            )
        except Exception as err:
            logging.exception(err)
            logging.exception("Can't generate {} image.".format(direction))
    if actCarrierAggregation:
        ul_failed = False
        dl_failed = False
        try:
            logging.info("Start checking ul throughput in bi-direction check.")
            _validate_tput_values(ultp[None], ultarget_throughput,
                                  target_avg_percent, min_percent, "all")
        except ValueError as err:
            logging.exception(err)
            ul_failed = True
        try:
            logging.info("Start checking dl throughput in bi-direction check.")
            _validate_tput_values(dltp[None], dltarget_throughput,
                                  target_avg_percent, min_percent, "all")
        except ValueError as err:
            logging.exception(err)
            dl_failed = True
        if ul_failed or dl_failed:
            raise ValueError("Failed during bi-direction check.")
    else:
        bi_failed = False
        bi_failed_error = ""
        for cid in cells:
            ul_failed = False
            dl_failed = False
            try:
                logging.info("Start checking ul throughput in bi-direction check.")
                _validate_tput_values(ultp[str(cid)], ultarget_throughput,
                                      target_avg_percent, min_percent, str(cid))
            except ValueError as err:
                logging.exception(err)
                ul_failed = True
                bi_failed_error = "check ul failed on cell: {}.".format(cid)
            try:
                logging.info("Start checking dl throughput in bi-direction check.")
                _validate_tput_values(dltp[str(cid)], dltarget_throughput,
                                      target_avg_percent, min_percent, str(cid))
            except ValueError as err:
                logging.exception(err)
                dl_failed = True
                bi_failed_error = "check dl failed on cell: {}.".format(cid)
            if ul_failed or dl_failed:
                logging.exception("Failed during bi-direction check on cell: {}.".format(cid))
                bi_failed = True
        else:
            if bi_failed:
                raise ValueError(bi_failed_error)


def get_dl_aasyslog_tput(log, cells=None, actCarrierAggregation=False):
    record_output = {}
    if actCarrierAggregation:
        alias = "dlcatp{}".format(log)
        aatput.create_ca_downlink_throughput(
            cells=cells, log=log, alias=alias, throughput_records_output=record_output
        )
    else:
        alias = "dltp{}".format(log)
        aatput.create_downlink_throughput(
            cells=cells, log=log, alias=alias, throughput_records_output=record_output
        )
    aatput.analyze(throughputs=[alias])
    return aatput.get_throughput(throughput=alias), record_output


def get_ul_aasyslog_tput(log, cells=None, actCarrierAggregation=False):
    record_output = {}
    if actCarrierAggregation:
        alias = "ulcatp{}".format(log)
        aatput.create_ca_uplink_throughput(
            cells=cells, log=log, alias=alias, throughput_records_output=record_output
        )
    else:
        alias = "ultp{}".format(log)
        aatput.create_uplink_throughput(
            cells=cells, log=log, alias=alias, throughput_records_output=record_output
        )
    aatput.analyze(throughputs=[alias])
    return aatput.get_throughput(throughput=alias), record_output


def get_bi_direction_aasyslog_tput(log, cells=None, actCarrierAggregation=False):
    ul_record_output = {}
    dl_record_output = {}
    if actCarrierAggregation:
        ulalias = "ulcatp{}".format(log)
        dlalias = "dlcatp{}".format(log)
        aatput.create_ca_uplink_throughput(
            cells=cells, alias=ulalias, throughput_records_output=ul_record_output
        )
        aatput.create_ca_downlink_throughput(
            cells=cells, alias=dlalias, throughput_records_output=dl_record_output
        )
    else:
        ulalias = "ultp{}".format(log)
        dlalias = "dltp{}".format(log)
        aatput.create_uplink_throughput(
            cells=cells, alias=ulalias, throughput_records_output=ul_record_output
        )
        aatput.create_downlink_throughput(
            cells=cells, alias=dlalias, throughput_records_output=dl_record_output
        )
    aatput.analyze(throughputs=[ulalias, dlalias], log=log)
    ottp = {"ul": aatput.get_throughput(throughput=ulalias),
            "dl": aatput.get_throughput(throughput=dlalias)}
    return ottp, ul_record_output, dl_record_output


def get_aasyslog_throughput(direction, log, cells, actCarrierAggregation=False):
    direction = direction.lower()
    if direction == "ul":
        origin_tput, origin_record = get_ul_aasyslog_tput(
            log=log, cells=cells, actCarrierAggregation=actCarrierAggregation
        )
    elif direction == "dl":
        origin_tput, origin_record = get_dl_aasyslog_tput(
            log=log, cells=cells, actCarrierAggregation=actCarrierAggregation
        )
    else:
        raise AttributeError(
            "Wrong direction: {}, should be UL or DL.".format(direction)
        )
    return origin_tput, origin_record


def _validate_tput_values(tput, target_tput, target_avg_percent, min_percent, cell_id):
    min_tput = tput["minimum"]
    avg_tput = tput["average"]
    avg_percent = translate_percentage(target_avg_percent)
    min_percent = translate_percentage(min_percent)
    min_target = float(target_tput) * min_percent
    avg_target = float(target_tput) * avg_percent
    if avg_target < 0:
        avg_target = -avg_target
        logging.info(
            "Validating cell {} average throughput, should lower than {}Mbps ({}Mbps * {})".format(
                cell_id, avg_target, target_tput, avg_percent
            )
        )
        if not avg_tput <= avg_target:
            raise ValueError("AVG is {}Mbps, Higher than{}Mbps".format(avg_tput, avg_target))
        else:
            logging.info("AVG is {}Mbps, check pass.".format(avg_tput))
    else:
        logging.info(
            "Validating cell {} average throughput, should not lower than {}Mbps ({}Mbps * {})".format(
                cell_id, avg_target, target_tput, avg_percent
            )
        )
        if not avg_tput >= avg_target:
            raise ValueError("AVG is {}Mbps, lower than{}Mbps".format(avg_tput, avg_target))
        else:
            logging.info("AVG is {}Mbps, check pass.".format(avg_tput))
    if min_target < 0:
        min_target = -min_target
        logging.info("Validating cell {} minimum tput, should lower than {}Mbps ({}Mbps * min_percent)".format(
            cell_id, min_target, target_tput
        ))
        if not min_tput < min_target:
            raise ValueError("min is {}Mbps, higher than {}Mbps".format(min_tput, min_target))
        else:
            logging.info("min is {}Mbps, check pass.".format(min_tput))
    else:
        logging.info("Validating cell {} minimum tput, should not lower than {}Mbps ({}Mbps * min_percent)".format(
            cell_id, min_target, target_tput
        ))
        if not min_tput >= min_target:
            raise ValueError("min is {}Mbps, lower than {}Mbps".format(min_tput, min_target))
        else:
            logging.info("min is {}Mbps, check pass.".format(min_tput))


def __convert_mbps_to_bytes_with_time_interval(tput, time_interval):
    return float(tput) / 8 * 1000 * 1000 * float(time_interval)


def __convert_bytes_to_mbps_with_time_interval(tput, time_interval):
    return int(float(tput) * 8 / 1000 / 1000 / float(time_interval))


def _image_generation(direction, origin_record, actCarrierAggregation,
                      target_throughput, target_avg_percent, min_percent,
                      output_dir=None, customized_log_name=None, time_interval=1.024):
    logging.info("start image generation...")
    min_cnt = 99999
    rows = 1
    cols = 1

    validate_avg = float(target_throughput) * translate_percentage(target_avg_percent)
    validate_min = float(target_throughput) * translate_percentage(min_percent)
    if actCarrierAggregation:
        validate_avg = validate_avg / len(origin_record)
        validate_min = validate_min / len(origin_record)

    cells = list(dict.keys(origin_record))
    cells.sort()
    if len(cells) > 1:
        rows = 2
    fig = subplots.make_subplots(rows=rows, cols=cols,
                                 subplot_titles=('throughput on each cell', 'total throughput'))
    xlist = []
    for cid in cells:
        xlist, ylist = _get_pic_data(origin_list=origin_record[cid], time_interval=time_interval)
        trace = go.Scatter(
            x=xlist, y=ylist, mode='lines', name=cid
        )
        fig.add_trace(trace, 1, 1)
        if len(xlist) < min_cnt:
            min_cnt = len(xlist)
    validate_avg_line = go.Scatter(
        x=xlist, y=[validate_avg] * len(xlist),
        mode='lines', line=dict(dash='dashdot'), name='validate_avg'
    )
    fig.add_trace(validate_avg_line, 1, 1)
    validate_min_line = go.Scatter(
        x=xlist, y=[validate_min] * len(xlist),
        mode='lines', line=dict(dash='dashdot'), name='validate_min'
    )
    fig.add_trace(validate_min_line, 1, 1)

    if len(cells) > 1:
        xlist_general = xlist[0:min_cnt]
        ylist_general = _get_general_pic_data(origin_list=origin_record, count=min_cnt, time_interval=time_interval)
        trace_general = go.Scatter(
            x=xlist_general, y=ylist_general, mode='lines', name='general'
        )
        fig.add_trace(trace_general, 2, 1)
        validate_avg_general = validate_avg * len(cells)
        validate_min_general = validate_min * len(cells)
        validate_avg_general_line = go.Scatter(
            x=xlist_general, y=[validate_avg_general] * len(xlist_general),
            mode='lines', line=dict(dash='dashdot'), name='validate_avg_general'
        )
        fig.add_trace(validate_avg_general_line, 2, 1)
        validate_min_general_line = go.Scatter(
            x=xlist_general, y=[validate_min_general] * len(xlist_general),
            mode='lines', line=dict(dash='dashdot'), name='validate_min_general'
        )
        fig.add_trace(validate_min_general_line, 2, 1)

    date = xlist[0].split(".")[0]
    if actCarrierAggregation:
        _tmp_name = "[{date}]_{direction}.html".format(date=date, direction=direction)
    else:
        cell_id = cells[0]
        _tmp_name = "[{date}]_{cell_id}_{direction}.html".format(date=date, cell_id=cell_id, direction=direction)
    if customized_log_name:
        _tmp_name = customized_log_name + "_" + _tmp_name
    if output_dir:
        _tmp_name = os.path.abspath(output_dir + _tmp_name)

    fig.update_layout(
        yaxis1=dict(ticksuffix='Mbps'),
        yaxis2=dict(ticksuffix='Mbps'),
        title_text='Line chart of throughput'
    )
    py.plot(fig, filename=_tmp_name, auto_open=False)
    logging.info("Image {} generation finished...".format(_tmp_name))


def _get_pic_data(origin_list, time_interval):
    tput_list = []
    time_list = []
    for data in origin_list:
        tput = __convert_bytes_to_mbps_with_time_interval(tput=data['throughput'], time_interval=time_interval)
        tput_list.append(tput)
        time_list.append(data['record_time'])
    return time_list, tput_list


def _get_general_pic_data(origin_list, count, time_interval):
    general_tput_list = [0] * count
    cells = list(dict.keys(origin_list))
    for cnt in range(0, count):
        for cid in cells:
            tput = __convert_bytes_to_mbps_with_time_interval(
                tput=origin_list[cid][cnt]['throughput'], time_interval=time_interval
                )
            general_tput_list[cnt] = general_tput_list[cnt] + tput
    return general_tput_list
