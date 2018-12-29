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
  uses interface Packet   as RadioPacket;
  uses interface AMPacket as RadioAMPacket;
  uses interface AMSend   as RadioAMSend;
  uses interface Receive  as RadioReceive;
  uses interface SplitControl as RadioAMControl;

  uses interface Packet   as SerialPacket;
  uses interface Receive  as SerialReceive;
  uses interface AMSend   as SerialAMSend;
  uses interface SplitControl as SerialControl;

    // other
    uses interface Leds;
    uses interface Boot;
    uses interface Timer<TMilli> as Timer0;
}

// 模块
implementation
{
bool busy = FALSE;
bool locked = FALSE;
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
    call RadioAMControl.start();
    call SerialControl.start();
}

event void RadioAMControl.startDone(error_t err)
{
    if (err == SUCCESS)
    {
    call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else{
    call RadioAMControl.start();
    }
}

event void RadioAMControl.stopDone(error_t err) {
// do nothing
}

  // 串口
  event void SerialControl.startDone(error_t err) {
    if (err == SUCCESS) {
    }
    else {
      call SerialControl.start();
    }
  }

  event void SerialControl.stopDone(error_t err) {}


event void Timer0.fired()
{
    // counter++;
    // dbg("BlinkToRadioC", "BlinkToRadioC: timer fired, counter is %hu.\n", counter);
    // if (!busy) {
    //     BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
    //     btrpkt->nodeid = TOS_NODE_ID;
    //     btrpkt->counter = counter;

    //     if (call AMSend.send(AM_BROADCAST_ADDR, &pkt,sizeof(BlinkToRadioMsg)) == SUCCESS) {
    //     busy = TRUE;
    //     }
    // }       
}

event void RadioAMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
    busy = FALSE;
    }
}

event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len == sizeof(BlinkToRadioMsg)) {
        BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
        // led2 亮
        call Leds.led2Toggle();

        // 转发到串口
      if (locked) {
        return NULL;
      }
      else {
        test_serial_msg_t* rcm = (test_serial_msg_t*)call SerialPacket.getPayload(&pkt, sizeof(test_serial_msg_t));
        if (rcm == NULL) {return NULL;}
        if (call SerialPacket.maxPayloadLength() < sizeof(test_serial_msg_t)) {
          return NULL;
        }
        rcm->counter = btrpkt->counter;
        if (call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(test_serial_msg_t)) == SUCCESS) {
          locked = TRUE;
        }
      }

    }
    return msg;
}

// 串口发送完成
  event void SerialAMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&pkt == bufPtr) {
      locked = FALSE;
    }
  }

  // 串口收到数据
    event message_t* SerialReceive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) 
    {
        call Leds.led0Toggle();
    if (len != sizeof(test_serial_msg_t)) {return bufPtr;}
    else
    {
      test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
      // led0 亮
      call Leds.led0Toggle();

      // 转发到无线
      if (!busy) 
      {
        BlinkToRadioMsg* btrpkt = 
      (BlinkToRadioMsg*)(call RadioPacket.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
        if (btrpkt == NULL) {
          return NULL;
        }
        btrpkt->nodeid = TOS_NODE_ID;
        btrpkt->counter = rcm->counter;
        if (call RadioAMSend.send(AM_BROADCAST_ADDR, 
            &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) 
        {
          busy = TRUE;
        }
      }


      return bufPtr;
    }
  }


}


