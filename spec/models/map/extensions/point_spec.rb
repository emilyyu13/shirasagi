require 'spec_helper'

describe Map::Extensions::Point, dbscope: :example do
  describe '#initialize' do
    it do
      point = described_class[loc: [34.0676396, 134.5891117], zoom_level: 8]
      expect(point).to be_a(described_class)
      expect(point.loc.lat).to eq 34.0676396
      expect(point.loc.lng).to eq 134.5891117
      expect(point.zoom_level).to eq 8
    end
  end

  describe '#mongoize' do
    it do
      point = described_class[loc: [34.0676396, 134.5891117], zoom_level: 8].mongoize
      expect(point).to be_a(Hash)
      expect(point['loc'][0]).to eq 34.0676396
      expect(point['loc'][1]).to eq 134.5891117
      expect(point['zoom_level']).to eq 8
    end
  end

  describe '#empty?' do
    it do
      point = described_class[loc: [34.0676396, 134.5891117], zoom_level: 8]
      expect(point.empty?).to be_falsey
      expect(point.blank?).to be_falsey
      expect(point.present?).to be_truthy
    end

    it do
      point = described_class.new
      expect(point.empty?).to be_truthy
      expect(point.blank?).to be_truthy
      expect(point.present?).to be_falsey
    end

    it do
      point = described_class[loc: []]
      expect(point.empty?).to be_truthy
      expect(point.blank?).to be_truthy
      expect(point.present?).to be_falsey
    end
  end

  describe ".demongoize" do
    it do
      point = described_class.demongoize(loc: [ 34.0676396, 134.5891117 ], zoom_level: 8)
      expect(point).to be_a(described_class)
      expect(point.loc.lat).to eq 34.0676396
      expect(point.loc.lng).to eq 134.5891117
      expect(point.zoom_level).to eq 8
    end

    it do
      point = described_class.demongoize({})
      expect(point).to be_a(described_class)
      expect(point.loc).to be_nil
      expect(point.zoom_level).to be_nil
    end

    it do
      point = described_class.demongoize(nil)
      expect(point).to be_a(described_class)
      expect(point.loc).to be_nil
      expect(point.zoom_level).to be_nil
    end
  end

  describe '.mongoize' do
    it do
      point = described_class.mongoize(described_class[loc: [34.0676396, 134.5891117], zoom_level: 8])
      expect(point).to be_a(Hash)
      expect(point['loc'][0]).to eq 34.0676396
      expect(point['loc'][1]).to eq 134.5891117
      expect(point['zoom_level']).to eq 8
    end

    it do
      point = described_class.mongoize(loc: [ 34.0676396, 134.5891117 ], zoom_level: 8)
      expect(point).to be_a(Hash)
      expect(point['loc'][0]).to eq 34.0676396
      expect(point['loc'][1]).to eq 134.5891117
      expect(point['zoom_level']).to eq 8
    end

    it do
      point = described_class.mongoize("loc"=>{"lng"=>"134.5891117", "lat"=>"34.0676396"}, "zoom_level"=>"8")
      expect(point).to be_a(Hash)
      expect(point['loc'][0]).to eq 34.0676396
      expect(point['loc'][1]).to eq 134.5891117
      expect(point['zoom_level']).to eq 8
    end

    it do
      point = described_class.mongoize("loc"=>{"lng"=>"134.5891117", "lat"=>"34.0676396"}, "zoom_level"=>"xyz")
      expect(point).to be_a(Hash)
      expect(point['loc'][0]).to eq 34.0676396
      expect(point['loc'][1]).to eq 134.5891117
      expect(point['zoom_level']).to be_nil
    end

    it do
      point = described_class.mongoize("loc"=>"", "zoom_level"=>"")
      expect(point).to be_a(Hash)
      expect(point).to eq({})
    end

    it do
      point = described_class.mongoize("loc"=>"", "zoom_level"=>"8")
      expect(point).to be_a(Hash)
      expect(point).to eq({})
    end
  end

  describe ".evolve" do
    it do
      point = described_class.evolve(described_class[loc: [34.0676396, 134.5891117], zoom_level: 8])
      expect(point).to be_a(Hash)
      expect(point['loc'][0]).to eq 34.0676396
      expect(point['loc'][1]).to eq 134.5891117
      expect(point['zoom_level']).to eq 8
    end

    it do
      point = described_class.evolve(loc: [ 34.0676396, 134.5891117 ], zoom_level: 8)
      expect(point).to be_a(Hash)
      expect(point['loc'][0]).to eq 34.0676396
      expect(point['loc'][1]).to eq 134.5891117
      expect(point['zoom_level']).to eq 8
    end
  end

  let(:point) { described_class.new }

  describe "validation" do
    context "when name contains script tag" do
      it "removes script tag" do
        point["name"] = "<script>alert('test')</script>"
        expect(point["name"]).to eq ""
      end
    end

    context "when text contains script tag" do
      it "removes script tag" do
        point["text"] = "<script>alert('test')</script>"
        expect(point["text"]).to eq ""
      end
    end

    context "when name contains valid text" do
      it "does not raise error" do
        expect do
          point["name"] = "テストマーカー"
        end.not_to raise_error
      end
    end

    context "when text contains valid text" do
      it "does not raise error" do
        expect do
          point["text"] = "テスト説明"
        end.not_to raise_error
      end
    end

    context "when name contains HTML tags" do
      it "removes HTML tags" do
        point["name"] = "テスト"
        expect(point["name"]).to eq "テスト"
      end
    end

    context "when text contains HTML tags" do
      it "removes HTML tags" do
        point["text"] = "テスト"
        expect(point["text"]).to eq "テスト"
      end
    end
  end

  describe "existing data sanitization" do
    context "when initializing with script tag in name" do
      it "removes script tag from name" do
        point = described_class.new("name" => "<script>alert('test')</script>")
        expect(point["name"]).to eq ""
      end
    end

    context "when initializing with script tag in text" do
      it "removes script tag from text" do
        point = described_class.new("text" => "<script>alert('test')</script>")
        expect(point["text"]).to eq ""
      end
    end

    context "when initializing with valid name" do
      it "keeps the name unchanged" do
        point = described_class.new("name" => "テストマーカー")
        expect(point["name"]).to eq "テストマーカー"
      end
    end

    context "when initializing with valid text" do
      it "keeps the text unchanged" do
        point = described_class.new("text" => "テスト説明")
        expect(point["text"]).to eq "テスト説明"
      end
    end

    context "when initializing with multiple fields" do
      it "sanitizes all fields correctly" do
        point = described_class.new(
          "name" => "<script>alert('test')</script>",
          "text" => "<script>alert('test2')</script>",
          "loc" => [34.0676396, 134.5891117]
        )
        expect(point["name"]).to eq ""
        expect(point["text"]).to eq ""
        expect(point.loc.lat).to eq 34.0676396
        expect(point.loc.lng).to eq 134.5891117
      end
    end
  end
end
