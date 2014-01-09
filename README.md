# abagnale

The simplest possible impostor for a credit card processor.

## Installation

    git clone https://github.com/actblue/abagnale.git
    bundle install
    createdb abagnale
    rake db:migrate
    ruby app.rb

## Usage

    curl -v -X POST -d @examples/request_orbital_auth.xml http://localhost:4567/authorize
    curl -v -X POST -d @examples/request_litle_auth.xml http://localhost:4567/vap/communicator/online
    curl -v -X POST -d @examples/request_litle_settle_batch.xml http://localhost:4567/
    curl -v -X POST -d @examples/request_litle_credit.xml http://localhost:4567/vap/communicator/online

[http://localhost:4567/](http://localhost:4567/) will give you a list of all processed transactions.

There is a test server in Heroku:

    curl -v -X POST -d @examples/request_orbital_auth.xml http://abagnale.herokuapp.com/authorize
