# CSC0056 Homework 4, Part 2

* Submit your answer to Moodle before 9AM, December 7th (**Monday**)

This is the second part of Homework 4, and it accounts for 40 points.

### 1. Setting up customized publishers/subscribers (10 points)

First of all, pull the latest version of our mosquitto from the CSC0056 repository. At your mosquitto directory, type

`$ git pull`

which should download everything necessary to complete this part of the homework.

Now, different from Homework 3, we are going to compile and use our customized mosquitto publishers/subscribers. The code for both publisher and subscriber is located in folder *client*. 

At folder *mosquitto*, type `make` to compile both broker, publisher, and subscriber.

Our compilation will produce a shared library *libmosquitto.so.1* in folder *lib*. This shared library will be used by both our publisher and subscriber at runtime, and we need to make it known by them. We achieve this by updating our system's environment variable *LD_LIBRARY_PATH* to include the path to the library. This update will only apply to the current user and thus will not mess up the system-wide setting. Type the following to modify your bash configuration:

`$ vim ~/.bashrc`

And the add the following line at the end of the file:

`LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/cw2/repos/mosquitto/lib/; export LD_LIBRARY_PATH`

Save the change and close the file. Then type the following to have our update came into effect:

`$ source ~/.bashrc`

In  

For your interest, try sending the following image as a "message":

<img src="https://upload.wikimedia.org/wikipedia/commons/e/e5/St._Louis_Arch_%281984%29.jpg" style="zoom:20%;" />

(The above image is from Wikimedia: https://commons.wikimedia.org/wiki/File:St._Louis_Arch_(1984).jpg. This is the landmark of the dear city where I've sojourned for seven years.)

There is a helper script named `sendImage.sh` for you to try it out. Run the script and a mosquitto subscriber will receive this image and dump it into a file named `output.jpg` :)

### 2. Evaluating Little's Theorem (10 points)

In this part of Homework 3, we will empirically validate the claim we've made in class, that an aggregation of data traffics will often behave as a Poisson process. In particular, we will verify that in data communication, in the presence of many data publishers, the overall inter-arrival times 

### 3. Quality-of-Service in action (20 points)

In this part of Homework 3, we will empirically validate the claim we've made in class, that an aggregation of data traffics will often behave as a Poisson process. In particular, we will verify that in data communication, in the presence of many data publishers, the overall inter-arrival times 

### 4. Summary and things to submit to Moodle

In this part of Homework 3, we will empirically validate the claim we've made in class, that an aggregation of data traffics will often behave as a Poisson process. In particular, we will verify that 