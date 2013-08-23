cydoemus
========

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
`git clone git@github.com:josephwegner/cydoemus.git`

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

Go to [http://localhost:3333/api/v0/keys](http://localhost:3333/api/v0/keys)
