cy
========

Cy was built to be used with the [open source](http://github.com/waltzio/waltz) [password helper, Waltz](https://getwaltz.com).

Generates Cryptographically Secure Reusable Keys

# Install

## Dependencies
- Obviously, you need to install [node.js](http://nodejs.org).
- [MongoDB](http://www.mongodb.org/)
- You might need to install CoffeeScript globally.  I'm honestly not sure.  
`npm install coffee-script -g` *this might need some sudo magic*
- [Foreman](https://github.com/ddollar/foreman) is optional


## The Actual Server
1. Check it out  
`git clone git@github.com:josephwegner/cy.git`

2. Get in there  
`cd cydoemus`

3. Install those modules  
`npm install`

4. Start that server   
If you're using foreman:  
`foreman start -f Procfile.local`  
If you're not using foreman:  
`mongod`   
then  
`coffee index`  

# Usage
For now, it just generates a random key.  And doesn't do anything with it.

# Deploy

Visit Digital Ocean
Boot up an instance with Ubuntu 13.04 x64
SSH in to your brand new server
Install dokku

    jesse@remote: wget -qO- https://raw.github.com/progrium/dokku/master/bootstrap.sh | sudo bash

    jesse@remote: touch /home/dokku/VHOST
    jesse@remote: echo <your_domain_name> > /home/dokku/VHOST

    jesse@local: cat ~/.ssh/id_rsa.pub| ssh user@<your_domain_name> "sudo sshcommand acl-add dokku <your_name>"
    jesse@local: git clone https://github.com/waltzio/cy
    jesse@local: git remote add deploy dokku@<your_domain_name>:cy
    jesse@local: git push deploy master

    jesse@remote: vi /home/dokku/cy/ENV

        export CLEF_APP_ID=<YOUR_CLEF_APP_ID>
        export CLEF_APP_SECRET=<YOUR_CLEF_APP_SECRET>
        export MONGOLAB_URI=<MONGO_LAB_URI>
        export NODE_ENV=production
        export application_env=production
        export URL=<URL_OF_APP>
        export HOST=<URL_MINUS_PROTOCAL_AND_PORT>

    jesse@remote: cd /home/dokku/cy
    jesse@remote: mkdir ssl
    jesse@remote: touch server.crt (add actual SSL certificate)
    jesse@remote: touch server.key (add actual SSL private key)

    jesse@local: git commit --allow-empty -m "sets up environment variables and ssl"
    jesse@local: git push deploy master


Go to [http://localhost:3333/api/v0/keys](http://localhost:3333/api/v0/keys)
