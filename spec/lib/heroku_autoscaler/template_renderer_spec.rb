describe HerokuAutoscaler::TemplateRenderer do
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
  let(:metric) { HerokuAutoscaler::Metric.new(metric_hash) }

  describe "alert" do
    let(:alert_template) { described_class.alert(type, 3, metric, 179.234, 100) }

    context "html" do
      let(:type) { "html" }
      let(:html_table) do
        "<table>\n        <tr>\n          <td class=\"label\">Metric</td>\n          <td class=\"label\">Value</td>\n        </tr>\n        \n          <tr>\n            <td>Average response time</td>\n            <td>2.0</td>\n          <tr>\n        \n          <tr>\n            <td>Calls per minute</td>\n            <td>1.94</td>\n          <tr>\n        \n          <tr>\n            <td>Call count</td>\n            <td>0</td>\n          <tr>\n        \n          <tr>\n            <td>Min response time</td>\n            <td>1.9</td>\n          <tr>\n        \n          <tr>\n            <td>Max response time</td>\n            <td>2.1</td>\n          <tr>\n        \n          <tr>\n            <td>Average exclusive time</td>\n            <td>2.0</td>\n          <tr>\n        \n          <tr>\n            <td>Average value</td>\n            <td>0.002</td>\n          <tr>\n        \n          <tr>\n            <td>Total call time per minute</td>\n            <td>0.0039</td>\n          <tr>\n        \n          <tr>\n            <td>Requests per minute</td>\n            <td>1.94</td>\n          <tr>\n        \n          <tr>\n            <td>Standard deviation</td>\n            <td>0.0</td>\n          <tr>\n        \n      </table>"
      end

      it "renders the html alert template" do
        expect(alert_template).to include(html_table)
      end
    end

    context "text" do
      let(:type) { "text" }

      it "renders the text alert template" do
        expect(alert_template).to include("- The average request queueing time is over: 100 miliseconds")
        expect(alert_template).to include("WebFrontend/QueueTime")
        expect(alert_template).to include("Average response time: 2.0")
        expect(alert_template).to_not include("<html>")
      end
    end
  end
end

