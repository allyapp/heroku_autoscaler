describe HerokuAutoscaler::Setter do
  class TestClass
    include HerokuAutoscaler::Setter

    FREQ_UPSCALE   = 50
    FREQ_DOWNSCALE = 100
    TIMER          = 10
    KEY            = "API-KEY"

    attr_accessor :freq_upscale, :freq_downscale, :timer, :key

    def initialize(options)
      writers_setting(options)
    end
  end

  let(:instance) { TestClass.new(freq_upscale: freq_upscale, freq_downscale: freq_downscale, timer: timer) }

  describe "writers_setting" do
    let(:freq_upscale)   { nil }
    let(:freq_downscale) { nil }
    let(:timer)          { nil }

    context "when attributes are not passed and ENV variable is not set" do
      it "sets the values from the constants" do
        expect(instance.timer).to eq(10)
      end
    end

    context "when attributes are not passed, but the ENV variable is set" do
      it "sets the values from the ENV variables" do
        expect(instance.freq_upscale).to eq(30)
        expect(instance.freq_downscale).to eq(60)
      end
    end

    context "when attributes are passed in the params" do
      let(:freq_upscale)   { 20  }
      let(:freq_downscale) { 120 }
      let(:timer)          { 5   }

      it "sets the values from the params" do
        expect(instance.freq_upscale).to eq(20)
        expect(instance.freq_downscale).to eq(120)
        expect(instance.timer).to eq(5)
      end
    end

    context "when an ENV variable is not a number" do
      it "returns sets the string" do
        expect(instance.key).to eq("API-KEY")
      end
    end
  end
end
