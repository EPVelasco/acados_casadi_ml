FROM graphcore/pytorch:2.6.0-ubuntu-20.04-20220726

# Set up time zone.
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt-get update
RUN apt-get upgrade -y

ARG USER_ID
ARG GROUP_ID

RUN apt-get update && apt-get install -y apt-utils curl wget git bash-completion build-essential sudo && rm -rf /var/lib/apt/lists/*

# Change HOME environment variable
ENV HOME /home/epvs
RUN mkdir -p ${HOME}/ml_casadi/src

#requisitos acados
RUN apt-get update && apt-get -y install cmake && apt-get -y install make

#requisitos 
RUN apt-get -y update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
# Install py39 from deadsnakes repository
RUN apt-get install -y python3.8
# Install pip from standard ubuntu packages
RUN apt-get install -y python3-pip
RUN apt-get install nano
RUN apt-get install bc 
RUN apt install -y liblapack-dev libopenblas-dev


#clone repository acados
RUN cd ${HOME}/ml_casadi/src/ && git clone https://github.com/EPVelasco/acados.git
RUN cd ${HOME}/ml_casadi/src/acados  && git submodule update --recursive --init && mkdir -p build
RUN cd ${HOME}/ml_casadi/src/acados/build && cmake -DACADOS_WITH_OPENMP=ON -DACADOS_INSTALL_DIR="/home/epvs/ml_casadi/src/acados" ..
RUN cd ${HOME}/ml_casadi/src/acados/build && make install -j4
RUN cd ${HOME}/ml_casadi/src/acados && make shared_library
RUN cd ${HOME}/ml_casadi/src/acados && make examples_c
RUN pip3 install catkin_pkg
RUN pip3 install -e /home/epvs/ml_casadi/src/acados/interfaces/acados_template


#clone repository ml casadi
RUN cd ${HOME}/ml_casadi/src/ && git clone https://github.com/EPVelasco/ml-casadi.git
COPY ./requirements.txt ${HOME}/ml_casadi/src/ml-casadi/
RUN cd ${HOME}/ml_casadi/src/ml-casadi/ && pip install -r requirements.txt
RUN cd ${HOME}/ml_casadi/src/ml-casadi/ && python3 setup.py build
RUN cd ${HOME}/ml_casadi/src/ml-casadi/ && python3 setup.py install

#Clone repository training
RUN cd ${HOME}/ml_casadi/src/ && git clone https://github.com/EPVelasco/neural-mpc.git
COPY ./neural-mpc/requirements.txt ${HOME}/ml_casadi/src/neural-mpc/
RUN cd ${HOME}/ml_casadi/src/neural-mpc/ && pip install -r requirements.txt

## ROS NOETIC INSTALL
# Minimal setup
RUN apt-get update \
 && apt-get install -y locales lsb-release
RUN dpkg-reconfigure locales
 
# Install ROS Noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update \
 && apt-get install -y --no-install-recommends ros-noetic-desktop-full
RUN apt-get install -y --no-install-recommends python3-rosdep
RUN rosdep init \
 && rosdep fix-permissions \
 && rosdep update

#RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
# set up environment
COPY ./update_bashrc /sbin/update_bashrc
RUN sudo chmod +x /sbin/update_bashrc ; sudo chown ros /sbin/update_bashrc ; sync ; /bin/bash -c /sbin/update_bashrc ; sudo rm /sbin/update_bashrc


RUN apt install -y vim
RUN apt-get update
RUN apt-get install -y libgl1-mesa-glx
RUN apt-get update
RUN apt-get -y install \
    libcanberra-gtk-module \
    libcanberra-gtk3-module
RUN apt-get install -y dvipng texlive-latex-extra texlive-fonts-recommended cm-super
RUN apt-get install -y python3-tk
RUN pip3 install PyQt5
RUN apt-get clean


##### install Tera acados
COPY ./t_renderer ${HOME}/ml_casadi/src/acados/bin/ 
RUN sudo chmod +x  ${HOME}/ml_casadi/src/acados/bin/t_renderer

## Clone the drone reposiroty 
RUN cd ${HOME}/ml_casadi/src/ && git clone https://github.com/lfrecalde1/Pendulum_cart.git

RUN apt-get update && apt-get install -y \
    x11-apps

# Configura la variable de entorno DISPLAY
ENV DISPLAY=:0    

# Allow use of NVIDIA card
RUN export CUDA_VISIBLE_DEVICES=[0]
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

