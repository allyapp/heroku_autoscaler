describe HerokuAutoscaler::Heroku do
  let(:heroku) { described_class.new }
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
    it "calls scale_dynos for the heroku app" do
      expect(account).to receive(:post_ps_scale).with(ENV.fetch("HEROKU_APP_NAME"), "web", new_dynos)
      heroku.scale_dynos(new_dynos)
    end
  end
end
