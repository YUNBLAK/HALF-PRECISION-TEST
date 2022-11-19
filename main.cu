#include <stdio.h>
#include <stdlib.h>
#include <cuda_fp16.h>
#include <time.h>

int *garr01, *garr02, *garr03;
int *arr01, *arr02, *arr03;
__half *bigArray;

// nvcc main.cu -o main -gencode arch=compute_75,code=[sm_75,compute_75]

__device__ __half2 Taylor_exponential_fp16(int n, __half2 x) { 
    __half2 exp_sum = __int2half2_rd(1);  
    __half2 initone = __int2half2_rd(1);   
    for (long int i = n - 1; i > 0; --i){
        //exp_sum = __hadd2(initone, __hdiv2((__hmul2(x, exp_sum)), __int2half2_rd(i)));
        exp_sum = __hcmadd(hmul2(x, exp_sum), hrcp(__int2half2_rd(i)), initone);
    }    
    return exp_sum; 
}

__device__ float Taylor_exponential_fp32(int n, float x) { 
    float exp_sum = 1;     
    for (long int i = n - 1; i > 0; --i ) 
        exp_sum = 1 + x * exp_sum / i;    
    return exp_sum; 
}

__device__ double Taylor_exponential_fp64(int n, double x) { 
    double exp_sum = 1;     
    for (long int i = n - 1; i > 0; --i ) 
        exp_sum = 1 + x * exp_sum / i;    
    return exp_sum; 
}

__global__ void gpuCal(int N, float x)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    // printf("[] %d\t %d\t %d\t %d\t\n", i, blockIdx.x, blockDim.x, threadIdx.x);
    
    #ifdef FP16
        printf ("[FP Float16 used]\n");
        __half xx = Taylor_exponential_fp16(N, __float2half(x));
        printf("\ne^x = %g\n",__half2float(xx));
    #else 
        printf ("[FP Float32 used]\n");
        float xx = Taylor_exponential_fp32(N, x);
        printf("\ne^x = %g\n",xx);
    #endif
}


int main(int argc, char *argv[]) 
{
    float x = 0.5;
    int taylor_N = 20000;
    int big_N = 1;

    int n = 1;
    int nBytes = n * sizeof(int);
    int block_size = 1;
    int block_no = (n + block_size - 1)/block_size;

    clock_t start, end;
    double cpu_time_used;

    char *a = argv[1];

    if (argc == 1 ){
        printf("Missing argument 'n', defaults to %ld.\n", taylor_N);
    }
    
    else {
        char *a = argv[1];
        taylor_N = atoi(a);
    }

    #ifdef FP16
        printf ("[FP Float16 used]\n");
    #else
        printf ("[FP Float32 used]\n");
    #endif
    
    printf("value of n = %ld and x = %g ", taylor_N, x);

    start = clock();
    gpuCal<<<block_no, block_size>>>(taylor_N, x);
    cudaDeviceSynchronize();
    end = clock();

    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf ("CPU time: %g seconds\n", cpu_time_used);

    return 0;
}