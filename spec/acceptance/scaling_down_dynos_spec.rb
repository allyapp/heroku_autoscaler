describe "Scaling down dynos" do
  let(:cache) { HerokuAutoscaler::CacheStore.new }
  let(:autoscale) do
    VCR.use_cassette("scaling_down_dynos") do
      HerokuAutoscaler::Scaler.new.autoscale
    end
  end

  context "when the queueing average response time is < than the threshold specified to scale down dynos" do
    let(:from_time) { to_time - 60 }
    let(:to_time)   { Time.new(2015, 2, 27, 13, 35, 0, "+00:00") }

    before do
      cache.set("last-scale", last_scale)
      allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:from_time) { from_time }
      allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:to_time) { to_time }
      allow_any_instance_of(HerokuAutoscaler::Scaler).to receive(:now) { to_time }
    end

    context "when last time the server scaled was >= than the frequency to scale down" do
      let(:last_scale) { to_time - 60 * 100 }

      it "scales down from 2 dynos to 1 dyno" do
        expect(autoscale).to eq(1)
      end
    end

    context "when last time the server scaled was < than the frequency to scale down" do
      let(:last_scale) { to_time - 20 }

      it "doesn't scale dynos down" do
        expect(autoscale).to be_nil
      end
    end
  end
end
