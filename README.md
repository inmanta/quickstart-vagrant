# Quickstart using Vagrant

This project is part of the [Quickstart guide for the Inmanta automation and orchestration tool.](http://inmanta.readthedocs.io/en/latest/quickstart.html) 

Setting up the tutorial
=========================

To quickly get started with Inmanta, use Vagrant to set up an environment to host the 
Inmanta server and some machines to be managed. 
Before starting this tutorial, first [install Vagrant on your machine](https://www.vagrantup.com/docs/installation/). 

 
Next, grab the Vagrant box from our Git repo and let Vagrant do the setup of the Inmanta server.

```sh
git clone https://github.com/inmanta/quickstart-vagrant.git
cd quickstart-vagrant
./make_keys.sh
vagrant up
```

Vagrant will set up the Inmanta server and two VMs to experiment on. When Vagrant is ready, you should be able to open the dashboard at http://127.0.0.1:8888.  

To get a shell on the Inmanta server:

    vagrant ssh server


Create an Inmanta project
==========================

An Inmanta project bundles modules that contain configuration information. A project is nothing more 
than a directory with a project.yml file, which contains parameters such as the location to search for 
modules and where to find the server.

Here we will create an Inmanta project called ``quickstart``, with a basic configuration file.

    mkdir quickstart
    cd quickstart
    cat > project.yml <<EOF
    name: quickstart
    modulepath: libs
    downloadpath: libs
    repo: https://github.com/inmanta/
    description: A quickstart project that installs a drupal website.
    EOF

    
The configuration file ``project.yml`` defines that reusable modules are stored in ``libs``. 

In the next section we will use existing modules to deploy our LAMP stack.

Reuse existing modules
=======================

At GitHub, we host modules to setup and manage many systems. Our modules are available in the https://github.com/inmanta/ repositories.

When you use an import statement in your model, Inmanta downloads these modules and their dependencies automatically. 


The configuration model
=======================

In this section we will use the configuration concepts defined in the existing modules to set up a Drupal website on the host named ``vm1``.

First, create a new ``main.cf`` file:

    import ip
    import redhat
    import apache
    import mysql
    import web
    import drupal

    # define the machine we want to deploy Drupal on
    vm1=ip::Host(name="vm1", os=redhat::fedora23, ip="192.168.33.101")

    # add a mysql and apache http server
    web_server=apache::Server(host=vm1)
    mysql_server=mysql::Server(host=vm1)

    # deploy drupal in that virtual host
    name=web::Alias(hostname="localhost")
    db=mysql::Database(server=mysql_server, name="drupal_test", user="drupal_test",
                       password="Str0ng-P433w0rd")
    drupal::Application(name=name, container=web_server, database=db, admin_user="admin",
                        admin_password="test", admin_email="admin@example.com", site_name="localhost")


* Lines 1-6 import all required packages.  
* Line 9 defines on which host we want to deploy Drupal. 
 * The *name* attribute is the host name of the machine, which is later used to determine what configuration needs to be deployed on which machine. 
 * The *os* attribute defines which operating system this server runs. This is used to select the right tools (yum, dnf or apt).
 * The *ip* attribute is the IP address of this host. At this moment we define this attribute manually, later in the tutorial we let Inmanta discover this automatically.
* Lines 12 and 13 deploy an Apache server and MySQL server on our host.
* Line 16 defines the name (host name) of the web application.
* Lines 17-18 define a database for our Drupal website.
* Lines 19-20 define the actual Drupal application.



Deploy the configuration model
------------------------------

To deploy this configuration model, we must first register it with the Inmanta server, by creating a project and an environment. This can be done via the dashboard, or via the CLI. 
For the CLI:

    inmanta-cli project-create -n test
    inmanta-cli environment-create  -n test -p test -r $(pwd) -b master --save
    

The ``--save`` option tells ``inmanta-cli`` to store the environment config in the ``.inmanta`` file. The compiler uses this file to find the server and to export to the right environment.
	
Then compile the project and send it to the server:

    inmanta -vvv  export
    
The first time you run this command may take a while, as all dependencies are downloaded.  When it is done, go to the [dashboard](http://127.0.0.1:8888).  

Go to your environment, and press Deploy.

Accessing your new Drupal server
---------------------------------

When the install is done, you can access your new Drupal server at <http://localhost:8080/>.


# Next steps

Continue the tutorial at http://inmanta.readthedocs.io/en/latest/quickstart.html#managing-multiple-machines