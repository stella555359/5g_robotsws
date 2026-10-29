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


aatput = aasyslog_throughput()


__all__ = ["check_aasyslog_throughput", "check_bi_aasyslog_throughput", "get_aasyslog_throughput"]


def check_aasyslog_throughput(direction, log, cells, target_throughput,
                              target_avg_percent=0.95, min_percent=0.85, actCarrierAggregation=False,
                              output_dir=None):
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
    tput = _transfer_tput_format(origin_tput)
    logging.info("Getting origin tput result: {}".format(origin_tput))
    try:
        _image_generation(
            direction=direction,
            origin_record=origin_record,
            actCarrierAggregation=actCarrierAggregation,
            target_throughput=target_throughput,
            target_avg_percent=target_avg_percent,
            output_dir=output_dir,
            min_percent=min_percent
        )
    except Exception as err:
        logging.info("Can't generate {} image. {}".format(direction, err))
    if actCarrierAggregation:
        _validate_tput_values(tput[None], target_throughput,
                              target_avg_percent, min_percent)
    else:
        cell_failed = False
        error_print = []
        for cid in cells:
            try:
                _validate_tput_values(tput[str(cid)], target_throughput,
                                      target_avg_percent, min_percent)
            except ValueError as err:
                logging.error("failed on Cell:{}, err: {}".format(cid, err))
                error_print.append(err)
                cell_failed = True
        else:
            if cell_failed:
                raise ValueError("Failed during checking all cell. Errors below:\n{}".format(
                    "\n".join(error_print)
                ))


def check_bi_aasyslog_throughput(log, cells, ultarget_throughput, dltarget_throughput,
                                 target_avg_percent=0.95, min_percent=0.85, actCarrierAggregation=False,
                                 output_dir=None):
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
    ultp = _transfer_tput_format(origin_tput["ul"])
    dltp = _transfer_tput_format(origin_tput["dl"])
    logging.info("Getting origin tput result: {}".format(origin_tput))
    try:
        _image_generation(
            direction='ul',
            origin_record=ul_origin_record,
            actCarrierAggregation=actCarrierAggregation,
            target_throughput=ultarget_throughput,
            target_avg_percent=target_avg_percent,
            output_dir=output_dir,
            min_percent=min_percent
        )
    except Exception as err:
        logging.info("Can't generate UL image. {}".format(err))
    try:
        _image_generation(
            direction='dl',
            origin_record=dl_origin_record,
            actCarrierAggregation=actCarrierAggregation,
            target_throughput=dltarget_throughput,
            target_avg_percent=target_avg_percent,
            output_dir=output_dir,
            min_percent=min_percent
        )
    except Exception as err:
        logging.info("Can't generate DL image. {}".format(err))
    if actCarrierAggregation:
        ul_failed = False
        dl_failed = False
        try:
            logging.info("Start checking ul throughput in bi-direction check.")
            _validate_tput_values(ultp[None], ultarget_throughput,
                                  target_avg_percent, min_percent)
        except ValueError as err:
            logging.error(err)
            ul_failed = True
        try:
            logging.info("Start checking dl throughput in bi-direction check.")
            _validate_tput_values(dltp[None], dltarget_throughput,
                                  target_avg_percent, min_percent)
        except ValueError as err:
            logging.error(err)
            dl_failed = True
        if ul_failed or dl_failed:
            raise ValueError("Failed during bi-direction check.")
    else:
        bi_failed = False
        for cid in cells:
            ul_failed = False
            dl_failed = False
            try:
                logging.info("Start checking ul throughput in bi-direction check.")
                _validate_tput_values(ultp[cid], ultarget_throughput,
                                      target_avg_percent, min_percent)
            except ValueError as err:
                logging.error(err)
                ul_failed = True
            try:
                logging.info("Start checking dl throughput in bi-direction check.")
                _validate_tput_values(dltp[cid], dltarget_throughput,
                                      target_avg_percent, min_percent)
            except ValueError as err:
                logging.error(err)
                ul_failed = True
            if ul_failed or dl_failed:
                logging.error("Failed during bi-direction check on cell: {}.".format(cid))
                bi_failed = True
        else:
            if bi_failed:
                raise ValueError("Failed during bi_direction check.")


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


def _transfer_tput_format(origin_tput):
    translated = {}
    for data in origin_tput:
        translated[data["cellid"]] = data
    return translated


def _translate_percentage(origin_percent):
    percent = str(origin_percent)
    if "%" in percent:
        target_percent = float(percent.replace("%", "")) / 100.0
    else:
        target_percent = float(percent)
    return target_percent


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


def _validate_tput_values(tput, target_tput, target_avg_percent, min_percent):
    min_tput = tput["minimum"]
    avg_tput = tput["average"]
    avg_percent = _translate_percentage(target_avg_percent)
    min_percent = _translate_percentage(min_percent)
    min_target = float(target_tput) * min_percent
    avg_target = float(target_tput) * avg_percent
    logging.info(
        "Validating average throughput, should not lower than {}Mbps ({}Mbps * {})".format(
            avg_target, target_tput, avg_percent
        )
    )
    if not avg_tput >= avg_target:
        raise ValueError("AVG is {}Mbps, lower than{}Mbps".format(avg_tput, avg_target))
    else:
        logging.info("AVG is {}Mbps, check pass.".format(avg_tput))
    logging.info("Validating minimum throughput, should not lower than {}Mbps ({}Mbps * min_percent)".format(
        min_target, target_tput
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
                      target_throughput, target_avg_percent, min_percent, output_dir=None):
    logging.info("start image generation...")
    min_cnt = 99999
    rows = 1
    cols = 1

    validate_avg = float(target_throughput) * _translate_percentage(target_avg_percent)
    validate_min = float(target_throughput) * _translate_percentage(min_percent)
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
        xlist, ylist = _get_pic_data(origin_list=origin_record[cid])
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
        ylist_general = _get_general_pic_data(origin_list=origin_record, count=min_cnt)
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
    if output_dir:
        _tmp_name = "_[{date}]_{direction}.html".format(date=date, direction=direction)
        image_name = os.path.abspath(output_dir + _tmp_name)
    else:
        image_name = date + '_' + direction + '.html'

    fig.update_layout(
        yaxis1=dict(ticksuffix='Mbps'),
        yaxis2=dict(ticksuffix='Mbps'),
        title_text='Line chart of throughput'
    )
    py.plot(fig, filename=image_name, auto_open=False)
    logging.info("Image generation finished...")


def _get_pic_data(origin_list):
    tput_list = []
    time_list = []
    for data in origin_list:
        tput = __convert_bytes_to_mbps_with_time_interval(tput=data['throughput'], time_interval=1.024)
        tput_list.append(tput)
        time_list.append(data['record_time'])
    return time_list, tput_list


def _get_general_pic_data(origin_list, count):
    general_tput_list = [0] * count
    cells = list(dict.keys(origin_list))
    for cnt in range(0, count):
        for cid in cells:
            tput = __convert_bytes_to_mbps_with_time_interval(
                tput=origin_list[cid][cnt]['throughput'], time_interval=1.024
                )
            general_tput_list[cnt] = general_tput_list[cnt] + tput
    return general_tput_list
