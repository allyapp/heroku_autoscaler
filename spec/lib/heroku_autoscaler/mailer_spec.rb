describe HerokuAutoscaler::Mailer do
  let(:email_config) do
    {
      delivery_method: :test,
      address: "smtp.gmail.com",
      port: 587,
      domain: "test.com",
      user_name: "user@test.com",
      password: "pass",
      enable_starttls_auto: true,
      to: "customer@gmail.com"
    }
  end
  let(:mailer) { described_class.new(email_config) }

  describe "config!" do
    it "calls delivery_method with the right settings" do
      setup_keys = [:address, :port, :domain, :user_name, :password, :enable_starttls_auto]
      setup_hash = email_config.select { |k,_| setup_keys.include?(k) }
      expect_any_instance_of(Mail::Configuration).to receive(:delivery_method)
                      .with(email_config[:delivery_method], setup_hash)
      mailer.config!
    end
  end

  describe "deliver" do
    include Mail::Matchers

    let(:body)    { "Body: Test" }
    let(:subject) { "Subjet: Testing" }
    before do
      Mail::TestMailer.deliveries.clear
      mailer.config!
      mailer.deliver(subject, body)
    end

    it "sends the email" do
      should have_sent_email
    end

    it "sends the email from the right sender" do
      should have_sent_email.from(email_config[:user_name])
    end

    it "sends the email to the right receiver" do
      should have_sent_email.to(email_config[:to])
    end

    it "sends the subject in the email" do
      should have_sent_email.with_subject(subject)
    end

    it "sends the body in the email" do
      should have_sent_email.with_body(body)
    end
  end
end
