FROM ubuntu:22.04

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TOOLS_PATH=/opt/gcc-arm-none-eabi
ARG ARM_TOOLCHAIN_SOURCE=https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz?rev=e434b9ea4afc4ed7998329566b764309&hash=CA590209F5774EE1C96E6450E14A3E26

# basic ubuntu requierments
RUN apt-get update && apt-get install -y \
	build-essential \
	git gnupg2 \
	stlink-tools \
	xz-utils curl \
    wget \
	make \
    gcc \
    g++ \
    libssl-dev \
	checkinstall \ 
	zlib1g-dev \
	ninja-build \
	ssh \
	python3 \
	python-is-python3

# install cmake
RUN wget "https://github.com/Kitware/CMake/releases/download/v3.29.0/cmake-3.29.0.tar.gz" && \
    tar -xzvf cmake-3.29.0.tar.gz && \
    cd cmake-3.29.0/ && \
    ./bootstrap &&\
	make && make install

# arm toolchain and compiler
RUN mkdir ${TOOLS_PATH} \
	&& curl -Lo gcc-arm-none-eabi.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz?rev=e434b9ea4afc4ed7998329566b764309&hash=CA590209F5774EE1C96E6450E14A3E26" \
	&& tar xf gcc-arm-none-eabi.tar.xz --strip-components=1 -C ${TOOLS_PATH} \
	&& rm gcc-arm-none-eabi.tar.xz \
	&& rm ${TOOLS_PATH}/*.txt \
	&& rm -rf ${TOOLS_PATH}/share/doc


# install static analysis tools
RUN apt-get install -y \
	clang-format clang-tidy \
	python3 python3-pip \
	&& pip install lizard cpplint \
	&& apt-get clean

# pip requierments
RUN pip install cantools

# install cppcheck which should be used while clang-tidy is not fixed for stm
RUN apt-get update -qq && apt-get install -y cppcheck

# Add Toolchain to PATH
ENV PATH="$PATH:${TOOLS_PATH}/bin"