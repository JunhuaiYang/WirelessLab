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
  TIMER_PERIOD_MILLI = 1000
};

enum {
  AM_TEST_SERIAL_MSG = 0x89,
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToRadioMsg;

typedef nx_struct test_serial_msg {
  nx_uint16_t counter;
  nx_uint16_t nodeid;
} test_serial_msg_t;

#endif // __RADIOANDSERIAL_h__



