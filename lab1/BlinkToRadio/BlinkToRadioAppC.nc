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
  
  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
}