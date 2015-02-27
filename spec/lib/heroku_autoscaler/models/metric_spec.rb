describe HerokuAutoscaler::Metric do
  let(:metric_hash) do
    {
      "name"       => "WebFrontend/QueueTime",
      "timeslices" => [
        {
          "from"   => "2015-02-27T09:45:52+00:00",
          "to"     => "2015-02-27T09:46:00+00:00",
          "values" => {
            "average_response_time"      => 2.0,
            "calls_per_minute"           => 1.94,
            "call_count"                 => 0,
            "min_response_time"          => 1.9,
            "max_response_time"          => 2.1,
            "average_exclusive_time"     => 2.0,
            "average_value"              => 0.002,
            "total_call_time_per_minute" => 0.0039,
            "requests_per_minute"        => 1.94,
            "standard_deviation"         => 0
          }
        }
      ]
    }
  end

  let(:metric) { described_class.new(metric_hash) }

  describe "parsing from hash set attributes" do
    it "name" do
    end

    it "from" do
    end

    it "to" do
    end

    describe "values" do
      let(:values) { metric.values }
      let(:values_hash) { metric_hash["timeslices"].first["values"] }

      it "average_response_time" do
        expect(values.average_response_time).to eq(values_hash["average_response_time"])
      end

      it "calls_per_minute" do
        expect(values.calls_per_minute).to eq(values_hash["calls_per_minute"])
      end

      it "call_count" do
        expect(values.call_count).to eq(values_hash["call_count"])
      end

      it "average_value" do
        expect(values.average_value).to eq(values_hash["average_value"])
      end

      it "min_response_time" do
        expect(values.min_response_time).to eq(values_hash["min_response_time"])
      end

      it "max_response_time" do
        expect(values.max_response_time).to eq(values_hash["max_response_time"])
      end

      it "average_exclusive_time" do
        expect(values.average_exclusive_time).to eq(values_hash["average_exclusive_time"])
      end

      it "total_call_time_per_minute" do
        expect(values.total_call_time_per_minute).to eq(values_hash["total_call_time_per_minute"])
      end

      it "requests_per_minute" do
        expect(values.requests_per_minute).to eq(values_hash["requests_per_minute"])
      end

      it "standard_deviation" do
        expect(values.standard_deviation).to eq(values_hash["standard_deviation"])
      end
    end
  end
end
