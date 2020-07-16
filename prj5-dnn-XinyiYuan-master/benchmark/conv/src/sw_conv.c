#include "printf.h"
#include "trap.h"
#include "mul.h"
#include "div.h"
#include "perf_cnt.h"

#define FRAC_BIT		10

#define RD_ADDR			135106448
#define RD_SIZE_D0		1
#define RD_SIZE_D1		1
#define RD_SIZE_D2		28
#define RD_SIZE_D3		28

#define WEIGHT_ADDR		134217728
#define WEIGHT_SIZE_D0	20		
#define WEIGHT_SIZE_D1	1
#define WEIGHT_SIZE_D2	5
#define WEIGHT_SIZE_D3	5

#define WR_ADDR			135108240
#define WR_SIZE_D0		1
#define WR_SIZE_D1		20
#define WR_SIZE_D2		12
#define WR_SIZE_D3		12

#define KERN_ATTR_CONV_PAD			0
#define KERN_ATTR_CONV_STRIDE		1
#define KERN_ATTR_POOL_PAD			0
#define KERN_ATTR_POOL_KERN_SIZE	2
#define KERN_ATTR_POOL_STRIDE		2

struct size_vec4 {
	unsigned d0;
	unsigned d1;
	unsigned d2;
	unsigned d3;
};

struct mem_addr {
	unsigned rd_addr;
	unsigned weight_addr;
	unsigned wr_addr;
};

int mul(short a,short b) {
	int ans = mul_ll(a, b);
	return ans;
}

struct mem_addr addr = {RD_ADDR, WEIGHT_ADDR, WR_ADDR};
struct size_vec4 rd_size = {RD_SIZE_D0, RD_SIZE_D1, RD_SIZE_D2, RD_SIZE_D3};
struct size_vec4 wr_size = {WR_SIZE_D0, WR_SIZE_D1, WR_SIZE_D2, WR_SIZE_D3};
struct size_vec4 weight_size = {WEIGHT_SIZE_D0, WEIGHT_SIZE_D1, WEIGHT_SIZE_D2, WEIGHT_SIZE_D3};
	
struct size_vec4 conv_size;

void convolution() {
	short* in = (short*)addr.rd_addr;
	short* weight = (short*)addr.weight_addr;
	short* out = (short*)addr.wr_addr;

	unsigned output_offset = 0;
	unsigned input_offset = 0;
	unsigned weight_offset = 0;
	
	unsigned input_fm_w = rd_size.d3;
	unsigned input_fm_h = rd_size.d2;

	unsigned pad = KERN_ATTR_CONV_PAD;
	unsigned pad_len = pad << 1; //extra length brought by 2 pads
	
	unsigned conv_out_w = rd_size.d3 - weight_size.d3 + pad_len;
	unsigned conv_out_h = rd_size.d2 - weight_size.d2 + pad_len;

	unsigned stride = KERN_ATTR_CONV_STRIDE; //one move

	conv_out_w = div(conv_out_w, stride);
	conv_out_h = div(conv_out_h, stride);

	conv_out_w++;
	conv_out_h++;

	conv_size.d0 = wr_size.d0; //number of input pictures
	conv_size.d1 = wr_size.d1; //number of output pictures
	conv_size.d2 = conv_out_h; //height of output pictures
	conv_size.d3 = conv_out_w; //width of output pictures
	
	//TODO: Please add your own algorithm implementaion here
	
	int no=0, ni=0;
	int x=0, y=0;
	int padx=0, pady=0;
	int kx=0, ky=0;
	int temp=0, temp_in=0, temp_w=0;
	
	for(no=0;no<conv_size.d1;++no){
	//number of output pictures
		input_offset=0; //reset
		for(ni=0;ni<conv_size.d0;++ni){
		//number of input pictures
			for(y=0;y<conv_size.d2;++y){
				for(x=0;x<conv_size.d3;++x){
				//(x,y) in output picture
					padx=x*stride;
					pady=y*stride;
					temp=0;
					
					if (ni==0) 
						out[output_offset+y*conv_size.d3+x]=weight[weight_offset]; //add bias
					
					for(ky=0;ky<weight_size.d2;++ky){
						for(kx=0;kx<weight_size.d3;++kx){
						//(kx,ky) in weight map
							if (padx+kx>=pad && padx+kx<input_fm_w+pad && pady+ky>=pad && pady+ky<input_fm_h+pad) //not in padding zone
								temp_in=(short int)in[input_offset+(pady+ky-pad)*input_fm_w+(padx+kx-pad)];//temp_in=in[padx+kx-pad,pady+ky-pad]
							else temp_in=0; //in padding zone
							
							temp_w=(short int)(weight[weight_offset+ky*weight_size.d3+kx+1]); //filter[0,0] is bias, +1 to skip it
							temp+=(int)(temp_in*temp_w);
						}
					}
					out[output_offset+y*conv_size.d3+x]+=(short)(temp>>FRAC_BIT); //only need 10 decimal places
				} //complete one row
			} //complete one input picture
			
			input_offset+=input_fm_h*input_fm_w; //go to next point
			weight_offset+=weight_size.d2*weight_size.d3+1; //size of a filter = 1+k*k
		} //complete one output picture
		
		output_offset+=conv_size.d2*conv_size.d3; //go to next output picture
	}
	
}

