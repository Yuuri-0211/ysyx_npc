#include "VsCPU.h"
#include "verilated.h" 
#include "nvboard.h"

static TOP_NAME dut;

void nvboard_bind_all_pins(TOP_NAME* sCPU);//连接引脚用的
//clk和rst不允许使用板子上的开关，只能用代码来操作
static void single_cycle(){
	dut.clk = 0;
	dut.eval();
	dut.clk = 1;
	dut.eval();
}

static void reset(int n){
	dut.rst = 1;
	while(n-- >0)single_cycle();
	dut.rst = 0;
}

int main(){
	nvboard_bind_all_pins(&dut);
	nvboard_init();//图形界面
	reset(10);
	while(1){
		nvboard_update();
		single_cycle();
	}
}
