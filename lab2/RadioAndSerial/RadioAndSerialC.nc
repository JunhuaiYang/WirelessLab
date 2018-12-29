
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

}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;
  bool locked = FALSE;


  event void Boot.booted() {
    call RadioAMControl.start();
    call SerialControl.start();
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

  event void SerialControl.stopDone(error_t err) {}


// 无线发送完成
  event void RadioAMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

// 串口发送完成
  event void SerialAMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

// 无线收到数据
  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len)
  {
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      // led2 亮
      call Leds.led2Toggle();

      // 转发到串口
      if (locked) {
        return;
      }
      else {
        test_serial_msg_t* rcm = (test_serial_msg_t*)call SerialPacket.getPayload(&packet, sizeof(test_serial_msg_t));
        if (rcm == NULL) {return;}
        if (call SerialPacket.maxPayloadLength() < sizeof(test_serial_msg_t)) {
          return;
        }
        rcm->counter = btrpkt->counter;
        if (call WL_AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {
          locked = TRUE;
        }
      }
    }
    return msg;
  }

  // 串口收到数据
    event message_t* SerialReceive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
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
          return;
        }
        btrpkt->nodeid = TOS_NODE_ID;
        btrpkt->counter = rcm->counter;
        if (call WL_AMSend.send(AM_BROADCAST_ADDR, 
            &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) 
        {
          busy = TRUE;
        }
      }


      return bufPtr;
    }
  }


}
