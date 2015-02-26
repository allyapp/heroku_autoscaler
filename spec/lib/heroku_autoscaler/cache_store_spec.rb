describe HerokuAutoscaler::CacheStore do
  let(:cache) { described_class.new }

  describe "set" do
    let(:key)   { "value" }
    let(:value) { "foo" }
    before { cache.set(key, value) }
    after  { cache.delete(key)     }

    it "sets the value under a key" do
      expect(cache.fetch(key)).to eq(value)
    end
  end

  describe "set_now" do
    let(:key) { "last-scale" }
    let(:now) { Time.new(2015, 03, 01) }
    before do
      allow(Time).to receive(:now) { now }
      cache.set_now(key)
    end
    after { cache.delete(key) }

    it "sets the time now" do
      expect(cache.fetch(key)).to eq(now)
    end
  end

  describe "fetch_number" do
    context "when the number doesn't exist" do
      let(:key) { "non_value" }

      it "returns 0 instead of nil" do
        expect(cache.fetch_number(key)).to eq(0)
      end
    end

    context "when the number exists" do
      let(:key) { "num_value" }
      before    { cache.set(key, 10) }
      after     { cache.delete(key)  }

      it "returns the number" do
        expect(cache.fetch_number(key)).to eq(10)
      end
    end
  end

  describe "delete" do
    before do
      cache.set("key", "value")
    end

    it "erases the key value" do
      expect(cache.fetch("key")).to eq("value")
      cache.delete("key")
      expect(cache.fetch("key")).to be_nil
    end
  end
end
