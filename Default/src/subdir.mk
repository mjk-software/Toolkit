################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../src/GPUToolkit.cu \
../src/main.cu 

CC_SRCS += \
../src/CPUToolkit.cc \
../src/Matrix.cc \
../src/Toolkit.cc 

CC_DEPS += \
./src/CPUToolkit.d \
./src/Matrix.d \
./src/Toolkit.d 

OBJS += \
./src/CPUToolkit.o \
./src/GPUToolkit.o \
./src/Matrix.o \
./src/Toolkit.o \
./src/main.o 

CU_DEPS += \
./src/GPUToolkit.d \
./src/main.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.0/bin/nvcc -O2 -std=c++11 -gencode arch=compute_61,code=sm_61  -odir "src" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.0/bin/nvcc -O2 -std=c++11 --compile  -x c++ -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.0/bin/nvcc -O2 -std=c++11 -gencode arch=compute_61,code=sm_61  -odir "src" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.0/bin/nvcc -O2 -std=c++11 --compile --relocatable-device-code=false -gencode arch=compute_61,code=compute_61 -gencode arch=compute_61,code=sm_61  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


