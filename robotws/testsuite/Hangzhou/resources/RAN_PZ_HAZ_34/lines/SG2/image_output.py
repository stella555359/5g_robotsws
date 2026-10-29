# -*- coding: utf-8 -*-
"""
:author: Yu Lu
:contact: lu.1.yu@nokia-sbell.com
Please do not modify the file without notification to author
"""
import logging
import os
import plotly.offline as py
import plotly.graph_objs as go
from plotly import subplots
import time
import xlwt
from xml.dom.minidom import parse
import xml.dom.minidom


def image_output(lists, output_dir=None):
    """
    :param lists: (list) list of data.for example,[23,45,56,23,.....]
    :param output_dir: (str) image file output directory, if None, will use current dir.
    """
    logging.info("start image generation...")
    fig = subplots.make_subplots(rows=1, cols=1)
    trace = go.Scatter(y=lists, mode='lines')
    fig.add_trace(trace, 1, 1)

    data = time.asctime(time.localtime(time.time()))
    image_name = "the_line_chart_[{data}].html".format(data=data)
    if output_dir:
        image_name = os.path.abspath(output_dir + image_name)

    fig.update_layout(title_text='The line chart')

    py.plot(fig, filename=image_name, auto_open=False)
    logging.info("Image generation finished...")


def draw_curve(goal_data, output_dir=None):
    """
    :param goal_data: Data to be drawn.for example,the data should be a dictionary list,
    [{'MSG':'pdsch','item':'mcs','value':[25,26,27...]},{'MSG':'pdsch','item':'numOfDmrsCdmGroupWithoutData',
    'value':[1,2,2,2,2,1….]},{'MSG':'pdcch','item':'xxx','value':[23,34,56...]},{'MSG':'pusch2','item':'mcs1',
    'value':[25,26,27...]},…]
    MSG:picture name
    item:line name
    value:line data,same count
    :param output_dir: (str) image file output directory, if None, will use current dir.
    """
    logging.info("start image generation...")
    pic_value = 10
    pic_dict = plan_y_axis(org_data=goal_data, pic_value=pic_value)
    name_list = organize_data(org_data=goal_data)
    count = len(name_list)
    if count == 1:
        rows = 1
        cols = 1
        specs_list = [[{"secondary_y": True}]]
    elif count == 2:
        rows = 2
        cols = 1
        specs_list = [[{"secondary_y": True}], [{"secondary_y": True}]]
    else:
        rows = 2
        cols = 2
        specs_list = [[{"secondary_y": True}, {"secondary_y": True}], [{"secondary_y": True}, {"secondary_y": True}]]
    fig = subplots.make_subplots(rows=rows, cols=cols,
                                 subplot_titles=name_list,
                                 specs=specs_list)

    for image_name in name_list:
        if pic_dict[image_name] == 1:
            for data in goal_data:
                if data['MSG'] == image_name:
                    ylist = data['value']
                    ylist_avg = get_avg(ylist)
                    if ylist_avg <= pic_value:
                        trace = go.Scatter(
                            y=ylist, mode='lines', name=data['item']
                        )
                        if name_list.index(image_name) == 0:
                            fig.add_trace(trace, 1, 1, secondary_y=False)
                        if name_list.index(image_name) == 1:
                            fig.add_trace(trace, 2, 1, secondary_y=False)
                        if name_list.index(image_name) == 2:
                            fig.add_trace(trace, 1, 2, secondary_y=False)
                        if name_list.index(image_name) == 3:
                            fig.add_trace(trace, 2, 2, secondary_y=False)
                    else:
                        trace = go.Scatter(
                            y=ylist, mode='lines+markers', name=data['item']
                        )
                        if name_list.index(image_name) == 0:
                            fig.add_trace(trace, 1, 1, secondary_y=True)
                        if name_list.index(image_name) == 1:
                            fig.add_trace(trace, 2, 1, secondary_y=True)
                        if name_list.index(image_name) == 2:
                            fig.add_trace(trace, 1, 2, secondary_y=True)
                        if name_list.index(image_name) == 3:
                            fig.add_trace(trace, 2, 2, secondary_y=True)
        else:
            for data in goal_data:
                if data['MSG'] == image_name:
                    ylist = data['value']
                    trace = go.Scatter(
                        y=ylist, mode='lines', name=data['item']
                    )
                    if name_list.index(image_name) == 0:
                        fig.add_trace(trace, 1, 1, secondary_y=False)
                    if name_list.index(image_name) == 1:
                        fig.add_trace(trace, 2, 1, secondary_y=False)
                    if name_list.index(image_name) == 2:
                        fig.add_trace(trace, 1, 2, secondary_y=False)
                    if name_list.index(image_name) == 3:
                        fig.add_trace(trace, 2, 2, secondary_y=False)

    data = time.asctime(time.localtime(time.time()))
    _tmp_name = "{name_list}_curve_[{data}].html".format(name_list=name_list, data=data)
    if output_dir:
        _tmp_name = os.path.abspath(output_dir + _tmp_name)

    fig.update_layout(
        title_text='Different MSG Curves'
    )
    py.plot(fig, filename=_tmp_name, auto_open=False)
    logging.info("Image generation finished...")

    logging.info("start write excel...")
    excel_name = "{name_list}_curve_data_[{data}].xls".format(name_list=name_list, data=data)
    if output_dir:
        excel_name = os.path.abspath(output_dir + excel_name)
    write_excel(goal_data=goal_data, excel_name=excel_name)
    logging.info("write excel finished...")


def organize_data(org_data):
    logging.info("start organize data...")
    name_list = []
    for data in org_data:
        name_list.append(data['MSG'])
    name_list = list(set(name_list))
    logging.info("organize data finished...")
    return name_list


def plan_y_axis(org_data, pic_value):
    logging.info("start plan_y_axis...")
    name_list = organize_data(org_data=org_data)
    pic_dict = {}
    for image_name in name_list:
        pic_list = []
        for data in org_data:
            over_pic = 0
            if data['MSG'] == image_name:
                avg = get_avg(data['value'])
                if avg >= pic_value:
                    over_pic = 1
                pic_list.append(over_pic)
        if len(pic_list) == 1:
            y_axis = 0
        elif len(pic_list) > 1 and sum_list(pic_list) >= 1:
            y_axis = 1
        else:
            y_axis = 0
        pic_dict[image_name] = y_axis
    logging.info("plan_y_axis finished...")
    return pic_dict


def get_avg(list_data):
    logging.info("start get_avg...")
    list_sum = 0
    for data in list_data:
        list_sum += data
    logging.info("get_avg finished...")
    return int(list_sum / len(list_data))


def sum_list(list_data):
    logging.info("start list_data...")
    list_sum = 0
    for data in list_data:
        list_sum += data
    logging.info("list_data finished...")
    return list_sum


def write_excel(goal_data, excel_name):
    w = xlwt.Workbook()
    ws = w.add_sheet('Curve data')
    col = 0
    for data in goal_data:
        ws.write(0, col, data['MSG'])
        ws.write(1, col, data['item'])
        for cont in range(0, len(data['value'])):
            ws.write(cont+2, col, data['value'][cont])
        col = col + 1
    w.save(excel_name)
