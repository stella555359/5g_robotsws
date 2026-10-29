import openpyxl
from openpyxl.styles import PatternFill, Font, Alignment, Border, Side
from openpyxl.styles.borders import BORDER_THICK, BORDER_THIN


def create_workbook():
    wb = openpyxl.Workbook()
    return wb


def load_workbook(file_name):
    wb = openpyxl.load_workbook(file_name)
    return wb


def get_active_worksheet_title(workbook):
    ws = workbook.active
    return ws.title


def append_to_worksheet(workbook, worksheet_title, row):
    ws = workbook[worksheet_title]
    ws.append(row)


def save_workbook(workbook, file_name):
    workbook.save(file_name)


def write_column_to_excel(file_name, start_cell, data):
    try:
        wb = openpyxl.load_workbook(file_name)
    except FileNotFoundError:
        wb = openpyxl.Workbook()

    ws = wb.active

    start_row = openpyxl.utils.cell.coordinate_from_string(start_cell)[1]
    start_col = openpyxl.utils.cell.coordinate_from_string(start_cell)[0]

    for i, value in enumerate(data):
        ws.cell(row=start_row + i, column=openpyxl.utils.column_index_from_string(start_col), value=value)

    wb.save(file_name)


def merge_cells_if_equal(file_name, column_letter):
    wb = openpyxl.load_workbook(file_name)
    ws = wb.active

    column_cells = ws[column_letter]

    start_row = None
    end_row = None
    previous_value = None

    for cell in column_cells:
        current_value = cell.value
        if current_value == previous_value:
            if start_row is None:
                start_row = cell.row - 1
            end_row = cell.row
        else:
            if start_row is not None and end_row is not None and start_row != end_row:
                ws.merge_cells(f"{column_letter}{start_row}:{column_letter}{end_row}")
            start_row = cell.row
            end_row = None
        previous_value = current_value

    # check last merge cells
    if start_row is not None and end_row is not None and start_row != end_row:
        ws.merge_cells(f"{column_letter}{start_row}:{column_letter}{end_row}")

    wb.save(file_name)


def increment_column_letter(col_letter, increment):
    new_col_letter = chr(ord(col_letter) + increment)
    return new_col_letter


def set_excel_header(file_name):
    wb = openpyxl.load_workbook(file_name)
    ws = wb.active

    header_fill = PatternFill(start_color='666666', end_color='666666', fill_type='solid')  # color background
    header_font = Font(color='FFFFFF')  # white color
    header_alignment = Alignment(horizontal='center', vertical='center')
    ws.row_dimensions[1].height = 30
    ws.column_dimensions['A'].width = 12
    ws.column_dimensions['B'].width = 30
    ws.column_dimensions['C'].width = 10
    ws.column_dimensions['D'].width = 10
    ws.column_dimensions['E'].width = 10
    ws.column_dimensions['F'].width = 10

    for cell in ws[1]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = header_alignment

    wb.save(file_name)


def set_excel_border(file_name):
    wb = openpyxl.load_workbook(file_name)
    ws = wb.active

    # header style
    thick_border = Border(
        left=Side(style=BORDER_THICK),
        right=Side(style=BORDER_THICK),
        top=Side(style=BORDER_THICK),
        bottom=Side(style=BORDER_THICK)
    )

    # data style
    thin_border = Border(
        left=Side(style=BORDER_THIN),
        right=Side(style=BORDER_THIN),
        top=Side(style=BORDER_THIN),
        bottom=Side(style=BORDER_THIN)
    )

    header = ws[1]
    # set header cell style
    for col_idx, value in enumerate(header, start=1):
        cell = ws.cell(row=1, column=col_idx)
        cell.border = thick_border
        cell.alignment = Alignment(wrap_text=True, horizontal='center', vertical='center')

    rows = ws['A']

    # set data cell style
    for row_idx, row in enumerate(rows[1:], start=2):  # data begin from row 2
        for col_idx, value in enumerate(header, start=1):
            cell = ws.cell(row=row_idx, column=col_idx)
            cell.border = thin_border

    wb.save(file_name)


def set_excel_background(file_name, column_start=1, column_end=3):
    wb = openpyxl.load_workbook(file_name)
    ws = wb.active

    # define color fill
    fill_olive_green = PatternFill(start_color="E4D6FC", end_color="E4D6FC", fill_type="solid")
    fill_pink = PatternFill(start_color="F9D7F4", end_color="F9D7F4", fill_type="solid")
    fill_orange = PatternFill(start_color="FDE4D5", end_color="FDE4D5", fill_type="solid")
    fill = [fill_olive_green, fill_pink, fill_orange]

    # max row
    max_row = ws.max_row
    color_index = 0

    # check from second row to the last row
    for row in range(2, max_row):
        first_cell_current_row = ws.cell(row=row, column=1).value
        first_cell_next_row = ws.cell(row=row + 1, column=1).value
        # print(first_cell_current_row, first_cell_next_row)

        is_merged = any(ws.cell(row=row + 1, column=1).coordinate in merged_range
                        for merged_range in ws.merged_cells.ranges)

        # compare the first 6 characters of the first cell of the current row and the next row
        if (is_merged and (first_cell_next_row is None or first_cell_current_row is None)
                or first_cell_current_row is not None and first_cell_next_row is not None
                and first_cell_current_row[:6] == first_cell_next_row[:6]):
            # fill color for the same cell
            for col in range(column_start, column_end + 1):
                ws.cell(row=row, column=col).fill = fill[color_index % len(fill)]
                ws.cell(row=row + 1, column=col).fill = fill[color_index % len(fill)]
        else:
            color_index += 1

    wb.save(file_name)


# set_excel_header("power_measure.xlsx")
