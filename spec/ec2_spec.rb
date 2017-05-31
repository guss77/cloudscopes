module Cloudscopes

RSpec.describe Ec2 do
  subject(:ec2) { Ec2.new }

  describe ".runs_on_ec2?" do
    subject(:runs_on_ec2?) { Ec2.runs_on_ec2? }
    let(:hypervisor_uuid) { nil }
    let(:dmi_product_uuid) { nil }

    before do
      allow(File).to receive(:exists?).and_return(false)
      if hypervisor_uuid
        path = '/sys/hypervisor/uuid'
        allow(File).to receive(:exists?).with(path).and_return(true)
        allow(File).to receive(:read).with(path).and_return(hypervisor_uuid)
      end
      if dmi_product_uuid
        path = '/sys/devices/virtual/dmi/id/product_uuid'
        allow(File).to receive(:exists?).with(path).and_return(true)
        allow(File).to receive(:read).with(path).and_return(dmi_product_uuid)
      end
    end

    context "on non EC2 instance" do
      it { is_expected.to be false }

      context "which has hypervisor UUID" do
        let(:hypervisor_uuid) { 'non-ec2' }

        it { is_expected.to be false }
      end

      context "which has no hypervisor UUID but DMI product UUID" do
        let(:dmi_product_uuid) { 'non-ec2' }

        it { is_expected.to be false }
      end
    end

    context "on EC2 instance" do
      context "which has hypervisor UUID" do
        let(:hypervisor_uuid) { 'ec2whatever' }

        it { is_expected.to be true }
      end

      context "which has no hypervisor UUID but DMI product UUID" do
        let(:dmi_product_uuid) { 'EC2WHATEVER' }

        it { is_expected.to be true }
      end
    end
  end

  describe "#instance_id" do
    subject(:instance_id) { ec2.instance_id }

    # current implementation uses class variable
    # unset it here to avoid side-effects
    before { Ec2.class_variable_set('@@instance_id', nil) }

    it "delivers the instance ID from the instance's metadata" do
      expect(Net::HTTP).
          to receive(:get).with(URI("http://169.254.169.254/latest/meta-data/instance-id")).
          and_return("metadata instance ID")
      expect(ec2.instance_id).to eq("metadata instance ID")
    end

    it "does not lookup twice" do
      expect(Net::HTTP).to receive(:get).exactly(:once).and_return("instance ID")
      expect(ec2.instance_id).to eq("instance ID")
      expect(ec2.instance_id).to eq("instance ID")
      expect(ec2.instance_id).to eq("instance ID")
    end
  end

  describe "#availability_zone" do
    subject(:availability_zone) { ec2.availability_zone }

    # current implementation uses class variable
    # unset it here to avoid side-effects
    before { Ec2.class_variable_set('@@availability_zone', nil) }

    it "delivers the availability zone from the instance's metadata" do
      expect(Net::HTTP).to receive(:get).
          with(URI("http://169.254.169.254/latest/meta-data/placement/availability-zone")).
          and_return("metadata AZ")
      expect(ec2.availability_zone).to eq("metadata AZ")
    end

    it "does not lookup twice" do
      expect(Net::HTTP).to receive(:get).exactly(:once).and_return("AZ")
      expect(ec2.availability_zone).to eq("AZ")
      expect(ec2.availability_zone).to eq("AZ")
      expect(ec2.availability_zone).to eq("AZ")
    end
  end
end

end
