//******************************************************************************//
// Module Name  : main.c
// Description  : 
// Designer     :
// Date         :
//******************************************************************************//
#include <stdint.h>

#include "../include/timer.h"
#include "../include/gpio.h"
#include "../include/utils.h"

//------------------------------------------------------------//
//
// define
//
//------------------------------------------------------------//
typedef struct{
    volatile unsigned int       CON;
    volatile unsigned int       CNT;
    volatile unsigned int       PERIOD;
} RV_TIMER_Typedef;

#define RV_TIMER0_BASE          (0x20000000)
#define RV_TIMER0               ((RV_TIMER_Typedef *)RV_TIMER0_BASE)

#define SFR(sfr, start, len, dat) (sfr = sfr & ~((~(0xffffffff<<len))<<start) | ((dat & (~(0xffffffff<<len)))<<start))
#define BIT(n)                    (1 << n)


//------------------------------------------------------------//
//
// param
//
//------------------------------------------------------------//
// static volatile unsigned int count;
static volatile uint32_t count;


//------------------------------------------------------------//
//
// interrupt
//
//------------------------------------------------------------//
void timer0_irq_handler()
{
    // clear int pending and start timer
    RV_TIMER0->CON |= BIT(2) | BIT(0);
    count++;
}


//------------------------------------------------------------//
//
// main
//
//------------------------------------------------------------//
int main()
{
    count = 0;

//----------------------------------------//
// simulation
//----------------------------------------//
#ifdef SIMULATION
    RV_TIMER0->PERIOD = 100;   // 2us 
    SFR(RV_TIMER0->CON, 0, 3, 7); // enable interrupt and start timer

    while(1) 
    {
        if(count == 10) 
        {
            SFR(RV_TIMER0->CON, 0, 3, 0); // stop timer0
            count = 0;

            set_test_pass();
            break;
        }
    }
//----------------------------------------//
// disable simulation
//----------------------------------------//
#else
    RV_TIMER0->PERIOD = 100000;   // 2ms 
    SFR(RV_TIMER0->CON, 0, 3, 7); // enable interrupt and start timer

    GPIO_REG(GPIO_DATA) = 0x1;

    while(1) 
    {
        // 100ms
        if(count == 50) 
        {
            count = 0;
            GPIO_REG(GPIO_DATA) ^= 0x1; // toggle led
        }
    }
#endif

}


//******************************************************************************//
// 
// END of Module
//
//******************************************************************************//
