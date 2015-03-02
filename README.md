# HerokuAutoscaler

WIP (Work In Progress)

Configurable heroku dynos' auto-scaler that read from NewRelic metrics in order to act upon the heroku instance configured.

Initially it will only read the ``WebFrontend/QueueTime`` metric in the last minute time lapse to consider up or downscaling dynos according to the configuration values set.

When the auto-scaler can't upscale dynos due the MAX_DYNOS was too small for a specified period of time, it will send an email alerting that this value should be increased with the last minute ``WebFrontend/QueueTime`` metrics summary.

## Dependencies

- Dalli cache store.
- Heroku Scheduler.
- Mail (if you want to get email alerts).
- NewRelic addon configured for the heroku instance.

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

````ruby
HEROKU_API_KEY = 12b5c169b-78a6-4ax-144b-7d9a17zd6050
HEROKU_APP_NAME = test-heroku-app
NEW_RELIC_API_KEY = 1ee6ffffef5e1f7e609d86aea050f6d123nasd124asd
NEW_RELIC_APP_ID = 6425276
MEMCACHE_SERVERS = 127.0.0.1
````

It's not mandatory, but advisable to also have the following variables set as ENV variables to quickly change a value without the need of deploying.
All these variables can be also set when the ``HerokuAutoscaler::Scaler`` class is instanciated. 

````ruby
MIN_DYNOS = 1
MAX_DYNOS = 4
FREQ_UPSCALE = 30
FREQ_DOWNSCALE = 60
FAILED_UPSCALES_ALERT = 4
ALERT_FREQUENCY = 60
UPSCALE_QUEUE_TIME = 100
DOWNSCALE_QUEUE_TIME = 30
EXEC_FREQUENCY = 15
````

* ``min_dynos:`` Minimum number of dynos it can be downscaled.
* ``max_dynos:`` Maximum number of dynos it can be upscaled.
* ``freq_upscale:`` Maximum frequency the heroku instance can upscale (seconds).
* ``freq_downscale:`` Maximum frequency the heroku instance can downscale (seconds).
* ``failed_upscales_alert:`` If the mailer is configured, the number of failed upscales that have to occur in order to send an alert email.
* ``alert_frequency:`` Maximum frequency alert emails will be sent (seconds).
* ``upscale_queue_time:`` Maximum queue time average to start upscaling (miliseconds).
Recommendation: start upscaling after 100ms if the availability is not too critical.
* ``downscale_queue_time:`` Minimum queue time average to start downscaling (miliseconds).
Recommendation: Leave a few miliseconds of margin to start downscaling.
* ``exec_frequency:`` Frequency the scaler is being executed. It will be used for calculating the failed upsacles alert, it also has to be configured in the scheduler (seconds).



## Contributing

1. Fork it ( https://github.com/[my-github-username]/heroku_autoscaler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
