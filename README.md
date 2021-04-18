SMS App Setup
============

## Prerequisites

Working setup requires `git`, `rails` and `postgres` pre-installed.

## Setting up the SMS App

Clone and move into repository

`git clone https://github.com/muhammed-uk/smsapp2.git`

`cd smsapp2`

create an environment `.env` file and keep the following credentials according to your machine.

```
DB_USER_NAME=your_db_name
DB_PASSWORD=your_db_password
DB_HOST=localhost
DEV_DB=sms_app_dev
TEST_DB=sms_app_test
PROD_DB=sms_app_prod
```

## Installation

from the app directory

```shell
bundle install

rake db:create

rake db:migrate

rails db < db/seed_data/schema.sql
```

## Starting the application

```shell
rails s
```
Now the application should be up and running on port 3000.
If you want to change the port please pass -p PORT_NUMBER

```shell
rails s -p 5000
```

## Running the Test

This application has automated testcases setup with `RSpec`
In order to run the testcase, Please enter

```shell
rspec
```
from app directory.

