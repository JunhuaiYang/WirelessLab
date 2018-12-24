/* 
 实验4.4
 */
#include "Timer.h"
#include "printf.h"

module BlinkC @safe()
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Leds;
  uses interface Boot;
}
implementation
{
  uint32_t i;

  event void Boot.booted()
  {
    call Timer0.startPeriodic( 250 );
    call Timer1.startPeriodic( 500 );
    call Timer2.startPeriodic( 1000 );
  }

task void computeTask()
  {
    uint32_t start = i;
    //for(i=0;i<10001;i++);
    //相当于每一次只运行了10000
    for (;i < start + 10000 && i < 400001; i++);
    if (i > 400000)
      i = 0;
    else 
      post computeTask();

  }

  event void Timer0.fired()
  {
    dbg("BlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
    call Leds.led0Toggle();
    printf("timer1\n");
    printfflush();
    post computeTask();
  }
  
  event void Timer1.fired()
  {
    dbg("BlinkC", "Timer 1 fired @ %s \n", sim_time_string());
    call Leds.led1Toggle();
    printf("timer2\n");
    printfflush();
  }
  
  event void Timer2.fired()
  {
    dbg("BlinkC", "Timer 2 fired @ %s.\n", sim_time_string());
    call Leds.led2Toggle();
    printf("timer3\n");
    printfflush();
  }
}

