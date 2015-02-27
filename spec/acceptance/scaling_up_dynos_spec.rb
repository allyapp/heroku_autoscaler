describe "Scaling up dynos" do
  let(:cache) { HerokuAutoscaler::CacheStore.new }

  context "when the queueing average response time is >= than the threshold specified to scale up dynos" do
    let(:from_time) { to_time - 60 }
    let(:to_time)   { Time.new(2015, 2, 27, 13, 23, 0, "+00:00") }
    let(:autoscale) do
      VCR.use_cassette("scaling_up_dynos") do
        HerokuAutoscaler::Scaler.new.autoscale
      end
    end
    before do
      cache.set("last-scale", last_scale)
      allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:from_time) { from_time }
      allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:to_time) { to_time }
      allow_any_instance_of(HerokuAutoscaler::Scaler).to receive(:now) { to_time }
    end

    context "when last time the server scaled was >= than the frequency to scale up" do
      let(:last_scale) { to_time - 60 * 100 }

      it "scales dynos up from 1 to 2" do
        expect(autoscale).to eq(2)
      end
    end

    context "when last time the server scaled was < than the frequency to scale up" do
      let(:last_scale) { to_time - 20 }

      it "doesn't scale dynos up" do
        expect(autoscale).to be_nil
      end
    end
  end

  # context "when the average response time is higher than the one specified to scale dynos and it can't scale up" do
  # end
end
