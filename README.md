abagnale
========
The simplest possible impostor for a credit card processor.

This README should probably have some content.

On the web: http://abagnale.heroku.com/

Some sample xml here:

$ curl -v -X POST -d @request_litle.xml http://localhost:9292/vap/communicator/online
$ curl -v -X POST -d @request_litle.xml http://abagnale.heroku.com/vap/communicator/online