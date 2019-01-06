
#include <Timer.h>
#include "RadioAndSerial.h"

configuration RadioAndSerialAppC {
}
implementation {
  components MainC;
  components LedsC;
  components RadioAndSerialC as App;
  components ActiveMessageC;
  components new AMSenderC(AM_BLINKTORADIO);
  components new AMReceiverC(AM_BLINKTORADIO);
  components SerialActiveMessageC as AM;

  // 计时器 test
  components new TimerMilliC();
  App.MilliTimer -> TimerMilliC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;

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
