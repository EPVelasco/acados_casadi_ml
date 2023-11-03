FROM osrf/ros:noetic-desktop-focal

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apt-utils curl wget git bash-completion build-essential sudo && rm -rf /var/lib/apt/lists/*

# Now create the user
ARG UID=1000
ARG GID=1000
RUN addgroup --gid ${GID} epvs
RUN adduser --gecos "ROS User" --disabled-password --uid ${UID} --gid ${GID} epvs
RUN usermod -a -G dialout epvs
RUN mkdir config && echo "ros ALL=(ALL) NOPASSWD: ALL" > config/99_aptget
RUN cp config/99_aptget /etc/sudoers.d/99_aptget
RUN chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget

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

# set up environment
COPY ./update_bashrc /sbin/update_bashrc
RUN sudo chmod +x /sbin/update_bashrc ; sudo chown ros /sbin/update_bashrc ; sync ; /bin/bash -c /sbin/update_bashrc ; sudo rm /sbin/update_bashrc

##### install Tera acados
COPY ./t_renderer ${HOME}/ml_casadi/src/acados/bin/ 
RUN sudo chmod +x  ${HOME}/ml_casadi/src/acados/bin/t_renderer

# Actualiza el sistema y instala las dependencias necesarias
RUN apt-get update && apt-get install -y \
    python3-tk \
    dvipng \
    texlive-latex-extra\
    texlive-fonts-recommended\
    cm-super\
    libgl1-mesa-glx\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configura la variable de entorno DISPLAYWORKDIR
ENV DISPLAY=:0    

#ruta de trabajo
WORKDIR /ml_casadi
