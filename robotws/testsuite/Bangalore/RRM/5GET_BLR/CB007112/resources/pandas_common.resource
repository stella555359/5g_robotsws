*** Settings ***
Documentation     [SUITE PURPOSE]  Common keyword of CB007112 feature
...               Prerequisite :
...               Scope : keywords for CB007112

# Library           taf.gnb.oam.coam.admin   WITH NAME   coam
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim           WITH NAME    wts
Library           ../../resources/python/PandasCsv.py

Resource          ../../resources/robot/Sherpa.robot



*** Variables ***

#Variables for TC 5GC001227-A-B6 CsirsPoolingGroupId check
@{FIELDS_cell_cellsetupreq}              physCellId     csirsPoolingGroupId

#Variables for TC 5GC001227-A-B5 PRB limitation check
${csv_file_name_dlStat}     macro__dlStat.csv
${csv_file_name_ulStat}     macro__ulStat.csv
${expected_MAX_PRB_DL}         106
${expected_MAX_PRB_UL}         94
${operator_compare}            >=
${column_name}              MAX PRB


${l1l2_csv_file_name}                 micro__l1l2Trace.csv
${DL_Pooling_Sherpa_Msg}              Dl PrbPoolingAllocationReport
${UL_Pooling_Sherpa_Msg}              Ul PrbPoolingAllocationReport
${DL_Pooling_Csv_Extracted}           Dl_PrbPoolingAllocationReport_45_.csv
${UL_Pooling_Csv_Extracted}           Ul_PrbPoolingAllocationReport_45_.csv
${DL_MinPrb_Expected}                 48
${UL_MinPrb_Expected}                 36

#Variables for TC 5GC001227-A-B8-B9 Round Robin check
@{UL_Pooling_Report}      Ul PrbPoolingAllocationReport(45)
@{DL_Pooling_Report}      Dl PrbPoolingAllocationReport(45)
${Regexp_UL_Subcell0_Selected}       (Type.UL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.67).*
${Regexp_UL_Subcell1_Selected}       (Type.UL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.67).*
${Regexp_UL_Subcell0_NoSelected}     (Type.UL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.36).*
${Regexp_UL_Subcell1_NoSelected}     (Type.UL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.36).*
${Regexp_DL_Subcell0_Selected}       (Type.DL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.106).*
${Regexp_DL_Subcell1_Selected}       (Type.DL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.106).*
${Regexp_DL_Subcell0_NoSelected}     (Type.DL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.101).*
${Regexp_DL_Subcell1_NoSelected}     (Type.DL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.101).*

#Variables for TC 5GC001227-B Metric Based checks

*** Keywords ***
Calling Panda Extract Csv function
      ${file_path_micro_l1l2} =      set variable    ${sherpa_output_path}/tcpdump/micro__l1l2Trace.csv
      BuiltIn.Log    ${file_path_micro_l1l2}
      PandasCsv.Setup Reader     ${file_path_micro_l1l2}    # Load data from a csv file using pandas library
      PandasCsv.extract_cvs_files_forcolumn    filter_column=TEXT    by_value=MSGID    filter=PrbPoolingAllocationReport(45)
      ...                                      list_grp=None    csv_sep=;
      PandasCsv.extract_cvs_files_forcolumn    filter_column=TEXT    by_value=MSGID    filter=PrbPoolingAllocationSubpool(45)
      ...                                      list_grp=None    csv_sep=;
      PandasCsv.extract_cvs_files_forcolumn    filter_column=TEXT    by_value=MSGID    filter=PdschSendReq
      ...                                      list_grp=None    csv_sep=;
      PandasCsv.extract_cvs_files_forcolumn    filter_column=TEXT    by_value=MSGID    filter=PdcchSendReq
      ...                                      list_grp=None    csv_sep=;
      PandasCsv.extract_cvs_files_forcolumn    filter_column=TEXT    by_value=MSGID    filter=Dl PdcchSendReq(29)
      ...                                      list_grp=None    csv_sep=;
      PandasCsv.extract_cvs_files_forcolumn    filter_column=TEXT    by_value=MSGID    filter=PuschReceiveReq
      ...                                      list_grp=None    csv_sep=;
      PandasCsv.extract_cvs_files_forcolumn    filter_column=TEXT    by_value=MSGID    filter=CsiRsSendReqEvent(13)
      ...                                      list_grp=None    csv_sep=;

Extract Panda Csv Based On Filter
    [Documentation]                 Extract CSV file based on filters
    [Arguments]                     ${filter_dict}
    Dated Log                       Loading csv file : ${filter_dict.sherpa_csv_file_name}
    PandasCsv.Setup Reader          ${filter_dict.sherpa_csv_file_name}
    PandasCsv.extract_cvs_files_forcolumn       filter_column=${filter_dict.filter_column_name}
    ...                                         by_value=${filter_dict.filter_by_value}
    ...                                         filter=${filter_dict.filter}
    ...                                         list_grp=None
    ...                                         csv_sep=${filter_dict.separator}

Verify MinPrbAlloc in Sherpa Pooling Report
    [Documentation]         To check the minimum PRB allocation in sherpa traces after the cell setup with poolin feature activated
    [Arguments]             ${sherpa_pooling_msgId}
    ...                     ${extracted_csv_filename}
    ...                     ${expected_value}
    Dated Log        SherpaPoolingReport msgId : ${sherpa_pooling_msgId}
    &{dict_csv_filter}      Create Dictionary
    ...                     sherpa_csv_file_name=${sherpa_output_path}/tcpdump/${l1l2_csv_file_name}
    ...                     filter_column_name=TEXT
    ...                     filter_by_value=MSGID
    ...                     filter=${sherpa_pooling_msgId}
    ...                     sherpa_event_id=45
    ...                     aseparator=;

    Extract Panda Csv Based On Filter       ${dict_csv_filter}
    Dated Log       extracted csv file name : ${extracted_csv_filename}
    Dated Log       expected min PRB value : ${expected_value}
    ${found}                Sherpa.Verify value with operator in csv Files      CsvName=${extracted_csv_filename}
    ...                     ColumnName=NumMinPrbAlloc                           valuetocheck=${expected_value}
    ...                     check_operator===                                   directory=${sherpa_output_path}
    Should be equal         "${found}"                                          "True"

