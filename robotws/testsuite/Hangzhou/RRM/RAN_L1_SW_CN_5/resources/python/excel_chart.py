#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
:author: Shenrao
:contact: shengrong.rao@nokia-sbell.com
:Description: wirte date to excel and draw chart.

"""
import os
from openpyxl import Workbook
from openpyxl import load_workbook
from openpyxl.chart import (
    LineChart,
    Reference,
    BarChart,
    Series
)


def create_excel_xlsx(filepath):
    """
    creat excel.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx

    """
    wb = Workbook()
    wb.save(filepath)


def create_newsheet(filepath, sheet, index=None):
    """
    creat newsheet.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    :param index: index should be number,default is None(insert at the end), index=0 mean insert at the first location.

    """
    if index:
        index = int(index)
    if os.path.exists(filepath):
        wb = load_workbook(filepath)
        sheet_names = wb.sheetnames
        if (sheet in sheet_names):
            raise TypeError("Created failed, sheet name existed.")
        else:
            ws = wb.create_sheet(sheet, index)
            wb.save(filepath)
    else:
        wb = Workbook()
        ws = wb.create_sheet(sheet, index)
        wb.save(filepath)


def remove_sheet(filepath, sheet):
    """
    remove sheet.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    wb.remove(ws)
    wb.save(filepath)


def copy_sheet(filepath, source_sheet, target_sheet):
    """
    copy sheet.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param source_sheet: source sheet name.
    :param target_sheet: target sheet name.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(source_sheet)
    target_sheet = wb.copy_worksheet(ws)
    wb.save(filepath)


def modify_sheetname(filepath, sheet, newname):
    """
    modify sheet name.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: source sheet name.
    :param newname: newsheet name.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    ws.title = newname
    wb.save(filepath)


def get_sheet_names(filepath):
    """
    get all sheet names.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx

    """
    wb = load_workbook(filepath)
    sheet_names = wb.sheetnames
    return sheet_names


def save_excel_xlxs(filepath):
    """
    save excel.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx

    """
    wb = load_workbook(filepath)
    wb.save(filepath)


def get_colNum(filepath, sheet='Sheet'):
    """
    get colnum of selected sheet, return min and max number.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    colNum_max = ws.max_column
    colNum_min = ws.min_column
    return colNum_max, colNum_min


def get_rowNum(filepath, sheet='Sheet'):
    """
    get row of selected sheet, return min and max number.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    rowNum_max = ws.max_row
    rowNum_min = ws.min_row
    return rowNum_max, rowNum_min


def get_CellValue(filepath, sheet, row, column):
    """
    get cell vaule based on row and column.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    :param row: int type, which row.
    :param column: int type, which column.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    cellvalue = ws.cell(row=int(row), column=int(column)).value
    return cellvalue


def get_Column_Values(filepath, sheet, column):
    """
    get all values of selected column.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    :param column: int type, selected column.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    rows = ws.max_row
    column_data = []
    for i in range(1, rows + 1):
        cellvalue = ws.cell(row=i, column=int(column)).value
        if cellvalue is not None:
            column_data.append(cellvalue)
    return column_data


def get_Row_Values(filepath, sheet, row):
    """
    get all values of selected row.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    :param row: int type, selected row.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    columns = ws.max_column
    row_data = []
    for i in range(1, columns + 1):
        cellvalue = ws.cell(row=int(row), column=i).value
        if cellvalue is not None:
            row_data.append(cellvalue)
    return row_data


def wirte_data_to_excel(filepath, sheet, row, column, value):
    """
    wirte data to excel based on row and column.
    :param filepath: path of excel. eg. /home/ute/excel.xlsx
    :param sheet: sheet name.
    :param row: int type, which row.
    :param column: int type, which column.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    ws.cell(row=int(row), column=int(column), value=value)
    wb.save(filepath)


def draw_chart(filepath, sheet, min_row, max_row, min_column,
               max_column, title, location, series_num=0):
    """
    select the row and column which you want to draw line chart.

    :param sheet: sheet name.
    :param min_row: start of row which you will draw chart.
    :param max_row: end of row which you will draw chart.
    :param min_column: start of column which you will draw chart.
    :param max_column: end of column which you will draw chart.
    :param title: title of chart.
    :param location: the location of chart in sheet. eg. "H20".
    :param series_num: number of smooth line handle, it should be <= max_column - min_column.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    c1 = LineChart()
    c1.title = title
    c1.style = 13
    c1.y_axis.title = 'size'
    c1.x_axis.title = 'number'
    data = Reference(
        ws,
        min_col=int(min_column),
        min_row=int(min_row),
        max_col=int(max_column),
        max_row=int(max_row))
    c1.add_data(data, titles_from_data=True)
    # Style the lines
    s2 = c1.series[int(series_num)]
    s2.smooth = True  # Make the line smooth
    ws.add_chart(c1, location)
    wb.save(filepath)


def draw_bar_chart(filepath, sheet, min_row, max_row,
                   min_column, max_column, title, location, style='10'):
    """
    select the row and column which you want to draw bar chart.

    :param sheet: sheet name.
    :param min_row: start of row which you will draw bar chart.
    :param max_row: end of row which you will draw bar chart.
    :param min_column: start of column which you will draw bar chart.
    :param max_column: end of column which you will draw bar chart.
    :param title: title of chart.
    :param location: the location of chart in sheet. eg. "H20".
    :param style: style of colour.

    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    c1 = BarChart()
    c1.title = title
    c1.type = "col"
    c1.style = style
    c1.y_axis.title = 'size'
    c1.x_axis.title = 'number'
    data = Reference(
        ws,
        min_col=int(min_column),
        min_row=int(min_row),
        max_col=int(max_column),
        max_row=int(max_row))
    c1.add_data(data, titles_from_data=True)
    c1.sharp = 4
    ws.add_chart(c1, location)
    wb.save(filepath)
