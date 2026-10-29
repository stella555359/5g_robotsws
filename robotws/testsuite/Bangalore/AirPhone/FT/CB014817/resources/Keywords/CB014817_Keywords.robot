** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Deepthi A
                 ...              :contact      : deepthi.a@nokia.com
                 ...              :Description  : Contains Keyword needed for CB014817
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,10.08.2025,deepthi.a@nokia.com

Resource    ../../../resources/Keywords/general_common_keywords.robot



*** Keywords ***
L3 Suite Setup
     Log to console      "suite setup"

L3 Suite Teardown
     Log to console      "suite teardown"

UE Register and PDU Session
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

#TC for NG HO
Attach UE to RANSIM
    	 Exe egate cmd         cmd=${UE_LOC_UPDATE}
         sleep       5
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE_LOC_CHANGE}
        ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
	     Exe egate cmd         cmd=${SEND_SIB1_TO_RANSIM}
         sleep       5
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
        ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    	 Exe egate cmd         cmd=${SEND_SIB2_TO_RANSIM}
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB2}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    	 Exe egate cmd         cmd=${SEND_SIB5_TO_RANSIM}
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB5}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    	 Exe egate cmd         cmd=${SEND_UE_HISTORY_INFO}          return_output=False
    	 Exe egate cmd         cmd=${COMMIT_UE_HISTORY_INFO}
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE_HISTORY_COMMIT}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

#TC for XN HO
Attach UE to RANSIM XN
    	 Exe egate cmd         cmd=${UE_LOC_UPDATE_XN}
         sleep       5
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE_LOC_CHANGE_XN}
        ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
	     Exe egate cmd         cmd=${SEND_SIB1_TO_RANSIM_XN}          return_output=False
         sleep       10
        Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
       ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    	 Exe egate cmd         cmd=${SEND_SIB2_TO_RANSIM_XN}
         sleep       10
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB2_XN}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    	 Exe egate cmd         cmd=${SEND_SIB5_TO_RANSIM_XN}
        sleep       10
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB5_XN}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    	 Exe egate cmd         cmd=${SEND_UE_HISTORY_INFO_XN}          return_output=False
    	 Exe egate cmd         cmd=${COMMIT_UE_HISTORY_INFO_XN}
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE_HISTORY_COMMIT}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
         Exe egate cmd         cmd= ${UE_HISTORY_INFO} 	           return_output=False
Send DL Data
	     Exe egate cmd         cmd=${DL_DATA}

Send UL Data
	     Exe egate cmd         cmd=${UL_DATA}

Configure sourceSCG-NR-Config in HO preparation msg
	     Exe egate cmd         cmd=${HO_PREPARATION}

Configure sourceSCG-Config in HO preparation msg
         Exe egate cmd         cmd=${HO_PREPARATION_no_nr}

Configure source_scg_eutra_config in HO preparation msg
         Exe egate cmd         cmd=${HO_PREPARATION_EUTRA}               return_output=False
Trigger NG-HO
	     Exe egate cmd         cmd=${CHECK MEAS REPORT}
	     Exe egate cmd         cmd=${TRIGGER HO}
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_INTER_GNB_HO}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Configure sourceSCG-NR-Config in HO preparation msg XNHO
	     Exe egate cmd         cmd=${HO_PREPARATION_XN}            return_output=False

Configure sourceSCG-Config in HO preparation msg XNHO
         Exe egate cmd         cmd=${HO_PREPARATION_no_nr_XN}               return_output=False

Configure source_scg_eutra_config in HO preparation msg XNHO
         Exe egate cmd         cmd=${HO_PREPARATION_EUTRA_XN}               return_output=False
Trigger XNHO
	     Exe egate cmd         cmd=${CHECK MEAS REPORT XN}
	     Exe egate cmd         cmd=${TRIGGER HO XN}
         Validate     log=${L_EGATE_CONSOLE}      element=${VAL_INTER_GNB_HO_XN}
         ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Deregister UE
         Exe egate cmd         cmd=${UE_DEREGISTER}

Create Interface for XN HO
    Run    sudo ip addr add 10.0.1.3/24 dev eth3

Delete Interface for XN HO
    Run    sudo ip addr del 10.0.1.3/24 dev eth3

Create Interface for NG HO
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
Delete Interface for NG HO
    Run    sudo ip addr del 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
