import socket


tl_name = socket.gethostname().replace('-', '_')

threshold_1013 = {
    '7_16_UTE5G286CLASS041': {
        '1_5G': [0, 30],
        '2_5G': [0, 30],
        '1_LTE': 90,
        '2_LTE': 7},
    '7_16_UTE5GCLOUDT151': {
        '1_5G': [0, 5],
        '2_5G': [0, 5],
        '1_LTE': 90,
        '2_LTE': 20},
    '7_16_UTE5GCLOUDT161': {
        '1_5G': [0, 30],
        '2_5G': [0, 30],
        '1_LTE': 0,
        '2_LTE': 0},
    '7_16_UTE5GCLOUDT175': {
        '1_5G': [40, 57],
        '2_5G': [0],
        '1_LTE': 21,
        '2_LTE': 90},
    '7_16_UTE5GCLOUDT152': {
        '1_5G': [0, 8],
        '2_5G': [0, 8],
        '1_LTE': 0,
        '2_LTE': 0}
}

try:
    att_values = threshold_1013[tl_name]
except KeyError as error:
    print("There are no thresholds for this TL:", error)
