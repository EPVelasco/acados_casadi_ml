# acados_casadi_ml
Its a docker file of ML-Casadi, Acados and ROS-Noetic or AMD architecture.
## Build Docker
```
git clone https://github.com/EPVelasco/acados_casadi_ml.git
cd acados_casadi_ml
sudo docker build -t acados_casadi_ml .
```
## Run container
```
sudo docker run --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 --rm -it --net=host -e DISPLAY=:0 --user=1000:1000 --name acados_casadi_ml_container --gpus all --cpuset-cpus=0-2 -v /home/epvs/:/epvelasco acados_casadi_ml

```
