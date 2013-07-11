# abagnale

The simplest possible impostor for a credit card processor.

## Installation

    git clone https://github.com/actblue/abagnale.git
    bundle install
    createdb abagnale
    rake db:migration
    ruby app.rb

## Usage

    curl -v -X POST -d @examples/request_litle_auth.xml http://localhost:4567/vap/communicator/online
    curl -v -X POST -d @examples/request_litle_auth.xml http://abagnale.heroku.com/vap/communicator/online

On the web: [http://abagnale.heroku.com/](http://abagnale.heroku.com/) will give you a list of all processed transactions.
