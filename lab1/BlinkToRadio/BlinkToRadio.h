/***********************************************************************
 * @file BlinkToRadio.h
     BLINKTORADIO
 * @brief   header file
 *
 * @Copyright (C)  2018  YangJunhuai. all right reserved
***********************************************************************/
#ifndef __BLINKTORADIO_h__
#define __BLINKTORADIO_h__

typedef nx_struct BlinkToRadioMsg
{
  nx_uint16_t nodeid;
  nx_uint16_t counter;
}
BlinkToRadioMsg;

enum {
AM_POINTTOPOINT = 6,
TIMER_PERIOD_MILLI = 1000,
NODE_ID_1 = 1,
NODE_ID_2 = 2
};



#endif // __BLINKTORADIO_h__