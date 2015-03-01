describe HerokuAutoscaler::Heroku do
  let(:cache)  { HerokuAutoscaler::CacheStore.new }
  let(:heroku) { described_class.new(cache) }
  let(:heroku_app) do
    double(data: { body: { "dynos" => 3 } })
  end
  let(:new_dynos) { 4 }
  let(:account) { double(:account) }
  before do
    allow(Heroku::API).to receive(:new).with(api_key: ENV.fetch("HEROKU_API_KEY")) { account }
    allow(account).to receive(:get_app).with(ENV.fetch("HEROKU_APP_NAME")) { heroku_app }
    allow(account).to receive(:post_ps_scale)
  end

  describe "account" do
    it "returns the heroku account" do
      expect(heroku.account).to eq(account)
    end
  end

  describe "dynos" do
    it "returns the current number of dynos" do
      expect(heroku.dynos).to eq(3)
    end
  end

  describe "app" do
    it "returns the heroku app" do
      expect(heroku.app).to eq(heroku_app)
    end
  end

  describe "scale_dynos" do
    before do
      allow(account).to receive(:post_ps_scale) { double(body: new_dynos) }
    end

    it "calls post_ps_scale with the right arguments" do
      expect(account).to receive(:post_ps_scale).with(ENV.fetch("HEROKU_APP_NAME"), "web", new_dynos)
      heroku.scale_dynos(new_dynos)
    end

    context "when the scaling was successful" do
      it "returns the number of dynos scaled" do
        expect(heroku.scale_dynos(new_dynos)).to eq(new_dynos)
      end
    end

    context "when the scaling was not successful" do
      before do
        allow(account).to receive(:post_ps_scale) { double(body: 3) }
      end

      it "returns nil" do
        expect(heroku.scale_dynos(new_dynos)).to be_nil
      end
    end
  end
end
