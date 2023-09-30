# acados_casadi_ml
Its a docker file of ML-Casadi, acados and ROS 
## Build Docker
```
git clone https://github.com/EPVelasco/acados_casadi_ml.git
cd acados_casadi_ml
sudo docker build -t acados_casadi_ml .

```
## Run container
```
sudo docker run --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 --rm -it --net=host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name acados_casadi_ml_container --gpus all --cpuset-cpus="0" -v ~/:/epvelasco acados_casadi_ml

```
