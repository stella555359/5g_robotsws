<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2019-01-25 15:53:23 by AirMosaic LTE Uu 7.5.0RC10 (Build 201812180944)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" DetachShutdown="false" Annotation="" GlobalVariables="" cellbinding="" AppVersion="AirMosaic LTE Uu 7.5.0RC10 (Build 201812180944)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0">
      <record name="Bearer 0" modifiable="true">
        <String name="instance" value="Bearer 0" />
        <Boolean name="Mandatory" value="false" />
        <Double name="SuccessPercentage" value="100.0" />
        <String name="QCI_MODE" value="Standard 3GPP QCI" />
        <String name="REQ_QCI" value="9" />
        <Integer name="OP_QCI" value="128" />
        <Object name="TFA" value="20" />
        <link name="REQ_MAX_BR_UL" value="Subscribed bitrate" />
        <link name="REQ_MAX_BR_DL" value="Subscribed bitrate" />
        <link name="REQ_GUAR_BR_UL" value="Subscribed bitrate" />
        <link name="REQ_GUAR_BR_DL" value="Subscribed bitrate" />
        <Object name="MOD_PROFILE" value="" />
        <Integer name="IDX_FOR_REORDER" value="-1" />
        <Boolean name="L1L2BearerEnable" value="true" />
        <Integer name="L1L2EPSBearerId" value="5" />
        <Integer name="T_ACT_OFFSET" value="0" />
        <String name="DEACT_FLAG_ENUM" value="UE triggered deactivation" />
      </record>
    </db>
  </Bearer>
  <BearerModificationProfileList>
    <db name="Bearer 0" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 0" value="false" />
  </BearerModificationProfileList>
  <Groups>
    <Group name="Attach_Lte" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user 0001"
      <TemplateProfileMobility name="Mobility.FixedPosition" Cell="10" RadioCondition="NOHO%normal%1000,15,0,15,0,1,2,Disabled,0.0,0.0,0.0,None,Disabled,0.0,0.0,No Fading,Not Applicable" ForcedRRCConnReestProc="None">
        <LoopedMode enable="false" />
        <SpeedModeEditable enable="false" />
        <db name="BRCDb" formatname="BRCDb" version="1.0">
          <record name="0" modifiable="true">
            <String name="Timestamp" value="1000" />
            <String name="WB_CQI_CW1" value="15" />
            <String name="SB_CQI_CW1" value="0" />
            <String name="WB_CQI_CW2" value="15" />
            <String name="SB_CQI_CW2" value="0" />
            <Integer name="PMI" value="1" />
            <String name="RI" value="2" />
            <String name="Pathloss" value="Disabled" />
            <Double name="UL_BLER_Coeff" value="0.0" />
            <Double name="DL_BLER_CoeffTxDiv" value="0.0" />
            <Double name="DL_BLER_CoeffMIMO" value="0.0" />
            <String name="NormPowHeadr" value="None" />
            <String name="AWGN" value="Disabled" />
            <Double name="RadialSpeed" value="0.0" />
            <Double name="Position" value="0.0" />
            <link name="FadingProfileIndex" value="No Fading" />
            <String name="RadioOff" value="Not Applicable" />
          </record>
        </db>
      </TemplateProfileMobility>
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 1" InterarrivalTime="1000" RandomRate="false" Repetitions="1" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0010Attach_Lte0013New session 100000000000100000" loop="false" Group="Attach_Lte">
      <TestTraceManager masterTraceLength="5" traces="1">
        <TestTrace>
          <TemplateProfile name="UDG Bidirectional Transmission" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" TIME_TO_WAIT_VIDEO="100" APN="Default APN" EXP_THROUGHPUT_UL="4000.0" EXP_THROUGHPUT_DL="19200.0" USR_PKT_LEN_TYPE="Fixed" USR_PKT_LEN="1000" NET_PKT_LEN_TYPE="Fixed" NET_PKT_LEN="1200" ProtocolLayer="IP" REMOTE_PORT="50100" UUDG_NET_IP="22.22.22.22" UUDG_NET_IPV6="2222::22" DELAY="100" NUM_TRAN="1" TRAN_TIME="300000" TRAN_T_INT="1000" IDLE_OUT_TIME="0" IDLE_OUT_SIDE="UE Not Synchronous" USR_N_PKT="2" USR_PKT_T_INT="4" USR_PKT_T_INT_UNIT="Millisecond" NET_N_PKT="4" NET_PKT_T_INT="2" NET_PKT_T_INT_UNIT="Millisecond" />
        </TestTrace>
      </TestTraceManager>
    </Session>
  </SessionList>
  <globals />
  <SmartphoneSimulator userLibraryFilename="" />
  <cell_list />
  <func_low_list />
</TestScenario>

