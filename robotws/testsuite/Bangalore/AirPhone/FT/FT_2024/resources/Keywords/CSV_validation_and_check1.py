import csv


def check_message_in_columns(file_path, column1, column2, column3, message):
    with open(file_path, mode='r', newline='') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if row[column1] == message or row[column2] == message or row[column3] == message:
                print(f"Message '{message}' found in row: {row}")
                return True
    print(f"Message '{message}' not found in columns '{column1}' or '{column2}' or '{column3}.")
    return False


# comment body
if __name__ == "__main__":
    #    file_path = '/home/ute/logs/Make_L3_SA_call/gNB/biptaf/TestCase_7103A/'  # Replace with your CSV file path
    #    column1 = 'UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag'
    #     Replace with the name of the first column to check
    #    column2 = 'UlData_puschReceiveReqGrant_t.mcs'  # Replace with the name of the second column to check
    #    message = [1]  # Replace with the message you want to check

    check_message_in_columns(file_path, column1, column2, column3, message)
