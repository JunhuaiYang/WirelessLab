/***********************************************************************
 * @file BlinkToRadio.nc
     BLINKTORADIO
 * @brief   sources file
 *
 * @Copyright (C)  2018  YangJunhuai. all right reserved
***********************************************************************/

#include "BlinkToRadio.h"
#include "Timer.h"


module BlinkToRadioAppC
{
    uses interface Packet;
    uses interface AMSend;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
    // other
    uses interface Leds;
    uses interface Boot;
    uses interface Receive;
    uses interface Timer<TMilli> as Timer0;
}

// 模块
implementation
{
bool busy = FALSE;
message_t pkt;
// 设置count
uint16_t counter = 0;

void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

event void Boot.booted() {
    call AMControl.start();
}

event void AMControl.startDone(error_t err)
{
    if (err == SUCCESS)
    {
    call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else{
    call AMControl.start();
    }
}

event void AMControl.stopDone(error_t err) {
// do nothing
}

event void Timer0.fired()
{
    counter++;
    dbg("BlinkToRadioC", "BlinkToRadioC: timer fired, counter is %hu.\n", counter);
    if (!busy) {
        BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
        btrpkt->nodeid = TOS_NODE_ID;
        btrpkt->counter = counter;

        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt,sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
        }
    }       
}

event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
    busy = FALSE;
    }
}

event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len == sizeof(BlinkToRadioMsg)) {
        BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
        call Leds.set(btrpkt->counter);
    }
    return msg;
}

}


