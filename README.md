# abagnale

The simplest possible impostor for a credit card processor.

## Installation

    git clone https://github.com/actblue/abagnale.git
    bundle install
    createdb abagnale
    rake db:migration
    bundle exec ruby app.rb

## Usage

    curl -v -X POST -d @examples/request_orbital_auth.xml http://localhost:4567/authorize
    curl -v -X POST -d @examples/request_orbital_auth.xml http://abagnale.heroku.com/authorize
    curl -v -X POST -d @examples/request_litle_auth.xml http://localhost:4567/vap/communicator/online
    curl -v -X POST -d @examples/request_litle_auth.xml http://abagnale.heroku.com/vap/communicator/online
    curl -v -X POST -d @examples/request_litle_settle_batch.xml http://localhost:4567/
    curl -v -X POST -d @examples/request_litle_settle_batch_with_360_error.xml http://localhost:4567/
    curl -v -X POST -d @examples/request_litle_settle_batch_with_invalid_merchant_id_error.xml http://localhost:4567/

On the web: [http://abagnale.heroku.com/](http://abagnale.heroku.com/) will give you a list of all processed transactions.
