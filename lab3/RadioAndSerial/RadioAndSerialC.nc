/***********************************************************************
 * @file RadioAndSerialC.nc
     RADIOANDSERIALC
 * @brief   sources file
 *
 * @Copyright (C)  2019  YangJunhuai. all right reserved
***********************************************************************/
#include <Timer.h>
#include "RadioAndSerial.h"

module RadioAndSerialC {
  uses interface Boot;
  uses interface Leds;

  uses interface Packet   as RadioPacket;
  uses interface AMPacket as RadioAMPacket;
  uses interface AMSend   as RadioAMSend;
  uses interface Receive  as RadioReceive;
  uses interface SplitControl as RadioAMControl;

  uses interface Packet   as SerialPacket;
  uses interface Receive  as SerialReceive;
  uses interface AMSend   as SerialAMSend;
  uses interface SplitControl as SerialControl;

  // test
  // uses interface Timer<TMilli> as MilliTimer;
}
implementation {

  message_t packet;
  message_t pkt;

  bool locked = FALSE;
  bool busy = FALSE;

  uint16_t counter = 0;
  uint16_t nodeid;
  uint16_t aim_node = 1;   


// 无需定时器

  event void Boot.booted() {
    call RadioAMControl.start();
    call SerialControl.start();
    // call MilliTimer.startPeriodic(1000);
  }

// 无线
  event void RadioAMControl.startDone(error_t err) {
    if (err == SUCCESS) {
    }
    else {
      call RadioAMControl.start();
    }
  }

  event void RadioAMControl.stopDone(error_t err) {
  }

  // 串口
  event void SerialControl.startDone(error_t err) {
    if (err == SUCCESS) {
    }
    else {
      call SerialControl.start();
    }
  }

  event void SerialControl.stopDone(error_t err) {
  }


// 无线发送完成
  event void RadioAMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

// 串口发送完成
  event void SerialAMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
        // call Leds.led1Toggle();
        locked = FALSE;
    }
  }

// 无线收到数据
  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len)
  {
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      // led2 亮

    // 路由
    //  目标节点是基站
     if(nodeid == TOS_NODE_ID)
      {  
         counter = counter + TOS_NODE_ID ;
         nodeid = 1;  
         setLeds(counter);
     }

      // 转发到串口
      if (locked) {
        return NULL;
      }
      else 
      {
        test_serial_msg_t* rcm = (test_serial_msg_t*)call SerialPacket.getPayload(&packet, sizeof(test_serial_msg_t));
        if (rcm == NULL) 
        {  
          return NULL;
        }
        if (call SerialPacket.maxPayloadLength() < sizeof(test_serial_msg_t)) {
            return NULL;
        }
          rcm->counter = btrpkt->counter;
          rcm->nodeid = btrpkt ->nodeid;
          if (call SerialAMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {
              // call Leds.led1Toggle();
              locked = TRUE;
          }
        }
      }
      return msg;
    }

  // 串口收到数据
    event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) 
    {
        if (len != sizeof(test_serial_msg_t)) 
        {return bufPtr;}
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
            if (btrpkt == NULL)
            {
                return NULL;
            }
            btrpkt->nodeid = rcm->nodeid;
            btrpkt->counter = rcm->counter;
            // 基站自身节点+1
            aim_node = TOS_NODE_ID +1;
            // 单播发送
            if (call RadioAMSend.send(aim_node, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) 
            {
                busy = TRUE;
            }
        }

      return bufPtr;
    }
  }


}
