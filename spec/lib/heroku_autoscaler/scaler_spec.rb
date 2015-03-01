describe HerokuAutoscaler::Scaler do
  let(:options) do
    {
      freq_upscale:         30,
      freq_downscale:       60,
      min_dynos:            1,
      max_dynos:            4,
      upscale_queue_time:   100,
      downscale_queue_time: 30
    }
  end
  let(:scaler)  { described_class.new(options) }
  let(:dynos)   { 2 }
  let(:metrics) { double(queue_time: double) }
  let(:cache)   { HerokuAutoscaler::CacheStore.new }
  let(:heroku_class) { HerokuAutoscaler::Heroku }
  let(:alerter_class) { HerokuAutoscaler::Alerter }

  before do
    allow_any_instance_of(heroku_class).to receive(:dynos) { dynos }
    allow_any_instance_of(described_class).to receive(:metrics) { metrics }
    allow_any_instance_of(described_class).to receive(:average_response_time) { average_response_time }
    allow_any_instance_of(alerter_class).to receive(:failed_upscale_alert)
  end

  RSpec.shared_examples "doesn't scale dynos" do
    it "and in fact it doesn't" do
      expect_any_instance_of(heroku_class).to_not receive(:scale_dynos)
      scaler.autoscale
    end
  end

  RSpec.shared_examples "after scaling" do
    it "restarts the event counters" do
      expect_any_instance_of(alerter_class).to receive(:restart_event_counters)
      scaler.autoscale
    end
    it "sets the last scale to now" do
      expect_any_instance_of(HerokuAutoscaler::CacheStore).to receive(:set_now).with("last-scale")
      scaler.autoscale
    end
  end

  RSpec.shared_examples "scaling dynos up" do
    it "increases the number of dynos" do
      expect_any_instance_of(heroku_class).to receive(:scale_dynos).with(dynos + 1)
      scaler.autoscale
    end
    it_behaves_like "after scaling"
  end

  RSpec.shared_examples "scaling dynos down" do
    it "decreases the number of dynos" do
      expect_any_instance_of(heroku_class).to receive(:scale_dynos).with(dynos - 1)
      scaler.autoscale
    end
    it_behaves_like "after scaling"
  end

  describe "autoscale" do
    before do
      allow_any_instance_of(heroku_class).to receive(:scale)
    end

    describe "upscaling" do
      let(:dynos) { 1 }
      context "when average response time is more than UPSCALE_QUEUE_TIME" do
        let(:average_response_time) { 400 }

        context "and the last time dynos were scaled was more than the frequency to upscale" do
          before do
            cache.set("last-scale", Time.now - 31)
          end

          context "and when the dynos are still inferior than the maximum dynos allowed to scale" do
            before do
              allow_any_instance_of(heroku_class).to receive(:scale_dynos) { dynos + 1 }
            end

            context "when params are taken from the arguments" do
              it_behaves_like "scaling dynos up"
            end

            context "when params are taken the ENV variables" do
              let(:params) { {} }
              it_behaves_like "scaling dynos up"
            end

            context "when values are taken the default constants" do
              let(:params) { {} }
              before do
                allow_any_instance_of(described_class).to receive(:env_value) { nil }
              end

              it_behaves_like "scaling dynos up"
            end
          end

          context "and when the dynos are equal than the maximum dynos allowed to scale up" do
            let(:dynos) { 4 }

            it "failed_upscale_alert is called" do
              expect_any_instance_of(alerter_class).to receive(:failed_upscale_alert)
              scaler.autoscale
            end

            it_behaves_like "doesn't scale dynos"
          end
        end

        context "and the last time dynos were scaled was less than the frequency to upscale up" do
          before do
            cache.set("last-scale", Time.now - 20)
          end

          it_behaves_like "doesn't scale dynos"
        end
      end

      context "when average response time is less than UPSCALE_QUEUE_TIME" do
        let(:average_response_time) { 50 }

        it_behaves_like "doesn't scale dynos"
      end
    end

    describe "downscaling" do
      context "when average response time is less than DOWNSCALE_QUEUE_TIME" do
        let(:average_response_time) { 10 }

        context "when the last time dynos were scaled was more than the frequency to downscale" do
          before do
            cache.set("last-scale", Time.now - 61)
          end

          context "when the dynos are still higher than the minimum dynos allowed to scale down" do
            before do
              allow_any_instance_of(heroku_class).to receive(:scale_dynos) { dynos - 1 }
            end
            let(:dynos) { 3 }

            context "when params are taken from the arguments" do
              it_behaves_like "scaling dynos down"
            end

            context "when params are taken the ENV variables" do
              let(:params) { {} }
              it_behaves_like "scaling dynos down"
            end

            context "when values are taken the default constants" do
              let(:params) { {} }
              before do
                allow_any_instance_of(described_class).to receive(:env_value) { nil }
              end

              it_behaves_like "scaling dynos down"
            end
          end
        end

        context "when the last time dynos were scaled was less than the frequency to downscale" do
          before do
            cache.set("last-scale", Time.now - 59)
          end

          it_behaves_like "doesn't scale dynos"
        end
      end

      context "when average response time is more than DOWNSCALE_QUEUE_TIME" do
        let(:average_response_time) { 52 }

        it_behaves_like "doesn't scale dynos"
      end
    end
  end
end
