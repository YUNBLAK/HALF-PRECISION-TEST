#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>
#include <cuda_fp16.h>

int *garr01, *garr02, *garr03;
int *arr01, *arr02, *arr03;

__global__ void vecAdd(int *A, int *B, int *C, int N)
{
    half x = __float2half(0.0);
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N)
        C[i] = A[i] + B[i];
    
}

int main() 
{
    half * dh0, *dh1, *dh2;
    int n = 100;
    int nBytes = n * sizeof(int);
    int block_size = 32;
    int block_no = (n + block_size - 1)/block_size;

    arr01 = (int *)malloc(nBytes);
    arr02 = (int *)malloc(nBytes);
    arr03 = (int *)malloc(nBytes);

    for(int i = 0; i<n; i++){
        arr01[i] = i;
        arr02[i] = i*i;
    }

    printf("Allocating device memory on host\n");
    cudaMalloc((void **)&garr01, n*sizeof(int));
    cudaMalloc((void **)&garr02, n*sizeof(int));
    cudaMalloc((void **)&garr03, n*sizeof(int));
    
    printf("Copying to device\n");
    cudaMemcpy(garr01, arr01, n *sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(garr02, arr02, n *sizeof(int), cudaMemcpyHostToDevice);
    //cudaMemcpy(garr03, arr03, n *sizeof(int), cudaMemcpyHostToDevice);
    
    printf("Doing GPU Vector\n");
    vecAdd<<<block_no, block_size>>>(garr01, garr02, garr03, n);

    printf("SYNC\n");
    cudaDeviceSynchronize();

    // vecAddOne_h(host_A, host_C1, n);
    cudaMemcpy(arr03, garr03, n*sizeof(int), cudaMemcpyDeviceToHost);
    
    for(int i =0;i<n; i++){
        printf("%d\n", arr03[i]);
    }
    
    cudaFree(garr01);
    cudaFree(garr02);
    cudaFree(garr03);

    return 0;
}
