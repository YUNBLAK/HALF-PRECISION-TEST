# HALF-PRECISION-TEST
## HALF-PRECISION-TEST

### BASHRC

    export PATH=/usr/local/cuda-11.7/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=/usr/local/cuda-11.7/extras/CUPTI/lib64:$LD_LIBRARY_PATH


### *Words
    
    BlockIdx  : Inherent Group including Threads
    BlockDim  : The number of Threads
    ThreadIdx : Index of A Thread

### Half-Precision Complie Command

    nvcc main.cu -o main -gencode arch=compute_75,code=[sm_75,compute_75]
    // BASED ON RTX 2070 POWER (7.5)
    // CUDA HALF-PRECISION CAN RUN ON THE POWER OVER THAN 530
    // if !defined(__CUDA_ARCH__) || (__CUDA_ARCH__ >= 530) # cuda_fp16.h
    
### PRECISION CONTROL

    nvcc main.cu -DFP16 -o main -gencode arch=compute_75,code=[sm_75,compute_75]


### HALF-PRECISION ARITHMETICS FUNCTIONS

[CUDA WEBSITE](https://docs.nvidia.com/cuda/cuda-math-api/group__CUDA__MATH____HALF__ARITHMETIC.html#group__CUDA__MATH____HALF__ARITHMETIC)    

### Taylor Exponential Experiment with CUDA
