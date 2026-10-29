import taf.sbts.oam.coam.admin
import csv


def get_temperature_value():
    with open('./temperature.csv',  mode='r') as csvfile:
        csv_reader = csv.reader(csvfile, delimiter=';', quotechar='|')
        for row in csv_reader:
            current_temperature_float = float(row[1])
    return current_temperature_float
