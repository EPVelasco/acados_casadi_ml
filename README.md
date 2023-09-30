# acados_casadi_ml
Its a docker file of ML-Casadi, acados and ROS 
## Build Docker
```
git clone https://github.com/EPVelasco/ml_casadi_acados.git
cd ml_casadi_acados
sudo docker build -t ml_casadi_acados .

```
## Run container
```
sudo docker run --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 --rm -it --net=host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name ml_casadi_acados_container --gpus all --cpuset-cpus="0" -v ~/:/epvelasco ml_casadi_acados

```
