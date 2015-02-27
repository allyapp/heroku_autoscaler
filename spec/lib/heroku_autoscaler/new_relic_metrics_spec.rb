describe HerokuAutoscaler::NewRelicMetrics do
  let(:new_relic_metrics) { described_class.new(print: false) }

  describe "queue_time" do
    let(:queue_time) do
      VCR.use_cassette("new_relic/queue_time") do
        new_relic_metrics.queue_time
      end
    end
    let(:now)       { Time.new(2015, 02, 27, 10, 46, 0) }
    let(:from_time) { (now - 60).to_s }
    let(:to_time)   { now.to_s }
    before do
      allow_any_instance_of(described_class).to receive(:from_time) { from_time }
      allow_any_instance_of(described_class).to receive(:to_time) { to_time }
    end

    describe "returns the metrics" do
      it "with name" do
        expect(queue_time.name).to eq("WebFrontend/QueueTime")
      end

      it "with timeslices" do
        expect(queue_time.from).to be_kind_of(Time)
        expect(queue_time.to).to be_kind_of(Time)
      end

      it "with values" do
        expect(queue_time.values.average_response_time).to eq(2.0)
      end
    end
  end
end
