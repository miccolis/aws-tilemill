## AWS TileMill

This project describes a simple and fast way to launch TileMill in the cloud. Reasons you might want to do this (vs running locally) include:

 - You need more processing power
 - You want to work realtime styling maps with other cartographers in different places

### Get setup with Amazon AWS

Go to http://aws.amazon.com/ and hit "sign up" to create an Amazon account if you don't already have one.

## Login to the AWS console

Go to https://console.aws.amazon.com and navigate to the ec2 section (https://console.aws.amazon.com/ec2/home). This is where you will be managing your instance(s) once launched.

### Create Key Pair

Now, at this step you need to choose a keypair name that you'll use to login via ssh with later on. If you don't have any keys create them now. Keep in mind here that keypairs are specific to ec2 region.

### Launch an Instance

Navigate to CloudFormation (https://console.aws.amazon.com/cloudformation/home), enter a name for your "Stack" and select "Provide a template URL", and enter the url `[S3-URI]`.

On the next screen you'll need to provide the name of the key pair you created, a password for accessing TileMill and select an instance size.

## Connecting to the instance

Once the instances page shows a big green ball indicating the instance is running, click on it to display its metadata. Scroll down through the description details to find the "Public DNS" url and copy it.

Now open up a terminal on your local machine and type:

    ssh -i <yourkey>.pem ubuntu@<instance-dns>

An example here would be:

    export TILEMILL_HOST="ec2-54-241-113-11.us-west-1.compute.amazonaws.com"
    export EC2_KEY="mykey.pem"
    ssh -i ${EC2_KEY} ubuntu@${TILEMILL_HOST}

Just exchange `<yourkey>` for the full path to the keypair that you downloaded and `<instance-dns>` with the full url that you just copied.

## Setting up project files

Since TileMill does not offer any way to upload project files you will need to get data onto the machine via ssh.

Once you have started TileMill once on the remote server the documents folder should exist at `/home/ubuntu/Documents/MapBox`. Say you have self contained project on your local machine you'd like to upload you could do this by opening a terminal locally and typing this command:

    export PROJECT_NAME="<somemap>"
    scp -i ${EC2_KEY} -r ~/Documents/MapBox/project/${PROJECT_NAME} ubuntu@${TILEMILL_HOST}:/home/ubuntu/Documents/MapBox/

Make sure to change `<somemap>` to refer to the name of the project folder that exists locally which you want to upload.

Using `git` may be easier to transfer files and keep them versioned. Say you wanted to populate your remote server with the example projects from https://github.com/springmeyer/tilemill-examples. You could do that like:

    sudo apt-get -y install git
    cd /home/ubuntu/Documents/MapBox/project
    git init .
    git remote add origin git://github.com/springmeyer/tilemill-examples.git
    git pull origin master

## Accessing TileMill

After starting tilemill on the remote server, then paste $TILEMILL_HOST:20009 into a web browser and you should see your projects.

### Choosing an Instance Size 

Choose an instance type with at least >= 2GB ram and multiple cores. Go as big as you like, just make sure you don't let the machine run for more than a few days or forget to shut it down otherwise you'll be surprised by the bill at the end of the month. See [this page](http://aws.amazon.com/ec2/pricing/#on-demand) for pricing details per instance type.

If you just need TileMill running for a relatively short period of time consider using Spot pricing.

### Note about "shutdown behavior".

Whenever you `terminate` this instance you will loose your data!

## Learn more

 https://gist.github.com/springmeyer/b0bbcd976378cf3e4e44
 https://gist.github.com/2164897