void pooling() {
	short* out = (short*)addr.wr_addr;
	
	unsigned output_offset = 0;
	unsigned input_offset = 0;
	
	unsigned input_fm_w = conv_size.d3;
	unsigned input_fm_h = conv_size.d2;
	
	unsigned pad = KERN_ATTR_POOL_PAD;
	unsigned pad_len = pad << 1;
	
	unsigned pad_w_test = conv_size.d3 - KERN_ATTR_POOL_KERN_SIZE;
	unsigned pad_h_test = conv_size.d2 - KERN_ATTR_POOL_KERN_SIZE;

	unsigned pool_out_w = pad_w_test + pad_len;
	unsigned pool_out_h = pad_h_test + pad_len;

	unsigned stride = KERN_ATTR_POOL_STRIDE;

	unsigned pad_w_test_remain = pad_w_test - mul(div(pad_w_test, stride), stride);
	unsigned pad_h_test_remain = pad_h_test - mul(div(pad_h_test, stride), stride);

	pool_out_w = div(pool_out_w, stride);
	pool_out_h = div(pool_out_h, stride);
	pool_out_w++;
	pool_out_h++;

	if ( (!pad) && (pad_w_test_remain || pad_h_test_remain) )
	{
		pool_out_w++;
		pool_out_h++;
	}
	
	//TODO: Please add your own algorithm implementaion here
	int no=0;
	int x=0, y=0;
	int ox=0, oy=0;
	int i=0, j=0;
	int max=0;
	int temp=0;
	
	for(no=0;no<conv_size.d1;++no){
		for(y=0;y<pool_out_h;++y){
			for(x=0;x<pool_out_w;++x){
			//(x,y) in pooling output
				ox=x*stride;
				oy=y*stride; //pooling stride
				max=-2147483648; //int min
				
				for(j=0;j<stride;++j){
					for(i=0;i<stride;++i){
					//(ox+i,oy+j) in pooling area
						if (ox+i>=pad && ox+i<input_fm_w+pad && oy+j>=pad && oy+j<input_fm_h+pad) 
							//not in the padding zone
							temp=(short)out[input_offset+(oy+j-pad)*input_fm_w+(ox+i-pad)];
						else temp=0; //in the padding zone
						
						if (temp>max) max=temp;
					}
				}
				
				out[output_offset+y*pool_out_w+x] = max;
			}
		}
		
		input_offset += input_fm_h * input_fm_w; //change to another input
		output_offset += pool_out_h * pool_out_w; //change to another output
	}
}

int main()
{
	Result res;
	
	bench_prepare(&res);
	printf("Start convolution\n");
	convolution();
	printf("Start pooling\n");
	pooling();
	bench_done(&res);
	
	printf("Cycles of sw: %u\n",res.msec);
	printf("Memory visit times: %u\n",res.mem_cycle);
	return 0;
}
