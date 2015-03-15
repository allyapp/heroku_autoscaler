describe HerokuAutoscaler::MetricsInterface do
  let(:options) { {} }
  let(:metrics) { described_class.new(options) }
  let(:metric_values) { double(:metric_values, values: double(average_response_time: 50)) }

  before do
    allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:queue_time) { metric_values }
    allow_any_instance_of(HerokuAutoscaler::NewRelicMetrics).to receive(:http_dispatcher) { metric_values }
  end

  describe "queue_time" do
    let(:queue_time) { metrics.queue_time }

    it "returns the queue_time metrics" do
      expect(queue_time).to eq(metric_values)
    end

    describe "queue_average_response_time" do
      let(:average_time) { metrics.queue_average_response_time }

      it "returs the average_response_time value" do
        expect(average_time).to eq(50)
      end
    end
  end

  describe "http_response_time" do
    let(:http_response_time) { metrics.http_response_time }

    it "returns the queue_time metrics" do
      expect(http_response_time).to eq(metric_values)
    end

    describe "http_average_response_time" do
      let(:average_time) { metrics.http_average_response_time }

      it "returs the average_response_time value" do
        expect(average_time).to eq(50)
      end
    end
  end
end
