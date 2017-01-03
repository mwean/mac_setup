describe MacSetup::ServicesInstaller do
  let(:config) { empty_config }
  let(:status) { instance_double(MacSetup::SystemStatus, installed_taps: ["homebrew/services"]) }
  let(:sandbox_path) { Pathname.new("spec/sandbox").expand_path }
  let(:launch_agents_path) { sandbox_path.join("LaunchAgents").to_s }

  before(:each) do
    stub_const("MacSetup::ServicesInstaller::LAUNCH_AGENTS_PATH", launch_agents_path)
    FakeShell.stub(/brew services list/, with: services_list(service_statuses))

    config.services = services
  end

  after(:each) { FileUtils.rm_rf(launch_agents_path) }

  context "no services are specified" do
    let(:services) { [] }
    let(:service_statuses) { {} }

    it "does not create the LaunchAgents directory" do
      FileUtils.rmdir(launch_agents_path)

      run_installer

      expect(Pathname.new(launch_agents_path)).not_to exist
    end
  end

  context "services are specified" do
    let(:services) { %w(service1 service2) }
    let(:service_statuses) { {} }

    it "creates the LaunchAgents directory" do
      FileUtils.rmdir(launch_agents_path)

      run_installer

      expect(Pathname.new(launch_agents_path)).to exist
    end

    it "starts the services" do
      run_installer

      services.each do |service|
        expect("brew services start #{service}").to have_been_run
      end
    end

    context "a service is already started" do
      let(:service_statuses) { { service2: :started } }

      it "restarts the service" do
        run_installer

        expect("brew services start service1").to have_been_run
        expect("brew services restart service2").to have_been_run
      end
    end

    context "a service is loaded but not started" do
      let(:service_statuses) { { service2: :stopped } }

      it "restarts the service" do
        run_installer

        expect("brew services start service1").to have_been_run
        expect("brew services start service2").to have_been_run
      end
    end
  end

  def run_installer
    quiet { MacSetup::ServicesInstaller.run(config, status) }
  end

  def services_list(service_statuses)
    header = "Name Status User Plist"

    service_lines = service_statuses.map do |service, status|
      "#{service} #{status} Jim /Users/Jim/Library/LaunchAgents/homebrew.mxcl.#{service}.plist"
    end

    ([header] + service_lines).join("\n")
  end
end
