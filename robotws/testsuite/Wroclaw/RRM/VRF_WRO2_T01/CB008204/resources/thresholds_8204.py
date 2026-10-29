import socket


tl_name = socket.gethostname().replace('-', '_')

threshold_8204 = {
    '7_16_UTE5GCLOUD1': 35,
    '7_16_UTE5G286CLASS041': 35,
    '7_16_UTE5GCLOUDT151': 35,
    '7_16_UTE5GCLOUDT161': 35,
    'ute_image10': [35, 60],
}

try:
    att_value = threshold_8204[tl_name]
except KeyError as error:
    print("There are no thresholds for this TL:", error)
