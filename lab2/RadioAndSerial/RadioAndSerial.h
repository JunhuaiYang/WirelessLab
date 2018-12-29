/***********************************************************************
 * @file RadioAndSerial.h
     RADIOANDSERIAL
 * @brief   header file
 *
 * @Copyright (C)  2018  YangJunhuai. all right reserved
***********************************************************************/
#ifndef __RADIOANDSERIAL_h__
#define __RADIOANDSERIAL_h__

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToRadioMsg;

#endif // __RADIOANDSERIAL_h__



