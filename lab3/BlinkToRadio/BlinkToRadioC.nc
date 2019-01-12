/***********************************************************************
 * @file BlinkToRadioC.nc
     BLINKTORADIOC
 * @brief   sources file
 *
 * @Copyright (C)  2019  YangJunhuai. all right reserved
***********************************************************************/

#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation {

  uint16_t counter;
  uint16_t  aim_node = 1;
  uint16_t  nodeid = 1;
  message_t pkt;
  bool busy = FALSE;

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

// 关灯
  void LedsOff() {
  	call Leds.led0Off();
  	call Leds.led1Off();
  	call Leds.led2Off();
  }

  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    while (err != SUCCESS) {
    	call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() 
  {
    // 每次触发定时器就关灯
    LedsOff();

    // 转发信息
    if (!busy) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
      if (btrpkt == NULL) {
	      return;
      }
      btrpkt->nodeid  = nodeid;
      btrpkt->counter = counter;
      if (call AMSend.send(aim_node, 
          &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
    
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      
      nodeid  = btrpkt->nodeid;
      counter = btrpkt->counter;

// 大于本身 +1
     if(nodeid > TOS_NODE_ID){   
        aim_node = TOS_NODE_ID + 1; 
        setLeds(aim_node);
        call Timer0.startOneShot(1000);
     }

// 小于本身 -1
     if(nodeid < TOS_NODE_ID) { 
         aim_node = TOS_NODE_ID - 1;
         setLeds(aim_node);
         call Timer0.startOneShot(1000);
     }
     
    //  目标节点是自己
     if(nodeid == TOS_NODE_ID)
      {  
         counter = counter + TOS_NODE_ID ;
        //  把总目标节点设为几基站节点
         nodeid = 1;  
        //  传回去
         aim_node = TOS_NODE_ID -1;
         setLeds(counter);
         call Timer0.startOneShot(3000);
     }
    }
    return msg;
  }
}