require 'spec_helper'

describe SS::Config do
  describe "#env" do
    it { expect(SS.config.env.multibyte_filename).to be_present }
  end

  describe "#method_missing" do
    it { expect(SS.config.cms.serve_static_pages).to be_present }

    it "not to raise NoMethodError" do
      method_name = "method_#{unique_id}".to_sym
      expect { SS.config.send(method_name) }.not_to raise_error
    end
  end

  describe "#respond_to?" do
    it do
      expect(SS.config.respond_to?("cms")).to be_truthy
      expect(SS.config.respond_to?(:cms)).to be_truthy
      expect(SS.config.respond_to?("cms-#{unique_id}")).to be_falsey
    end
  end
end
