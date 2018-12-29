/***********************************************************************
 * @file BlinkToRadioAppc.nc
     BLINKTORADIOAPPC
 * @brief   sources file
 *
 * @Copyright (C)  2018  YangJunhuai. all right reserved
***********************************************************************/

#include "BlinkToRadio.h"

configuration BlinkToRadioAppc {}
implementation {
  components MainC, LedsC;
  components BlinkToRadioC as App;
  components new AMSenderC(AM_POINTTOPOINT);
  components new AMReceiverC(AM_POINTTOPOINT);
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components SerialActiveMessageC as AM;

  
  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;

  // App.Packet -> AMSenderC;
  // App.AMPacket -> AMSenderC;
  // App.AMControl -> ActiveMessageC;
  // App.AMSend -> AMSenderC;
  // App.Receive -> AMReceiverC;
  
  App.RadioPacket -> AMSenderC;
  App.RadioAMPacket -> AMSenderC;
  App.RadioAMControl -> ActiveMessageC;
  App.RadioAMSend -> AMSenderC;
  App.RadioReceive -> AMReceiverC;

  App.SerialReceive -> AM.Receive[AM_TEST_SERIAL_MSG];
  App.SerialAMSend -> AM.AMSend[AM_TEST_SERIAL_MSG];
  App.SerialPacket -> AM;
  App.SerialControl -> AM;
}