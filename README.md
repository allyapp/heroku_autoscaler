# HerokuAutoscaler

WIP (Work In Progress)

Configurable heroku dynos' auto-scaler that read from NewRelic metrics in order to act upon the heroku instance configured.

Initially it will only read the ``WebFrontend/QueueTime`` metric in the last minute time lapse to consider up or downscaling dynos according to the configuration values set.

When the auto-scaler can't upscale dynos due the maximum number of dynos set was too small for a specified period of time, it will send an email alerting that this value should be increased with the last minute ``WebFrontend/QueueTime`` metrics summary.

## Dependencies

- [Dalli](https://github.com/mperham/dalli) cache store.
- A scheduler. Here are some recommended alternatives:
    * [Heroku scheduler](https://addons.heroku.com/scheduler)
    * [Rufus scheduler](https://github.com/jmettraux/rufus-scheduler)
- [Mail](https://github.com/mikel/mail) (if you want to get email alerts).
- [New Relic](https://addons.heroku.com/newrelic) addon configured for the heroku instance.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'heroku_autoscaler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heroku_autoscaler

## Usage

In order to start using this gem, please read carefully all the configurable variables to get it running accordingly to your needs.

### Configuration

To have it working it's mandatory to already have the following ENV variables set:

#### External depencies: Heroku, NewRelic and Dalli

````ruby
HEROKU_API_KEY = 12b5c169b-78a6-4ax-144b-7d9a17zd6050
HEROKU_APP_NAME = test-heroku-app
NEW_RELIC_API_KEY = 1ee6ffffef5e1f7e609d86aea050f6d123nasd124asd
NEW_RELIC_APP_ID = 6425276
MEMCACHE_SERVERS = 127.0.0.1
````

#### Auto-scaling

It's not mandatory, but advisable to also have the following variables set as ENV variables to quickly change a value without the need of deploying.
All these variables can be also set when the ``HerokuAutoscaler::Scaler`` class is instantiated. 

````ruby
MIN_DYNOS = 1
MAX_DYNOS = 2
FREQ_UPSCALE = 30
FREQ_DOWNSCALE = 60
FAILED_UPSCALES_ALERT = 4
ALERT_FREQUENCY = 60
UPSCALE_QUEUE_TIME = 100
DOWNSCALE_QUEUE_TIME = 30
EXEC_FREQUENCY = 15
````

If some of these variables are not set as ENV variable or passed in the arguments when the class is instantiated, the default values (which correspond the ones above) will be set. 

* ``min_dynos:`` Minimum number of dynos it can be downscaled.
* ``max_dynos:`` Maximum number of dynos it can be upscaled.
* ``freq_upscale:`` Maximum frequency the heroku instance can upscale (seconds).
* ``freq_downscale:`` Maximum frequency the heroku instance can downscale (seconds).
* ``failed_upscales_alert:`` If the mailer is configured, the number of failed upscales that have to occur in order to send an alert email.
* ``alert_frequency:`` Maximum frequency alert emails will be sent (seconds).
* ``upscale_queue_time:`` Maximum queue time average to start upscaling (miliseconds).
Recommendation: start upscaling after 100ms of request queueing time if the availability is not too critical.
* ``downscale_queue_time:`` Minimum queue time average to start downscaling (miliseconds).
Recommendation: Set a few miliseconds of margin to start downscaling, don't set the value to 0ms because unless there's no server load, it might not downscale.
* ``exec_frequency:`` Frequency the auto-scaler is being executed. It will be used for calculating the failed upscale alerts, it also has to be configured in the scheduler (seconds).

#### Mailer

As mailer, the gem [Mail](https://github.com/mikel/mail) has been used to send the alert emails. The idea is to eventually decouple this depency, but for the time being it will be kept.

````ruby
email_config = {
    delivery_method: :smtp,
    address: "smtp.gmail.com",
    port: 587,
    domain: "test.com",
    user_name: "user@test.com",
    password: "password",
    enable_starttls_auto: true,
    to: "developers@test.com"
}
````

The sender will be set from the ``email_config[:user_name]`` while the receiver from ``email_config[:to]``.

#### Scheduler

After having configured the 3 sections above (external dependencies, auto-scaling and mailer), it's time to start running the heroku auto-scaler:

````ruby
options = {
  logging: true,              # false by default. Logs WebFrontend/QueueTime metrics whenever the autoscale function is executed
  send_email: true,           # false by default. Boolean required to send emails, even configuration is sent
  email_config: email_config, # Taking as example the ruby hash defined previously
}

# If auto-scaling values are not set as ENV variables.
# Values passed as params will have priority over ENV variables.
# You might want to have some values set as ENV variables and other as arguments, it's up to you.

autoscaling_options = {
  min_dynos: 1,
  max_dynos: 4,
  freq_upscale: 30,          # 30 secs
  freq_downscale: 60,        # 60 secs
  failed_upscales_alert: 4,
  alert_frequency: 60,       # 60 secs
  upscale_queue_time: 100,   # 100 milisecs
  downscale_queue_time: 30,  # 30 milisecs
  exec_frequency: 15         # 15 milisecs
}

# This is the method that should be executed with the desired frequency using the scheduler

HerokuAutoscaler::Scaler.new(options.merge(autoscaling_options)).autoscale
````

## Contributing

1. Fork it ( https://github.com/[my-github-username]/heroku_autoscaler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
