describe "Sending email alert due maximum of dynos reached" do
  let(:cache) { HerokuAutoscaler::CacheStore.new }
  let(:email_config) do
    {
      delivery_method: :test,
      address: "smtp.gmail.com",
      port: 587,
      domain: "test.com",
      user_name: "user@test.com",
      password: "pass",
      enable_starttls_auto: true,
      to: "customer@gmail.com"
    }
  end
  let(:config) do
    {
      logging: true,
      send_email: true,
      email_config: email_config,
      failed_upscales_alert: 5,
      max_dynos: 1
    }
  end

  let(:from_time)  { to_time - 60 }
  let(:to_time)    { Time.new(2015, 2, 27, 13, 23, 0, "+00:00") }
  let(:last_scale) { to_time - 60 * 100 }
  let(:autoscale) do
    VCR.use_cassette("scaling_up_dynos") do
      HerokuAutoscaler::Scaler.new(config).autoscale
    end
  end
  before do
    cache.set("last-scale", last_scale)
    cache.set("failed-upscale", failed_upscale)
    allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:from_time) { from_time }
    allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:to_time) { to_time }
    allow_any_instance_of(HerokuAutoscaler::Scaler).to receive(:now) { to_time }
  end

  after do
    cache.delete("last-scale")
    cache.delete("failed-upscale")
    cache.delete("alert-sent:failed-upscale")
  end

  describe "when it can't upscale" do
    include Mail::Matchers

    let(:failed_upscale) { 4.5 }

    describe "and the tries to upscale didn't reach the threshold to send the alert" do
      let(:failed_upscale) { 4 }

      it "doesn't send an email" do
        autoscale
        should_not have_sent_email
      end
    end

    describe "and the tries to upscale reached the threshold to send the alert, but the alert was sent recently" do
      before do
        cache.set("alert-sent:failed-upscale", Time.now - 10)
      end

      it "doesn't send an email" do
        autoscale
        should_not have_sent_email
      end
    end

    describe "but the tries to upscale reached the threshold to send the alert" do

      it "sends an email" do
        autoscale
        should have_sent_email
      end

      it "sends the email from the right sender" do
        autoscale
        should have_sent_email.from(email_config[:user_name])
      end

      it "sends the email to the right receiver" do
        autoscale
        should have_sent_email.to(email_config[:to])
      end

      it "sends the subject in the email" do
        autoscale
        should have_sent_email.with_subject("Performance Alert: Request Queueing average exceeded")
      end
    end
  end
end
