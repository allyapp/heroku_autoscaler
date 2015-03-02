describe HerokuAutoscaler::Alerter do
  let(:cache) { HerokuAutoscaler::CacheStore.new }
  let(:dynos) { 2 }
  let(:metrics) { double(:metrics) }
  let(:freq_upscale) { 30 }
  let(:upscale_queue_time) { 100 }
  let(:failed_event_times_till_now) { 3.5 }
  let(:alert_name) { "failed-upscale" }
  let(:options) { {} }
  let(:mailer) { HerokuAutoscaler::Mailer.new({}) }
  let(:alerter) { described_class.new(cache, mailer) }
  let(:failed_upscale_alert) do
    alerter.failed_upscale_alert(dynos, metrics, freq_upscale, upscale_queue_time)
  end

  before do
    allow_any_instance_of(HerokuAutoscaler::Mailer).to receive(:request_queueing_alert)
    allow_any_instance_of(HerokuAutoscaler::CacheStore).to receive(:set_now)
  end

  RSpec.shared_examples "sends a request_queueing_alert alert" do
    it "sends an email" do
      expect_any_instance_of(HerokuAutoscaler::Mailer).to receive(:request_queueing_alert)
      failed_upscale_alert
    end
    it "sets the time when the alert was sent" do
      expect(cache).to receive(:set_now)
      failed_upscale_alert
    end
  end

  RSpec.shared_examples "doesn't send a request_queueing_alert alert" do
    it "doesn't send an email" do
      expect_any_instance_of(HerokuAutoscaler::Mailer).to_not receive(:request_queueing_alert)
      failed_upscale_alert
    end
    it "doesn't set the time when the alert was sent" do
      expect(cache).to_not receive(:set_now)
      failed_upscale_alert
    end
  end

  describe "restart_event_counters" do
  end

  describe "failed_upscale_alert" do
    before do
      cache.set(alert_name, failed_event_times_till_now)
    end
    after { cache.delete(alert_name) }

    it "increments the failed_event_times stored in the cache" do
      failed_upscale_alert
      expect(cache.fetch(alert_name)).to eq(4)
    end

    context "when the number of failed upscales is >= than the number times this event happens set to send an alert" do
      context "when an alert was not sent previously" do
        before { cache.delete("alert-sent:#{alert_name}") }

        it_behaves_like "sends a request_queueing_alert alert"
      end

      context "when the alert frequency is <= than the previous time that last alert was sent" do
        before { cache.set("alert-sent:#{alert_name}", Time.now - 20 * 60) }
        after  { cache.delete("alert-sent:#{alert_name}") }

        context "and the mailer is configured" do
          it_behaves_like "sends a request_queueing_alert alert"
        end

        context "and the mailer is not configured" do
          let(:mailer) { nil }

          it_behaves_like "doesn't send a request_queueing_alert alert"
        end
      end

      context "when the alert frequency is > than the previous time that last alert was sent" do
        before { cache.set("alert-sent:#{alert_name}", Time.now - 20) }
        after  { cache.delete("alert-sent:#{alert_name}") }

        it_behaves_like "doesn't send a request_queueing_alert alert"
      end
    end

    context "when the number of failed upscales is < than the number times this event happens set to send an alert" do
      let(:failed_event_times_till_now) { 1 }

      it_behaves_like "doesn't send a request_queueing_alert alert"
    end
  end
end
