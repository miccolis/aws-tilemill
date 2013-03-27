# TileMill on AWS

This project describes a simple and fast way to launch TileMill in the cloud. Reasons you might want to do this (vs running locally) include:

 - You need more processing power
 - You want to work realtime styling maps with other cartographers in different places

## Get setup with Amazon AWS

Go to http://aws.amazon.com/ and hit "sign up" to create an Amazon account if you don't already have one.

### Login to the AWS console

Go to https://console.aws.amazon.com and navigate to the ec2 section (https://console.aws.amazon.com/ec2/home). This is where you will be managing your instance(s) once launched.

### Create Key Pair

Now, at this step you need to choose a keypair name that you'll use to login via ssh with later on. If you don't have any keys create them now. Keep in mind here that keypairs are specific to ec2 region.

If you need to create a kep pair, in the left sidebar of the EC2 console click on "Key Pairs". Then click the "Create Key Pair" button. Follow the instructions, and you'll end up with a file locally called `KEY-NAME.pem`.

## Launch TileMill

Download [the cloudformation template](https://raw.github.com/miccolis/aws-tilemill/master/cloudformation/tilemill.template) to your computer.

Navigate to CloudFormation (https://console.aws.amazon.com/cloudformation/home), enter a name for your "Stack" and select "Upload a template file" and upload the file.

On the next screen you'll need to provide the name of the key pair you created, a password for accessing TileMill and select an instance size. If you're not sure about the instance size, just start with `m1.large`, the default.

### Connecting to the instance on the web

It takes a few minutes for AWS to provision your server, and then for TileMill to be installed. So grab a fresh cup of coffee and in 10-15 minutes everything should be running.

Hi again! Head back to the EC2 console. The instances page should show a big green ball indicating the instance is running, click on it to display its metadata. Scroll down through the description details to find the "Public DNS" url, copy and paste it into a web browser. You'll be prompted to enter a username and password. The username is `tilemill` and the password is whatever you set while launching the instance.

If the instance is running, but you can't get to tilemill give it a couple more minutes to finish. After that log into the box via ssh (see below) and see if there are errors in `/var/log/syslog`, `/var/log/puppet.log` or `/var/log/upstart/tilemill.log`.

### Connecting to the instance via ssh

Since TileMill does not offer any way to upload project files you will need to get data onto the machine via ssh.

Now open up a terminal on your local machine and type:

    ssh -i <yourkey>.pem ubuntu@<instance-dns>

An example here would be:

    export TILEMILL_HOST="ec2-54-241-113-11.us-west-1.compute.amazonaws.com"
    export EC2_KEY="mykey.pem"
    ssh -i ${EC2_KEY} ubuntu@${TILEMILL_HOST}

Just exchange `<yourkey>` for the full path to the keypair that you downloaded and `<instance-dns>` with the full url that you just copied.

### Setting up project files

On the remote server the documents folder should exist at `/home/tilemill/Documents/MapBox`. Say you have self contained project on your local machine you'd like to upload you could do this by opening a terminal locally and typing this command:

    export PROJECT_NAME="<somemap>"
    scp -i ${EC2_KEY} -r ~/Documents/MapBox/project/${PROJECT_NAME} ubuntu@${TILEMILL_HOST}:/home/tilemill/Documents/MapBox/

Make sure to change `<somemap>` to refer to the name of the project folder that exists locally which you want to upload.

Using `git` may be easier to transfer files and keep them versioned. Say you wanted to populate your remote server with the example projects from https://github.com/springmeyer/tilemill-examples. You could do that like:

    cd /home/tilemill/Documents/MapBox/project
    git init .
    git remote add origin git://github.com/springmeyer/tilemill-examples.git
    git pull origin master

### Note about Instance Sizes

Choose an instance type with at least >= 2GB ram and multiple cores. Go as big as you like, just make sure you don't let the machine run for more than a few days or forget to shut it down otherwise you'll be surprised by the bill at the end of the month. See [this page](http://aws.amazon.com/ec2/pricing/#on-demand) for pricing details per instance type.

If you just need TileMill running for a relatively short period of time consider using spot pricing. To use spot pricing simply add a line like `"SpotPrice": "0.10",` in the `TileMillLaunchConfig` section of the cloudformation template. For example just above the `UserData` script.

### Note about "shutdown behavior".

Whenever you `terminate` this instance you will loose your data!

## Learn more

 https://gist.github.com/springmeyer/b0bbcd976378cf3e4e44

 https://gist.github.com/2164897
